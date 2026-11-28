// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Mavlink/MAVLinkInterface.cs
//   getWPCount / getWP / setWPTotal / setWP / setWPACK and ExtLibs/ArduPilot/Mavlink/MAVLinkMission
//   (download: MISSION_REQUEST_LIST -> MISSION_COUNT -> MISSION_REQUEST_INT(seq) -> MISSION_ITEM_INT
//    ... -> MISSION_ACK; upload: MISSION_COUNT -> vehicle MISSION_REQUEST(_INT)(seq) -> MISSION_ITEM_INT
//    ... -> vehicle MISSION_ACK). Same protocol with mission_type 1 (fence) and 2 (rally).
// For mission_type 0 ArduPilot's item 0 is HOME (Mission Planner shows it as "Home", user
// waypoints start at 1). Fence and rally lists have no home item.
//
// Pure state machine (caller supplies `now`, sends what it returns, feeds replies back).

import Foundation

public enum MissionType: UInt8, CaseIterable {
    case mission = 0, fence = 1, rally = 2

    public var label: String {
        switch self {
        case .mission: return "Mission"
        case .fence: return "Fence"
        case .rally: return "Rally"
        }
    }
}

public enum MAVFrame {
    public static let global: UInt8 = 0                 // altitude AMSL
    public static let globalRelativeAlt: UInt8 = 3      // altitude above home
    public static let globalTerrainAlt: UInt8 = 10      // altitude above terrain
}

public enum MissionCmd {
    public static let waypoint: UInt16 = 16
    public static let loiterUnlim: UInt16 = 17
    public static let loiterTurns: UInt16 = 18
    public static let loiterTime: UInt16 = 19
    public static let returnToLaunch: UInt16 = 20
    public static let land: UInt16 = 21
    public static let takeoff: UInt16 = 22
    public static let splineWaypoint: UInt16 = 82
    public static let doJump: UInt16 = 177
    public static let doChangeSpeed: UInt16 = 178
    public static let doSetCamTriggDist: UInt16 = 206
    public static let fencePolygonInclusion: UInt16 = 5001
    public static let fencePolygonExclusion: UInt16 = 5002
    public static let fenceCircleInclusion: UInt16 = 5003
    public static let fenceCircleExclusion: UInt16 = 5004
    public static let rallyPoint: UInt16 = 5100

    /// Commands whose X/Y are a location (drawn on the map).
    public static func hasLocation(_ cmd: UInt16) -> Bool {
        switch cmd {
        case 16, 17, 18, 19, 21, 22, 31, 82, 84, 85, 94, 195, 201, 5001, 5002, 5003, 5004, 5100: return true
        default: return false
        }
    }
}

public struct MissionItem: Equatable {
    public var seq: UInt16
    public var frame: UInt8
    public var command: UInt16
    public var current: UInt8
    public var autocontinue: UInt8
    public var param1: Float
    public var param2: Float
    public var param3: Float
    public var param4: Float
    /// Latitude * 1e7 (MISSION_ITEM_INT x)
    public var x: Int32
    /// Longitude * 1e7 (MISSION_ITEM_INT y)
    public var y: Int32
    /// Altitude in metres, meaning depends on `frame`
    public var z: Float
    public var missionType: UInt8

    public init(seq: UInt16 = 0, frame: UInt8 = MAVFrame.globalRelativeAlt, command: UInt16 = MissionCmd.waypoint,
                current: UInt8 = 0, autocontinue: UInt8 = 1, param1: Float = 0, param2: Float = 0, param3: Float = 0,
                param4: Float = 0, latitude: Double = 0, longitude: Double = 0, altitude: Float = 0,
                missionType: MissionType = .mission) {
        self.seq = seq
        self.frame = frame
        self.command = command
        self.current = current
        self.autocontinue = autocontinue
        self.param1 = param1
        self.param2 = param2
        self.param3 = param3
        self.param4 = param4
        self.x = Self.e7(latitude)   // BUG-007: never trap on NaN/out-of-range input
        self.y = Self.e7(longitude)
        self.z = altitude
        self.missionType = missionType.rawValue
    }

    public var latitude: Double {
        get { Double(x) / 1e7 }
        set { x = Self.e7(newValue) } // BUG-007
    }

