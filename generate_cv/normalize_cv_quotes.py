#!/usr/bin/env python3
"""Normalize quotation marks in CV prose before LaTeX compilation."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def normalize(text: str) -> str:
    # Convert paired Unicode curly double quotes to standard TeX quotation marks.
    text = re.sub(r"“([^”\n]+)”", r"``\1''", text)

    # Convert paired straight quotes, plus half-normalized pairs left by older
    # source edits. Restrict matches to a single line so URLs and structure are
    # not consumed accidentally.
    text = re.sub(r'"([^"\n]+)"', r"``\1''", text)
    text = re.sub(r'"([^"\n]+)\'\'', r"``\1''", text)
    text = re.sub(r'``([^"\n]+)"', r"``\1''", text)

    # CV titles occur at the start of an \item or an \href argument. Normalize
    # straight/malformed opening marks only in those well-defined positions.
    text = re.sub(r'(\\item\s+)(?:"|\'\')(?=\S)', r"\1``", text)
    text = re.sub(r'(\\href\{[^\n]*?\}\{)(?:"|\'\')(?=\S)', r"\1``", text)

    return text


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} TEX_FILE", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    original = path.read_text(encoding="utf-8")
    updated = normalize(original)

    if updated != original:
        path.write_text(updated, encoding="utf-8")
        print(f"Normalized quotation marks in: {path}")
    else:
        print(f"Quotation marks already normalized: {path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
