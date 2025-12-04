#!/usr/bin/env python3
"""
Convert Obsidian notes to Zettelkasten naming convention.

- Renames files from 'Note Title.md' to 'YYYYMMDDHHmmss.md'
- Adds original title (lowercase) to frontmatter title and aliases
- Sets appropriate tag based on directory (📥 for inbox, 📝 for notes)
- Skips files already named with timestamp
"""

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path

# Directory to tag mapping
DIR_TAGS = {
    "inbox": "📥",
    "notes": "📝",
}


def is_timestamp_name(name: str) -> bool:
    """Check if filename is already a 14-digit timestamp."""
    return bool(re.match(r"^\d{14}$", name))


def get_creation_time(path: Path) -> str:
    """Get file creation time as YYYYMMDDHHmmss."""
    stat = path.stat()
    # macOS: st_birthtime, Linux fallback: st_ctime
    ctime = getattr(stat, "st_birthtime", stat.st_ctime)
    return datetime.fromtimestamp(ctime).strftime("%Y%m%d%H%M%S")


def parse_frontmatter(content: str) -> tuple[dict | None, str, str]:
    """
    Parse frontmatter from content.
    Returns: (frontmatter_dict or None, frontmatter_raw, body)
    """
    if not content.startswith("---"):
        return None, "", content

    # Find closing ---
    match = re.match(r"^---\n(.*?)\n---\n?", content, re.DOTALL)
    if not match:
        return None, "", content

    frontmatter_raw = match.group(1)
    body = content[match.end() :]

    # Simple YAML parsing for our use case
    fm = {}
    for line in frontmatter_raw.split("\n"):
        if ":" in line:
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip()
            fm[key] = value

    return fm, frontmatter_raw, body


def build_frontmatter(
    title: str, tag: str, created: str, existing_fm: dict | None
) -> str:
    """Build new frontmatter with title, tags, aliases, and created date."""
    title_lower = title.lower()

    # Format created date as YYYY-MM-DD HH:MM:SS
    created_formatted = datetime.strptime(created, "%Y%m%d%H%M%S").strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    # Preserve any extra fields from existing frontmatter
    extra_lines = []
    if existing_fm:
        skip_keys = {"title", "tags", "aliases", "created"}
        for key, value in existing_fm.items():
            if key.lower() not in skip_keys:
                extra_lines.append(f"{key}: {value}")

    lines = [
        "---",
        f"title: {title_lower}",
        f"created: {created_formatted}",
        f"tags: [{tag}]",
        "aliases:",
        f"  - {title_lower}",
    ]

    if extra_lines:
        lines.extend(extra_lines)

    lines.append("---")

    return "\n".join(lines) + "\n"


def convert_note(
    path: Path, dir_name: str, dry_run: bool, update_existing: bool = False
) -> dict | None:
    """
    Convert single note.
    Returns info about changes, or None if skipped.
    """
    stem = path.stem  # filename without extension

    # Check if already timestamp
    already_timestamp = is_timestamp_name(stem)

    if already_timestamp and not update_existing:
        return {"path": path, "skipped": True, "reason": "already timestamp"}

    # Get timestamp from filename or creation time
    if already_timestamp:
        timestamp = stem
        new_path = path  # Don't rename
        # Get title from existing frontmatter
        content = path.read_text(encoding="utf-8")
        existing_fm, _, body = parse_frontmatter(content)
        # Use existing title/alias or filename
        title = None
        if existing_fm:
            title = existing_fm.get("title")
            if not title:
                aliases = existing_fm.get("aliases", "")
                if aliases and aliases not in ("[]", ""):
                    # Extract first alias
                    match = re.search(r"\[([^\]]+)\]", aliases)
                    if match:
                        title = match.group(1).strip().strip("'\"")
        if not title:
            title = stem  # fallback to timestamp
    else:
        # Get creation timestamp
        timestamp = get_creation_time(path)
        title = stem

        # Check for collision
        new_path = path.parent / f"{timestamp}.md"
        if new_path.exists() and new_path != path:
            # Add suffix to avoid collision
            suffix = 1
            while new_path.exists():
                new_path = path.parent / f"{timestamp}_{suffix}.md"
                suffix += 1

        # Read content
        content = path.read_text(encoding="utf-8")

        # Parse existing frontmatter
        existing_fm, _, body = parse_frontmatter(content)

    # Get tag for directory
    tag = DIR_TAGS.get(dir_name, "📝")

    # Build new frontmatter
    new_frontmatter = build_frontmatter(title, tag, timestamp, existing_fm)

    # New content
    new_content = new_frontmatter + body

    result = {
        "path": path,
        "new_path": new_path,
        "title": title.lower(),
        "tag": tag,
        "skipped": False,
        "updated": already_timestamp,
    }

    if not dry_run:
        # Write new content
        path.write_text(new_content, encoding="utf-8")
        # Rename file only if path changed
        if new_path != path:
            path.rename(new_path)

    return result


def main():
    parser = argparse.ArgumentParser(
        description="Convert Obsidian notes to Zettelkasten naming convention."
    )
    parser.add_argument("vault", type=Path, help="Path to Obsidian vault")
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Actually perform changes (default is dry-run)",
    )
    parser.add_argument(
        "--dirs",
        nargs="+",
        default=["inbox", "notes"],
        help="Directories to process (default: inbox notes)",
    )
    parser.add_argument(
        "--update-existing",
        action="store_true",
        help="Update frontmatter of existing timestamp files",
    )

    args = parser.parse_args()

    vault_path = args.vault.expanduser().resolve()
    dry_run = not args.execute
    update_existing = args.update_existing

    if not vault_path.exists():
        print(f"Error: Vault path does not exist: {vault_path}")
        sys.exit(1)

    print(f"Vault: {vault_path}")
    print(f"Directories: {', '.join(args.dirs)}")
    print(f"Mode: {'DRY RUN' if dry_run else 'EXECUTE'}")
    if update_existing:
        print("Update existing: YES")
    print()

    results = []
    skipped = []

    for dir_name in args.dirs:
        dir_path = vault_path / dir_name
        if not dir_path.exists():
            print(f"Warning: Directory not found: {dir_path}")
            continue

        for md_file in dir_path.glob("*.md"):
            result = convert_note(md_file, dir_name, dry_run, update_existing)
            if result:
                if result.get("skipped"):
                    skipped.append(result)
                else:
                    results.append(result)

    # Print results
    if results:
        print(f"{'Would convert' if dry_run else 'Converted'} {len(results)} notes:\n")
        for r in results:
            print(f"  {r['path'].name}")
            print(f"    → {r['new_path'].name}")
            print(f"    + title: {r['title']}")
            print(f"    + aliases: [{r['title']}]")
            print(f"    + tags: [{r['tag']}]")
            print()
    else:
        print("No notes to convert.")

    if skipped:
        print(f"Skipped {len(skipped)} notes (already timestamp):")
        for s in skipped:
            print(f"  ⏭ {s['path'].name}")
        print()

    if dry_run and results:
        print("---")
        print("Dry run complete. Use --execute to apply changes.")


if __name__ == "__main__":
    main()