    public var longitude: Double {
        get { Double(y) / 1e7 }
        set { y = Self.e7(newValue) } // BUG-007
    }

    public var hasLocation: Bool { MissionCmd.hasLocation(command) && (x != 0 || y != 0) }

    /// BUG-007: degrees → 1e7 integer without trapping. Non-finite → 0, out-of-range values clamp to Int32.
    /// Callers that accept user/file input validate the range first (`isValidCoordinate`).
    public static func e7(_ degrees: Double) -> Int32 {
        guard degrees.isFinite else { return 0 }
        let v = (degrees * 1e7).rounded()
        return Int32(max(Double(Int32.min), min(Double(Int32.max), v)))
    }

    /// Latitude/longitude a vehicle can fly to.
    public static func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        latitude.isFinite && longitude.isFinite && abs(latitude) <= 90 && abs(longitude) <= 180
    }

    public init(_ m: MAV.MissionItemInt) {
        seq = m.seq; frame = m.frame; command = m.command; current = m.current; autocontinue = m.autocontinue
        param1 = m.param1; param2 = m.param2; param3 = m.param3; param4 = m.param4
        x = m.x; y = m.y; z = m.z; missionType = m.missionType
    }

    /// Legacy MISSION_ITEM (float lat/lon) from old firmware.
    public init(_ m: MAV.MissionItem) {
        seq = m.seq; frame = m.frame; command = m.command; current = m.current; autocontinue = m.autocontinue
        param1 = m.param1; param2 = m.param2; param3 = m.param3; param4 = m.param4
        // BUG-007: only location commands carry degrees in x/y; for the others x/y are param5/param6 (raw values).
        if MissionCmd.hasLocation(m.command) {
            x = Self.e7(Double(m.x)); y = Self.e7(Double(m.y))
        } else {
            x = Int32(max(Double(Int32.min), min(Double(Int32.max), Double(m.x.isFinite ? m.x : 0).rounded())))
            y = Int32(max(Double(Int32.min), min(Double(Int32.max), Double(m.y.isFinite ? m.y : 0).rounded())))
        }
        z = m.z
        missionType = m.missionType
    }

    public func message(targetSystem: UInt8, targetComponent: UInt8) -> MAV.MissionItemInt {
        MAV.MissionItemInt(param1: param1, param2: param2, param3: param3, param4: param4, x: x, y: y, z: z,
                           seq: seq, command: command, targetSystem: targetSystem, targetComponent: targetComponent,
                           frame: frame, current: current, autocontinue: autocontinue, missionType: missionType)
    }
}

public enum MAVMissionResult {
    public static func text(_ r: UInt8) -> String {
        switch r {
        case 0: return "Accepted"
        case 1: return "Error"
        case 2: return "Unsupported frame"
        case 3: return "Unsupported command"
        case 4: return "No space (too many items)"
        case 5: return "Invalid parameter"
        case 6, 7, 8, 9, 10, 11, 12: return "Invalid parameter \(r - 5)"
        case 13: return "Invalid sequence"
        case 14: return "Denied"
        case 15: return "Cancelled"
        default: return "Result \(r)"
        }
    }
}

public final class MissionSession {
    public struct Config {
        public var timeout: TimeInterval = 1.5
        public var retries = 5
        public init() {}
        public static var narrowLink: Config {
            var c = Config()
            c.timeout = 3
            c.retries = 15 // retries reset on every bit of progress; this only bounds a dead link
            return c
        }
    }

    public enum Event: Equatable {
        case progress(type: MissionType, done: Int, total: Int)
        case downloaded(type: MissionType, items: [MissionItem])
        case uploaded(type: MissionType, count: Int)
        case failed(type: MissionType, reason: String)
    }

    private enum Op {
        case idle
        case downloadWaitCount(MissionType)
        case downloadItems(MissionType, count: Int, next: Int, items: [MissionItem])
        case upload(MissionType, items: [MissionItem], lastRequested: Int?)
        /// BUG-033: the final ACK may have been lost; read MISSION_COUNT back to confirm the upload…
        case uploadVerify(MissionType, items: [MissionItem])
        /// …then items from `next` on (review 1: missions/rally are written item by item, so a vehicle that timed out keeps
        /// the OLD last item → check the last one; review 2: ArduPilot keeps the whole OLD fence on timeout → check all).
        case uploadVerifyLast(MissionType, items: [MissionItem], next: Int)
    }

