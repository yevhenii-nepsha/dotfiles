#!/usr/bin/env python3
"""
Install all available Nerd Fonts using getnf.

This script:
- Installs getnf tool if not present
- Fetches list of all available Nerd Fonts
- Installs all fonts automatically (skips already installed)
"""

import subprocess
import sys
from pathlib import Path
from shutil import which

# Constants
GETNF_BIN = Path.home() / ".local/bin/getnf"
GETNF_INSTALL_URL = "https://raw.githubusercontent.com/getnf/getnf/main/install.sh"

# Colors for terminal output
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
RED = "\033[0;31m"
NC = "\033[0m"  # No Color


def log_info(msg: str) -> None:
    """Print info message in blue."""
    print(f"{BLUE}[INFO] {msg}{NC}")


def log_success(msg: str) -> None:
    """Print success message in green."""
    print(f"{GREEN}[OK] {msg}{NC}")


def log_warning(msg: str) -> None:
    """Print warning message in yellow."""
    print(f"{YELLOW}[WARN] {msg}{NC}")


def log_error(msg: str) -> None:
    """Print error message in red."""
    print(f"{RED}[ERROR] {msg}{NC}")


def check_command(cmd: str) -> bool:
    """Check if command exists in PATH."""
    return which(cmd) is not None


def install_getnf() -> bool:
    """Install getnf tool to ~/.local/bin."""
    log_info("Installing getnf...")
    try:
        result = subprocess.run(
            f"curl -fsSL {GETNF_INSTALL_URL} | bash -s -- --silent",
            shell=True,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            log_error(f"Failed to install getnf: {result.stderr}")
            return False
        log_success("getnf installed successfully")
        return True
    except subprocess.SubprocessError as e:
        log_error(f"Error installing getnf: {e}")
        return False


def parse_font_list(output: str) -> list[str]:
    """Parse font list output from getnf."""
    fonts = []
    for line in output.strip().split("\n"):
        font = line.strip()
        # Skip empty lines, header line (contains ":"), and ANSI escape sequences
        if not font or ":" in font or font.startswith("\x1b"):
            continue
        # Remove any ANSI color codes from font name
        clean_font = font.replace("\x1b[33m", "").replace("\x1b[m", "").strip()
        if clean_font:
            fonts.append(clean_font)
    return fonts


def get_all_fonts() -> list[str]:
    """Get list of all available Nerd Fonts."""
    result = subprocess.run(
        [str(GETNF_BIN), "-L"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []
    return parse_font_list(result.stdout)


def get_installed_fonts() -> list[str]:
    """Get list of already installed Nerd Fonts."""
    result = subprocess.run(
        [str(GETNF_BIN), "-l"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []

    fonts = []
    for line in result.stdout.strip().split("\n"):
        line = line.strip()
        # Skip empty lines, header line, and ANSI escape sequences
        if not line or ":" in line or line.startswith("\x1b"):
            continue
        # Format is "FontName - vX.X.X", extract just the font name
        if " - " in line:
            font_name = line.split(" - ")[0].strip()
            if font_name:
                fonts.append(font_name)
    return fonts


def install_fonts(fonts: list[str]) -> bool:
    """Install specified Nerd Fonts."""
    fonts_str = ",".join(fonts)
    log_info(f"Installing {len(fonts)} Nerd Fonts (this may take a while)...")

    result = subprocess.run(
        [str(GETNF_BIN), "-i", fonts_str],
    )
    return result.returncode == 0


def main() -> int:
    """Main entry point."""
    print()
    log_info("Setting up Nerd Fonts via getnf")
    print()

    # Check dependencies
    if not check_command("curl"):
        log_warning("curl not found, skipping Nerd Fonts installation")
        return 0

    # Ensure ~/.local/bin exists
    local_bin = Path.home() / ".local/bin"
    local_bin.mkdir(parents=True, exist_ok=True)

    # Install getnf if not present
    if not GETNF_BIN.exists():
        if not install_getnf():
            return 1
    else:
        log_info("getnf already installed")

    # Get all available fonts
    all_fonts = get_all_fonts()
    if not all_fonts:
        log_error("Failed to get font list from getnf")
        return 1

    log_info(f"Found {len(all_fonts)} available Nerd Fonts")

    # Get already installed fonts
    installed_fonts = get_installed_fonts()
    log_info(f"Found {len(installed_fonts)} already installed")

    # Calculate fonts to install
    fonts_to_install = [f for f in all_fonts if f not in installed_fonts]

    if not fonts_to_install:
        log_success("All Nerd Fonts are already installed!")
        return 0

    log_info(f"Installing {len(fonts_to_install)} missing fonts...")

    # Install only missing fonts
    if not install_fonts(fonts_to_install):
        log_error("Font installation failed")
        return 1

    print()
    log_success("All Nerd Fonts installed successfully!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
