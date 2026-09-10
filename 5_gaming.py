#!/usr/bin/env python3
"""
4_gaming.py

Installs Steam, PrismLauncher, Heroic, emulators (Eden/Azahar), and
performance tooling (GameMode, MangoHud).

Assumes multilib is already enabled (established back in 1_hardware.py) —
lib32-gamemode and lib32-mangohud both need it, same as lib32-mesa and
lib32-vulkan-intel did.
"""


import sys
import time
from typing import List

from utils.command_runner import add_user_to_group, install_config_and_enable
from utils.package import Package
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------
def _configure_gamemode():
    add_user_to_group("gamemode") # package auto-creates this group


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
LAUNCHER_PACKAGES = [
    Package("steam"),
    Package("prismlauncher"),       # Minecraft
    Package("heroic-games-launcher-bin"), # Epic/GOG/Amazon
]

EMULATOR_PACKAGES = [
    # Package("eden"),                # Switch emulator (.nsp)
    # Package("azahar"),              # 3DS emulator (.3ds)
]

PERFORMANCE_PACKAGES = [
    Package("gamemode", post_install=_configure_gamemode),
    Package("lib32-gamemode"),      # needed for GameMode to activate on 32-bit Proton titles
    Package("mangohud", config_dir="config/MangoHud"),
    Package("lib32-mangohud"),      # overlay support in 32-bit games
    Package("protonplus"),          # manage Proton builds for Steam
]

ALL_PKGS: List[Package] = (
    LAUNCHER_PACKAGES
    + EMULATOR_PACKAGES
    + PERFORMANCE_PACKAGES
)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    if not ALL_PKGS:
        print("Package list is empty — nothing to install.", file=sys.stderr)
        sys.exit(1)

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

                restore_screen()
                print(
                    f"\n==> '{pkg.name}' failed non-interactively — retrying "
                    "so you can answer any prompt yourself (e.g. which "
                    "package to keep):"
                )
                result = install_config_and_enable(pkg, no_confirm=False)
                setup_screen()
                if result == 0:
                    installed += 1
                else:
                    failed.append(pkg.name)

            draw_bar(installed, total, "done")
            time.sleep(0.3)
        finally:
            restore_screen()

    run_with_snapper_wrapped(workload, desc="4_gaming")

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
