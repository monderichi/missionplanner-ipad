# Review R3-1: uncommitted BUG-037 round 3 (bug_037_split_model)

Scope: `git diff` (working tree vs `a5caccb`) for `App/Vehicle/VehicleModel.swift`, `App/Map/MapCanvas.swift`,
`App/MissionPlannerPadApp.swift`, `App/UI/{FlightDataTabs,FlightMapView,PlanView,RootView,RoverSetupPage,SetupExtraPages,SetupView,SubSetupPage,TelemetryViews}.swift`,
plus the new untracked `App/Vehicle/FastTelemetry.swift`. `gui.md` and `prototype/` are out of scope. Read only, not
compiled (Windows).

**APPROVED**

## Required changes

None. Nothing I found would break compilation, crash, freeze a displayed value or regress behaviour. The optional
notes below include the change that most limits the CPU gain (notes 1 and 2).

## Optional notes

1. **The STATUSTEXT flood still redraws every VehicleModel observer at 10 Hz** (`VehicleModel.swift:553`,
   `messages.insert(..., at: 0)`). During the flood each 100 ms batch carries about 20 STATUSTEXT, so `messages` publishes
   on every batch. That redraws HUDContainer (it observes `vehicle` too), StatusBar, FlightMapView and its MapCanvas
   (`updateUIView`, now cheap), the open Data tab, and MessagesView (a 300-row `List` whose rows all shift on every
   insert). So the flood phase gains little over round 2 (32 %). Only MapCanvas does less work now. Suggested next
   step: move `messages`, `leakDetected` and `lastAlert`/`warning` into a small `StatusLog: ObservableObject`. MessagesView,
   PrearmPage, SpeechAlerts (`v.$messages`) and Diagnostics would observe it. Or buffer the inserts and publish
   `messages` at most twice a second. HUDContainer should then observe only `fast` plus a mode/armed/link object, or take
   those values as plain parameters from a parent that redraws at 1 Hz.
2. **Unconditional @Published assignments left on VehicleModel.**
   - Every heartbeat assigns `lastHeartbeat`, `vehicleType`, `autopilot`, `armed`, `customMode` and `systemStatus`
     (`VehicleModel.swift:321-327`). That is one full-tree redraw per second, which is fine.
   - `lastHeartbeat` is read only by `CommandCenter.swift:106`, so it could drop `@Published`. The other heartbeat
     fields could use assign-if-changed.
   - Leave at least one 1 Hz publish in place, or give `messageCounts` an explicit refresh. See note 4.
   - `BATTERY_STATUS` assigns `batteryConsumedMah` and `cellVoltages` unconditionally (`:478-481`). The fake drone
     doesn't send BATTERY_STATUS, so the perf test won't show it. A real ArduPilot sends it with the SRx_EXTRA3 /
     MAVx_EXTRA3 stream, and `currentConsumed` changes while flying. Use assign-if-changed there too.
   - `MissionItemReached`, `magCalProgress` and `magCalReports` are low-rate and fine as they are.
3. **FastTelemetry still sends many `objectWillChange` per batch.** At 50 Hz, ATTITUDE, VFR_HUD and
   GLOBAL_POSITION_INT each set 3–6 fields per packet. That is several hundred sends per second, each walking every
   subscriber. SwiftUI coalesces them into one render per runloop, so this costs little. If the profile still shows
   Combine, make the fast fields plain stored properties and call `fast.objectWillChange.send()` once at the top of
   `LinkManager.apply(_:)` when the batch holds a fast message.
4. **Stale comment / slower refresh of `messageCounts`.** `VehicleModel.swift:86-87` still says the views re-read
   `messageCounts` when the batch publishes "attitude, heartbeat". Attitude now publishes on `fast`, so:
   - StatusListView still refreshes at 10 Hz, because it observes `fast`.
   - DiagnosticsView (`DiagnosticsView.swift:81`) now refreshes at about 1 Hz, from the heartbeat and LinkManager
     `stats`.

   That's acceptable. Update the comment.
