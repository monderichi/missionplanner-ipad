// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/CurrentState.cs (UpdateCurrentSettings:
// how each telemetry message maps to cs.roll/pitch/yaw, groundspeed, alt, battery_voltage,
// gpsstatus, satcount, gpshdop, ekfstatus, vibex/y/z, messages ...) and MAVState.cs.
//
// Phase 2 scope: a single vehicle (the first autopilot that sends a heartbeat). The full
// MAVList multi-vehicle multiplexer and parameter engine arrive in Phase 3.

import Foundation
import MAVLinkKit

struct StatusMessage: Identifiable {
    let id = UUID()
    let date: Date
    let severity: MAVSeverity
    let text: String
}

final class VehicleModel: ObservableObject {
    // identity (from HEARTBEAT)
    @Published private(set) var systemID: UInt8?
    @Published private(set) var componentID: UInt8 = 1
    @Published private(set) var vehicleType: UInt8 = 0
    @Published private(set) var autopilot: UInt8 = 0
    @Published private(set) var armed = false
    @Published private(set) var customMode: UInt32 = 0
    @Published private(set) var systemStatus: UInt8 = 0
    @Published private(set) var lastHeartbeat: Date?
    /// True while heartbeats arrive (Mission Planner flags the link lost after a few seconds of silence).
    @Published private(set) var heartbeatAlive = false

    // attitude (ATTITUDE), degrees
    @Published private(set) var roll = 0.0
    @Published private(set) var pitch = 0.0
    @Published private(set) var yaw = 0.0

    // VFR_HUD
    @Published private(set) var airspeed = 0.0
    @Published private(set) var groundspeed = 0.0
    @Published private(set) var heading = 0.0
    @Published private(set) var throttle = 0
    @Published private(set) var altitudeMSL = 0.0
    @Published private(set) var climbRate = 0.0

    // GLOBAL_POSITION_INT
    @Published private(set) var latitude: Double?
    @Published private(set) var longitude: Double?
    @Published private(set) var relativeAltitude = 0.0

    // GPS_RAW_INT
    @Published private(set) var gpsFixType: UInt8 = 0
    @Published private(set) var satellites: UInt8 = 0
    @Published private(set) var hdop = 0.0

    // SYS_STATUS
    @Published private(set) var batteryVoltage = 0.0
    @Published private(set) var batteryCurrent = 0.0
    @Published private(set) var batteryRemaining = -1

    // NAV_CONTROLLER_OUTPUT
    @Published private(set) var waypointDistance = 0.0
    @Published private(set) var currentWaypoint = 0

    // EKF_STATUS_REPORT / VIBRATION
    @Published private(set) var ekfFlags: UInt16 = 0
    @Published private(set) var ekfVariances: [Double] = [0, 0, 0, 0, 0] // vel, posH, posV, compass, terrain
    @Published private(set) var vibration: [Double] = [0, 0, 0]
    @Published private(set) var clipping: [UInt32] = [0, 0, 0]

    // RADIO_STATUS
    @Published private(set) var radioRSSI: Int?
    @Published private(set) var radioRemoteRSSI: Int?

    @Published private(set) var messages: [StatusMessage] = []
    @Published private(set) var messageCounts: [String: Int] = [:]

    private var statusChunks: [UInt16: String] = [:]
    static let heartbeatTimeout: TimeInterval = 5
    static let maxMessages = 300

    var modeName: String {
        systemID == nil ? "—" : ArduPilotModes.name(customMode: customMode, vehicleType: vehicleType)
    }

    var vehicleTypeName: String {
        guard let t = MAVType(rawValue: vehicleType) else { return "Type \(vehicleType)" }
        switch t.firmware {
        case .copter: return "ArduCopter"
        case .plane: return "ArduPlane"
        case .rover: return "ArduRover"
        case .sub: return "ArduSub"
        case .tracker: return "AntennaTracker"
        case .other: return "\(t)"
        }
    }

    var gpsFixName: String {
        switch gpsFixType {
        case 0: return "No GPS"
        case 1: return "No Fix"
        case 2: return "2D Fix"
        case 3: return "3D Fix"
        case 4: return "3D DGPS"
        case 5: return "RTK Float"
        case 6: return "RTK Fixed"
        case 7: return "Static"
        case 8: return "PPP"
        default: return "Fix \(gpsFixType)"
        }
    }

    func reset() {
        systemID = nil
        heartbeatAlive = false
        lastHeartbeat = nil
        latitude = nil
        longitude = nil
        messageCounts = [:]
        statusChunks = [:]
    }

    /// Called ~1 Hz by the link manager.
    func tick(now: Date = Date()) {
        let alive = lastHeartbeat.map { now.timeIntervalSince($0) < Self.heartbeatTimeout } ?? false
        if alive != heartbeatAlive { heartbeatAlive = alive }
    }

