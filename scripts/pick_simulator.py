#!/usr/bin/env python3
"""Prints the id of an available iPhone simulator on the newest iOS runtime."""

import json
import re
import subprocess

# Standard runtimes only, e.g. "com.apple.CoreSimulator.SimRuntime.iOS-27-2".
# Device-specific preview runtimes ("...iOS-27-2-iPhone19-4") are skipped.
RUNTIME_PATTERN = re.compile(r"\.iOS-(\d+)-(\d+)$")


def version_key(runtime: str) -> tuple:
    match = RUNTIME_PATTERN.search(runtime)
    return (int(match.group(1)), int(match.group(2))) if match else (0, 0)


def main() -> None:
    output = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    devices = json.loads(output)["devices"]
    runtimes = sorted((r for r in devices if RUNTIME_PATTERN.search(r)), key=version_key, reverse=True)
    for runtime in runtimes:
        for device in devices[runtime]:
            if device["name"].startswith("iPhone"):
                print(device["udid"])
                return


if __name__ == "__main__":
    main()
