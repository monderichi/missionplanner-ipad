# Mission Planner for iPad: progress and how to continue

Snapshot of 2026-11-27, end of day. Latest commit on `main`: `4f8c1f7`. Read this first in a new session,
then `CLAUDE.md` (detailed handoff log and ground rules) and `README.md`.

## The project in one paragraph

A native iPad (iPadOS 16+) recreation of ArduPilot **Mission Planner**, written in SwiftUI plus a pure-Swift
MAVLink package (`Packages/MAVLinkKit`). There is no Mac, so **GitHub Actions is the only compiler**. Every push to
`main` builds an unsigned `.ipa`, which is installed with **Sideloadly** (free Apple ID). Repo:
`monderichi/missionplanner-ipad` (private). The main link is **ExpressLRS MAVLink through the TX backpack Wi-Fi**
(10.0.0.1, backpack listens on 14555 and sends to 14551 on the owner's unit). That link has been confirmed
working on the real iPad.

## How we work

- **Opus plans and reviews, Sonnet sub-agents implement** (parallel agents, each owning separate files). Opus fixes
  compile risks and wires the cross-file glue.
- Swift compile-safety rules (no local compiler):
  - Avoid `for (k, var v) in`, `guard let (a, b) = tuple` and typed tuple-destructuring closure params.
  - Use no trailing closures on `Slider`.
  - Use `.pickerStyle(.menu)` outside a NavigationStack.
  - Wrap ternary initialisers that have `didSet` in parentheses.
  - Bracket-balance check before pushing.
- Commit messages containing **`[sim]`** also run the **iPad Simulator job**:
  - It runs `scripts/sim_screenshots.sh` against `tools/fake_vehicle.py` and publishes screenshots, logs and
    tlogs to the `ci-screenshots` branch.
  - Fetch the results with `git fetch origin ci-screenshots` then `git archive --format=zip -o sim.zip origin/ci-screenshots`.
  - The branch commit message names the source commit.
- `gh` is not installed on this PC. Watch the `ci-screenshots` branch, or open the Actions page in Chrome.

## What is done (commit history)

| Commit | What |
|--------|------|
| `0bec9f8`, `071924d` | Phases 1–2: scaffold, MAVLink v1/v2 core (generated from MP's MAVLink.dll), UDP/TCP links, tlog, HUD, map, status |
| `3377e99`, `813dc59` | ExpressLRS Wi-Fi link; Phase 3 parameters (download/gap-fill/set, .param files) and commands |
| `a90a9a5` | Phases 4–7: map with offline tiles, mission/fence/rally planner, setup and calibration, tlog replay |
| `d424ab7` | Frozen-HUD fix (vehicle lock on the real autopilot), attitude watchdog, geofence / max altitude page |
| `24ccabb` | MP parity: actions, fly-here, servo/relay, checklist, speech, DataFlash log download, setup pages |
| `a1e41f0` | Offline maps: save a radius (default 10 km) around the map centre, drone or home |
| `b9a0151`, `c14c3e1` | Tester build 0.4.0: Diagnostics screen, build stamp, `TESTING.md`, online feedback page |
| `7bfb06e`, `3ef9fcf` | CI iPad Simulator job and fake ArduCopter; fixes found by it |
| `407e5b7`, `903bf32` | Batch 2: graph tab, MAVLink inspector, custom Quick tiles, setup pages, ADS-B, gimbal/camera, long-press menu, circle/orbit, DataFlash review |
| `e93f82e`, `1ad2f59` | Simulator coverage for the batch-2 screens; inspector rate over a 5 s window; fake ADS-B traffic |
| `4aeb00b` | **UGV (ArduRover) + ROV (ArduSub)**: setup pages per firmware, Rover setup and ROV setup pages, depth/water temp/leak, manual control (gamepad + on-screen sticks), `tools/audit_params.py` settings audit |
| `87c6a3f` | Control tab: game-controller toggle, on-screen sticks fallback (the simulator reports a fake "Gamepad"), rover throttle bar = MANUAL_CONTROL z |
| `4f8c1f7` | `TESTING_SIMULATOR.md` (simulator test plan for Elias); gain label no longer wraps |

The last simulator run (`87c6a3f`) is green. Screenshots were checked for:
- copter: data, actions, status, checklist, servo, messages, graph, inspector, setup pages, log review, ADS-B;
- rover: data, actions, setup, motors, control;
- sub: data, control, setup, messages.

## Testing status

- **Real iPad:** the ExpressLRS connection works. Most features have not yet been tried on the real iPad and vehicle.
  The tester feedback page (https://claude.ai/artifact/AJkcibTj4zuqpb5RpnXpPr, db collection `feedback`) had 0 results.
- **Elias (github.com/EliaKr)** will run `TESTING_SIMULATOR.md` on a Mac (iPad Simulator + ArduPilot SITL or the fake
  vehicle). He reports by test ID (S-C*, S-R*, S-S*, S-G*), with screenshots, diagnostics and .tlog.
  The owner adds him as a repo collaborator themselves (GitHub needed a passkey confirmation).
- The real-iPad test plan for flying testers is `TESTING.md`.

## Next steps (tomorrow)

1. Collect Elias's results (file, GitHub issue or the feedback page) and fix every failure; re-run `[sim]`.
2. Check that the CI build of `4f8c1f7` is green (only the gain label changed).
3. Known gaps:
   - `PlannerSettings` units are not used by all screens.
   - Manual control has never driven a real rover/sub.
   - The frozen HUD over ELRS on the real iPad is not proven fixed; analyse an iPad `.tlog` if one is shared.
4. Optional: add more simulator shots (boat profile, the gamepad toggle on), multi-vehicle support (still single-vehicle).

## Not possible on a sideloaded iPad

Firmware flashing, ESC calibration, MP scripts, USB serial, and UDP broadcast/multicast receive (needs a
restricted entitlement). Every link must be unicast UDP/TCP or the ExpressLRS backpack.