    public let targetSystem: UInt8
    public let targetComponent: UInt8
    public var config: Config

    private var op: Op = .idle
    private var lastActivity: TimeInterval = 0
    private var attempts = 0

    public init(targetSystem: UInt8, targetComponent: UInt8 = 1, config: Config = Config()) {
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
        self.config = config
    }

    public var isBusy: Bool {
        if case .idle = op { return false }
        return true
    }

    // MARK: start

    public func startDownload(_ type: MissionType, now: TimeInterval) -> [MAVLinkMessage] {
        op = .downloadWaitCount(type)
        lastActivity = now
        attempts = 0
        return [MAV.MissionRequestList(targetSystem: targetSystem, targetComponent: targetComponent, missionType: type.rawValue)]
    }

    /// Items are renumbered 0..n-1 and stamped with `type`. For `.mission`, item 0 must be home.
    public func startUpload(_ type: MissionType, items: [MissionItem], now: TimeInterval) -> [MAVLinkMessage] {
        var numbered = items
        for i in numbered.indices {
            numbered[i].seq = UInt16(i)
            numbered[i].missionType = type.rawValue
            numbered[i].current = (type == .mission && i == 0) ? 1 : 0
        }
        op = .upload(type, items: numbered, lastRequested: nil)
        lastActivity = now
        attempts = 0
        return [countMessage(type, numbered.count)]
    }

    public func clearAll(_ type: MissionType) -> [MAVLinkMessage] {
        [MAV.MissionClearAll(targetSystem: targetSystem, targetComponent: targetComponent, missionType: type.rawValue)]
    }

    public func setCurrent(_ seq: UInt16) -> [MAVLinkMessage] {
        [MAV.MissionSetCurrent(seq: seq, targetSystem: targetSystem, targetComponent: targetComponent)]
    }

    public func cancel() {
        op = .idle
    }

    private func countMessage(_ type: MissionType, _ n: Int) -> MAVLinkMessage {
        MAV.MissionCount(count: UInt16(n), targetSystem: targetSystem, targetComponent: targetComponent, missionType: type.rawValue)
    }

    private func requestItem(_ type: MissionType, _ seq: Int) -> MAVLinkMessage {
        MAV.MissionRequestInt(seq: UInt16(seq), targetSystem: targetSystem, targetComponent: targetComponent, missionType: type.rawValue)
    }

    private func ack(_ type: MissionType, _ result: UInt8 = 0) -> MAVLinkMessage {
        MAV.MissionAck(targetSystem: targetSystem, targetComponent: targetComponent, type: result, missionType: type.rawValue)
    }

    // MARK: input

