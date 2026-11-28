# Onboarding prompt for a collaborator's Claude

Paste everything below the line into your **already open** Claude Code session in your clone of this repo
(Windows or macOS).

---

Please bring yourself up to speed with recent changes to **Mission Planner for iPad** before doing anything else.
Don't change code until you've done sections 0–1 and reported back.

The project is a SwiftUI ground-control app for ArduPilot (Copter, Rover, Sub), plus **MAVLinkKit**, the MAVLink
v1/v2 Swift package it uses. It is sideloaded with Sideloadly under a free Apple ID and deploys to iOS 16. The main
pilot flies a copter over **ExpressLRS in MAVLink mode**: the iPad joins the TX Backpack Wi-Fi hotspot and talks UDP
to `10.0.0.1`.

## 0. Sync safely first
1. Run `git status`. If there are uncommitted changes or you're on a feature branch, **don't discard anything**. Tell
   me what's there, then commit or stash it, as I decide.
2. Run `git fetch origin`, then `git checkout main`, then `git pull --ff-only origin main`.
   `main` now contains two large squash merges (see section 2).
3. If I have a feature branch in progress, ask me before merging or rebasing `main` into it. The changes touch
   `App/Link`, `App/Vehicle`, `App/UI` and `Packages/MAVLinkKit` heavily, so expect conflicts.

## 1. Read, in this order
1. `CLAUDE.md`: the running handoff log (phases, ELRS link design, bench state). Some of its early ground rules are
   out of date. **Section 4 below wins where they disagree.** In particular, GitHub Actions is no longer the
   compiler, and a Mac now runs the full test suite.
2. `README.md` (what works, build, install) and `PROGRESS.md`.
3. `TESTING_RESULTS.md`: the break-test report. It lists 37 bugs, each with a one-command repro and acceptance
   criteria. **Section 9 is the current status of every item.**
4. `testing/FIX_LOG.md`: every fix with its cause, change and proof, plus what each review asked for
   ("Review 1"…"Review 5", "Round 2").
5. `testing/README.md`: the test kit.
6. Skim `testing/REVIEW_*.md` for the reasoning behind the command, mission and log protocol changes.

## 2. What changed recently (2026-11-28, both merged into `main`)
- **0.5.0, PR #1 (`bug_fixes`), squash `d908201`.** This fixed the break-test findings. Highlights:
  - **Link loss:** NO HEARTBEAT is never hidden, TCP reconnects by itself, and stale values show "—".
  - **Commands (`CommandSession`):** arm/disarm and mode changes *supersede* the in-flight command at once. They are
    confirmed by a later ACK or by the vehicle's heartbeat, but only after an ambiguity window. Other commands
    (servo, relay, motor test, REQUEST_MESSAGE) queue FIFO per command id. A queued command can't be resolved by an
    ACK before it has been sent.
  - **Missions (`MissionSession`):** INVALID_SEQUENCE isn't fatal. A lost final ACK is verified by reading back the
    count and then the last item; fences are read back in full, with the circle radius compared. A one-item fence or
    rally upload is verified as well.
  - **Crashes:** no more crashes from NaN/Inf/out-of-range telemetry or corrupt files.
  - **UI:** a warning banner, confirmations for dangerous actions, and parameter metadata regenerated from ArduPilot
    4.7.3 (`tools/gen_param_meta_ardupilot.py`; 4.7 renamed `SRn_*` to `MAVn_*`).
- **Round 2, PR #2 (`bug_fixes_2`), squash `d623456`:**
  - **DataFlash downloads stream to `<name>.partial` on disk** (BUG-019). The 256 MB cap is gone; a free-space check
    replaces it.
  - **UI batches publish at 10 Hz**, and the per-packet counters no longer trigger SwiftUI updates (BUG-037 partial:
    CPU 34 % → 29 %).
  - Review leftovers were fixed too.
- **Still open:**
  - BUG-037: UI CPU target < 15 %. The next step is splitting `VehicleModel` so the map and status views don't redraw
    with the HUD.
  - BUG-035: accessibility contrast.
  - **Nothing has been tried on a real iPad or vehicle yet** (`TESTING.md` section G).
- **Known limits, by design:**
  - COMMAND_ACK has no request id, so a late duplicate ACK can resolve the next queued command once it has been sent.
  - At 30 % loss each way, about 1 mission upload in 3000 hits the 15-retry dead-link limit.

## 3. Code map
- **`Packages/MAVLinkKit`**: pure protocol state machines (`CommandProtocol`, `MissionProtocol`, `ParameterProtocol`,
  `LogProtocol`, `MAVLinkFraming`, `DataFlash`). The caller passes `now` in and does the I/O. It imports only
  Foundation. Tests are in `Packages/MAVLinkKit/Tests`.
- **`App/Link`**: transports (Apple Network framework) and `LinkManager` (I/O queue, link generations, 10 Hz UI
  batch).
