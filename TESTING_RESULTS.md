# TESTING_RESULTS: Mission Planner for iPad, break-test against simulated drones

Tested commit `c14c3e1` (build 0.4.0), 2026-11-27. Written for the agent that will fix these issues: every
action item has a one-command repro, the suspected cause with `file:line`, a suggested fix and acceptance criteria.
Ground rule kept: **no app source was modified**. All test code lives in `testing/` (see `testing/README.md`).

---

## 0. Test plan (written before testing)

**App map.** SwiftUI iPad app (iOS 16+) plus the `MAVLinkKit` package (codec and pure, clock-injected state machines
for parameters, commands, missions and logs). MAVLink v1/v2 (ardupilotmega), GCS id 255/190, 1 Hz GCS heartbeat,
REQUEST_DATA_STREAM + SET_MESSAGE_INTERVAL. Transports: UDP listen (14550), UDP connect, TCP client, ExpressLRS backpack
(UDP bind 14550 → 10.0.0.1:14555 + `GET /mavlink`), BLE UART. One vehicle at a time. Data flow: transport callback →
`LinkManager.ioQueue` (parser, tlog) → main queue → `VehicleModel.handle` + stores (`ParameterStore`, `CommandCenter`,
`MissionStore`, `CalibrationStore`, `LogStore`), driven by a 4 Hz control timer and a 1 Hz heartbeat/staleness timer.
State machines: link state, vehicle lock (heartbeat sysid/compid, 5 s timeout), attitude watchdog (3 s), command
retry/ACK, parameter download/gap-fill/set, mission up/download, log list/download, accel-cal (vehicle-driven).
Persistence: Documents/{logs,params,missions,tiles}; `@AppStorage` for connect settings and Actions inputs.

