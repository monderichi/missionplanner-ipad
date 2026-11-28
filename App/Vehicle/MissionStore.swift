// REA Parity Source: MissionPlanner GCSViews/FlightPlanner.cs (waypoint grid: add on map click,
// drag to move, insert/delete, default alt, frame Relative/Absolute/Terrain, Read/Write WPs,
// Load/Save .waypoints, home as item 0, geofence + rally point editing).
// Holds the plan being edited and drives MAVLinkKit.MissionSession for the vehicle.

import Foundation
import MAVLinkKit

struct MissionCommandInfo: Decodable, Identifiable, Hashable {
    let id: UInt16
    let name: String
    /// Labels for P1, P2, P3, P4, X(lat), Y(lon), Z(alt). Empty = unused.
    let p: [String]

    var title: String { name.replacingOccurrences(of: "_", with: " ").capitalized }
    var usesLocation: Bool { p.count == 7 && (!p[4].isEmpty || !p[5].isEmpty) }
    var usesAltitude: Bool { p.count == 7 && !p[6].isEmpty }
}

enum MissionCommandCatalog {
    private static var cache: [String: [MissionCommandInfo]]?

    /// copter / plane / rover lists from Mission Planner's mavcmd.xml (App/Resources/MissionCommands.json).
    static func commands(vehicleType: UInt8) -> [MissionCommandInfo] {
        if cache == nil {
            let url = Bundle.main.url(forResource: "MissionCommands", withExtension: "json")
            cache = url.flatMap { try? Data(contentsOf: $0) }
                .flatMap { try? JSONDecoder().decode([String: [MissionCommandInfo]].self, from: $0) } ?? [:]
        }
        let key: String
        switch MAVType(rawValue: vehicleType)?.firmware {
        case .plane: key = "plane"
        case .rover: key = "rover"
        default: key = "copter"
        }
        return cache?[key] ?? []
    }

    static func info(_ command: UInt16, vehicleType: UInt8) -> MissionCommandInfo? {
        commands(vehicleType: vehicleType).first { $0.id == command }
    }

    static func name(_ command: UInt16, vehicleType: UInt8) -> String {
        switch command {
        case MissionCmd.fencePolygonInclusion: return "Fence vertex (inclusion)"
        case MissionCmd.fencePolygonExclusion: return "Fence vertex (exclusion)"
        case MissionCmd.fenceCircleInclusion: return "Fence circle (inclusion)"
        case MissionCmd.fenceCircleExclusion: return "Fence circle (exclusion)"
        case MissionCmd.rallyPoint: return "Rally point"
        default: return info(command, vehicleType: vehicleType)?.title ?? "Command \(command)"
        }
    }
}

final class MissionStore: ObservableObject {
    /// index 0 = home (ArduPilot convention), user waypoints from 1
    @Published var mission: [MissionItem] = [] { didSet { version += 1 } }
    @Published var fence: [MissionItem] = [] { didSet { version += 1 } }
    @Published var rally: [MissionItem] = [] { didSet { version += 1 } }
    /// Survey polygon being drawn (not sent to the vehicle).
    @Published var surveyPolygon: [GeoPoint] = [] { didSet { version += 1 } }
    /// Bumped on every change; the map uses it to know when to redraw.
    @Published private(set) var version = 0

    @Published private(set) var busy: MissionType?
    @Published private(set) var progress: (done: Int, total: Int)?
    @Published var banner: String?
    @Published var defaultAltitude: Float = UserDefaults.standard.object(forKey: "plan.defaultAlt") as? Float ?? 50 {
        didSet { UserDefaults.standard.set(defaultAltitude, forKey: "plan.defaultAlt") }
    }
    @Published var defaultFrame: UInt8 = MAVFrame.globalRelativeAlt

    var send: ((MAVLinkMessage) -> Void)?
    /// Supplies the vehicle's home/position when the plan needs a home item.
    var homeProvider: (() -> GeoPoint?)?
    var vehicleType: UInt8 = 2

    private var session: MissionSession?
    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
    var isAttached: Bool { session != nil }

    // MARK: lifecycle

    func attach(systemID: UInt8, componentID: UInt8, vehicleType: UInt8, narrowLink: Bool) {
        session = MissionSession(targetSystem: systemID, targetComponent: componentID,
                                 config: narrowLink ? .narrowLink : MissionSession.Config())
        self.vehicleType = vehicleType
        busy = nil
        progress = nil
    }

