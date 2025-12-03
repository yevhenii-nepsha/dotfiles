#!/usr/bin/env python3
import os
import subprocess
import sys
from datetime import datetime

VOLUMES = [
    {"volume": "smb://macmini/archive", "mount_point": "/Volumes/archive"},
    {"volume": "smb://macmini/photography", "mount_point": "/Volumes/photography"},
]
LOG_FILE = os.path.expanduser("~/Library/Logs/mount_network_drives.log")


def log(msg, level="INFO"):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] [{level}] {msg}\n"

    # Write to file
    try:
        with open(LOG_FILE, "a") as f:
            f.write(log_msg)
    except Exception as e:
        print(f"Failed to write to log: {e}", file=sys.stderr)

    # Also print to stdout for launchd logs
    print(log_msg.strip())


def is_mounted(mount_point):
    return os.path.ismount(mount_point)


def mount_volume(volume, mount_point):
    if is_mounted(mount_point):
        log(f"Volume already mounted at {mount_point}", "DEBUG")
        return

    log(f"Attempting to mount {volume}")
    try:
        result = subprocess.run(
            ["osascript", "-e", f'mount volume "{volume}"'],
            check=True,
            capture_output=True,
            text=True,
        )
        log(f"Mounted successfully at {mount_point}", "SUCCESS")
        if result.stdout:
            log(f"Output: {result.stdout.strip()}", "DEBUG")
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr.strip() if e.stderr else "Unknown error"
        log(f"Mount failed for {volume}: {error_msg}", "ERROR")
    except Exception as e:
        log(f"Unexpected error for {volume}: {str(e)}", "ERROR")


def mount_all():
    for vol_config in VOLUMES:
        mount_volume(vol_config["volume"], vol_config["mount_point"])


if __name__ == "__main__":
    log("=== Script started ===")
    mount_all()
    log("=== Script finished ===\n")
