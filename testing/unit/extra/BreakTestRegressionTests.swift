// Added by the break-test (see TESTING_RESULTS.md). Plain XCTest, so these files can be moved into
// Packages/MAVLinkKit/Tests/MAVLinkKitTests/ unchanged. Tests named test_BUG_xxx FAIL on c14c3e1 and
// must pass once that bug is fixed; test_cov_* cover thin areas and pass today.
import XCTest
@testable import MAVLinkKit

final class BreakTestRegressionTests: XCTestCase {
    private func ack(_ cmd: UInt16, _ result: UInt8 = 0) -> MAV.CommandAck {
        MAV.CommandAck(command: cmd, result: result, progress: 0, resultParam2: 0, targetSystem: 255, targetComponent: 190)
    }

    /// BUG-002: CommandSession keys pending commands by command id only, so Disarm sent before the
    /// Arm ACK arrives is completed by the Arm ACK and never retried.
    func test_BUG002_disarmNotCompletedByEarlierArmAck() {
        let s = CommandSession(targetSystem: 1)
        _ = s.arm(true, now: 0)
        _ = s.arm(false, now: 0.1)
        _ = s.handle(ack(MAVCmd.componentArmDisarm), now: 0.2)  // this ACK answers the ARM
        let r = s.tick(now: 5)
        // The disarm must still be outstanding (retried) or reported as superseded, never "accepted".
        XCTAssertTrue(!s.pendingCommands.isEmpty || !r.messages.isEmpty, "disarm was silently dropped")
    }

    /// BUG-002 variant: two mode changes in a row, only the first reached the vehicle.
    func test_BUG002_secondModeChangeRetriedAfterFirstAck() {
        let s = CommandSession(targetSystem: 1)
        _ = s.setMode(5, now: 0)          // LOITER (delivered)
        _ = s.setMode(6, now: 0.05)       // RTL (lost on the link)
        let ev = s.handle(ack(MAVCmd.doSetMode), now: 0.3) // ACK for LOITER
        XCTAssertNotEqual(ev, [.accepted(command: MAVCmd.doSetMode)], "RTL reported accepted from LOITER's ACK")
    }

    /// BUG-020: ParamFile.parse accepts nan/inf, which are then offered as writes in Load/Compare.
    func test_BUG020_paramFileRejectsNonFinite() {
        let f = ParamFile.parse("A_NAN,nan\nB_INF,inf\nC_OK,1.5\n")
        XCTAssertEqual(f.keys.sorted(), ["C_OK"])
    }

    /// BUG-007: WaypointFile.parse must reject coordinates that MissionItem can't hold, with an error
    /// (today it traps in MissionItem.init: Int32((latitude * 1e7).rounded())). Uses out-of-range
    /// values that are still Int32-safe so this test reports instead of crashing the run.
    func test_BUG007_waypointFileRejectsOutOfRangeLatitude() {
        let text = "QGC WPL 110\n0\t1\t0\t16\t0\t0\t0\t0\t95.0\t200.0\t584\t1\n"
        XCTAssertThrowsError(try WaypointFile.parse(text))
    }

    // MARK: coverage for thin areas (pass today)

    func test_cov_parserSurvivesOversizedLengthAndNoise() {
        let p = MAVLinkParser()
        let sender = MAVLinkSender(systemID: 1, componentID: 1)
        var bytes: [UInt8] = [0xFD, 255, 0, 0, 0, 1, 1, 30, 0, 0] + [UInt8](repeating: 0x55, count: 40)
        bytes += sender.pack(MAV.Heartbeat(type: 2, autopilot: 3))
        bytes += (0..<600).map { _ in UInt8.random(in: 0...255) }
        bytes += sender.pack(MAV.Heartbeat(type: 2, autopilot: 3))
        let out = p.parse(bytes)
        XCTAssertGreaterThanOrEqual(out.filter { $0.messageID == 0 }.count, 1)
    }

    func test_cov_duplicatesDoNotCountAsLoss() {
        let p = MAVLinkParser()
        let s = MAVLinkSender(systemID: 1, componentID: 1)
        for _ in 0..<20 {
            let f = s.pack(MAV.Heartbeat(type: 2, autopilot: 3))
            _ = p.parse(f + f)
        }
        XCTAssertEqual(p.stats.packetsLost, 0)
        XCTAssertEqual(p.stats.packetsReceived, 40)
    }

    func test_cov_paramSessionSetTimesOutWhenNoEcho() {
        let s = ParameterSession(targetSystem: 1)
        _ = s.set("NO_SUCH", value: 1, now: 0)
        var events: [ParameterSession.Event] = []
        var t = 0.0
        while t < 30 { t += 0.25; events += s.tick(now: t).events }
        XCTAssertTrue(events.contains(.setTimedOut(name: "NO_SUCH")), "\(events)")
        XCTAssertTrue(s.pendingSetNames.isEmpty)
    }

    func test_cov_waypointFileRoundTripKeepsPrecision() throws {
        let items = [MissionItem(frame: MAVFrame.global, latitude: -35.3632621, longitude: 149.1652374, altitude: 584),
                     MissionItem(command: MissionCmd.loiterTime, param1: 12.5, latitude: -35.3633, longitude: 149.1653, altitude: 30)]
        let back = try WaypointFile.parse(WaypointFile.format(items))
        XCTAssertEqual(back.map(\.x), items.map(\.x))
        XCTAssertEqual(back.map(\.y), items.map(\.y))
        XCTAssertEqual(back[1].param1, 12.5)
    }
}
