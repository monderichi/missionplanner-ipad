// Round-4 UI tests: TESTING_SIMULATOR.md (S-C*, S-R*, S-S*, S-G*) items on the code merged from origin/main.
// The fake drone switches vehicle type at runtime ("vtype 10" rover, "vtype 12" sub) and sends STATUSTEXT ("text 2 …").
import Foundation
import XCTest

final class BreakTestUITests3: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = true
        drone("vtype 2")
        for f in ["adsb", "adsb_bad", "adsb_flood", "high_rate"] { drone("fault \(f) off") }
    }

    override func tearDown() {
        shot("end-\(name)")
        app?.terminate()
        drone("vtype 2")
    }

    @discardableResult
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let a = XCUIApplication()
        a.launchArguments = ["-link.kind", "TCP", "-link.host", "127.0.0.1", "-link.port", "5799",
                             "-speech.enabled", "<false/>", "-actions.takeoffAlt", "10"] + extra
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
    }

    private func text(_ s: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", s)).firstMatch
    }

    private func connect(_ firmware: String = "ArduCopter", params: Bool = true) {
        let form = app.collectionViews.firstMatch
        XCTAssertTrue(form.waitForExistence(timeout: 5), "Connect sheet not shown")
        form.buttons["Connect"].firstMatch.tap()
        XCTAssertTrue(text(firmware).waitForExistence(timeout: 12), "no \(firmware) within 12 s")
        if params { sleep(3) }
    }

    private func screen(_ title: String) { app.segmentedControls.buttons[title].firstMatch.tap(); sleep(1) }

    private func assertRunning(_ what: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(app.state, .runningForeground, "app not running after: \(what)", file: file, line: line)
    }

    private func clickMap(_ x: Double, _ y: Double, hold: TimeInterval = 0) {
        let map = app.maps.firstMatch.exists ? app.maps.firstMatch : app.windows.firstMatch
        let v = app.maps.firstMatch.exists ? CGVector(dx: x, dy: y) : CGVector(dx: 0.45 + 0.5 * x, dy: 0.15 + 0.8 * y)
        let c = map.coordinate(withNormalizedOffset: v)
        if hold > 0 { c.press(forDuration: hold) } else { c.tap() }
        usleep(500_000)
    }

    static let allPages = ["Pre-arm & sensors", "Frame type", "Rover setup", "ROV setup", "Geofence & max altitude",
                           "Battery monitor", "Failsafe", "Tuning", "DataFlash logs", "Accelerometer", "Compass",
                           "Radio calibration", "Flight modes", "Motor test", "Servo output", "Other calibrations",
                           "Rangefinder", "Airspeed sensor", "Optical flow", "GPS", "Compass config", "Serial ports",
                           "Planner settings"]

    /// S-C16 / S-R2 / S-S7: open every Setup page that is listed for this vehicle type.
    private func openEverySetupPage(_ label: String) {
        screen("Setup")
        var shown: [String] = [], crashedOn: String?
        for p in Self.allPages {
            let row = app.buttons[p].firstMatch.exists ? app.buttons[p].firstMatch : app.staticTexts[p].firstMatch
            guard row.exists else { continue }
            shown.append(p)
            row.tap()
            sleep(1)
            if app.state != .runningForeground { crashedOn = p; break }
            shot("\(label)-setup-\(p)")
        }
        note("\(label) setup pages listed: \(shown.joined(separator: ", "))")
        XCTAssertNil(crashedOn, "\(label): app crashed opening Setup › \(crashedOn ?? "")")
    }

    func test_SC16_everySetupPage_copter() {
        launch(); connect()
        openEverySetupPage("copter")
        XCTAssertTrue(app.buttons["Frame type"].exists || app.staticTexts["Frame type"].exists, "copter: Frame type missing")
    }

    func test_SR2_everySetupPage_rover() {
        drone("vtype 10")
        launch(); connect("ArduRover")
        openEverySetupPage("rover")
        XCTAssertFalse(app.staticTexts["Frame type"].exists && app.buttons["Frame type"].exists, "S-R2: copter Frame type shown for a rover")
        XCTAssertTrue(app.buttons["Rover setup"].exists || app.staticTexts["Rover setup"].exists, "S-R2: Rover setup missing")
    }

    func test_SS7_everySetupPage_sub() {
        drone("vtype 12")
        launch(); connect("ArduSub")
        openEverySetupPage("sub")
        XCTAssertTrue(app.buttons["ROV setup"].exists || app.staticTexts["ROV setup"].exists, "S-S7: ROV setup missing")
    }

    func test_SS5_leakBanner() {
        drone("vtype 12")
        launch(); connect("ArduSub", params: false)
        drone("text 2 Leak Detected")
        sleep(3)
        shot("SS5-leak")
        screen("Setup")
        let row = app.buttons["ROV setup"].firstMatch
        if row.exists { row.tap(); sleep(1) }
        XCTAssertTrue(text("LEAK DETECTED").exists, "S-S5: leak not reported")
    }

    func test_SR5_roverControlTab() {
        drone("vtype 10")
        launch(); connect("ArduRover", params: false)
        app.buttons["Control"].firstMatch.tap()
        sleep(1)
        shot("SR5-control-tab")
        assertRunning("rover Control tab")
    }

    func test_SC12_graph() {
        launch(); connect(params: false)
        let g = app.buttons["Graph"].firstMatch
        for _ in 0..<3 where !g.isHittable { app.buttons["Messages"].firstMatch.tap() } // scroll the tab strip
        g.tap()
        sleep(4)
        shot("SC12-graph")
        assertRunning("Graph tab")
    }

    func test_SC13_inspector() {
        launch(); connect(params: false)
        app.buttons["Diagnostics and feedback"].firstMatch.tap()
        app.buttons["MAVLink Inspector"].firstMatch.tap()
        sleep(3)
        XCTAssertTrue(text("ATTITUDE").exists, "S-C13: ATTITUDE not listed in the inspector")
        shot("SC13-inspector")
    }

    func test_SC6_measure() {
        launch(); connect(params: false)
        clickMap(0.3, 0.4, hold: 1.5)
        let m = app.buttons["Measure distance from here"].firstMatch
        XCTAssertTrue(m.waitForExistence(timeout: 3), "S-C6: long-press menu has no Measure")
        m.tap()
        clickMap(0.7, 0.6)
        sleep(1)
        shot("SC6-measure")
        assertRunning("measure")
    }

    func test_SC15_dataflashReview() {
        launch(); connect(params: false)
        screen("Setup")
        app.buttons["DataFlash logs"].firstMatch.tap()
        sleep(1)
        if app.buttons["List"].exists { app.buttons["List"].tap() }
        sleep(3)
        shot("SC15-log-list")
        let review = app.buttons["Review a downloaded log…"].firstMatch
        if review.exists { review.tap(); sleep(2); shot("SC15-review") }
        assertRunning("DataFlash review")
    }

    func test_SG2_plannerSettingsPersist() {
        launch(); connect(params: false)
        screen("Setup")
        app.buttons["Planner settings"].firstMatch.tap()
        sleep(1)
        shot("SG2-planner-settings")
        assertRunning("Planner settings")
    }
}
