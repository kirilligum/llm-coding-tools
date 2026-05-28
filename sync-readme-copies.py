#!/usr/bin/env python3
"""Sync generated copy blocks in README.md from their source prompt files."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
README_PATH = ROOT / "README.md"

COPY_BLOCKS = [
    {
        "source": ROOT / "phase-plan-follow-upper.txt",
        "begin": "<!-- BEGIN phase-plan-follow-upper.txt copy -->",
        "end": "<!-- END phase-plan-follow-upper.txt copy -->",
        "language": "text",
    },
]


def fence_for(text: str) -> str:
    longest_backtick_run = max(
        (len(match.group(0)) for match in re.finditer(r"`+", text)),
        default=0,
    )
    return "`" * max(3, longest_backtick_run + 1)


def replace_block(readme: str, block: dict[str, object]) -> str:
    source_path = block["source"]
    begin = str(block["begin"])
    end = str(block["end"])
    language = str(block["language"])

    if not isinstance(source_path, Path):
        raise TypeError("source must be a Path")

    if readme.count(begin) != 1 or readme.count(end) != 1:
        raise ValueError(f"Expected exactly one generated block for {source_path.name}")

    source = source_path.read_text().rstrip("\n")
    fence = fence_for(source)
    replacement = f"{begin}\n{fence}{language}\n{source}\n{fence}\n{end}"

    pattern = re.escape(begin) + r".*?" + re.escape(end)
    updated, count = re.subn(pattern, replacement, readme, count=1, flags=re.S)
    if count != 1:
        raise ValueError(f"Could not replace generated block for {source_path.name}")

    return updated


def sync_readme() -> str:
    readme = README_PATH.read_text()
    for block in COPY_BLOCKS:
        readme = replace_block(readme, block)
    return readme


def main(argv: list[str]) -> int:
    check_only = argv == ["--check"]
    if argv and not check_only:
        print("usage: python3 sync-readme-copies.py [--check]", file=sys.stderr)
        return 2

    current = README_PATH.read_text()
    updated = sync_readme()

    if current == updated:
        print("README.md generated copy blocks are in sync.")
        return 0

    if check_only:
        print(
            "README.md generated copy blocks are out of sync. "
            "Run `python3 sync-readme-copies.py`.",
            file=sys.stderr,
        )
        return 1

    README_PATH.write_text(updated)
    print("Updated README.md generated copy blocks.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
