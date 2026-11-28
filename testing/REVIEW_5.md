# Review 5: PR #1 `bug_fixes` → `main` (re-review after `fd0011e`)

Reviewer: independent senior review (Claude), 2026-11-28. HEAD is `fd0011e`. Scope:
- the REVIEW_4 required change in `CommandProtocol.swift`, the rest of `CommandSession`, and how
  `App/Vehicle/CommandCenter.swift` uses it;
- `git diff 8931fcb..HEAD` (CommandProtocol, BreakTestRegressionTests, MissionTests).

Items marked known/partial in TESTING_RESULTS.md §9 are not raised again.

## Verdict

**CHANGES REQUIRED** (1 required change)

The REVIEW_4 defect is fixed: an unsent released command can no longer be resolved by an ACK. The optional window
that came with it has a side effect that the tests miss. Once any command in a queue has been resent, every later
command in that queue is sent twice, even when the link is clean again (required change 1). On a clean link with
nothing resent, each command still goes out once, and nothing gets stuck.

## Status of the REVIEW_4 item

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | A duplicate ACK resolves a released queued command before it is sent | **Resolved** (see required change 1 for a side effect) | `CommandProtocol.swift:129`: `if p.attempts == 0 { return [] }` comes before the window and result checks, so an unsent entry can't be accepted, rejected or marked in progress. `:95`: `confirmByState` now also needs `attempts > 0`. That only matters for arm/mode, which are never queued, so it is defensive. `:103-108`: `releaseQueued(_:previousResent:)` stores `afterResend`. It is called with `p.attempts > 1` after accept (`:135`), reject (`:142`) and state confirm (`:97`), and with `true` after a timeout (`:155`). `:160`: the first send of an `afterResend` entry sets `ambiguousUntil = now + min(0.5, timeout/3)`, which is 0.5 s for both configs. The REVIEW_4 E2 scenario is fixed: the duplicate at 1.60 is ignored, servo 6 goes out at the next tick, and probe D1 confirms it. The test `test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand` matches the scenario. |

## Required changes

### 1. After one resend, the review-4 window double-sends every later queued command (it cascades)
`Packages/MAVLinkKit/Sources/MAVLinkKit/CommandProtocol.swift:135, 142, 155, 160`

- **Mechanism:**
  1. Command N's predecessor was resent, so N gets the 0.5 s window on its first send.
  2. On a normal link, N's own ACK comes back inside 0.5 s (ELRS round trips are about 0.1–0.6 s), so it is
     ignored.
  3. N is resent at `timeout` and resolved by the second ACK with `attempts == 2`.
  4. `releaseQueued(previousResent: true)` then gives N+1 the window as well, and the same thing happens again.

  So one lost packet, or one timed-out command, makes every remaining command in that queue go out twice, and the
  link never has to be lossy again. The same thing happens after a timeout (`:155` always passes `true`): when the
  vehicle comes back, the commands after it are all doubled.
- **Scenario:** on the setup page the pilot taps motor test A, B, C, D (MAV_CMD_DO_MOTOR_TEST 209, queued:
  `CalibrationStore.swift:198`). Take photo (203) or relay/servo taps behave the same way. Motor A's first ACK is
  lost. A is resent, and then B, C and D each start twice, `timeout` apart (3 s on ELRS). With a test duration
  under 3 s, each motor stops and then spins up again on its own. Two photos are taken per tap. REVIEW_3 treated
  this kind of double send as the worse failure.
- **Probe C1** (default config, clean link with a 0.2 s round trip, only servo 5's first ACK lost, servos 6–8
  queued):

  | Variant | Sends |
  |---|---|
  | HEAD | `5@0 5@1.5 6@1.75 6@3.25 7@3.5 7@5.0 8@5.25 8@6.75` |
  | Window removed (only the `attempts == 0` guard) | `5@0 5@1.5 6@1.75 7@2.0 8@2.25` |

- **Monte Carlo** (4 queued commands per run; extra executions on the vehicle / runs where a command was accepted
  but never executed):

  | Scenario | HEAD | Window removed | Window only while a send is unanswered |
  |---|---|---|---|
  | 10 % loss, 20–100 ms one way, default config, 2000 runs | 2478 / 0 | 747 / 0 | 1850 / 0 |
  | 30 % loss, 0.1–0.3 s one way, narrowLink, 2000 runs | ~4900 / 0 | 2692 / 0 | ~4600 / 0 |
  | Vehicle silent for 5 s, then clean, 200 runs | 400 / 0 | 0 / 0 | 200 / 0 |
  | Jitter 0.1–1.0 s, 10 % loss, 2000 runs | ~1690 / ~75 | ~1590 / ~105 | ~1690 / ~76 |
  | ACKs bunched into 2 s buckets, 500 runs | ~1730 / 1–2 | ~1720 / 2–3 | ~1720 / 0 |

  The window adds a lot of double executions. It only slightly reduces mis-attributed accepts, and only on links
  with jitter around the timeout. When ACK latency is constantly above `timeout`, the duplicate arrives about one
  `timeout` after the first ACK, well outside 0.5 s, so the window doesn't catch it (probe D1, 0 of 200 caught in
  the "latency > timeout" scenario).
