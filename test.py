# terminal_section_dividers.py

import shutil
from typing import Literal

Style = Literal["double", "single", "heavy", "minimal", "rounded"]

def terminal_width(default: int = 80) -> int:
    try:
        return shutil.get_terminal_size().columns
    except Exception:
        return default


def print_section(
    title: str,
    style: Style = "double",
    padding: int = 2
) -> None:
    width = terminal_width()
    title = f"{' ' * padding}{title.upper()}{' ' * padding}"

    if style == "double":
        top = "╔" + "═" * (width - 2) + "╗"
        mid = "║" + title.center(width - 2) + "║"
        bot = "╚" + "═" * (width - 2) + "╝"

    elif style == "single":
        top = "┌" + "─" * (width - 2) + "┐"
        mid = "│" + title.center(width - 2) + "│"
        bot = "└" + "─" * (width - 2) + "┘"

    elif style == "heavy":
        top = "█" * width
        mid = "█" + title.center(width - 2) + "█"
        bot = "█" * width

    elif style == "rounded":
        top = "╭" + "─" * (width - 2) + "╮"
        mid = "│" + title.center(width - 2) + "│"
        bot = "╰" + "─" * (width - 2) + "╯"

    elif style == "minimal":
        print("─" * width)
        print(title.strip().center(width))
        print("─" * width)
        return

    else:
        raise ValueError(f"Unknown style: {style}")

    print(top)
    print(mid)
    print(bot)


if __name__ == "__main__":
    print_section("System Initialization", style="double")
    print("[INFO] Starting services...")

    print_section("Data Ingestion", style="single")
    print("[INFO] Reading input streams...")

    print_section("Model Inference", style="heavy")
    print("[INFO] Running inference...")

    print_section("Final Results", style="rounded")
    print("[OK] Completed successfully.")
