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
    /// Review 1 (BUG-033): ArduPilot writes items to storage as they arrive and cancels an upload after 8 s without one,
    /// keeping the mix of new and old items. `dropSeq` loses every copy of that item (an ELRS dropout on the last item).
    var writeThrough = false
    var dropSeq: Int?
    var now: TimeInterval = 0
    private var lastItemTime: TimeInterval = 0
    private var uploading: (type: UInt8, count: Int, items: [Int: MissionItem])?
    /// Last finished upload: a re-sent final item (our ACK was lost) is ACKed again.
    private var lastCompleted: (type: UInt8, count: Int)?
    private let sender = MAVLinkSender(systemID: 1, componentID: 1)
    /// SplitMix64: seeded, so a lossy run can be repeated exactly (review 4: an unseeded RNG made the 200-run test flaky).
    private var state: UInt64

    init(dropRate: Double, seed: UInt64 = 0x9E3779B97F4A7C15) {
        self.dropRate = dropRate
        state = seed
    }

    private func lost() -> Bool {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z ^= z >> 31
        return Double(z >> 11) / Double(1 << 53) < dropRate
    }

    func receive(_ frames: [[UInt8]]) -> [[UInt8]] {
        var out: [MAVLinkMessage] = []
        let parser = MAVLinkParser()
        for f in frames where !lost() {
            for p in parser.parse(f) {
                if writeThrough, let u = uploading, now - lastItemTime > 8 {
                    uploading = nil // ArduPilot: upload timed out, cancelled; what was written stays
                    _ = u
                }
                if let m = p.decode(MAV.MissionItemInt.self), let d = dropSeq, Int(m.seq) == d { continue }
                if arduPilotLike, p.decode(MAV.MissionRequestList.self) != nil, uploading != nil {
                    out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: 14, missionType: 0)) // DENIED
                    continue
                }
                if let r = p.decode(MAV.MissionRequestList.self) {
                    out.append(MAV.MissionCount(count: UInt16(stored[r.missionType]!.count), targetSystem: 255,
                                                targetComponent: 190, missionType: r.missionType))
                } else if let r = p.decode(MAV.MissionRequestInt.self) {
                    if let it = stored[r.missionType]?[safe: Int(r.seq)] {
                        out.append(it.message(targetSystem: 255, targetComponent: 190))
                    }
                } else if let c = p.decode(MAV.MissionCount.self) {
                    uploading = (c.missionType, Int(c.count), [:])
                    lastItemTime = now
                    if writeThrough && c.missionType != 1 { // missions/rally: truncate; old items stay until overwritten
                        // (fences, review 2: ArduPilot buffers the whole fence and keeps the old one until completion)
                        stored[c.missionType] = Array((stored[c.missionType] ?? []).prefix(Int(c.count)))
                    }
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
                    lastItemTime = now
                    if writeThrough, u.type != 1, Int(m.seq) < (stored[u.type]?.count ?? 0) { stored[u.type]![Int(m.seq)] = MissionItem(m) }
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
                } else if arduPilotLike, let m = p.decode(MAV.MissionItemInt.self), uploading == nil {
                    // not receiving (e.g. after the 8 s timeout): ArduPilot answers ERROR
                    out.append(MAV.MissionAck(targetSystem: 255, targetComponent: 190, type: 1, missionType: m.missionType))
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
            v.now = t
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

    /// BUG-033 (review 1): the final item is lost until the vehicle's 8 s upload timeout; the vehicle keeps its OLD last
    /// item and the count still matches. The session must not report "uploaded".
    func testUploadNotConfirmedWhenVehicleKeptOldLastItem() {
        let v = SimulatedMissionVehicle(dropRate: 0)
        v.arduPilotLike = true
        v.writeThrough = true
        let old = sampleMission(3)
        v.stored[0] = old
        var edited = old
        edited[edited.count - 1] = MissionItem(seq: UInt16(edited.count - 1), command: MissionCmd.land, latitude: -35.1, longitude: 149.1, altitude: 0)
        v.dropSeq = edited.count - 1
        let s = MissionSession(targetSystem: 1, config: .narrowLink)
        let up = run(s, v, start: s.startUpload(.mission, items: edited, now: 0))
        XCTAssertFalse(up.contains(.uploaded(type: .mission, count: edited.count)), "stale last item reported as uploaded: \(up.suffix(2))")
        XCTAssertEqual(v.stored[0]?.last?.command, old.last?.command, "the simulated vehicle should still hold the old last item")
    }

    /// Review 2: a fence edit that keeps the vertex count and the last vertex: the vehicle times out and keeps the whole
    /// OLD fence. Only a full read-back notices; the session must not report "uploaded".
    func testFenceUploadNotConfirmedWhenVehicleKeptOldFence() {
        let v = SimulatedMissionVehicle(dropRate: 0)
        v.arduPilotLike = true
        v.writeThrough = true
        let corners = [(-35.36, 149.16), (-35.36, 149.17), (-35.37, 149.17), (-35.37, 149.16)]
        let old = corners.enumerated().map { i, c in
            MissionItem(seq: UInt16(i), frame: 0, command: MissionCmd.fencePolygonInclusion, param1: 4,
                        latitude: c.0, longitude: c.1, missionType: .fence)
        }
        v.stored[1] = old
        var edited = old
        edited[1].latitude = -35.355 // drag a middle vertex
        v.dropSeq = 3                 // the last vertex never arrives → vehicle times out
        let s = MissionSession(targetSystem: 1, config: .narrowLink)
        let up = run(s, v, start: s.startUpload(.fence, items: edited, now: 0))
        XCTAssertFalse(up.contains(.uploaded(type: .fence, count: 4)), "old fence reported as uploaded: \(up.suffix(2))")
        XCTAssertEqual(v.stored[1]?[1].x, old[1].x, "the simulated vehicle should still hold the old fence")
    }

    /// Review 3: a single fence circle (count 1) that moved, and a radius-only change of a circle; the last item is lost
    /// until the vehicle times out and keeps its old fence. Neither may be reported as uploaded.
    func testSingleFenceCircleAndRadiusChangeAreVerified() {
        func circle(_ lat: Double, _ radius: Float, seq: UInt16 = 0) -> MissionItem {
            MissionItem(seq: seq, frame: 0, command: MissionCmd.fenceCircleInclusion, param1: radius,
                        latitude: lat, longitude: 149.16, missionType: .fence)
        }
        for (old, edited) in [([circle(-35.36, 50)], [circle(-35.30, 50)]),              // moved ~7 km, count 1
                              ([circle(-35.36, 50)], [circle(-35.36, 20)])] {             // radius only
            let v = SimulatedMissionVehicle(dropRate: 0)
            v.arduPilotLike = true
            v.writeThrough = true
            v.stored[1] = old
            v.dropSeq = edited.count - 1
            let s = MissionSession(targetSystem: 1, config: .narrowLink)
            let up = run(s, v, start: s.startUpload(.fence, items: edited, now: 0))
            XCTAssertFalse(up.contains(.uploaded(type: .fence, count: edited.count)), "old fence reported as uploaded: \(up.suffix(2))")
        }
    }

    /// Review 4 (optional): a single rally point that moved; its only item is lost and the vehicle keeps the old one.
    func testSingleRallyPointMoveIsVerified() {
        let old = [MissionItem(seq: 0, frame: 3, command: MissionCmd.rallyPoint, latitude: -35.36, longitude: 149.16, altitude: 30, missionType: .rally)]
        let edited = [MissionItem(seq: 0, frame: 3, command: MissionCmd.rallyPoint, latitude: -35.30, longitude: 149.16, altitude: 30, missionType: .rally)]
        let v = SimulatedMissionVehicle(dropRate: 0)
        v.arduPilotLike = true
        v.writeThrough = true
        v.stored[2] = old
        v.dropSeq = 0
        let s = MissionSession(targetSystem: 1, config: .narrowLink)
        let up = run(s, v, start: s.startUpload(.rally, items: edited, now: 0))
        XCTAssertFalse(up.contains(.uploaded(type: .rally, count: 1)), "old rally point reported as uploaded: \(up.suffix(2))")
    }

    /// BUG-033: uploads to an ArduPilot-like vehicle at 30 % loss each way must all end "uploaded" (verified by read-back
    /// when the final ACK is lost), never "Invalid sequence" / "Error". Review 1: 200 runs, no failure allowed.
    func testUploadToArduPilotLikeVehicleSurvivesLoss() {
        var failures: [String] = []
        // Seeded (review 4), so the result is repeatable. LOSSY_RUNS=3000 tries more seeds: about 1 in 3000 then ends in
        // "No answer from vehicle" because 16 tries in a row for one item were lost (0.51^16): the dead-link limit, by design.
        let runs = ProcessInfo.processInfo.environment["LOSSY_RUNS"].flatMap { Int($0) } ?? 200
        for attempt in 0..<runs {
            let v = SimulatedMissionVehicle(dropRate: 0.3, seed: UInt64(attempt))
            v.arduPilotLike = true
            let s = MissionSession(targetSystem: 1, config: .narrowLink)
            let items = sampleMission(13)
            let up = run(s, v, start: s.startUpload(.mission, items: items, now: 0))
            if !up.contains(.uploaded(type: .mission, count: items.count)) { failures.append("run \(attempt): \(up.suffix(1))") }
            else if v.stored[0]?.count != items.count { failures.append("run \(attempt): stored \(v.stored[0]?.count ?? -1)") }
        }
        XCTAssertEqual(failures.count, 0, "\(failures.count)/\(runs) failed: \(failures.prefix(3))")
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
