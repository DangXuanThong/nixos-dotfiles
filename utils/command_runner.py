import subprocess
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
