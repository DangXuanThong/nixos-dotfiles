#!/usr/bin/env python3
"""
3_virtualization.py

Installs rootless Docker and the KVM/libvirt virtualization stack.

Docker runs rootless (see _setup_docker_rootless) — no docker group, no
system-wide daemon. libvirt still uses the standard group-membership
approach (via add_user_to_group in utils/command_runner.py), which takes
effect on your NEXT login, not immediately — opening virt-manager right
after this script finishes will still need sudo until you log out and
back in.
"""


import getpass
import sys
import time
from pathlib import Path
from typing import List

from utils.command_runner import add_user_to_group, install_config_and_enable, run
from utils.package import Package, Service
from utils.screen import draw_bar, restore_screen, setup_screen
from utils.shutdown import register_cleanup
from utils.snapper import run_with_snapper_wrapped


# ---------------------------------------------------------------------------
# post_install helpers
# ---------------------------------------------------------------------------
def _setup_docker_rootless() -> None:
    """Rootless Docker setup. Multi-step and script-driven (the setup tool
    creates its own user-level systemd unit), unlike every other
    post_install in this project, which just enables a unit that already
    exists on disk."""
    user = getpass.getuser()

    # newuidmap/newgidmap come from `shadow` (base, always present on
    # Arch) — no package needed. Whether subuid/subgid actually have a
    # range for this user is a separate, real question. Not auto-fixed
    # here — picking a safe, non-conflicting range automatically in a
    # system identity file carries real risk, and Docker's own setup tool
    # doesn't auto-remediate this either, it just detects and tells you.
    for path in ("/etc/subuid", "/etc/subgid"):
        try:
            lines = Path(path).read_text().splitlines()
        except FileNotFoundError:
            lines = []
        has_range = any(
            len(parts) == 3 and parts[0] == user and int(parts[2]) >= 65536
            for parts in (line.split(":") for line in lines)
        )
        if not has_range:
            print(
                f"    {path} has no range for this user — rootless setup "
                "will fail until you add one, e.g.:\n"
                f"    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 {user}"
            )
            return

    # Must run unprivileged — this configures YOUR user namespace.
    run(["dockerd-rootless-setuptool.sh", "install"], check=False)

    # Without lingering, the daemon dies when your last session ends.
    run(["loginctl", "enable-linger", user], sudo=True, check=False)

    # The setup tool creates the unit but doesn't necessarily enable it.
    run(["systemctl", "--user", "enable", "--now", "docker.service"], check=False)

    # fish syntax specifically — stage 2 sets fish as your default shell.
    fish_config = Path.home() / ".config" / "fish" / "config.fish"
    line = "set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/docker.sock\n"
    existing = fish_config.read_text() if fish_config.exists() else ""
    if "DOCKER_HOST" not in existing:
        fish_config.parent.mkdir(parents=True, exist_ok=True)
        with fish_config.open("a") as f:
            f.write(line)

    print("    rootless docker configured — log out and back in for lingering to take effect")


# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------
KVM_PACKAGES = [
    Package("qemu-desktop"),        # KVM accel + typical desktop VM backend, no cross-arch emulation bloat
    Package(
        "libvirt",
        services=[Service("libvirtd.service")],
        post_install=lambda: add_user_to_group("libvirt"),
    ),                              # system service — manages VMs system-wide
    Package("virt-manager"),        # GUI for creating/managing VMs
    Package("dnsmasq"),             # DHCP/DNS for libvirt's default NAT network
    Package("edk2-ovmf"),           # UEFI firmware for VMs (Windows 11 / macOS guests need this)
]

DOCKER_PACKAGES = [
    Package("docker-rootless-extras", post_install=_setup_docker_rootless),
    Package("slirp4netns"),         # recommended network driver — only optional on docker-rootless-extras
    Package("fuse-overlayfs"),      # overlayfs support — same story
    Package("docker-compose"),      # `docker compose` CLI plugin
]

ALL_PKGS: List[Package] = (
    KVM_PACKAGES
    + DOCKER_PACKAGES
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

    run_with_snapper_wrapped(workload, desc="3_virtualization")

    if failed:
        print(f"==> {len(failed)} package(s) failed to install:", file=sys.stderr)
        for pkg in failed:
            print(f"    - {pkg}", file=sys.stderr)

    print(f"==> Done. Installed {installed - len(failed)}/{total} packages.")

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
