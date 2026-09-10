#!/usr/bin/env python3
"""
4_dev_tools.py
"""


import sys
import time
from typing import List

from utils.command_runner import install_config_and_enable, run
from utils.package import Package
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------
def _configure_git() -> None:
    run(["git", "config", "--global", "user.name", "Dang Xuan Thong"], check=False)
    run(["git", "config", "--global", "user.email", "dangxuanthongvn@gmail.com"], check=False)
    run(["git", "config", "--global", "init.defaultBranch", "main"], check=False)


def _remind_gh_auth() -> None:
    print(
        "    github-cli installed — run 'gh auth login' once to authenticate "
        "(browser-based OAuth; the token lands in your system keyring, e.g. "
        "KWallet via Secret Service, not a plaintext file). Say yes when it "
        "offers to set up git's credential helper, or run "
        "'gh auth setup-git' afterward if you skipped that prompt."
    )


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
SDK_PACKAGES = [
    Package("jdk25-openjdk"),
    Package("nodejs"),
    Package("npm"),
    Package("python"),
]

IDE_PACKAGES = [
    # Package("jetbrains-toolbox"),
    # Package("intellij-idea-community-edition"),
    Package("android-studio"),
    Package("visual-studio-code-bin"),
]

OTHER_PACKAGES = [
    Package("git", post_install=_configure_git),
    Package("github-cli", post_install=_remind_gh_auth),
    # Package("genymotion"),
]

ALL_PKGS: List[Package] = (
    SDK_PACKAGES
    + IDE_PACKAGES
    + OTHER_PACKAGES
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

    run_with_snapper_wrapped(workload, desc="4_dev_tools")

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
