#!/usr/bin/env python3
"""
1_hardware.py

Installs Intel graphics drivers (including 32-bit for Steam/Proton),
firmware, power management, PipeWire, NetworkManager, Bluetooth and CUPS,
then enables the relevant services.

Snapshot behaviour
------------------
Takes exactly ONE pre-install and ONE post-install snapper snapshot for the
whole run instead of letting snap-pac create a pre/post pair for every
individual pacman transaction.

On Ctrl-C / SIGTERM the script restores the terminal scroll region and
re-enables per-transaction snap-pac snapshots before exiting.

Conflicts
---------
Each package installs with --noconfirm first (silent, fast path). If a
package fails — most commonly a pacman package conflict, e.g.
pipewire-jack vs. jack2, where --noconfirm auto-declines the removal
prompt by pacman's own hardcoded default — that one package is retried
without --noconfirm, so pacman's real "Remove X? [y/N]" prompt reaches
the terminal and you decide what to keep.

UI
--
While packages install, a status bar is pinned to the last line of the
terminal.  yay's own output scrolls in the region above it.  Falls back to
plain sequential output when stdout is not a TTY.
"""

from __future__ import annotations

import atexit
import shutil
import signal
import subprocess
import sys
import time
from typing import List, Sequence


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SNAPPER_CONFIG = "root"
DESC_PRE = "pre: 1_hardware.py"
DESC_POST = "post: 1_hardware.py"

# ---------------------------------------------------------------------------
# Package lists
# ---------------------------------------------------------------------------
GRAPHICS_PKGS = [
    "mesa",
    "vulkan-icd-loader",
    "vulkan-intel",
    "intel-media-driver",
    "libva-utils",
    # 32-bit libraries required by Steam + Proton / most Windows games
    "lib32-mesa",
    "lib32-vulkan-intel",
]

FIRMWARE_PKGS = [
    "intel-ucode",
    "linux-firmware",
]

POWER_PKGS = [
    "power-profiles-daemon",
    "upower",
]

AUDIO_PKGS = [
    "pipewire",
    "pipewire-alsa",
    "pipewire-pulse",
    "pipewire-jack",
    "wireplumber",
]

NETWORK_PKGS = [
    "networkmanager",
]

BLUETOOTH_PKGS = [
    "bluez",
    "bluez-utils",
    "blueman",
]

PRINTING_PKGS = [
    "cups",
    "ghostscript",
    "system-config-printer",
    "cups-pdf",
    # Uncommment for printers discovered via network
    # "avahi",
    # "nss-mdns",
]