- **`App/Vehicle`**: `VehicleModel` and the stores (`CommandCenter`, `MissionStore`, `ParameterStore`, `LogStore`,
  `CalibrationStore`, …).
- **`App/UI`**, **`App/Map`**, **`App/Control`** (manual control).
- **`testing/`**: the break-test kit:
  - a headless harness that compiles the app's real Link/Vehicle/Storage code (macOS only);
  - a scriptable Python fake drone with fault injection, plus a fault proxy (any OS);
  - ArduPilot 4.7.3 SITL;
  - Mac Catalyst UI tests (macOS only).
- **`tools/`**:
  - `mavlink_ref.py`: a Python twin of the Swift codec, any OS.
  - `fake_vehicle.py`, `gen_param_meta*.py`, `audit_params.py`.
  - PowerShell generators: `gen_mission_cmds.ps1`, `make_fixtures.ps1`, `dump_mavlink_defs.ps1`.
  - `fc_params.py`: **real hardware**, see rule 1.

## 4. Rules from now on
1. **Never connect to real hardware** (flight controller, COM port, radio, ESC, the ELRS backpack) unless I explicitly
   ask in chat for that specific action. That includes `tools/fc_params.py COMxx` and desktop Mission Planner
   connected to a real vehicle. Every test vehicle binds to `127.0.0.1`.
2. **No GitHub Actions.** The account has no Actions minutes left.
   - Put `[skip ci]` in every commit message you push, merge commits included.
   - Never wait on CI or poll it.
   - Cancel any run that starts by mistake (`gh run cancel <id>`).
   - The `break-test` job is manual-only. An IPA build ("Build Sideloadly IPA") happens only when the repo owner
     starts it by hand.
   - All verification is local (section 5).
3. **Workflow:** branch off `main`, make small focused commits, open a PR, and get an **independent review** in a
   fresh agent or session. The reviewer writes `testing/REVIEW_<name>.md`, starting with the verdict line
   `**APPROVED**` or `**CHANGES REQUIRED** (N)`. Fix what it asks for, re-review until it approves, then squash-merge
   with `[skip ci]`. Don't push to `main` directly, and don't merge without an approving review.
4. **Windows can't compile or run the app.** Any Swift change made on Windows must pass the macOS checks in section 5
   before it is merged:
   - Push the branch with `[skip ci]` and open the PR.
   - In the PR, list exactly which macOS checks are needed.
   - Ask me to have them run on the Mac. Don't merge Swift changes that were only read and never compiled.
   - Python, PowerShell and docs changes can be fully verified on Windows.
5. **Platform limits:**
   - iOS 16 APIs only.
   - No restricted entitlements: sideloaded with a free Apple ID, so no multicast/broadcast receive and no USB serial.
   - Unicast networking only.
   - Keep ELRS narrow-link configs (`.narrowLink`) and low stream rates.
6. **Code conventions:**
   - Keep the `// REA Parity Source:` header comments, because protocol code mirrors Mission Planner.
   - Tag every fix `// BUG-0xx:` (or `// review N:`) and explain *why* in the comment.
   - MAVLinkKit stays pure: Foundation only, no UIKit, no timers, no I/O.
   - Don't hide a failure from the pilot: report a lost link, an unconfirmed command or an unverified upload in plain
     words.
7. **Docs are part of the change:**
   - add a row to `testing/FIX_LOG.md` (cause, change, proof);
   - update the item's status in `TESTING_RESULTS.md` section 9;
   - update `CLAUDE.md` when you learn something on the bench.
   - A bug is FIXED only with a passing test that reproduces it. Otherwise it is PARTIAL, with the remainder written
     down.
8. **Housekeeping:**
   - Never commit `testing/.build`, `testing/artifacts`, `testing/logs`, `testing/.sitl` or `testing/.venv`; they are
     git-ignored.
   - Line endings are enforced by `.gitattributes` (LF for `.sh`, `.swift`, `.yml`, `.plist`). Don't commit CRLF
     versions of those files.
   - Don't put personal data in requests to outside services.
   - Ask before deleting anything you didn't create.

## 5. Tests to run

### On Windows (PowerShell; Python 3 from python.org, standard library only)
None of these touch hardware.
- **Protocol ideas against the Python codec:** `tools\mavlink_ref.py` is the reference twin of the Swift codec. Use it
  to try framing, CRC or message ideas before writing Swift.
- **Fake drone:**
  ```powershell
  py -3 testing\fake_drone\fake_drone.py --tcp-server 5760 [--fault NAME,...]
  ```
  Run `--help` for the roughly 40 faults (NaN telemetry, lossy ACKs, reject_arm, statustext_flood, ADS-B, …).
  - Connect **desktop Mission Planner** to TCP `127.0.0.1:5760` to compare the app's expected behaviour with Mission
    Planner's on the same faults. This is a parity check, so record any difference in `TESTING_RESULTS.md`.
  - Control a running drone over UDP 17001: `fault NAME on|off`, `silent N`, `vtype N`, `text SEV MESSAGE`,
    `reboot`, `status`.
