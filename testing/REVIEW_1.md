# Review 1: PR #1 `bug_fixes` → `main`

Reviewer: independent senior review (Claude), 2026-11-28. Scope: `git diff origin/main...HEAD -- App Packages tools .github project.yml`
(commits `b8463ee`…`782f4df`), read against TESTING_RESULTS.md §3/§9, testing/FIX_LOG.md and testing/PR_DESCRIPTION.md.

## Verdict

**CHANGES REQUIRED**

Most fixes are correct and well targeted: the crash guards (BUG-003/-004/-005/-006/-007/-009/-010/-038), the callback race
(BUG-032), sanitising, confirmations, the param metadata and the CI job. But the BUG-002 command queue adds new
safety regressions on the arm/disarm and mode paths. The BUG-033 read-back can report a mission as uploaded when it was not.
I confirmed both with small probes against MAVLinkKit (see "What I checked"). There are also two smaller real defects in the
app layer.

## Required changes

### 1. BUG-002: a superseded command keeps being retried, and the newer one waits up to 12 s (safety regression)
`Packages/MAVLinkKit/Sources/MAVLinkKit/CommandProtocol.swift:57-63`, `:110-126`

- **Problem:** When a second command with the same id arrives, it goes into `queued`. The *older* command stays in `pending`
  and keeps being resent with its own parameters until it is ACKed or runs out of attempts. Probe on the ELRS config
  (`.narrowLink`, 3 s × 4) when the ACKs are lost: ARM, then the pilot taps DISARM 0.5 s later. Result: **0 packets go out at
  the tap, the ARM is resent 3 more times, and the first DISARM leaves at t = 12.25 s.** The same happens for LOITER → RTL:
  RTL is held back while LOITER is re-commanded. Before this PR the DISARM/RTL went out at once and the ARM retries stopped.
  On a lossy link the new code can arm a vehicle *after* the pilot asked to disarm, because a late ARM retry gets through.
  TESTING_RESULTS BUG-002 "Fix" also requires: "For arm/disarm and DO_SET_MODE, always verify against the next HEARTBEAT".
  That is not implemented.
- **Fix:** When a newer command with the same id arrives:
  - Send it **immediately**. Stop retrying the old one: mark it superseded and never resend it.
  - Treat any ACK that arrives within about one timeout of the supersede as ambiguous. For `componentArmDisarm` and
    `doSetMode`, resolve the new command from the vehicle state instead: HEARTBEAT `base_mode` armed flag / `custom_mode`
    equals the request → accepted. Keep retrying the new command until that state is seen, an unambiguous ACK arrives, or
    the attempts run out.
  - Apply the "newest wins" rule only to arm/disarm and set-mode (see item 3).
  - Add a test: ARM, DISARM 0.5 s later, ARM ACKs lost → DISARM is on the wire within one tick and no ARM resend follows.

### 2. BUG-002: force-disarm can be "accepted" by the ARM's ACK and is then never retried
`CommandProtocol.swift:57-66`, `:93-99`

- **Problem:** Force-disarm overwrites `pending[400]` while an ARM is still in flight. The next COMMAND_ACK(400) is normally
  the ARM's ACK, and it completes the force-disarm. Probe: `arm(true)`, `arm(false, force: true)`, ACK(400) → `accepted`,
  `pending = []`, 0 resends. If the force-disarm packet was lost, the vehicle stays armed while the banner says
  "Arm/disarm: accepted". This is the BUG-002 failure on the one command where it matters most.
  `test_BUG002_forceDisarmGoesOutImmediately` only checks that the packet is sent.
- **Fix:** Use the same supersede path as item 1. A force-disarm that replaced a pending ARM/DISARM is confirmed only by the
  HEARTBEAT armed flag going false, or by an ACK received after the ambiguity window. Until then it is retried. Add a
  regression test for exactly this sequence.

### 3. BUG-002: the single-slot queue silently drops commands that target different things (servo, relay, motor test, REQUEST_MESSAGE)
`CommandProtocol.swift:61` (`queued[command] = msg // the newest request wins`); callers
`App/UI/FlightDataTabs.swift:115` (DO_SET_SERVO), `:159` (DO_SET_RELAY), `App/Vehicle/CalibrationStore.swift:176`
(MOTOR_TEST), `App/Vehicle/CommandCenter.swift:109-114` (REQUEST_MESSAGE).

