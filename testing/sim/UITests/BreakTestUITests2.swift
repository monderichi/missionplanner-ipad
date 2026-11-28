// Round-3 UI tests (Mac Catalyst or iPad Simulator): every remaining screen of TESTING.md that the Mac can drive.
// Same harness as BreakTestUITests.swift: fake_drone.py on 127.0.0.1:5799 (control port 17001), app data isolated
// via BREAKTEST_HOME. Tests named test_Z* are expected to CRASH or FAIL until the bug in their name is fixed.
// Results and screenshots: testing/sim/catalyst.sh uitest → testing/artifacts/catalyst/<run>/.
import Foundation
import XCTest

final class BreakTestUITests2: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = true
        for f in ["nan_attitude", "bad_latlon", "fltmode_ch0", "battery_critical", "gps_loss", "high_rate",
                  "statustext_flood", "reject_arm", "adsb", "adsb_bad", "adsb_flood"] { drone("fault \(f) off") }
    }

    override func tearDown() {
        shot("end-\(name)")
        app?.terminate()
    }

    // MARK: helpers (kept local so this file stands alone)

    @discardableResult
    private func launch(_ extra: [String] = [], dark: Bool? = nil) -> XCUIApplication {
        let a = XCUIApplication()
        a.launchArguments = ["-link.kind", "TCP", "-link.host", "127.0.0.1", "-link.port", "5799",
                             "-speech.enabled", "<false/>", "-actions.takeoffAlt", "10"] + extra
        if let dark { a.launchArguments += ["-AppleInterfaceStyle", dark ? "Dark" : "Light"] }
        if let home = ProcessInfo.processInfo.environment["BREAKTEST_HOME"] { a.launchEnvironment["CFFIXED_USER_HOME"] = home }
        a.launch()
        app = a
        return a
    }

    private func drone(_ cmd: String) {
        let s = socket(AF_INET, SOCK_DGRAM, 0)
        defer { close(s) }
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = UInt16(17001).bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")
        let bytes = Array(cmd.utf8)
        _ = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                sendto(s, bytes, bytes.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
    }

    private func shot(_ name: String) {
        guard let app, app.state == .runningForeground else { return }
        let a = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    private func note(_ text: String) {
        let a = XCTAttachment(string: text)
        a.name = "note-\(name)"
        a.lifetime = .keepAlways
        add(a)
        print("NOTE \(name): \(text)")
    }

    private func text(_ s: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", s)).firstMatch
    }

    private func connect(params: Bool = true) {
        let form = app.collectionViews.firstMatch
        XCTAssertTrue(form.waitForExistence(timeout: 5), "Connect sheet not shown")
        form.buttons["Connect"].firstMatch.tap()
        XCTAssertTrue(text("ArduCopter").waitForExistence(timeout: 10), "no vehicle within 10 s")
        if params { sleep(3) } // ~400 params on a clean link
    }

    private func screen(_ title: String) { app.segmentedControls.buttons[title].firstMatch.tap(); sleep(1) }

    private func tab(_ title: String) { app.buttons[title].firstMatch.tap(); sleep(1) }

    /// Clicks the map at a normalised position inside the map view (right-hand side of the window).
    private func clickMap(_ x: Double, _ y: Double, hold: TimeInterval = 0) {
        let map = app.maps.firstMatch.exists ? app.maps.firstMatch : app.windows.firstMatch
        let base = app.maps.firstMatch.exists ? CGVector(dx: x, dy: y) : CGVector(dx: 0.45 + 0.5 * x, dy: 0.15 + 0.8 * y)
        let c = map.coordinate(withNormalizedOffset: base)
        if hold > 0 { c.press(forDuration: hold) } else { c.tap() }
        usleep(400_000)
    }

    /// SwiftUI `Menu` is a menu button on Mac Catalyst and a button on iPad.
    private func openMenu(_ title: String) {
        let candidates = [app.menuButtons[title].firstMatch, app.popUpButtons[title].firstMatch, app.buttons[title].firstMatch,
                          app.descendants(matching: .any).matching(NSPredicate(format: "label == %@ OR identifier == %@", title, title)).firstMatch]
        (candidates.first(where: { $0.exists }) ?? candidates[0]).tap()
        usleep(500_000)
    }

    private func menuItem(_ title: String) -> XCUIElement {
        let mi = app.menuItems[title].firstMatch
        return mi.exists ? mi : app.buttons[title].firstMatch
    }

    private func waypointRows() -> Int { app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).count }

    private func dialogButton(_ title: String) -> XCUIElement {
        for q in [app.alerts, app.sheets, app.dialogs] where q.buttons[title].exists { return q.buttons[title] }
        let all = app.buttons.matching(identifier: title)
        return all.count > 1 ? all.element(boundBy: all.count - 1) : all.firstMatch
    }

    private func assertRunning(_ what: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(app.state, .runningForeground, "app not running after: \(what)", file: file, line: line)
    }

    // MARK: E3 / E5 / E6 / E7 Plan

    func test_E3_E4_planEditWriteRead() {
        launch(); connect()
        screen("Plan")
        if app.switches["Add on tap"].exists, (app.switches["Add on tap"].value as? String) == "0" { app.switches["Add on tap"].tap() }
        for (x, y) in [(0.3, 0.3), (0.6, 0.3), (0.6, 0.6), (0.3, 0.6)] { clickMap(x, y) }
        let wps = app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).count
        note("waypoint rows after 4 map clicks: \(wps)")
        XCTAssertGreaterThanOrEqual(wps, 4, "E3: map clicks did not add 4 waypoints")
        if app.buttons["+ Takeoff"].exists { app.buttons["+ Takeoff"].tap() }
        if app.buttons["+ RTL"].exists { app.buttons["+ RTL"].tap() }
        shot("E3-plan-with-waypoints")
        // edit a waypoint: open the first "Waypoint" row, change altitude, Done
        app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 3), "E3: item editor did not open")
        shot("E3-item-editor")
        app.buttons["Done"].tap()
        app.buttons["Write"].firstMatch.tap()
        XCTAssertTrue(text("accepted").waitForExistence(timeout: 15), "E4: write not confirmed")
        app.buttons["Clear"].firstMatch.tap()
        dialogButton("Clear").tap()
        app.buttons["Read"].firstMatch.tap()
        let done = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Read ' AND label CONTAINS 'items'")).firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 15), "E4: read not confirmed")
        sleep(1)
        let back = app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).count
        XCTAssertEqual(back, wps, "E4: read-back count differs")
        shot("E4-read-back")
    }

    func test_E5_saveWaypointsFile() {
        launch(); connect()
        screen("Plan")
        for (x, y) in [(0.4, 0.4), (0.6, 0.5)] { clickMap(x, y) }
        openMenu("File")
        menuItem("Save .waypoints").tap()
        sleep(2)
        // The confirmation is a sheet on Mac whose text XCUITest can't read: check the file itself.
        if let home = ProcessInfo.processInfo.environment["BREAKTEST_HOME"] {
            let dir = URL(fileURLWithPath: home).appendingPathComponent("Documents/missions")
            let recent = ((try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey])) ?? [])
                .filter { $0.pathExtension == "waypoints" }
                .filter { (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
                    .map { Date().timeIntervalSince($0) < 30 } ?? false }
            XCTAssertFalse(recent.isEmpty, "E5: no .waypoints file written")
        } else {
            XCTAssertTrue(text("Saved to Files").waitForExistence(timeout: 5), "E5: no save confirmation")
        }
        shot("E5-saved")
    }

    func test_E6_surveyGrid() {
        launch(); connect()
        screen("Plan")
        app.segmentedControls.buttons["Survey"].firstMatch.tap()
        for (x, y) in [(0.3, 0.3), (0.7, 0.3), (0.7, 0.7), (0.3, 0.7)] { clickMap(x, y) }
        shot("E6-survey-outline")
        let gen = app.buttons["Generate into mission"].firstMatch
        XCTAssertTrue(gen.waitForExistence(timeout: 3), "E6: Generate button missing")
        gen.tap()
        app.segmentedControls.buttons["Mission"].firstMatch.tap()
        let n = app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).count
        note("mission rows after survey: \(n)")
        XCTAssertGreaterThan(n, 4, "E6: no lawn-mower grid appended")
        shot("E6-survey-generated")
    }

    func test_E7_fenceAndRally() {
        launch(); connect()
        screen("Plan")
        app.segmentedControls.buttons["Fence"].firstMatch.tap()
        for (x, y) in [(0.3, 0.3), (0.7, 0.3), (0.7, 0.7), (0.3, 0.7)] { clickMap(x, y) }
        app.buttons["Write"].firstMatch.tap()
        XCTAssertTrue(text("accepted").waitForExistence(timeout: 15), "E7: fence write not confirmed")
        app.segmentedControls.buttons["Rally"].firstMatch.tap()
        clickMap(0.5, 0.5)
        app.buttons["Write"].firstMatch.tap()
        XCTAssertTrue(text("accepted").waitForExistence(timeout: 15), "E7: rally write not confirmed")
        shot("E7-fence-rally")
    }

    func test_Z5_BUG007_editorLatitude300() {
        launch(); connect()
        screen("Plan")
        clickMap(0.25, 0.3) // away from the home/vehicle markers in the centre
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).firstMatch.waitForExistence(timeout: 3))
        app.staticTexts.matching(NSPredicate(format: "label == 'Waypoint'")).firstMatch.tap()
        let lat = app.textFields["Latitude"].firstMatch
        XCTAssertTrue(lat.waitForExistence(timeout: 3))
        lat.tap()
        lat.typeKey("a", modifierFlags: .command)
        lat.typeText("300\n")
        if app.buttons["Done"].exists { app.buttons["Done"].tap() }
        sleep(2)
        assertRunning("latitude 300 typed in the waypoint editor (BUG-007)")
    }

    // MARK: G3 fly here (click-and-hold)

    func test_G3_flyHereClickHold() {
        launch(); connect()
        clickMap(0.6, 0.4, hold: 1.5)
        let dialog = app.alerts.firstMatch.exists ? app.alerts.firstMatch : app.sheets.firstMatch
        XCTAssertTrue(text("Fly here").waitForExistence(timeout: 3) || dialog.exists, "G3: no Fly-here prompt on click-and-hold")
        shot("G3-fly-here-prompt")
        let alt = app.textFields.firstMatch
        if alt.exists {
            alt.tap(); alt.typeKey("a", modifierFlags: .command); alt.typeText("-5")
            shot("G3-negative-altitude-typed")
            dialogButton("Fly here").tap()
            sleep(2)
            note("after Fly here at -5 m: banner '\(text("Flying to").exists ? "Flying to … shown" : "none")'")
            XCTAssertFalse(text("at -5 m").exists, "BUG-006/-011: Fly-here accepted a negative altitude")
        }
    }

    // MARK: Setup pages D1 D4 D6 D7 D8

    private func setupPage(_ title: String) {
        screen("Setup")
        let row = app.buttons[title].firstMatch.exists ? app.buttons[title].firstMatch : app.staticTexts[title].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 3), "Setup row \(title) missing")
        row.tap()
        sleep(1)
    }

    func test_D1_prearmButton() {
        drone("fault reject_arm on")
        launch(); connect()
        setupPage("Pre-arm & sensors")
        app.buttons["Run pre-arm checks now"].firstMatch.tap()
        XCTAssertTrue(text("PreArm").waitForExistence(timeout: 6), "D1: PreArm reason not shown")
        shot("D1-prearm")
    }

    func test_D4_radioBars() {
        launch(); connect()
        setupPage("Radio calibration")
        sleep(2)
        XCTAssertTrue(text("CH1").exists, "D4: RC channel rows not shown")
        let grouped = text("1.500").exists || text("1,500").exists
        if grouped { note("BUG-036: PWM 1500 is shown with a locale grouping separator (\"1.500\"/\"1,500\")") }
        XCTAssertTrue(text("1500").exists || text("1300").exists, "D4/BUG-036: RC values not shown as plain µs (grouped: \(grouped))")
        shot("D4-radio")
    }

    func test_D6_motorTestLockouts() {
        launch(); connect()
        setupPage("Motor test")
        let a = app.buttons["A"].firstMatch
        XCTAssertTrue(a.exists && !a.isEnabled, "D6: motor buttons must be disabled until 'props removed' is ticked")
        app.switches.firstMatch.tap()
        XCTAssertTrue(a.isEnabled, "D6: motor buttons not enabled after ticking props removed")
        a.tap()
        XCTAssertTrue(text("accepted").waitForExistence(timeout: 5) || text("Motor A").exists, "D6: no result for motor A")
        shot("D6-motor-test")
    }

    func test_D7_fencePage() {
        launch(); connect()
        setupPage("Geofence & max altitude")
        XCTAssertTrue(app.buttons["Apply altitude limit"].firstMatch.waitForExistence(timeout: 3), "D7: Apply button missing")
        shot("D7-fence-page")
    }

    func test_Z6_BUG018_batteryCalibrationNoConfirm() {
        launch(); connect()
        setupPage("Battery monitor")
        let field = app.textFields["V"].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap(); field.typeText("1.64\n")
        app.buttons["Calibrate voltage"].firstMatch.tap()
        sleep(1)
        let asked = app.alerts.count + app.sheets.count > 0
        shot("BUG018-battery-cal")
        XCTAssertTrue(asked, "BUG-018: a 10x voltage calibration change was applied without any confirmation")
    }

    // MARK: C4 / F1 / F4 / F5 / B4 / A2 / B6

    func test_C4_paramEditorListsAndBitmask() {
        launch(); connect()
        screen("Params")
        let search = app.textFields["Search name or description"].firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap(); search.typeText("FRAME_CLASS")
        app.staticTexts["FRAME_CLASS"].firstMatch.tap()
        XCTAssertTrue(text("Quad").waitForExistence(timeout: 3), "C4: FRAME_CLASS value list not shown")
        shot("C4-frame-class")
        if app.buttons["Cancel"].exists { app.buttons["Cancel"].tap() } else { app.typeKey(.escape, modifierFlags: []) }
        search.tap(); search.typeKey("a", modifierFlags: .command); search.typeText("ARMING_CHECK")
        app.staticTexts["ARMING_CHECK"].firstMatch.tap()
        XCTAssertTrue(app.switches.count + app.checkBoxes.count > 3, "C4: ARMING_CHECK bitmask checkboxes not shown")
        shot("C4-arming-check")
    }

    func test_F1_checklist() {
        launch(); connect()
        tab("Checklist")
        XCTAssertTrue(text("GPS").exists, "F1: checklist rows missing")
        shot("F1-checklist")
    }

    func test_F4_servoMotorOutputsGreyed() {
        launch(); connect()
        tab("Servo")
        let lows = app.buttons.matching(identifier: "Low")
        XCTAssertGreaterThanOrEqual(lows.count, 8)
        XCTAssertFalse(lows.element(boundBy: 0).isEnabled, "F4: Out 1 (motor) override enabled")
        XCTAssertTrue(lows.element(boundBy: 4).isEnabled, "F4: Out 5 (non-motor) override disabled")
        shot("F4-servo")
    }

    func test_B4_escTelemetryInStatus() {
        launch(); connect()
        tab("Status")
        let esc = text("rpm")
        let list = app.collectionViews.count > 0 ? app.collectionViews.element(boundBy: app.collectionViews.count - 1) : app.tables.firstMatch
        for _ in 0..<8 where !esc.exists { list.swipeDown(velocity: .fast) }
        for _ in 0..<12 where !esc.exists { list.swipeUp(velocity: .slow) }
        XCTAssertTrue(esc.exists, "B4: ESC telemetry rows not shown in Status")
        shot("B4-esc")
    }

    func test_A2_B6_diagnostics() {
        launch(); connect()
        app.buttons["Diagnostics and feedback"].firstMatch.tap()
        XCTAssertTrue(text("0.4.0").waitForExistence(timeout: 3) || text("Version").exists, "A2: version not shown")
        shot("A2-B6-diagnostics")
    }

    func test_F5_replayBar() {
        launch(); connect()
        sleep(4) // record a few seconds of tlog
        app.buttons["Link"].firstMatch.tap()
        let log = app.buttons.containing(NSPredicate(format: "label CONTAINS '.tlog'")).firstMatch
        XCTAssertTrue(log.waitForExistence(timeout: 3), "F5: no tlog listed under Replay")
        log.tap()
        sleep(3)
        shot("F5-replay")
        XCTAssertTrue(text("Replaying").exists || app.sliders.count > 0, "F5: replay bar not shown")
    }

    // MARK: accessibility, appearance, offline maps, performance

    func test_a11y_audit() throws {
        guard #available(iOS 17.0, macCatalyst 17.0, *) else { throw XCTSkip("needs iOS 17 / Catalyst 17") }
        launch(); connect()
        var issues: [String] = []
        for s in ["Data", "Plan", "Setup", "Params"] {
            screen(s)
            try? app.performAccessibilityAudit { issue in
                issues.append("\(s): \(issue.auditType) \(issue.compactDescription) [\(issue.element?.label ?? "?")]")
                return true // collect, don't fail per issue
            }
        }
        note("accessibility issues (\(issues.count)):\n" + issues.joined(separator: "\n"))
    }

    func test_appearance_lightAndDark() {
        for dark in [false, true] {
            launch(dark: dark); connect(params: false)
            shot("appearance-\(dark ? "dark" : "light")-data")
            screen("Plan"); shot("appearance-\(dark ? "dark" : "light")-plan")
            app.terminate()
        }
    }

    func test_E1_offlineMapsTinyArea() {
        launch(); connect(params: false)
        openMenu("Map")
        let item = menuItem("Offline maps…")
        XCTAssertTrue(item.waitForExistence(timeout: 3), "E1: Offline maps menu item missing")
        item.tap()
        // Only the sheet and the tile estimate are checked: no download, to stay well inside Esri's usage terms
        // (the smallest 1 km area at zoom 17 + 2 km extra detail is still hundreds of tiles).
        XCTAssertTrue(text("Offline maps").waitForExistence(timeout: 3), "E1: Offline maps sheet not shown")
        XCTAssertTrue(app.sliders.count > 0, "E1: radius slider missing")
        shot("E1-offline-sheet")
    }

    /// Runs ~2 min at 50 Hz telemetry + 200 STATUSTEXT/s; catalyst.sh perf samples the app's CPU and memory meanwhile.
    func test_perf_highRateAndFlood() {
        launch(); connect()
        drone("fault high_rate on")
        sleep(60)
        drone("fault statustext_flood on")
        sleep(60)
        drone("fault statustext_flood off"); drone("fault high_rate off")
        assertRunning("2 min of 50 Hz telemetry + STATUSTEXT flood")
        shot("perf-after-load")
    }

    /// Long session (default 30 min, BREAKTEST_LONG_MIN overrides): plain telemetry, memory sampled by catalyst.sh perf.
    func test_perf_longSession() {
        let minutes = Int(ProcessInfo.processInfo.environment["BREAKTEST_LONG_MIN"] ?? "30") ?? 30
        launch(); connect()
        for _ in 0..<minutes { sleep(60); if app.state != .runningForeground { break } }
        assertRunning("\(minutes) min session")
        shot("perf-long-session")
    }

    // MARK: ADS-B (merged from origin/main)

    func test_ADSB_trafficShownOnMap() {
        launch(); connect(params: false)
        drone("fault adsb on")
        sleep(4)
        assertRunning("ADS-B traffic")
        XCTAssertTrue(text("TEST0").exists || text("TEST1").exists, "ADS-B traffic labels not shown on the map")
        shot("ADSB-traffic")
    }

    func test_Z7_adsbOutOfRangeCoordinate() {
        launch(); connect(params: false)
        drone("fault adsb_bad on")
        sleep(5)
        assertRunning("ADSB_VEHICLE at lat 200 / lon 210 (expected to be rejected)")
        shot("ADSB-bad-coordinate")
    }

    /// 200 new aircraft per second for 60 s (12 000 unique ICAO): sampled by `catalyst.sh perf`.
    func test_perf_adsbFlood() {
        launch(); connect(params: false)
        drone("fault adsb_flood on")
        sleep(60)
        drone("fault adsb_flood off")
        sleep(5)
        assertRunning("ADS-B flood")
        shot("ADSB-flood")
    }
}
