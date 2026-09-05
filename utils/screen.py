import shutil
import sys

from ansi import Ansi


# ---------------------------------------------------------------------------
# Status-bar TUI (only active when stdout is a real terminal)
# ---------------------------------------------------------------------------
_USE_TUI = sys.stdout.isatty()
_BREAKPOINT = 60      # below this width, split the bar and text onto 2 lines
_BAR_ROW = 0          # row where the progress bar is drawn (bottom of the scroll region)
_BAR_HEIGHT = 1       # 1 (single line) or 2 (bar + text on separate lines)
_MIN_BAR_WIDTH = 10   # never render a bar shorter than this
_LOG_LIMIT = 0        # the last row used for logging, evaluated by terminal height - _BAR_HEIGHT
# _cleanup_done = False


def setup_screen() -> None:
    global _BAR_ROW, _BAR_HEIGHT, _LOG_LIMIT
    if not _USE_TUI: return

    size = shutil.get_terminal_size()
    rows, cols = size.lines, size.columns
    # Decided once, at setup time, since it determines how many rows we
    # carve out of the scroll region — not re-evaluated per redraw (that
    # would desync the reserved rows from the actual scroll region without
    # also handling SIGWINCH, which this script doesn't).
    _BAR_HEIGHT = 2 if cols < _BREAKPOINT else 1
    _BAR_ROW = rows - _BAR_HEIGHT + 1
    _LOG_LIMIT = _BAR_ROW - 1
    # hide cursor
    sys.stdout.write(Ansi.CursorHide)
    # set scroll region to lines 1 .. LOG_LIMIT_ROW
    sys.stdout.write(Ansi.ScrollRegion(bottom=_LOG_LIMIT))
    # park cursor at bottom of the scroll region
    sys.stdout.write(Ansi.CursorMove(_LOG_LIMIT))
    sys.stdout.flush()


def restore_screen() -> None:
    if not _USE_TUI: return

    # reset scroll region
    sys.stdout.write(Ansi.ScrollReset)
    # explicitly clear every reserved bottom row — resetting the scroll
    # region above only changes future scrolling behaviour, it does NOT
    # erase whatever the status bar last drew there. Without this, an
    # interrupted run (Ctrl-C) leaves the stale progress bar frozen on
    # screen, since no further output happens afterwards to scroll it away.
    if _BAR_ROW:
        for row in range(_BAR_ROW, _BAR_ROW + _BAR_HEIGHT):
            sys.stdout.write(Ansi.CursorMove(row) + Ansi.LineClear)
    # show cursor
    sys.stdout.write(Ansi.CursorShow)
    sys.stdout.write("\n")
    sys.stdout.flush()


def draw_bar(installed: int, total: int, pkg: str) -> None:
    if not _USE_TUI:
        print(f"  ({installed}/{total}) installing: {pkg}")
        return
    
    pct = (installed * 100) // total if total else 100
    cols = shutil.get_terminal_size().columns

    sys.stdout.write(Ansi.CursorSave)  # save cursor position

    if _BAR_HEIGHT == 2:
        # Narrow terminal: the bar gets its own full-width line, stats
        # (percentage / counts / current package) go on the line below,
        # truncated with an ellipsis if they don't fit.
        bar_width = max(cols - 2, 1)
        filled = (pct * bar_width) // 100
        bar = "#" * filled + "-" * (bar_width - filled)
        stats = _truncate(
            f"{pct:3d}% | {installed}/{total} installed | {pkg}", cols
        )

        sys.stdout.write(Ansi.CursorMove(_BAR_ROW) + Ansi.LineClear)
        sys.stdout.write(Ansi.ReverseOn + f"[{bar}]" + Ansi.Reset)
        sys.stdout.write(Ansi.CursorMove(_BAR_ROW + 1) + Ansi.LineClear)
        sys.stdout.write(Ansi.ReverseOn + f"{stats:<{cols}}" + Ansi.Reset)
    else:
        # Wide terminal: one line. The text (percentage, counts, current
        # package — truncated with an ellipsis if needed) is laid out
        # first, and the bar stretches to fill whatever width is left.
        prefix = f"{pct:3d}% | {installed}/{total} installed | installing: "
        chrome = len(prefix) + 4  # "[" "] " and a leading/trailing space
        pkg_budget = max(cols - chrome - _MIN_BAR_WIDTH, 3)
        pkg_display = _truncate(pkg, pkg_budget)
        text = f"{prefix}{pkg_display}"

        bar_width = max(cols - len(text) - 4, _MIN_BAR_WIDTH)
        filled = (pct * bar_width) // 100
        bar = "#" * filled + "-" * (bar_width - filled)

        line = f" [{bar}] {text} "
        line = line[:cols].ljust(cols)  # hard clamp, never overflow the row

        sys.stdout.write(Ansi.CursorMove(_BAR_ROW) + Ansi.LineClear)
        sys.stdout.write(Ansi.ReverseOn + line + Ansi.Reset)

    sys.stdout.write(Ansi.CursorLoad)  # restore cursor position
    sys.stdout.flush()


def _truncate(s: str, max_len: int) -> str:
    """Shorten s to at most max_len chars, with a trailing ellipsis if cut."""
    if max_len <= 0:
        return ""
    if len(s) <= max_len:
        return s
    if max_len == 1:
        return "…"
    return s[: max_len - 1] + "…"
