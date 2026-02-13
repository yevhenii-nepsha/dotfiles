#!/usr/bin/env python3
"""Delete low-rated albums from Navidrome music library.

Fetches all albums via Subsonic API (for ratings), resolves full paths
via Navidrome native API, then deletes matching directories from disk.
Dry-run by default; use --execute to actually delete.

Usage:
    env $(cat .env | xargs) ./scripts/clean-navidrome-ratings.py --execute
"""

import argparse
import hashlib
import json
import os
import secrets
import shutil
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

DEFAULT_URL = os.environ.get("NAVIDROME_URL", "http://localhost:4533")
DEFAULT_MUSIC_ROOT = "/Volumes/archive/music/Library"
SUBSONIC_API_VERSION = "1.16.1"
SUBSONIC_CLIENT = "navidrome-cleanup"
PAGE_SIZE = 500


def generate_subsonic_params(username: str, password: str) -> dict[str, str]:
    """Generate Subsonic API auth parameters with salted token."""
    salt = secrets.token_hex(16)
    token = hashlib.md5((password + salt).encode()).hexdigest()
    return {
        "u": username,
        "t": token,
        "s": salt,
        "v": SUBSONIC_API_VERSION,
        "c": SUBSONIC_CLIENT,
        "f": "json",
    }


def get_native_token(base_url: str, username: str, password: str) -> str:
    """Authenticate with Navidrome native API and return JWT token."""
    url = f"{base_url}/auth/login"
    payload = json.dumps({"username": username, "password": password}).encode()
    request = urllib.request.Request(
        url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request) as response:
        data = json.loads(response.read())
    return data["token"]


def call_subsonic(
    base_url: str,
    endpoint: str,
    params: dict[str, str],
    extra: dict[str, str | int] | None = None,
) -> dict:
    """Call Subsonic API endpoint and return parsed response."""
    merged = {**params}
    if extra:
        merged.update({k: str(v) for k, v in extra.items()})
    query = urllib.parse.urlencode(merged)
    url = f"{base_url}/rest/{endpoint}.view?{query}"
    request = urllib.request.Request(url)
    with urllib.request.urlopen(request) as response:
        data = json.loads(response.read())

    subsonic_response = data.get("subsonic-response", {})
    if subsonic_response.get("status") != "ok":
        error = subsonic_response.get("error", {})
        raise RuntimeError(
            f"Subsonic API error: {error.get('message', 'unknown')} "
            f"(code {error.get('code', '?')})"
        )
    return subsonic_response


def call_native(
    base_url: str,
    endpoint: str,
    token: str,
    params: dict[str, str | int] | None = None,
) -> list | dict:
    """Call Navidrome native API endpoint and return parsed response."""
    url = f"{base_url}/api/{endpoint}"
    if params:
        query = urllib.parse.urlencode({k: str(v) for k, v in params.items()})
        url = f"{url}?{query}"
    request = urllib.request.Request(
        url,
        headers={"x-nd-authorization": f"Bearer {token}"},
    )
    with urllib.request.urlopen(request) as response:
        return json.loads(response.read())


def fetch_all_albums(base_url: str, params: dict[str, str]) -> list[dict]:
    """Paginate getAlbumList2 and return all albums."""
    albums = []
    offset = 0
    while True:
        response = call_subsonic(
            base_url,
            "getAlbumList2",
            params,
            extra={
                "type": "alphabeticalByName",
                "size": PAGE_SIZE,
                "offset": offset,
            },
        )
        album_list = response.get("albumList2", {})
        batch = album_list.get("album", [])
        if not batch:
            break
        albums.extend(batch)
        if len(batch) < PAGE_SIZE:
            break
        offset += PAGE_SIZE
    return albums


def filter_by_rating(
    albums: list[dict], min_rating: int, max_rating: int
) -> list[dict]:
    """Keep albums where userRating is between min and max inclusive."""
    result = []
    for album in albums:
        rating = album.get("userRating", 0)
        if rating > 0 and min_rating <= rating <= max_rating:
            result.append(album)
    return result


def get_album_dir(base_url: str, token: str, album_id: str) -> str | None:
    """Resolve full relative directory path via native API song lookup."""
    songs = call_native(
        base_url,
        "song",
        token,
        params={
            "album_id": album_id,
            "_start": 0,
            "_end": 1,
            "_order": "ASC",
            "_sort": "title",
        },
    )
    if not songs:
        return None
    # path is "Genre/Artist/(year) Album/track.flac"
    song_path = songs[0].get("path", "")
    if not song_path:
        return None
    return str(Path(song_path).parent)


