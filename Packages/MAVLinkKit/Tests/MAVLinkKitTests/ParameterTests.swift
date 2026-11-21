import XCTest
@testable import MAVLinkKit

/// Minimal ArduPilot parameter server behind a lossy link. Messages go through real
/// MAVLink framing both ways, so encode/decode is exercised too.
final class SimulatedVehicle {
    var names: [String]
    var values: [String: Float]
    var types: [String: UInt8]
    var dropRate: Double
    var rng = SystemRandomNumberGenerator()
    /// Optional clamp to emulate the FC refusing a value.
    var clamp: [String: ClosedRange<Float>] = [:]
    private let sender = MAVLinkSender(systemID: 1, componentID: 1)
    private var outbox: [[UInt8]] = []

    init(count: Int, dropRate: Double) {
        names = (0..<count).map { String(format: "PARAM_%04d", $0) }
        values = Dictionary(uniqueKeysWithValues: names.enumerated().map { item in
            (item.element, Float(item.offset) * 0.5)
        })
        types = Dictionary(uniqueKeysWithValues: names.enumerated().map { item in
            (item.element, item.offset % 3 == 0 ? MAVParamType.int16 : MAVParamType.real32)
        })
        self.dropRate = dropRate
    }

    private func lost() -> Bool { Double.random(in: 0..<1, using: &rng) < dropRate }

    private func reply(_ name: String, index: Int?) {
        let i = index ?? Int(UInt16.max)
        let m = MAV.ParamValue(paramValue: values[name]!, paramCount: UInt16(names.count), paramIndex: UInt16(i),
                               paramId: MAVString.encode(name, length: 16), paramType: types[name]!)
        if !lost() { outbox.append(sender.pack(m)) }
    }

    /// Feed GCS frames in; returns vehicle frames out.
    func receive(_ frames: [[UInt8]]) -> [[UInt8]] {
        let parser = MAVLinkParser()
        for f in frames where !lost() {
            for p in parser.parse(f) {
                if let _ = p.decode(MAV.ParamRequestList.self) {
                    for (i, n) in names.enumerated() { reply(n, index: i) }
                } else if let r = p.decode(MAV.ParamRequestRead.self) {
                    if r.paramIndex >= 0 {
                        let i = Int(r.paramIndex)
                        if i < names.count { reply(names[i], index: i) }
                    } else {
                        let n = MAVString.decode(r.paramId)
                        if let i = names.firstIndex(of: n) { reply(n, index: i) }
                    }
                } else if let s = p.decode(MAV.ParamSet.self) {
                    let n = MAVString.decode(s.paramId)
                    guard values[n] != nil else { continue }
                    var v = s.paramValue
                    if let c = clamp[n] { v = min(max(v, c.lowerBound), c.upperBound) }
                    values[n] = v
                    reply(n, index: nil) // ArduPilot echoes with index 65535
                }
            }
        }
        defer { outbox.removeAll() }
        return outbox
    }
}

final class ParameterTests: XCTestCase {
    private let gcs = MAVLinkSender()

    /// Drives session <-> vehicle in 0.25 s steps until `done` or `limit` seconds pass.
    private func run(_ session: ParameterSession, _ vehicle: SimulatedVehicle, start: [MAVLinkMessage],
                     limit: TimeInterval = 600, until done: ([ParameterSession.Event]) -> Bool) -> [ParameterSession.Event] {
        var all: [ParameterSession.Event] = []
        var toSend = start
        var t: TimeInterval = 0
        let parser = MAVLinkParser()
        while t < limit {
            let frames = toSend.map { gcs.pack(any: $0) }
            for reply in vehicle.receive(frames) {
                for p in parser.parse(reply) {
                    if let v = p.decode(MAV.ParamValue.self) { all += session.handle(v, now: t) }
                }
            }
            if done(all) { return all }
            t += 0.25
            let r = session.tick(now: t)
            toSend = r.messages
            all += r.events
            if done(all) { return all }
        }
        return all
    }

