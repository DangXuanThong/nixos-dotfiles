import os
import subprocess
from pathlib import Path
from subprocess import CompletedProcess
from typing import Optional, Sequence

from utils.package import Package


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
    if pkg.activation_cmd: run(pkg.activation_cmd.split(), check=False)
    return result.returncode


def create_config_symlink(config_dir: Path, overwrite: bool = False):
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    name = config_dir.name
    dest = config_home / name

    if not config_dir.exists():
        print(f"    config directory not found, skipping: {config_dir.resolve()}")
        return

    try:
        if dest.exists():
            print(f"    config directory already exist at: {dest.resolve()}")
            if not overwrite: dest.rename(dest.with_name(name + ".bak"))
            else: dest.rmdir()
        dest.symlink_to(config_dir.resolve(), target_is_directory=True)
    except:
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