- **Problem:** For these commands param1 says *what* is addressed: the servo channel, the relay or the motor. Probe: Servo 5,
  6 and 7 tapped quickly → **channels ever sent: [5, 7]**. Servo 6 is dropped with no message. For relays, the
  `relays`/`toggled` @State in `ServoView` then shows Relay N "ON" when it was never switched. Before the PR every tap was
  sent at least once. A second problem in the same area: `CommandCenter.command()` writes `names[command] = label` (`:73`)
  and `arm()` writes `requestedArm` (`:49`) when the command is *queued*, not when it is sent. The ACK of the first command
  is then reported with the second command's label ("Servo 7 → 1900: accepted" for servo 5). A timed-out ARM is reported
  as "no ACK, but the vehicle is now disarmed" when a DISARM is queued behind it. Nothing updates the banner when a queued
  command is released, so it can say "accepted" while the queued DISARM is still in flight.
- **Fix:** Make `queued` a FIFO per id (`[UInt16: [MAV.CommandLong]]`). Coalesce ("newest wins") only for arm/disarm and
  set-mode, or for identical param1. Keep label and requested state per pending entry, not per command id: return the
  `CommandLong` in the event, or keep a per-entry token. When a queued command is released, emit a "sending" event so
  `lastResult` says "Disarming…" again.

### 4. BUG-033: read-back by count alone confirms uploads where the vehicle kept the old final item
`Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:323-325`, `:331-336`, `:367-370`

- **Problem:** `uploadVerify` reports `.uploaded` whenever MISSION_COUNT equals the uploaded count. ArduPilot writes
  waypoint items to storage as they arrive and truncates on MISSION_COUNT. When the vehicle cancels the upload after its 8 s
  receive timeout (an ELRS dropout during the last item), it keeps items 0…n-2 from the new mission and item n-1 from the
  **old** one. That happens on the most common workflow: re-uploading an edited mission of the same or shorter length. The
  count still matches, and our next resend gets MISSION_ACK ERROR (the vehicle is "not receiving"), which this code treats
  as "verify". Probe: 3-item upload, final item lost, vehicle answers ERROR then MISSION_COUNT 3 → event
  `uploaded(count: 3)`. The pilot is told the mission is stored while the last item (often LAND/RTL) is stale. Also, in
  `.uploadVerify` a MISSION_REQUEST(_INT) for the last item is ignored, and ArduPilot answers MISSION_REQUEST_LIST with
  DENIED while it is still receiving. So a vehicle that only wanted the last item again is starved until it times out. That
  produces exactly the stale-item case above. `testUploadToArduPilotLikeVehicleSurvivesLoss` starts from an empty vehicle,
  so a count check can't fail, and it allows 3/60 failures where the acceptance criterion is 200/200.
- **Fix:** Keep `items` in `.uploadVerify`:
  - While verifying, answer MISSION_REQUEST(_INT) for an in-range seq (and go back to `.upload`). Treat MISSION_ACK 0 as
    success. Treat DENIED as "still receiving, keep waiting".
  - After MISSION_COUNT == n, request item n-1 (MISSION_REQUEST_INT) and compare command, frame, x/y/z and param1-4 with
    what was sent. Report `.uploaded` only on a match. On a mismatch, report "not confirmed: last item differs, upload
    again". On the narrow link a full read-back is an option, but the last item is the one that can be stale.
  - Extend `SimulatedMissionVehicle(arduPilotLike:)` with a pre-existing same-length mission and the 8 s receive timeout,
    and add a test where the final item is lost until the vehicle times out → must not report `.uploaded`.

### 5. BUG-012 makes the app say "Disarmed" on Disconnect, Reconnect and Replay while the vehicle is still armed
`App/Vehicle/VehicleModel.swift:215` (`armed = false` in `reset()`), `App/Vehicle/SpeechAlerts.swift:36-37` (`v.$armed` sink),
called from `App/Link/LinkManager.swift:244` (`disconnect`) and `:95`/`:103` (`startReplay`).

