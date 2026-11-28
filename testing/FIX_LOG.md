# Fix log (branch `bug_fixes`)

One entry per fix: bug id → cause → change → proof (test). Bug details and repros: `TESTING_RESULTS.md`.
Code comments at each change are tagged `// BUG-0xx:`.

## MAVLinkKit (unit-tested with `testing/unit/run_unit_tests.sh`)

| Bug | Change | Proof |
|---|---|---|
| BUG-002 | `CommandSession` queues a second command with the same id until the first one is resolved (COMMAND_ACK has no request id), then sends and retries it on its own; force-disarm is never queued. `pendingCommands` includes queued ones. | `test_BUG002_disarmNotCompletedByEarlierArmAck`, `test_BUG002_secondModeChangeRetriedAfterFirstAck`, `test_BUG002_forceDisarmGoesOutImmediately`, `probe_command_overwrite.sh` |
| BUG-007 | `MissionItem.e7()` converts degrees without trapping (non-finite → 0, clamp); `isValidCoordinate`; legacy `MISSION_ITEM` scales x/y only for location commands (others are param5/6); `WaypointFile.parse` rejects non-finite values and impossible positions (`badLine`). | `test_BUG007_*`, `probe_waypoint_file_nan/_huge_lat.sh`, `probe_mission_item_nan_coord.sh`, `probe_fuzz_pipeline.sh` |
| BUG-010 | `WaypointFile.parse` stops at `maxItems` (10 000) with `tooManyItems`. (App side: see below.) | `probe_waypoint_file_huge.sh` |
| BUG-016 | Loss estimate: late/duplicate packets no longer move the sequence baseline; a late packet that had been counted missing is un-counted. | `test_BUG016_reorderedPacketsAreNotLoss`, `test_cov_duplicatesDoNotCountAsLoss`, `reorder.sh` |
| BUG-020 | `ParamFile.parse` skips nan/inf. | `test_BUG020_paramFileRejectsNonFinite`, `probe_param_file_nan.sh` |
| BUG-033 | Mission upload: MISSION_ACK INVALID_SEQUENCE (13) is not fatal (ArduPilot keeps the upload open); after the last item, MISSION_ACK ERROR (1) or exhausted retries start a read-back (`uploadVerify`: MISSION_REQUEST_LIST → MISSION_COUNT must equal the uploaded count). The unit tests' simulated vehicle gained an `arduPilotLike` mode that behaves like SITL 4.7.3. | `testUploadToArduPilotLikeVehicleSurvivesLoss` (60 runs at 30 % loss), `sitl_lossy*.sh` |

## App (compiled as the full app for Mac Catalyst; behaviour checked by the headless harness scenarios/probes)

