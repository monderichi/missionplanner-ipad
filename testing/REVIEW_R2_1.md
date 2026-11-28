# Review R2-1: PR #2 (`bug_fixes_2` → `main`), round 2 changes

**APPROVED**

Scope: `git diff main..bug_fixes_2 -- Packages App testing/harness`. That covers BUG-019 (file-backed DataFlash
download), the `CommandCenter` quiet counter and the test changes.

## Required changes

None. I found no defect introduced by this round.

## Optional suggestions

1. **Zero-size log: the download never ends (this predates the PR).** `LogDownloadSession.start` with `size == 0`
   sets `active = false` and returns `[end()]` without an event. `LogStore` keeps `downloading` set, so the
   "Downloading log N" section stays up and every Download button stays disabled until the user taps Cancel. The
   in-memory path on `main` behaves the same way. In file mode the session now also holds an open `FileHandle` and an
   empty `<name>.partial` file until Cancel or detach. Nothing leaks permanently: Cancel calls `closeFile()` plus
   `discardPartial()`, and detach unlinks the file, after which the handle closes on deinit. ArduPilot can list
   empty logs, and the button is enabled for them (`SetupView.swift:1024`). The fix is small. In `start`, for
   `size == 0`, close the file and emit the finish event, for example by returning it from a `start` variant or
   letting the first `tick` report `.finishedFile(url, bytes: 0)` / `.finished(Data())`. Alternatively, disable
   Download when `e.size == 0`.
2. **Overwriting an existing `.bin` is not atomic.** `.finishedFile` calls `removeItem(at: url)` and then
   `moveItem`. If the move fails after the remove succeeded, the old copy of the same log is gone and the partial is
   deleted too. Both are in the same directory, so this is very unlikely. `FileManager.replaceItemAt(url, withItemAt: partial)`
   (iOS 4+) does it in one step and keeps the old file on failure.
3. **A partial file survives an app kill.** If iOS kills the app mid-download, `<name>.partial` stays in
   Files › Mission Planner › logs › dataflash. `LogReviewView` filters on `.bin`, so nothing breaks, and a re-download
   of the same log truncates the file through `createFile`. A one-line sweep of `*.partial` in
   `LogStore.attach`/init would keep the Files folder clean. Do it only when no download is active.
4. **`startError` path.** If `createFile` succeeds but `FileHandle(forWritingTo:)` fails, the empty partial is left
   behind, because `LogStore` sets `download = nil` without calling `discardPartial()`. Calling
   `discardPartial()` before clearing `download` there handles it. This is cosmetic.
5. **The quiet `requestMessage` banner on re-attach (this predates the PR).** If the HOME_POSITION request is still
   in flight when `attach` runs (compid change), `abandonPending()` shows the red "Request message: link changed,
   not confirmed". The counter change does not alter this. If it matters, skip quiet ids when picking
   `pendingCommands[0]`.

## What I checked

- **LogProtocol (file mode).**
  - Every exit path closes the handle: cancel, the stall timeout in `tick`, a write error in `handle` and completion.
    The only exception is `size == 0` (suggestion 1).
  - `handle` is guarded by `active`, so nothing is written after cancel, failure or finish.
  - Writes stay inside `[0, size)`. The file starts empty, so its length equals `size` once all chunks are in, and the
    swallowed `truncate` error cannot produce a file that is too long. An over-reported LOG_ENTRY shrinks `size` on
    the short or zero-length EOF chunk. The new test covers this with `reportedExtra = 50`.
  - `seek(toOffset:)`, `write(contentsOf:)`, `truncate(atOffset:)` and `close()` are the throwing iOS 13.4+ APIs, so
    they are fine on iOS 16. A disk-full error throws instead of raising an ObjC exception, and it is reported as
    `.failed`, never as "Saved".
- **LogStore.**
  - `start` while a download is active is guarded, and the UI also disables the button.
  - Cancel, `.failed` (from both `tick` and `handle`) and `detach` delete the partial file. `discardPartial()` runs
    before `download = nil` in each case.
  - A link loss or disconnect goes through `LinkManager` (line 228), which calls `logs.detach()`.
  - A failed move is reported as "Save failed" and removes the partial file.
  - The free-space check (`volumeAvailableCapacityForImportantUsageKey`, iOS 11+) is skipped when the value is
    unavailable. Running out of space mid-download is still caught by the write error.
  - The `.partial` name includes the log id, so two logs cannot collide.
- **CommandCenter.**
  - Every `MAV_CMD_REQUEST_MESSAGE` goes through `requestMessage`, which is quiet. The callers are `LinkManager.swift:350`
    and `ActionsView.swift:199`, and the generic `command(...)` path is never used with id 512.
  - So the counter cannot swallow a user-visible result. Overlapping requests queue FIFO in `CommandSession`, and each
    produces exactly one accepted, rejected or timed-out event, which decrements the count.
  - `abandonPending` resets the counter together with the session, whose results can no longer arrive, so counts do
    not leak.
- **Tests.**
  - `testFileBackedDownloadThroughLoss`: 20 % loss, a LOG_ENTRY 50 bytes too large and out-of-order writes. The bytes
    in the file must match exactly.
  - `testFileBackedDownloadReportsUncreatableFile`.
  - The MissionTests asserts were tightened to require a read-back "differs" failure.
  - The harness now checks that no `.partial` file is left.
- **Runs.**
  - `testing/unit/run_unit_tests.sh` → `RESULT: 66 tests, 0 failed`.
  - `HARNESS_BIN=… python3 testing/scenarios/run.py -j 2 log_download` → `PASS log_download`
    (`TOTAL 1: PASS=1, FAIL=0`).