    func testDownloadCleanLink() {
        let v = SimulatedVehicle(count: 50, dropRate: 0)
        let s = ParameterSession(targetSystem: 1)
        let events = run(s, v, start: s.startDownload(now: 0)) { $0.contains(.downloadComplete(total: 50)) }
        XCTAssertTrue(events.contains(.downloadComplete(total: 50)))
        XCTAssertEqual(s.params.count, 50)
        XCTAssertEqual(s.params["PARAM_0003"]?.value, 1.5)
        XCTAssertEqual(s.params["PARAM_0003"]?.type, MAVParamType.int16)
        XCTAssertEqual(s.downloadState, .complete(total: 50))
    }

    func testDownloadRecoversFromHeavyLossByRequestingMissingIndices() {
        let v = SimulatedVehicle(count: 900, dropRate: 0.3) // ~ArduCopter size, 30% loss each way
        let s = ParameterSession(targetSystem: 1, config: .narrowLink)
        let events = run(s, v, start: s.startDownload(now: 0)) { $0.contains(.downloadComplete(total: 900)) }
        XCTAssertTrue(events.contains(.downloadComplete(total: 900)), "missing \(s.missingIndices.count)")
        XCTAssertEqual(s.params.count, 900)
        for (i, n) in v.names.enumerated() {
            XCTAssertEqual(s.params[n]?.value, Float(i) * 0.5)
            XCTAssertEqual(s.params[n]?.index, i)
        }
    }

    func testDownloadFailsWhenVehicleIsSilent() {
        let v = SimulatedVehicle(count: 10, dropRate: 1.0)
        let s = ParameterSession(targetSystem: 1)
        let events = run(s, v, start: s.startDownload(now: 0), limit: 60) { evs in
            evs.contains { if case .downloadFailed = $0 { return true } else { return false } }
        }
        XCTAssertTrue(events.contains { if case .downloadFailed = $0 { return true } else { return false } })
        if case .failed = s.downloadState {} else { XCTFail("state \(s.downloadState)") }
    }

    func testSetConfirmsWithEchoAndRetriesThroughLoss() {
        let v = SimulatedVehicle(count: 20, dropRate: 0)
        let s = ParameterSession(targetSystem: 1)
        _ = run(s, v, start: s.startDownload(now: 0)) { $0.contains(.downloadComplete(total: 20)) }

        v.dropRate = 0.5
        let events = run(s, v, start: s.set("PARAM_0004", value: 7.25, now: 0)) { evs in
            evs.contains { if case .setResult = $0 { return true }; if case .setTimedOut = $0 { return true }; return false }
        }
        // With 50% loss either it confirms, or (rarely) all attempts were lost.
        if events.contains(.setTimedOut(name: "PARAM_0004")) {
            XCTAssertTrue(s.pendingSetNames.isEmpty)
        } else {
            XCTAssertTrue(events.contains(.setResult(name: "PARAM_0004", requested: 7.25, actual: 7.25, ok: true)))
            XCTAssertEqual(s.params["PARAM_0004"]?.value, 7.25)
            XCTAssertEqual(v.values["PARAM_0004"], 7.25)
        }
    }

    func testSetReportsClampedValue() {
        let v = SimulatedVehicle(count: 5, dropRate: 0)
        v.clamp["PARAM_0001"] = 0...2
        let s = ParameterSession(targetSystem: 1)
        _ = run(s, v, start: s.startDownload(now: 0)) { $0.contains(.downloadComplete(total: 5)) }
        let events = run(s, v, start: s.set("PARAM_0001", value: 9, now: 0)) { evs in
            evs.contains { if case .setResult = $0 { return true } else { return false } }
        }
        XCTAssertTrue(events.contains(.setResult(name: "PARAM_0001", requested: 9, actual: 2, ok: false)))
    }

    func testSetUsesVehicleReportedType() {
        let s = ParameterSession(targetSystem: 1)
        _ = s.handle(MAV.ParamValue(paramValue: 3, paramCount: 1, paramIndex: 0,
                                    paramId: MAVString.encode("FRAME_CLASS", length: 16), paramType: MAVParamType.int8), now: 0)
        let msg = s.set("FRAME_CLASS", value: 1, now: 0).first as? MAV.ParamSet
        XCTAssertEqual(msg?.paramType, MAVParamType.int8)
        XCTAssertEqual(MAVString.decode(msg!.paramId), "FRAME_CLASS")
    }

