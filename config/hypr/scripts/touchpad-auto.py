#!/usr/bin/env python3
"""Disables the touchpad whenever any other pointer (USB or Bluetooth mouse) is connected.
Handles ELAN-style touchpads that report as two separate device nodes
(e.g. "elan079c:00-04f3:3244-mouse" + "elan079c:00-04f3:3244-touchpad")."""

import fcntl
import json
import os
import re
import subprocess
import sys
import time

RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
LOCK_PATH = os.path.join(RUNTIME_DIR, "touchpad-auto.lock")
LOG_PATH = os.path.join(RUNTIME_DIR, "touchpad-auto.log")


def acquire_lock():
    """Open (or create) the lock file and try to grab an exclusive, non-blocking
    lock on it. If another instance already holds it, exit quietly — same idea
    as `flock -n 9 || exit 0` in the bash version."""
    lock_file = open(LOCK_PATH, "w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)
    return lock_file  # caller must keep this referenced — closing it releases the lock


def get_devices() -> dict:
    """Ask Hyprland for the current device list and parse it as JSON directly —
    no jq needed."""
    result = subprocess.run(
        ["hyprctl", "devices", "-j"], capture_output=True, text=True, check=True
    )
    return json.loads(result.stdout)


def get_touchpad_name() -> str | None:
    for mouse in get_devices().get("mice", []):
        if re.search("touchpad", mouse["name"], re.IGNORECASE):
            return mouse["name"]
    return None


def update_touchpad_state(touchpad_name: str) -> None:
    base = touchpad_name.removesuffix("-touchpad")  # e.g. "elan079c:00-04f3:3244"
    external_count = sum(
        1 for m in get_devices().get("mice", []) if not m["name"].startswith(base)
    )
    enabled = "false" if external_count > 0 else "true"
    subprocess.run(
        ["hyprctl", "eval", f"hl.device({{ name = '{touchpad_name}', enabled = {enabled} }})"],
        check=False,
    )


def main():
    _lock_file = acquire_lock()  # kept alive for the whole program — releasing it unlocks

    log_file = open(LOG_PATH, "a", buffering=1)  # line-buffered, like bash's `exec >`
    sys.stdout = log_file
    sys.stderr = log_file

    touchpad_name = get_touchpad_name()
    if not touchpad_name:
        print("touchpad-auto: no touchpad device found")
        sys.exit(1)

    update_touchpad_state(touchpad_name)  # set correct state immediately at startup

    # Stream udev events for hotplugged input devices (USB or Bluetooth).
    proc = subprocess.Popen(
        ["udevadm", "monitor", "--udev", "--subsystem-match=input", "--property"],
        stdout=subprocess.PIPE,
        text=True,
    )
    assert proc.stdout is not None  # guaranteed by stdout=PIPE above
    for line in proc.stdout:
        if line.startswith("UDEV"):
            time.sleep(0.6)  # let Bluetooth's handshake finish before checking
            update_touchpad_state(touchpad_name)


if __name__ == "__main__":
    main()