- **Fix:** either of these.
  - **(a) Drop the window and keep the `:129` guard.** This is the simplest and has the fewest double sends: remove
    `:160` and `afterResend`. Then relax the `1.8` "third copy" step in
    `test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand`.
  - **(b) Stop the cascade.** Record when an ACK is ignored inside the window, for example a flag set at `:131`
    when `now < p.ambiguousUntil`. That ACK already answers the send, so the resend it causes leaves no duplicate
    behind. In that case release the next command with `previousResent: false`, for example
    `p.attempts > 1 && !p.ignoredAckInWindow`, and do the same at `:155`. Only the first command after a real
    resend is then doubled, never the whole queue.
- **Test:** queue servos 5–8 on a clean link with a 0.2 s round trip and drop only servo 5's first ACK. Servos 7
  and 8 must be sent exactly once each, and so must servo 6 with (a). Add a second case where servo 5 times out
  with no answer and the link then recovers: servos 7 and 8 must again go out once each.

## Optional suggestions

1. **COMMAND_ACK has no request id.** A duplicate that comes from latency, not loss, can still resolve the next
   queued command early (probe D1, and the jitter row above, under every variant). This is inherent, so documenting
   it next to `supersedable` is enough. The item is still sent, so only the banner timing is wrong, unless that one
   send was lost.
2. **The new one-item rally test, like the fence test it copies, only asserts "not `uploaded`".** A hang or an
   unrelated failure would also pass. Asserting a `.failed` event whose text contains `differs` would pin the
   verify path down.
3. **`CommandCenter.requestMessage`** (`CommandCenter.swift:146-152`) goes through the session queue but doesn't
   push to `labelQueue`. `quiet` is a `Set`, so if two requests overlap (`LinkManager.swift:350` and
   `ActionsView.swift:199`), the second result shows a "Request message: accepted" banner. This is a cosmetic nit.

## What I checked

- **Code:** all of `CommandProtocol.swift`, at HEAD and in the diff, and all of `CommandCenter.swift`.
  - `labelQueue` pops on accepted, rejected and timedOut, which matches each `releaseQueued` call site. An ACK
    ignored at `:129`/`:131` produces no event, so there is no label pop either.
  - `abandonPending` clears the label and `sentAt` state.
  - `confirmFromVehicleState` only handles arm/mode, and `markSent` runs after the session call, so it sees the
    supersede window.
  - Supersedable arm/mode is unchanged: replaced at once with `ambiguousUntil = now + timeout`, never queued, and
    resent at `lastSent + timeout`. Probe A1 (arm, then disarm 0.1 s later): the arm ACK is ignored, the disarm is
    resent at 1.6 and accepted at 1.75, and no ARM is sent after the DISARM. Probe A2 (arm, disarm, arm within
    0.1 s): the newest one is in flight, with a 1.5 s window.
  - `tick` iterates over a copy of `pending`, so a release made while the loop runs is sent on the next tick.
- **Diff `8931fcb..HEAD`:**
  - The SplitMix64 constants are correct, and `Double(z >> 11) / 2^53` lies in [0, 1).
  - Per-run seeds and `LOSSY_RUNS` are fine.
  - The new regression test steps match the session logic.
  - The rally test is set up like the fence test (`stored[2]`, `dropSeq = 0`, writeThrough truncates rally).
  - I found no correctness bugs in the tests.
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 63 tests, 0 failed`.
- **Fake-drone CI set:** `build_harness.sh` + `run.py -j 4 ci` → `TOTAL 88: PASS=88, FAIL=0, CRASH=0, ERROR=0,
  SKIP=0`. This ran on localhost only: no SITL, no UI and no hardware.
- **Probes:** a scratch package outside the repo, linked against MAVLinkKit, with a discrete-event vehicle: per-way
  loss, latency, ACK bunching, the first ACK rejected, the vehicle silent for N s, and a 4 Hz tick. Variants
  compared: HEAD, HEAD without `:160`, and HEAD with "window only while a send is unanswered".
  - In every scenario, including a dead link and reject-then-release, there were **0 commands never sent**, **0
    sessions left pending**, and every queued label got an outcome.
  - On clean links (P1/P2, 400 runs) there were **0 double sends**.
  - The double sends and mis-attributed accepts are as tabled above.
