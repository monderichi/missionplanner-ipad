import XCTest
@testable import MAVLinkKit

/// ArduPilot-like mission server (all three mission types) behind a lossy link.
final class SimulatedMissionVehicle {
    var stored: [UInt8: [MissionItem]] = [0: [], 1: [], 2: []]
    var dropRate: Double
    var useLegacyRequest = false
    /// BUG-033: behave like ArduPilot 4.7.3 (seen in SITL): a duplicate/out-of-order item during an upload gets
    /// MISSION_ACK INVALID_SEQUENCE (13) plus a re-request, and a re-sent final item after completion gets ERROR (1)
    /// instead of a second ACCEPTED.
    var arduPilotLike = false
    private var uploading: (type: UInt8, count: Int, items: [Int: MissionItem])?
    /// Last finished upload: a re-sent final item (our ACK was lost) is ACKed again.
    private var lastCompleted: (type: UInt8, count: Int)?
    private let sender = MAVLinkSender(systemID: 1, componentID: 1)
    private var rng = SystemRandomNumberGenerator()

    init(dropRate: Double) { self.dropRate = dropRate }

    private func lost() -> Bool { Double.random(in: 0..<1, using: &rng) < dropRate }

    func receive(_ frames: [[UInt8]]) -> [[UInt8]] {
        var out: [MAVLinkMessage] = []
        let parser = MAVLinkParser()
        for f in frames where !lost() {
            for p in parser.parse(f) {
                if let r = p.decode(MAV.MissionRequestList.self) {
                    out.append(MAV.MissionCount(count: UInt16(stored[r.missionType]!.count), targetSystem: 255,
                                                targetComponent: 190, missionType: r.missionType))
                } else if let r = p.decode(MAV.MissionRequestInt.self) {
                    if let it = stored[r.missionType]?[safe: Int(r.seq)] {
                        out.append(it.message(targetSystem: 255, targetComponent: 190))
                    }
                } else if let c = p.decode(MAV.MissionCount.self) {
                    uploading = (c.missionType, Int(c.count), [:])
                    if c.count == 0 {
                        stored[c.missionType] = []
                        out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: 0, missionType: c.missionType))
                        uploading = nil
                    } else {
                        out.append(request(0, c.missionType))
                    }
                } else if arduPilotLike, let m = p.decode(MAV.MissionItemInt.self), let u = uploading, m.missionType == u.type,
                          let want = (0..<u.count).first(where: { u.items[$0] == nil }), Int(m.seq) != want {
                    out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: 13, missionType: u.type))
                    out.append(request(want, u.type))
                } else if let m = p.decode(MAV.MissionItemInt.self), var u = uploading, m.missionType == u.type {
                    u.items[Int(m.seq)] = MissionItem(m)
                    uploading = u
                    if let next = (0..<u.count).first(where: { u.items[$0] == nil }) {
                        out.append(request(next, u.type))
                    } else {
                        stored[u.type] = (0..<u.count).map { u.items[$0]! }
                        out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: 0, missionType: u.type))
                        lastCompleted = (u.type, u.count)
                        uploading = nil
                    }
                } else if let m = p.decode(MAV.MissionItemInt.self), uploading == nil, let done = lastCompleted,
                          m.missionType == done.type, Int(m.seq) == done.count - 1 {
                    out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: arduPilotLike ? 1 : 0,
                                              missionType: done.type))
                }
            }
        }
        return out.filter { _ in !lost() }.map { sender.pack(any: $0) }
    }

    private func request(_ seq: Int, _ type: UInt8) -> MAVLinkMessage {
        useLegacyRequest
            ? MAV.MissionRequest(seq: UInt16(seq), targetSystem: 255, targetComponent: 190, missionType: type)
            : MAV.MissionRequestInt(seq: UInt16(seq), targetSystem: 255, targetComponent: 190, missionType: type)
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

final class MissionTests: XCTestCase {
    private let gcs = MAVLinkSender()

    private func run(_ s: MissionSession, _ v: SimulatedMissionVehicle, start: [MAVLinkMessage],
                     limit: TimeInterval = 300) -> [MissionSession.Event] {
        var events: [MissionSession.Event] = []
        var toSend = start
        var t: TimeInterval = 0
        let parser = MAVLinkParser()
        while t < limit {
            var next: [MAVLinkMessage] = []
            for reply in v.receive(toSend.map { gcs.pack(any: $0) }) {
                for p in parser.parse(reply) {
                    let r = s.handle(p, now: t)
                    next += r.messages
                    events += r.events
                }
            }
            if !s.isBusy { return events }
            t += 0.25
            let r = s.tick(now: t)
            next += r.messages
            events += r.events
            if !s.isBusy { return events }
            toSend = next
        }
        return events
    }

    private func sampleMission(_ n: Int) -> [MissionItem] {
        var items = [MissionItem(frame: MAVFrame.global, latitude: 37.9838, longitude: 23.7275, altitude: 100)] // home
        items.append(MissionItem(command: MissionCmd.takeoff, altitude: 20))
        for i in 0..<n {
            items.append(MissionItem(param1: Float(i % 3), latitude: 37.98 + Double(i) * 1e-4,
                                     longitude: 23.72 + Double(i) * 2e-4, altitude: 30 + Float(i)))
        }
        items.append(MissionItem(command: MissionCmd.returnToLaunch))
        return items
    }

    /// BUG-033: uploads to an ArduPilot-like vehicle at 30 % loss each way must all end "uploaded" (verified by read-back
    /// when the final ACK is lost), never "Invalid sequence" / "Error".
    func testUploadToArduPilotLikeVehicleSurvivesLoss() {
        var failures: [String] = []
        for attempt in 0..<60 {
            let v = SimulatedMissionVehicle(dropRate: 0.3)
            v.arduPilotLike = true
            let s = MissionSession(targetSystem: 1, config: .narrowLink)
            let items = sampleMission(13)
            let up = run(s, v, start: s.startUpload(.mission, items: items, now: 0))
            if !up.contains(.uploaded(type: .mission, count: items.count)) { failures.append("run \(attempt): \(up.suffix(1))") }
            else if v.stored[0]?.count != items.count { failures.append("run \(attempt): stored \(v.stored[0]?.count ?? -1)") }
        }
        XCTAssertTrue(failures.count <= 3, "\(failures.count)/60 failed: \(failures.prefix(3))")
    }

    func testUploadThenDownloadRoundTripsThroughLossyLink() {
        let v = SimulatedMissionVehicle(dropRate: 0.25)
        let s = MissionSession(targetSystem: 1, config: .narrowLink)
        let items = sampleMission(40)
        let up = run(s, v, start: s.startUpload(.mission, items: items, now: 0))
        XCTAssertTrue(up.contains(.uploaded(type: .mission, count: items.count)), "\(up.suffix(2))")
        XCTAssertEqual(v.stored[0]?.count, items.count)

        let down = run(s, v, start: s.startDownload(.mission, now: 0))
        guard case .downloaded(_, let got)? = down.last else { return XCTFail("\(down.suffix(2))") }
        XCTAssertEqual(got.count, items.count)
        for (a, b) in zip(got, items) {
            XCTAssertEqual(a.command, b.command)
            XCTAssertEqual(a.x, b.x)
            XCTAssertEqual(a.y, b.y)
            XCTAssertEqual(a.z, b.z)
            XCTAssertEqual(a.param1, b.param1)
        }
        XCTAssertEqual(got[0].current, 1) // home flagged current on upload
    }

    func testFenceAndRallyUseTheirOwnMissionType() {
        let v = SimulatedMissionVehicle(dropRate: 0)
        v.useLegacyRequest = true
        let s = MissionSession(targetSystem: 1)
        let fence = [
            MissionItem(command: MissionCmd.fencePolygonInclusion, param1: 3, latitude: 1, longitude: 1),
            MissionItem(command: MissionCmd.fencePolygonInclusion, param1: 3, latitude: 1, longitude: 2),
            MissionItem(command: MissionCmd.fencePolygonInclusion, param1: 3, latitude: 2, longitude: 1),
        ]
        XCTAssertTrue(run(s, v, start: s.startUpload(.fence, items: fence, now: 0)).contains(.uploaded(type: .fence, count: 3)))
        XCTAssertEqual(v.stored[1]?.count, 3)
        XCTAssertEqual(v.stored[0]?.count, 0)
        XCTAssertEqual(v.stored[1]?.first?.missionType, MissionType.fence.rawValue)
        XCTAssertEqual(v.stored[1]?.first?.current, 0) // no home item in a fence list

        let rally = [MissionItem(command: MissionCmd.rallyPoint, latitude: 5, longitude: 6, altitude: 40)]
        XCTAssertTrue(run(s, v, start: s.startUpload(.rally, items: rally, now: 0)).contains(.uploaded(type: .rally, count: 1)))
        let down = run(s, v, start: s.startDownload(.rally, now: 0))
        XCTAssertEqual(down.last, .downloaded(type: .rally, items: v.stored[2]!))
    }

    func testEmptyDownloadAndSilentVehicle() {
        let v = SimulatedMissionVehicle(dropRate: 0)
        let s = MissionSession(targetSystem: 1)
        XCTAssertEqual(run(s, v, start: s.startDownload(.mission, now: 0)).last, .downloaded(type: .mission, items: []))

        let dead = SimulatedMissionVehicle(dropRate: 1)
        let events = run(s, dead, start: s.startDownload(.mission, now: 0))
        XCTAssertEqual(events.last, .failed(type: .mission, reason: "No answer from vehicle"))
        XCTAssertFalse(s.isBusy)
    }

    func testWaypointFileMissionPlannerFormat() throws {
        // As written by desktop Mission Planner (CRLF, tab separated)
        let mp = "QGC WPL 110\r\n0\t1\t0\t16\t0\t0\t0\t0\t-35.363262\t149.165237\t584.090027\t1\r\n" +
                 "1\t0\t3\t22\t0.000000\t0.000000\t0.000000\t0.000000\t0.000000\t0.000000\t20.000000\t1\r\n" +
                 "2\t0\t3\t16\t0.000000\t0.000000\t0.000000\t0.000000\t-35.36130250\t149.16522790\t50.000000\t1\r\n"
        let items = try WaypointFile.parse(mp)
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].frame, MAVFrame.global)
        XCTAssertEqual(items[1].command, MissionCmd.takeoff)
        XCTAssertEqual(items[2].latitude, -35.3613025, accuracy: 1e-7)
        XCTAssertEqual(items[2].z, 50)

        let again = try WaypointFile.parse(WaypointFile.format(items))
        XCTAssertEqual(again.map(\.x), items.map(\.x))
        XCTAssertEqual(again.map(\.y), items.map(\.y))
        XCTAssertEqual(again.map(\.command), items.map(\.command))
        XCTAssertThrowsError(try WaypointFile.parse("SERIAL6_BAUD,460\n"))
    }

    func testSurveyGridCoversSquare() {
        // ~200 m x 200 m square
        let o = GeoPoint(latitude: 38.0, longitude: 23.7)
        let sq = [(0.0, 0.0), (200.0, 0.0), (200.0, 200.0), (0.0, 200.0)].map { Geo.fromLocal(x: $0.0, y: $0.1, origin: o) }
        var opt = SurveyGrid.Options()
        opt.spacing = 40
        let pts = SurveyGrid.generate(polygon: sq, options: opt)
        XCTAssertEqual(pts.count, 10) // 5 lines x 2 ends
        // first line runs south->north at x≈20 m, second comes back north->south
        let l = pts.map { Geo.toLocal($0, origin: o) }
        XCTAssertEqual(l[0].x, 20, accuracy: 0.5)
        XCTAssertEqual(l[0].y, 0, accuracy: 0.5)
        XCTAssertEqual(l[1].y, 200, accuracy: 0.5)
        XCTAssertEqual(l[2].y, 200, accuracy: 0.5)
        XCTAssertEqual(l[2].x, 60, accuracy: 0.5)
        XCTAssertEqual(Geo.area(sq), 40_000, accuracy: 50)

        opt.angle = 90
        let rotated = SurveyGrid.generate(polygon: sq, options: opt).map { Geo.toLocal($0, origin: o) }
        XCTAssertEqual(rotated.count, 10)
        XCTAssertEqual(abs(rotated[0].y - rotated[1].y), 0, accuracy: 0.5) // east-west lines
    }

    func testGeoDistanceAndBearing() {
        let a = GeoPoint(latitude: 0, longitude: 0), b = GeoPoint(latitude: 0, longitude: 1)
        XCTAssertEqual(Geo.distance(a, b), 111_319.5, accuracy: 1)
        XCTAssertEqual(Geo.bearing(a, b), 90, accuracy: 0.001)
        XCTAssertEqual(Geo.bearing(b, a), 270, accuracy: 0.001)
    }
}
