class Ansi:
    CursorHide = "\033[?25l"
    CursorShow = "\033[?25h"
    CursorSave = "\0337"
    CursorLoad = "\0338"
    ScrollReset = "\033[r"
    LineClear = "\033[2K"
    ReverseOn = "\033[7m"
    Reset = "\033[0m"

    @staticmethod
    def ScrollRegion(top: int = 1, bottom: int = 1) -> str:
        return f"\033[{top};{bottom}r"

    @staticmethod
    def CursorMove(row: int = 1, col: int = 1) -> str:
        return f"\033[{row};{col}H"
