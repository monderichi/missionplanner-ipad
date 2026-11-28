# Review 2: PR #1 `bug_fixes` → `main` (re-review after `ab78340`)

Reviewer: independent senior review (Claude), 2026-11-28. Scope: `git diff origin/main...HEAD -- App Packages tools .github project.yml`
at `ab78340`, read against testing/REVIEW_1.md, the "Review 1" table in testing/FIX_LOG.md and TESTING_RESULTS.md §9.

## Verdict

**CHANGES REQUIRED** (2 required changes, both small)

All seven REVIEW_1 items are fixed in code, not just in the docs. The BUG-002 redesign is sound: supersede for arm and mode,
FIFO for everything else, ambiguous ACKs ignored, and labels that follow the queue. Two gaps are left, both in the new
"confirm" paths, and each one can tell the pilot a safety-relevant action succeeded when it did not:

1. A heartbeat can confirm a **superseding** arm/disarm or mode command after only 0.3 s. That heartbeat can be stale in the
   same way as the ACKs the PR now ignores.
2. The BUG-033 last-item read-back is not enough for **fence** uploads. ArduPilot stages the whole fence and keeps the old
   one when an upload times out.

Everything else I found is optional.

## Status of REVIEW_1 items

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Superseded command retried, newer one delayed | **Resolved** | `CommandProtocol.swift:69-75`: for `supersedable` (400, 176) the new message replaces `pending` and is returned at once, with `ambiguousUntil = now + timeout`. The old message is gone, so `tick` can't resend it. `handle` ignores ACKs before `ambiguousUntil` (`:119`). `test_BUG002_disarmSentAtOnceAndArmNotResent` (narrowLink, ARM then DISARM at 0.5 s, no ACKs, 20 s of ticks) checks that DISARM goes out at once and that ARM is never resent. State confirmation is added (`CommandCenter.confirmFromVehicleState`, `:97-104`). See required change 1 for the remaining gap in its timing guard. |
| 2 | Force-disarm "accepted" by the ARM's ACK | **Resolved** (same caveat) | Force-disarm uses the supersede path. `test_BUG002_forceDisarmNotAcceptedByArmAck`: an ACK at 0.2 s is ignored, and force-disarm (param2 21196) is resent at 2 s. |
| 3 | Single slot drops servo/relay/motor/REQUEST_MESSAGE | **Resolved** | `queued: [UInt16: [CommandLong]]` FIFO (`:44`, `:76`). `releaseQueued` sends the next one on the following tick. `CommandCenter.labelQueue` keeps the labels in the same order, and `apply()` shows "label…" when a queued command is released (`:189-204`). `requestedArm`/`requestedMode` are only set by `arm`/`setMode`, which are never queued. `test_BUG002_servoTapsAreNotDropped` → [5, 6, 7]. Small remaining issues are under optional suggestions. |
| 4 | BUG-033 count-only read-back | **Resolved for missions and rally**, **not for fence** | `.uploadVerify` answers re-requests (`resumeUpload`), treats ACK 0 as success and DENIED as "wait". After MISSION_COUNT == n it goes to `.uploadVerifyLast`, which requests item n-1 and compares it with `sameItem` (`MissionProtocol.swift:333-366`, `:386`). `testUploadNotConfirmedWhenVehicleKeptOldLastItem` uses a write-through vehicle. `testUploadToArduPilotLikeVehicleSurvivesLoss`: 200 runs, 0 failures allowed. The check is sound for storage that writes each item as it arrives (ArduPilot waypoints and rally). For the fence it is not: see required change 2. |
| 5 | "Disarmed" spoken on Disconnect/Replay | **Resolved** | `SpeechAlerts.swift:36-41`: `[weak self, weak v]` and `guard let v, v.heartbeatAlive`. `reset()` clears `heartbeatAlive` (`VehicleModel.swift:197`) before `armed` (`:215`). `startReplay` sets `speech.muted = true` before `disconnect()` (`LinkManager.swift:95`). This adds a small side effect, see optional suggestion 1. |
| 6 | RC column modifiers commented out; min/max grouped | **Resolved** | `SetupView.swift:466`: `/* BUG-036 … */` is a block comment, so `.frame(width: 50, alignment: .trailing).monospacedDigit()` applies again. `:468` uses `Text(verbatim: "\(mins[i])–\(maxs[i])")`. |
| 7 | TCP retry loop can't be stopped | **Resolved** | `ConnectView.swift:130`: Disconnect is shown when `link.state != .disconnected \|\| link.isReplaying`. `LinkState` is `Equatable`. `disconnect()` closes the transport, which sets `closed` and ends `retryLater`, and bumps `connectGeneration`, which also cancels a pending ELRS backpack lookup. |

The optional REVIEW_1 suggestions were taken too: the CI comment moved and the job runs `-j 2`, `uiFlushScheduled` is reset,
fly-here has a 5 s timeout and its window is cleared by `read`/`write`, and a failed replay now calls `disconnect()`. The
batch fix is only partial, see optional suggestion 3.

## Required changes

