# Review R3-2: follow-up to R3-1 (bug_037_split_model, uncommitted)

Scope: the deltas after R3-1. These are `App/Vehicle/VehicleModel.swift` (`lastHeartbeat` no longer `@Published`,
assign-if-changed heartbeat fields, `pendingMessages` + `flushMessages(force:)`, and the `messageCounts` comment),
`App/Vehicle/SpeechAlerts.swift` (the `$messages` sink with `lastMessageID`), `testing/FIX_LOG.md` "Round 3" and
`TESTING_RESULTS.md` section 9 (BUG-037 row). Read only, not compiled (Windows).

**APPROVED**

**Re-check (after the fix).** Required change 1 is applied correctly.
- `VehicleModel.swift:215-217`: the first line of `reset()` is now `flushMessages(force: true)`, tagged BUG-037 (round 3) / BUG-025 with the reason.
- Every `reset()` caller is covered:
  - `startReplay` mutes first (`LinkManager.swift:95`), and its `disconnect()` → `reset()` then flushes while muted. The second `reset()` at `:104` finds an empty buffer.
  - `connect()` → `disconnect()` → `reset()` runs before `open()` unmutes (`:187`), so a replay's tail is published while still muted and is never spoken.
  - A plain Disconnect now shows the tail in Messages at once.
- The `pendingMessages` comment (`:87-90`) now says "within about a second" and "reset() flushes the buffer".
- FIX_LOG has the `reset()` line (`testing/FIX_LOG.md:143`).

Optional notes 1–6 below still stand as notes. Nothing else is required. The macOS checks below must still pass before the merge.

## Required changes (original review; now resolved)

1. **Buffered STATUSTEXT survives `reset()`. It is later published, and spoken, as if it came from the new link.**
   (`VehicleModel.swift:212-245` `reset()` does not touch `pendingMessages`; `:283` `tick()` flushes them.)
   - **Problem.** `flushMessages` holds back any message that arrives within 0.5 s of the previous publish until the
     next 1 Hz `tick()`. `disconnect()` cancels that timer (`LinkManager.swift:218-222`) before `vehicle.reset()`
     (`:247`), so the pending tail of a burst stays buffered. Two things then go wrong:
     - **Speech after replay (BUG-025).** Replay ends with a burst of warnings, for example a failsafe tlog. The user
       taps Connect. `connect()` → `disconnect()` → `reset()` leaves them pending, `open()` sets `speech.muted = false`
       (`:187`), and the new link's first `tick()` publishes them. The new `$messages` sink then says up to 3 replayed
       warnings as if they were live.
     - **Missed update.** The same tail is missing from the Messages tab after Disconnect (no timer is left to flush
       it). It shows up out of context after the next Connect.
   - **Fix.** Make the first line of `reset()` `flushMessages(force: true)`, tagged
     `// BUG-037 (round 3) / BUG-025: publish the buffered tail now, while speech is still muted for a replay, so it isn't spoken later as live`.
     - On the replay path, `startReplay` mutes before `disconnect()`, and `connect()` from a replay runs `disconnect()`
       before `open()` unmutes. So the flush happens while muted, and the sink still advances `lastMessageID`.
     - Live-to-live, it speaks at most the last ≤ 1 s of real live warnings that weren't announced yet. That matches
       the old behaviour, which spoke them as they arrived.
     - If you'd rather never speak at reset, `pendingMessages = []` also fixes the speech problem. But it drops those
       messages from the Messages list, so the flush is better.

## Optional notes

1. **Harness timing: nothing is timing-sensitive.**
   - The fake drone sends every STATUSTEXT a scenario checks as a single message after a quiet spell
     (`fake_drone.py:373,402,608,679`), and the flood only runs in `statustext_flood`. `lastMessagesPublish` is then
     more than 0.5 s old, so the message is published in the same batch.
   - The checks: F3 `rejectArm` (`Scenarios.swift:129`, after `pump(0.5)`), D1 (`:703`), the mid-mission "LOITER"
     (`:595`, after a 60 s wait), and G4 "Fence" (`:784`, after a mode wait).
   - `statustextFlood` (`:417-419`) only checks the cap. `pendingMessages` is capped too, so `messages.count <= 300`
     still holds.
   - The SITL checks at `:653,661,850,883,887,902` only print `messages` in notes.
   - `waitUntil`/`pump` run `RunLoop.main` (`main.swift:65`), so the main-queue 1 Hz timer still flushes in the
     harness.
