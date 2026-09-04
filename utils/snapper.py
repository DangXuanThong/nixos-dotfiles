import sys
from typing import Callable

from command_runner import run


DEFAULT_CONFIG = "root"


def verify_snapper_config(config: str = DEFAULT_CONFIG) -> None:
    """Verify snapper config exists"""
    result = run(["snapper", "list-configs"], sudo=True, capture=True)
    configs = {line.split()[0] for line in result.stdout.splitlines() if line.strip()}
    if config not in configs:
        print(
            f"Snapper config '{config}' not found. "
            "Run 'snapper list-configs' and update the config.",
            file=sys.stderr,
        )
        sys.exit(1)


def run_with_snapper_wrapped(
    workload: Callable[[], None], desc: str, config: str = DEFAULT_CONFIG
) -> None:
    """Run workload() with snapper pre/post hooks.

    Re-enabling per-transaction snap-pac snapshots is guaranteed via
    `finally`, regardless of whether workload() succeeds, raises, or is
    interrupted (SIGINT/SIGTERM propagating as SystemExit still unwinds
    through this frame) — otherwise a crash mid-run would leave
    PACMAN_PRE_POST disabled system-wide. The post-install snapshot, by
    contrast, is only created if workload() completes without raising —
    an interrupted/failed run still gets its pre-snapshot as a rollback
    point, but no post-snapshot, matching the original intent.
    """
    verify_snapper_config(config)

    print("==> Creating pre-install snapshot")
    result = run(
        [
            "snapper", "-c", config, "create",
            "--type", "pre",
            "--print-number",
            "--description", f"pre: {desc}",
        ],
        sudo=True,
        capture=True,
    )
    pre_num = result.stdout.strip()
    print(f"    pre snapshot #{pre_num}")

    print("==> Disabling per-transaction snap-pac snapshots for this run")
    run(
        ["snapper", "-c", config, "set-config", "PACMAN_PRE_POST=no"],
        sudo=True,
    )

    try:
        workload()
    finally:
        print("==> Re-enabling per-transaction snap-pac snapshots")
        run(
            ["snapper", "-c", config, "set-config", "PACMAN_PRE_POST=yes"],
            sudo=True,
            check=False,
        )

    print("==> Creating post-install snapshot")
    result = run(
        [
            "snapper", "-c", config, "create",
            "--type", "post",
            "--pre-number", pre_num,
            "--print-number",
            "--description", f"post: {desc}",
        ],
        sudo=True,
        capture=True,
    )
    post_num = result.stdout.strip()
    print(f"    post snapshot #{post_num} (paired with pre #{pre_num})")
