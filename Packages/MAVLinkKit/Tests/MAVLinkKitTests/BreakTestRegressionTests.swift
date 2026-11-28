// Regression tests from the break-test (TESTING_RESULTS.md, testing/FIX_LOG.md): test_BUG0xx_* failed on c14c3e1 and
// pass with the fixes on bug_fixes; test_cov_* cover thin areas. Also run on CI by `swift test`.
import XCTest
@testable import MAVLinkKit

final class BreakTestRegressionTests: XCTestCase {
    private func ack(_ cmd: UInt16, _ result: UInt8 = 0) -> MAV.CommandAck {
        MAV.CommandAck(command: cmd, result: result, progress: 0, resultParam2: 0, targetSystem: 255, targetComponent: 190)
    }

    /// BUG-002: Disarm sent before the Arm ACK arrives must not be completed by the Arm ACK.
    func test_BUG002_disarmNotCompletedByEarlierArmAck() {
        let s = CommandSession(targetSystem: 1)
        _ = s.arm(true, now: 0)
        _ = s.arm(false, now: 0.1)
        _ = s.handle(ack(MAVCmd.componentArmDisarm), now: 0.2)  // this ACK answers the ARM
        let r = s.tick(now: 5)
        // The disarm must still be outstanding (retried) or reported as superseded, never "accepted".
        XCTAssertTrue(!s.pendingCommands.isEmpty || !r.messages.isEmpty, "disarm was silently dropped")
    }

    /// BUG-002 (review 1): LOITER then RTL: RTL goes out at once, LOITER's (ambiguous) ACK doesn't complete it, and
    /// RTL is the one retried.
    func test_BUG002_secondModeChangeRetriedAfterFirstAck() {
        let s = CommandSession(targetSystem: 1)
        _ = s.setMode(5, now: 0)               // LOITER
        let second = s.setMode(6, now: 0.05)   // RTL supersedes at once
        XCTAssertEqual((second.first as? MAV.CommandLong)?.param2, 6, "RTL must be sent immediately")
        XCTAssertTrue(s.handle(ack(MAVCmd.doSetMode), now: 0.3).isEmpty, "an ACK inside the ambiguity window is not RTL's")
        XCTAssertEqual(s.pendingCommands, [MAVCmd.doSetMode])
        let r = s.tick(now: 2.0)
        XCTAssertEqual((r.messages.first as? MAV.CommandLong)?.param2, 6, "RTL (not LOITER) is retried")
    }

    /// Review 1: ARM, then DISARM 0.5 s later on the ELRS config with the ACKs lost: DISARM is on the wire at once and the
    /// ARM is never resent again.
    func test_BUG002_disarmSentAtOnceAndArmNotResent() {
        let s = CommandSession(targetSystem: 1, config: .narrowLink)
        _ = s.arm(true, now: 0)
        let d = s.arm(false, now: 0.5)
        XCTAssertEqual((d.first as? MAV.CommandLong)?.param1, 0, "DISARM must go out immediately")
        var resent: [Float] = []
        var t = 0.5
        while t < 20 { t += 0.25; resent += s.tick(now: t).messages.compactMap { ($0 as? MAV.CommandLong)?.param1 } }
        XCTAssertFalse(resent.contains(1), "ARM was resent after DISARM: \(resent)")
    }

    /// Review 1: force-disarm while an ARM is in flight: the ARM's ACK must not "accept" it; it is retried.
    func test_BUG002_forceDisarmNotAcceptedByArmAck() {
        let s = CommandSession(targetSystem: 1)
        _ = s.arm(true, now: 0)
        XCTAssertEqual(s.arm(false, force: true, now: 0.1).count, 1, "force-disarm goes out immediately")
        XCTAssertTrue(s.handle(ack(MAVCmd.componentArmDisarm), now: 0.2).isEmpty)
        let r = s.tick(now: 2.0)
        XCTAssertEqual((r.messages.first as? MAV.CommandLong)?.param2, 21196, "force-disarm must be retried")
        XCTAssertTrue(s.confirmByState(MAVCmd.componentArmDisarm, now: 0.5).isEmpty, "no state confirmation inside the window")
        XCTAssertEqual(s.confirmByState(MAVCmd.componentArmDisarm, now: 2.5), [.accepted(command: MAVCmd.componentArmDisarm)])
    }

    /// Review 1: servo 5, 6, 7 tapped quickly: every channel is sent (FIFO), none dropped.
    func test_BUG002_servoTapsAreNotDropped() {
        let s = CommandSession(targetSystem: 1)
        var sent: [Float] = []
        for ch in [Float(5), 6, 7] { sent += s.send(183, params: [ch, 1900], now: 0).compactMap { ($0 as? MAV.CommandLong)?.param1 } }
        for k in 0..<2 {
            let t = Double(k) * 2
            _ = s.handle(ack(183), now: 0.3 + t) // ACK of the in-flight one (after any ambiguity window)
            sent += s.tick(now: 0.5 + t).messages.compactMap { ($0 as? MAV.CommandLong)?.param1 }
        }
        XCTAssertEqual(sent, [5, 6, 7])
    }