### 1. State confirmation of a superseding arm/disarm or mode command accepts a stale heartbeat (0.3 s guard)
`App/Vehicle/CommandCenter.swift:97-104` (the `hb.timeIntervalSince(t) >= 0.3` guard), `Packages/MAVLinkKit/Sources/MAVLinkKit/CommandProtocol.swift:84-89`

- **Problem:** The PR treats ACKs inside one timeout (3 s on `.narrowLink`) after a supersede as ambiguous, because they
  may answer the old command. A HEARTBEAT is ambiguous in the same way: it may have been sent before the old command took
  effect. Yet one received only ≥ 0.3 s after the send confirms the new command, which then stops all retries.
  `confirmByState` has no time check of its own.
  Example on ELRS, where telemetry is 1 Hz and the uplink is shared with GCS heartbeats, parameter and mission traffic:
  1. The vehicle is disarmed. ARM is sent at t0, and the pilot confirms DISARM at t1.
  2. A heartbeat the vehicle sent before the ARM arrived (still "disarmed") reaches the iPad at t1 + 0.3 s or later.
     `v.armed == (param1 == 1)` holds, so DISARM is "accepted" and is never resent.
  3. The ARM then arrives and the vehicle arms. The single DISARM packet was lost.
  4. The banner says "Arm/disarm: accepted" with the vehicle **armed**, and nothing is retried.

  This is the REVIEW_1 item 2 outcome, now as a timing race rather than a certainty. It needs ARM uplink plus heartbeat
  downlink latency of more than (t1 − t0) + 0.3 s. The two confirmation dialogs make t1 − t0 about 1 s or more, so this is
  rare, but it is possible on a congested ELRS link. The same race applies to LOITER → RTL → LOITER: the second LOITER
  can be "confirmed" by a pre-RTL heartbeat, and if it is lost the vehicle stays in RTL. The HUD does show the real state on
  the next heartbeat, but the command is no longer being retried.
- **Fix:** The state rule only needs to change for commands that **superseded** another one. A plain ARM/DISARM/mode
  command can keep the 0.3 s rule.
  - In `CommandSession`, give `confirmByState(_:now:)` a `now` argument and make it return `[]` while
    `now < pending[cmd].ambiguousUntil`. Alternatively, expose `ambiguousUntil` and check it in `confirmFromVehicleState`.
  - Optionally, also accept the state earlier if a heartbeat received after the send showed the *opposite* state and a
    later one shows the requested state. That is an observed transition, which can't be stale.
  - Repeating a DISARM or a mode change that has already happened is harmless, so the extra ≤ 3 s of retries costs nothing.
  - Add a unit test: ARM, then DISARM at +1 s, then `confirmByState` at +1.4 s returns `[]`, and DISARM is resent at +4 s.

### 2. BUG-033 last-item verification can report a **fence** as uploaded while the vehicle kept the old fence
`Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:333-366` (`.uploadVerify` → `.uploadVerifyLast`), `:386` (`sameItem`)

- **Problem:** Checking only the last item relies on ArduPilot writing each item as it arrives, which is true for
  waypoints and rally points. Fences work differently. In ArduPilot's `MissionItemProtocol_Fence.cpp`:
  - `allocate_receive_resources` stages items in `_new_items`, and only `complete()` calls `write_fence()`.
  - `truncate()` is empty, and `timeout()` only sends "Fence upload timeout".

  So when a fence upload times out (an ELRS dropout during the last vertex), the vehicle keeps the **whole old fence**.
  Our resend of the last vertex then gets ERROR, which leads to verify. The count matches whenever the edit kept the
  vertex count, which is the usual case of dragging a vertex. The last vertex also matches whenever the moved vertex was not
  the last one. The session then reports `uploaded(.fence)`.
  Probe (scratch package against MAVLinkKit): 4-vertex fence upload, ERROR after the last item, MISSION_COUNT 4, last
  vertex identical → event `uploaded(type: fence, count: 4)`. The pilot is told the new geofence is active while the
  vehicle enforces the old one.
- **Fix:** For `.fence`, read back **all** items in the verify step and compare each with `sameItem`. Fences are a few
  dozen items, so this is cheap even on ELRS. You can reuse the download path: start a download and compare the result. A
  simpler alternative is to never report `.uploaded` from verify for `.fence` and say "Fence upload not confirmed: upload
  again". In both cases, extend `SimulatedMissionVehicle` with staged fence storage (keep the old list on timeout) and add a
  test where only a middle vertex changed and the last vertex is lost until the timeout.

## Optional suggestions

1. **Armed/mode changes during a link dropout are no longer spoken** (side effect of item 5). In
   `VehicleModel.handle` (`:310-314`) `armed` and `customMode` are assigned before `heartbeatAlive = true`. On the first
   heartbeat after "Telemetry lost", the new guard therefore suppresses "Disarmed" or "Armed", for example a failsafe or
   crash-check disarm during the dropout. The mode observer already behaved this way. Fix: set `heartbeatAlive = true`
   (and `lastHeartbeat`) before `armed`/`customMode`, or guard on `v.lastHeartbeat != nil` instead. `reset()` clears it
   before `armed`.
