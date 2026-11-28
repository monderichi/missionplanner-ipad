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
| BUG-033 (SITL) | Re-run against ArduCopter 4.7.3 SITL at 30 %/30 %/15 % loss: 3/3 uploads succeed (were 4/5 failing). | `sitl_lossy*.sh` PASS |
| BUG-034 | New `tools/gen_param_meta_ardupilot.py` converts ArduPilot's own `apm.pdef.json` (generated from the Copter-4.7.3 source with `param_parse.py`) into the app's metadata JSON for Copter/Rover/Sub/Plane/Tracker. Coverage of a 4.7.3 SITL dump: 99.9 % (was 57.9 %). TESTING.md C3 and README now say `MAV6_` (4.7+) / `SR6_` (older). Names only older firmware has (e.g. `ARMING_CHECK`, replaced by `ARMING_SKIPCHK` in 4.7; `SRn_*`) are kept from the previous metadata, so 4.6 vehicles keep their descriptions. | `testing/tools/param_meta_coverage.py`, UI `test_C4_…` |
| BUG-035 | Setup rows, Map and File menus get accessibility labels (SF Symbol names were read aloud); top-bar captions use primary colour (contrast). Partial: the remaining contrast findings are on system-styled controls. | UI `test_a11y_audit` |
| TEST-030 | Regression tests moved into `Packages/MAVLinkKit/Tests` (run by CI's `swift test`); new CI job `break-test` builds the headless harness and runs `run.py -j 3 ci` (all fake-drone scenarios + probes). | CI |
| TEST-031 | Identifiers: `connect.button`, `status.link`, `actions.arm`, `actions.disarm`, `plan.file`, `map.menu`, `setup.<page>`, `banner.noHeartbeat`, `banner.noAttitude`, `banner.warning`. | UI tests |
| (regression) | Batched UI updates could re-populate the model after Disconnect: the main-queue apply now checks the connection generation. | `stale_after_disconnect.sh` ×3 PASS |
| Version | `MARKETING_VERSION` 0.4.0 → 0.5.0 (project.yml, TESTING.md A2). | — |

## Review 1 (testing/REVIEW_1.md): required changes applied

| # | Change | Proof |
|---|---|---|
| 1 | BUG-002 redesigned: a newer arm/disarm or mode command is **sent immediately** and the superseded one is never resent. ACKs within one timeout are ambiguous and ignored; the command is confirmed by a later ACK or by the HEARTBEAT armed flag / custom mode received ≥ 0.3 s after sending (`CommandSession.confirmByState`, `CommandCenter.confirmFromVehicleState`). | `test_BUG002_disarmSentAtOnceAndArmNotResent`, `test_BUG002_secondModeChangeRetriedAfterFirstAck`, `sitl_arm.sh` |
| 2 | Force-disarm after an in-flight ARM is not "accepted" by the ARM's ACK; it is retried until a later ACK or a disarmed heartbeat. | `test_BUG002_forceDisarmNotAcceptedByArmAck` |
| 3 | Other commands (servo, relay, motor test, REQUEST_MESSAGE) queue FIFO per id: every tap is sent. Labels follow the queue, so results name the right channel, and a released command shows "…" again. | `test_BUG002_servoTapsAreNotDropped` |
| 4 | BUG-033 verification reads back the **last item** after the count matches (command, position, altitude ±5 cm); a vehicle that is still receiving gets its re-requested item (back to upload), and DENIED means "keep waiting". | `testUploadNotConfirmedWhenVehicleKeptOldLastItem`, `testUploadToArduPilotLikeVehicleSurvivesLoss` (200 runs, 0 failures), `sitl_lossy*.sh` |
| 5 | Speech announces Armed/Disarmed only for a live vehicle; replay mutes speech before disconnecting. | code |
| 6 | RC page: layout modifiers restored (a `//` comment had swallowed them); capture min/max use `Text(verbatim:)`. | UI `test_D4_radioBars` |
| 7 | Disconnect is shown whenever a link exists (also while failed/retrying) or a replay runs. | code |
| opt. | CI comment moved to the simulator job and `-j 2`; UI batch flag reset on disconnect; fly-here 5 s no-answer message and its ACK window cleared by other mission operations; a failed replay fully disconnects. Also: the accel-cal start is resent (≤ 3×) when no position request arrives within 5 s. | `accel_cal_lossy*.sh` |

## Review 2 (testing/REVIEW_2.md): required changes applied

| # | Change | Proof |
|---|---|---|
| 1 | Heartbeat confirmation of a superseding arm/disarm or mode command only counts after its ambiguity window (`CommandSession.confirmByState(_:now:)`, `CommandCenter.markSent`): a heartbeat from before the superseded command took effect can't confirm a lost DISARM. | `test_BUG002_forceDisarmNotAcceptedByArmAck` (no confirmation inside the window), `sitl_arm.sh` |
| 2 | Fence uploads are verified by reading back **every** vertex (ArduPilot keeps the whole old fence on timeout); missions/rally keep the last-item check. | `testFenceUploadNotConfirmedWhenVehicleKeptOldFence`, `sitl_fence_rally.sh` |
| opt. | Released queued commands ignore ACKs for a short window (a duplicate ACK of the previous one can't accept them); heartbeat marks the link alive before `armed`, so arm/disarm during a dropout is still announced; an old link's 50 ms flush no longer takes the new link's batch; read-back compares only the command for non-location items, rally altitude ±1 m; `Int()` of huge SERVOn_FUNCTION values clamped. | unit 60/60, fake drone 86/86, SITL 21/21, UI suite 1 9/9 |

## Review 3 (testing/REVIEW_3.md): required changes applied

| # | Change | Proof |
|---|---|---|
| 1 | The "count matches and ≤ 1 item → done" shortcut applies only to a home-only **mission**. A one-item fence (single circle) or rally upload is read back like any other. | `testSingleFenceCircleAndRadiusChangeAreVerified` (moved single circle) |
| 2 | Fence read-back compares `param1`: circle radius ±1 m, vertex count of polygon vertices exact. | `testSingleFenceCircleAndRadiusChangeAreVerified` (radius-only change), `sitl_fence_rally.sh` |
| opt. | The short ACK window for released queued commands was removed: ignoring a command's own fast ACK made each queued servo/motor/camera command go out twice. A rare duplicate ACK of the previous command is the smaller risk. | `test_BUG002_servoTapsAreNotDropped`, unit 61/61, fake drone 86/86, SITL subset 5/5 |

## Review 4 (testing/REVIEW_4.md): required change applied

| # | Change | Proof |
|---|---|---|
| 1 | A queued command released after its predecessor's ACK is not resolved by an ACK before it has been sent (`attempts == 0`): that ACK can only be a duplicate for the predecessor. If the predecessor was resent, the released command's first send gets a short window (`min(0.5 s, timeout/3)`) for late duplicates. On a clean link each command still goes out once. | `test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand`, `test_BUG002_servoTapsAreNotDropped` |
| opt. | One-item rally upload verified (`testSingleRallyPointMoveIsVerified`). The simulated mission vehicle's RNG is seeded (SplitMix64), so the 200-run lossy test is repeatable. With `LOSSY_RUNS=3000` about 1 run in 3000 ends in "No answer from vehicle": 16 tries in a row for one item lost at 30 % each way (0.51^16), which is the dead-link limit working as designed. | unit 63/63, fake drone 86/86, SITL subset 4/4 |

## Review 5 (testing/REVIEW_5.md): required change applied

| # | Change | Proof |
|---|---|---|
| 1 | The short ACK window after a resent predecessor (added for review 4) is removed. It cascaded: the next command's own fast ACK was ignored, so it was resent, which marked the following one as "after a resend", and so on (every later motor test or photo went out twice). Only the review-4 guard stays: an ACK can't resolve a queued command that hasn't been sent yet. Known limit, documented in the code: COMMAND_ACK has no request id, so a late duplicate ACK of the previous command can still resolve the next one once it is sent. | `test_BUG002_queueRecoversAfterLostAckAndTimeout` (6, 7, 8 go out once each after a lost ACK and after a timeout), `test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand` |
| CI | The user has no GitHub Actions minutes left. The `break-test` job now runs only on a manual workflow run, and pushes from here on carry `[skip ci]`. All checks run locally. | unit 64/64, fake drone 86/86, SITL subset 3/3 |

## Round 2 (branch `bug_fixes_2`, after the 0.5.0 merge)

| Item | Change | Proof |
|---|---|---|
| BUG-019 | `LogDownloadSession(fileURL:)` writes each 90-byte chunk at its offset in a file (`FileHandle` seek + write), truncates to the real size at the short EOF chunk and ends with `.finishedFile(url, bytes:)`. RAM use is 1 byte per chunk instead of 2× the log. `LogStore` streams to `<name>.partial` and moves it into place on success; cancel, failure and detach delete the partial file. The 256 MB cap is replaced by a free-space check (keep 200 MB free). | `testFileBackedDownloadThroughLoss` (20 % loss, oversize LOG_ENTRY), `testFileBackedDownloadReportsUncreatableFile`, `log_download` + `sitl_log_download` (size matches, no `.partial` left) |
| REVIEW_5 opt. 3 | Quiet `requestMessage` results are counted per id instead of a set, so overlapping requests never show a "Request message: accepted" banner; reset on link change. | code (harness scenarios) |
| REVIEW_5 opt. 2 | The one-item fence/rally tests also require the read-back failure ("differs"), so a hang can't pass them. | `testSingleFenceCircleAndRadiusChangeAreVerified`, `testSingleRallyPointMoveIsVerified` |

Verified: unit 66/66, fake drone 86/86, SITL `sitl_log_download`, `sitl_arm`, `sitl_mission_roundtrip`.
