# Review 6: PR #1 `bug_fixes` → `main` (re-review after `a9223d8`)

Reviewer: independent senior review (Claude), 2026-11-28. HEAD is `a9223d8`. Scope: the REVIEW_5 required change in
`CommandProtocol.swift`, and `git diff fd0011e..HEAD` (CommandProtocol, BreakTestRegressionTests, workflow). Known items in
TESTING_RESULTS.md §9 and the accepted COMMAND_ACK-has-no-request-id limit are not raised again.

## Verdict

**APPROVED**

The post-resend window is gone, the review-4 unsent guard is kept, and the new test fails on the previous code and
passes on HEAD. I found no correctness defects in the diff.

## Status of the REVIEW_5 item

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | The post-resend ACK window cascaded double sends down the queue | **Resolved** | `CommandProtocol.swift:33-40`: `Pending` no longer has `afterResend`. `:100-105`: `releaseQueued(_:)` takes no flag, and the released entry is `attempts: 0, lastSent: -.infinity` with the default `ambiguousUntil = -.infinity`. `:153-162`: the resend branch no longer sets `ambiguousUntil`, so a released command's own fast ACK resolves it. `ambiguousUntil` is now set only by the supersede path (`:78`, arm/mode). Guards kept: `handle` `:126` (`attempts == 0` → ignore) before the window check `:128` and the result switch; `confirmByState` `:92` (`attempts > 0`, `now >= ambiguousUntil`). The supersedable path `:74-80` is unchanged (replace at once, never queued, window = one timeout). No leftover references to `afterResend`/`previousResent` in `App/` or `Packages/`. |

**Does the new test exercise the cascade?** Yes. `BreakTestRegressionTests.swift:93-118` queues servos 5–8 on a 0.2 s
round trip with a 4 Hz tick, loses servo 5's first ACK (or all of them, so it times out), and asserts 6, 7, 8 go out
exactly once and nothing is left pending. I ran the HEAD test file against `fd0011e`'s `CommandProtocol.swift` in a
scratch copy: it fails for both cases, with `sent = [5,5,6,6,7,7,8,8]` (lost ACK) and `[5,5,5,6,6,7,7,8,8]`
(timeout). That is exactly the REVIEW_5 probe C1 cascade. On HEAD it passes. The edit to
`test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand` (`:75-89`) only drops the "third copy inside the window"
step, which no longer applies. The duplicate-before-send case at `:82-83` still checks the `:126` guard.

## Required changes

None.

## Optional suggestions

1. **Merging to `main` triggers `build`.** The workflow still runs `build` (macOS) on `push` to `main` and on
   `pull_request` (`build-sideloadly-ipa.yml:3-9`). `[skip ci]` on branch commits doesn't cover the merge commit. If
   minutes are still at zero, put `[skip ci]` in the merge commit message, or expect that run to fail or queue. This is
   operational, not a code defect.
2. **Comment.** The `Pending.ambiguousUntil` doc comment (`CommandProtocol.swift:37-38`) could say it is now set only
   on supersede (arm/mode). This is a nit.

## What I checked

- **Code:** all of `CommandProtocol.swift` at HEAD.
  - Every resolution path (accept, reject, timeout, state confirm) calls `releaseQueued`, and `inProgress` keeps
    waiting.
  - `tick` iterates over a value copy of `pending`, so a release made during the loop goes out on the next tick with
    `confirmation = 0`.
  - With `config.attempts ≥ 1`, a released entry is always sent before it can time out.
  - `CommandCenter.swift:94` still uses `ambiguityRemaining`, which is correct (0 for released entries).
- **Workflow:** it parses as YAML (PyYAML): jobs `build`, `break-test`, `simulator`, with no `needs:`.
  - `break-test` has `if: github.event_name == 'workflow_dispatch'`.
  - `build` has no `if:`, and its triggers and steps are unchanged.
- **Unit tests:** `testing/unit/run_unit_tests.sh` → `RESULT: 64 tests, 0 failed`.
- **Fake-drone CI set:** `build_harness.sh` + `run.py -j 4 ci` → `TOTAL 88: PASS=88, FAIL=0, CRASH=0, ERROR=0, SKIP=0`.
  This ran on localhost only: no SITL, no hardware and no Actions.
- **Mutation check:** the HEAD tests against `fd0011e`'s `CommandProtocol.swift` gave 1 failure, the new test, in both
  of its cases.
- **Scratch probes** (outside the repo, linked against HEAD MAVLinkKit; both passed):
  - **Clean link, queued commands:** 5 queued motor tests (209), default and narrowLink configs, round trip
    0.05 s … timeout−0.3 s in 0.05 s steps, all accepted or all rejected, ACKs delivered between 4 Hz ticks. Each
    command was sent exactly once, there was one event per command, and nothing was left pending.
  - **Arm then disarm:** gaps of 0.05–1.4 s, 0.2 s round trip. No ARM was sent after the first DISARM, and nothing was
    left pending.