    /// Feed every mission-protocol packet from the vehicle here.
    public func handle(_ packet: MAVLinkPacket, now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        switch op {
        case .idle:
            return ([], [])

        case .downloadWaitCount(let type):
            guard let c = packet.decode(MAV.MissionCount.self), c.missionType == type.rawValue else { return ([], []) }
            lastActivity = now
            attempts = 0
            if c.count == 0 {
                op = .idle
                return ([ack(type)], [.downloaded(type: type, items: [])])
            }
            op = .downloadItems(type, count: Int(c.count), next: 0, items: [])
            return ([requestItem(type, 0)], [.progress(type: type, done: 0, total: Int(c.count))])

        case .downloadItems(let type, let count, let next, var items):
            var item: MissionItem?
            if let m = packet.decode(MAV.MissionItemInt.self) { item = MissionItem(m) }
            else if let m = packet.decode(MAV.MissionItem.self) { item = MissionItem(m) }
            guard let it = item, it.missionType == type.rawValue, Int(it.seq) == next else { return ([], []) }
            items.append(it)
            lastActivity = now
            attempts = 0
            if items.count >= count {
                op = .idle
                return ([ack(type)], [.downloaded(type: type, items: items)])
            }
            op = .downloadItems(type, count: count, next: next + 1, items: items)
            return ([requestItem(type, next + 1)], [.progress(type: type, done: items.count, total: count)])

        case .upload(let type, let items, let lastRequested):
            var requested: Int?
            if let r = packet.decode(MAV.MissionRequestInt.self), r.missionType == type.rawValue { requested = Int(r.seq) }
            else if let r = packet.decode(MAV.MissionRequest.self), r.missionType == type.rawValue { requested = Int(r.seq) }
            if let seq = requested {
                guard seq < items.count else {
                    op = .idle
                    return ([], [.failed(type: type, reason: "Vehicle asked for item \(seq) of \(items.count)")])
                }
                lastActivity = now
                attempts = 0
                op = .upload(type, items: items, lastRequested: seq)
                return ([items[seq].message(targetSystem: targetSystem, targetComponent: targetComponent)],
                        [.progress(type: type, done: seq + 1, total: items.count)])
            }
            if let a = packet.decode(MAV.MissionAck.self), a.missionType == type.rawValue {
                if a.type == 0 {
                    op = .idle
                    return ([], [.uploaded(type: type, count: items.count)])
                }
                // BUG-033: ArduPilot answers a duplicate (resent) item with INVALID_SEQUENCE but keeps the upload open
                // and re-requests the item it wants. Not an error: keep waiting.
                if a.type == 13 {
                    lastActivity = now
                    return ([], [])
                }
                // BUG-033: after the last item, ERROR usually means our resend reached a vehicle that had already
                // stored everything (its ACCEPTED was lost; ArduPilot does not re-ACK). Verify by reading the count.
                if a.type == 1, lastRequested == items.count - 1 {
                    return startVerify(type, items: items, now: now)
                }
                op = .idle
                return ([], [.failed(type: type, reason: MAVMissionResult.text(a.type))])
            }
            return ([], [])

        case .uploadVerify(let type, let items):
            // Still receiving after all? ArduPilot re-requests the item it wants: resume the upload.
            if let seq = Self.requestedSeq(packet, type), seq < items.count {
                return resumeUpload(type, items: items, seq: seq, now: now)
            }
            if let a = packet.decode(MAV.MissionAck.self), a.missionType == type.rawValue {
                if a.type == 0 { op = .idle; return ([], [.uploaded(type: type, count: items.count)]) }
                if a.type == 14 { lastActivity = now; return ([], []) } // DENIED: still receiving, keep waiting
                return ([], []) // other answers to the list request: wait for MISSION_COUNT or time out
            }
            guard let c = packet.decode(MAV.MissionCount.self), c.missionType == type.rawValue else { return ([], []) }
            // review 3: home-only *missions* only (ArduPilot rewrites home itself); a single fence circle or rally point
            // must still be read back.
            if type == .mission && Int(c.count) == items.count && items.count <= 1 {
                op = .idle
                return ([ack(type)], [.uploaded(type: type, count: items.count)])
            }
            guard Int(c.count) == items.count else {
                op = .idle
                return ([ack(type)], [.failed(type: type, reason: "Not confirmed: vehicle has \(c.count) items, expected \(items.count). Upload again.")])
            }
            let first = type == .fence ? 0 : items.count - 1
            op = .uploadVerifyLast(type, items: items, next: first)
            lastActivity = now
            attempts = 0
            return ([requestItem(type, first)], [])

        case .uploadVerifyLast(let type, let items, let next):
            var got: MissionItem?
            if let m = packet.decode(MAV.MissionItemInt.self) { got = MissionItem(m) }
            else if let m = packet.decode(MAV.MissionItem.self) { got = MissionItem(m) }
            guard let it = got, it.missionType == type.rawValue, Int(it.seq) == next else { return ([], []) }
            guard Self.sameItem(it, items[next], type: type) else {
                op = .idle
                return ([ack(type)], [.failed(type: type, reason: "Not confirmed: the vehicle's item \(next) differs from the plan. Upload again.")])
            }
            if next + 1 < items.count {
                op = .uploadVerifyLast(type, items: items, next: next + 1)
                lastActivity = now
                attempts = 0
                return ([requestItem(type, next + 1)], [])
            }
            op = .idle
            return ([ack(type)], [.uploaded(type: type, count: items.count)])
        }
    }