    /// Returns true when this heartbeat is the first from a (new) vehicle, so the link
    /// manager can request data streams.
    @discardableResult
    func handle(_ packet: MAVLinkPacket) -> Bool {
        messageCounts[packet.name, default: 0] += 1
        var newVehicle = false

        if packet.messageID == MAV.Heartbeat.mavInfo.id, let hb = packet.decode(MAV.Heartbeat.self) {
            // Ignore other GCSs, gimbals, cameras... (MAVList keys vehicles by sysid/compid).
            guard hb.type != MAVType.gcs.rawValue, hb.autopilot != MAVAutopilot.invalid else { return false }
            if systemID == nil || !heartbeatAlive {
                newVehicle = systemID != packet.systemID || !heartbeatAlive
                systemID = packet.systemID
                componentID = packet.componentID
            }
            guard packet.systemID == systemID, packet.componentID == componentID else { return false }
            vehicleType = hb.type
            autopilot = hb.autopilot
            armed = (hb.baseMode & MAVModeFlag.safetyArmed) != 0
            customMode = hb.customMode
            systemStatus = hb.systemStatus
            lastHeartbeat = Date()
            if !heartbeatAlive { heartbeatAlive = true }
            return newVehicle
        }

        // STATUSTEXT from any component of our vehicle (or anyone before we lock on).
        if packet.messageID == MAV.Statustext.mavInfo.id, let st = packet.decode(MAV.Statustext.self) {
            if systemID == nil || packet.systemID == systemID { addStatusText(st) }
            return false
        }

        guard packet.systemID == systemID, packet.componentID == componentID else { return false }

        switch packet.messageID {
        case MAV.Attitude.mavInfo.id:
            guard let m = packet.decode(MAV.Attitude.self) else { break }
            roll = Double(m.roll) * 180 / .pi
            pitch = Double(m.pitch) * 180 / .pi
            yaw = Self.wrap360(Double(m.yaw) * 180 / .pi)

        case MAV.VfrHud.mavInfo.id:
            guard let m = packet.decode(MAV.VfrHud.self) else { break }
            airspeed = Double(m.airspeed)
            groundspeed = Double(m.groundspeed)
            heading = Double(m.heading)
            throttle = Int(m.throttle)
            altitudeMSL = Double(m.alt)
            climbRate = Double(m.climb)

        case MAV.GlobalPositionInt.mavInfo.id:
            guard let m = packet.decode(MAV.GlobalPositionInt.self) else { break }
            if m.lat != 0 || m.lon != 0 {
                latitude = Double(m.lat) / 1e7
                longitude = Double(m.lon) / 1e7
            }
            relativeAltitude = Double(m.relativeAlt) / 1000

        case MAV.GpsRawInt.mavInfo.id:
            guard let m = packet.decode(MAV.GpsRawInt.self) else { break }
            gpsFixType = m.fixType
            satellites = m.satellitesVisible == 255 ? 0 : m.satellitesVisible
            hdop = m.eph == UInt16.max ? 99.99 : Double(m.eph) / 100

        case MAV.SysStatus.mavInfo.id:
            guard let m = packet.decode(MAV.SysStatus.self) else { break }
            batteryVoltage = m.voltageBattery == UInt16.max ? 0 : Double(m.voltageBattery) / 1000
            batteryCurrent = m.currentBattery < 0 ? 0 : Double(m.currentBattery) / 100
            batteryRemaining = Int(m.batteryRemaining)

        case MAV.NavControllerOutput.mavInfo.id:
            guard let m = packet.decode(MAV.NavControllerOutput.self) else { break }
            waypointDistance = Double(m.wpDist)

        case MAV.MissionCurrent.mavInfo.id:
            guard let m = packet.decode(MAV.MissionCurrent.self) else { break }
            currentWaypoint = Int(m.seq)

        case MAV.EkfStatusReport.mavInfo.id:
            guard let m = packet.decode(MAV.EkfStatusReport.self) else { break }
            ekfFlags = m.flags
            ekfVariances = [m.velocityVariance, m.posHorizVariance, m.posVertVariance,
                            m.compassVariance, m.terrainAltVariance].map { Double($0) }

        case MAV.Vibration.mavInfo.id:
            guard let m = packet.decode(MAV.Vibration.self) else { break }
            vibration = [Double(m.vibrationX), Double(m.vibrationY), Double(m.vibrationZ)]
            clipping = [m.clipping0, m.clipping1, m.clipping2]

        default:
            break
        }
        return false
    }

    /// RADIO_STATUS comes from the radio (its own sysid/compid), so it's handled for any source.
    func handleRadio(_ packet: MAVLinkPacket) {
        guard let m = packet.decode(MAV.RadioStatus.self) else { return }
        radioRSSI = Int(m.rssi)
        radioRemoteRSSI = Int(m.remrssi)
    }

    private func addStatusText(_ st: MAV.Statustext) {
        var text = MAVString.decode(st.text)
        // MAVLink 2 chunked STATUSTEXT: id != 0, chunk_seq counts up, last chunk has a NUL.
        if st.id != 0 {
            let part = text
            text = (statusChunks[st.id] ?? "") + part
            if !st.text.contains(0) && st.chunkSeq < 20 {
                statusChunks[st.id] = text
                return
            }
            statusChunks[st.id] = nil
        }
        let sev = MAVSeverity(rawValue: st.severity) ?? .info
        messages.insert(StatusMessage(date: Date(), severity: sev, text: text), at: 0)
        if messages.count > Self.maxMessages { messages.removeLast(messages.count - Self.maxMessages) }
    }

    static func wrap360(_ deg: Double) -> Double {
        let d = deg.truncatingRemainder(dividingBy: 360)
        return d < 0 ? d + 360 : d
    }
}
