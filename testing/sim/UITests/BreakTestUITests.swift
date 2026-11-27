// XCUITest repros for TESTING_RESULTS.md. Run with `testing/sim/sim.sh uitest`, which keeps
// `fake_drone.py --tcp-server 5799` running (restarting it if it exits) on the Mac; the simulator shares the
// Mac's network. Faults are switched over the drone's UDP control port 17001 from the test itself.
// Screenshots are attached to the result bundle and exported to testing/artifacts/ by sim.sh.
// NOT RUN YET (no Xcode on the test Mac when written).
import Foundation
import UIKit
import XCTest

final class BreakTestUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = true
        for f in ["nan_attitude", "bad_latlon", "fltmode_ch0", "battery_critical", "gps_loss"] { drone("fault \(f) off") }
    }

    override func tearDown() {
        shot("end-\(name)")
        app?.terminate()
    }

    // MARK: helpers

    @discardableResult
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let a = XCUIApplication()
        a.launchArguments = ["-link.kind", "TCP", "-link.host", "127.0.0.1", "-link.port", "5799",
                             "-speech.enabled", "<false/>"] + extra
        a.launch()
        app = a
        return a
    }

    /// Sends a text command to fake_drone.py's control port (127.0.0.1:17001 on the Mac).
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
        let a = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    private func connect() {
        let form = app.collectionViews.firstMatch
        XCTAssertTrue(form.waitForExistence(timeout: 5), "Connect sheet not shown (A1)")
        form.buttons["Connect"].firstMatch.tap()
        XCTAssertTrue(waitForText("ArduCopter", timeout: 10), "no vehicle within 10 s (B1)")
    }

    private func waitForText(_ s: String, timeout: TimeInterval) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", s)).firstMatch.waitForExistence(timeout: timeout)
    }

    private func assertStillRunning(_ what: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(app.state, .runningForeground, "app is not running after: \(what)", file: file, line: line)
    }

    private func tapScreen(_ title: String) { app.segmentedControls.buttons[title].tap() }

    // MARK: TESTING.md A/B

    func test_A1_B1_launchAndConnect() {
        launch()
        shot("A1-connect-sheet")
        connect()
        sleep(3)
        shot("B1-connected")
    }

    func test_B5_noHeartbeatBannerOnSilence() {
        launch(); connect()
        drone("silent 12")
        sleep(7)
        shot("B5-silent-expect-red-NO-HEARTBEAT")   // banner is drawn in a Canvas: check the screenshot
        sleep(8)
        shot("B5-recovered")
    }

    // MARK: action items

    func test_BUG001_tcpDropHidesBanner() {
        launch(); connect()
        drone("quit")            // sim.sh restarts the drone 2 s later
        sleep(7)
        shot("BUG001-after-tcp-drop-expect-banner")
        sleep(10)
        XCTAssertTrue(waitForText("ArduCopter", timeout: 5), "BUG-001: no automatic TCP reconnect")
    }

    func test_BUG003_nanAttitudeDoesNotCrash() {
        drone("fault nan_attitude on")
        launch(); connect()
        sleep(4)
        assertStillRunning("NaN ATTITUDE (BUG-003)")
        shot("BUG003-nan-attitude")
    }

    func test_BUG004_badLatLonDoesNotCrash() {
        drone("fault bad_latlon on")
        launch(); connect()
        sleep(4)
        assertStillRunning("lat 200 / lon 210 (BUG-004)")
        shot("BUG004-bad-latlon")
    }

    func test_BUG005_flightModesWithChannelDisabled() {
        drone("fault fltmode_ch0 on")
        launch(); connect()
        sleep(5) // parameters
        tapScreen("Setup")
        app.buttons["Flight modes"].firstMatch.tap()
        sleep(2)
        assertStillRunning("Setup > Flight modes with FLTMODE_CH = 0 (BUG-005)")
        shot("BUG005-flight-modes")
    }

    func test_BUG006_persistedHugeTakeoffAltitude() {
        launch(["-actions.takeoffAlt", "1e20"]); connect()
        app.buttons["Actions"].firstMatch.tap()
        sleep(2)
        assertStillRunning("Actions tab with takeoffAlt = 1e20 (BUG-006)")
        shot("BUG006-actions")
    }

    func test_BUG008_criticalBatteryVisible() {
        launch(); connect()
        drone("fault battery_critical on")
        sleep(4)
        shot("BUG008-critical-battery-expect-banner")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'battery'")).count > 1,
                      "BUG-008: no battery warning element besides the top-bar item")
    }

    func test_BUG013_disconnectWhileArmedAsksFirst() {
        launch(); connect()
        app.buttons["Actions"].firstMatch.tap()
        app.buttons["Arm"].firstMatch.tap()
        app.alerts.buttons["Arm"].tap()
        XCTAssertTrue(waitForText("ARMED", timeout: 5))
        app.buttons["Link"].firstMatch.tap()
        app.collectionViews.buttons["Disconnect"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 2), "BUG-013: no confirmation while armed")
        shot("BUG013-disconnect-armed")
    }

    func test_lifecycle_backgroundForegroundKeepsLink() {
        launch(); connect()
        XCUIDevice.shared.press(.home)
        sleep(10)
        app.activate()
        XCTAssertTrue(waitForText("ArduCopter", timeout: 8), "link not alive 8 s after returning from background")
        shot("lifecycle-after-background")
    }

    func test_lifecycle_rotation() {
        launch(); connect()
        for o in [UIDeviceOrientation.landscapeLeft, .portrait, .landscapeRight] {
            XCUIDevice.shared.orientation = o
            sleep(1)
            shot("rotation-\(o.rawValue)")
            assertStillRunning("rotation \(o.rawValue)")
        }
    }
}
