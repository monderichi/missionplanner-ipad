# Review 3: PR #1 `bug_fixes` → `main` (re-review after `7586209`)

Reviewer: independent senior review (Claude), 2026-11-28. Scope: REVIEW_2 required items 1–2 in code, the fix commit
`7586209`, and a quick pass over `git diff 85e7f2d..HEAD -- App Packages .github`. HEAD is `fcbf36e`; after `7586209`
only `testing/harness/Sources/Probes.swift` and `testing/AUTONOMOUS_PLAN.md` changed (CI type-check fix), so no app or
package code changed after it. Items marked known/partial in TESTING_RESULTS.md §9 are not raised again.

## Verdict

**CHANGES REQUIRED** (2 required changes, both small and in the same mission read-back path)

REVIEW_2 item 1 (heartbeat confirmation of a superseding arm/mode command) is fixed. REVIEW_2 item 2 (fence read-back)
is fixed for the case it described: a moved polygon vertex. Two gaps remain in the same verify step. In each one the
session reports a geofence or rally upload as `uploaded` while the vehicle still holds the old one:

1. A **one-item** fence or rally upload skips the read-back entirely. This is a shortcut that was meant only for a
   home-only mission.
2. The fence read-back ignores `param1`, so a changed **circle radius** is never noticed.

Both were reproduced with a probe against MAVLinkKit (see "What I checked").

## Status of REVIEW_2 required items

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Stale heartbeat confirms a superseding arm/disarm or mode command | **Resolved** | `CommandProtocol.swift:89-96`: `confirmByState(_:now:)` returns `[]` while `now < ambiguousUntil`. `CommandCenter.swift:92-95`: `markSent` sets the earliest confirming heartbeat time to `max(0.3 s, ambiguityRemaining)`, and it is called *after* `session.arm`/`setMode`, so it sees the new `ambiguousUntil = now + timeout` (`CommandProtocol.swift:78`). `confirmFromVehicleState` (`:104-113`) needs `hb >= after` **and** the session check. Both use the same clock (`systemUptime` for the session, `Date()` for heartbeats, compared only as offsets). Plain (non-superseding) commands keep `ambiguousUntil = -inf`, so the 0.3 s rule is unchanged for them. No stuck state: the superseding command is resent by `tick` at `t1 + timeout` (`now - lastSent >= timeout`), an ACK after the window is accepted (`:126`), the next heartbeat after the window confirms by state, and otherwise it times out after `attempts` and BUG-017 reports the real state. Probe P3 (narrowLink, ARM at 0, DISARM at 1.0): `confirmByState@1.4 = []`, `ambiguityRemaining@1.0 = 3.0`, DISARM (param1 0) resent at 4.0, `confirmByState@4.1 = accepted`. The unit test `test_BUG002_forceDisarmNotAcceptedByArmAck` covers this at session level. |
| 2 | Fence verify by last item only; ArduPilot keeps the whole old fence on timeout | **Partially resolved** | `MissionProtocol.swift:353`: for `.fence` the verify starts at item 0. `:359-375` reads every item in order (`next`), compares each one with `sameItem`, ignores late replies for other seqs (`Int(it.seq) == next`), and `tick` resends the current request with the usual retry limit (`:442-444`). Missions and rally keep the last-item check. `testFenceUploadNotConfirmedWhenVehicleKeptOldFence` passes, and the simulated vehicle now stages fences (`MissionTests.swift:53, 71`). Two gaps remain (required changes 1 and 2): one-item uploads never reach this code, and circle radius is not compared. |

The optional REVIEW_2 items that were taken are correct:
- The old link's 50 ms flush now returns without touching `uiBatch`/`uiFlushScheduled` (`LinkManager.swift:379`).
  This is safe because `connect` and `startReplay` always call `disconnect()` first, which resets both under `ioQueue.sync` (`:236-239`).
- `heartbeatAlive` is set before `armed` (`VehicleModel.swift:308-313`).
- The clamped `Int()` calls (`FlightDataTabs.swift:174`, `RoverSetupPage.swift:27`) come after the `isFinite` guards.
- Rally altitude is compared with ±1 m.
- Non-location mission items are compared by command only.

The queued-command ACK window has a side effect, see optional suggestion 1.

## Required changes

### 1. One-item fence/rally uploads are confirmed by count alone
`Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:345`

```swift
if Int(c.count) == items.count && items.count <= 1 { // home only: ArduPilot rewrites home itself
    op = .idle
    return ([ack(type)], [.uploaded(type: type, count: items.count)])
}
```

- **Problem:** The shortcut comes from `ab78340` and is meant for a mission that holds only home. It does not check
  `type`, so it also applies to a fence or rally list with exactly one item. Examples: one inclusion circle, or the very
  common single rally point. When that item is lost until the vehicle times out, our resend gets ERROR, which leads to
  verify. MISSION_COUNT is 1 on both sides, and the session reports `uploaded` without reading anything back.
  - Fence: ArduPilot keeps the whole old fence on timeout.
  - Rally: ArduPilot writes item by item, so the old point stays.
  - Probe P4, with the single item moved by about 7 km: `uploaded(type: fence, count: 1)` and
    `uploaded(type: rally, count: 1)`, while the vehicle still holds the old coordinates. The pilot is told the new
    geofence or rally point is active when it is not. This is the failure REVIEW_2 item 2 and REVIEW_1 item 4 were meant to close.
