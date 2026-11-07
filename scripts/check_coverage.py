#!/usr/bin/env python3
"""Checks CueKit line coverage per target against the plan's thresholds.

Usage: check_coverage.py <path to the llvm-cov JSON from `swift test --show-codecov-path`>

Thresholds (development plan, section 5): Domain and Engine >= 95 %,
every other CueKit target >= 85 %. A target with no code yet is skipped.
"""

import json
import re
import sys
from collections import defaultdict

STRICT_TARGETS = {"Domain": 95.0, "Engine": 95.0}
DEFAULT_THRESHOLD = 85.0
TARGET_PATTERN = re.compile(r"/CueKit/Sources/([^/]+)/")


def coverage_by_target(report: dict) -> dict:
    totals = defaultdict(lambda: [0, 0])  # target -> [covered, count]
    for data in report["data"]:
        for file in data["files"]:
            match = TARGET_PATTERN.search(file["filename"])
            if not match:
                continue
            lines = file["summary"]["lines"]
            totals[match.group(1)][0] += lines["covered"]
            totals[match.group(1)][1] += lines["count"]
    return totals


def main() -> int:
    with open(sys.argv[1], encoding="utf-8") as handle:
        totals = coverage_by_target(json.load(handle))

    failed = False
    for target in sorted(totals):
        covered, count = totals[target]
        threshold = STRICT_TARGETS.get(target, DEFAULT_THRESHOLD)
        if count == 0:
            print(f"  {target}: no code yet (skipped)")
            continue
        percent = 100.0 * covered / count
        status = "ok" if percent >= threshold else "TOO LOW"
        failed |= percent < threshold
        print(f"  {target}: {percent:.1f} % (minimum {threshold:.0f} %) {status}")
    if not totals:
        print("  No CueKit code yet (skipped)")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