**Fake-drone approach (in order of realism).**
1. **ArduCopter 4.7.3 SITL** (the user's exact firmware, d9c5097c), built natively on macOS by `testing/sitl/build_sitl.sh`.
2. **Scripted mock ArduCopter**, `testing/fake_drone/fake_drone.py` (stdlib only; reuses `tools/mavlink_ref.py`): heartbeat,
   telemetry, params, arming, modes, guided takeoff, AUTO missions, RTL/land, fence/rally, logs, ~35 injectable faults,
   runtime control over UDP 17001. Used for faults SITL can't produce on demand.
3. **Fault proxy**, `testing/fake_drone/fault_proxy.py`: loss, latency, jitter, duplication, reordering, corruption, blackout.
4. **Headless app harness**, `testing/harness/`: compiles the app's **real, unmodified** `App/Link`, `App/Vehicle`,
   `App/Storage` sources on macOS with a scripted driver instead of SwiftUI, so the real `LinkManager` + stores run against
   the fake drones. **Crash probes** run single suspicious code paths in their own process (real app code where possible,
   otherwise the exact expression copied from a SwiftUI view).

**Environment limit found in recon:** the test Mac had **no Xcode** (Command Line Tools only). So there was no iPad
Simulator, `xcodebuild`, XCTest or XCUITest. The MAVLinkKit suite runs through a small XCTest stand-in
(`testing/unit/`, test sources unchanged). UI-only behaviour was covered by code inspection plus headless execution of the
same logic; `testing/sim/sim.sh` is ready for a simulator run once Xcode is installed (see section 6).

**Not testable in simulation:** ExpressLRS RF/backpack Wi-Fi, the iPadOS Local Network prompt, BLE bridges, Sideloadly
install, the Files app, speech output, real sensor calibration, real flight.

---

## 1. Summary

**Environment.** macOS 26.7.3 (Apple silicon), Command Line Tools with Swift 6.4, **no Xcode → no iPad Simulator**
(model: none). Python 3.9.6 (stdlib only). Vehicles: scripted fake ArduCopter (all runs) + fault proxy; ArduCopter 4.7.3
SITL scripted but **not run** (see section 6: the source download had not finished when the session ended).

**What was tested.** 71 scenario/probe runs through the real app link/vehicle/store code, plus the unit suite.

| Suite | Result |
|---|---|
| Existing MAVLinkKit unit tests (34) | **34 pass, 0 fail** |
| New unit tests (`testing/unit/extra`, 8) | 4 coverage tests pass; 4 regression tests **fail as intended** (BUG-002, -007, -020) |
| Scenarios + probes (71) | **39 PASS, 16 FAIL, 16 CRASH** (a crash = the app process would die) |

Full verdict list: `testing/logs/summary.txt` after a run; the table in section 5 maps every TESTING.md item.

**What works well:** connecting over TCP / UDP listen / UDP connect; heartbeat lock (ignores other GCS and a second
vehicle); parameter download (400 and 1500 params; 400 params at 30 % loss + 80±60 ms jitter in 9.5 s); write with
confirm; `.param` round trip; arm/disarm/refusals; modes; guided takeoff/land; mission/fence/rally round trip; AUTO mission
to RTL and auto-disarm; reboot with parameter re-download; link-loss detection (~5 s) and recovery; parser resync under
noise/bad CRC/truncated/oversized frames; 50 Hz × 8 message streams at ~7 % CPU with flat memory; a 5-minute session grows only 0.5 MB; 700-item missions;
DataFlash list/download; tlog replay including garbage/empty files; rapid connect/disconnect.

**Top 5 risks**
1. **BUG-001**: when the transport fails (TCP reset/close) the red NO HEARTBEAT banner is *hidden*, the frozen HUD looks
   live, and TCP never reconnects.
2. **BUG-002**: a command can be "confirmed" by the ACK of an earlier command with the same id (Disarm by the Arm ACK,
   RTL by the Loiter ACK) and is then never retried.
3. **BUG-003/-004/-009**: single telemetry packets crash the GCS (NaN/Inf/huge ATTITUDE in the HUD, out-of-range position
   in the map, malformed ACCELCAL COMMAND_LONG). A crash in flight leaves the pilot without a GCS.
4. **BUG-008**: low battery and failsafes have no visual warning; without speech the pilot gets no alert at all.
5. **BUG-005/-006/-007/-010**: configuration and user input crash the app (FLTMODE_CH = 0, a long takeoff-altitude entry
   that persists and crash-loops the Actions tab, latitude typo, corrupt or huge `.waypoints`, big survey).

---

## 2. How to reproduce the test setup

From a clean checkout on macOS with Command Line Tools (Swift ≥ 5.9) and python3:

```bash
testing/unit/run_unit_tests.sh                 # MAVLinkKit suite + testing/unit/extra (exit 1 while BUG tests fail)
testing/harness/build_harness.sh               # builds the headless app (prints the binary path)
python3 testing/scenarios/run.py --list        # all scenario names
python3 testing/scenarios/run.py all           # everything except long/SITL runs (~10 min)
python3 testing/scenarios/run.py probes        # crash probes only (~10 s)
testing/scenarios/tcp_drop.sh                  # one scenario (one wrapper per scenario)
python3 testing/scenarios/run.py long_session  # 5 min memory run
testing/sitl/build_sitl.sh && python3 testing/scenarios/run.py sitl   # real ArduCopter 4.7.3 SITL (~1.5 GB)
```

Verdicts: PASS / FAIL (a check failed; reason printed) / CRASH (harness died on a signal; the Swift "Fatal error" line is
printed) / ERROR. Logs per run: `testing/logs/<scenario>.{harness,drone,proxy,sitl}.log`; `CHECK`, `NOTE`, `METRIC` and
`SNAPSHOT` (JSON of the app state) lines in the harness log.

Manual use of the fake drone (e.g. with the app in a simulator, which shares the Mac's network):

```bash
python3 testing/fake_drone/fake_drone.py --tcp-server 5799 --fault nan_attitude   # app: TCP 127.0.0.1:5799
python3 testing/fake_drone/fake_drone.py --udp-out 127.0.0.1:14550               # app: UDP listen 14550
python3 testing/fake_drone/fault_proxy.py --listen 14560 --loss 30 --latency 80 --jitter 60   # + drone --udp-out 127.0.0.1:14560
echo "fault gps_loss on" | nc -u -w0 127.0.0.1 17001                              # runtime fault control
```

Simulator (needs Xcode + `brew install xcodegen`; not run in this session):

```bash
testing/sim/sim.sh build
testing/sim/sim.sh boot "iPad Pro 13-inch (M4)"
testing/sim/sim.sh run
testing/sim/sim.sh shot <name>
testing/sim/sim.sh stop
```

The harness writes app files to `testing/.build/home/Documents` (via `CFFIXED_USER_HOME`) and passes
`-speech.enabled <false/>` so nothing is spoken and nothing lands in `~/Documents`.

---

## 3. Action items (sorted by severity)

Legend: **Verdict** CONFIRMED = reproduced by running the app's code; CODE = confirmed by reading the code, needs the
simulator for the UI part.

### BUG-001: A failed link hides the NO HEARTBEAT banner, keeps a frozen HUD on screen, and TCP never reconnects
- **Severity** High · **Category** safety · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/tcp_drop.sh` (connect over TCP, the fake drone process exits, then restarts 3 s later).
- **Expected** NO HEARTBEAT banner shown; telemetry marked stale; the app reconnects when the vehicle comes back.
- **Actual** `state=Failed: … Connection reset by peer hbAlive=false uiLinkAlive=true`: the banner is suppressed. Mode
  "Stabilize", attitude, ARMED/Disarmed and battery stay on screen as if live. No reconnect after the remote comes back
  (`TCP auto-reconnect after remote restart` FAIL). Only the small top-bar caption says "Failed: …".
- **Evidence** `testing/logs/tcp_drop.harness.log` (CHECK FAIL lines + SNAPSHOT).
- **Cause** `App/UI/RootView.swift:49` passes `linkAlive: vehicle.heartbeatAlive || !link.state.isActive`, so any
  non-active state (`.failed`, `.disconnected`) counts as "alive". `App/Link/NetworkTransports.swift:231-232` (TCP
  `isComplete`) and the `.failed` case of the state handler (≈line 185) end the TCP link with no retry (only UDP retries).
- **Fix** Show the banner whenever a vehicle was seen and `!vehicle.heartbeatAlive`, whatever the transport state (and
  label it "LINK FAILED" for `.failed`). Add reconnect with backoff (1, 2, 4… ≤ 10 s) for TCP on remote close/reset and
  `.failed`, until the user taps Disconnect. Grey out or mark stale every telemetry value when the link isn't alive.
- **Accept** `tcp_drop.sh` passes all 4 checks. In the simulator, killing the fake drone in flight shows the red banner
  within 5 s and the HUD reconnects by itself after the drone restarts.

### BUG-002: Commands are matched to ACKs by command id only; a later command is "accepted" by an earlier ACK and never retried
- **Severity** High · **Category** safety · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/probe_command_overwrite.sh`; unit tests `test_BUG002_*` (`testing/unit/run_unit_tests.sh`).
- **Expected** Arm then Disarm (or Loiter then RTL) in quick succession: the second command stays pending until *its*
  ACK, and is retried if lost.
- **Actual** `events=[accepted(command: 400)] pending=[] resent=0`: the Arm ACK completes the pending Disarm. On a lossy
  link (ELRS), if the second packet is lost, the UI says "Mode change: accepted" / "Arm/disarm: accepted" and nothing is
  resent.
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/CommandProtocol.swift:53` (`pending[command] = …` overwrites) and `:74`
  (ACK matched on `command` only). COMMAND_ACK carries no request id, so the fix must avoid the ambiguity.
- **Fix** Keep a queue per command id. When a new command arrives with the same id but different params while one is in
  flight, either (a) send it only after the earlier one resolves, or (b) supersede it: mark the old one superseded and keep
  the new one pending until an ACK that arrives *after* the new send + RTT, then confirm against vehicle state (HEARTBEAT
  base_mode armed flag / custom_mode) before reporting "accepted". For arm/disarm and DO_SET_MODE, always verify against the
  next HEARTBEAT.
- **Accept** `test_BUG002_disarmNotCompletedByEarlierArmAck` and `test_BUG002_secondModeChangeRetriedAfterFirstAck` pass;
  `probe_command_overwrite.sh` PASS; the 34 existing tests still pass.

### BUG-003: Non-finite or huge ATTITUDE/VFR_HUD values are stored unchecked and crash the HUD
- **Severity** High · **Category** crash · **Verdict** CONFIRMED (model + trap); HUD draw path CODE
- **Repro** `testing/scenarios/nan_values.sh`, `inf_values.sh`, `huge_values.sh`; trap: `probe_hud_label_nan.sh`,
  `probe_hud_label_huge.sh`.
- **Expected** Invalid values are ignored (keep the last good value, flag the field invalid); the app never crashes.
- **Actual** VehicleModel holds `roll=nan pitch=nan yaw=nan`, `roll=inf`, `gs=inf alt=nan climb=-inf`, roll 1.7e40°.
  `Int(roll)` in the HUD traps: `Fatal error: Double value cannot be converted to Int because it is either infinite or NaN`.
- **Cause** `App/Vehicle/VehicleModel.swift:270-281` (no `isFinite` checks; `wrap360` turns ±inf into NaN at `:272`);
  `App/UI/HUDView.swift:142` (`Int(roll)`, `Int(pitch)`, `Int(heading)` in `accessibilityLabel`, evaluated on every
  render). Also `App/Map/MapCanvas.swift:132` builds a `CGAffineTransform` from `v.yaw` (NaN transform: CALayer exception).
- **Fix** Sanitise in `VehicleModel.handle`: drop non-finite values and values outside physical ranges (|roll/pitch| ≤ π,
  speeds < 1000 m/s, altitudes within ±100 km); count rejects in Diagnostics. In views use a safe formatter
  (`v.isFinite ? Int(v.rounded()) : 0` or `String(format:)`), never a bare `Int(Double)`.
- **Accept** `nan_values.sh`, `inf_values.sh`, `huge_values.sh` PASS. A unit test feeding ATTITUDE NaN/Inf to `VehicleModel`
  keeps the previous finite values. In the simulator the HUD keeps rendering with the drone on `--fault nan_attitude`.

### BUG-004: Out-of-range GLOBAL_POSITION_INT is accepted and is expected to crash the map
- **Severity** High · **Category** crash · **Verdict** CONFIRMED (accepted into the model); crash CODE (needs the simulator)
- **Repro** `testing/scenarios/bad_latlon.sh` (lat 200°, lon 210°). Simulator: drone `--fault bad_latlon`, open Flight Data.
- **Expected** Positions outside ±90/±180 are rejected.
- **Actual** `lat=200.0 lon=210.0 trail=1`: stored as the vehicle position and added to the trail. `MapCanvas` then calls
  `MKMapView.setRegion` with that centre, which raises `NSInvalidArgumentException` ("Invalid Region") in UIKit.
- **Cause** `App/Vehicle/VehicleModel.swift:285-297` (only checks `lat != 0 || lon != 0`); `App/Map/MapCanvas.swift:136`
  (`setRegion`), `:138` (`setCenter`), plus the trail polyline.
- **Fix** In `VehicleModel`, accept only `CLLocationCoordinate2DIsValid`-equivalent ranges (|lat| ≤ 90, |lon| ≤ 180).
  In `MapCanvas`, guard every coordinate with `CLLocationCoordinate2DIsValid` before `setRegion`/`setCenter`/annotations.
- **Accept** `bad_latlon.sh` PASS. In the simulator with `--fault bad_latlon` the map stays up and shows no vehicle position.

### BUG-005: Setup › Flight modes crashes when FLTMODE_CH (or Rover MODE_CH) is 0 = "Disabled"
- **Severity** High · **Category** crash · **Verdict** CONFIRMED (trap on the exact expression)
- **Repro** `testing/scenarios/probe_fltmode_ch0.sh`; end to end `testing/scenarios/param_nan.sh` (the fake vehicle reports
  FLTMODE_CH = 0). Simulator: drone `--fault fltmode_ch0`, wait for params, open Setup › Flight modes.
- **Expected** The page shows "Mode switch disabled".
- **Actual** `Fatal error: Index out of range`. 0 is a valid documented value (`[0,"Disabled"]` in ArduCopter.json).
- **Cause** `App/UI/SetupView.swift:438`: `channel <= vehicle.rcChannels.count ? vehicle.rcChannels[channel - 1]` with
  channel 0 → index −1 (`activeSlot` at `:417` guards `channel >= 1`; this line doesn't). Related: `:449`
  `UInt32(p.value)` traps for a negative FLTMODEn (`probe_fltmode_picker_negative.sh`).
- **Fix** Use `vehicle.rcChannels[safe: channel - 1]` with `channel >= 1` and show "Disabled" for 0. In the Picker use
  `UInt32(exactly: p.value.rounded()) ?? 0`.
- **Accept** `probe_fltmode_ch0.sh` and `probe_fltmode_picker_negative.sh` PASS (after changing the probes to call the fixed
  helper), `param_nan.sh` check 2 PASS, and the page renders in the simulator with FLTMODE_CH = 0.

### BUG-006: A long takeoff-altitude entry crashes the Actions tab every time it opens (value persists); no bounds on takeoff/speed/altitude inputs
- **Severity** High · **Category** crash, safety · **Verdict** CONFIRMED (trap on the exact expression); UI CODE
- **Repro** `testing/scenarios/probe_takeoff_alt_huge.sh`. Simulator: Actions › Guided takeoff › type
  `100000000000000000000`, leave the field.
- **Expected** Input is clamped/rejected (e.g. 1–500 m) and can never crash.
- **Actual** `Fatal error: Double value cannot be converted to Int because the result would be greater than Int.max`. The
  value is stored in `@AppStorage("actions.takeoffAlt")`, so the Actions tab then crashes on every launch; recovery needs
  a reinstall or clearing app data. Takeoff, Change speed, Change altitude and Fly-here altitude have no upper bound, and
  Fly-here accepts negative or 0 m (descends into the ground).
- **Cause** `App/UI/ActionsView.swift:169` (alert title `Int(takeoffAlt)` is built on every body evaluation), `:20-22`
  (persisted, unvalidated), `:114`, `:172`; `App/UI/FlightMapView.swift:60-61,79` (fly-here altitude).
- **Fix** Validate on input: takeoff 1–500 m, speed 0.1–50 m/s, altitude 1–1000 m (relative), Fly-here ≥ 2 m; reject
  non-finite values. Format with `String(format: "%.0f")` instead of `Int()`. Sanitise the stored values on load.
- **Accept** `probe_takeoff_alt_huge.sh` PASS once it calls the shared formatter; a unit test of the validator rejects
  1e20, NaN, −5 and 0. In the simulator, typing a huge value shows an inline error and no crash after a relaunch.

### BUG-007: Out-of-range or NaN coordinates crash the app (corrupt `.waypoints` file, waypoint editor typo)
- **Severity** High · **Category** crash, data · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/probe_waypoint_file_nan.sh`, `probe_waypoint_file_huge_lat.sh`, `probe_mission_item_nan_coord.sh`,
  `probe_waypoint_editor_lat_300.sh`; unit test `test_BUG007_waypointFileRejectsOutOfRangeLatitude`.
  Simulator: Plan › File › Load a `.waypoints` file whose line 1 has `nan` as latitude; or tap a waypoint and type
  latitude `300`.
- **Expected** The file is rejected with "line N: invalid coordinate"; the editor refuses |lat| > 90, |lon| > 180.
- **Actual** `Fatal error: Double value cannot be converted to Int32 because it is either infinite or NaN` /
  `… greater than Int32.max`. Any latitude ≥ 214.75 traps; 90 < lat < 214 is silently accepted (BUG-007 unit test).
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:89-90` (init) and `:97`, `:102` (setters):
  `Int32((latitude * 1e7).rounded())`. `WaypointFile.parse` (`:363-374`) accepts any `Double`. `App/UI/PlanView.swift:345-346`
  binds free-text fields straight to the setters.
- **Fix** In MAVLinkKit, validate in `WaypointFile.parse` (`throw .badLine(n)` for non-finite, |lat| > 90, |lon| > 180; a
  frame-0/home line with 0,0 is fine) and make the setters non-trapping (`Int32(exactly:)`/clamp, or a failable API). In
  PlanView, validate before writing back and show an error.
- **Accept** All four probes PASS; `test_BUG007_*` passes; a new unit test `WaypointFile.parse("…nan…")` throws `badLine(2)`.

### BUG-008: Low battery and failsafes have no visual warning; with speech off there is no alert at all
- **Severity** High · **Category** safety, UX · **Verdict** CODE + CONFIRMED (values reach the model)
- **Repro** `testing/scenarios/battery_failsafe.sh` (battery 12 % / 13.9 V, then 3 % / 13.0 V; the app's state shows the values,
  but there is no warning state anywhere in the model or UI).
- **Expected** A prominent, hard-to-miss warning (HUD banner + red battery item) at the vehicle's BATT_LOW/CRT levels, for
  failsafe STATUSTEXT (severity ≤ WARNING, e.g. "Battery failsafe", "Radio failsafe", "EKF failsafe") and for
  GPS loss, independent of speech. Desktop MP shows these in the HUD.
- **Actual** Only `SpeechAlerts` reacts (≤ 20 % remaining, `App/Vehicle/SpeechAlerts.swift:45`). The top-bar Battery item
  has no colour (`App/UI/RootView.swift:122-124`), the HUD has no battery input, and STATUSTEXT warnings only appear in the
  Messages tab. With `BATT_MONITOR` = voltage only, `battery_remaining` is −1 and nothing ever fires.
- **Fix** Add `VehicleModel.warnings` (battery low/critical from SYS_STATUS remaining and from BATT_LOW_VOLT/BATT_CRT_VOLT
  params, failsafe STATUSTEXT ≤ WARNING held for 10 s, GPS fix < 3 while armed, EKF flags). Render it as a banner over the
  HUD (like NO HEARTBEAT) and colour the battery item orange/red. Speech stays as an extra.
- **Accept** A harness/unit test feeding SYS_STATUS 13.0 V with BATT_CRT_VOLT 13.2 sets a critical warning. In the
  simulator, `fault battery_critical on` shows a red banner within 2 s with speech disabled.

### BUG-009: A malformed ACCELCAL_VEHICLE_POS (COMMAND_LONG 42429) from the vehicle crashes the app
- **Severity** Medium · **Category** crash · **Verdict** CONFIRMED end to end
- **Repro** `testing/scenarios/accelcal_live_nan.sh` (fake vehicle sends 42429 with param1 = NaN); also
  `probe_accelcal_nan.sh`, `probe_accelcal_neg.sh`, `probe_accelcal_huge.sh`.
- **Expected** Unknown or invalid positions are ignored (ArduPilot sends 1–6, 16777215, 16777216).
- **Actual** `Fatal error: Float value cannot be converted to UInt32 because it is either infinite or NaN` one second after
  connecting, outside any calibration. Likelihood with ArduPilot is low, but any component on the vehicle's sysid can send it.
- **Cause** `App/Vehicle/CalibrationStore.swift:80` `UInt32(cmd.param1)`; `App/Link/LinkManager.swift:330` routes every
  COMMAND_LONG from the vehicle to it, even with no calibration running.
- **Fix** `guard let p = UInt32(exactly: cmd.param1) else { return }`, and handle it only while an accel calibration is
  in progress.
- **Accept** `accelcal_live_nan.sh` PASS (no CRASH) and the 3 probes PASS.

### BUG-010: Missions with more than 65,535 items crash (huge `.waypoints` file or large survey)
- **Severity** Medium · **Category** crash · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/probe_waypoint_file_huge.sh` (70,000 lines), `probe_survey_huge.sh` (22 km square, 0.6 m spacing).
- **Expected** "Mission too large (max N items)"; ArduPilot boards hold a few hundred to a few thousand items.
- **Actual** `Fatal error: Not enough bits to represent the passed value`.
- **Cause** `MissionProtocol.swift:372` `UInt16(out.count)`; `App/Vehicle/MissionStore.swift:196` `UInt16(i)`, `:228`
  `UInt16(mission.count)`; `SurveyGrid.generate` has no point cap.
- **Fix** Cap in `WaypointFile.parse` (throw), `MissionStore.setItems`/`add`, and `addSurvey` (return an error when > a sane
  limit such as 5000, or > MIS_TOTAL when known). Show the error in Plan.
- **Accept** Both probes PASS and report an error instead of crashing.

### BUG-011: Fly-here reports "Flying to…" even when the vehicle rejected it; altitude not validated
- **Severity** Medium · **Category** safety, UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/fly_here.sh` (first goto sent while in Stabilize; the vehicle answers MISSION_ACK error).
- **Expected** The banner shows the vehicle's answer (accepted, or "rejected: not in GUIDED").
- **Actual** `Flying to -35.362762, 149.165237 at 20 m` after a rejection. `FlightMapView.flyHere` asks for GUIDED and sends
  the target 0.8 s later regardless of whether the mode change succeeded.
- **Cause** `App/Vehicle/MissionStore.swift:129-135` (fire and forget; MISSION_ACK for `current = 2` is ignored because no
  session is busy); `App/UI/FlightMapView.swift:73-80`.
- **Fix** Track the guided item: wait for MISSION_ACK (type 0 = accepted), retry twice on timeout, and show the result.
  Send the target only after HEARTBEAT shows GUIDED (or after the DO_SET_MODE ACK), and abort with a message otherwise.
  Validate the altitude (see BUG-006).
- **Accept** `fly_here.sh` all checks PASS.

### BUG-012: After Disconnect (or starting a replay) the last ARMED state, mode, attitude and battery stay on screen with no stale marker
- **Severity** Medium · **Category** safety, UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/stale_after_disconnect.sh`.
- **Expected** After Disconnect, values are cleared or visibly greyed out ("—"), and no banner says the vehicle is OK.
- **Actual** `armed=true mode=Stabilize uiLinkAlive=true battery=16.396` after Disconnect: the top bar still shows ARMED in
  red, the HUD keeps the last attitude, and the NO HEARTBEAT banner is suppressed (see BUG-001 for the cause).
- **Cause** `App/Link/LinkManager.swift:174-198` doesn't reset `VehicleModel`; `VehicleModel.reset()` (`:157-175`) is only
  called on the next connect and doesn't clear `armed`, `customMode`, attitude, battery or GPS. `RootView.swift:49`.
- **Fix** On disconnect, call `vehicle.reset()` and extend it to clear all live fields (or add `isLive` and render "—").
- **Accept** `stale_after_disconnect.sh` PASS.

### BUG-013: No confirmation for Disconnect, Reconnect or "Replay a log" while the vehicle is armed
- **Severity** Medium · **Category** safety, UX · **Verdict** CODE
- **Repro** Simulator: connect to `fake_drone.py --tcp-server 5799`, arm in Actions, open the Connect sheet, tap a log under
  Replay: the live link closes immediately. Headless equivalent: `stale_after_disconnect.sh` (disconnect while armed is
  accepted silently).
- **Expected** "Vehicle is ARMED. Disconnect anyway?" confirmation.
- **Cause** `App/UI/ConnectView.swift:113` (Disconnect), `:117` (Reconnect), `:134` and `:149` (`link.startReplay`), and
  `LinkManager.startReplay` calls `disconnect()` first (`App/Link/LinkManager.swift:80`).
- **Fix** If `vehicle.armed && vehicle.heartbeatAlive`, show a destructive confirmation before these four actions.
- **Accept** XCUITest (once identifiers exist, see TEST-027): with an armed fake vehicle, tapping Disconnect shows an alert
  and Cancel keeps the link up.

### BUG-014: The Servo tab's "motor outputs are blocked" guard is fail-open until parameters have downloaded
- **Severity** Medium · **Category** safety · **Verdict** CONFIRMED (logic)
- **Repro** `testing/scenarios/servo_before_params.sh` (3000 params, slow stream: Out 1 = motor, but `SERVO1_FUNCTION`
  unknown → buttons enabled).
- **Expected** Overrides stay disabled until `SERVOn_FUNCTION` is known (ELRS downloads take ~1 min).
- **Actual** `isMotor` returns false when the function is unknown, so Low/Mid/High/Toggle are enabled for motor outputs.
  (ArduPilot itself refuses DO_SET_SERVO on motor functions, so this is defence in depth, but the UI promises a block.)
- **Cause** `App/UI/FlightDataTabs.swift:170-172`.
- **Fix** Treat unknown as blocked: `guard let f = … else { return true }`; show "waiting for parameters".
- **Accept** `servo_before_params.sh` PASS.

### BUG-015: On GPS loss the map keeps the last position as the current one, with no stale indication
- **Severity** Medium · **Category** UX, safety · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/gps_loss.sh`.
- **Expected** The vehicle marker is greyed/flagged "GPS lost" (and stays so until a valid fix).
- **Actual** `fix=No GPS` in the top bar, but `position` and the map marker stay at the last value indefinitely.
- **Cause** `App/Vehicle/VehicleModel.swift:285` ignores lat/lon = 0 and keeps the old value; nothing records its age.
- **Fix** Store `positionDate`; mark the position stale after 3 s without a valid GLOBAL_POSITION_INT, or when
  `gpsFixType < 2`. Render the stale marker grey with a "GPS lost" label.
- **Accept** `gps_loss.sh` PASS (with the check adapted to the new `positionStale` flag).

### BUG-016: The Link % in the top bar treats reordering and jitter as packet loss
- **Severity** Medium · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/reorder.sh` (0 % real loss → Link 55.6 %); `lossy_link.sh` (30 % loss + 80±60 ms jitter →
  `rx=579 lost=7640`, so Link shows about 7 % while about 70 % of packets were delivered).
- **Expected** About 100 % for a reordered-but-complete stream, about 70 % for 30 % loss.
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/MAVLinkFraming.swift:229-237`: after a late packet, `last` moves
  backwards, so the next in-order packet counts the gap again.
- **Fix** Ignore packets whose sequence is "behind" (gap ≥ 128 means late/duplicate: don't update `last`). Better, keep a
  256-bit window of seen sequence numbers per source and compute loss over a sliding window (as MAVProxy does).
- **Accept** `reorder.sh` PASS (≥ 90 %); a new parser unit test with a shuffled sequence 0…99 reports 0 lost.

### BUG-017: When the ACK is lost but the command worked, the banner reports a failure
- **Severity** Medium · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/no_ack.sh` (vehicle executes but never ACKs).
- **Expected** "Mode change: no ACK, but the vehicle is now in Loiter" (success), or similar.
- **Actual** `mode=Loiter banner=Mode change: no answer from vehicle` (orange).
- **Cause** `App/Vehicle/CommandCenter.swift:161-163` decides from ACKs only.
- **Fix** On timeout for DO_SET_MODE / ARM_DISARM, check HEARTBEAT `custom_mode` / armed flag before reporting failure.
  This shares the vehicle-state check with BUG-002.
- **Accept** `no_ack.sh` PASS.

### BUG-018: Battery voltage/current calibration accepts any value without bounds or confirmation
- **Severity** Medium · **Category** safety · **Verdict** CODE
- **Repro** Simulator: Setup › Battery monitor, with the fake drone at 16.4 V, type measured `1.64` (decimal-point typo) →
  Calibrate: BATT_VOLT_MULT becomes 1/10 of its value and the vehicle then reports 1.6 V (immediate battery failsafe in
  flight). The reverse (164) makes the battery never look low.
- **Cause** `App/UI/SetupView.swift:754-755` and `:761-762`.
- **Fix** Reject ratios outside 0.8–1.25 of the current reading (or ask "This changes the reading by N %. Apply?"); refuse
  while armed.
- **Accept** A unit test of the extracted calibration function rejects a 10× change; a simulator check shows the confirmation.

### BUG-019: DataFlash download keeps the whole log in RAM twice
- **Severity** Medium · **Category** performance · **Verdict** CODE (the download itself is CONFIRMED working: `log_download.sh`)
- **Repro** `testing/scenarios/log_download.sh` works for small logs. For the problem: a LOG_ENTRY with size 2 GB makes
  `LogDownloadSession` allocate 2 GB up front, plus a second copy at the end; on an iPad this is a jetsam kill.
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/LogProtocol.swift:122` (`[UInt8](repeating: 0, count: size)`), `:176`
  (`Data(buffer)` copy).
- **Fix** Stream chunks to a temporary file opened with `FileHandle` (write at offset). Keep only the `have` bitmap in RAM.
  Refuse or warn above a limit (e.g. 1 GB), and check free disk space.
- **Accept** A unit test with a simulated 200 MB entry keeps process memory growth under 20 MB (measure with
  `Probes.rssMB()`, as in the harness).

### BUG-020: `.param` files with `nan`/`inf` are accepted; a NaN parameter always shows as "different"
- **Severity** Medium · **Category** data · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/probe_param_file_nan.sh`, `testing/scenarios/param_nan.sh`; unit test
  `test_BUG020_paramFileRejectsNonFinite`.
- **Expected** Non-finite values are skipped with a warning; NaN equals NaN in the compare view.
- **Actual** `["FOO_A": nan, "FOO_B": inf, "FOO_C": inf]` are offered as writes (ArduPilot ignores them, so each one times
  out after retries). A vehicle NaN parameter appears in "differ" forever (`changes=["TEST_P001"]`).
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/ParameterProtocol.swift:304`; `ParameterStore.differences` (`App/Vehicle/
  ParameterStore.swift:183`) compares with `!=`.
- **Fix** `guard let v = Float(valueText), v.isFinite`; in `differences`, treat both-NaN as equal.
- **Accept** `test_BUG020_*` passes; both scenarios PASS.

### BUG-021: ExpressLRS backpack answers with port 0 or `enabled:false` are used as-is
- **Severity** Low · **Category** UX · **Verdict** CONFIRMED (decoder)
- **Repro** `testing/scenarios/probe_elrs_backpack_json.sh`.
- **Actual** `{"ports":{"listen":0,"send":0}}` → the app connects to 10.0.0.1:0 from iPad port 0. With `enabled:false` it
  connects anyway, and the warning is only in the Connect footer.
- **Cause** `App/Link/LinkManager.swift:122-123`; `App/Link/ELRSBackpack.swift`.
- **Fix** Ignore ports 0; if `enabled == false`, set state `.failed("MAVLink is disabled on the backpack: set Backpack
  Telemetry = WiFi")`.
- **Accept** The probe PASS.

### BUG-022: Out-of-range port text is silently replaced by the default port
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Repro** Simulator: Connect › TCP › port `70000` › Connect → connects to 5760 without a word.
- **Cause** `App/UI/ConnectView.swift:119-120` (`UInt16(portText) ?? kind.defaultPort`).
- **Fix** Validate (1–65535) and disable Connect with an inline error.
- **Accept** XCUITest: entering 70000 disables Connect.

### BUG-023: "Telemetry lost" is spoken on a deliberate Disconnect, and speech also runs during replay
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Cause** `App/Link/LinkManager.swift:197` (`vehicle.tick(now: .distantFuture)` flips `heartbeatAlive`) +
  `App/Vehicle/SpeechAlerts.swift:34`; `SpeechAlerts` doesn't know about `isReplaying`.
- **Fix** Suppress link alerts on user disconnect; mute (or prefix "Replay:") during replay.
- **Accept** Unit test with a stub synthesiser: disconnect produces no "Telemetry lost".

### BUG-024: A failed replay keeps the previous log's name, packet count and duration in the replay bar
- **Severity** Low · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/replay.sh`: after `garbage.tlog`, `state=Failed: No MAVLink packets … loaded=true
  packets=607 dur=6.04` (values from the previous file).
- **Cause** `App/Link/ReplayTransport.swift:75-83` fails without resetting `ReplayController`; `LinkManager.startReplay`
  keeps `isReplaying = true`.
- **Fix** Reset the controller at `open()`. On failure set `isReplaying = false` (hide the ReplayBar) and show the error.
- **Accept** `replay.sh` adds a check that `replay.loaded == false` after the garbage file (PASS).

### BUG-025: A pending-command banner ("Arming…") can stay forever after the sessions re-attach or detach
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Cause** `App/Vehicle/CommandCenter.swift:20-29`: `attach`/`detach` replace the session without resolving `lastResult`,
  so the timeout event never fires.
- **Fix** In `attach`/`detach`, set `lastResult = "…: link changed, not confirmed"` for pending commands.
- **Accept** Unit test: `arm()`, then `attach()` with a new compid, sets `lastResultOK == false` with a message.

### TEST-026: The app layer has no tests, CI runs only MAVLinkKit, and there are no UI tests
- **Severity** Medium · **Category** test gap
- **Details** `LinkManager`, `VehicleModel`, the stores and every view are untested. All bugs above except BUG-002/-007/-010/
  -016/-019/-020 live there. CI (`.github/workflows/build-sideloadly-ipa.yml`) runs `swift test` for MAVLinkKit only.
- **Fix** (1) Move `testing/unit/extra/BreakTestRegressionTests.swift` into `Packages/MAVLinkKit/Tests/MAVLinkKitTests/`.
  (2) Extract `VehicleModel`, the stores and `LinkManager` (no UIKit) into a second package or test target and port the
  harness scenarios to XCTest using the Python fake drone, or a Swift in-process fake transport implementing `MAVTransport`.
  (3) Add a CI job: `testing/harness/build_harness.sh && python3 testing/scenarios/run.py all` (needs no Xcode project).
  (4) Add an XCUITest target in `project.yml` covering connect, arm-confirm, mode buttons and the banners.
- **Accept** CI runs the harness scenarios and fails on any CRASH; the XCUITest target runs on `iPad Pro 13-inch (M4)`.

### TEST-027: The UI has no accessibility identifiers, so XCUITest can't drive it reliably
- **Severity** Low · **Category** testability (tiny change, listed instead of made, per the ground rules)
- **Fix** Add `.accessibilityIdentifier` to: Connect/Disconnect/Reconnect buttons and link-kind picker (`ConnectView`),
  Arm/Disarm/Force-disarm/mode buttons/Takeoff (`ActionsView`), HUD banners (`HUDView`: "banner.noHeartbeat",
  "banner.noAttitude"), top-bar items (`RootView.StatusBar`), Plan Read/Write/Clear (`PlanView`).
- **Accept** An XCUITest can tap `connect.button` and assert `banner.noHeartbeat` exists after the fake drone goes silent.

---

## 4. Improvement recommendations (not bugs)

- **One "telemetry validity" layer.** Most crashes come from trusting numbers. Put range/finite checks in one place
  (`VehicleModel.handle` and the file parsers) and ban bare `Int(Double)`/`UInt32(Float)`/`Int32(Double)` conversions in
  the app (use `Int(exactly:)`, a clamping helper, or formatters). A grep-based CI lint for `Int(` on floating values would
  have caught BUG-003/-005/-006/-007/-009.
- **Command result model.** Make the commands' "accepted" reflect vehicle state (heartbeat mode/armed), not only ACKs
  (BUG-002, BUG-017). Show a per-command result list, not a single `lastResult` string that later commands overwrite.
- **Stale-data model.** Give every telemetry group a timestamp and derive "stale" in one place. The UI then greys out
  stale values (HUD, map marker, battery). This fixes BUG-001/-012/-015 consistently.
- **Warnings.** A central warnings list (battery, failsafe, GPS, EKF, link, vibration) drawn as HUD banners, with speech as
  an extra (BUG-008).
- **Reconnect policy.** All transports should reconnect automatically until the user disconnects, with the backoff shown.
- **Input validation.** Shared numeric field components with min/max/unit, used by Actions, Plan editor, Survey, Fence and
  Battery pages.
- **Threading.** `LinkManager` publishes on main from `ioQueue` per batch. At 200 STATUSTEXT/s, `messages.insert(at: 0)`
  copies a 300-element array per message on the main thread. Use a ring buffer and coalesce UI publishes to ≤ 10 Hz.
- **Accessibility.** The HUD is a Canvas with one accessibility label. Expose mode, armed state, altitude, speed, battery
  and the banners as separate elements; add VoiceOver announcements for warnings.
- **Testability.** Inject the clock and `DocumentsStore` root (the harness had to use `CFFIXED_USER_HOME`). Make
  `SpeechAlerts` take a synthesiser protocol, so its triggers can be unit-tested silently.
- **CI.** Run the unit suite and the harness on every push; keep the IPA build. The harness needs only the Command Line
  Tools, so it also runs on cheap macOS runners.

---

## 5. Coverage matrix

Status: PASS, FAIL (→ action item), PARTIAL (logic tested, UI not), NOT TESTED, N/T = not testable here (reason).

| TESTING.md item | How covered | Status |
|---|---|---|
| A1 Install, landscape, Connect sheet | needs an iPad/Sideloadly; no simulator | N/T (no Xcode) |
| A2 Diagnostics version/build | UI; build stamp comes from CI | N/T (no Xcode) |
| A3 Documents folders | harness: `DocumentsStore` creates logs/params/missions/tiles | PASS |
| B1 Connect, firmware/mode/GPS shown | `connect`, `connect_udp_listen`, `connect_udp_connect` | PASS. ELRS kind N/T (Wi-Fi-only + real 10.0.0.1 backpack); backpack JSON → BUG-021 |
| B2 HUD moves, no NO ATTITUDE banner | `connect` (attitude flowing, not stale); HUD drawing N/T | PARTIAL; NaN/Inf → BUG-003 |
| B3 Values plausible | `connect` vs fake drone truth | PASS |
| B4 ESC telemetry | fake drone doesn't emit ESC_TELEMETRY | NOT TESTED |
| B5 Link drop banner + voice | `link_loss`, `link_loss_udp`, `blackout` PASS; `tcp_drop` FAIL; voice N/T | FAIL → BUG-001 |
| B6 Heartbeat sources, message counts | `connect` | PASS |
| C1 Download all params | `params` (400), `params_1500`, `lossy_link` (30 % loss: 9.5 s) | PASS |
| C2 Save .param | `param_file_roundtrip` | PASS |
| C3 Write + confirm + set back | `param_set` | PASS |
| C4 Options/bitmask metadata | `params` (metadata loaded); editor UI N/T | PARTIAL |
| C5 Load file → 0 differ | `param_file_roundtrip` PASS; NaN case FAIL | FAIL → BUG-020 |
| D1 Pre-arm checks | `reject_arm` (PreArm text reaches Messages); the "Run pre-arm checks" button N/T | PARTIAL |
| D2 Accelerometer calibration | crash path only (`accelcal_live_nan`); normal 6-position flow not simulated | FAIL → BUG-009 |
| D3 Compass calibration | fake drone has no MAG_CAL_PROGRESS | NOT TESTED |
| D4 Radio calibration | UI only | N/T (no Xcode) |
| D5 Flight modes page | `probe_fltmode_ch0`, `param_nan` | FAIL → BUG-005 |
| D6 Motor test | UI; code reviewed (props-off toggle, disabled when armed: OK) | N/T (no Xcode) |
| D7 Geofence altitude | code reviewed; not driven end to end | NOT TESTED |
| D8 Battery monitor calibration | code review | FAIL → BUG-018 |
| D9 DataFlash list/download | `log_download` | PASS (memory: BUG-019) |
| E1 Offline map download | MapKit/UIKit + internet tile servers | N/T |
| E2 Offline imagery | as E1 | N/T |
| E3 Plan editing | store logic via `fence_rally` add; editor UI N/T | PARTIAL; editor crash → BUG-007 |
| E4 Write/Clear/Read mission | `mission_roundtrip`, `large_mission` (700), `lossy_link` | PASS |
| E5 Save .waypoints | `mission_roundtrip` (save + parse); desktop MP check N/T | PASS; corrupt file → BUG-007, huge → BUG-010 |
| E6 Survey grid | existing unit tests + `probe_survey_*` | PARTIAL; huge → BUG-010 |
| E7 Fence + rally round trip | `fence_rally` | PASS |
| F1 Checklist | UI only | N/T (no Xcode) |
| F2 Quick mode + banner | `mode_change` PASS (incl. 3-tap spam); `no_ack` FAIL | FAIL → BUG-017 |
| F3 Arm/disarm + refusal | `arm_disarm`, `reject_arm` PASS; confirmation dialogs present (code) | PASS (lossy-link caveat: BUG-002) |
| F4 Servo override, motors greyed | `servo_before_params` | FAIL → BUG-014 |
| F5 Replay, play/pause, seek, speed | `replay` (+ garbage/empty files) | PASS (BUG-024) |
| G1 Manual flight, trail | simulated in `auto_mission` (trail drawn) | PARTIAL (no real flight) |
| G2 Auto mission, current WP | `auto_mission` (waypoints reached, RTL, land, disarm) | PASS (simulated) |
| G3 Fly here | `fly_here` (vehicle flies there; rejection mis-reported) | FAIL → BUG-011 |
| G4 Altitude fence breach | fake drone has no fence logic; SITL run pending | NOT TESTED |
| G5 Share report + log | tlog recorded (`connect`); share sheet N/T | PARTIAL |

| Extra area | Scenarios | Status |
|---|---|---|
| Link loss + reconnect | `link_loss`, `link_loss_udp`, `blackout`, `tcp_drop` | FAIL → BUG-001 |
| Packet loss / latency / jitter | `lossy_link`, `lossy_link_corrupt` | PASS (Link % → BUG-016) |
| Duplicates / reordering | `dup_reorder` PASS, `reorder` FAIL | FAIL → BUG-016 |
| Malformed / truncated / oversized frames | `malformed`, unit `test_cov_parserSurvivesOversizedLengthAndNoise` | PASS |
| NaN / Inf / out-of-range values | `nan_values`, `inf_values`, `huge_values`, `bad_latlon` | FAIL → BUG-003, BUG-004 |
| GPS loss | `gps_loss` | FAIL → BUG-015 |
| Low/critical battery, failsafe | `battery_failsafe`, `mode_change_mid_mission` | FAIL → BUG-008 |
| Rejected commands / timeouts | `reject_arm` PASS, `no_ack` FAIL, `probe_command_overwrite` FAIL | FAIL → BUG-002, BUG-017 |
| Mid-mission mode change | `mode_change_mid_mission` | PASS |
| Disconnect during arm/takeoff | `disconnect_on_arm` | PASS |
| Reboot | `reboot` | PASS |
| Multiple vehicles / other GCS / compid change | `second_vehicle`, `other_gcs`, `compid_switch` | PASS |
| Rapid repeated actions | `connect_spam`, `arm_disarm` (arm, arm, disarm), `mode_change` (spam) | PASS on a clean link |
| Disconnect mid-transfer | `disconnect_mid_transfer` | PASS |
| STATUSTEXT flood | `statustext_flood` (200/s: list capped at 300, +0.6 MB) | PASS |
| High telemetry rate | `high_rate` (50 Hz × 8: 7 % CPU, +0.4 MB) | PASS (headless; UI cost N/T) |
| Long session | `long_session` (5 min at default rates: RSS 32.2 → 32.5 MB; tlog 390 KB ≈ 4.7 MB/h) | PASS |
| Large mission | `large_mission` (700 items, 0.1 s each way) | PASS |
| Input validation (files, fields) | `probe_*` | FAIL → BUG-006, -007, -010, -020 |
| Backgrounding, rotation, memory warning | iOS lifecycle | N/T (no Xcode) |
| Existing tests | `testing/unit/run_unit_tests.sh` | PASS 34/34 |

---

## 6. Not tested and why

- **Everything that needs the iPad Simulator / XCUITest** (A1, A2, D4, D6, E1, E2, F1, view layout, rotation,
  backgrounding, memory warnings, gestures, on-screen banners, screenshots): the test Mac has no Xcode, only the Command
  Line Tools. `testing/sim/sim.sh` is written but has **not** been run. No screenshots or videos exist in
  `testing/artifacts/` for the same reason. To finish: install Xcode + an iOS runtime, `brew install xcodegen`, then run
  the simulator repro lines in BUG-001, -003, -004, -005, -006, -007, -012, -013, -018, -022.
- **ArduCopter SITL**: `testing/sitl/build_sitl.sh` (Copter-4.7.3) and the `sitl_smoke`, `sitl_params`, `sitl_arm` scenarios
  are ready. The shallow clone with submodules was still downloading when the session ended (the network was shared with a
  large download), so no SITL results are reported; the partial download was deleted to free disk space. Once built, run `python3 testing/scenarios/run.py sitl`. `sitl_arm` also
  checks the in-flight disarm refusal and DO_SET_SERVO on a motor output against real ArduPilot.
- **ExpressLRS link type**: it is Wi-Fi-only (`requiredInterfaceType = .wifi`), so it can't run over loopback, and the
  ground rules forbid binding a fake backpack to a LAN interface. The backpack JSON handling was probed offline (BUG-021).
- **BLE transport, Local Network permission, speech output, Files app, share sheets**: platform/hardware features with no
  simulator-free equivalent. Speech *triggers* were code-reviewed (BUG-008, BUG-023).
- **ESC telemetry (B4), compass calibration (D3), accel calibration happy path (D2), geofence breach (G4)**: the fake drone
  doesn't model them. SITL covers D3/G4. These are the next additions for `fake_drone.py`.
- **Real flight (G1–G5)**: out of scope; G1–G3 were simulated with the fake drone's kinematics.

---

## 7. Run log (in order)

- Recon. No Xcode on the Mac → XCTest stand-in + headless harness chosen. MAVLinkKit suite: 34/34 PASS.
- Crash probes: traps confirmed for ACCELCAL param1 NaN/-1/1e10, `.waypoints` lat nan/1e10, HUD label NaN/huge,
  FLTMODE_CH = 0, takeoff 1e20, FLTMODEn = -1. ParamFile accepts nan/inf; CommandSession completes Disarm with the Arm ACK.
- Batch, first half: the functional scenarios PASS; tcp_drop, stale_after_disconnect, nan/inf/huge, bad_latlon,
  fly_here, no_ack, param_nan FAIL.
- Batch, second half: performance/transfer scenarios PASS; `accelcal_live_nan` CRASH end to end; gps_loss, reorder FAIL.
- Re-runs after fixing two test-kit bugs (flood fault never fired; `link_loss_proxy` missing): statustext_flood PASS,
  blackout PASS; new: servo_before_params FAIL, waypoint_editor_lat_300 CRASH, elrs_backpack_json FAIL.
- long_session (300 s) PASS: RSS 32.2 → 32.5 MB, no growth trend.
