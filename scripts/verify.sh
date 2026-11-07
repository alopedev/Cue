#!/usr/bin/env bash
# Runs every quality gate of Cue. Green here = ready for a PR.
#
#   scripts/verify.sh            all steps
#   SKIP_UI_TESTS=1 scripts/verify.sh   skip the simulator (faster)
#   CUE_SIMULATOR="iPhone 17" scripts/verify.sh   pick the simulator
#
# Steps: no secrets in git -> format -> lint -> CueKit build + tests + coverage
#        -> app build + UI tests in the simulator.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SOURCES=(Cue CueUITests CueKit/Sources CueKit/Tests CueKit/Package.swift)
DERIVED_DATA="${DERIVED_DATA:-$ROOT/.build/DerivedData}"
RESULT_BUNDLE="$ROOT/.build/UITests.xcresult"

step() { printf '\n==> %s\n' "$1"; }
fail() { printf '\nFAIL: %s\n' "$1" >&2; exit 1; }

step "Secrets: Config/Secrets.xcconfig must not be in git"
if git ls-files --error-unmatch Config/Secrets.xcconfig >/dev/null 2>&1; then
    fail "Config/Secrets.xcconfig is tracked by git. Remove it with: git rm --cached Config/Secrets.xcconfig"
fi

step "Format (swift-format)"
xcrun swift-format lint --strict --recursive "${SOURCES[@]}" || fail "format. Fix with: xcrun swift-format format -i -r ${SOURCES[*]}"

step "Lint (SwiftLint)"
command -v swiftlint >/dev/null || fail "SwiftLint is not installed. Install it with: brew install swiftlint"
swiftlint lint --quiet || fail "lint"

step "CueKit: build and tests with coverage"
(cd CueKit && swift build && swift test --enable-code-coverage) || fail "CueKit tests"

step "CueKit: coverage"
python3 scripts/check_coverage.py "$(cd CueKit && swift test --show-codecov-path)" || fail "coverage"

if [[ "${SKIP_UI_TESTS:-0}" == "1" ]]; then
    step "App: UI tests skipped (SKIP_UI_TESTS=1)"
    exit 0
fi

step "App: build and UI tests in the simulator"
SIMULATOR="${CUE_SIMULATOR:-$(python3 scripts/pick_simulator.py)}"
[[ -n "$SIMULATOR" ]] || fail "no iPhone simulator found. Install an iOS runtime in Xcode > Settings > Components"
echo "Simulator: $SIMULATOR"
rm -rf "$RESULT_BUNDLE"
xcodebuild test \
    -project Cue.xcodeproj \
    -scheme Cue \
    -destination "platform=iOS Simulator,id=$SIMULATOR" \
    -derivedDataPath "$DERIVED_DATA" \
    -resultBundlePath "$RESULT_BUNDLE" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet || fail "app build or UI tests. Details: open $RESULT_BUNDLE in Xcode"

printf '\nAll checks passed.\n'
