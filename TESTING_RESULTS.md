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

**Environment.** macOS 26.7.3 (Apple silicon), Command Line Tools with Swift 6.4, later Xcode 27.2. **No iPad Simulator**
(model: none): Xcode arrived late in the session without an iOS simulator runtime, and that ~8 GB download was declined.
Instead the **real, unmodified app UI ran natively on the Mac as a Mac Catalyst build** (`testing/sim/catalyst.sh`) and was
driven by XCUITest against the fake drone. iPad layout, touch, rotation and backgrounding are therefore not covered. Python 3.9.6 (stdlib only). Vehicles: scripted fake ArduCopter + fault proxy, and **ArduCopter 4.7.3 SITL**
(tag Copter-4.7.3, d9c5097c, the user's firmware; native macOS build, quad model, CMAC home) for 17 runs.

**What was tested.** 101 scenario/probe runs in the final parallel run (84 fake drone + 17 SITL; plus the 5-minute session run separately; + 8 re-runs under Thread Sanitizer, 7 under AddressSanitizer) through the real app link/vehicle/store code, plus the unit suite.

| Suite | Result |
|---|---|
| Existing MAVLinkKit unit tests (34) | **34 pass, 0 fail** |
| New unit tests (`testing/unit/extra`, 8) | 4 coverage tests pass; 4 regression tests **fail as intended** (BUG-002, -007, -020) |
| Scenarios + probes, final run `-j 4 everything` (101) | **61 PASS, 24 FAIL, 16 CRASH** (a crash = the app process would die) |
| UI tests on Mac Catalyst (9) | **2 PASS, 7 FAIL**: 4 real app crashes (BUG-003, -004, -005, -006), plus BUG-001, -008, -013 |

Full verdict list: `testing/logs/summary.txt` after a run; the table in section 5 maps every TESTING.md item.

**What works well:** connecting over TCP / UDP listen / UDP connect; heartbeat lock (ignores other GCS and a second
vehicle); parameter download (400 and 1500 params; 400 params at 30 % loss + 80±60 ms jitter in 9.5 s); write with
confirm; `.param` round trip; arm/disarm/refusals; modes; guided takeoff/land; mission/fence/rally round trip; AUTO mission
to RTL and auto-disarm (also on real ArduCopter SITL, which also refuses an in-flight disarm and motor-output
DO_SET_SERVO, with the reason shown); reboot with parameter re-download; 1370-parameter download from SITL in < 1 s
(20 s at 30 % loss); 3 MB DataFlash download from SITL at ~100 kB/s; link-loss detection (~5 s) and recovery; parser resync under
noise/bad CRC/truncated/oversized frames; 50 Hz × 8 message streams at ~7 % CPU with flat memory; a 5-minute session grows only 0.5 MB; 700-item missions;
DataFlash list/download; tlog replay including garbage/empty files; rapid connect/disconnect.

**Top risks**
1. **BUG-001**: when the transport fails (TCP reset/close) the red NO HEARTBEAT banner is *hidden*, the frozen HUD looks
   live, and TCP never reconnects.
2. **BUG-002**: a command can be "confirmed" by the ACK of an earlier command with the same id (Disarm by the Arm ACK,
   RTL by the Loiter ACK) and is then never retried.
3. **BUG-003/-004/-009**: single telemetry packets crash the GCS (NaN/Inf/huge ATTITUDE in the HUD, out-of-range position
   in the map, malformed ACCELCAL COMMAND_LONG); the HUD and map crashes were reproduced in the real app UI. A crash in flight
   leaves the pilot without a GCS.
4. **BUG-008**: low battery and failsafes have no visual warning; without speech the pilot gets no alert at all.
5. **BUG-033**: on a lossy link (15–30 %), every mission upload to **real ArduPilot 4.7.3** failed or was misreported
   (INVALID_SEQUENCE treated as fatal; a lost final ACK reported as failure). This is the user's main ExpressLRS use case.
6. **BUG-005/-006/-007/-010**: configuration and user input crash the app (FLTMODE_CH = 0, a long takeoff-altitude entry
   that persists and crash-loops the Actions tab, latitude typo, corrupt or huge `.waypoints`, big survey).

---

## 2. How to reproduce the test setup

From a clean checkout on macOS with Command Line Tools (Swift ≥ 5.9) and python3:

```bash
testing/unit/run_unit_tests.sh                 # MAVLinkKit suite + testing/unit/extra (exit 1 while BUG tests fail)
testing/harness/build_harness.sh               # builds the headless app (prints the binary path)
python3 testing/scenarios/run.py --list        # all scenario names
python3 testing/scenarios/run.py all           # everything except long/SITL runs (~10 min)
python3 testing/scenarios/run.py -j 4 everything   # all incl. SITL, 4 at a time (per-worker ports/SITL instance)
python3 testing/scenarios/run.py probes        # crash probes only (~10 s)
testing/scenarios/tcp_drop.sh                  # one scenario (one wrapper per scenario)
python3 testing/scenarios/run.py long_session  # 5 min memory run
testing/sitl/build_sitl.sh && python3 testing/scenarios/run.py sitl   # real ArduCopter 4.7.3 SITL (~1.5 GB; patches a
                                                                      # macOS linker issue in AP_FWVersion.h)
python3 testing/tools/tlog_trace.py <file.tlog> --grep MISSION            # message trace of a recorded run
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
testing/sim/catalyst.sh build              # app as a Mac Catalyst app (needs Xcode + xcodegen, no iOS runtime)
testing/sim/catalyst.sh uitest             # 9 UI tests vs a self-restarting fake drone; screenshots -> testing/artifacts/catalyst/
testing/sim/sim.sh uitest            # XCUITest repros (testing/sim/UITests) with a self-restarting fake drone
```

SITL runs with `--serial0 udpclient:127.0.0.1:14550` (the app's UDP listen port) and serial1/2 pointed at unused localhost
ports, so no SITL TCP listener is opened. If Xcode is installed but its license is not accepted, prefix commands with
`DEVELOPER_DIR=/Library/Developer/CommandLineTools`.

The harness writes app files to `testing/.build/home/Documents` (via `CFFIXED_USER_HOME`) and passes
`-speech.enabled <false/>` so nothing is spoken and nothing lands in `~/Documents`.

---

## 3. Action items (sorted by severity)

Legend: **Verdict** CONFIRMED = reproduced by running the app's code; CODE = confirmed by reading the code, needs the
simulator for the UI part.

### BUG-001: A failed link hides the NO HEARTBEAT banner, keeps a frozen HUD on screen, and TCP never reconnects
- **Severity** High · **Category** safety · **Verdict** CONFIRMED headless and **in the real UI** (Mac Catalyst)
- **Repro** `testing/scenarios/tcp_drop.sh`; UI: `testing/sim/catalyst.sh uitest test_BUG001_tcpDropHidesBanner` (connect over TCP, the fake drone process exits, then restarts 3 s later).
- **Expected** NO HEARTBEAT banner shown; telemetry marked stale; the app reconnects when the vehicle comes back.
- **Actual** `state=Failed: … Connection reset by peer hbAlive=false uiLinkAlive=true`: the banner is suppressed. Mode
  "Stabilize", attitude, ARMED/Disarmed and battery stay on screen as if live. No reconnect after the remote comes back
  (`TCP auto-reconnect after remote restart` FAIL). Only the small top-bar caption says "Failed: …".
- **Evidence** `testing/logs/tcp_drop.harness.log`; screenshot `testing/evidence/catalyst-BUG001-after-tcp-drop-expect-banner.jpg`:
  no banner; HUD, "Stabilize", "Disarmed", "3D Fix · 12", "16.4V 88%" and "Link 100%" all look live; only a truncated
  "Failed: The operation couldn't be c…" caption. Compare `catalyst-B5-silent-expect-red-NO-HEARTBEAT.jpg` (UDP silence:
  banner shown).
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
- **Severity** High · **Category** crash · **Verdict** CONFIRMED: **the real app crashes** (Mac Catalyst UI test
  `test_Z1_BUG003_nanAttitudeDoesNotCrash`; crash report: EXC_BREAKPOINT in `HUDView.body.getter (HUDView.swift:142)`,
  `testing/evidence/catalyst-crash-frames.txt`)
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

### BUG-004: Out-of-range GLOBAL_POSITION_INT is accepted and crashes the map
- **Severity** High · **Category** crash · **Verdict** CONFIRMED: **the real app crashes** (UI test
  `test_Z2_BUG004_badLatLonDoesNotCrash`; uncaught NSException from `-[MKMapView setCenterCoordinate:animated:]` called at
  `MapCanvas.swift:139`, `testing/evidence/catalyst-crash-frames.txt`)
- **Repro** `testing/scenarios/bad_latlon.sh` (lat 200°, lon 210°). Simulator: drone `--fault bad_latlon`, open Flight Data.
- **Expected** Positions outside ±90/±180 are rejected.
- **Actual** `lat=200.0 lon=210.0 trail=1`: stored as the vehicle position and added to the trail. The map then passes
  that centre to `MKMapView`, which throws an uncaught exception (SIGABRT): the app dies about a second after connecting.
- **Cause** `App/Vehicle/VehicleModel.swift:285-297` (only checks `lat != 0 || lon != 0`); `App/Map/MapCanvas.swift:136`
  (`setRegion`), `:138` (`setCenter`), plus the trail polyline.
- **Fix** In `VehicleModel`, accept only `CLLocationCoordinate2DIsValid`-equivalent ranges (|lat| ≤ 90, |lon| ≤ 180).
  In `MapCanvas`, guard every coordinate with `CLLocationCoordinate2DIsValid` before `setRegion`/`setCenter`/annotations.
- **Accept** `bad_latlon.sh` PASS. `test_Z2_BUG004_badLatLonDoesNotCrash` passes (the map stays up and shows no vehicle position.

### BUG-005: Setup › Flight modes crashes when FLTMODE_CH (or Rover MODE_CH) is 0 = "Disabled"
- **Severity** High · **Category** crash · **Verdict** CONFIRMED: **the real app crashes** (UI test
  `test_Z3_BUG005_flightModesWithChannelDisabled`; EXC_BREAKPOINT in `FlightModesPage.body.getter (SetupView.swift:438)`)
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
- **Severity** High · **Category** crash, safety · **Verdict** CONFIRMED: **the real app crashes** when the stored value is 1e20 (UI test
  `test_Z4_BUG006_persistedHugeTakeoffAltitude`, launched with `-actions.takeoffAlt 1e20`; EXC_BREAKPOINT in
  `ActionsView.body.getter (ActionsView.swift:169)`)
- **Also (UI)** Fly-here accepts a negative altitude: `BreakTestUITests2/test_G3_flyHereClickHold` typed −5 m and the app
  sent the target ("Flying to … at -5 m").
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
- **Severity** High · **Category** crash, data · **Verdict** CONFIRMED; the editor case **crashes the real UI**
  (`BreakTestUITests2/test_Z5_BUG007_editorLatitude300`)
- **Repro** `testing/scenarios/probe_waypoint_file_nan.sh`, `probe_waypoint_file_huge_lat.sh`, `probe_mission_item_nan_coord.sh`,
  `probe_waypoint_editor_lat_300.sh`; unit test `test_BUG007_waypointFileRejectsOutOfRangeLatitude`.
  Simulator: Plan › File › Load a `.waypoints` file whose line 1 has `nan` as latitude; or tap a waypoint and type
  latitude `300`.
- **Expected** The file is rejected with "line N: invalid coordinate"; the editor refuses |lat| > 90, |lon| > 180.
- **Actual** `Fatal error: Double value cannot be converted to Int32 because it is either infinite or NaN` /
  `… greater than Int32.max`. Any latitude ≥ 214.75 traps; 90 < lat < 214 is silently accepted (BUG-007 unit test).
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:89-90` (init) and `:97`, `:102` (setters):
  `Int32((latitude * 1e7).rounded())`. `WaypointFile.parse` (`:363-374`) accepts any `Double`. `App/UI/PlanView.swift:345-346`
  binds free-text fields straight to the setters. Also `MissionProtocol.swift:117` `MissionItem(_ m: MAV.MissionItem)`: a
  vehicle answering with a legacy MISSION_ITEM whose x/y are NaN or ≥ 214.75 traps (found by `probe_fuzz_pipeline.sh`).
  Its x/y for non-location commands are param5/param6, so scaling them by 1e7 also corrupts those values.
- **Fix** In MAVLinkKit, validate in `WaypointFile.parse` (`throw .badLine(n)` for non-finite, |lat| > 90, |lon| > 180; a
  frame-0/home line with 0,0 is fine) and make the setters non-trapping (`Int32(exactly:)`/clamp, or a failable API). In
  PlanView, validate before writing back and show an error.
- **Accept** All four probes and `probe_fuzz_pipeline.sh` PASS; `test_BUG007_*` passes; a new unit test `WaypointFile.parse("…nan…")` throws `badLine(2)`.

### BUG-008: Low battery and failsafes have no visual warning; with speech off there is no alert at all
- **Severity** High · **Category** safety, UX · **Verdict** CODE + CONFIRMED (values reach the model)
- **Repro** `testing/scenarios/battery_failsafe.sh` (battery 12 % / 13.9 V, then 3 % / 13.0 V; the app's state shows the values,
  but there is no warning state anywhere in the model or UI).
- **Expected** A prominent, hard-to-miss warning (HUD banner + red battery item) at the vehicle's BATT_LOW/CRT levels, for
  failsafe STATUSTEXT (severity ≤ WARNING, e.g. "Battery failsafe", "Radio failsafe", "EKF failsafe") and for
  GPS loss, independent of speech. Desktop MP shows these in the HUD.
- **Actual** `SpeechAlerts` reacts (≤ 20 % remaining, `App/Vehicle/SpeechAlerts.swift:45`), and **the Quick tab's
  Battery tile turns red below 20 %** (`App/UI/TelemetryViews.swift:33-34`; screenshot
  `testing/evidence/catalyst-BUG008-critical-battery.jpg`). That's all: the tile is hidden whenever another tab is open, the
  top-bar Battery item has no colour (`App/UI/RootView.swift:122-124`), the HUD has no battery input, and STATUSTEXT warnings only appear in the
  Messages tab. With `BATT_MONITOR` = voltage only, `battery_remaining` is −1 and nothing ever fires.
- **Fix** Add `VehicleModel.warnings` (battery low/critical from SYS_STATUS remaining and from BATT_LOW_VOLT/BATT_CRT_VOLT
  params, failsafe STATUSTEXT ≤ WARNING held for 10 s, GPS fix < 3 while armed, EKF flags). Render it as a banner over the
  HUD (like NO HEARTBEAT) and colour the battery item orange/red. Speech stays as an extra.
- **Accept** A harness/unit test feeding SYS_STATUS 13.0 V with BATT_CRT_VOLT 13.2 sets a critical warning. In the
  simulator, `fault battery_critical on` shows a red banner within 2 s with speech disabled.

### BUG-033: Mission upload to real ArduPilot fails or is misreported on a lossy link
- **Severity** High · **Category** data, safety (ELRS) · **Verdict** CONFIRMED on ArduCopter 4.7.3 SITL (4/4 lossy runs)
- **Repro** `testing/scenarios/sitl_lossy.sh` (30 % loss, 80±60 ms), `sitl_lossy_b.sh` (30 %, other seed), `sitl_lossy_c.sh`
  (15 % loss, 40±20 ms). Trace the run's tlog: `python3 testing/tools/tlog_trace.py "testing/.build/home/Documents/logs/<newest>.tlog"`.
- **Expected** The 13-item mission is stored and the banner says so (desktop MP and MAVProxy complete these uploads).
- **Actual** `Mission transfer failed: Invalid sequence` / `…: Error` / `…: No answer from vehicle`. Traces:
  - `>> ITEM 0` · (request for 1 lost) · `>> ITEM 0` (timeout resend) · `<< MISSION_ACK 13 (INVALID_SEQUENCE)` → app aborts.
    ArduPilot sends this ACK for a duplicate and **keeps the upload open**.
  - `<< REQUEST 12` · `>> ITEM 12` · (final ACK 0 lost) · `>> ITEM 12` ×2 · `<< MISSION_ACK 1 (ERROR)` → app reports failure,
    but the vehicle had already stored all items. ArduPilot does **not** re-ACK a duplicate final item.
  The same upload through the fake drone at 30 % loss passed, because the fake (like `SimulatedMissionVehicle` in
  `MissionTests.swift`) re-ACKs duplicates. CLAUDE.md's note "the simulated vehicle re-ACKs a duplicate final item, as
  ArduPilot does" is wrong for 4.7.3.
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:288-291` (any MISSION_ACK ≠ 0 ends the upload) and
  `:313-317` (timeout resends the last requested item, which provokes INVALID_SEQUENCE).
- **Fix** During upload, ignore MISSION_ACK 13 (INVALID_SEQUENCE) and keep waiting for the next request. After the last item
  was sent, treat a timeout or MISSION_ACK 1 (ERROR) as "unknown": verify with MISSION_REQUEST_LIST, and if MISSION_COUNT
  equals the uploaded count, report success ("verified by read-back"). Optionally download and compare the items. Change
  `SimulatedMissionVehicle` to behave like ArduPilot (INVALID_SEQUENCE on duplicates, no re-ACK) so unit tests cover this.
- **Accept** `sitl_lossy.sh`, `sitl_lossy_b.sh`, `sitl_lossy_c.sh` PASS. A MissionTests case with the ArduPilot-like simulated
  vehicle at 30 % loss completes 200/200 uploads.

### BUG-034: Bundled parameter metadata is out of date for ArduCopter 4.7 (42 % of parameters have no description, range or options)
- **Severity** Medium · **Category** data, UX · **Verdict** CONFIRMED on SITL 4.7.3
- **Repro** `testing/scenarios/sitl_param_file_roundtrip.sh`, then `python3 testing/tools/param_meta_coverage.py`.
- **Actual** 577 of 1370 parameters are missing from the metadata (e.g. `ACRO_RP_RATE_TC`, `AHRS_OPTIONS`, `ARMING_NEED_LOC`, and all
  `MAVn_*` stream rates). For those the editor shows no description, units, range warning, value list or bitmask, and no
  reboot-required flag. 4.7 renamed `SRn_*` to `MAVn_*`: the metadata has 70 `SRn_` entries and no `MAVn_` ones.
  **TESTING.md C3 and README.md step 4 tell testers to search `SR6_`, which doesn't exist on 4.7.3** (use `MAV6_`).
  CLAUDE.md's bench notes say `SR6_*` were set on the user's 4.7.3 board; re-check on the hardware which names it really has.
- **Cause** `App/Resources/ParamMeta/*.json` generated by `tools/gen_param_meta.py` from an older `ParameterMetaDataBackup.xml`.
- **Fix** Regenerate the metadata from ArduPilot's 4.7 `apm.pdef.xml` (`Tools/autotest/param_metadata/param_parse.py`), or
  load it per firmware version. Update TESTING.md C3 and README to `MAV6_`. Add a CI check that the metadata covers ≥ 95 % of a
  SITL parameter dump.
- **Accept** `param_meta_coverage.py` reports ≥ 95 % for a 4.7.3 SITL dump; TESTING.md and README mention `MAV6_`.

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
- **Severity** Medium · **Category** safety, UX · **Verdict** CONFIRMED headless and in the real UI
- **Repro** `testing/scenarios/stale_after_disconnect.sh`; screenshot `testing/evidence/catalyst-BUG013-disconnect-armed.jpg`
  ("Disconnected", yet the top bar shows **ARMED**, 3D Fix, 16.4 V, Link 100 %, and the HUD shows ARMED).
- **Expected** After Disconnect, values are cleared or visibly greyed out ("—"), and no banner says the vehicle is OK.
- **Actual** `armed=true mode=Stabilize uiLinkAlive=true battery=16.396` after Disconnect: the top bar still shows ARMED in
  red, the HUD keeps the last attitude, and the NO HEARTBEAT banner is suppressed (see BUG-001 for the cause).
- **Cause** `App/Link/LinkManager.swift:174-198` doesn't reset `VehicleModel`; `VehicleModel.reset()` (`:157-175`) is only
  called on the next connect and doesn't clear `armed`, `customMode`, attitude, battery or GPS. `RootView.swift:49`.
- **Fix** On disconnect, call `vehicle.reset()` and extend it to clear all live fields (or add `isLive` and render "—").
- **Accept** `stale_after_disconnect.sh` PASS.

### BUG-013: No confirmation for Disconnect, Reconnect or "Replay a log" while the vehicle is armed
- **Severity** Medium · **Category** safety, UX · **Verdict** CONFIRMED in the real UI (Disconnect); Reconnect/Replay by code
- **Repro** `testing/sim/catalyst.sh uitest test_BUG013_disconnectWhileArmedAsksFirst` (arms, opens Link, taps Disconnect:
  the link drops at once; screenshot `testing/evidence/catalyst-BUG013-disconnect-armed.jpg`). Headless equivalent: `stale_after_disconnect.sh` (disconnect while armed is
  accepted silently).
- **Expected** "Vehicle is ARMED. Disconnect anyway?" confirmation.
- **Cause** `App/UI/ConnectView.swift:113` (Disconnect), `:117` (Reconnect), `:134` and `:149` (`link.startReplay`), and
  `LinkManager.startReplay` calls `disconnect()` first (`App/Link/LinkManager.swift:80`).
- **Fix** If `vehicle.armed && vehicle.heartbeatAlive`, show a destructive confirmation before these four actions.
- **Accept** `test_BUG013_disconnectWhileArmedAsksFirst` passes (a confirmation appears, so "Disconnected" is not shown).

### BUG-014: The Servo tab's "motor outputs are blocked" guard is fail-open until parameters have downloaded
- **Severity** Medium · **Category** safety · **Verdict** CONFIRMED (logic)
- **Repro** `testing/scenarios/servo_before_params.sh` (3000 params, slow stream: Out 1 = motor, but `SERVO1_FUNCTION`
  unknown → buttons enabled).
- **Expected** Overrides stay disabled until `SERVOn_FUNCTION` is known (ELRS downloads take ~1 min).
- **Actual** `isMotor` returns false when the function is unknown, so Low/Mid/High/Toggle are enabled for motor outputs.
  (Confirmed on SITL 4.7.3: ArduPilot refuses DO_SET_SERVO on a motor output with "ServoRelayEvent: Channel 1 is already in
  use", and the app shows "Failed. Check Messages". So this is defence in depth, but the UI promises a block.)
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

### BUG-016: The Link % in the top bar is wrong: reordering counts as loss, and a dead link still shows 100 %
- **Severity** Medium · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/reorder.sh` (0 % real loss → Link 55.6 %); `lossy_link.sh` (30 % loss + 80±60 ms jitter →
  `rx=579 lost=7640`, so Link shows about 7 % while about 70 % of packets were delivered).
- **Also (UI)** During a total outage the top bar keeps showing **Link 100 %** (`testing/evidence/catalyst-B5-silent-expect-red-NO-HEARTBEAT.jpg`):
  the figure is cumulative since connect (`App/UI/RootView.swift` `linkQuality`), so it never drops when nothing arrives.
- **Expected** About 100 % for a reordered-but-complete stream, about 70 % for 30 % loss, and "—"/0 % while no packets arrive.
- **Cause** `Packages/MAVLinkKit/Sources/MAVLinkKit/MAVLinkFraming.swift:229-237`: after a late packet, `last` moves
  backwards, so the next in-order packet counts the gap again.
- **Fix** Compute Link % over a sliding window (e.g. last 5 s) and show "—" when nothing arrived in it. Ignore packets whose sequence is "behind" (gap ≥ 128 means late/duplicate: don't update `last`). Better, keep a
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
- **Severity** Medium · **Category** safety · **Verdict** CONFIRMED in the real UI (`BreakTestUITests2/test_Z6_BUG018_batteryCalibrationNoConfirm`:
  measured 1.64 V → Calibrate voltage → applied with no prompt)
- **Repro** Setup › Battery monitor, with the fake drone at 16.4 V, type measured `1.64` (decimal-point typo) →
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
- **Also** `ParameterStore.set` sends NaN to the vehicle. SITL 4.7.3 ignores it, so the write sits pending and then times
  out (`sitl_param_set.sh`: `pending=["MAV1_EXTRA1"]`).
- **Fix** `guard let v = Float(valueText), v.isFinite`; refuse non-finite values in `ParameterStore.set`/`setMany`; in
  `differences`, treat both-NaN as equal.
- **Accept** `test_BUG020_*` passes; both scenarios and `sitl_param_set.sh` PASS.

### BUG-021: Accelerometer calibration stalls on a lossy link (single unrepeated confirm/result, no timeout, no feedback)
- **Severity** Medium · **Category** UX (ELRS) · **Verdict** CONFIRMED against the fake vehicle; SITL 4.7.3 (`sitl_accel_probe.sh`)
  confirms that ArduPilot re-requests the position every second (10 requests in 10 s), so only the lost confirm and the lost
  final result remain
- **Repro** `testing/scenarios/accel_cal_lossy.sh` (25 % loss; user taps once per position) and `accel_cal_lossy_retap.sh`
  (user taps again every 6 s). The fake vehicle re-requests the position every second, as ArduPilot does.
- **Expected** The calibration finishes on a 25 % lossy link, or tells the user to tap again / retry.
- **Actual** Clean link: PASS in 7 s (`accel_cal.sh`). Lossy, one tap per position: stuck on "Level" for 60 s. A lost
  confirm is never resent, and the banner shows "Level done…" as if it had worked. Lossy with retaps: reaches position 6,
  then stays there forever because the single success COMMAND_LONG (16777215) was lost, and later taps are ignored.
- **Cause** `App/Vehicle/CalibrationStore.swift:66-69` (`sendOnce`, deliberately not retried, so nothing checks for progress);
  `:77-85` (`.success`/`.failed` only from COMMAND_LONG 42429); `.starting` has no timeout (`App/UI/SetupView.swift:231-233`).
- **Fix** After a confirm, if the vehicle still requests the *same* position after 2 s, resend the confirm (this is safe:
  ArduPilot ignores a confirm for a position it isn't waiting for). Also treat the STATUSTEXT "Calibration successful" /
  "Calibration FAILED" as the result (Mission Planner does this). Add a 30 s timeout in `.starting`/`.place` with
  "No answer: tap to retry".
- **Accept** `accel_cal_lossy.sh` and `accel_cal_lossy_retap.sh` PASS (calibration ends successful within 60 s).

### BUG-022: The geofence page applies an altitude limit below the current altitude while flying, with no warning
- **Severity** Medium · **Category** safety · **Verdict** CONFIRMED on the fake drone and on SITL 4.7.3 (`sitl_fence.sh`: a 15 m limit
  applied at 25.8 m → "Max Alt fence breached" → RTL at once)
- **Repro** `testing/scenarios/fence_breach.sh` (take off to 40 m, apply 20 m with the page's writes).
- **Expected** While armed, refuse a limit below the current altitude (or confirm: "Vehicle is at 26 m; a 20 m fence breaches
  immediately and triggers RTL/Land"). Also show the breach prominently (see BUG-008).
- **Actual** FENCE_ALT_MAX = 20, FENCE_ENABLE = 1 are written at 26 m with no prompt, and the vehicle breaches at once
  (mode → RTL/Land, "Fence Breach" only in Messages). D7 on the bench and the G4 action itself work (`geofence_apply.sh` PASS).
- **Cause** `App/UI/SetupView.swift:590-596` (`limitAltitude`, no armed/altitude check); the button is only disabled outside
  10–1000 m (`:565`).
- **Fix** If `vehicle.armed`, require `quickAlt > vehicle.relativeAltitude + 10` or a destructive confirmation.
- **Accept** `fence_breach.sh` PASS (its last check flips once the page has a guard; move the guard into a testable function
  that the scenario calls).

### BUG-032: Data race: `disconnect()` clears transport callbacks on main while the transport queue calls them
- **Severity** Medium · **Category** crash (concurrency) · **Verdict** CONFIRMED with Thread Sanitizer
- **Repro** `HARNESS_SANITIZE=thread TSAN_OPTIONS="halt_on_error=0 exitcode=0" python3 testing/scenarios/run.py connect_spam replay`
  then `grep -A12 "ThreadSanitizer: data race" testing/logs/connect_spam.harness.log`.
- **Expected** No races; a callback is either delivered completely or not at all after Disconnect.
- **Actual** 2 races in `connect_spam` and 2 in `replay`: "Write of size 8 by main thread: NWClientTransport.onReceive.setter
  ← LinkManager.disconnect() LinkManager.swift:188 / Previous read by GCD worker: NWClientTransport.receive
  NetworkTransports.swift:230", and the same for `ReplayTransport.step()` ReplayTransport.swift:158 (via
  `LinkManager.startReplay` → `disconnect()`). Swift closures are 16-byte values, so a torn read can call a freed context
  (a rare crash when tapping Disconnect, Reconnect or a replay during heavy traffic). The other 6 scenarios run under TSan
  (connect, UDP link loss, TCP drop, mid-transfer disconnect, 30 % lossy link, reboot) were race-free.
- **Cause** `App/Link/LinkManager.swift:188-189` mutates `onReceive`/`onStateChange` from main; the transports read them on
  their own queues (`NetworkTransports.swift:230` TCP, `:216` UDP, `ReplayTransport.swift:158`); `UDPListenTransport` (`:76`) uses
  the same pattern.
- **Fix** Let each transport own its callbacks behind its queue: `close()` clears them with `queue.sync`/`queue.async`
  before cancelling, and `LinkManager` stops touching the properties. Alternatively, protect them with a lock. Keep the
  generation check that already drops late callbacks.
- **Accept** The repro above reports 0 races for `connect_spam`, `replay`, `tcp_drop` and `disconnect_mid_transfer`.

### BUG-036: Integers are shown with the locale's grouping separator: PWM 1500 reads "1.500"
- **Severity** Medium · **Category** UX, data · **Verdict** CONFIRMED in the real UI (Mac Catalyst, Greek/EU locale)
- **Repro** `testing/sim/catalyst.sh uitest BreakTestUITests2/test_D4_radioBars` (Setup › Radio calibration).
- **Expected** PWM values as plain microseconds: `1500`, `1300`.
- **Actual** `1.500`, `1.300` (screenshot `testing/evidence/catalyst-D4-radio-grouped.jpg`): in "." grouping locales a pilot reads
  1.5. The same happens for servo outputs, ESC RPM ("9.000 rpm"), the flight-mode "Current PWM" and the parameter group
  counts. Values ≥ 1000 are affected; most of Europe uses "." or a space as the grouping separator.
- **Cause** SwiftUI `Text("…\(intValue)…")` and `Text(cond ? "—" : "\(v)")` build a `LocalizedStringKey`, whose
  interpolation formats integers with grouping: `App/UI/SetupView.swift:342` (RC), `:438` (flight-mode PWM),
  `App/UI/FlightDataTabs.swift:133` (servo out), `:190` (ESC rpm), `App/UI/ParametersView.swift:187` (counts).
- **Fix** For machine values use `Text(verbatim: "\(v)")` or `Text(String(v))` (or `v.formatted(.number.grouping(.never))`).
  Add a lint/grep check in CI for `Text("\\(` on integer telemetry.
- **Accept** `test_D4_radioBars` passes (plain `1500`), in a locale with "." grouping (`-AppleLocale el_GR` launch argument).

### BUG-037: The real UI uses ~48 % CPU at high telemetry rates and memory grows under load
- **Severity** Medium · **Category** performance · **Verdict** CONFIRMED (Mac Catalyst, Apple silicon; an iPad will be slower)
- **Repro** `testing/sim/catalyst.sh perf BreakTestUITests2/test_perf_highRateAndFlood` (fake drone 50 Hz × 8 streams for
  60 s, then + 200 STATUSTEXT/s for 60 s; CPU/RSS sampled every 5 s into `testing/logs/catalyst_perf_*.csv`).
- **Actual** avg **48 % CPU** (one core) at 50 Hz, versus 7 % for the same code headless (so ~85 % of the cost is SwiftUI
  re-rendering on every packet); RSS **312 → 358 MB in 2 min** under load. Long-session result: see section 7.
- **Cause** Every decoded packet hops to main and mutates `@Published` properties one by one (`LinkManager.swift:316-338`,
  `VehicleModel.handle`), so the whole HUD/map/status hierarchy invalidates up to hundreds of times a second;
  `messages.insert(at: 0)` per STATUSTEXT; per-packet `messageCounts` dictionary publish.
- **Fix** Coalesce: apply packets to a plain model on the I/O queue and publish a snapshot to the UI at ≤ 10–20 Hz
  (HUD) / 2 Hz (status lists); keep `messageCounts` unpublished and refresh Diagnostics on a timer; ring buffer for
  messages. Re-measure with the perf command.
- **Accept** `perf test_perf_highRateAndFlood` averages < 15 % CPU and RSS growth < 10 MB over the 2 minutes.

### BUG-023: ExpressLRS backpack answers with port 0 or `enabled:false` are used as-is
- **Severity** Low · **Category** UX · **Verdict** CONFIRMED (decoder)
- **Repro** `testing/scenarios/probe_elrs_backpack_json.sh`.
- **Actual** `{"ports":{"listen":0,"send":0}}` → the app connects to 10.0.0.1:0 from iPad port 0. With `enabled:false` it
  connects anyway, and the warning is only in the Connect footer.
- **Cause** `App/Link/LinkManager.swift:122-123`; `App/Link/ELRSBackpack.swift`.
- **Fix** Ignore ports 0; if `enabled == false`, set state `.failed("MAVLink is disabled on the backpack: set Backpack
  Telemetry = WiFi")`.
- **Accept** The probe PASS.

### BUG-024: Out-of-range port text is silently replaced by the default port
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Repro** Simulator: Connect › TCP › port `70000` › Connect → connects to 5760 without a word.
- **Cause** `App/UI/ConnectView.swift:119-120` (`UInt16(portText) ?? kind.defaultPort`).
- **Fix** Validate (1–65535) and disable Connect with an inline error.
- **Accept** XCUITest: entering 70000 disables Connect.

### BUG-025: "Telemetry lost" is spoken on a deliberate Disconnect, and speech also runs during replay
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Cause** `App/Link/LinkManager.swift:197` (`vehicle.tick(now: .distantFuture)` flips `heartbeatAlive`) +
  `App/Vehicle/SpeechAlerts.swift:34`; `SpeechAlerts` doesn't know about `isReplaying`.
- **Fix** Suppress link alerts on user disconnect; mute (or prefix "Replay:") during replay.
- **Accept** Unit test with a stub synthesiser: disconnect produces no "Telemetry lost".

### BUG-026: A failed replay keeps the previous log's name, packet count and duration in the replay bar
- **Severity** Low · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/replay.sh`: after `garbage.tlog`, `state=Failed: No MAVLink packets … loaded=true
  packets=607 dur=6.04` (values from the previous file).
- **Cause** `App/Link/ReplayTransport.swift:75-83` fails without resetting `ReplayController`; `LinkManager.startReplay`
  keeps `isReplaying = true`.
- **Fix** Reset the controller at `open()`. On failure set `isReplaying = false` (hide the ReplayBar) and show the error.
- **Accept** `replay.sh` adds a check that `replay.loaded == false` after the garbage file (PASS).

### BUG-027: A pending-command banner ("Arming…") can stay forever after the sessions re-attach or detach
- **Severity** Low · **Category** UX · **Verdict** CODE
- **Cause** `App/Vehicle/CommandCenter.swift:20-29`: `attach`/`detach` replace the session without resolving `lastResult`,
  so the timeout event never fires.
- **Fix** In `attach`/`detach`, set `lastResult = "…: link changed, not confirmed"` for pending commands.
- **Accept** Unit test: `arm()`, then `attach()` with a new compid, sets `lastResultOK == false` with a message.

### BUG-028: A failed compass shows 100 % progress
- **Severity** Low · **Category** UX · **Verdict** CONFIRMED
- **Repro** `testing/scenarios/compass_cal_fail.sh` (compass 2 fails at 60 %).
- **Actual** `progress=[0: 100, 1: 100]`. The red "Failed" text appears under a full green bar.
- **Cause** `App/Vehicle/VehicleModel.swift:374` sets the progress to 100 for any MAG_CAL_REPORT.
- **Fix** Set 100 only when `calStatus == 4` (success); otherwise keep the last value and colour the bar red.
- **Accept** `compass_cal_fail.sh` PASS.

### BUG-029: Radio calibration samples RC at 1 Hz on narrow links, so the stored min/max can be too narrow
- **Severity** Low · **Category** data · **Verdict** CODE
- **Repro** Simulator, ExpressLRS or BLE link (narrow stream rates): Setup › Radio › Calibrate, then sweep the sticks quickly.
  The extremes are often missed between 1 Hz samples, and RCn_MIN/MAX are written too narrow.
- **Cause** `App/Link/LinkManager.swift:41-44` (`rcChannels: 1` Hz on narrow links); `App/UI/SetupView.swift:364-370` samples
  whatever arrives; the page doesn't raise the rate.
- **Fix** While capturing, send SET_MESSAGE_INTERVAL(RC_CHANNELS, 10 Hz) (5 Hz on ELRS) and restore it on Save/Cancel. Show
  the sample rate and ask the user to hold each extreme for 1 s.
- **Accept** A harness test with the fake drone (RC_CHANNELS rate follows SET_MESSAGE_INTERVAL) captures the full
  1000–2000 range from a 0.5 Hz sweep.

### BUG-035: Accessibility: 165 audit issues (low-contrast captions, icon names read aloud, unlabelled menus)
- **Severity** Low · **Category** accessibility · **Verdict** CONFIRMED (XCUITest `performAccessibilityAudit`, Mac Catalyst)
- **Repro** `testing/sim/catalyst.sh uitest BreakTestUITests2/test_a11y_audit` (Data, Plan, Setup, Params screens); the
  full list is attached to the result bundle as "note-…a11y…".
- **Actual** 112 contrast failures (top-bar captions in `.secondary` on `.bar`: "TCP 127.0.0.1:5799", "ArduCopter · sys 1",
  Link button; repeated on every screen), 13 "label not human-readable" in Params (raw names/values only), SF Symbol
  names read aloud as labels ("battery.75", "exclamationmark.shield", "hand.tap"), the Map and File menus and the
  altitude-frame picker without a description, 4 "potentially inaccessible text" on Data (HUD Canvas).
- **Cause** `App/UI/RootView.swift:84-145` (caption colours), Setup sidebar `Label` icons
  (`App/UI/SetupView.swift:50-61`), `MapToolsMenu`/`File` menus without `accessibilityLabel`, `HUDView` Canvas exposes
  one label only.
- **Fix** Use `.foregroundStyle(.primary)`/higher-contrast colours on the bar; `Label(title, systemImage:)` with
  `.labelStyle` instead of bare images; `.accessibilityLabel` on menus/pickers; expose HUD values and banners as
  accessibility elements (also needed for TEST-031).
- **Accept** `test_a11y_audit` reports < 10 issues, none on the top bar.

### BUG-038: ManualControl turns a NaN stick value into full deflection
- **Severity** Low · **Category** safety (hardening) · **Verdict** CONFIRMED headless (`manual_control_rover.sh`, `manual_control_sub.sh`)
- **Actual** `frame.y=1000 for NaN input`: `ManualControl.scaled` clamps with `max(-1, min(1, NaN))`, which Swift evaluates to
  `1.0`. The on-screen sticks can't produce NaN (their drag math divides by a constant) and gamepad axes are finite, so this is
  hardening for a control path that moves a vehicle.
- **Cause** `App/Control/ManualControl.swift` `shape(_:)`/`scaled(_:)`.
- **Fix** `guard v.isFinite else { return 0 }` in `shape`; treat non-finite as centre.
- **Accept** both scenarios PASS.

### BUG-039: ADS-B traffic is accepted without a coordinate check or a count limit
- **Severity** Low · **Category** robustness, performance · **Verdict** CONFIRMED (code + UI: lat 200/lon 210 is stored; no crash)
- **Repro** `testing/sim/catalyst.sh uitest BreakTestUITests2/test_Z7_adsbOutOfRangeCoordinate` (no crash: MapKit tolerates an
  invalid annotation coordinate); flood: `BreakTestUITests2/test_perf_adsbFlood` (200 new aircraft/s; not measured yet).
- **Cause** `App/Vehicle/VehicleModel.swift:292-303` stores any ADSB_VEHICLE with `lat != 0 || lon != 0`, from any sysid, with
  only a 60 s expiry; `MapCanvas.syncTraffic` re-walks every aircraft on every update.
- **Fix** Accept only |lat| ≤ 90, |lon| ≤ 180; cap at ~300 aircraft (drop the farthest/oldest); throttle map sync to 2 Hz.
- **Accept** a harness test with 10 000 unique ICAO keeps `traffic.count` ≤ 300 and rejects lat 200.

### TEST-030: The app layer has no tests, CI runs only MAVLinkKit, and there are no UI tests
- **Severity** Medium · **Category** test gap
- **Details** `LinkManager`, `VehicleModel`, the stores and every view are untested. All bugs above except BUG-002/-007/-010/
  -016/-019/-020 live there. CI (`.github/workflows/build-sideloadly-ipa.yml`) runs `swift test` for MAVLinkKit only.
- **Fix** (1) Move `testing/unit/extra/BreakTestRegressionTests.swift` into `Packages/MAVLinkKit/Tests/MAVLinkKitTests/`.
  (2) Extract `VehicleModel`, the stores and `LinkManager` (no UIKit) into a second package or test target and port the
  harness scenarios to XCTest using the Python fake drone, or a Swift in-process fake transport implementing `MAVTransport`.
  (3) Add a CI job: `testing/harness/build_harness.sh && python3 testing/scenarios/run.py all` (needs no Xcode project).
  (4) Add an XCUITest target in `project.yml` covering connect, arm-confirm, mode buttons and the banners.
- **Accept** CI runs the harness scenarios and fails on any CRASH; the XCUITest target runs on `iPad Pro 13-inch (M4)`.

### TEST-031: The UI has no accessibility identifiers, so XCUITest can't drive it reliably
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
| A1 Install, landscape, Connect sheet | Mac Catalyst UI: app launches with the Connect sheet (`test_A1_B1_launchAndConnect`, `testing/evidence/catalyst-A1-connect-sheet.jpg`); Sideloadly install/landscape on iPad N/T | PARTIAL |
| A2 Diagnostics version/build | UI `test_A2_B6_diagnostics` (version shown; CI stamps the build number) | PASS |
| A3 Documents folders | harness: `DocumentsStore` creates logs/params/missions/tiles | PASS |
| B1 Connect, firmware/mode/GPS shown | `connect`, `connect_udp_listen`, `connect_udp_connect` | PASS. ELRS kind N/T (Wi-Fi-only + real 10.0.0.1 backpack); backpack JSON → BUG-023 |
| B2 HUD moves, no NO ATTITUDE banner | `connect` (attitude flowing); Mac Catalyst UI: HUD, tapes and map render live (`catalyst-B1-connected.jpg`) | PASS; NaN/Inf crash → BUG-003 |
| B3 Values plausible | `connect` vs fake drone truth | PASS |
| B4 ESC telemetry | `esc_telemetry` (4 ESCs, 0 RPM disarmed, RPM + temperature armed); UI scroll to the section not automatable on Mac | PASS (RPM grouping → BUG-036) |
| B5 Link drop banner + voice | `link_loss`, `link_loss_udp`, `blackout` PASS; UI: red NO HEARTBEAT shown on silence and cleared after (`test_B5_…`); `tcp_drop` + UI `test_BUG001_…` FAIL; voice N/T | FAIL → BUG-001 (Link % → BUG-016) |
| B6 Heartbeat sources, message counts | `connect` | PASS |
| C1 Download all params | `params` (400), `params_1500`, `lossy_link` (30 % loss: 9.5 s); SITL `sitl_params` (1370 in < 1 s), `sitl_lossy` (1370 at 30 % loss in 20 s) | PASS (metadata gap → BUG-034) |
| C2 Save .param | `param_file_roundtrip`, `sitl_param_file_roundtrip` | PASS |
| C3 Write + confirm + set back | `param_set`, `sitl_param_set` (MAV1_EXTRA1) | PASS (NaN → BUG-020; `SR6_` in the instructions → BUG-034) |
| C4 Options/bitmask metadata | `params`; UI `test_C4_paramEditorListsAndBitmask` (FRAME_CLASS list, ARMING_CHECK checkboxes) | PASS |
| C5 Load file → 0 differ | `param_file_roundtrip` PASS; NaN case FAIL | FAIL → BUG-020 |
| D1 Pre-arm checks | `prearm_check`, `sitl_prearm_check`, `reject_arm`; UI `test_D1_prearmButton` | PASS |
| D2 Accelerometer calibration | `accel_cal` PASS (positions 1–6, success), `accel_cal_fail` PASS; `accel_cal_lossy(_retap)` FAIL; `accelcal_live_nan` CRASH; `sitl_accel_probe` (real position re-requests at 1 Hz) | FAIL → BUG-009, BUG-021 |
| D3 Compass calibration | `compass_cal` PASS (progress, reports, accept); `compass_cal_fail` FAIL | PASS (UX: BUG-028) |
| D4 Radio calibration | UI `test_D4_radioBars` (16 channels with bars) | PARTIAL: values grouped → BUG-036; BUG-029 |
| D5 Flight modes page | `probe_fltmode_ch0`, `param_nan`, UI `test_Z3_BUG005_…` (real crash) | FAIL → BUG-005 |
| D6 Motor test | `motor_test`; UI `test_D6_motorTestLockouts` (buttons disabled until "props removed", then accepted) | PASS |
| D7 Geofence altitude | `geofence_apply`; UI `test_D7_fencePage` | PASS (in-flight → BUG-022) |
| D8 Battery monitor calibration | UI `test_Z6_BUG018_…` | FAIL → BUG-018 |
| D9 DataFlash list/download | `log_download`; `sitl_log_download` (3 logs listed, 3 MB downloaded at ~100 kB/s, size matches) | PASS (memory: BUG-019) |
| E1 Offline map download | UI `test_E1_offlineMapsTinyArea`: sheet, radius slider and tile estimate; no download (Esri terms) | PARTIAL |
| E2 Offline imagery | as E1 | N/T |
| E3 Plan editing | UI `test_E3_E4_planEditWriteRead` (4 map clicks → 4 waypoints, +Takeoff/+RTL, editor) | PASS; editor crash → BUG-007 |
| E4 Write/Clear/Read mission | `mission_roundtrip`, `large_mission` (700), `lossy_link`; SITL `sitl_mission_roundtrip` PASS; SITL lossy uploads FAIL | FAIL → BUG-033 |
| E5 Save .waypoints | `mission_roundtrip` (save + parse); UI `test_E5_saveWaypointsFile` (File › Save writes the file); desktop MP check N/T | PASS; corrupt file → BUG-007, huge → BUG-010 |
| E6 Survey grid | UI `test_E6_surveyGrid` (outline 4 corners → grid appended); `probe_survey_*` | PASS; huge → BUG-010 |
| E7 Fence + rally round trip | `fence_rally`, `sitl_fence_rally`; UI `test_E7_fenceAndRally` | PASS |
| F1 Checklist | UI `test_F1_checklist` | PASS |
| F2 Quick mode + banner | `mode_change`, `sitl_mode_change` PASS (incl. 3-tap spam); `no_ack` FAIL | FAIL → BUG-017 |
| F3 Arm/disarm + refusal | `arm_disarm`, `reject_arm`, `sitl_arm` (arms in GUIDED; in-flight disarm refused and explained) PASS; confirmation dialogs present (code) | PASS (lossy-link caveat: BUG-002) |
| F4 Servo override, motors greyed | UI `test_F4_servoMotorOutputsGreyed` PASS (after params); `servo_before_params` FAIL; SITL refuses motor overrides | FAIL → BUG-014 (defence in depth) |
| F5 Replay, play/pause, seek, speed | `replay` (+ garbage/empty files); UI `test_F5_replayBar` | PASS (BUG-026) |
| G1 Manual flight, trail | simulated in `auto_mission` (trail drawn) | PARTIAL (no real flight) |
| G2 Auto mission, current WP | `auto_mission` (fake), `sitl_auto` (real ArduCopter: AUTO, waypoints reached, RTL, land, disarm) | PASS (simulated) |
| G3 Fly here | `fly_here`; UI `test_G3_flyHereClickHold` (click-and-hold prompt works; −5 m accepted) | FAIL → BUG-011, BUG-006 |
| G4 Altitude fence breach | `fence_breach` (fake), `sitl_fence` (real: "Max Alt fence breached" → RTL) | PASS (simulated); applying in flight → BUG-022 |
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
| Reboot | `reboot`, `sitl_reboot` | PASS |
| Multiple vehicles / other GCS / compid change | `second_vehicle`, `other_gcs`, `compid_switch` | PASS |
| Rapid repeated actions | `connect_spam`, `arm_disarm` (arm, arm, disarm), `mode_change` (spam) | PASS on a clean link |
| Disconnect mid-transfer | `disconnect_mid_transfer` | PASS |
| STATUSTEXT flood | `statustext_flood` (200/s: list capped at 300, +0.6 MB) | PASS |
| High telemetry rate | `high_rate` (50 Hz × 8: 7 % CPU, +0.4 MB) | PASS (headless; UI cost N/T) |
| Long session | `long_session` (5 min at default rates: RSS 32.2 → 32.5 MB; tlog 390 KB ≈ 4.7 MB/h) | PASS |
| Large mission | `large_mission` (700 items, 0.1 s each way) | PASS |
| Input validation (files, fields) | `probe_*` | FAIL → BUG-006, -007, -010, -020 |
| Backgrounding, rotation, memory warning | iOS lifecycle; tests exist (`test_lifecycle_*`) but are compiled out on Mac Catalyst | N/T (no iPad Simulator) |
| Fuzzing (random valid-CRC frames, all 349 ids, NaN/Inf-biased floats, random sysids) | `probe_fuzz_pipeline.sh` (300k frames), `probe_fuzz_pipeline_skip_known.sh` (3 × 300k, skipping ids 76/39) | CRASH on ids 76 (BUG-009) and 39 (BUG-007); no other traps in 900k frames; out-of-range values stored (BUG-003/-004) |
| Data races (Thread Sanitizer) | 8 network/replay scenarios with `HARNESS_SANITIZE=thread` | FAIL → BUG-032 (4 reports in 2 scenarios) |
| Memory errors (AddressSanitizer) | `HARNESS_SANITIZE=address`: connect, connect_spam, replay, malformed, lossy_link_corrupt, log_download, fuzz | PASS (no reports) |
| Mission protocol edge cases | `mission_no_space` (MISSION_ACK NO_SPACE → "No space (too many items)"), `mission_oob` (request beyond count → upload aborted with "Vehicle asked for item 16 of 11") | PASS (aborting is acceptable; the `mission_oob` check expects "accepted" and so reports FAIL by design) |
| Parameter edge cases | `param_16char` (16-char name, no NUL: decoded and writable), `param_count_change` (inconsistent total → "10 missing. Tap Refresh") | PASS (the FAIL in `param_count_change` comes from the fake's inconsistent count; the app's handling is correct) |
| Accessibility audit (UI) | `test_a11y_audit` on Data/Plan/Setup/Params | FAIL → BUG-035 (165 issues) |
| Light/dark appearance (UI) | `test_appearance_lightAndDark`: dark mode readable (`catalyst-appearance-dark-data.jpg`); the `-AppleInterfaceStyle Light` argument did not override the Mac's dark mode, so light mode was **not** rendered | PARTIAL (light N/T) |
| UI performance (real SwiftUI) | `catalyst.sh perf test_perf_highRateAndFlood`, `test_perf_longSession` (30 min) | FAIL → BUG-037 |
| Existing tests | `testing/unit/run_unit_tests.sh` | PASS 34/34 |

---

## 6. Not tested and why

- **iPad-only UI** (A1 install/landscape, iPad layout, touch gestures such as long-press "Fly here", rotation,
  backgrounding, memory warnings, the Files app, on-screen keyboards): the iOS simulator runtime (~8 GB) was declined. The UI
  ran instead as a Mac Catalyst app (`testing/sim/catalyst.sh`, 9 tests). The full iPad suite (`testing/sim/sim.sh uitest`,
  11 tests incl. `test_lifecycle_*`) is ready for when a runtime is installed: `xcodebuild -downloadPlatform iOS`, then
  `testing/sim/sim.sh boot && testing/sim/sim.sh uitest`.
- **SITL coverage gaps**: SITL ran 17 scenarios (section 5). Not run on SITL: compass calibration (SITL can't rotate), the
  accel calibration to completion (same reason: only the request/confirm protocol was probed), ESC telemetry.
- **ExpressLRS link type**: it is Wi-Fi-only (`requiredInterfaceType = .wifi`), so it can't run over loopback, and the
  ground rules forbid binding a fake backpack to a LAN interface. The backpack JSON handling was probed offline (BUG-023).
- **BLE transport, Local Network permission, speech output, Files app, share sheets**: platform/hardware features with no
  simulator-free equivalent. Speech *triggers* were code-reviewed (BUG-008, BUG-025).
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
- Round 2 (fake drone now models ESC telemetry, onboard compass cal, 6-position accel cal with 1 Hz re-requests, pre-arm
  check, motor test, altitude fence): 11 scenarios, 7 PASS, 4 FAIL → BUG-021, BUG-022, BUG-028 (+ BUG-029 by code review).
- Fuzzing: in-process fuzzer (`testing/harness/Sources/Fuzz.swift`) through the real VehicleModel/stores routing: crashes on
  COMMAND_LONG (BUG-009) and legacy MISSION_ITEM (added to BUG-007); 900k further frames without a trap.
- Thread Sanitizer build (`HARNESS_SANITIZE=thread`): data races on transport callbacks → BUG-032.
- Protocol edge cases (NO_SPACE, out-of-range request, 16-char names, changing param_count): app handling correct.
  AddressSanitizer over 7 scenarios incl. fuzzing: no reports.
- SITL (ArduCopter 4.7.3 built natively after patching a macOS linker issue): 17 scenarios. Confirmed BUG-014 (ArduPilot
  rejects motor-output overrides itself), BUG-020 (NaN write hangs), BUG-021 (ArduPilot re-requests positions at 1 Hz),
  BUG-022 (immediate breach on real firmware). New: BUG-033 (lossy mission upload fails or is misreported; 4/4 runs) and
  BUG-034 (42 % of 4.7.3 params have no metadata; `SRn_` renamed `MAVn_`).
- The runner gained `-j N` (parallel workers with their own ports, SITL instance and Documents folder).
- Mac Catalyst UI: the unmodified app builds as a Mac app from a test-only spec (`testing/sim/project-catalyst.yml`; the UI
  test runner is re-signed ad-hoc). 9 XCUITests vs the fake drone: real crashes for BUG-003 (HUDView.swift:142), BUG-004
  (MKMapView setCenterCoordinate, MapCanvas.swift:139), BUG-005 (SetupView.swift:438), BUG-006 (ActionsView.swift:169);
  BUG-001, -012, -013 confirmed on screen; BUG-008 corrected (the Quick tile turns red below 20 %); BUG-016 extended (Link %
  stays 100 % while the link is dead). Screenshots: `testing/evidence/`.
- Round 3, Mac Catalyst UI (22 tests in `BreakTestUITests2`): PASS for E3/E4, E5, E6, E7, D1, D6, D7, C4, F1, F4, F5, A2/B6,
  E1 (sheet only), a11y collection, dark mode (light mode could not be forced); FAIL/CRASH confirming BUG-006/-011 (fly-here −5 m), BUG-007 (editor crash),
  BUG-018 (no confirmation); new BUG-035 (165 accessibility issues), BUG-036 (locale-grouped PWM "1.500"), BUG-037 (48 % CPU
  at 50 Hz, memory growth). B4 in the UI not automatable on Mac (list scrolling).

---

## 8. Re-test after pulling origin/main (12 upstream commits, merged as 467f9ea on 2026-11-28)

Upstream added rover/sub support, gamepad/on-screen MANUAL_CONTROL, a graph, MAVLink inspector, ADS-B, gimbal, DataFlash
review and several setup pages. Re-test results:

| Area | Result |
|---|---|
| Reported bugs BUG-001…037 | **All still present** (every cause line unchanged; full re-run 105 runs: 65 PASS / 24 FAIL / 16 CRASH, same set as before) |
| Unit tests | 51 (incl. 9 new DataFlash tests): all upstream tests pass; the 4 regression tests still fail as intended |
| Harness | builds after adding a UIKit stand-in (`testing/harness/UIKitShim`): `PlannerSettings.swift` (model layer) now imports UIKit |
| ManualControl (new) | opt-in, ~10 Hz frames, off on link loss / app backgrounding, stays off until re-enabled, refused on copters: PASS. NaN → full deflection: BUG-038 |
| ArduRover / ArduSub SITL (new) | `sitl_rover_manual`, `sitl_sub_manual`: the vehicle drives under MANUAL_CONTROL (rover 10 m, ROV 5.5 m in 8 s); params 1256 / 1399 |
| DataFlash parser (new) | `probe_dataflash_fuzz`: 20 000 mutated/random .bin inputs, no trap |
| TelemetryHistory / MessageInspector (new) | bounded (120 s / 5 s windows) by code review |
| ADS-B (new) | no crash with out-of-range positions; no validation or cap: BUG-039 |
| TESTING_SIMULATOR.md UI (Mac Catalyst) | S-C6 measure, S-C12 graph, S-C13 inspector, S-C15 DataFlash review, S-C16/S-R2/S-S7 every setup page for copter/rover/sub (no crash), S-R5 rover Control tab, S-S5 leak banner: PASS. S-G2: test could not reach the row (list scrolling), not a bug |
| Long UI session (30 min, normal rates) | avg 30 % CPU; RSS 327 → 383 MB in 15 min then flat (378–388 MB): warm-up, no steady leak (CPU → BUG-037) |
| Mission upload on lossy SITL | BUG-033 is intermittent: 4/5 failed in earlier runs, 1/3 in this run |

---

## 9. Status after the fixes (branch `bug_fixes`, version 0.5.0)

Every action item was addressed; details per bug (cause → change → proof) in `testing/FIX_LOG.md`, and every change is
tagged `// BUG-0xx:` in the code. Verification on the fixed code:

| Check | Before | After |
|---|---|---|
| Unit tests (`swift test` / stand-in) | 51 pass + 4 regression tests failing | **55/55 pass** (regression tests now in `Packages/MAVLinkKit/Tests`) |
| Fake-drone scenarios + probes (`run.py -j 4 all`) | 16 CRASH, 24 FAIL | **0 CRASH; 86/86 PASS** (the two by-design edge cases now assert the intended behaviour) |
| ArduCopter/Rover/Sub 4.7.3 SITL (`run.py -j 4 sitl`) | lossy mission upload failed 4/5 | **21/21 PASS** incl. 3/3 lossy uploads (BUG-033) |
| Thread Sanitizer (6 link scenarios) | 4 races | **0 races** (BUG-032) |
| Mac Catalyst UI, crash tests (BUG-003/-004/-005/-006/-007) | app crashed in each | **no crash** |
| Mac Catalyst UI, BUG-001 / -008 / -013 | banner hidden / no warning / no confirmation | **pass** |

Status per item: FIXED = code change + passing test; PARTIAL = improved, remainder documented.

| Item | Status | Item | Status |
|---|---|---|---|
| BUG-001 link failure banner, TCP reconnect | FIXED | BUG-021 accel cal on lossy links | FIXED (confirm resend + STATUSTEXT result) |
| BUG-002 ACK matching | FIXED | BUG-022 fence below vehicle | FIXED (confirmation) |
| BUG-003 non-finite telemetry | FIXED | BUG-023 backpack ports | FIXED |
| BUG-004 map invalid coordinates | FIXED | BUG-024 port validation | FIXED |
| BUG-005 flight-mode channel 0 | FIXED | BUG-025 speech on disconnect/replay | FIXED |
| BUG-006 input ranges / crash loop | FIXED | BUG-026 failed replay state | FIXED |
| BUG-007 coordinate traps | FIXED | BUG-027 stuck command banner | FIXED |
| BUG-008 warnings | FIXED (HUD banner + battery colour) | BUG-028 failed compass 100 % | FIXED |
| BUG-009 ACCELCAL crash | FIXED | BUG-029 radio cal sample rate | FIXED |
| BUG-010 > 65 535 items | FIXED (limit 10 000) | BUG-032 data race | FIXED |
| BUG-011 fly-here result | FIXED | BUG-033 lossy mission upload | FIXED |
| BUG-012 stale after disconnect | FIXED | BUG-034 param metadata | FIXED (99.9 % coverage of 4.7.3) |
| BUG-013 confirm while armed | FIXED | BUG-035 accessibility | PARTIAL (labels, ids, top-bar contrast) |
| BUG-014 servo guard | FIXED | BUG-036 locale grouping | FIXED |
| BUG-015 GPS-loss stale position | FIXED | BUG-037 UI CPU | PARTIAL (50 ms batching: 48 % → 34 % CPU at 50 Hz; target < 15 %) |
| BUG-016 Link % | FIXED | BUG-038 NaN stick | FIXED |
| BUG-017 lost ACK reporting | FIXED | BUG-039 ADS-B limits | FIXED |
| BUG-018 battery calibration | FIXED | TEST-030 CI + app-layer tests | FIXED (CI `break-test` job) |
| BUG-019 DataFlash memory | PARTIAL (256 MB limit; streaming to file left as follow-up) | TEST-031 identifiers | FIXED |
| BUG-020 non-finite params | FIXED | | |

Not changed by design: aborting an upload when the vehicle asks for an item beyond the count (`mission_oob`), and
reporting "N missing, tap Refresh" when a vehicle's parameter count is inconsistent (`param_count_change`).
Still only testable on real hardware: iPad layout/touch/rotation/backgrounding, ExpressLRS backpack, BLE, speech, flight.
