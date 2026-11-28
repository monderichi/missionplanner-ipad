# Review 4: PR #1 `bug_fixes` → `main` (re-review after `4e8fd39`)

Reviewer: independent senior review (Claude), 2026-11-28. HEAD is `8931fcb`. Scope:
- the REVIEW_3 required items 1–2 and the optional item that was taken (the queued-command ACK window);
- `git diff fcbf36e..HEAD -- Packages App .github testing/harness testing/scenarios/run.py`.

Items marked known/partial in TESTING_RESULTS.md §9 are not raised again.

## Verdict

**CHANGES REQUIRED** (1 required change)

Both REVIEW_3 required items are fixed and hold up under probing. I found no false "uploaded" report in 900 lossy
fence/rally uploads. One gap remains in the queued-command path that the optional change touched: a stale duplicate
ACK can resolve a released queued command. If that ACK lands before the command's first send, the command is never
sent and is still reported `accepted`. This was already possible before `4e8fd39` (the old window opened only at
the first send), so it is not new. Removing the window widened it, and it is a one-line fix.

## Status of REVIEW_3 items

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | One-item fence/rally uploads were confirmed by count alone | **Resolved** | `MissionProtocol.swift:347`: the shortcut now needs `type == .mission`. One-item fence and rally lists go on to `:355`, where `first` = 0 for both, and they are read back. Probes A1–A4 (single circle moved, single exclusion circle with only the radius changed, single rally point moved, single rally point with only the altitude changed; item lost until the vehicle times out) all end in `failed("Not confirmed: … item 0 differs")`. A5/A6 (clean link) end in `uploaded`. A7/A8 (home-only mission, clean, and with the item lost) still end in `uploaded`, the clean one at t = 0.25 s. 0-item uploads can't reach verify: `lastRequested` is nil, so `nil == -1` is false at `:326` and `:440`. Unit test `MissionTests.swift:186`. |
| 2 | Fence read-back ignored `param1` | **Resolved** | `MissionProtocol.swift:403-408`: circles (5003/5004) are compared with a ±1 m tolerance on `param1`, and every other fence command is compared exactly. That covers polygon vertex counts, and a return point gets 0 = 0. Probes: B1 (4-vertex polygon plus a circle as the last item, radius 50 → 20, last item lost) → `failed(… item 4 differs)`. REVIEW_3 P1 gave `uploaded` here. B2 (circle first, then a polygon) → fails at item 0. B3 (6-vertex polygon split into 3+3 with the same coordinates) → fails at item 0. `sameItem` gives 20.0 vs 20.6 → true (integer storage), 20 vs 22 → false, 3 vs 4 vertices → false. A NaN radius is never treated as the same item, so the result is a safe failure. |
| opt. 1 | ACK window for released queued commands removed | **Done, no double send; see required change 1** | `CommandProtocol.swift:152-158`. Probe E1 (ACK after 20 ms): servo 5 is sent at 0.00 and servo 6 at 0.05, once each, both `accepted` (REVIEW_3 P2 sent servo 6 twice). The supersede logic is unchanged: the arm/mode replace with `ambiguousUntil = now + timeout` (`:74-80`), `confirmByState` gated by the window (`:92`), and stale ACKs ignored inside the window (`:126`). Arm and mode are never queued, so this change does not affect them. A queued command can't get stuck: `releaseQueued` sets `lastSent = -inf`, the next 4 Hz tick sends it, and it then retries and times out normally (`:145-150`). |

## Required changes

### 1. A duplicate ACK of the previous command can resolve a released queued command, even one that was never sent
`Packages/MAVLinkKit/Sources/MAVLinkKit/CommandProtocol.swift:100-105, 123-131`

- **Scenario:**
  1. The pilot taps servo 5 and then servo 6 (or relay, motor test, take photo). Both use the same command id, so
     servo 6 is queued.
  2. Servo 5's ACK is delayed past `timeout` on a congested ELRS link, so servo 5 is resent.
  3. Both ACKs then arrive close together. The first one accepts servo 5 and `releaseQueued` makes servo 6 pending
     with `attempts = 0`, still unsent until the next 4 Hz tick. The second ACK, a duplicate for servo 5, finds that
     pending entry with `ambiguousUntil = -inf` and accepts it.
  4. Servo 6 is never transmitted, and the banner says "Servo 6: accepted".