5. **Vehicle marker view built by MapKit gets no transform or alpha** (`MapCanvas.swift:481-492`, together with the
   new key at `:228-249`). `viewFor` sets only the image. Rotation and the BUG-015 stale fade are applied in
   `syncVehicle`, and now only when the key changes. Suppose MapKit recreates or re-dequeues the vehicle view after
   `drawnVehicleKey` was set, for example after the user pans it off-screen and back. The arrow then points to screen
   north at full alpha until the position, yaw or staleness changes.
   - On a live link the yaw jitter changes the key at once, so this is cosmetic in practice.
   - Before this change the same gap existed while the link was silent.
   - Cheap fix in `viewFor` `.vehicle`: set `v.transform` from `parent.fast.yaw - mapView.camera.heading` (guarded by
     `isFinite`) and set `v.alpha` from `parent.vehicle.positionStale`. Or clear `drawnVehicleKey = nil` there.
6. **Follow mode re-centres only when the key changes** (`MapCanvas.swift:231`). The old code re-centred on every
   update, so a pan by the user while following was undone within 100 ms. Now it is undone at the next yaw or position
   change, which is effectively the same on a live vehicle. Note it in case a UI test pans with follow on.
7. **Views that observe only VehicleModel but read a moved value for enable state or on demand.** They refresh at about
   1 Hz now, not 10 Hz. None displays a live number, so none freezes:
   - `ActionsView.swift:136,143`: `vehicle.position == nil` in `.disabled`.
   - `SetupExtraPages.swift:189,196,202`: fixed-yaw compass "Use current" (on tap) and `.disabled(vehicle.position == nil)`.
   - `SetupView.swift:756,765`: fence quick-set compares with `vehicle.relativeAltitude` on tap and in the dialog text.
   - `FlightMapView.swift:95,232,335` and `PlanView.swift:329,385`: read on tap, or in the offline-maps estimate.
   - `DiagnosticsView.swift:36`: share report.
8. **`SubSetupPage` declares `fast` but still reads `vehicle.depth`** (`SubSetupPage.swift:8,14`). It works: an
   `@EnvironmentObject` subscribes whether or not the body reads it, and `depth` forwards to `fast.relativeAltitude`.
   `QuickView` relies on the same pattern through `TelemetryCatalogue` closures. Reading `-fast.relativeAltitude` when
   `vehicle.isSub` would make the dependency explicit.
9. **Bonus fix worth logging.** `syncTrail` now also compares `trail.last` (`MapCanvas.swift:278`). Before this, a
   full trail (3000 points, constant count) stopped redrawing. Mention it in the FIX_LOG row.
10. **Conventions and docs.**
    - BUG-037 tags are present and explain the reason. A few one-line tags (`:426`, `:431`, `:435`, `:466`) lean on the
      comment above them, which is fine.
    - `FastTelemetry.swift` has a REA Parity Source header.
    - MAVLinkKit is untouched (`git status Packages` is clean).
    - The new file is LF.
    - `py -3 -I tools/audit_params.py` gives "345 names, 75 missing on Copter, 0 in no firmware: []".
    - Rule 4.7 still to do: a FIX_LOG row for round 3, and the BUG-037 status in TESTING_RESULTS section 9 with the
      measured perf numbers. It stays PARTIAL unless the perf run reaches < 15 %.

## What I checked

- **Compile.**
  - Every `!=`/`==` is on an Equatable type: `ESCInfo` (already `Equatable`), `Traffic` (`Equatable`), `GeoPoint`
    (`Equatable, Hashable`), arrays and dictionaries of those, and `Optional<Double>`/`Optional<Int>` against a
    non-optional (promotion).
  - `let meMoved: Bool` is assigned in both branches.
  - The empty then-branch in `syncVehicle` (comment only) is legal Swift.
  - The literals are annotated: `let key: [Double]`, `[UInt16]`, `[Double]`, `[UInt32]`.
  - `fast.trail.removeFirst(fast.trail.count - …)` follows the same pattern as before; the argument is evaluated
    before the mutating access.
  - The `MapCanvas` memberwise init order is `vehicle:, fast:, mission:`. Both call sites (`FlightMapView.swift:33`,
    `PlanView.swift:70`) match.
  - Views that dropped `vehicle` (RootView, ServoView, RoverSetupPage, ServoRow) have no remaining `vehicle`
    references.
  - FastTelemetry's writers are all inside VehicleModel. Its properties are internal `var`, so there is no
    `private(set)` problem.
  - No `$roll`-style publisher of a moved property is used anywhere. SpeechAlerts subscribes only to `customMode`,
    `armed`, `heartbeatAlive`, `messages`, `leakDetected` and `batteryRemaining`, which all stayed on VehicleModel.
  - `RadioPage.onChange(of: fast.rcChannels)` still fires on change.
  - Harness: `build_harness.sh` copies `App/Vehicle/*.swift` (FastTelemetry is included; it has the same imports as
    VehicleModel). `testing/harness/Sources` (Fuzz, main, Scenarios) only reads the forwarded names.
  - UITests: no references to moved names. `Packages/` is unaffected. `project.yml` includes `App/` by path, so the new
    file is picked up.