2. **A released FIFO command has no ambiguity window**, so a duplicate ACK of its predecessor accepts it. Probe: servo 5,
   servo 6 queued, servo 5 resent at 1.5 s, both servo-5 ACKs arrive at 1.6 and 1.8 s, and servo 6 (released at 1.75 s) is
   lost → `accepted` twice, servo 6 never retried, `pending = []`. This is only a banner/relay-state error for servo and
   relay, not a safety issue. Fix: in `releaseQueued`, set `ambiguousUntil = now + timeout` when the predecessor was
   resent (attempts > 1).
3. **UI batch after a quick reconnect** (`LinkManager.swift:376-386`): the old link's `asyncAfter` flush still runs. It
   takes `uiBatch`, which by then may hold the new link's first packets, and drops them on the generation check. That is
   ≤ 50 ms of packets, which every protocol retries. Store the generation with the batch (or `uiBatch = [(gen, packet)]`)
   so the old timer only drops its own packets.
4. **`sameItem` false negatives:** ArduPilot reads back x/y/z = 0 for commands that don't store a location (RTL, DO_*),
   and rally altitude as whole metres. A plan whose last item is RTL with a non-zero altitude (for example from a .waypoints
   file), or a rally point at 50.5 m, then always shows "Not confirmed" on the verify path. Compare x/y/z only for
   location commands (`MissionCmd.hasLocation` plus takeoff), and use a ±1 m tolerance for rally.
5. **BUG-005-style traps on huge finite values** remain at `FlightDataTabs.swift:174` and `RoverSetupPage.swift:27`.
   `Int(f.rounded())` after `isFinite` still traps for |f| > 9.2e18 (a fuzzed or corrupt PARAM_VALUE). Clamp first, as
   `FlightModesPage.channel` does, or use `Int(exactly:)`. A real ArduPilot sends `SERVOn_FUNCTION` as INT16, so this is
   low risk.
6. **The banner hides a queued command's predecessor result** (`CommandCenter.swift:194-199`): after "Servo 5: Denied…",
   the release of servo 6 overwrites `lastResult` straight away with "Servo 6 → ……", so the rejection is never seen.
   Consider "Servo 5: Denied · Servo 6…" or keep failures visible for a moment.
7. **`requestMessage`** (`CommandCenter.swift:137-143`) neither uses `labelQueue` nor checks whether it was queued. A
   second request while one is in flight overwrites `names[512]`, and its later result shows a "Request message: accepted"
   banner. This is cosmetic.
8. **Accel-cal start resend** (`CalibrationStore.tick`): if the start was received but all position requests in 5 s were
   lost, the resend restarts the calibration from position 1. That is acceptable, but say "restarting" in the banner so the
   pilot isn't confused.

## What I checked

- **REVIEW_1 items:** read the full current `CommandProtocol.swift` and `CommandCenter.swift`, the `MissionSession`
  upload/verify state machine and tick, the `SpeechAlerts` observers against `VehicleModel.reset()` and the heartbeat
  handler, `SetupView` RadioPage, `ConnectView`, and LinkManager connect/disconnect/startReplay/wire/process/apply. Also
  `git diff aa5adbc ab78340` for the fix commit itself.
- **Fresh pass:** read the whole diff of every Swift file under `App/` and `Packages/`, the workflow and `project.yml`. I
  skipped the ParamMeta JSON content and only skimmed `tools/gen_param_meta_ardupilot.py`. Threading: transport callbacks
  are immutable after `wire()`; `ioGeneration`/`uiBatch`/`uiFlushScheduled` are only touched on ioQueue; the main-queue
  apply checks `connectGeneration`; `disconnect()`'s `ioQueue.sync` is never reached from ioQueue; a failed replay's
  `disconnect()` runs from a main-queue async block, not inside the transport. I found no retain cycles (closures use
  `[weak self]`, `CommandCenter.vehicle` is weak).
- **iOS 16 / compile:** no new API above iOS 16. `Text(verbatim:)`, `overlay(alignment:content:)` and `let` in a
  ViewBuilder are fine with Xcode 14+. Block comments between modifiers are fine. `LinkState` is `Equatable` for `!=`.
- **ArduPilot behaviour:** checked `MissionItemProtocol_Fence.cpp` (master) for staged fence storage and the timeout
  behaviour (required change 2).
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 59 tests, 0 failed`.
- **Fake-drone CI set:** `testing/harness/build_harness.sh` built OK. `HARNESS_BIN=… python3 testing/scenarios/run.py -j 3 ci`
  → `TOTAL 88: PASS=88, FAIL=0, CRASH=0, ERROR=0` (localhost only; no SITL, no Catalyst UI tests, no hardware).
- **Probes** (scratch package against MAVLinkKit, outside the repo):
  1. FIFO duplicate ACK → servo 6 accepted without being received, never retried (optional suggestion 2).
  2. Fence upload, ERROR after the last item, MISSION_COUNT 4, last vertex unchanged → `uploaded(fence, 4)` (required
     change 2).
  - Required change 1 follows directly from the code: `confirmByState` has no time check and the only guard is the
    0.3 s receive time in `CommandCenter`.
