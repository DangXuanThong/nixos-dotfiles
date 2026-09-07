#!/usr/bin/env python3
"""
2_wm_de.py
"""


import getpass
import grp
import sys
import time
from typing import List

from utils.command_runner import install_config_and_enable, run
from utils.package import Package, Service
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------
def _add_user_to_group(group: str) -> None:
    """Add the current user to `group` if not already a member. Needed for
    brightnessctl's udev rule (grants brightness control to the `video`
    group) to actually take effect — installing the package alone only
    gets you the udev rule, not membership. Takes effect on next login."""
    user = getpass.getuser()
    try:
        members = grp.getgrnam(group).gr_mem
    except KeyError:
        print(f"    group '{group}' does not exist, skipping")
        return

    if user in members:
        print(f"    {user} is already in the '{group}' group")
        return

    print(f"    adding {user} to the '{group}' group (takes effect next login)")
    run(["usermod", "-aG", group, user], sudo=True, check=False)


def _remind_kwallet_pam() -> None:
    """kwallet-pam needs a pam_kwallet5.so line added to the PAM file for
    whichever login flow you actually use — which file depends entirely on
    the login manager (already present by default for SDDM/LightDM, needs
    a manual edit for GDM/greetd/plain TTY login). That choice isn't made
    yet here (greetd-regreet is still commented out above), and PAM files
    control authentication — a wrong guess here risks a login lockout, not
    just a missing feature — so this stays a pointer, not an automated
    edit, until the login manager is settled."""
    print(
        "    kwallet-pam needs a pam_kwallet5.so line in your login "
        "manager's PAM file to auto-unlock — already present by default "
        "for SDDM/LightDM, needs a manual edit for GDM/greetd/TTY login. "
        "See: https://wiki.archlinux.org/title/KDE_Wallet#Unlock_KDE_Wallet_automatically_on_login"
    )


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
WM_PACKAGES = [
    # Package("greetd-regreet"),
    Package("kwallet"),
    Package("kwallet-pam", post_install=_remind_kwallet_pam),  # Auto-unlock wallet on login
    Package("kwalletmanager"),      # GUI manager
]

DE_PACKAGES = [
    Package("uwsm"),                # For using hyprland with uwsm
    Package("libnewt"),             # For using hyprland with uwsm

    # Hypr* family
    Package("hyprland", config_dir="config/hypr"),
    Package("hyprpolkitagent", services=[Service("hyprpolkitagent.service", is_user_service=True)]),
    Package("hypridle", services=[Service("hypridle.service", is_user_service=True)]),
    Package("hyprpaper"),
    Package("hyprlauncher"),
    Package("hyprlock"),
    Package("hyprshot-rs"),

    Package("quickshell", config_dir="config/quickshell"),
    Package("swaync", services=[Service("swaync.service", is_user_service=True)]), # Notification daemon
    Package("dconf"),               # Config for GNOME apps
    Package("dolphin"),             # KDE file manager
    Package("obs-studio"),          # Screen recorder
    Package("loupe"),               # Image viewer
    Package("celluloid"),           # Video viewer
    Package("ktexteditor"),         # Text editor
    Package("mission-center"),      # Task manager but for linux
    Package("ark"),                 # Archive viewer
]

TERMINAL_PACKAGES = [
    Package("fish", post_install=lambda: run(["chsh", "-s", "/usr/bin/fish"], check=False)),
    Package("kitty"),
    Package("fastfetch-git"),
    Package("eza"),                 # Alternative to `ls`
    Package("bat"),                 # Better `cat` (content at file)
    Package("jq"),                  # CLI json processor
    Package("libnotify"),           # Provide `notify-send`
    Package("brightnessctl", post_install=lambda: _add_user_to_group("video")),  # Control brightness
    Package("wl-clipboard"),        # Clipboard
]

FONT_PACKAGES = [
    Package("inter-font"),
    Package("ttf-jetbrains-mono-nerd"),
    Package("noto-fonts-cjk"),
    Package("noto-fonts-emoji"),
    Package("ttf-ms-fonts"),
]

ALL_PKGS: List[Package] = (
    WM_PACKAGES
    + DE_PACKAGES
    + TERMINAL_PACKAGES
    + FONT_PACKAGES
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

    run_with_snapper_wrapped(workload, desc="2_wm_de.py")

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed: sys.exit(1)


if __name__ == "__main__":
    main()
