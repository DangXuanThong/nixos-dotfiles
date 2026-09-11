import getpass
import grp
import os
import shutil
import subprocess
from pathlib import Path
from subprocess import CompletedProcess
from typing import Optional, Sequence

from .package import Package


# utils/command_runner.py -> parent (utils/) -> parent (repo root)
REPO_ROOT = Path(__file__).resolve().parent.parent


def run(
    cmd: Sequence[str],
    *,
    sudo: bool = False,
    check: bool = True,
    capture: bool = False,
) -> CompletedProcess:
    """Thin wrapper around subprocess.run. Pass `sudo=True` to prefix the
    command with sudo."""
    return subprocess.run(
        ["sudo", *cmd] if sudo else cmd,
        check=check,
        text=True,
        capture_output=capture,
    )


def add_user_to_group(group: str) -> None:
    """Add the current user to `group` if not already a member. Shared
    across stages that need unprivileged access to a daemon's socket or
    device node (docker, libvirt, brightnessctl's video group, ...).
    Takes effect on next login, not immediately."""
    user = getpass.getuser()
    try:
        members = grp.getgrnam(group).gr_mem
    except KeyError:
        print(f"    group '{group}' does not exist, skipping")
        return

    if user in members: return

    print(f"    adding {user} to the '{group}' group (takes effect next login)")
    run(["usermod", "-aG", group, user], sudo=True, check=False)


_user_session_ok: Optional[bool] = None
def _user_session_available() -> bool:
    """Whether a user systemd session bus is reachable — checked once and
    cached, rather than re-querying it for every user-service package."""
    global _user_session_ok
    if _user_session_ok is None:
        result = run(
            ["systemctl", "--user", "is-system-running"],
            check=False,
            capture=True,
        )
        _user_session_ok = result.stdout.strip() in ("running", "degraded")
    return _user_session_ok


def install_config_and_enable(pkg: Package, no_confirm: bool = True) -> int:
    cmd = ["yay", "-S", "--needed"]
    if no_confirm: cmd.append("--noconfirm")
    cmd.append(pkg.name)

    # check=False: one failing/conflicting package should not
    # take down the rest of the run — record it and keep going.
    result = run(cmd, check=False)

    # Early return if install fails
    if result.returncode != 0: return result.returncode

    if pkg.config_dir: create_config_symlink(pkg.config_dir)
    if pkg.services: enable_services(pkg)
    if pkg.post_install: pkg.post_install()
    return result.returncode


def create_config_symlink(config_dir: str, overwrite: bool = False) -> None:
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    src = REPO_ROOT / config_dir
    dest = config_home / src.name

    if not src.exists():
        print(f"    config directory not found, skipping: {src.resolve()}")
        return

    try:
        # check for both existance and is symlink, because a dangling symlink will report as not exist
        if dest.exists() or dest.is_symlink():
            print(f"    config directory already exists at: {dest.resolve()}")
            if not overwrite: dest.rename(dest.with_name(dest.name + ".bak"))
            elif dest.is_symlink(): dest.unlink()
            else: shutil.rmtree(dest)
        dest.symlink_to(src.resolve(), target_is_directory=True)
    except Exception:
        print(f"    error symlinking config directory to {dest.resolve()}")


def enable_services(pkg: Package) -> None:
    """Enable whatever services this package owns, called right after that
    package installs successfully — not batched at the end of the run."""
    for svc in pkg.services:
        if svc.is_user_service:
            if _user_session_available():
                print(f"    enabling (user): {svc.name}")
                run(["systemctl", "--user", "enable", "--now", svc.name], check=False)
            else:
                print(
                    f"    no active user session bus — enable manually later: "
                    f"systemctl --user enable --now {svc.name}"
                )
        else:
            print(f"    enabling: {svc.name}")
            run(["systemctl", "enable", "--now", svc.name], sudo=True, check=False)