    func detach() {
        session?.cancel()
        session = nil
        busy = nil
        progress = nil
    }

    // MARK: vehicle transfer

    func read(_ type: MissionType) {
        guard let session, !session.isBusy else { return }
        guidedSent = nil // review 1: this transfer's MISSION_ACK must not be read as the fly-here answer
        session.startDownload(type, now: now).forEach { send?($0) }
        busy = type
        progress = nil
        banner = "Reading \(type.label.lowercased()) from vehicle…"
    }

    func write(_ type: MissionType) {
        guard let session, !session.isBusy else { return }
        guidedSent = nil // review 1
        var items: [MissionItem]
        switch type {
        case .mission:
            ensureHome()
            items = mission
        case .fence:
            items = Self.numberFenceGroups(fence)
        case .rally:
            items = rally
        }
        session.startUpload(type, items: items, now: now).forEach { send?($0) }
        busy = type
        progress = nil
        banner = "Writing \(items.count) \(type.label.lowercased()) items…"
    }

    /// Guided "fly here" (MissionPlanner setGuidedModeWP: MISSION_ITEM_INT with current = 2).
    /// The vehicle must be in GUIDED; altitude is relative to home.
    func guidedGoTo(_ p: GeoPoint, altitude: Float) {
        guard let session else { return }
        var it = MissionItem(frame: MAVFrame.globalRelativeAlt, command: MissionCmd.waypoint,
                             latitude: p.latitude, longitude: p.longitude, altitude: altitude)
        it.current = 2
        send?(it.message(targetSystem: session.targetSystem, targetComponent: session.targetComponent))
        // BUG-011: the vehicle answers a guided target with MISSION_ACK; report what it said (handle()).
        guidedSent = (Date(), String(format: "%.6f, %.6f at %.0f m", p.latitude, p.longitude, altitude))
        banner = "Fly here: sent \(guidedSent!.1)…"
    }

    func setCurrent(_ seq: Int) {
        session?.setCurrent(UInt16(seq)).forEach { send?($0) }
        banner = "Jumping to waypoint \(seq)"
    }

    /// BUG-011: last guided ("fly here") target sent, awaiting the vehicle's MISSION_ACK.
    private var guidedSent: (Date, String)?

    func handle(_ packet: MAVLinkPacket) {
        guard let session else { return }
        if !session.isBusy, let g = guidedSent, Date().timeIntervalSince(g.0) < 5,
           let a = packet.decode(MAV.MissionAck.self), a.missionType == 0 {
            guidedSent = nil
            banner = a.type == 0 ? "Flying to \(g.1)" : "Fly here rejected: \(MAVMissionResult.text(a.type)) (is the vehicle in Guided?)"
            return
        }
        let r = session.handle(packet, now: now)
        r.messages.forEach { send?($0) }
        r.events.forEach(apply)
    }

    func tick() {
        guard let session else { return }
        // BUG-011 (review 1): no MISSION_ACK within 5 s: say so instead of "sent…" forever.
        if let g = guidedSent, Date().timeIntervalSince(g.0) > 5 {
            guidedSent = nil
            banner = "Fly here: no answer from the vehicle (target \(g.1))"
        }
        let r = session.tick(now: now)
        r.messages.forEach { send?($0) }
        r.events.forEach(apply)
    }

    private func apply(_ e: MissionSession.Event) {
        switch e {
        case .progress(_, let done, let total):
            progress = (done, total)
        case .downloaded(let type, let items):
            switch type {
            case .mission: mission = items
            case .fence: fence = items
            case .rally: rally = items
            }
            busy = nil
            progress = nil
            let n = type == .mission ? max(0, items.count - 1) : items.count
            banner = "Read \(n) \(type.label.lowercased()) items"
        case .uploaded(let type, let count):
            busy = nil
            progress = nil
            let n = type == .mission ? max(0, count - 1) : count
            banner = "Wrote \(n) \(type.label.lowercased()) items. Vehicle accepted."
        case .failed(let type, let reason):
            busy = nil
            progress = nil
            banner = "\(type.label) transfer failed: \(reason)"
        }
    }

    // MARK: editing

