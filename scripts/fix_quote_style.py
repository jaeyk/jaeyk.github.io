#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

# Normalize every quotation style to plain straight quotes so titles render
# consistently (e.g. LaTeX-style ``...'' or curly "..."/'...' all become "..."/'...').
REPLACEMENTS = [
    ("``", '"'),
    ("''", '"'),
    ("“", '"'),  # left double quotation mark “
    ("”", '"'),  # right double quotation mark ”
    ("‘", "'"),  # left single quotation mark ‘
    ("’", "'"),  # right single quotation mark ’
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Normalize inconsistent quotation styles to straight quotes."
    )
    parser.add_argument(
        "--file",
        default="publications/pubs.qmd",
        help="Target file to fix. Defaults to publications/pubs.qmd.",
    )
    return parser.parse_args()


def fix_quotes(text: str) -> tuple[str, int]:
    total_replacements = 0
    for old, new in REPLACEMENTS:
        count = text.count(old)
        if count:
            text = text.replace(old, new)
            total_replacements += count
    return text, total_replacements


def main() -> int:
    args = parse_args()
    path = Path(args.file)
    original = path.read_text(encoding="utf-8")
    updated, total_replacements = fix_quotes(original)

    if updated != original:
        path.write_text(updated, encoding="utf-8")

    print(f"Fixed {total_replacements} inconsistent quotation mark(s) in {path}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
