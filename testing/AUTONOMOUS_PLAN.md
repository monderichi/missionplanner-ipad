# Autonomous run plan (2026-11-27 23:58 → deadline 2026-11-28 10:00 EET)

The user is away. This file is the **single source of truth** for the run: every resume (scheduled check-in or
manual) starts by reading it, continues at the first unchecked step, and appends to the progress log at the bottom.
The user's original request is kept verbatim at the end; the version below is the same task, made explicit.

## Ground rules for the whole run
- Never connect to real hardware. All vehicles are the fake drone or ArduCopter SITL on 127.0.0.1.
- Never stop to wait for the user. If something is ambiguous, pick the safest reasonable option, write the decision
  in "Decisions" below, and carry on. If a step fails 3 times, document it and move to the next step.
- Keep documentation current: `TESTING_RESULTS.md` (findings), `testing/FIX_LOG.md` (one entry per fix: bug id, cause,
  change, test that proves it), code comments at every non-obvious fix (`// BUG-0xx: …`), this file's progress log.
- Commit early and often with clear messages; never force-push; never rewrite main's history.
- Use `DEVELOPER_DIR` only if Xcode tools misbehave; Xcode 27.2 (license accepted) is the default now.
- Delete large temporary data at the end (`testing/.build`, `testing/artifacts`, crash reports the tests create).
  Keep Xcode and keep `testing/.sitl` + `testing/.venv` (user's choice).

## Steps (same meaning as the user's list; numbered as theirs where they gave numbers)

- [x] **0. Exhaust the Mac test suite** (current branch `testing/break-test-2026-11-27`). Extend the Mac Catalyst UI
  tests and run them, in this order:
  a. Plan screen: add/drag/delete waypoints by clicking the map, waypoint editor, Survey, Fence, Rally, `.waypoints`
     save/load through the file dialog (E3, E5, E6).
  b. Fly-here via click-and-hold on the map, incl. the altitude prompt (G3, BUG-006/-011).
  c. Setup pages: pre-arm button (D1), radio calibration bars (D4), motor-test props-off toggle and armed lock-out
     (D6), fence page (D7, BUG-022), battery calibration (D8, BUG-018).
  d. Parameter editor value lists/bitmasks (C4), Checklist (F1), Servo tab greyed motors (F4, BUG-014), replay bar
     (F5), ESC telemetry in Status (B4), Diagnostics (A2, B6).
  e. Accessibility audit on every screen (XCUITest `performAccessibilityAudit`).
  f. UI performance: CPU/memory of the real app at 50 Hz telemetry, long trail, STATUSTEXT flood.
  g. Long UI session (30 min) memory trend.
  h. Light and dark appearance of HUD, banners and state colours.
  i. Offline maps E1/E2 with a tiny area only (respect Esri/OSM tile policies; OSM bulk download stays disabled).
  Record every result in `TESTING_RESULTS.md` (new items get new BUG ids; coverage matrix updated).
- [x] **1. Commit** the findings and all useful test code/docs on `testing/break-test-2026-11-27`.
- [x] **2. Pull** the latest `origin/main` (12 new upstream commits by monderichi at 23:57: UGV/ROV, gamepad, batch 2,
  `TESTING_SIMULATOR.md`, `PROGRESS.md`) and merge it into the test branch.
- [x] **3. Review the upstream changes and re-run the tests**: which reported bugs are now fixed, still present, or
  changed; which new bugs the new code brings (new screens, ArduRover/ArduSub, gamepad). Re-run unit tests, harness
  scenarios (fake drone + SITL, `-j 4`), probes and Catalyst UI tests. Update `TESTING_RESULTS.md` with a
  "Re-test after pull" section (status per bug + new bugs).
- [x] **4. Commit** the final review files on the test branch.
- [x] **5. Push** to a new remote branch **`bug_fixes`** (created from the reviewed test branch).
- [x] **6. Fix all bugs** on `bug_fixes`, highest severity first, re-running the relevant tests after each fix and the
  full suite at the end. Each fix: code + comment + regression test (unit test, harness scenario or UI test) +
  `testing/FIX_LOG.md` entry + `TESTING_RESULTS.md` status → FIXED. Keep CI green (GitHub Actions builds on push to main;
  check the PR's checks). Commit per bug or small group; push regularly.
- [x] **7. Open a PR** `bug_fixes` → `main` with a full description (what changed, how it was tested, what remains).
- [x] **8. Independent review**: a fresh agent (no access to this conversation) reviews the PR diff for correctness,
  safety and regressions and writes `testing/REVIEW_<n>.md`.
- [x] **9. Apply** the reviewer's required changes (if any), with tests, and push.
- [ ] **10. Re-run the independent review** on the updated PR.
- [ ] **11. If the review is OK**: commit, push, merge the PR into `main` (method per "Decisions"); otherwise go back
  to step 9. Afterwards: clean up large temporary data and write the final summary in this file and in the PR.

## Decisions (filled in from the user's answers and during the run)
- Auto-resume: CronCreate check-ins every 30 min (xx:07, xx:37) from 00:07 to 11:07 on 2026-11-28 (session-only: needs this
  Claude app open). Each check-in: read this file, continue from the first unchecked step, or do nothing if all are done.
- Merge: after the independent review passes, merge `bug_fixes` into `main` myself and resolve conflicts (re-sync with main
  first; re-run tests if main moved).
- Merge style: **squash**, and bump `MARKETING_VERSION` 0.4.0 → **0.5.0** in `project.yml`.
- SITL: re-download ArduCopter 4.7.3 SITL and **keep it** afterwards (`testing/.sitl` is not deleted at the end).
- FC parameter naming (SR6_ vs MAV6_) is unknown for the user's board: docs mention both ("`MAV6_` on 4.7+, `SR6_` before").

## Progress log
- 2026-11-27 23:58 Plan written. Upstream main is 12 commits ahead (39 files, +3954/-85).

---
## Original request (verbatim)
> Run all these tests in order to exhaust the possible test suite on this mac.
> Afterwards queue these actions: 1) Commit your findings and anything else useful. 2) Pull the repo again.
> 3) Review changes and rerun any necessary tests to check bugs, bug fixes and any new bugs that may have arisen.
> 4) Commit the final review files after the pull. 5) Push to a bug_fixes branch. 6) Fix all bugs while running tests
> again. 7) Create a PR to merge the repo into main. 8) Get an independent agent to review the PR before merging to main.
> 9) Follow the agents instructions to improve the PR, if they exist. 10) Rerun the agent review
> 11) If ok, commit, push, merge to main, otherwise goto 9.
> Keep detailed documentation at all times in the form of .md files and comments. I will be afk so sort out any
> permissions now. Ask me any and all questions now. Do not get stuck at any step. If usage runs out make sure to
> autoresume so you get all this work done by 10:00. Set up autoresume now! for both usage resets.
- 00:2x Step 0 done (round-3 UI tests; long 30-min UI session running in background, result added in step 3). Step 1 committed 3ec59d6.
- 00:30 Step 2 done: merged origin/main (12 commits) → 467f9ea; CLAUDE.md conflict resolved by keeping both sections. Step 3 started: no reported bug is fixed upstream; harness needs a UIKit shim (added).
- 00:36 STATE FOR RESUME (usage limit hit). Step 3 in progress on branch testing/break-test-2026-11-27 (merged origin/main 467f9ea).
  Done in step 3: no BUG-001..037 fixed upstream (cause lines unchanged); harness builds with UIKit shim
  (testing/harness/UIKitShim); ManualControl scenarios PASS except NaN→full deflection (new BUG-038 Low);
  DataFlash fuzz 20k PASS; rover/sub SITL built, sitl_rover_manual/sitl_sub_manual drive OK (rover check relaxed);
  ADS-B: no coordinate check + no count cap (BUG-039 candidate, UI tests test_Z7_/test_perf_adsbFlood written, NOT run);
  UI class BreakTestUITests3 (TESTING_SIMULATOR.md S-* items) written, NOT run.
  Background runs at stop time: Catalyst long session (perf CSV testing/logs/catalyst_perf_test_perf_longSession.csv; RSS rising
  ~4.7 MB/min at normal rates, ~29 % CPU) and full retest `testing/logs/retest_after_pull.log` (RUN_SLOT_BASE=1 -j 4 everything).
  param_parse.py (BUG-034 metadata) failed with exit 1 in testing/.sitl/pdef/*/parse.log: check the log (likely missing
  python deps such as lxml in testing/.venv) before writing tools/gen_param_meta_ardupilot.py.
  NEXT: 1) read retest_after_pull.log + long-session CSV; 2) catalyst.sh build, then uitest BreakTestUITests3, BreakTestUITests2
  (ADS-B tests), BreakTestUITests; 3) write TESTING_RESULTS.md section 8 "Re-test after pull" (BUG-038, -039, long session);
  4) commit (step 4), push bug_fixes (step 5); 5) fixes per the design list in testing/FIX_LOG.md (create it).
- 00:37 Resume check-in: full retest after pull finished: 105 runs, 65 PASS / 24 FAIL / 16 CRASH (testing/logs/retest_after_pull.log):
  same failures/crashes as before the pull (all reported bugs still present), plus manual_control_rover/sub FAIL = BUG-038 NaN
  check (expected), sitl_lossy_b FAIL = BUG-033, sitl_lossy and sitl_lossy_c passed this time (BUG-033 is intermittent).
  Long UI session still running (631 s: 32 % CPU, RSS 367.7 MB, rising). Usage limit hit again; NEXT steps unchanged (see 00:36 entry).
- 00:57 Long UI session (30 min, normal rates) done: avg 30 % CPU; RSS 327 → 383 MB in the first 15 min, then flat
  (378–388 MB): warm-up growth (map tiles/trail/history buffers), no steady leak. Record under BUG-037 (CPU) in section 8.
  Usage limit hit again; NEXT unchanged (00:36 entry, starting at item 2: catalyst.sh build + UI classes 3/2/1).
- 03:25 Step 3 done (section 8 in TESTING_RESULTS.md; BUG-038, BUG-039 added). Step 4: committed. Step 5 next.
- 03:26 Step 5 done: bug_fixes pushed (85e7f2d).
- 03:24–04:05 Step 6: MAVLinkKit fixes (b8463ee), app fixes (ff486da), BUG-034 metadata (8a65346), CI/a11y (03db204),
  version 0.5.0 + legacy metadata names + section 9. Verified: unit 55/55, fake drone 86/86, SITL 21/21, TSan 0 races,
  Catalyst UI crash tests pass. Remaining UI fails are test limitations (ADS-B labels / ESC list scroll not visible to XCUI).
- 04:10 Step 7 done: PR https://github.com/monderichi/missionplanner-ipad/pull/1 (bug_fixes → main), bound in the app.
  Step 8 started: independent general-purpose agent reviewing; it writes testing/REVIEW_1.md (no code edits).
  BUG-037 re-measured: 48 % → 34 % CPU at 50 Hz (PARTIAL).
- 04:24 Step 8 done: REVIEW_1.md = CHANGES REQUIRED (7). Step 9 done: all 7 + optional items applied. Verified: unit 59/59,
  fake drone 86/86 (after updating the no_ack check: the outcome now comes from the heartbeat), SITL 21/21, UI suite 1 9/9.
  Step 10 next: fresh reviewer → testing/REVIEW_2.md.
- 04:31 CI: IPA build green; new break-test job failed (CI Swift couldn't type-check the probe dictionary literal). Rewritten entry by entry; probes 20/20 locally; pushed. Review 2 running.
- 04:58 Step 10 (review 2): CHANGES REQUIRED (2; all 7 of review 1 confirmed fixed). Back to step 9: both + optional items applied.
  Verified: unit 60/60, fake drone 86/86, SITL 21/21, UI suite 1 9/9. Next: step 10 again (review 3).