    private static func requestedSeq(_ packet: MAVLinkPacket, _ type: MissionType) -> Int? {
        if let r = packet.decode(MAV.MissionRequestInt.self), r.missionType == type.rawValue { return Int(r.seq) }
        if let r = packet.decode(MAV.MissionRequest.self), r.missionType == type.rawValue { return Int(r.seq) }
        return nil
    }

    private func resumeUpload(_ type: MissionType, items: [MissionItem], seq: Int, now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        op = .upload(type, items: items, lastRequested: seq)
        lastActivity = now
        attempts = 0
        return ([items[seq].message(targetSystem: targetSystem, targetComponent: targetComponent)],
                [.progress(type: type, done: seq + 1, total: items.count)])
    }

    /// Same item as sent, as far as ArduPilot stores it. Location items: command, position (1e-7°) and altitude
    /// (missions keep cm → ±5 cm; rally points keep whole metres → ±1 m). Non-location items (RTL, DO_*, …): command
    /// only, since ArduPilot keeps just the params a command uses. A stale old item differs in these.
    static func sameItem(_ a: MissionItem, _ b: MissionItem, type: MissionType = .mission) -> Bool {
        guard a.command == b.command else { return false }
        guard MissionCmd.hasLocation(b.command) || type != .mission else { return true }
        let altTolerance: Float = type == .rally ? 1.0 : 0.05
        guard abs(Int(a.x) - Int(b.x)) <= 1 && abs(Int(a.y) - Int(b.y)) <= 1 else { return false }
        if type == .fence {
            // review 3: param1 is the polygon vertex count (exact) or the circle radius (ArduPilot keeps it as a float;
            // allow ±1 m for rounding)
            let circle = b.command == MissionCmd.fenceCircleInclusion || b.command == MissionCmd.fenceCircleExclusion
            return circle ? abs(a.param1 - b.param1) <= 1 : a.param1 == b.param1
        }
        return abs(a.z - b.z) <= altTolerance
    }

    /// BUG-033: confirm an upload whose final ACK may be lost by asking for the vehicle's item count.
    private func startVerify(_ type: MissionType, items: [MissionItem], now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        op = .uploadVerify(type, items: items)
        lastActivity = now
        attempts = 0
        return ([MAV.MissionRequestList(targetSystem: targetSystem, targetComponent: targetComponent, missionType: type.rawValue)], [])
    }

    // MARK: timeouts

    public func tick(now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        guard isBusy, now - lastActivity >= config.timeout else { return ([], []) }
        lastActivity = now
        attempts += 1
        let type: MissionType
        let resend: MAVLinkMessage
        switch op {
        case .idle:
            return ([], [])
        case .downloadWaitCount(let t):
            type = t
            resend = MAV.MissionRequestList(targetSystem: targetSystem, targetComponent: targetComponent, missionType: t.rawValue)
        case .downloadItems(let t, _, let next, _):
            type = t
            resend = requestItem(t, next)
        case .upload(let t, let items, let lastRequested):
            type = t
            // BUG-033: retries for the last item ran out: the vehicle may have stored it and lost our ACK. Verify.
            if attempts > config.retries, lastRequested == items.count - 1 {
                return startVerify(t, items: items, now: now)
            }
            if let seq = lastRequested {
                resend = items[seq].message(targetSystem: targetSystem, targetComponent: targetComponent)
            } else {
                resend = countMessage(t, items.count)
            }
        case .uploadVerify(let t, _):
            type = t
            resend = MAV.MissionRequestList(targetSystem: targetSystem, targetComponent: targetComponent, missionType: t.rawValue)
        case .uploadVerifyLast(let t, _, let next):
            type = t
            resend = requestItem(t, next)
        }
        if attempts > config.retries {
            op = .idle
            return ([], [.failed(type: type, reason: "No answer from vehicle")])
        }
        return ([resend], [])
    }
}

// MARK: - .waypoints files

/// Mission Planner / QGroundControl "QGC WPL 110" text format:
/// `seq current frame command p1 p2 p3 p4 lat lon alt autocontinue` (tab separated).
/// REA Parity Source: MissionPlanner GCSViews/FlightPlanner.cs (SaveFile_Click / readQGC110wpfile).
public enum WaypointFile {
    public static let header = "QGC WPL 110"