    func testIntegerComparison() {
        XCTAssertTrue(ParameterSession.same(460, 460.0001, isInteger: true))
        XCTAssertFalse(ParameterSession.same(0.15, 0.16, isInteger: false))
        XCTAssertTrue(ParameterSession.same(0.15, Float("0.15")!, isInteger: false))
    }
}

final class CommandTests: XCTestCase {
    func testArmRetriesWithIncrementingConfirmationThenAck() {
        let c = CommandSession(targetSystem: 1)
        let first = c.arm(true, now: 0).first as! MAV.CommandLong
        XCTAssertEqual(first.command, MAVCmd.componentArmDisarm)
        XCTAssertEqual(first.param1, 1)
        XCTAssertEqual(first.confirmation, 0)

        let r1 = c.tick(now: 1.6)
        XCTAssertEqual((r1.messages.first as? MAV.CommandLong)?.confirmation, 1)
        let ev = c.handle(MAV.CommandAck(command: MAVCmd.componentArmDisarm, result: MAVResult.accepted.rawValue), now: 2)
        XCTAssertEqual(ev, [.accepted(command: MAVCmd.componentArmDisarm)])
        XCTAssertTrue(c.pendingCommands.isEmpty)
    }

    func testRejectedAndTimedOut() {
        let c = CommandSession(targetSystem: 1)
        _ = c.setMode(5, now: 0)
        let ev = c.handle(MAV.CommandAck(command: MAVCmd.doSetMode, result: MAVResult.denied.rawValue), now: 0.5)
        XCTAssertEqual(ev, [.rejected(command: MAVCmd.doSetMode, result: 2)])

        _ = c.reboot(now: 10)
        var events: [CommandSession.Event] = []
        var t = 10.0
        while t < 20 { t += 0.5; events += c.tick(now: t).events }
        XCTAssertEqual(events, [.timedOut(command: MAVCmd.preflightRebootShutdown)])
    }

    func testSetModeParams() {
        let c = CommandSession(targetSystem: 1)
        let m = c.setMode(16, now: 0).first as! MAV.CommandLong // PosHold
        XCTAssertEqual(m.command, 176)
        XCTAssertEqual(m.param1, 1)
        XCTAssertEqual(m.param2, 16)
    }

    func testPackAnyMatchesGenericPack() {
        let a = MAVLinkSender(), b = MAVLinkSender()
        let hb = MAV.Heartbeat(customMode: 3, type: 6)
        XCTAssertEqual(a.pack(any: hb), b.pack(hb))
    }
}

final class ParamFileTests: XCTestCase {
    func testFormatLikeMissionPlanner() {
        let text = ParamFile.format(["SERIAL6_BAUD": 460, "ATC_RAT_RLL_P": 0.135, "ACRO_BAL_ROLL": 1], note: "test")
        XCTAssertEqual(text, "#NOTE: test\nACRO_BAL_ROLL,1\nATC_RAT_RLL_P,0.135\nSERIAL6_BAUD,460\n")
    }

    func testParseMissionPlannerAndQGCFormats() {
        let mp = "#NOTE: 21/11/2026\r\nSERIAL6_BAUD,460\r\nATC_RAT_RLL_P,0.135\n\n# comment\nBAD LINE\nTOO_LONG_PARAMETER_NAME_X,1\n"
        XCTAssertEqual(ParamFile.parse(mp), ["SERIAL6_BAUD": 460, "ATC_RAT_RLL_P": 0.135])
        let qgc = "# Onboard parameters\n1\t1\tSR6_EXTRA1\t4\t9\n1\t1\tFRAME_CLASS\t1\t2\n"
        XCTAssertEqual(ParamFile.parse(qgc), ["SR6_EXTRA1": 4, "FRAME_CLASS": 1])
        XCTAssertEqual(ParamFile.parse("RC1_MIN 1000\nRC1_MAX\t2000"), ["RC1_MIN": 1000, "RC1_MAX": 2000])
    }

    func testRoundTrip() {
        let p: [String: Float] = ["A": 0.1, "B": -3, "C": 1e-5, "D": 123456.5]
        XCTAssertEqual(ParamFile.parse(ParamFile.format(p)), p)
    }
}