ALL_PKGS = (
    GRAPHICS_PKGS
    + FIRMWARE_PKGS
    + POWER_PKGS
    + AUDIO_PKGS
    + NETWORK_PKGS
    + BLUETOOTH_PKGS
    + PRINTING_PKGS
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def run(cmd: Sequence[str], *, check: bool = True, capture: bool = False) -> subprocess.CompletedProcess:
    """Thin wrapper around subprocess.run."""
    return subprocess.run(
        cmd,
        check=check,
        text=True,
        capture_output=capture,
    )


def run_sudo(cmd: Sequence[str], **kwargs) -> subprocess.CompletedProcess:
    return run(["sudo", *cmd], **kwargs)


def which(cmd: str) -> bool:
    return shutil.which(cmd) is not None


# ---------------------------------------------------------------------------
# Status-bar TUI (only active when stdout is a real terminal)
# ---------------------------------------------------------------------------
USE_TUI = sys.stdout.isatty()
BAR_ROW = 0
BAR_HEIGHT = 1       # 1 (single line) or 2 (bar + text on separate lines)
LOG_BOTTOM = 0
NARROW_COLS = 60     # below this width, split the bar and text onto 2 lines
MIN_BAR_WIDTH = 10   # never render a bar shorter than this
_cleanup_done = False


def setup_screen() -> None:
    global BAR_ROW, BAR_HEIGHT, LOG_BOTTOM
    if not USE_TUI:
        return
    size = shutil.get_terminal_size()
    rows, cols = size.lines, size.columns
    # Decided once, at setup time, since it determines how many rows we
    # carve out of the scroll region — not re-evaluated per redraw (that
    # would desync the reserved rows from the actual scroll region without
    # also handling SIGWINCH, which this script doesn't).
    BAR_HEIGHT = 2 if cols < NARROW_COLS else 1
    BAR_ROW = rows
    LOG_BOTTOM = rows - BAR_HEIGHT
    # hide cursor
    sys.stdout.write("\033[?25l")
    # set scroll region to lines 1 .. LOG_BOTTOM
    sys.stdout.write(f"\033[1;{LOG_BOTTOM}r")
    # park cursor at bottom of the scroll region
    sys.stdout.write(f"\033[{LOG_BOTTOM};1H")
    sys.stdout.flush()


def restore_screen() -> None:
    if not USE_TUI:
        return
    # reset scroll region
    sys.stdout.write("\033[r")
    # explicitly clear every reserved bottom row — resetting the scroll
    # region above only changes future scrolling behaviour, it does NOT
    # erase whatever the status bar last drew there. Without this, an
    # interrupted run (Ctrl-C) leaves the stale progress bar frozen on
    # screen, since no further output happens afterwards to scroll it away.
    if BAR_ROW:
        for row in range(BAR_ROW - BAR_HEIGHT + 1, BAR_ROW + 1):
            sys.stdout.write(f"\033[{row};1H\033[2K")
    # show cursor
    sys.stdout.write("\033[?25h")
    sys.stdout.write("\n")
    sys.stdout.flush()


def _truncate(s: str, max_len: int) -> str:
    """Shorten s to at most max_len chars, with a trailing ellipsis if cut."""
    if max_len <= 0:
        return ""
    if len(s) <= max_len:
        return s
    if max_len == 1:
        return "…"
    return s[: max_len - 1] + "…"


def draw_bar(installed: int, total: int, pkg: str) -> None:
    if not USE_TUI:
        print(f"  ({installed}/{total}) installing: {pkg}")
        return

    pct = (installed * 100) // total if total else 100
    cols = shutil.get_terminal_size().columns

    sys.stdout.write("\0337")  # save cursor position

    if BAR_HEIGHT == 2:
        # Narrow terminal: the bar gets its own full-width line, stats
        # (percentage / counts / current package) go on the line below,
        # truncated with an ellipsis if they don't fit.
        bar_width = max(cols - 2, 1)
        filled = (pct * bar_width) // 100
        bar = "#" * filled + "-" * (bar_width - filled)
        stats = _truncate(
            f"{pct:3d}% | {installed}/{total} installed | {pkg}", cols
        )

        sys.stdout.write(f"\033[{BAR_ROW - 1};1H\033[2K")
        sys.stdout.write(f"\033[7m[{bar}]\033[0m")
        sys.stdout.write(f"\033[{BAR_ROW};1H\033[2K")
        sys.stdout.write(f"\033[7m{stats:<{cols}}\033[0m")
    else:
        # Wide terminal: one line. The text (percentage, counts, current
        # package — truncated with an ellipsis if needed) is laid out
        # first, and the bar stretches to fill whatever width is left.
        prefix = f"{pct:3d}% | {installed}/{total} installed | installing: "
        chrome = len(prefix) + 4  # "[" "] " and a leading/trailing space
        pkg_budget = max(cols - chrome - MIN_BAR_WIDTH, 3)
        pkg_display = _truncate(pkg, pkg_budget)
        text = f"{prefix}{pkg_display}"

        bar_width = max(cols - len(text) - 4, MIN_BAR_WIDTH)
        filled = (pct * bar_width) // 100
        bar = "#" * filled + "-" * (bar_width - filled)

        line = f" [{bar}] {text} "
        line = line[:cols].ljust(cols)  # hard clamp, never overflow the row

        sys.stdout.write(f"\033[{BAR_ROW};1H\033[2K")
        sys.stdout.write(f"\033[7m{line}\033[0m")

    sys.stdout.write("\0338")  # restore cursor position
    sys.stdout.flush()


# ---------------------------------------------------------------------------
# Cleanup – always restore terminal + re-enable snap-pac
# ---------------------------------------------------------------------------
def cleanup() -> None:
    global _cleanup_done
    if _cleanup_done:
        return
    _cleanup_done = True

    restore_screen()
    print("==> Re-enabling per-transaction snap-pac snapshots")
    try:
        run_sudo(
            ["snapper", "-c", SNAPPER_CONFIG, "set-config", "PACMAN_PRE_POST=yes"],
            check=False,
        )
    except Exception:
        pass


def _signal_handler(signum, frame) -> None:
    cleanup()
    sys.exit(128 + signum)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    # verify snapper config exists
    result = run_sudo(["snapper", "list-configs"], capture=True)
    configs = {line.split()[0] for line in result.stdout.splitlines() if line.strip()}
    if SNAPPER_CONFIG not in configs:
        print(
            f"Snapper config '{SNAPPER_CONFIG}' not found. "
            "Run 'snapper list-configs' and update SNAPPER_CONFIG.",
            file=sys.stderr,
        )
        sys.exit(1)

    if not ALL_PKGS:
        print("Package list is empty — nothing to install.", file=sys.stderr)
        sys.exit(1)

    # register cleanup handlers
    atexit.register(cleanup)
    signal.signal(signal.SIGINT, _signal_handler)
    signal.signal(signal.SIGTERM, _signal_handler)

    # ---- pre-snapshot + disable per-transaction hooks ---------------------
    print("==> Creating pre-install snapshot")
    result = run_sudo(
        [
            "snapper", "-c", SNAPPER_CONFIG,
            "create", "--type", "pre",
            "--print-number",
            "--description", DESC_PRE,
        ],
        capture=True,
    )
    pre_num = result.stdout.strip()
    print(f"    pre snapshot #{pre_num}")

    print("==> Disabling per-transaction snap-pac snapshots for this run")
    run_sudo(
        ["snapper", "-c", SNAPPER_CONFIG, "set-config", "PACMAN_PRE_POST=no"]
    )

    # ---- install packages -------------------------------------------------
    total = len(ALL_PKGS)
    installed = 0
    failed: List[str] = []

    setup_screen()

    try:
        for pkg in ALL_PKGS:
            draw_bar(installed, total, pkg)
            # check=False: one failing/conflicting package should not take
            # down the rest of the run — record it and keep going.
            result = run(["yay", "-S", "--needed", "--noconfirm", pkg], check=False)

            if result.returncode != 0:
                # --noconfirm auto-declines pacman's own "Remove X? [y/N]"
                # conflict prompt (that default is hardcoded in pacman, not
                # something --noconfirm can flip). Rather than guess what to
                # do, drop out of the status bar and retry this one package
                # *without* --noconfirm, so pacman's real prompt reaches the
                # terminal and you can choose what to keep.
                restore_screen()
                print(
                    f"\n==> '{pkg}' failed non-interactively — retrying so you "
                    "can answer any prompt yourself (e.g. which package to keep):"
                )
                result = run(["yay", "-S", "--needed", pkg], check=False)
                setup_screen()

                if result.returncode != 0:
                    failed.append(pkg)

            installed += 1

        draw_bar(installed, total, "done")
        time.sleep(0.3)
    finally:
        restore_screen()

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    # ---- enable services --------------------------------------------------
    print("==> Enabling system services")
    for svc in (
        "NetworkManager.service",
        "bluetooth.service",
        "cups.service",
        "avahi-daemon.service",
        "power-profiles-daemon.service",
    ):
        run_sudo(["systemctl", "enable", "--now", svc])

    print("==> Enabling PipeWire user services")
    try:
        # Check whether a user session bus is available
        run(
            ["systemctl", "--user", "is-system-running"],
            check=False,
            capture=True,
        )
        run(
            [
                "systemctl", "--user", "enable", "--now",
                "pipewire.service",
                "pipewire-pulse.service",
                "wireplumber.service",
            ]
        )
    except Exception:
        print("    No active user session bus — enable these manually after your next login:")
        print(
            "    systemctl --user enable --now "
            "pipewire.service pipewire-pulse.service wireplumber.service"
        )

    # ---- post-snapshot ----------------------------------------------------
    print("==> Creating post-install snapshot")
    result = run_sudo(
        [
            "snapper", "-c", SNAPPER_CONFIG,
            "create", "--type", "post",
            "--pre-number", pre_num,
            "--print-number",
            "--description", DESC_POST,
        ],
        capture=True,
    )
    post_num = result.stdout.strip()
    print(f"    post snapshot #{post_num} (paired with pre #{pre_num})")

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