    public static func format(_ items: [MissionItem]) -> String {
        var s = header + "\n"
        for (i, it) in items.enumerated() {
            let fields: [String] = [
                "\(i)", "\(i == 0 ? 1 : 0)", "\(it.frame)", "\(it.command)",
                num(it.param1), num(it.param2), num(it.param3), num(it.param4),
                String(format: "%.8f", it.latitude), String(format: "%.8f", it.longitude),
                String(format: "%.6f", it.z), "\(it.autocontinue)",
            ]
            s += fields.joined(separator: "\t") + "\n"
        }
        return s
    }

    private static func num(_ f: Float) -> String { String(format: "%.8f", Double(f)) }

    public enum ParseError: Error, Equatable {
        case notWaypointFile
        case badLine(Int)
        /// BUG-010: more items than the mission protocol (UInt16 seq) or any autopilot can hold.
        case tooManyItems(Int)
    }

    /// BUG-010: upper bound accepted from files (MAVLink seq is UInt16; ArduPilot boards hold a few thousand at most).
    public static let maxItems = 10_000

    public static func parse(_ text: String) throws -> [MissionItem] {
        let lines = text.split(whereSeparator: { $0.isNewline }).map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard let first = lines.first, first.hasPrefix("QGC WPL") else { throw ParseError.notWaypointFile }
        var out: [MissionItem] = []
        for (n, line) in lines.dropFirst().enumerated() {
            let c = line.split(whereSeparator: { $0 == "\t" || $0 == " " || $0 == "," }).map(String.init)
            guard c.count >= 12,
                  let frame = UInt8(c[2]), let cmd = UInt16(c[3]),
                  let p1 = Float(c[4]), let p2 = Float(c[5]), let p3 = Float(c[6]), let p4 = Float(c[7]),
                  let lat = Double(c[8]), let lon = Double(c[9]), let alt = Float(c[10]), let ac = UInt8(c[11]) else {
                throw ParseError.badLine(n + 2)
            }
            // BUG-007: reject non-finite values and impossible positions instead of trapping later.
            guard p1.isFinite, p2.isFinite, p3.isFinite, p4.isFinite, lat.isFinite, lon.isFinite, alt.isFinite,
                  !MissionCmd.hasLocation(cmd) || MissionItem.isValidCoordinate(latitude: lat, longitude: lon) else {
                throw ParseError.badLine(n + 2)
            }
            guard out.count < maxItems else { throw ParseError.tooManyItems(lines.count - 1) } // BUG-010
            out.append(MissionItem(seq: UInt16(out.count), frame: frame, command: cmd, current: 0, autocontinue: ac,
                                   param1: p1, param2: p2, param3: p3, param4: p4,
                                   latitude: lat, longitude: lon, altitude: alt))
        }
        return out
    }
}

// MARK: - Geometry