- **Probe E2:** ACKs arrive 100 ms after each send, and the first one is 1.5 s late. Sends:
  `servo5@0.00(c0), servo5@1.50(c1)`. Events: `accepted@1.60, accepted@1.60`. Servo 6 is never sent within 12 s.
- **History:** before `4e8fd39` the same thing happened if the duplicate came before the first tick. After the first
  send it was shielded by the window, which is now gone, so the duplicate also "confirms" a servo 6 send that may
  have been lost.
- **Effect:** a payload release, gripper or relay command is reported done when it is not.
- **Fix:** in `handle(_:now:)`, ignore ACKs for a pending entry that hasn't been sent yet:
  `if p.attempts == 0 { return [] }`. That ACK can't be for it. Optionally, restore the window only when the
  resolved predecessor was resent, as REVIEW_3 optional item 1 suggested: pass `attempts > 1` into `releaseQueued`
  and set `ambiguousUntil = now + min(0.5, timeout/3)` on the first send in that case only. A fast link then still
  sends each command once.
- **Test:** queue servo 5 and 6, resend 5, deliver two ACKs for 183, then tick. Servo 6 must be sent, and must not be
  `accepted` before it is sent.

## Optional suggestions

1. `MissionTests.testSingleFenceCircleAndRadiusChangeAreVerified` covers fence only. Adding a one-item rally case
   (moved point, `dropSeq = 0`) would pin down the rally half of REVIEW_3 item 1. Probe A3/A4 shows that it works.
2. Probe-writing note, not a code issue: `SimulatedMissionVehicle` answers with the items exactly as stored. A test
   that seeds `stored` with items whose `seq` is left at 0 makes verify loop on "wrong seq" until it times out
   (`No answer from vehicle`). The existing tests seed correctly numbered items. Renumbering in the sim
   (`stored[t]![i].seq = i` on reply) would make it harder to misuse.

## What I checked

- **Code:** read the `MissionSession` upload / verify / `tick` paths (`MissionProtocol.swift:267-460`) and all of
  `CommandProtocol.swift`. I also read the `CommandCenter` ACK / tick / apply path and the LinkManager 4 Hz control
  timer (`LinkManager.swift:325-333`). I read the fence numbering in `MissionStore.numberFenceGroups`: param1 is the
  vertex count, which is what ArduPilot returns.
- **Post-REVIEW_3 diff:** `4e8fd39` (CommandProtocol, MissionProtocol, MissionTests), `ec0f60d`/`8931fcb`. The rest is
  test-only:
  - the harness `dataflashFuzz` was split out and typed, with the same logic;
  - `-solver-expression-time-threshold` was added for the harness target only;
  - the reconnect param wait went from 30 to 90 s;
  - `run.py` log names drop `:`. Only harness/proxy/drone log names used `key`, the SITL logs use the SITL name, and
    `testing/logs/` is what CI uploads.

  Nothing changed in `App/` or `.github/`.
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 61 tests, 0 failed`.
- **Fake-drone CI set:** `testing/harness/build_harness.sh` built OK. `HARNESS_BIN=… run.py -j 4 ci` →
  `TOTAL 88: PASS=88, FAIL=0, CRASH=0, ERROR=0, SKIP=0` (localhost only; no SITL, UI tests or hardware).
- **Probes:** a scratch package outside the repo, linking MAVLinkKit and a copy of the repo's
  `SimulatedMissionVehicle` (`arduPilotLike` + `writeThrough`, narrowLink):
  - A1–A8 and B1–B3 as in the table above.
  - C1: 900 uploads at 30% loss each way (single circle moved and resized, single rally point moved, polygon plus
    circle moved and resized): 767 `uploaded` with the vehicle holding the new items, 133 `failed`, **0 false
    `uploaded`**.
  - D1–D4: `sameItem` tolerances.
  - E1/E2: queued servo commands on a fast link and with a duplicate ACK (required change 1).
