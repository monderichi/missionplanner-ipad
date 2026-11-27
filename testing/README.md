# testing/: break-test kit (see ../TESTING_RESULTS.md for results)

Needs only macOS + Command Line Tools (Swift 5.9+) + python3 (stdlib). Nothing here touches real hardware:
every vehicle binds to 127.0.0.1.

| Path | What |
|---|---|
| `unit/run_unit_tests.sh` | Runs MAVLinkKit's XCTest suite + `unit/extra/*.swift` through an XCTest stand-in (CLT has no XCTest). |
| `harness/build_harness.sh` | Builds the headless GCS: the app's real `App/Link`, `App/Vehicle`, `App/Storage` + `harness/Sources`. |
| `fake_drone/fake_drone.py` | Scriptable fake ArduCopter with ~35 faults; runtime control over UDP 17001. `--help` lists them. |
| `fake_drone/fault_proxy.py` | UDP proxy: loss, latency, jitter, dup, reorder, corrupt, blackout. |
| `scenarios/run.py` | Starts drone/proxy/SITL + harness for a scenario, verdict PASS/FAIL/CRASH. `all`, `probes`, `sitl`, `--list`. |
| `scenarios/<name>.sh` | One-command repro per scenario (wraps run.py). |
| `sitl/build_sitl.sh` | Builds ArduCopter 4.7.3 SITL into `.sitl/` (~1.5 GB; delete afterwards). |
| `sim/sim.sh` | iPad Simulator build/boot/run/screenshot (needs Xcode; not run yet). |
| `logs/`, `artifacts/`, `.build/`, `.sitl/`, `.venv/` | Generated; safe to delete. |

The harness redirects the app's Documents folder to `testing/.build/home` (CFFIXED_USER_HOME) and disables speech.
