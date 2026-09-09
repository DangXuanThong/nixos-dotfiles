#!/usr/bin/env python3
"""
2_wm_de.py
"""


import json
from pathlib import Path
import shlex
import sys
import tempfile
import time
from typing import List

from utils.command_runner import add_user_to_group, install_config_and_enable, run
from utils.package import Package, Service
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------
def _configure_fish() -> None:
    """Change the default shell to `fish`"""
    run(["chsh", "-s", "/usr/bin/fish"], check=False)


def _configure_brightnessctl() -> None:
    add_user_to_group("video")


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


def _configure_zen_browser() -> None:
    """Write zen-browser's policies.json (merged, not overwritten — the AUR
    package already ships its own DisableAppUpdate there) plus the
    AutoConfig pair needed for locked prefs (lockPref() only works inside
    a .cfg file, not a plain defaults/pref/*.js — see the pointer file
    below). All three files are staged as temp files first (no privilege
    needed), then installed into the root-owned tree in a single sudo call.
    """
    ZEN_INSTALL_DIR = Path("/opt/zen-browser-bin")
    if not ZEN_INSTALL_DIR.is_dir():
        print(f"    zen-browser-bin not found at {ZEN_INSTALL_DIR}, skipping config")
        return

    ZEN_EXTENSIONS = {
        # To add additional extensions, find it on addons.mozilla.org, find
        # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
        # Then go to https://addons.mozilla.org/api/v5/addons/addon/!SHORT_ID!/ to get the guid
        "adguardadblocker@adguard.com": "adguard-adblocker",
        "{446900e4-71c2-419f-a6a7-df9c091e268b}": "bitwarden-password-manager",
        "addon@darkreader.org": "darkreader",
        "addon@fastforward.team": "fastforwardteam",
        "jid1-KKzOGWgsW3Ao4Q@jetpack": "i-dont-care-about-cookies",
        "{2d97895d-fcd3-41ab-82e6-6a1d4d2243f6}": "temp-mail",
        # Missing: google translate since it doesn't available for firefox
    }
    ZEN_LOCKED_PREFS = {
        # Check these out at about:config
        "extensions.autoDisableScopes": 0,
        "extensions.pocket.enabled": False,
        "widget.wayland.fractional-scale.enabled": False,
    }

    policies_path = ZEN_INSTALL_DIR / "distribution" / "policies.json"
    try:
        existing = json.loads(policies_path.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        existing = {}
    policies: dict = existing.setdefault("policies", {})
    policies["DisableTelemetry"] = True
    policies.setdefault("ExtensionSettings", {})
    for guid, slug in ZEN_EXTENSIONS.items():
        policies["ExtensionSettings"][guid] = {
            "install_url": f"https://addons.mozilla.org/en-US/firefox/downloads/latest/{slug}/latest.xpi",
            "installation_mode": "normal_installed",
        }
    policies_content = json.dumps(existing, indent=2)

    pointer_content = (
        'pref("general.config.filename", "zen.cfg");\n'
        'pref("general.config.obscure_value", 0);\n'
    )

    cfg_lines = ["// autoconfig — first line is intentionally skipped by Firefox's reader"]
    for name, value in ZEN_LOCKED_PREFS.items():
        cfg_lines.append(f"lockPref({json.dumps(name)}, {json.dumps(value)});")
    cfg_content = "\n".join(cfg_lines) + "\n"

    targets = {
        policies_path: policies_content,
        ZEN_INSTALL_DIR / "defaults" / "pref" / "zen-local-settings.js": pointer_content,
        ZEN_INSTALL_DIR / "zen.cfg": cfg_content,
    }
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_dir = Path(tmp_dir)
        src_paths = {}
        for i, (dest, content) in enumerate(targets.items()):
            src_path = tmp_dir / f"file{i}"
            src_path.write_text(content)
            src_paths[dest] = src_path
 
        install_script = "\n".join(
            f"install -D -m644 {shlex.quote(str(src))} {shlex.quote(str(dest))}"
            for dest, src in src_paths.items()
        )
        script_path = tmp_dir / "install.sh"
        script_path.write_text(install_script + "\n")
 
        run(["bash", str(script_path)], sudo=True, check=False)

    print(f"    configured zen-browser policies + locked prefs at {ZEN_INSTALL_DIR}")


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
WM_PACKAGES = [
    # Package("greetd-regreet"),
    Package("kwallet"),             # KDE Wallet daemon (secrets storage)
    Package("kwallet-pam", post_install=_remind_kwallet_pam),  # Auto-unlock wallet on login
    Package("kwalletmanager"),      # GUI manager
]

DE_PACKAGES = [
    Package("uwsm"),                # For using hyprland with uwsm
    Package("libnewt"),             # For using hyprland with uwsm

    # Hypr* family
    Package("hyprland", config_dir="config/hypr"),  # Wayland compositor
    Package("hyprpolkitagent", services=[Service("hyprpolkitagent.service", is_user_service=True)]), # Polkit auth agent
    Package("hypridle", services=[Service("hypridle.service", is_user_service=True)]), # Idle management (lock/DPMS)
    Package("hyprpaper", services=[Service("hyprpaper.service", is_user_service=True)]), # Wallpaper daemon
    Package("hyprlauncher"),        # App launcher
    Package("hyprlock"),            # Screen locker
    Package("hyprshot-rs"),         # Screenshot tool
    Package("xdg-desktop-portal-hyprland"),

    Package("quickshell", config_dir="config/quickshell"),  # Custom status bar (QtQuick-based)
    Package("swaync", services=[Service("swaync.service", is_user_service=True)]), # Notification daemon
    Package("dconf"),               # Config for GNOME apps
    Package("dolphin"),             # KDE file manager
    Package("gvfs"),                # Provides trash, smb, mtp...
    Package("filelight"),           # Disk usage visualizer
    Package("partitionmanager"),    # GUI partition tool
    Package("obs-studio"),          # Screen recorder
    Package("loupe"),               # Image viewer
    Package("celluloid"),           # Video viewer
    Package("ktexteditor"),         # Text editor
    Package("mission-center"),      # Task manager but for linux
    Package("ark"),                 # Archive viewer
    Package("zen-browser-bin", post_install=_configure_zen_browser), # Web browser
]

TERMINAL_PACKAGES = [
    Package("fish", config_dir="config/fish", post_install=_configure_fish),
    Package("kitty"),               # Terminal emulator
    Package("fastfetch-git", config_dir="config/fastfetch"),
    Package("eza"),                 # Alternative to `ls`
    Package("bat"),                 # Better `cat` (content at file)
    Package("jq"),                  # CLI json processor
    Package("libnotify"),           # Provide `notify-send`
    Package("brightnessctl", post_install=_configure_brightnessctl),  # Control brightness
    Package("wl-clipboard"),        # Clipboard
]

FONT_PACKAGES = [
    Package("inter-font"),           # UI font
    Package("ttf-jetbrains-mono-nerd"), # Monospace/terminal font with icon glyphs
    Package("noto-fonts-cjk"),       # Chinese/Japanese/Korean glyph coverage
    Package("noto-fonts-emoji"),     # Emoji glyph coverage
    Package("ttf-ms-fonts"),         # Metric-compatible with common MS fonts (doc/web compatibility)
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
