#!/usr/bin/env python3
"""
1_hardware.py

Installs Intel graphics drivers (including 32-bit for Steam/Proton),
firmware, power management, PipeWire, NetworkManager, Bluetooth and CUPS.
Each package's services (see the Package/Service model below) are enabled
immediately after that package installs, not batched at the end of the run.

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


import sys
import time
from typing import List

from utils.command_runner import install_config_and_enable
from utils.package import Package, Service
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
GRAPHICS_PKGS = [
    Package("mesa"),
    Package("vulkan-icd-loader"),
    Package("vulkan-intel"),
    Package("intel-media-driver"),
    Package("libva-utils"),
    # 32-bit libraries required by Steam + Proton / most Windows games
    Package("lib32-mesa"),
    Package("lib32-vulkan-intel"),
]

FIRMWARE_PKGS = [
    Package("intel-ucode"),
    Package("linux-firmware"),
]

POWER_PKGS = [
    Package("power-profiles-daemon", services=[Service("power-profiles-daemon.service")]),
    Package("upower"),  # dbus-activated on demand, nothing to enable
]

AUDIO_PKGS = [
    Package("rtkit"),
    Package("pipewire", services=[Service("pipewire.service", is_user_service=True)]),
    Package("pipewire-alsa"),
    Package("pipewire-pulse", services=[Service("pipewire-pulse.service", is_user_service=True)]),
    Package("pipewire-jack"),
    Package("wireplumber", services=[Service("wireplumber.service", is_user_service=True)]),
]

NETWORK_PKGS = [
    Package("networkmanager", services=[Service("NetworkManager.service")]),
]

BLUETOOTH_PKGS = [
    Package("bluez", services=[Service("bluetooth.service")]),
    Package("bluez-utils"),
    Package("blueman"),
]

PRINTING_PKGS = [
    Package("cups", services=[Service("cups.service")]),
    Package("ghostscript"),
    Package("system-config-printer"),
    Package("cups-pdf"),
    Package("avahi", services=[Service("avahi-daemon.service")]),
    Package("nss-mdns"),
]

ALL_PKGS: List[Package] = (
    GRAPHICS_PKGS
    + FIRMWARE_PKGS
    + POWER_PKGS
    + AUDIO_PKGS
    + NETWORK_PKGS
    + BLUETOOTH_PKGS
    + PRINTING_PKGS
)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    if not ALL_PKGS:
        print("Package list is empty — nothing to install.", file=sys.stderr)
        sys.exit(1)

    # Ctrl-C / SIGTERM / normal exit will all still restore the terminal
    # exactly once (see utils/shutdown.py). Re-enabling PACMAN_PRE_POST is
    # NOT registered here: run_with_snapper_wrapped guarantees that on its
    # own, via its own try/finally around workload() — a second copy here
    # would just be a harmless-but-redundant duplicate re-enable call on
    # every Ctrl-C during the install loop.
    register_cleanup(restore_screen)

    total = len(ALL_PKGS)
    installed = 0
    failed: List[str] = []

    def workload() -> None:
        nonlocal installed, failed
        setup_screen()
        try:
            for pkg in ALL_PKGS:
                draw_bar(installed, total, pkg.name)
                result = install_config_and_enable(pkg)

                if result == 0:
                    installed += 1
                    continue

                # --noconfirm auto-declines pacman's own "Remove X? [y/N]"
                # conflict prompt (that default is hardcoded in pacman,
                # not something --noconfirm can flip). Rather than guess
                # what to do, drop out of the status bar and retry this
                # one package *without* --noconfirm, so pacman's real
                # prompt reaches the terminal and you can choose what to
                # keep.
                restore_screen()
                print(
                    f"\n==> '{pkg.name}' failed non-interactively — retrying "
                    "so you can answer any prompt yourself (e.g. which "
                    "package to keep):"
                )
                result = install_config_and_enable(pkg, no_confirm=False)
                setup_screen()
                if result == 0: installed += 1
                else: failed.append(pkg.name)

            draw_bar(installed, total, "done")
            time.sleep(0.3)
        finally:
            restore_screen()

    run_with_snapper_wrapped(workload, desc="1_hardware.py")

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed: sys.exit(1)


if __name__ == "__main__":
    main()