2. **A second message within 0.5 s shows up to 1 s late** (at the next `tick()`), not at most 0.5 s as the comment at
   `VehicleModel.swift:87-89` implies. Only a later message ≥ 0.5 s after the publish, or the tick, flushes it. That's
   fine for a message list; the wording could say "within about a second".
3. **Speech sink, edge cases.** All are correct:
   - On subscribe, `@Published` replays the current value. Its first id equals `lastMessageID` (set just before), so
     `fresh` is empty and nothing old is spoken. Re-observing resets `lastMessageID` the same way.
   - If `lastMessageID` was trimmed off the 300 cap, the loop takes the whole list, but `prefix(3)` bounds it.
   - The sink runs in `willSet`, with `list` as the new value, which is what it needs.
   - `say()` still checks `enabled` and `!muted`, so the BUG-025 mute and `suppressLinkAlerts` are unchanged.
4. **Banners are still immediate.** `leakDetected` (`:550-551`) and `lastAlert` + `updateWarning` (`:566-569`) are set in
   `addStatusText` before buffering, so the HUD leak/warning banners and the "Leak detected" speech don't wait for the
   flush.
5. **`lastHeartbeat` not published is safe.** Its only reader is `CommandCenter.confirmFromVehicleState`
   (`CommandCenter.swift:106`), which polls from `tick()`. No view reads it. With heartbeat assign-if-changed, a steady
   vehicle may publish nothing on VehicleModel for a while. `messageCounts` readers still refresh, though:
   `DiagnosticsView` and `StatusListView` observe `LinkManager`, which publishes `stats` at 1 Hz, and StatusListView
   also observes `fast`.
6. **Docs.** The FIX_LOG "Round 3" section and the TESTING_RESULTS row are accurate and say "not compiled or measured
   yet". After the required fix, add one line saying `reset()` flushes the buffered messages (BUG-025). Git warns that
   both `.md` files would get CRLF on checkout; that's `.gitattributes` behaviour for `.md`, nothing to do.

## What I checked

- **Compile.**
  - `lastMessageID: UUID?` compared with `m.id` (`UUID`) is a valid optional promotion.
  - `warnings.prefix(3).reversed()` (ArraySlice → ReversedCollection) works with `for … in`.
  - The multi-statement sink closure gets its parameter type from `Published<[StatusMessage]>.Publisher`.
  - `var list = pendingMessages + messages`; `removeLast(n)` is guarded by `count > max`.
  - `lastHeartbeat` keeps `private(set)` and is still read from `CommandCenter`.
  - Heartbeat compares are `UInt8`/`UInt32`/`Bool`.
  - The harness copies `App/Vehicle/*.swift` (SpeechAlerts imports AVFoundation/Combine as before).
- **Flood rate.** Each STATUSTEXT calls `flushMessages(force: false)`, and at most one publish passes per 0.5 s. So
  `messages` publishes about 2–3 times a second under 200 STATUSTEXT/s, down from 10.

## macOS checks required before merging

The R3-1 list still applies (unit tests, `build_harness.sh` + `run.py -j 4 all`, `catalyst.sh build` + `uitest`,
`catalyst.sh perf BreakTestUITests2/test_perf_highRateAndFlood`, and the short manual Catalyst pass). Add these:
- With `fake_drone.py`, check that `text 4 PreArm: test` appears in Messages and is spoken at once (speech on).
- `fault statustext_flood on` for 10 s: Messages updates about twice a second, and speech doesn't queue (severity 6 is
  never spoken).
- Replay a tlog that contains warnings, then Connect live: nothing from the replay is spoken.