- **Stale UI.** I grepped all of `App/` for every moved name and for `position`, `depth` and `trail`. Every view that
  displays one live observes `fast`:
  - HUDContainer (also covers `depth`), QuickView (TelemetryCatalogue closures), StatusListView, ESCStatusSection
    (it also keeps `vehicle` for battery details), ServoView, ChecklistView.
  - Prearm, Radio, FlightModes, Servo and Rover setup pages; SubSetupPage.
  - MapCanvas, which observes both objects, so `updateUIView` still runs on `fast` changes.
  - GraphView samples on a 5 Hz timer, so it is unaffected.
- **Injection.** `.environmentObject(link.vehicle.fast)` is on the app root. Every `fast` consumer lives in the root
  hierarchy (RootView tabs, SetupView pages). None is in a sheet: the sheets are ConnectView, DiagnosticsView/InspectorView,
  MissionItemEditor, the param sheets, offline maps and log review, and none of them declares `fast`. On iOS 16, sheets
  inherit the environment anyway, as DiagnosticsView already relies on. There is no `UIHostingController`. No previews.
- **MapCanvas caches.**
  - First add: `drawnVehicleKey` is set only once `map.view(for:)` exists, so it retries.
  - Removal on `position == nil` resets both flags.
  - Map rotation and vehicle type are in the key. NaN is handled by bit patterns.
  - Home: re-applied when `home` changes. After `reset()` it stays at the old place, the same as before.
  - Trail: `clearTrail()`/`reset()` gives count 0, so the overlay is removed.
  - Traffic: Disconnect sets `traffic = [:]` while annotations exist, so they are removed. `lastSeen` makes each new
    ADSB packet unequal, so the annotations update. Map rotation and own-position (5 m) changes refresh the labels.
  - Nothing else removes the vehicle or home annotation (`drawPlan` removes only `planAnnotations`), so the new flags
    can't go stale.
- **Assign-if-changed.** Each one compares the newly computed value with the stored one before assigning, so nothing
  is missed. `reset()` writes through to `fast` and the published properties directly.
- **Goal estimate.**
  - With the perf fake drone (`testing/fake_drone/fake_drone.py:111-114`: 8 streams at 50 Hz, no BATTERY_STATUS), the
    50 Hz phase should now publish VehicleModel only at about 1–2 Hz: heartbeat, plus SYS_STATUS voltage if the battery
    drains. Only the HUD, the open tab and MapCanvas redraw at 10 Hz, so a clear drop from 26 % is plausible.
  - The flood phase is still bounded by note 1.
  - Overall < 15 % is unlikely until note 1 is done.

## macOS checks required before merging

1. `testing/unit/run_unit_tests.sh` → `RESULT: 67 tests, 0 failed` (or more).
2. `B=$(testing/harness/build_harness.sh | tail -1)` must build. It compiles the new `FastTelemetry.swift` and the
   changed `VehicleModel.swift`. Then `HARNESS_BIN=$B python3 testing/scenarios/run.py -j 4 all` → all PASS (86).
3. `testing/sim/catalyst.sh build`: the first real compile of the SwiftUI and MapCanvas changes.
4. `testing/sim/catalyst.sh uitest` → all pass.
5. `testing/sim/catalyst.sh perf BreakTestUITests2/test_perf_highRateAndFlood`. Record average CPU per phase (50 Hz vs
   flood) and RSS against round 2 (26 % / 32 %, 29 % average) in FIX_LOG and TESTING_RESULTS.
6. Manual look in the Catalyst app with `fake_drone.py`, about 5 minutes:
   - the map vehicle arrow appears, moves and rotates, including with the map rotated;
   - follow on/off; trail, then Clear trail;
   - `fault adsb on`: traffic shows, then clears on Disconnect;
   - Setup › Radio bars move, Calibrate radio captures min/max, Servo tab and Setup › Servo PWM update;
   - Status tab values update;
   - `vtype 12`: HUD depth and Sub page depth update.
