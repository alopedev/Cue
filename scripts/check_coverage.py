#!/usr/bin/env python3
"""Checks CueKit line coverage against the plan's thresholds.

Usage: check_coverage.py <llvm-cov JSON export covering every test bundle>

Coverage is grouped by area: each folder directly under `Sources/CueKit/`
(Domain, Engine, Library, Adapters…) and every other target as a whole
(DesignSystem). Thresholds (development plan, section 5): Domain and Engine
>= 95 %, every other area >= 85 %. An area with no code yet is skipped.
"""

import json
import re
import sys
from collections import defaultdict

STRICT_AREAS = {"Domain": 95.0, "Engine": 95.0}
DEFAULT_THRESHOLD = 85.0
SOURCE_PATTERN = re.compile(r"/CueKit/Sources/([^/]+)/(?:([^/]+)/)?")


def area_of(filename: str) -> str | None:
    """Folder under Sources/CueKit for the logic target, the target name otherwise."""
    match = SOURCE_PATTERN.search(filename)
    if not match:
        return None
    target, folder = match.groups()
    if target == "CueKit" and folder:
        return folder
    return target


def coverage_by_area(report: dict) -> dict:
    totals = defaultdict(lambda: [0, 0])  # area -> [covered, count]
    seen = set()
    for data in report["data"]:
        for file in data["files"]:
            name = file["filename"]
            area = area_of(name)
            if area is None or name in seen:
                continue
            seen.add(name)
            lines = file["summary"]["lines"]
            totals[area][0] += lines["covered"]
            totals[area][1] += lines["count"]
    return totals


def main() -> int:
    with open(sys.argv[1], encoding="utf-8") as handle:
        totals = coverage_by_area(json.load(handle))

    if not totals:
        print("  FAIL: the coverage report has no CueKit source files")
        return 1

    failed = False
    for area in sorted(totals):
        covered, count = totals[area]
        threshold = STRICT_AREAS.get(area, DEFAULT_THRESHOLD)
        if count == 0:
            print(f"  {area}: no code yet (skipped)")
            continue
        percent = 100.0 * covered / count
        status = "ok" if percent >= threshold else "TOO LOW"
        failed |= percent < threshold
        print(f"  {area}: {percent:.1f} % (minimum {threshold:.0f} %) {status}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
