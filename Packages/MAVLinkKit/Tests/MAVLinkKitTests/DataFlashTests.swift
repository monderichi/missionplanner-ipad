// REA Parity Source: MissionPlanner ExtLibs/Utilities/DFLog.cs (DataFlash binary parsing)
import XCTest
@testable import MAVLinkKit

final class DataFlashTests: XCTestCase {
    static func fixtureData() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "sample", withExtension: "bin", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    func testMessageNamesAndCounts() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData())
        XCTAssertEqual(log.messageNames, ["ATT", "GPS", "MODE", "PARM"])
        XCTAssertEqual(log.count(of: "ATT"), 100)
        XCTAssertEqual(log.count(of: "GPS"), 20)
        XCTAssertEqual(log.count(of: "MODE"), 3)
        XCTAssertEqual(log.count(of: "PARM"), 6)
        XCTAssertEqual(log.recordCount, 5 + 100 + 20 + 3 + 6)
        XCTAssertEqual(log.columns(of: "ATT"), ["DesRoll", "Roll", "DesPitch", "Pitch", "DesYaw", "Yaw", "ErrRP", "ErrYaw"])
        XCTAssertEqual(log.formats[129]?.name, "ATT")
    }

    func testDecodedValuesAndScaling() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData())
        let roll = log.values(message: "ATT", column: "Roll")
        XCTAssertEqual(roll.v.count, 100)
        XCTAssertEqual(roll.t[0], 1.0, accuracy: 1e-9)
        XCTAssertEqual(roll.t[50], 6.0, accuracy: 1e-9)
        XCTAssertEqual(roll.v[0], -5.0, accuracy: 1e-9)
        XCTAssertEqual(roll.v[50], 5.0, accuracy: 1e-9)
        XCTAssertEqual(log.values(message: "ATT", column: "Pitch").v[99], -4.95, accuracy: 1e-9)
        XCTAssertEqual(log.values(message: "ATT", column: "Yaw").v[50], 180.0, accuracy: 1e-9)
        let lat = log.values(message: "GPS", column: "Lat")
        XCTAssertEqual(lat.v[0], 37.7749, accuracy: 1e-9)
        XCTAssertEqual(log.values(message: "GPS", column: "Lng").v[0], -122.4194, accuracy: 1e-9)
        XCTAssertEqual(log.values(message: "GPS", column: "Alt").v[0], 123.45, accuracy: 1e-9)
        XCTAssertEqual(log.values(message: "GPS", column: "Spd").v[3], 1.5, accuracy: 1e-6)
        XCTAssertEqual(log.values(message: "GPS", column: "NSats").v[0], 10)
        XCTAssertEqual(log.startTime, 0.5, accuracy: 1e-9)   // first PARM is at 0.5 s
        XCTAssertEqual(log.endTime, 10.9, accuracy: 1e-9)
        XCTAssertTrue(log.values(message: "ATT", column: "Nope").v.isEmpty)
    }

    func testResyncAfterGarbage() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData())
        XCTAssertEqual(log.skippedBytes, 10)   // the garbage blob inserted after ATT #49
        // ATT 50...99 are still decoded after the garbage.
        XCTAssertEqual(log.values(message: "ATT", column: "ErrYaw").v[99], 198)
    }

    func testLeadingGarbageAndTruncation() throws {
        var data = Data([1, 2, 3, 0xA3, 0x00, 0x95])
        data.append(try Self.fixtureData())
        data.removeLast(5)   // cut the last GPS-less ATT record short
        let log = try DataFlashLog.parse(data)
        XCTAssertEqual(log.count(of: "ATT"), 99)
        XCTAssertEqual(log.count(of: "GPS"), 20)
    }

    func testEmptyThrows() {
        XCTAssertThrowsError(try DataFlashLog.parse(Data([0, 1, 2, 3, 4, 5])))
        XCTAssertThrowsError(try DataFlashLog.parse(Data()))
    }

    func testMaxRecords() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData(), maxRecords: 10)
        XCTAssertEqual(log.recordCount, 10)
    }

    func testModeExtraction() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData())
        XCTAssertEqual(log.modeChanges.map { $0.mode }, [0, 5, 6])
        XCTAssertEqual(log.modeChanges.map { $0.name }, ["Stabilize", "Loiter", "RTL"])
        XCTAssertEqual(log.modeChanges[1].time, 3.0, accuracy: 1e-9)
    }

    func testParameterExtraction() throws {
        let log = try DataFlashLog.parse(try Self.fixtureData())
        XCTAssertEqual(log.parameters.count, 5)
        XCTAssertEqual(log.parameters["RTL_ALT"], 2000)    // last value wins
        XCTAssertEqual(log.parameters["BATT_CAPACITY"], 5200)
        XCTAssertEqual(log.parameters["FS_BATT_ENABLE"], 2)
    }

    func testDownsample() {
        let n = 10_000
        let t = (0..<n).map { Double($0) }
        var v = (0..<n).map { sin(Double($0) * 0.01) }
        v[4321] = 50      // spike
        v[7777] = -50
        let d = DataFlashLog.downsample(t: t, v: v, maxPoints: 500)
        XCTAssertLessThanOrEqual(d.t.count, 500)
        XCTAssertEqual(d.t.count, d.v.count)
        XCTAssertEqual(d.v.max(), 50)
        XCTAssertEqual(d.v.min(), -50)
        XCTAssertEqual(d.t, d.t.sorted())
        // Small input is returned unchanged.
        let s = DataFlashLog.downsample(t: [0, 1, 2], v: [3, 4, 5], maxPoints: 2000)
        XCTAssertEqual(s.v, [3, 4, 5])
    }
}
