## Break-test fixes → 0.5.0

Fixes from an overnight break-test of the app against a scriptable fake ArduCopter, ArduPilot 4.7.3 SITL
(Copter/Rover/Sub) and the real UI built as a Mac Catalyst app. The findings are in `TESTING_RESULTS.md`, and every
fix is listed in `testing/FIX_LOG.md` with its cause, change and proof. Code changes are tagged `// BUG-0xx:`.

### What changes for pilots
- **Link loss is never hidden.** NO HEARTBEAT shows whenever the heartbeat stops, including after a TCP failure. TCP
  reconnects by itself, and the top bar shows "—" instead of stale ARMED/mode/battery values (BUG-001, -012).
- **Commands are confirmed correctly.** A Disarm/RTL sent right after Arm/Loiter goes out immediately, the superseded
  command is never resent, and the earlier ACK can't confirm it: it is confirmed by a later ACK or by the vehicle's
  heartbeat (armed flag / mode). Force-disarm works the same way and is retried until confirmed. Servo/relay/motor
  commands queue in order, so none is dropped (BUG-002). A lost ACK is checked against the heartbeat before an
  error is shown (BUG-017).
- **Mission upload works on lossy links to real ArduPilot.** INVALID_SEQUENCE is no longer fatal, and a lost final
  ACK is verified by reading back the count and the last item (all vertices for fences, which ArduPilot keeps whole on
  a timeout).
  Lossy SITL uploads went from 4/5 failing to 3/3 passing (BUG-033).
- **No more crashes** from NaN/Inf/out-of-range telemetry, corrupt files, FLTMODE_CH = 0, a huge takeoff altitude,
  a latitude typo, missions over 65 535 items, or a malformed ACCELCAL message (BUG-003…-007, -009, -010).
- **Warnings are visible.** A HUD banner shows failsafe/fence/EKF/battery messages and low/critical battery, with
  speech on or off (BUG-008).
- **Confirmations for dangerous actions:** Disconnect/Reconnect/Replay while armed, a fence below the vehicle in
  flight, and large battery calibration changes (BUG-013, -018, -022). Fly-here checks the altitude and reports the
  vehicle's answer (BUG-006, -011).
- **Parameter metadata regenerated from ArduPilot 4.7.3:** 99.9 % coverage, up from 58 %, including the new `MAVn_*`
  stream rates; older names such as ARMING_CHECK and SRn_* are kept (BUG-034).
- Plus BUG-014…-016, -019…-029, -032, -035…-039, TEST-030/-031, and the version bump to 0.5.0.

### How it was tested
| Check | Result |
|---|---|
| MAVLinkKit unit tests (incl. new regression tests and an ArduPilot-like lossy mission vehicle) | 61/61 |
| Headless app harness vs fake drone: scenarios, crash probes, fuzzers (`python3 testing/scenarios/run.py -j 4 all`) | 86/86, 0 crashes (before: 16 crashes, 24 fails) |
| ArduCopter/Rover/Sub 4.7.3 SITL (`run.py -j 4 sitl`) | 21/21 |
| Thread Sanitizer on the link scenarios | 0 races (before: 4) |
| Mac Catalyst UI tests (`testing/sim/catalyst.sh uitest`) | the former crash tests and BUG-001/-008/-013 pass; remaining failures are XCUITest limits (ADS-B labels, list scrolling) |

Independent reviews: `testing/REVIEW_1.md` (7 required changes), `testing/REVIEW_2.md` (2) and `testing/REVIEW_3.md` (2),
all applied, see `testing/FIX_LOG.md`.
New CI job `break-test` runs the harness scenarios and probes on every push and PR.

### Known remaining (documented)
- BUG-019: DataFlash downloads are capped at 256 MB. Streaming to a file is left as a follow-up.
- BUG-035: accessibility labels and contrast are improved, but some system-control contrast findings remain.
- BUG-037: UI CPU at 50 Hz went from 48 % to 34 % on a Mac. Re-measure on an iPad.
- Not testable here: real iPad layout/touch/rotation, ExpressLRS backpack, BLE, speech, real flight. TESTING.md
  section G is still needed.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
