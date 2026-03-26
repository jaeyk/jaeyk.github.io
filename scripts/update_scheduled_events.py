#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from datetime import date
from pathlib import Path


MONTHS = {
    "jan": 1,
    "january": 1,
    "feb": 2,
    "february": 2,
    "mar": 3,
    "march": 3,
    "apr": 4,
    "april": 4,
    "may": 5,
    "jun": 6,
    "june": 6,
    "jul": 7,
    "july": 7,
    "aug": 8,
    "august": 8,
    "sep": 9,
    "sept": 9,
    "september": 9,
    "oct": 10,
    "october": 10,
    "nov": 11,
    "november": 11,
    "dec": 12,
    "december": 12,
}

DATE_RANGE_RE = re.compile(
    r"^\s*"
    r"(?P<month>[A-Za-z]+)"
    r"\s+"
    r"(?P<start>\d{1,2})"
    r"(?:\s*[-–]\s*(?:(?P<end_month>[A-Za-z]+)\s+)?(?P<end>\d{1,2}))?"
    r"\s*$"
)
YEAR_HEADER_RE = re.compile(r"<summary>.*?\b(20\d{2})\b.*?</summary>")
SCHEDULED_MARKER_RE = re.compile(r"\s*\(\*scheduled\*\)")


@dataclass
class ParseResult:
    year: int | None
    updated_lines: list[str]
    removed_count: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Remove expired '(*scheduled*)' markers from index.qmd event rows."
    )
    parser.add_argument(
        "--file",
        default="index.qmd",
        help="Target Quarto file to update. Defaults to index.qmd.",
    )
    return parser.parse_args()


def parse_end_date(raw_date: str, year: int) -> date | None:
    match = DATE_RANGE_RE.match(raw_date.strip())
    if not match:
        return None

    month_name = match.group("month").lower()
    end_month_name = (match.group("end_month") or month_name).lower()
    end_day = int(match.group("end") or match.group("start"))

    month = MONTHS.get(end_month_name)
    if month is None:
        return None

    try:
        return date(year, month, end_day)
    except ValueError:
        return None


def process_lines(lines: list[str], today: date) -> ParseResult:
    current_year: int | None = None
    removed_count = 0
    updated_lines: list[str] = []

    for line in lines:
        header_match = YEAR_HEADER_RE.search(line)
        if header_match:
            current_year = int(header_match.group(1))
            updated_lines.append(line)
            continue

        if current_year is None or "(*scheduled*)" not in line or not line.lstrip().startswith("|"):
            updated_lines.append(line)
            continue

        cells = [cell.strip() for cell in line.strip().split("|")[1:-1]]
        if not cells:
            updated_lines.append(line)
            continue

        end_date = parse_end_date(cells[0], current_year)
        if end_date is None or end_date >= today:
            updated_lines.append(line)
            continue

        new_line, replacements = SCHEDULED_MARKER_RE.subn("", line, count=1)
        removed_count += replacements
        updated_lines.append(new_line)

    return ParseResult(year=current_year, updated_lines=updated_lines, removed_count=removed_count)


def main() -> int:
    args = parse_args()
    path = Path(args.file)
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)
    result = process_lines(lines, today=date.today())
    updated = "".join(result.updated_lines)

    if updated != original:
        path.write_text(updated, encoding="utf-8")

    print(f"Removed {result.removed_count} expired scheduled marker(s) from {path}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