def build_plan(
    albums: list[dict],
    base_url: str,
    native_token: str,
    music_root: Path,
) -> list[dict]:
    """Build deletion plan with resolved paths for each album."""
    plan = []
    for album in albums:
        album_id = album.get("id", "")
        artist = album.get("artist", "Unknown")
        name = album.get("name", "Unknown")
        rating = album.get("userRating", 0)

        relative_dir = get_album_dir(base_url, native_token, album_id)
        if not relative_dir:
            print(f"  Warning: no songs found for '{artist} - {name}', skipping")
            continue

        full_path = music_root / relative_dir
        plan.append(
            {
                "id": album_id,
                "artist": artist,
                "name": name,
                "rating": rating,
                "relative_dir": relative_dir,
                "full_path": full_path,
                "exists": full_path.exists(),
            }
        )
    return plan


def print_plan(plan: list[dict], dry_run: bool) -> None:
    """Print tabular summary of planned deletions."""
    if not plan:
        print("No albums match the filter criteria.")
        return

    mode = "DRY RUN" if dry_run else "EXECUTE"
    print(f"\n{'=' * 70}")
    print(f"  Mode: {mode} | Albums: {len(plan)}")
    print(f"{'=' * 70}\n")

    for entry in plan:
        status = "" if entry["exists"] else " [NOT FOUND]"
        print(f"  Rating: {entry['rating']}/5")
        print(f"  Artist: {entry['artist']}")
        print(f"  Album:  {entry['name']}")
        print(f"  Path:   {entry['full_path']}{status}")
        print()

    if dry_run:
        print("---")
        print("Dry run complete. Use --execute to delete these directories.")


def execute_deletions(plan: list[dict]) -> tuple[int, int]:
    """Delete album directories from disk. Returns (success, failure) counts."""
    ok_count = 0
    fail_count = 0
    for entry in plan:
        path = entry["full_path"]
        if not entry["exists"]:
            print(f"  Skip (not found): {path}")
            fail_count += 1
            continue
        try:
            shutil.rmtree(path)
            print(f"  Deleted: {path}")
            ok_count += 1
        except PermissionError as exc:
            print(f"  Error (permission denied): {path} — {exc}")
            fail_count += 1
        except OSError as exc:
            print(f"  Error: {path} — {exc}")
            fail_count += 1
    return ok_count, fail_count


def trigger_rescan(base_url: str, params: dict[str, str]) -> None:
    """Trigger Navidrome library rescan via Subsonic API."""
    call_subsonic(base_url, "startScan", params)
    print("Library rescan triggered.")


def main() -> None:
    """Entry point: parse args, fetch albums, filter, delete or dry-run."""
    parser = argparse.ArgumentParser(
        description="Delete low-rated albums from Navidrome library."
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help=f"Navidrome server URL (default: {DEFAULT_URL})",
    )
    parser.add_argument(
        "--music-root",
        type=Path,
        default=Path(DEFAULT_MUSIC_ROOT),
        help=f"Host path to music directory (default: {DEFAULT_MUSIC_ROOT})",
    )
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Actually delete directories (default: dry-run)",
    )
    parser.add_argument(
        "--min-rating",
        type=int,
        default=1,
        help="Minimum rating to delete, inclusive (default: 1)",
    )
    parser.add_argument(
        "--max-rating",
        type=int,
        default=2,
        help="Maximum rating to delete, inclusive (default: 2)",
    )
    args = parser.parse_args()

    username = os.environ.get("NAVIDROME_USER")
    password = os.environ.get("NAVIDROME_PASSWORD")
    if not username or not password:
        print("Error: set NAVIDROME_USER and NAVIDROME_PASSWORD env vars.")
        sys.exit(1)

    dry_run = not args.execute
    base_url = args.url.rstrip("/")
    music_root = args.music_root

    print(f"Server:     {base_url}")
    print(f"Music root: {music_root}")
    print(f"Filter:     rating {args.min_rating}-{args.max_rating}")
    print(f"Mode:       {'DRY RUN' if dry_run else 'EXECUTE'}")

    # Authenticate
    subsonic_params = generate_subsonic_params(username, password)
    native_token = get_native_token(base_url, username, password)

    # Fetch and filter albums
    print("\nFetching albums...")
    start = time.monotonic()
    all_albums = fetch_all_albums(base_url, subsonic_params)
    elapsed = time.monotonic() - start
    print(f"Found {len(all_albums)} albums ({elapsed:.1f}s)")

    matched = filter_by_rating(all_albums, args.min_rating, args.max_rating)
    print(
        f"Matched {len(matched)} albums with rating {args.min_rating}-{args.max_rating}"
    )

    if not matched:
        print("Nothing to do.")
        return

    # Resolve full paths via native API
    print("Resolving paths...")
    plan = build_plan(matched, base_url, native_token, music_root)
    print_plan(plan, dry_run)

    if not dry_run and plan:
        print("\nDeleting directories...")
        ok_count, fail_count = execute_deletions(plan)
        print(f"\nDone: {ok_count} deleted, {fail_count} failed/skipped")

        if ok_count > 0:
            print("\nTriggering library rescan...")
            trigger_rescan(base_url, subsonic_params)


if __name__ == "__main__":
    main()