    func items(_ type: MissionType) -> [MissionItem] {
        switch type {
        case .mission: return mission
        case .fence: return fence
        case .rally: return rally
        }
    }

    func setItems(_ type: MissionType, _ items: [MissionItem]) {
        // BUG-010: more than WaypointFile.maxItems can't be uploaded (UInt16 seq; boards hold far fewer): refuse.
        guard items.count <= WaypointFile.maxItems else {
            banner = "Too many items (\(items.count)); the limit is \(WaypointFile.maxItems)."
            return
        }
        let numbered = items.enumerated().map { i, it -> MissionItem in
            var m = it
            m.seq = UInt16(clamping: i) // BUG-010 (lists are capped below)
            m.missionType = type.rawValue
            return m
        }
        switch type {
        case .mission: mission = numbered
        case .fence: fence = numbered
        case .rally: rally = numbered
        }
    }

    /// Home item from the vehicle (or first waypoint) if the plan doesn't have one yet.
    func ensureHome(fallback: GeoPoint? = nil) {
        if let first = mission.first, first.seq == 0, first.command == MissionCmd.waypoint, first.frame == MAVFrame.global {
            if first.x == 0 && first.y == 0, let h = homeProvider?() ?? fallback {
                mission[0].latitude = h.latitude
                mission[0].longitude = h.longitude
            }
            return
        }
        let h = homeProvider?() ?? fallback ?? GeoPoint(latitude: 0, longitude: 0)
        let home = MissionItem(frame: MAVFrame.global, command: MissionCmd.waypoint, latitude: h.latitude,
                               longitude: h.longitude, altitude: 0)
        setItems(.mission, [home] + mission)
    }

    func add(_ type: MissionType, at p: GeoPoint) {
        switch type {
        case .mission:
            ensureHome(fallback: p)
            var it = MissionItem(frame: defaultFrame, command: MissionCmd.waypoint, latitude: p.latitude,
                                 longitude: p.longitude, altitude: defaultAltitude)
            it.seq = UInt16(clamping: mission.count) // BUG-010
            mission.append(it)
        case .fence:
            setItems(.fence, fence + [MissionItem(frame: MAVFrame.global, command: MissionCmd.fencePolygonInclusion,
                                                  latitude: p.latitude, longitude: p.longitude, missionType: .fence)])
        case .rally:
            setItems(.rally, rally + [MissionItem(frame: defaultFrame, command: MissionCmd.rallyPoint,
                                                  latitude: p.latitude, longitude: p.longitude,
                                                  altitude: defaultAltitude, missionType: .rally)])
        }
    }

    func move(_ type: MissionType, index: Int, to p: GeoPoint) {
        var list = items(type)
        guard list.indices.contains(index) else { return }
        list[index].latitude = p.latitude
        list[index].longitude = p.longitude
        setItems(type, list)
    }

    func update(_ type: MissionType, index: Int, _ item: MissionItem) {
        var list = items(type)
        guard list.indices.contains(index) else { return }
        list[index] = item
        setItems(type, list)
    }

    func delete(_ type: MissionType, at offsets: IndexSet) {
        var list = items(type)
        // never delete the home item
        let safe = type == .mission ? IndexSet(offsets.filter { $0 != 0 }) : offsets
        for i in safe.sorted(by: >) where list.indices.contains(i) { list.remove(at: i) }
        setItems(type, list)
    }

    func moveItems(_ type: MissionType, from: IndexSet, to: Int) {
        var list = items(type)
        if type == .mission && (from.contains(0) || to == 0) { return } // home stays first
        let moving = from.sorted().map { list[$0] }
        for i in from.sorted(by: >) { list.remove(at: i) }
        let dest = to - from.filter { $0 < to }.count
        list.insert(contentsOf: moving, at: max(0, min(dest, list.count)))
        setItems(type, list)
    }

    func insert(_ type: MissionType, _ item: MissionItem, at index: Int) {
        var list = items(type)
        list.insert(item, at: max(type == .mission ? 1 : 0, min(index, list.count)))
        setItems(type, list)
    }

    func clear(_ type: MissionType) {
        switch type {
        case .mission: mission = mission.first.map { [$0] } ?? []
        case .fence: fence = []
        case .rally: rally = []
        }
    }

