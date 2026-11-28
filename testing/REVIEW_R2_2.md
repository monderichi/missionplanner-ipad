# Review R2-2: commit 2ecfc4e (`bug_fixes_2`)

Scope: `git diff HEAD~1..HEAD -- Packages App` (LogStore, LogProtocol, CommandCenter, LinkManager, VehicleModel, LogTests).

**APPROVED**

## Required changes

None.

## Optional notes

1. **`.partial` sweep is folder-wide** (`LogStore.attach`). It deletes every `*.partial` in `Documents/.../dataflash`, which
   the user can see in Files. Only the app writes there, so the risk is close to nil. If you want to be strict, match
   `*.bin.partial` instead.
2. **Quiet filter is keyed by command id** (`CommandCenter.abandonPending`). `quiet` counts per command id
   (`MAVCmd.requestMessage`). If a user-visible REQUEST_MESSAGE and a quiet one were in flight together, the user one
   would also be treated as quiet. Today no user action sends REQUEST_MESSAGE through the labelled path, so nothing
   breaks.
3. **The zero-size log creates the `.partial` before `discardPartial()` removes it.** That's fine: the handle is closed
   first (the new `closeFile()`), so the file isn't held open when it's removed.

## What I checked

- **`replaceItemAt` success path.** I ran a standalone Swift script on this Mac with the same names (`... log3.bin`
  plus `... log3.bin.partial`, handle closed first). It returned the `.bin` URL, the directory held only the `.bin`, and
  the `.bin` had the new content. On failure the catch removes the partial and the old `.bin` stays, so nothing is lost.
  The returned URL is ignored, which is safe because the file lands in the same directory under the same name.
- **Start error / zero size.** `LogDownloadSession.start` opens the file before the size check. The size-0 branch now
  closes the handle and returns `[LOG_REQUEST_END]` with `active = false` and `startError = nil`. `LogStore.start`
  takes the new `!s.active` branch, which shows a message, discards the partial and clears `download`/`downloading`,
  so the UI isn't left stuck on "downloading". On a start error the partial is discarded too. The order in both
  branches is right: `discardPartial()` reads `download?.fileURL` before `download = nil`.
- **Attach sweep.** It's guarded by `download == nil`, so a re-attach during an active download (compid change) can't
  delete the live file.
- **`abandonPending`.** The `defer` clears `quiet` after the `first(where:)` check, so the check sees the quiet counts.
  A banner appears only for a non-quiet pending command.
- **`messageCounts` no longer `@Published`.** Both views still refresh:
  - `StatusListView` (`App/UI/TelemetryViews.swift:138`) and `DiagnosticsView` (`:40-81`) both observe `LinkManager`.
  - `LinkManager` publishes `stats`/`bytesReceived` from the 1 Hz heartbeat timer while connected.
  - `VehicleModel.handle` assigns the `@Published` `vehicleType`/`armed`/`customMode`/`systemStatus` on every
    autopilot heartbeat. `@Published` fires on every assignment, equal values included.
  - `apply(batch)` runs all of a batch's mutations synchronously on main before SwiftUI re-renders, so the views read
    the latest counts.
  - `reset()` clears the counts and sets many published properties, so the cleared state shows after Disconnect.
  - The share report (`report`) is computed at render time, so it is at most about 1 s stale. That's acceptable.
- **`uiBatchInterval` 0.1.** This is a constant change only. The generation guards around the flush are unchanged.
- **Unit tests.** `testing/unit/run_unit_tests.sh` gave `RESULT: 67 tests, 0 failed`. The new test covers the file-backed
  zero-size path.