- **Fix:** Apply the shortcut only to `type == .mission`, so fence and rally always read their items back. Add a unit
  test with a one-item fence and a one-item rally (item moved, `dropSeq = 0`, `writeThrough`) that must not report `uploaded`.

### 2. Fence read-back ignores `param1`, so a changed circle radius (or polygon split) is confirmed
`Packages/MAVLinkKit/Sources/MAVLinkKit/MissionProtocol.swift:396-400` (`sameItem`)

- **Problem:** For `.fence`, `sameItem` compares the command and x/y only. On a fence item, `param1` carries data that
  ArduPilot does store and return:
  - the circle radius (5003/5004), which PlanView edits as "Radius (m)" (`PlanView.swift:441`);
  - the polygon vertex count (5001/5002).

  If a radius-only edit times out on the vehicle, every item read back matches, and the session reports `uploaded`.
  Probe P1: 4-vertex inclusion polygon plus an exclusion circle (last item), radius changed from 50 to 20, last item
  lost until timeout → `uploaded(type: fence, count: 5)` with the vehicle still at radius 50. Probe P1b (a single
  circle) gives the same result, but it goes through required change 1 first. A shrunk exclusion zone or a grown
  inclusion circle would be reported active while the old one is enforced.
- **Fix:** For `type == .fence`, also compare `param1`:
  - exactly for the polygon commands (the vertex count);
  - with a tolerance of about 1 m for the circle commands, because older ArduPilot storage keeps the radius as a whole number.

  Extend `testFenceUploadNotConfirmedWhenVehicleKeptOldFence` with a radius-only edit of a circle that is the last item.

## Optional suggestions

1. **Released queued commands are always sent twice when the round trip is under 0.5 s** (`CommandProtocol.swift:154`).
   The window is opened for every released command, not only when the predecessor was resent, so on USB, TCP or Wi-Fi
   the command's own first ACK lands inside it and is discarded.
   - Probe P2 (default config, ACK 20 ms after each send): servo 5 at 0.00, servo 6 at 0.02, and servo 6 again at 1.52.
   - This is harmless for servo, relay and REQUEST_MESSAGE. It does repeat `DO_MOTOR_TEST` (209: ArduCopter restarts the
     test timer and sequence, so the motor spins about `timeout` longer), and also take-photo and start/stop-video when
     one of them was queued.
   - It also spends one of the retries.
   - It only happens when the pilot taps a second command with the same id while the first is still in flight, so it is
     rare on fast links.
   - Fix: when `releaseQueued` runs, remember whether the resolved predecessor had `attempts > 1` (only then can a
     duplicate ACK exist), and open the window only in that case. A predecessor that was resent keeps the window, as now.
2. **App-layer coverage for item 1:** the `hb >= after` guard in `CommandCenter.confirmFromVehicleState` is only tested
   through the session API. If the break-test harness can drive `CommandCenter`, a scenario with ARM, then DISARM at
   +1 s, then a "disarmed" heartbeat at +1.4 s (must not confirm) and another at +4.1 s (confirms) would pin it down.
3. **Stale doc comment:** `CommandCenter.swift:103` still says "Only a heartbeat received ≥ 0.3 s after the send
   counts". It should mention the ambiguity window, as `markSent` does.

## What I checked

- **REVIEW_2 items:** read all of `CommandProtocol.swift` and `CommandCenter.swift`, and the `MissionSession` upload,
  verify and tick paths. I read the whole `git show 7586209 -- App Packages` diff (CommandCenter, CommandProtocol,
  MissionProtocol, VehicleModel, LinkManager, FlightDataTabs, RoverSetupPage, tests). I looked for stuck states and
  endless retries: superseding commands are resent and time out normally, and fence read-back steps reset `attempts`
  per item and end in `failed` after `retries`. The new window can't make confirmation impossible, because only the
  first send opens it and resends come after `timeout` > window. I also checked
  `git diff 7586209 HEAD` (harness `Probes.swift` and the plan only).
- **Fresh pass:** the 7586209 delta and the connect/disconnect/wire/process/flush generation logic in `LinkManager`.
  The earlier 85e7f2d..ab78340 diff was covered by REVIEW_2 and nothing in it changed except the lines above.
  I found no new API above iOS 16, and nothing new that is hard to type-check in `App/` (the CI type-check fix touched
  only the harness).
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 60 tests, 0 failed`.
- **Fake-drone CI set:** `testing/harness/build_harness.sh` built OK; `run.py -j 3 ci` →
  `TOTAL 88: PASS=88, FAIL=0, CRASH=0, ERROR=0, SKIP=0` (localhost only; no SITL, no UI tests, no hardware).
- **Probes** (scratch package outside the repo, linking MAVLinkKit and the repo's `SimulatedMissionVehicle` with
  `arduPilotLike` + `writeThrough`):
  - P1: fence polygon + circle, radius-only edit, last item lost → `uploaded(fence, 5)` (required change 2).
  - P1b: single circle, radius edit → `uploaded(fence, 1)` (required changes 1 and 2).
  - P2: queued servo on a fast link → servo 6 sent twice (optional suggestion 1).
  - P3: ARM, then DISARM at +1 s on narrowLink → no confirmation inside the window, resend at +4 s, confirmed after it
    (item 1 resolved).
  - P4: one-item fence and one-item rally, item moved, lost until timeout → `uploaded(…, 1)` for both (required change 1).