    /// Review 4: servo 5's ACK is late, so it is resent; both ACKs then arrive together. The duplicate must not accept
    /// servo 6, which was released from the queue but not sent yet: servo 6 goes out and is confirmed by its own ACK.
    func test_BUG002_duplicateAckDoesNotAcceptUnsentQueuedCommand() {
        let s = CommandSession(targetSystem: 1) // timeout 1.5 s
        var sent: [Float] = []
        var accepted: [Float] = [] // channel of the in-flight command when each `accepted` fires
        func note(_ e: [CommandSession.Event], _ ch: Float?) { accepted += e.filter { if case .accepted = $0 { return true }; return false }.compactMap { _ in ch } }
        for ch in [Float(5), 6] { sent += s.send(183, params: [ch, 1900], now: 0).compactMap { ($0 as? MAV.CommandLong)?.param1 } }
        sent += s.tick(now: 1.5).messages.compactMap { ($0 as? MAV.CommandLong)?.param1 } // servo 5 resent
        for t in [1.6, 1.6] { let ch = s.inFlight(183)?.param1; note(s.handle(ack(183), now: t), ch) } // original + duplicate
        XCTAssertEqual(accepted, [5], "duplicate ACK of servo 5 accepted servo 6 before it was sent")
        sent += s.tick(now: 1.75).messages.compactMap { ($0 as? MAV.CommandLong)?.param1 } // servo 6 first send
        do { let ch = s.inFlight(183)?.param1; note(s.handle(ack(183), now: 2.4), ch) } // servo 6's own ACK
        XCTAssertEqual(sent, [5, 5, 6])
        XCTAssertEqual(accepted, [5, 6])
        XCTAssertTrue(s.pendingCommands.isEmpty)
    }

    /// Review 5: after one lost ACK (servo 5 resent) and after a timeout, the rest of the queue goes out once each on a
    /// clean link (0.2 s round trip): no cascade of double sends.
    func test_BUG002_queueRecoversAfterLostAckAndTimeout() {
        for timeoutFirst in [false, true] {
            let s = CommandSession(targetSystem: 1) // timeout 1.5 s, 3 attempts
            var sent: [Float] = []
            var acks: [(at: Double, ch: Float)] = [] // ACK due at time `at` for a send of channel `ch`
            var lostFirst = true
            func out(_ m: [MAVLinkMessage], _ t: Double) {
                for c in m.compactMap({ $0 as? MAV.CommandLong }) {
                    sent.append(c.param1)
                    // servo 5: first ACK lost (or, with timeoutFirst, every ACK lost so it times out)
                    if c.param1 == 5 && (timeoutFirst || lostFirst) { lostFirst = false; continue }
                    acks.append((t + 0.2, c.param1))
                }
            }
            for ch in [Float(5), 6, 7, 8] { out(s.send(183, params: [ch, 1900], now: 0), 0) }
            var t = 0.0
            while t < 20, !s.pendingCommands.isEmpty {
                t += 0.25
                for a in acks where a.at <= t { _ = s.handle(ack(183), now: t) }
                acks.removeAll { $0.at <= t }
                out(s.tick(now: t).messages, t)
            }
            XCTAssertTrue(s.pendingCommands.isEmpty, "stuck: \(s.pendingCommands)")
            XCTAssertEqual(sent.filter { $0 != 5 }, [6, 7, 8], "timeoutFirst=\(timeoutFirst): \(sent)")
        }
    }

    /// BUG-002: emergency force-disarm is never queued.
    func test_BUG002_forceDisarmGoesOutImmediately() {
        let s = CommandSession(targetSystem: 1)
        _ = s.arm(true, now: 0)
        XCTAssertEqual(s.arm(false, force: true, now: 0.1).count, 1)
    }

    /// BUG-016: reordering must not count as loss.
    func test_BUG016_reorderedPacketsAreNotLoss() {
        let p = MAVLinkParser()
        let s = MAVLinkSender(systemID: 1, componentID: 1)
        var frames: [[UInt8]] = (0..<100).map { _ in s.pack(MAV.Heartbeat(type: 2, autopilot: 3)) }
        for i in stride(from: 0, to: 98, by: 3) { frames.swapAt(i, i + 1) }
        for f in frames { _ = p.parse(f) }
        XCTAssertEqual(p.stats.packetsLost, 0)
    }

    /// BUG-007: legacy MISSION_ITEM with NaN / huge coordinates must not trap; non-location params are not scaled.
    func test_BUG007_legacyMissionItemConversionIsSafe() {
        let bad = MissionItem(MAV.MissionItem(x: .nan, y: 3e10, z: 10, seq: 1, command: MissionCmd.waypoint))
        XCTAssertEqual(bad.x, 0)
        let jump = MissionItem(MAV.MissionItem(param1: 3, x: 5, y: 0, seq: 2, command: MissionCmd.doJump))
        XCTAssertEqual(jump.x, 5)
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
