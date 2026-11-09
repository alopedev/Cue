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

step "CueKit: coverage of every test bundle"
# `swift test --show-codecov-path` only covers the first test bundle, so export
# the merged profile against all of them (CueKitTests and DesignSystemTests).
BIN_PATH="$(cd CueKit && swift build --show-bin-path)"
PROFILE="$BIN_PATH/codecov/default.profdata"
COVERAGE_JSON="$ROOT/.build/coverage.json"
TEST_BINARIES=()
for bundle in "$BIN_PATH"/*.xctest; do
    TEST_BINARIES+=(-object "$bundle/Contents/MacOS/$(basename "$bundle" .xctest)")
done
[[ -f "$PROFILE" && ${#TEST_BINARIES[@]} -gt 0 ]] || fail "coverage: no profile or test bundles in $BIN_PATH"
mkdir -p "$ROOT/.build"
xcrun llvm-cov export -summary-only -instr-profile "$PROFILE" "${TEST_BINARIES[@]:1}" >"$COVERAGE_JSON" \
    || fail "coverage export"
python3 scripts/check_coverage.py "$COVERAGE_JSON" || fail "coverage"

if [[ "${SKIP_UI_TESTS:-0}" == "1" ]]; then
    step "App: UI tests skipped (SKIP_UI_TESTS=1)"
    exit 0
fi

step "App: build and UI tests in the simulator"
SIMULATOR="${CUE_SIMULATOR:-$(python3 scripts/pick_simulator.py)}"
[[ -n "$SIMULATOR" ]] || fail "no iPhone simulator found. Install an iOS runtime in Xcode > Settings > Components"
echo "Simulator: $SIMULATOR"
rm -rf "$RESULT_BUNDLE"
# A cold simulator can take longer to boot than the UI tests wait for the app.
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR" -b >/dev/null || fail "the simulator did not finish booting"
RETRY_FLAGS=()
if [[ -n "${CI:-}" ]]; then
    # GitHub's shared machines are slow and noisy: a failing UI test runs once more there.
    RETRY_FLAGS=(-retry-tests-on-failure -test-iterations 2)
fi
xcodebuild test \
    -project Cue.xcodeproj \
    -scheme Cue \
    -destination "platform=iOS Simulator,id=$SIMULATOR" \
    -derivedDataPath "$DERIVED_DATA" \
    -resultBundlePath "$RESULT_BUNDLE" \
    CODE_SIGNING_ALLOWED=NO \
    ${RETRY_FLAGS[@]+"${RETRY_FLAGS[@]}"} \
    -quiet || fail "app build or UI tests. Details: open $RESULT_BUNDLE in Xcode"

printf '\nAll checks passed.\n'
