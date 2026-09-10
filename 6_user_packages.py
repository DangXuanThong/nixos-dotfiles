#!/usr/bin/env python3
"""
6_user_packages.py

Place packages you want to install here but not related to any of previous stages
"""


import sys
import time
from typing import List

from utils.command_runner import install_config_and_enable
from utils.package import Package
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
ARCH_PKGS = [
    Package("flatpak"),
    Package("flatseal"),            # Permission management for flatpak apps
    Package("proton-vpn-gtk-app"),  # VPN app
    Package("onlyoffice-bin")       # Alternative to MS Office
]

FLATPAK_PKGS = [
    # Placeholder, waiting to create Flatpak class
    # org.vinegarhq.Sober
]

ALL_PKGS: List[Package] = (
    ARCH_PKGS
    + FLATPAK_PKGS
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