| Bug | Change | Proof |
|---|---|---|
| BUG-001 | NO HEARTBEAT shows whenever a vehicle was seen and its heartbeat stopped (`linkAlive: heartbeatAlive \|\| systemID == nil`); TCP reconnects every 2 s after failure/remote close; status bar shows "—" when not live. | `tcp_drop.sh` PASS |
| BUG-003 | `VehicleModel` drops non-finite/absurd ATTITUDE and VFR_HUD values; HUD label via `HUDView.whole()`; map marker transform only with finite angles. | `nan/inf/huge_values.sh`, `probe_hud_label_*` PASS |
| BUG-004 | Positions/home/ADS-B outside ±90/±180 rejected; `MapCanvas` only centres on `CLLocationCoordinate2DIsValid` coordinates. | `bad_latlon.sh` PASS |
| BUG-005 | Flight-mode channel 0 = "Mode switch disabled"; picker and Rover page use `UInt32(exactly:)`/finite checks. | `probe_fltmode_ch0`, `param_nan.sh` PASS |
| BUG-006 | `ActionLimits` ranges (takeoff 1–500, speed 0.1–50, alt 1–1000, fly-here 2–500 m); labels without `Int()`; persisted bad values repaired on appear. | `probe_takeoff_alt_huge` PASS |
| BUG-007 (UI) | Waypoint editor refuses invalid positions on Done. | UI `test_Z5_…` |
| BUG-008 | `VehicleModel.warning`: failsafe/fence/EKF/battery STATUSTEXT (≤ WARNING, 15 s) or battery ≤ 20 % / ≤ 10 %; HUD banner as a real accessible view; battery item coloured. | `battery_failsafe.sh`, UI `test_BUG008_…` |
| BUG-009 | `CalibrationStore.handle` uses `UInt32(exactly:)` and only codes 1–6/success/failed. | `accelcal_live_nan.sh`, `probe_accelcal_*` PASS |
| BUG-010 (app) | `MissionStore.setItems`/`addSurvey` refuse > 10 000 items with a banner; seq clamps. | `probe_waypoint_file_huge`, `probe_survey_huge` PASS |
| BUG-011 | Fly-here validates altitude, waits (≤ 5 s) for GUIDED before sending, and reports the vehicle's MISSION_ACK. | `fly_here.sh` |
| BUG-012 | `disconnect()` resets the vehicle model (armed/mode/attitude/battery/GPS cleared). | `stale_after_disconnect.sh` PASS |
| BUG-013 | Disconnect / Reconnect / Replay ask for confirmation when the vehicle is armed. | UI `test_BUG013_…` |
| BUG-014 | Servo overrides blocked while `SERVOn_FUNCTION` is unknown. | `servo_before_params.sh` PASS |
| BUG-015 | `VehicleModel.positionStale` (no valid position for 3 s or no fix); vehicle marker faded. | `gps_loss.sh` PASS |
| BUG-016 (UI) | Link % over the last 5 s (`LinkManager.linkQualityPct`), "—"/0 % when nothing arrives. | `reorder.sh` PASS |
| BUG-017 | Command timeout checks HEARTBEAT mode/armed before reporting failure. | `no_ack.sh` PASS |
| BUG-018 | Battery calibration refused while armed; changes outside ±20 % need confirmation. | UI `test_Z6_…` |
| BUG-019 | DataFlash downloads above 256 MB refused with a message (whole-log RAM buffer kept for now). | code |
| BUG-020 (app) | `ParameterStore.set`/`setMany` refuse non-finite values; NaN == NaN in compare. | `param_set.sh`, `param_nan.sh` |
| BUG-021 | Accel cal resends a lost confirm when ArduPilot keeps asking for the same position; STATUSTEXT result fallback. | `accel_cal_lossy*.sh` |
| BUG-022 | Fence page asks before applying a limit below the current altitude while armed. | `fence_breach.sh` PASS |
| BUG-023 | Backpack port 0 falls back to typed ports; `enabled:false` → failed state with instructions. | `probe_elrs_backpack_json` PASS |
| BUG-024 | Connect disabled with an inline error for ports outside 1–65535. | code |
| BUG-025 | No "Telemetry lost" on a deliberate Disconnect; speech muted during replay. | code |
| BUG-026 | Replay controller reset on open; a failed replay ends replay mode. | `replay.sh` |
| BUG-027 | Pending command banner resolved when sessions re-attach/detach. | code |
| BUG-028 | Compass progress 100 % only on success. | `compass_cal_fail.sh` |
| BUG-029 | Radio calibration requests RC_CHANNELS at 10 Hz while capturing, default afterwards. | code |
| BUG-032 | Transport callbacks are never mutated after wiring; generation checks drop late callbacks (no TSan race). | TSan re-run |
| BUG-036 | `Text(verbatim:)` for PWM/RPM/counts (no locale grouping). | UI `test_D4_radioBars` |
| BUG-037 | Packets reach the UI in batches every 50 ms instead of one main-queue hop per datagram. | `catalyst.sh perf` |
| BUG-038 | ManualControl treats non-finite stick values as centre. | `manual_control_rover/sub.sh` |
| BUG-039 | ADS-B: only valid positions, at most 300 aircraft. | code + UI `test_Z7_…` |
