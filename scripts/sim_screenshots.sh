#!/usr/bin/env bash
# Builds the app for the iPad Simulator, starts tools/fake_vehicle.py (a fake ArduCopter on
# tcp 127.0.0.1:5760), launches the app on each screen connected to it, and saves screenshots,
# the fake vehicle's log of everything the app sent, and any crash reports to build/sim/.
# Runs on the GitHub macOS runner (workflow job "simulator").
set -uo pipefail

cd "$(dirname "$0")/.."
OUT=build/sim
mkdir -p "$OUT"
BID=io.github.missionplannerpad.app

xcodegen generate
if ! xcodebuild -project MissionPlannerPad.xcodeproj -scheme MissionPlannerPad -configuration Debug \
     -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath build/SimDerived \
     CODE_SIGNING_ALLOWED=NO build > "$OUT/xcodebuild.log" 2>&1; then
  grep -E "error:" "$OUT/xcodebuild.log" | head -40
  tail -40 "$OUT/xcodebuild.log"
  exit 1
fi
APP=build/SimDerived/Build/Products/Debug-iphonesimulator/MissionPlannerPad.app

# newest iOS runtime, prefer a 13-inch iPad Pro, else any iPad
UDID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
d = json.load(sys.stdin)["devices"]
c = [(rt, x) for rt, l in d.items() if "iOS" in rt for x in l if "iPad" in x["name"]]
c.sort(key=lambda p: (p[0], "13-inch" in p[1]["name"] and "Pro" in p[1]["name"]), reverse=True)
print(c[0][1]["udid"] if c else "")')
if [ -z "$UDID" ]; then echo "no iPad simulator available"; xcrun simctl list devices available; exit 1; fi
NAME=$(xcrun simctl list devices -j | python3 -c "import json,sys; print([x['name'] for l in json.load(sys.stdin)['devices'].values() for x in l if x['udid']=='$UDID'][0])")
echo "Simulator: $NAME ($UDID)" | tee "$OUT/notes.txt"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b
xcrun simctl install "$UDID" "$APP"

python3 -I tools/fake_vehicle.py --port 5760 --seconds 1200 > "$OUT/fake_vehicle.log" 2>&1 &
FAKE=$!
sleep 2

shot() {
  local name=$1 wait=$2
  shift 2
  echo "== $name: $*" >> "$OUT/notes.txt"
  xcrun simctl launch --terminate-running-process "$UDID" "$BID" "$@" >> "$OUT/notes.txt" 2>&1
  sleep "$wait"
  xcrun simctl io "$UDID" screenshot "$OUT/$name.png" > /dev/null 2>&1
  if ! pgrep -f "MissionPlannerPad.app/MissionPlannerPad" > /dev/null; then
    echo "!! app NOT running after $name (crash?)" | tee -a "$OUT/notes.txt"
  fi
}

C=(-MPAutoConnect tcp:127.0.0.1:5760)
shot 01-connect-sheet 6
shot 02-data-quick 14 "${C[@]}" -MPScreen data -MPTab quick
shot 03-data-actions 10 "${C[@]}" -MPScreen data -MPTab actions
shot 04-data-status 10 "${C[@]}" -MPScreen data -MPTab status
shot 05-data-checklist 10 "${C[@]}" -MPScreen data -MPTab checklist
shot 06-data-servo 10 "${C[@]}" -MPScreen data -MPTab servo
shot 07-plan-mission 16 "${C[@]}" -MPScreen plan -MPReadMission YES
shot 08-setup-prearm 10 "${C[@]}" -MPScreen setup -MPSetupPage prearm
shot 09-setup-fence 16 "${C[@]}" -MPScreen setup -MPSetupPage fence
shot 10-setup-modes 16 "${C[@]}" -MPScreen setup -MPSetupPage modes
shot 11-setup-battery 16 "${C[@]}" -MPScreen setup -MPSetupPage battery
shot 12-params 18 "${C[@]}" -MPScreen params
shot 13-diagnostics 12 "${C[@]}" -MPScreen data -MPShowDiagnostics YES
shot 14-data-messages 16 "${C[@]}" -MPScreen data -MPTab messages

# telemetry logs from the simulator (proves which MAVLink messages, e.g. STATUSTEXT, reached the app)
DATA=$(xcrun simctl get_app_container "$UDID" "$BID" data 2>/dev/null || true)
mkdir -p "$OUT/tlogs"
if [ -n "$DATA" ]; then cp "$DATA"/Documents/logs/*.tlog "$OUT/tlogs/" 2>/dev/null || true; fi

kill "$FAKE" 2>/dev/null || true
cp ~/Library/Logs/DiagnosticReports/*MissionPlannerPad* "$OUT/" 2>/dev/null || true
grep -c "APP ->" "$OUT/fake_vehicle.log" | xargs echo "messages the app sent to the fake vehicle:" | tee -a "$OUT/notes.txt"
grep -o "APP -> [A-Z_]*" "$OUT/fake_vehicle.log" | sort | uniq -c | sort -rn | tee -a "$OUT/notes.txt"
ls -la "$OUT"