- **Problem:** `reset()` now sets `armed = false`. The speech observer announces every change of `armed` without checking
  that the link is live, unlike the mode observer just above it, which checks `heartbeatAlive`. `suppressLinkAlerts` only
  covers the heartbeat sink. A confirmed Disconnect/Reconnect/Replay while armed (BUG-013 path) therefore says "Disarmed"
  aloud about a vehicle that is still flying. In `startReplay`, `speech.muted = true` is set only after `disconnect()`, so
  replay says it too. This is the kind of misleading announcement BUG-025 was meant to remove.
- **Fix:** In the `$armed` sink, capture `[weak self, weak v]` and add `guard let v, v.heartbeatAlive else { return }`. `reset()` already clears
  `heartbeatAlive` before `armed`. Alternatively, mute speech around `vehicle.reset()`. In `startReplay`, set
  `speech.muted = true` before `disconnect()`.

### 6. BUG-036 edit comments out the RC-bar layout modifiers, and the capture min/max are still locale-grouped
`App/UI/SetupView.swift:466`, `:468`

- **Problem:**
  `Text(verbatim: …) // BUG-036: no locale grouping ("1.500").frame(width: 50, alignment: .trailing).monospacedDigit()`.
  The `//` comment swallows `.frame(width: 50, alignment: .trailing).monospacedDigit()`, so the PWM column loses its fixed
  width and alignment. During capture the min/max label is pushed around, and the bars jitter as values change width. It
  compiles, so neither CI nor `test_D4_radioBars` notices. Line 468, `Text("\(mins[i])–\(maxs[i])")`, still formats with
  grouping: "1.100–1.900" in el_GR, the same screen and the same bug.
- **Fix:** Use `Text(verbatim: v == 0 || v == UInt16.max ? "—" : String(v)) /* BUG-036 */ .frame(width: 50, alignment: .trailing).monospacedDigit()`,
  and `Text(verbatim: "\(mins[i])–\(maxs[i])")` on line 468.

### 7. BUG-001 TCP auto-reconnect can't be stopped from the UI
`App/Link/NetworkTransports.swift:190-193`, `:233-235`; `App/UI/ConnectView.swift:129`

- **Problem:** TCP now retries every 2 s forever ("until the user disconnects", FIX_LOG). During the retry loop the state is
  `.failed` most of the time, and `ConnectView` shows **Disconnect** only when `state.isActive` (`.connecting`/`.open`).
  So the pilot can't stop a TCP link that keeps failing. The GCS-heartbeat and control timers keep running too. The only
  way out is to press Connect, which makes a new link. UDP already behaved like this; TCP now does as well.
- **Fix:** Show Disconnect whenever a transport exists (for example
  `link.state != .disconnected || link.isReplaying`). Alternatively, report the retry phase as
  `.connecting("…: <reason> · retrying")` so `isActive` stays true. Then the Reconnect confirmation (BUG-013) also covers it.

## Optional suggestions

- `LinkManager.process` (`App/Link/LinkManager.swift:371-378`): after a quick Disconnect → Connect, `uiFlushScheduled` can
  still be true from the old generation. The first ≤ 50 ms of packets from the new link then get the old `gen` and are
  dropped. That's harmless (heartbeats repeat), but simple to fix: reset `uiFlushScheduled = false` in `disconnect()`'s
  `ioQueue.sync`, and capture `gen` per batch at append time.
- `MAVLinkParser.trackSequence` (`MAVLinkFraming.swift:233-251`): a "gap ≥ 128" also happens after a vehicle reboot or a
  long outage. `last` then stays frozen for up to 128 packets, with no loss counted. Entries in `missing` are also never
  removed when that seq comes round again in order on a later lap. That only affects the Link % figure. Consider resyncing
  when several consecutive packets fall in the "behind" half, and removing the seq from `missing` on in-order receipt.
