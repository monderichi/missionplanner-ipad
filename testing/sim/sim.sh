#!/usr/bin/env bash
# iPad Simulator driver. NOT RUN in the 2026-11-27 session (no Xcode on the test Mac); written so the
# UI-level repros in TESTING_RESULTS.md can be run as soon as Xcode + an iOS runtime are installed.
#   testing/sim/sim.sh build            # xcodegen + xcodebuild for the simulator (needs: brew install xcodegen)
#   testing/sim/sim.sh boot [MODEL]     # default "iPad Pro 13-inch (M4)", falls back to the first iPad
#   testing/sim/sim.sh run              # install + launch, start log capture
#   testing/sim/sim.sh shot NAME        # screenshot -> testing/artifacts/NAME.png
#   testing/sim/sim.sh video NAME       # record until Ctrl-C -> testing/artifacts/NAME.mov
#   testing/sim/sim.sh stop             # stop log capture, shut the simulator down
#   testing/sim/sim.sh uitest [TEST]    # fake drone (auto-restart) + XCUITest suite testing/sim/UITests -> testing/artifacts/
# The simulator shares the Mac's network: in the app choose TCP 127.0.0.1:5799 and start a fake drone with
#   python3 testing/fake_drone/fake_drone.py --tcp-server 5799 [--fault ...]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ART="$ROOT/testing/artifacts"; LOGS="$ROOT/testing/logs"; DD="$ROOT/testing/.build/DerivedData"
BUNDLE=io.github.missionplannerpad.app
mkdir -p "$ART" "$LOGS"
udid() { cat "$ROOT/testing/.build/sim_udid" 2>/dev/null; }
case "${1:-}" in
  build)
    cd "$ROOT" && xcodegen generate --quiet
    xcodebuild -project MissionPlannerPad.xcodeproj -scheme MissionPlannerPad -sdk iphonesimulator \
      -configuration Debug -derivedDataPath "$DD" CODE_SIGNING_ALLOWED=NO build > "$LOGS/sim_build.log" 2>&1 \
      && echo "built: $(find "$DD" -name MissionPlannerPad.app -path '*iphonesimulator*' | head -1)" \
      || { grep -E "error:" "$LOGS/sim_build.log" | head -20; exit 2; } ;;
  boot)
    MODEL="${2:-iPad Pro 13-inch (M4)}"
    U=$(xcrun simctl list devices available | grep -F "$MODEL (" | head -1 | grep -oE '[0-9A-F-]{36}' || true)
    [[ -z "$U" ]] && U=$(xcrun simctl list devices available | grep -E "iPad" | head -1 | grep -oE '[0-9A-F-]{36}')
    echo "$U" > "$ROOT/testing/.build/sim_udid"
    xcrun simctl boot "$U" 2>/dev/null || true
    xcrun simctl list devices | grep "$U" | tee "$LOGS/sim_device.txt" ;;
  run)
    APP=$(find "$DD" -name MissionPlannerPad.app -path '*iphonesimulator*' | head -1)
    xcrun simctl install "$(udid)" "$APP"
    xcrun simctl spawn "$(udid)" log stream --level debug --predicate "process == \"MissionPlannerPad\"" > "$LOGS/sim_app.log" 2>&1 &
    echo $! > "$ROOT/testing/.build/sim_logpid"
    xcrun simctl launch "$(udid)" "$BUNDLE" ;;
  shot) xcrun simctl io "$(udid)" screenshot "$ART/${2:-shot}.png" ;;
  video) xcrun simctl io "$(udid)" recordVideo "$ART/${2:-video}.mov" ;;
  stop)
    kill "$(cat "$ROOT/testing/.build/sim_logpid" 2>/dev/null)" 2>/dev/null || true
    xcrun simctl shutdown "$(udid)" 2>/dev/null || true ;;
  uitest)
    command -v xcodegen >/dev/null || { echo "needs: brew install xcodegen"; exit 2; }
    SIMPRJ="$ROOT/testing/.build/sim"; mkdir -p "$SIMPRJ"
    xcodegen generate --quiet --spec "$ROOT/testing/sim/project.yml" --project "$SIMPRJ"
    [[ -n "$(udid)" ]] || "$0" boot
    ( while true; do python3 "$ROOT/testing/fake_drone/fake_drone.py" --tcp-server 5799 >> "$LOGS/sim_drone.log" 2>&1; sleep 2; done ) &
    DRONE_LOOP=$!; trap 'kill $DRONE_LOOP 2>/dev/null; pkill -f "fake_drone.py --tcp-server 5799"' EXIT
    RB="$ROOT/testing/.build/uitest.xcresult"; rm -rf "$RB"
    xcodebuild -project "$SIMPRJ/MissionPlannerPadBreakTest.xcodeproj" -scheme BreakTest -derivedDataPath "$DD" \
      -destination "id=$(udid)" -resultBundlePath "$RB" ${2:+-only-testing:BreakTestUITests/BreakTestUITests/$2} \
      test > "$LOGS/sim_uitest.log" 2>&1; rc=$?
    grep -E "Test Case .*(passed|failed)|error:" "$LOGS/sim_uitest.log" | sed 's/^.*Test Case/Test Case/' | head -40
    xcrun xcresulttool export attachments --path "$RB" --output-path "$ART" >/dev/null 2>&1 \
      || echo "(attachments: open $RB in Xcode)"
    exit $rc ;;
  *) sed -n 2,13p "$0" ;;
esac