public struct GeoPoint: Equatable, Hashable {
    public var latitude: Double
    public var longitude: Double
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum Geo {
    public static let earthRadius = 6_378_137.0

    /// Great-circle distance in metres.
    public static func distance(_ a: GeoPoint, _ b: GeoPoint) -> Double {
        let p1 = a.latitude * .pi / 180, p2 = b.latitude * .pi / 180
        let dp = p2 - p1, dl = (b.longitude - a.longitude) * .pi / 180
        let h = sin(dp / 2) * sin(dp / 2) + cos(p1) * cos(p2) * sin(dl / 2) * sin(dl / 2)
        return 2 * earthRadius * asin(min(1, sqrt(h)))
    }

    /// Initial bearing a -> b in degrees 0..360.
    public static func bearing(_ a: GeoPoint, _ b: GeoPoint) -> Double {
        let p1 = a.latitude * .pi / 180, p2 = b.latitude * .pi / 180
        let dl = (b.longitude - a.longitude) * .pi / 180
        let y = sin(dl) * cos(p2)
        let x = cos(p1) * sin(p2) - sin(p1) * cos(p2) * cos(dl)
        let d = atan2(y, x) * 180 / .pi
        return d < 0 ? d + 360 : d
    }

    /// Local tangent-plane projection around `origin` (metres east/north). Good to well under
    /// 0.1% over a few km, which is what survey grids span.
    public static func toLocal(_ p: GeoPoint, origin: GeoPoint) -> (x: Double, y: Double) {
        let x = (p.longitude - origin.longitude) * .pi / 180 * earthRadius * cos(origin.latitude * .pi / 180)
        let y = (p.latitude - origin.latitude) * .pi / 180 * earthRadius
        return (x, y)
    }

    public static func fromLocal(x: Double, y: Double, origin: GeoPoint) -> GeoPoint {
        let lat = origin.latitude + y / earthRadius * 180 / .pi
        let lon = origin.longitude + x / (earthRadius * cos(origin.latitude * .pi / 180)) * 180 / .pi
        return GeoPoint(latitude: lat, longitude: lon)
    }

    /// Polygon area in m² (shoelace in the local plane).
    public static func area(_ polygon: [GeoPoint]) -> Double {
        guard polygon.count >= 3 else { return 0 }
        let o = polygon[0]
        let pts = polygon.map { toLocal($0, origin: o) }
        var s = 0.0
        for i in pts.indices {
            let j = (i + 1) % pts.count
            s += pts[i].x * pts[j].y - pts[j].x * pts[i].y
        }
        return abs(s) / 2
    }
}

/// Lawn-mower survey pattern inside a polygon.
/// REA Parity Source: MissionPlanner ExtLibs/Utilities/Grid.cs CreateGrid (lines at `angle`,
/// `spacing` apart, clipped to the polygon, alternate direction, optional overshoot).
public enum SurveyGrid {
    public struct Options: Equatable {
        public var spacing: Double = 20       // metres between lines
        public var angle: Double = 0          // degrees, 0 = lines run north-south
        public var overshoot: Double = 0      // metres added past each end of a line
        public var altitude: Float = 50
        public init() {}
    }

    /// Returns the turn points (two per line) in flight order.
    public static func generate(polygon: [GeoPoint], options o: Options) -> [GeoPoint] {
        guard polygon.count >= 3, o.spacing > 0.5 else { return [] }
        let origin = GeoPoint(latitude: polygon.map(\.latitude).reduce(0, +) / Double(polygon.count),
                              longitude: polygon.map(\.longitude).reduce(0, +) / Double(polygon.count))
        // rotate so survey lines are parallel to the local y axis
        let a = o.angle * .pi / 180
        let rot = { (x: Double, y: Double) -> (Double, Double) in (x * cos(a) - y * sin(a), x * sin(a) + y * cos(a)) }
        let unrot = { (x: Double, y: Double) -> (Double, Double) in (x * cos(a) + y * sin(a), -x * sin(a) + y * cos(a)) }
        let pts = polygon.map { p -> (Double, Double) in
            let l = Geo.toLocal(p, origin: origin)
            return rot(l.x, l.y)
        }
        let minX = pts.map { $0.0 }.min()!, maxX = pts.map { $0.0 }.max()!
        var out: [GeoPoint] = []
        var forward = true
        var x = minX + o.spacing / 2
        while x < maxX {
            var ys: [Double] = []
            for i in pts.indices {
                let p = pts[i], q = pts[(i + 1) % pts.count]
                if (p.0 <= x && q.0 > x) || (q.0 <= x && p.0 > x) {
                    ys.append(p.1 + (x - p.0) / (q.0 - p.0) * (q.1 - p.1))
                }
            }
            ys.sort()
            // pairs of crossings = inside segments (handles concave shapes)
            var segments: [(Double, Double)] = []
            var k = 0
            while k + 1 < ys.count {
                segments.append((ys[k] - o.overshoot, ys[k + 1] + o.overshoot))
                k += 2
            }
            if !forward { segments = segments.reversed().map { ($0.1, $0.0) } }
            for s in segments {
                for y in [s.0, s.1] {
                    let (lx, ly) = unrot(x, y)
                    out.append(Geo.fromLocal(x: lx, y: ly, origin: origin))
                }
            }
            forward.toggle()
            x += o.spacing
        }
        return out
    }
}
