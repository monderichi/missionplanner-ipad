#!/usr/bin/env bash
# Mac Catalyst UI testing (no iOS simulator runtime needed). Needs Xcode (license accepted) + xcodegen.
#   testing/sim/catalyst.sh build              # generate + build the app for "My Mac (Mac Catalyst)"
#   testing/sim/catalyst.sh run [ARGS...]      # launch the built app with test defaults (+ ARGS), isolated HOME
#   testing/sim/catalyst.sh uitest [TEST]      # fake drone (auto-restart) + XCUITest suite on Catalyst
#   testing/sim/catalyst.sh clean              # remove DerivedData, test HOME, app preferences
# The UI-test runner is re-signed ad-hoc after the build: macOS library validation rejects an ad-hoc test bundle
# inside a runner that still carries Apple's team ID ("mapping process and mapped file have different Team IDs").
# App data goes to testing/.build/catalyst_home (CFFIXED_USER_HOME), never ~/Documents.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PRJ="$ROOT/testing/.build/catalyst"; DD="$ROOT/testing/.build/DerivedDataCatalyst"
LOGS="$ROOT/testing/logs"; ART="$ROOT/testing/artifacts/catalyst"; HOMEDIR="$ROOT/testing/.build/catalyst_home"
BID=io.github.missionplannerpad.breaktest
mkdir -p "$PRJ" "$LOGS" "$ART" "$HOMEDIR/Documents"
DEST='platform=macOS,variant=Mac Catalyst'
gen() { xcodegen generate --quiet --spec "$ROOT/testing/sim/project-catalyst.yml" --project "$PRJ"; }
# test selector: "" = all, "Class" (BreakTestUITests2), "Class/test", or a bare test name in BreakTestUITests
sel() { case "$1" in "") ;; BreakTestUITests*/*) echo "-only-testing:BreakTestUITests/$1" ;;
        BreakTestUITests*) echo "-only-testing:BreakTestUITests/$1" ;; *) echo "-only-testing:BreakTestUITests/BreakTestUITests/$1" ;; esac; }
app() { find "$DD" -path '*maccatalyst*' -name MissionPlannerPad.app -maxdepth 5 | head -1; }
case "${1:-}" in
  build)
    gen
    xcodebuild -project "$PRJ/MissionPlannerPadCatalyst.xcodeproj" -scheme BreakTestCatalyst -destination "$DEST" \
      -derivedDataPath "$DD" build-for-testing > "$LOGS/catalyst_build.log" 2>&1 \
      && codesign --force --deep --sign - "$(dirname "$(app)")/BreakTestUITests-Runner.app" >/dev/null 2>&1 \
      && echo "built: $(app)" || { grep -E "error:" "$LOGS/catalyst_build.log" | sort -u | head -25; exit 2; } ;;
  run)
    shift
    CFFIXED_USER_HOME="$HOMEDIR" "$(app)/Contents/MacOS/MissionPlannerPad" \
      -link.kind TCP -link.host 127.0.0.1 -link.port 5799 -speech.enabled '<false/>' "$@" > "$LOGS/catalyst_app.log" 2>&1 &
    echo "pid $!" ;;
  uitest)
    killall "Problem Reporter" 2>/dev/null || true   # close "quit unexpectedly" dialogs left by deliberate crash tests
    ( while true; do python3 "$ROOT/testing/fake_drone/fake_drone.py" --tcp-server 5799 >> "$LOGS/catalyst_drone.log" 2>&1; sleep 2; done ) &
    LOOP=$!; trap 'kill $LOOP 2>/dev/null; pkill -f "fake_drone.py --tcp-server 5799" || true' EXIT
    RB="$ROOT/testing/.build/catalyst_uitest.xcresult"; rm -rf "$RB"
    set +e
    TEST_RUNNER_BREAKTEST_LONG_MIN="${BREAKTEST_LONG_MIN:-30}" TEST_RUNNER_BREAKTEST_HOME="$HOMEDIR" xcodebuild -project "$PRJ/MissionPlannerPadCatalyst.xcodeproj" -scheme BreakTestCatalyst -destination "$DEST" \
      -derivedDataPath "$DD" -resultBundlePath "$RB" $(sel "${2:-}") \
      test-without-building > "$LOGS/catalyst_uitest.log" 2>&1; rc=$?
    set -e
    grep -E "Test Case .*(passed|failed)|error: -\[|Fatal error|crashed" "$LOGS/catalyst_uitest.log" | sed 's/^.*Test Case/Test Case/' | head -60
    ART="$ART/${2:-suite}"; rm -rf "$ART"; mkdir -p "$ART"
    xcrun xcresulttool export attachments --path "$RB" --output-path "$ART" >/dev/null 2>&1 || echo "(attachments: open $RB)"
    python3 - "$ART" <<'PY'
import json, os, re, sys
d = sys.argv[1]
for t in json.load(open(os.path.join(d, "manifest.json"))):
    for a in t["attachments"]:
        n = re.sub(r"_\d+_[0-9A-F-]{36}", "", a["suggestedHumanReadableName"]).replace("--[BreakTestUITests ", "-").replace("]", "")
        os.replace(os.path.join(d, a["exportedFileName"]), os.path.join(d, n))
PY
    ls "$ART" | grep -v manifest | head -40
    exit $rc ;;
  perf)  # perf TEST [interval_s]: run a UI test while sampling the app's CPU % and RSS into testing/logs/catalyst_perf_<TEST>.csv
    T="${2:?test name}"; IV="${3:-5}"; CSV="$LOGS/catalyst_perf_${T##*/}.csv"; echo "t_s,cpu_pct,rss_mb" > "$CSV"
    ( t0=$(date +%s); while true; do
        pid=$(pgrep -f "MissionPlannerPad.app/Contents/MacOS/MissionPlannerPad" | head -1 || true)
        [[ -n "$pid" ]] && ps -o %cpu=,rss= -p "$pid" | awk -v t=$(( $(date +%s) - t0 )) '{printf "%d,%.1f,%.1f\n", t, $1, $2/1024}' >> "$CSV"
        sleep "$IV"; done ) &
    SAMPLER=$!
    "$0" uitest "$T"; rc=$?
    kill $SAMPLER 2>/dev/null
    awk -F, 'NR>1 && $3>0 {n++; c+=$2; if ($3>m) m=$3; if (!f) f=$3; l=$3} END {if (n) printf "samples=%d avg_cpu=%.0f%% rss_first=%.0fMB rss_last=%.0fMB rss_max=%.0fMB\n", n, c/n, f, l, m}' "$CSV"
    exit $rc ;;
  clean)
    rm -rf "$DD" "$PRJ" "$HOMEDIR" "$ROOT/testing/.build/catalyst_uitest.xcresult"
    defaults delete "$BID" 2>/dev/null || true; defaults delete "$BID.uitests.xctrunner" 2>/dev/null || true ;;
  *) sed -n 2,8p "$0" ;;
esac