- **Fault proxy:** `py -3 testing\fake_drone\fault_proxy.py --help` adds loss, latency, jitter, duplication,
  reordering, corruption and blackouts between any GCS and the drone.
- **tlog analysis:** `py -3 testing\tools\tlog_trace.py <file.tlog>` traces a recorded tlog, for example one shared
  from the iPad (Files › Mission Planner › logs).
- **Parameter metadata audit:** `py -3 -I tools\audit_params.py`.
- **MAVLinkKit unit tests (optional, unverified on Windows):** MAVLinkKit imports only Foundation, so with the
  official Swift for Windows toolchain (5.9+) `swift test --package-path Packages\MAVLinkKit` may work. If it fails
  for platform reasons, don't patch the package for Windows: rely on the Mac run.
- **SITL (optional, unverified on Windows):** two options.
  - Mission Planner's own **Simulation** tab runs ArduPilot SITL locally.
  - In **WSL2 (Ubuntu)**, `testing/sitl/build_sitl.sh` and `python3 testing/scenarios/run.py` may work. The script was
    written for macOS, so don't promise anything; the Swift harness itself needs macOS.

### On the Mac (macOS with Xcode + `brew install xcodegen`; required before merging any Swift change)
Run before every merge, with the expected results in the comments:
```bash
testing/unit/run_unit_tests.sh                       # MAVLinkKit unit tests → "RESULT: 67 tests, 0 failed" (or more)
B=$(testing/harness/build_harness.sh | tail -1)      # headless app harness (real App/Link, App/Vehicle, App/Storage)
HARNESS_BIN=$B python3 testing/scenarios/run.py -j 4 all   # fake drone: scenarios + crash probes + fuzzers → all PASS (86)
```
Run these too when the change calls for it:
- **Protocol or mission/param/log changes: ArduPilot 4.7.3 SITL.** Built once with `testing/sitl/build_sitl.sh`, which
  takes about 15 min and needs about 1.5 GB. Then:
  ```bash
  HARNESS_BIN=$B python3 testing/scenarios/run.py -j 4 sitl
  ```
  Expect 21/21. Copter, Rover and Sub are covered. A subset is fine for small changes, for example
  `sitl_arm sitl_mission_roundtrip sitl_fence_rally sitl_lossy sitl_log_download`.
- **Threading changes:** `HARNESS_SANITIZE=thread testing/harness/build_harness.sh`, then run the link scenarios with
  that binary. Expect 0 races.
- **Any SwiftUI/UI change: build the real app as Mac Catalyst and run the UI tests.**
  ```bash
  testing/sim/catalyst.sh build
  testing/sim/catalyst.sh uitest
  ```
  You can also pass one test, as `Class/test`. macOS must approve UI automation once. If it isn't approved you'll see
  "Timed out while enabling automation mode": ask, don't loop.
- **Performance:** `testing/sim/catalyst.sh perf BreakTestUITests2/test_perf_highRateAndFlood` writes CPU/RSS to
  `testing/logs/catalyst_perf_*.csv`. It is at 29 % now; the target is < 15 %.
- **One bug's repro:** `testing/scenarios/<name>.sh` (see `TESTING_RESULTS.md`), or `run.py --list`.
- `run.py -j N` gives each worker its own ports and SITL instance.
  - Two runs at once need `RUN_SLOT_BASE=10` on one of them (and a shared `HARNESS_BIN`), or their ports and builds
    clash.
  - After an aborted run, `pkill -f Harness; pkill -f fake_drone`.

## 6. Pitfalls already hit (don't repeat them)
- **Swift type-checker timeouts:** large dictionary or closure literals time out the type checker on slower machines.
  Build tables statement by statement inside a function.
- **Argument evaluation order:** Swift evaluates arguments left to right. In tests, read state such as
  `session.inFlight(id)` *before* calling something that changes it in the same expression.
- **Lossy tests:** seed their RNG (see `SimulatedMissionVehicle(seed:)`). Unseeded loss makes tests flaky.
- **Ambiguity windows:**
  - A window that ignores ACKs right after a send makes the command go out twice.
  - A window applied after a resend cascades down the whole queue.
  - Only guard what can't be the command's own ACK.
- **ArduPilot 4.7.3 differs from older notes:** it answers a duplicate final mission item with
  INVALID_SEQUENCE/ERROR and never re-ACKs it. On a timeout it keeps the whole old fence.
- **Windows:** Swift code edited without compiling has broken CI before (`for (k, var v)` patterns, slider trailing
  closures, typed tuple closures). Write conservative Swift, and leave the compile to the Mac.

## 7. Report back
After sections 0–1, reply with:
- what you synced, and anything you stashed or committed;
- a short summary of the changes that touch what I'm working on;
- which section 5 checks you ran on this machine, with their results;
- the open items: `TESTING_RESULTS.md` section 9 PARTIAL items, and `TESTING.md` section G real-device checks.

Then ask me what to work on next.
