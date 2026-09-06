import atexit
import signal
import sys
from typing import Callable


_cleanup_done = False


def register_cleanup(action: Callable[[], None]) -> None:
    """Register `action` to run exactly once — on normal exit, SIGINT, or
    SIGTERM, whichever happens first. `action` takes no arguments and its
    return value is ignored; it should be safe to call from a signal
    handler (avoid anything that isn't reentrant-safe).
    """

    def _cleanup() -> None:
        global _cleanup_done
        if _cleanup_done:
            return
        action()
        _cleanup_done = True

    def _signal_handler(signum, frame) -> None:
        _cleanup()
        sys.exit(128 + signum)

    atexit.register(_cleanup)
    signal.signal(signal.SIGINT, _signal_handler)
    signal.signal(signal.SIGTERM, _signal_handler)