- Fly-here (BUG-011): the acceptance text says "retry twice on timeout, and show the result". With no MISSION_ACK the
  banner stays "Fly here: sent …" forever and nothing is retried. Add a 3-5 s timeout message, or a resend. The 5 s
  interception window in `MissionStore.handle` (`:150`) can also take the MISSION_ACK of an unrelated idle-time operation
  (for example `clearAll`) as the guided answer. Clear `guidedSent` when another mission operation is sent.
- BUG-026: a replay that fails to load leaves `isReplaying = false`, but the replay transport and timers keep running until
  the next connect. Consider calling `disconnect()`.
- `.github/workflows/build-sideloadly-ipa.yml:45-48`: the comment "Runs the real app in the iPad Simulator …" now sits above
  the new `break-test` job instead of `simulator`. Move it. `-j 3` timing-sensitive scenarios on the 3-core hosted runner
  may be flaky. If they are, retry once, or use `-j 2`.
- `MissionTests.testUploadToArduPilotLikeVehicleSurvivesLoss` tolerates 3/60 failures. Once item 4 is fixed, make it
  deterministic (seeded RNG) and require 0 failures, as the acceptance criterion asks.
- The FIX_LOG/PR text "force-disarm is never delayed" is true but incomplete until item 2 is fixed. Say how it is confirmed.

## What I checked

- Read the full diff of every changed Swift file under `App/` and `Packages/`, plus `tools/gen_param_meta_ardupilot.py`
  (skimmed), `project.yml` and the workflow. Read the whole of `CommandProtocol.swift`, `CommandCenter.swift`, the
  `MissionSession` state machine, `NWClientTransport`, and LinkManager connect/disconnect/wire/process/apply, against the
  BUG-0xx causes and acceptance criteria in TESTING_RESULTS.md.
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 55 tests, 0 failed`.
- **Harness + CI scenario set:** `testing/harness/build_harness.sh` built OK, and `python3 testing/scenarios/run.py -j 3 ci`
  → `TOTAL 88: PASS=88, FAIL=0`, exit 0 (fake drone on localhost only). The scenarios don't catch items 1-4,
  because the fake drone ACKs every command and re-ACKs mission items.
- **Probes** (scratch Swift package against MAVLinkKit, not committed):
  1. `.narrowLink`, ARM, DISARM 0.5 s later, ACKs lost → DISARM sent 0× at the tap, ARM resent 3×, first DISARM at
     t = 12.25 s.
  2. DO_SET_SERVO channels 5, 6, 7 tapped quickly → channels sent: [5, 7].
  3. ARM, force-disarm, ACK(400) → `accepted`, pending empty, 0 resends.
  4. 3-item upload, final item lost, then ERROR, then MISSION_COUNT 3 → `uploaded(count: 3)`.
- **Threading:** transport callbacks are now immutable after `wire()`, and generations are checked on both ioQueue and main.
  `uiBatch`/`uiFlushScheduled`/`ioGeneration` are only touched on ioQueue. There is no `DispatchQueue.main.sync` from
  ioQueue, so the `ioQueue.sync` in `wire()`/`disconnect()` can't deadlock. Closures use `[weak self]`, and
  `CommandCenter.vehicle` is `weak`. I found no retain cycles.
- **iOS 16 / compile:** the added code uses no API newer than iOS 16 (`overlay(alignment:content:)` iOS 15, `LabeledContent`
  iOS 16, `if let x` shorthand needs Swift 5.7 / Xcode 14+, `let` inside ViewBuilder needs Swift 5.4+). The Link/Vehicle/Storage
  sources compile for macOS in the harness. The UI files compile only in Xcode CI. I saw no compile risk in them (struct
  closures that capture `self` implicitly are fine since SE-0269).
- **TCP reconnect:** a double `retryLater` (state `.failed` plus `isComplete`) is safe because of the generation check.
- **ParamMeta JSON:** same key set (`a b d i n r rb ro u v`) and value types as `main` for all 5 vehicles. No parameter
  names were lost, and the counts went up (Copter 3136 → 6209).
- **CI job:** paths match `build_harness.sh`/`run.py` (`ci` = all non-long, non-SITL scenarios plus probes). It needs only
  python3 stdlib and Swift. Logs are uploaded on failure, and the default `contents: read` token is enough.
