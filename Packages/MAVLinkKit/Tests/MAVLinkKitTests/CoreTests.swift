import XCTest
@testable import MAVLinkKit

final class CoreTests: XCTestCase {
    func testCRCCheckValue() {
        // CRC-16/MCRF4XX check value
        XCTAssertEqual(X25CRC.calculate(Array("123456789".utf8)), 0x6F91)
    }

    func testKnownTableEntriesMatchMissionPlanner() {
        XCTAssertEqual(MAVLinkMessages.info(for: 0)?.crcExtra, 50)   // HEARTBEAT
        XCTAssertEqual(MAVLinkMessages.info(for: 30)?.crcExtra, 39)  // ATTITUDE
        XCTAssertEqual(MAVLinkMessages.info(for: 22)?.crcExtra, 220) // PARAM_VALUE
        XCTAssertEqual(MAVLinkMessages.info(for: 253)?.length, 54)   // STATUSTEXT incl. extensions
        XCTAssertNil(MAVLinkMessages.info(for: 0xFFFFFF))
    }

    func testSenderSequenceWrapsAndUsesGCSIdentity() {
        let sender = MAVLinkSender()
        var last: [UInt8] = []
        for _ in 0..<257 { last = sender.pack(MAV.Heartbeat(type: MAVType.gcs.rawValue, autopilot: MAVAutopilot.invalid)) }
        let p = MAVLinkParser().parse(last).first!
        XCTAssertEqual(p.sequence, 0) // 257th packet: seq 256 wraps to 0
        XCTAssertEqual(p.systemID, 255)
        XCTAssertEqual(p.componentID, 190)
        let hb = p.decode(MAV.Heartbeat.self)!
        XCTAssertEqual(hb.type, 6)
        XCTAssertEqual(hb.autopilot, 8)
    }

    func testV2TruncatedPayloadIsZeroExtended() {
        let att = MAV.Attitude(timeBootMs: 1234)
        let bytes = MAVLinkFraming.encode(att, sequence: 0, systemID: 1, componentID: 1)
        XCTAssertEqual(Int(bytes[1]), 2) // 1234 = 0x04D2 -> two bytes, rest truncated
        let decoded = MAVLinkParser().parse(bytes).first!.decode(MAV.Attitude.self)!
        XCTAssertEqual(decoded, att)
    }

    func testSignedPacketIsFramedAndSignatureSkipped() {
        let hb = MAV.Heartbeat(customMode: 5, type: 2, autopilot: 3)
        let info = MAV.Heartbeat.mavInfo
        let payload = hb.payloadBytes()
        var frame: [UInt8] = [0xFD, UInt8(payload.count), MAVLinkConstants.incompatFlagSigned, 0, 9, 1, 1, 0, 0, 0]
        frame += payload
        let crc = X25CRC.accumulate(info.crcExtra, X25CRC.calculate(frame[1...]))
        frame += [UInt8(crc & 0xFF), UInt8(crc >> 8)]
        frame += [UInt8](repeating: 0xAB, count: 13)
        let next = MAVLinkFraming.encode(hb, sequence: 10, systemID: 1, componentID: 1)
        let packets = MAVLinkParser().parse(frame + next)
        XCTAssertEqual(packets.count, 2)
        XCTAssertTrue(packets[0].isSigned)
        XCTAssertEqual(packets[0].signature?.count, 13)
        XCTAssertEqual(packets[0].decode(MAV.Heartbeat.self), hb)
        XCTAssertFalse(packets[1].isSigned)
    }

    func testPacketLossFromSequenceGaps() {
        let parser = MAVLinkParser()
        let hb = MAV.Heartbeat()
        for seq: UInt8 in [0, 1, 2, 5, 6] {
            _ = parser.parse(MAVLinkFraming.encode(hb, sequence: seq, systemID: 1, componentID: 1))
        }
        XCTAssertEqual(parser.stats.packetsReceived, 5)
        XCTAssertEqual(parser.stats.packetsLost, 2)
    }

    func testStringHelpers() {
        let st = MAV.Statustext(severity: MAVSeverity.warning.rawValue, text: MAVString.encode("PreArm: Compass not calibrated", length: 50))
        let p = MAVLinkParser().parse(MAVLinkFraming.encode(st, sequence: 0, systemID: 1, componentID: 1)).first!
        XCTAssertEqual(MAVString.decode(p.decode(MAV.Statustext.self)!.text), "PreArm: Compass not calibrated")
        XCTAssertEqual(MAVString.decode(MAVString.encode("SR0_POSITION_XYZ", length: 16)), "SR0_POSITION_XYZ") // 16 chars, no NUL
    }

    func testTLogRoundTripIsBigEndianMicroseconds() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000.123456)
        let pkt = MAVLinkFraming.encode(MAV.Heartbeat(type: 2), sequence: 3, systemID: 1, componentID: 1)
        let rec = TLog.record(pkt, at: date)
        let usec = TLog.timestamp(date)
        XCTAssertEqual(Array(rec[0..<8]), (0..<8).reversed().map { UInt8(truncatingIfNeeded: usec >> UInt64($0 * 8)) })
        XCTAssertEqual(Array(rec[8...]), pkt)

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let writer = try TLogWriter(directory: dir, date: date)
        XCTAssertTrue(writer.url.lastPathComponent.hasSuffix(".tlog"))
        writer.write(raw: pkt, at: date)
        writer.write(raw: [0x00, 0x01]) // garbage between records must be skipped by the reader
        writer.write(raw: pkt, at: date.addingTimeInterval(1))
        writer.close()

        let reader = try TLogReader(url: writer.url)
        let records = Array(reader)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0].packet.raw, pkt)
        XCTAssertEqual(records[1].date.timeIntervalSince1970, date.timeIntervalSince1970 + 1, accuracy: 0.00001)
        try? FileManager.default.removeItem(at: dir)
    }

    func testModeNames() {
        XCTAssertEqual(ArduPilotModes.name(customMode: 5, vehicleType: MAVType.quadrotor.rawValue), "Loiter")
        XCTAssertEqual(ArduPilotModes.name(customMode: 10, vehicleType: MAVType.fixedWing.rawValue), "Auto")
        XCTAssertEqual(ArduPilotModes.name(customMode: 4, vehicleType: MAVType.groundRover.rawValue), "Hold")
        XCTAssertEqual(ArduPilotModes.name(customMode: 99, vehicleType: 2), "Mode 99")
    }
}