    /// Appends a survey: optional camera trigger distance, the grid turn points, then trigger off.
    func addSurvey(options: SurveyGrid.Options, cameraTriggerDistance: Float) -> Int {
        let points = SurveyGrid.generate(polygon: surveyPolygon, options: options)
        guard !points.isEmpty else { return 0 }
        // BUG-010: a huge area with tight spacing made > 65 535 points and trapped; refuse with a message.
        guard mission.count + points.count + 2 <= WaypointFile.maxItems else {
            banner = "Survey too large (\(points.count) points): increase the line spacing or shrink the area."
            return 0
        }
        ensureHome(fallback: points.first)
        var list = mission
        if cameraTriggerDistance > 0 {
            list.append(MissionItem(command: MissionCmd.doSetCamTriggDist, param1: cameraTriggerDistance))
        }
        for p in points {
            list.append(MissionItem(frame: defaultFrame, command: MissionCmd.waypoint, latitude: p.latitude,
                                    longitude: p.longitude, altitude: options.altitude))
        }
        if cameraTriggerDistance > 0 {
            list.append(MissionItem(command: MissionCmd.doSetCamTriggDist, param1: 0))
        }
        setItems(.mission, list)
        return points.count
    }

    /// Mission Planner Auto WP > Circle. Either `points` waypoints per turn around `center`
    /// (starting due north of it), or one LOITER_TURNS item at the centre (the real ArduPilot orbit:
    /// param1 = turns, param3 = radius, negative = counter-clockwise). Returns the items added.
    func addCircle(center: GeoPoint, radius: Double, points: Int, altitude: Float, clockwise: Bool,
                   turns: Int, asLoiterTurns: Bool) -> Int {
        guard radius > 0, turns >= 1 else { return 0 }
        ensureHome(fallback: center)
        var list = mission
        if asLoiterTurns {
            list.append(MissionItem(frame: defaultFrame, command: MissionCmd.loiterTurns, param1: Float(turns),
                                    param3: clockwise ? Float(radius) : -Float(radius),
                                    latitude: center.latitude, longitude: center.longitude, altitude: altitude))
            setItems(.mission, list)
            return 1
        }
        let n = max(3, points)
        var added = 0
        for step in 0..<(n * turns) {
            let frac = Double(step) / Double(n) * 2 * Double.pi
            let theta = clockwise ? frac : -frac        // bearing from north, clockwise positive
            let p = Geo.fromLocal(x: radius * sin(theta), y: radius * cos(theta), origin: center)
            list.append(MissionItem(frame: defaultFrame, command: MissionCmd.waypoint, latitude: p.latitude,
                                    longitude: p.longitude, altitude: altitude))
            added += 1
        }
        setItems(.mission, list)
        return added
    }

    /// ArduPilot fence polygons: param1 of every vertex = vertex count of its polygon
    /// (consecutive vertices of the same kind form one polygon).
    static func numberFenceGroups(_ items: [MissionItem]) -> [MissionItem] {
        var out = items
        var i = 0
        while i < out.count {
            let cmd = out[i].command
            guard cmd == MissionCmd.fencePolygonInclusion || cmd == MissionCmd.fencePolygonExclusion else {
                i += 1
                continue
            }
            var j = i
            while j < out.count && out[j].command == cmd { j += 1 }
            for k in i..<j { out[k].param1 = Float(j - i) }
            i = j
        }
        return out
    }

    // MARK: stats

    /// Path length of the located mission items (home excluded), metres.
    var missionDistance: Double {
        let pts = mission.dropFirst().filter(\.hasLocation).map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        guard pts.count > 1 else { return 0 }
        return zip(pts, pts.dropFirst()).reduce(0) { $0 + Geo.distance($1.0, $1.1) }
    }

    // MARK: files

    var directory: URL { DocumentsStore.shared.missions }

    func save(name: String? = nil) throws -> URL {
        ensureHome()
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let url = directory.appendingPathComponent((name ?? "mission \(f.string(from: Date()))") + ".waypoints")
        try WaypointFile.format(mission).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func load(_ url: URL) throws {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url)
        let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
        setItems(.mission, try WaypointFile.parse(text))
        banner = "Loaded \(max(0, mission.count - 1)) waypoints from \(url.lastPathComponent)"
    }

    func savedFiles() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil,
                                                                  options: [.skipsHiddenFiles])) ?? []
        return urls.filter { ["waypoints", "txt", "mission"].contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
}
