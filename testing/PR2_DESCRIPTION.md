## Break-test round 2: BUG-019 DataFlash streaming + review leftovers

Follow-up to PR #1 (0.5.0). Details: `testing/FIX_LOG.md` section "Round 2".

- **BUG-019 (was PARTIAL, now fixed):** DataFlash logs download straight to `<name>.partial` on disk, chunk by chunk,
  and are moved into place when complete. RAM use no longer grows with the log size, the 256 MB cap is replaced by a
  free-space check, and unfinished files are deleted on cancel, failure or link change.
- Overlapping background `REQUEST_MESSAGE` commands no longer show a stray "Request message: accepted" banner
  (REVIEW_5 optional 3).
- The one-item fence/rally tests now require the read-back failure itself (REVIEW_5 optional 2).

### How it was tested (locally; no GitHub Actions minutes, so pushes carry `[skip ci]`)
| Check | Result |
|---|---|
| MAVLinkKit unit tests (`testing/unit/run_unit_tests.sh`) | 66/66 |
| Headless app vs fake drone (`run.py -j 4 all`) | 86/86 |
| ArduCopter 4.7.3 SITL: `sitl_log_download`, `sitl_arm`, `sitl_mission_roundtrip` | 3/3 (log size matches, no `.partial` left) |

🤖 Generated with [Claude Code](https://claude.com/claude-code)
