#!/usr/bin/env python3

"""
Cleanup script to remove packages not needed on server profile.
This script compares installed packages with what should be on server
and removes unnecessary packages.
"""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import Set, List


# Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


def extract_packages(brewfile_path: Path) -> Set[str]:
    """Extract cask package names from a Brewfile."""
    packages = set()

    if not brewfile_path.exists():
        return packages

    with open(brewfile_path, 'r') as f:
        for line in f:
            line = line.strip()
            # Look for cask lines
            if line.startswith('cask '):
                # Remove comments
                line = line.split('#')[0].strip()
                # Extract package name between quotes
                if '"' in line:
                    parts = line.split('"')
                    if len(parts) >= 2:
                        packages.add(parts[1])

    return packages


def get_expected_packages(dotfiles_dir: Path) -> Set[str]:
    """Get list of packages that should be on server."""
    profiles_dir = dotfiles_dir / 'profiles'
    packages = set()

    # Combine base + server profiles
    base_file = profiles_dir / 'base.Brewfile'
    server_file = profiles_dir / 'server.Brewfile'

    packages.update(extract_packages(base_file))
    packages.update(extract_packages(server_file))

    return packages


def get_installed_casks() -> Set[str]:
    """Get list of installed cask packages."""
    try:
        result = subprocess.run(
            ['brew', 'list', '--cask'],
            capture_output=True,
            text=True,
            check=True
        )
        return set(result.stdout.strip().split('\n'))
    except subprocess.CalledProcessError:
        return set()


def find_packages_to_remove(expected: Set[str], installed: Set[str]) -> List[str]:
    """Find packages that should be removed."""
    to_remove = installed - expected
    return sorted(to_remove)


def uninstall_package(package: str) -> bool:
    """Uninstall a single cask package."""
    try:
        subprocess.run(
            ['brew', 'uninstall', '--cask', package],
            capture_output=True,
            check=True,
            stdin=subprocess.DEVNULL
        )
        return True
    except subprocess.CalledProcessError:
        return False


def get_current_profile() -> str:
    """Get current dotfiles profile."""
    profile_file = Path.home() / '.dotfiles-profile'
    if profile_file.exists():
        return profile_file.read_text().strip()
    return 'unknown'


def main():
    parser = argparse.ArgumentParser(
        description='Remove packages not needed on server profile',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --dry-run    # See what would be removed
  %(prog)s              # Interactive cleanup
  %(prog)s --yes        # Remove without confirmation
        """
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be removed without actually removing'
    )
    parser.add_argument(
        '--yes',
        action='store_true',
        help='Skip confirmation prompt'
    )

    args = parser.parse_args()

    # Header
    print(f"{Colors.BLUE}{'━' * 60}{Colors.NC}")
    print(f"{Colors.BLUE}  Server Package Cleanup{Colors.NC}")
    print(f"{Colors.BLUE}{'━' * 60}{Colors.NC}")
    print()

    # Check profile
    current_profile = get_current_profile()
    if current_profile != 'server':
        print(f"{Colors.YELLOW}⚠️  Warning: Current profile is '{current_profile}', not 'server'{Colors.NC}")
        print(f"{Colors.YELLOW}   This script is intended for server profile only{Colors.NC}")
        print()
        if not args.yes and not args.dry_run:
            response = input("Continue anyway? (y/N): ")
            if response.lower() != 'y':
                print("Cancelled.")
                return 0

    # Get dotfiles directory
    script_dir = Path(__file__).resolve().parent
    dotfiles_dir = script_dir.parent

    print("🔍 Analyzing installed packages...")
    print()

    # Find packages to remove
    expected = get_expected_packages(dotfiles_dir)
    installed = get_installed_casks()
    packages_to_remove = find_packages_to_remove(expected, installed)

    if not packages_to_remove:
        print(f"{Colors.GREEN}✅ No unnecessary packages found!{Colors.NC}")
        print("Your server is already clean.")
        return 0

    # Show packages to remove
    print(f"{Colors.YELLOW}Found {len(packages_to_remove)} package(s) to remove:{Colors.NC}")
    print()
    for pkg in packages_to_remove:
        print(f"  {Colors.RED}✗{Colors.NC} {pkg}")
    print()

    if args.dry_run:
        print(f"{Colors.BLUE}[DRY RUN]{Colors.NC} No packages were removed.")
        print("Run without --dry-run to actually remove these packages.")
        return 0

    # Confirm
    if not args.yes:
        print(f"{Colors.YELLOW}⚠️  WARNING: This will remove the packages listed above{Colors.NC}")
        print()
        response = input("Proceed with removal? (y/N): ")
        if response.lower() != 'y':
            print("Cancelled.")
            return 0
        print()

    # Remove packages
    print("🗑️  Removing packages...")
    print()

    success_count = 0
    fail_count = 0

    for pkg in packages_to_remove:
        print(f"Removing {pkg}... ", end='', flush=True)
        if uninstall_package(pkg):
            print(f"{Colors.GREEN}✓{Colors.NC}")
            success_count += 1
        else:
            print(f"{Colors.RED}✗{Colors.NC}")
            fail_count += 1

    # Summary
    print()
    print(f"{Colors.GREEN}{'━' * 60}{Colors.NC}")
    print(f"{Colors.GREEN}✨ Cleanup complete!{Colors.NC}")
    print(f"{Colors.GREEN}{'━' * 60}{Colors.NC}")
    print()
    print(f"Successfully removed: {success_count}")
    if fail_count > 0:
        print(f"Failed to remove: {fail_count}")
    print()
    print("Next steps:")
    print("  1. Run: brew cleanup (to remove old versions)")
    print("  2. Verify: brew list --cask (to see remaining packages)")
    print()

    return 0


if __name__ == '__main__':
    sys.exit(main())
