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

    // ArduSub: SCALED_PRESSURE2 is the external (water) pressure/temperature sensor
    /// Water temperature in degC from SCALED_PRESSURE2 (nil until received).
    @Published private(set) var waterTemperature: Double?
    /// Set when a STATUSTEXT mentions a leak (ArduSub "Leak Detected"); cleared by a "cleared" text or reset.
    @Published private(set) var leakDetected = false

    @Published private(set) var messages: [StatusMessage] = []
    /// BUG-037 (round 2): not @Published: it changes on every packet. Views that show it re-read it whenever the batch
    /// publishes anything else (attitude, heartbeat), at most 10 times a second.
    private(set) var messageCounts: [String: Int] = [:]

    // HOME_POSITION
    @Published private(set) var homeLatitude: Double?
    @Published private(set) var homeLongitude: Double?
    @Published private(set) var homeAltitudeMSL = 0.0

    /// Flight path (appended when the vehicle moved more than ~1 m), newest last.
    @Published private(set) var trail: [GeoPoint] = []
    static let maxTrail = 3000

    // RC_CHANNELS / SERVO_OUTPUT_RAW (PWM, index 0 = channel 1)
    @Published private(set) var rcChannels: [UInt16] = Array(repeating: 0, count: 18)
    @Published private(set) var rcChannelCount = 0
    @Published private(set) var servoOutputs: [UInt16] = Array(repeating: 0, count: 16)

    // SYS_STATUS sensor bitmasks (MAV_SYS_STATUS_SENSOR)
    @Published private(set) var sensorsPresent: UInt32 = 0
    @Published private(set) var sensorsEnabled: UInt32 = 0
    @Published private(set) var sensorsHealthy: UInt32 = 0

    // MAG_CAL_PROGRESS / MAG_CAL_REPORT, keyed by compass id
    @Published private(set) var magCalProgress: [UInt8: UInt8] = [:]
    @Published private(set) var magCalReports: [UInt8: MAV.MagCalReport] = [:]

    @Published private(set) var lastReachedWaypoint: Int?

    /// Every HEARTBEAT source seen on the link ("sys/comp" -> "TYPE, autopilot N"), for Diagnostics.
    @Published private(set) var heartbeatSources: [String: String] = [:]

    // ESC_TELEMETRY_1_TO_4 / 5_TO_8 (DShot / BLHeli telemetry), index 0 = motor 1
    struct ESCInfo: Equatable {
        var rpm: Int = 0
        var temperature: Int = 0     // °C
        var voltage: Double = 0      // V
        var current: Double = 0      // A
    }
    @Published private(set) var escs: [ESCInfo] = Array(repeating: ESCInfo(), count: 8)
    @Published private(set) var escCount = 0

    // BATTERY_STATUS (first battery)
    @Published private(set) var batteryConsumedMah: Int?
    @Published private(set) var cellVoltages: [Double] = []

    // ADSB_VEHICLE (from the FC's ADS-B receiver or any other component), keyed by ICAO address
    struct Traffic: Equatable {
        var callsign: String
        var position: GeoPoint
        var altitude: Double    // m (ADSB altitude is mm)
        var heading: Double     // deg
        var speed: Double       // m/s
        var lastSeen: Date
    }
    @Published private(set) var traffic: [UInt32: Traffic] = [:]
    static let trafficTimeout: TimeInterval = 60
    static let maxTraffic = 300 // BUG-039

    /// BUG-015: when the last valid GLOBAL_POSITION_INT arrived; the map greys the vehicle when it is old.
    private var lastPosition: Date?
    /// BUG-015: no valid position for 3 s (GPS lost, link quiet) while one was known.
    @Published private(set) var positionStale = false
    /// BUG-008: warning banner text (nil = none) and whether it is critical (red).
    @Published private(set) var warning: String?
    @Published private(set) var warningCritical = false
    private var lastAlert: (text: String, date: Date)?

    /// BUG-003: radians that a real attitude can have (non-finite and absurd values are dropped).
    static func plausibleAngle(_ v: Float) -> Bool { v.isFinite && abs(v) <= 4 * .pi }
    static func plausible(_ v: Float, _ limit: Float) -> Bool { v.isFinite && abs(v) <= limit }

    private var statusChunks: [UInt16: String] = [:]
    static let heartbeatTimeout: TimeInterval = 5
    static let attitudeTimeout: TimeInterval = 3
    private var lastAttitude: Date?
    /// Heartbeats arrive but no ATTITUDE for a few seconds: the HUD would be frozen.
    @Published private(set) var attitudeStale = false
    static let maxMessages = 300

    /// True when the heartbeat says the vehicle is a submarine (ArduSub).
    var isSub: Bool { MAVType(rawValue: vehicleType)?.firmware == .sub }

    /// Depth in metres, positive down. ArduSub reports altitude relative to the surface (negative below).
    var depth: Double { isSub ? -relativeAltitude : 0 }

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
        homeLatitude = nil
        homeLongitude = nil
        trail = []
        rcChannelCount = 0
        magCalProgress = [:]
        magCalReports = [:]
        lastReachedWaypoint = nil
        lastAttitude = nil
        attitudeStale = false
        heartbeatSources = [:]
        traffic = [:]
        // BUG-012: clear the live state too, so nothing (ARMED, mode, attitude, battery) looks live after Disconnect.
        armed = false
        customMode = 0
        roll = 0; pitch = 0; yaw = 0
        groundspeed = 0; airspeed = 0; climbRate = 0; relativeAltitude = 0
        batteryVoltage = 0; batteryCurrent = 0; batteryRemaining = -1
        gpsFixType = 0; satellites = 0
        lastPosition = nil; positionStale = false
        warning = nil; warningCritical = false; lastAlert = nil
        leakDetected = false
        waterTemperature = nil
    }

    func clearTrail() { trail = [] }

    func clearLeak() { leakDetected = false }

    private func updateESCs(base: Int, rpm: [UInt16], temp: [UInt8], volt: [UInt16], curr: [UInt16]) {
        var list = escs
        for i in 0..<4 {
            list[base + i] = ESCInfo(rpm: Int(rpm[i]), temperature: Int(temp[i]),
                                     voltage: Double(volt[i]) / 100, current: Double(curr[i]) / 100)
        }
        escs = list
        escCount = max(escCount, base + 4)
    }

    func resetMagCal() {
        magCalProgress = [:]
        magCalReports = [:]
    }

    var home: GeoPoint? {
        guard let la = homeLatitude, let lo = homeLongitude else { return nil }
        return GeoPoint(latitude: la, longitude: lo)
    }

    var position: GeoPoint? {
        guard let la = latitude, let lo = longitude else { return nil }
        return GeoPoint(latitude: la, longitude: lo)
    }

    /// Feed packets from a .tlog replay (same handling as live, no sysid lock-in surprises).
    func replay(_ packet: MAVLinkPacket) {
        _ = handle(packet)
        if packet.messageID == MAV.RadioStatus.mavInfo.id { handleRadio(packet) }
    }

    /// Called ~1 Hz by the link manager.
    func tick(now: Date = Date()) {
        let alive = lastHeartbeat.map { now.timeIntervalSince($0) < Self.heartbeatTimeout } ?? false
        if alive != heartbeatAlive { heartbeatAlive = alive }
        let stale = alive && (lastAttitude.map { now.timeIntervalSince($0) > Self.attitudeTimeout } ?? true)
        if stale != attitudeStale { attitudeStale = stale }
        // BUG-015: a known position that hasn't been refreshed for 3 s (or GPS fix lost) is shown as stale.
        let posStale = position != nil && (gpsFixType < 2 || (lastPosition.map { now.timeIntervalSince($0) > 3 } ?? true))
        if posStale != positionStale { positionStale = posStale }
        updateWarning(now: now)
        if !traffic.isEmpty {
            let fresh = traffic.filter { now.timeIntervalSince($0.value.lastSeen) < Self.trafficTimeout }
            if fresh.count != traffic.count { traffic = fresh }
        }
    }

    /// Heartbeat from a flight controller (not a GCS, gimbal, camera, OSD, radio...).
    static func isVehicleAutopilot(_ hb: MAV.Heartbeat) -> Bool {
        guard hb.type != MAVType.gcs.rawValue, hb.autopilot != MAVAutopilot.invalid else { return false }
        guard let t = MAVType(rawValue: hb.type) else { return false }
        return t.firmware != .other
    }

    /// Returns true when this heartbeat is the first from a (new) vehicle, so the link
    /// manager can request data streams.
    @discardableResult
    func handle(_ packet: MAVLinkPacket) -> Bool {
        messageCounts[packet.name, default: 0] += 1
        var newVehicle = false

        if packet.messageID == MAV.Heartbeat.mavInfo.id, let hb = packet.decode(MAV.Heartbeat.self) {
            // Only a real vehicle's autopilot drives the HUD. ArduPilot forwards heartbeats from
            // gimbals, OSDs, companions etc. on other serial ports (often autopilot=GENERIC), and
            // locking onto one of those froze the HUD. MAVList keys vehicles by sysid/compid and the
            // flight controller is component 1 (MAV_COMP_ID_AUTOPILOT1).
            let src = "\(packet.systemID)/\(packet.componentID)"
            let desc = "\(MAVType(rawValue: hb.type).map { "\($0)" } ?? "type \(hb.type)"), autopilot \(hb.autopilot)"
            if heartbeatSources[src] != desc { heartbeatSources[src] = desc }
            guard Self.isVehicleAutopilot(hb) else { return false }
            let preferThis = packet.componentID == 1 && packet.systemID == systemID && componentID != 1
            if systemID == nil || !heartbeatAlive || preferThis {
                newVehicle = systemID != packet.systemID || componentID != packet.componentID || !heartbeatAlive
                systemID = packet.systemID
                componentID = packet.componentID
            }
            guard packet.systemID == systemID, packet.componentID == componentID else { return false }
            // review 2: mark the link alive first, so an arm/disarm that happened during a dropout is still announced
            lastHeartbeat = Date()
            if !heartbeatAlive { heartbeatAlive = true }
            vehicleType = hb.type
            autopilot = hb.autopilot
            armed = (hb.baseMode & MAVModeFlag.safetyArmed) != 0
            customMode = hb.customMode
            systemStatus = hb.systemStatus
            return newVehicle
        }

        // ADS-B traffic comes from any component (FC or an external receiver): before the sysid guard.
        if packet.messageID == MAV.AdsbVehicle.mavInfo.id {
            // BUG-039: valid positions only, and at most maxTraffic aircraft (a flood/malformed feed can't grow it).
            if let m = packet.decode(MAV.AdsbVehicle.self), m.lat != 0 || m.lon != 0,
               abs(Int(m.lat)) <= 900_000_000, abs(Int(m.lon)) <= 1_800_000_000,
               traffic[m.ICAOAddress] != nil || traffic.count < Self.maxTraffic {
                let name = MAVString.decode(m.callsign).trimmingCharacters(in: .whitespaces)
                traffic[m.ICAOAddress] = Traffic(
                    callsign: name.isEmpty ? String(format: "%06X", m.ICAOAddress) : name,
                    position: GeoPoint(latitude: Double(m.lat) / 1e7, longitude: Double(m.lon) / 1e7),
                    altitude: Double(m.altitude) / 1000,
                    heading: Double(m.heading) / 100,
                    speed: Double(m.horVelocity) / 100,
                    lastSeen: Date())
            }
            return false
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
            // BUG-003: ignore non-finite / impossible attitudes (they trapped the HUD); the watchdog then reports
            // NO ATTITUDE DATA instead of showing garbage.
            guard Self.plausibleAngle(m.roll), Self.plausibleAngle(m.pitch), Self.plausibleAngle(m.yaw) else { break }
            lastAttitude = Date()
            roll = Double(m.roll) * 180 / .pi
            pitch = Double(m.pitch) * 180 / .pi
            yaw = Self.wrap360(Double(m.yaw) * 180 / .pi)

        case MAV.VfrHud.mavInfo.id:
            guard let m = packet.decode(MAV.VfrHud.self) else { break }
            // BUG-003: keep the last good value for any non-finite / impossible field.
            if Self.plausible(m.airspeed, 1000) { airspeed = Double(m.airspeed) }
            if Self.plausible(m.groundspeed, 1000) { groundspeed = Double(m.groundspeed) }
            heading = Double(m.heading)
            throttle = Int(m.throttle)
            if Self.plausible(m.alt, 100_000) { altitudeMSL = Double(m.alt) }
            if Self.plausible(m.climb, 1000) { climbRate = Double(m.climb) }

        case MAV.GlobalPositionInt.mavInfo.id:
            guard let m = packet.decode(MAV.GlobalPositionInt.self) else { break }
            // BUG-004: positions outside ±90/±180 crashed the map (MKMapView setCenter throws); lat=lon=0 = no fix.
            if (m.lat != 0 || m.lon != 0) && abs(Int(m.lat)) <= 900_000_000 && abs(Int(m.lon)) <= 1_800_000_000 {
                let p = GeoPoint(latitude: Double(m.lat) / 1e7, longitude: Double(m.lon) / 1e7)
                lastPosition = Date() // BUG-015
                latitude = p.latitude
                longitude = p.longitude
                if let last = trail.last {
                    if Geo.distance(last, p) > 1 {
                        trail.append(p)
                        if trail.count > Self.maxTrail { trail.removeFirst(trail.count - Self.maxTrail) }
                    }
                } else {
                    trail.append(p)
                }
            }
            if abs(Int(m.relativeAlt)) <= 100_000_000 { relativeAltitude = Double(m.relativeAlt) / 1000 } // BUG-003: ±100 km

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
            sensorsPresent = m.onboardControlSensorsPresent
            sensorsEnabled = m.onboardControlSensorsEnabled
            sensorsHealthy = m.onboardControlSensorsHealth

        case MAV.ScaledPressure2.mavInfo.id:
            guard let m = packet.decode(MAV.ScaledPressure2.self) else { break }
            waterTemperature = Double(m.temperature) / 100

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

        case MAV.HomePosition.mavInfo.id:
            guard let m = packet.decode(MAV.HomePosition.self),
                  abs(Int(m.latitude)) <= 900_000_000, abs(Int(m.longitude)) <= 1_800_000_000 else { break } // BUG-004
            homeLatitude = Double(m.latitude) / 1e7
            homeLongitude = Double(m.longitude) / 1e7
            homeAltitudeMSL = Double(m.altitude) / 1000

        case MAV.RcChannels.mavInfo.id:
            guard let m = packet.decode(MAV.RcChannels.self) else { break }
            rcChannels = [m.chan1Raw, m.chan2Raw, m.chan3Raw, m.chan4Raw, m.chan5Raw, m.chan6Raw, m.chan7Raw, m.chan8Raw,
                          m.chan9Raw, m.chan10Raw, m.chan11Raw, m.chan12Raw, m.chan13Raw, m.chan14Raw, m.chan15Raw,
                          m.chan16Raw, m.chan17Raw, m.chan18Raw]
            rcChannelCount = Int(m.chancount)

        case MAV.ServoOutputRaw.mavInfo.id:
            guard let m = packet.decode(MAV.ServoOutputRaw.self), m.port == 0 else { break }
            servoOutputs = [m.servo1Raw, m.servo2Raw, m.servo3Raw, m.servo4Raw, m.servo5Raw, m.servo6Raw, m.servo7Raw,
                            m.servo8Raw, m.servo9Raw, m.servo10Raw, m.servo11Raw, m.servo12Raw, m.servo13Raw,
                            m.servo14Raw, m.servo15Raw, m.servo16Raw]

        case MAV.EscTelemetry1To4.mavInfo.id:
            guard let m = packet.decode(MAV.EscTelemetry1To4.self) else { break }
            updateESCs(base: 0, rpm: m.rpm, temp: m.temperature, volt: m.voltage, curr: m.current)

        case MAV.EscTelemetry5To8.mavInfo.id:
            guard let m = packet.decode(MAV.EscTelemetry5To8.self) else { break }
            updateESCs(base: 4, rpm: m.rpm, temp: m.temperature, volt: m.voltage, curr: m.current)

        case MAV.BatteryStatus.mavInfo.id:
            guard let m = packet.decode(MAV.BatteryStatus.self), m.id == 0 else { break }
            batteryConsumedMah = m.currentConsumed >= 0 ? Int(m.currentConsumed) : nil
            cellVoltages = (m.voltages + m.voltagesExt)
                .filter { $0 != UInt16.max && $0 != 0 && $0 != UInt16.max - 1 }
                .map { Double($0) / 1000 }

        case MAV.MissionItemReached.mavInfo.id:
            guard let m = packet.decode(MAV.MissionItemReached.self) else { break }
            lastReachedWaypoint = Int(m.seq)

        case MAV.MagCalProgress.mavInfo.id:
            guard let m = packet.decode(MAV.MagCalProgress.self) else { break }
            magCalProgress[m.compassId] = m.completionPct

        case MAV.MagCalReport.mavInfo.id:
            guard let m = packet.decode(MAV.MagCalReport.self) else { break }
            magCalReports[m.compassId] = m
            // BUG-028: only a successful report completes the bar; a failed compass keeps its last progress.
            if m.calStatus == 4 { magCalProgress[m.compassId] = 100 }

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

    /// BUG-008: one banner for the most important current problem: a recent failsafe/fence/EKF/battery STATUSTEXT
    /// (severity ≤ WARNING, kept 15 s), else a low (≤ 20 %) / critical (≤ 10 %) battery. Shown even with speech off.
    private func updateWarning(now: Date) {
        var text: String?, critical = false
        if let a = lastAlert, now.timeIntervalSince(a.date) < 15 {
            text = a.text.uppercased(); critical = true
        } else if systemID != nil, heartbeatAlive, batteryRemaining >= 0, batteryRemaining <= 20 {
            critical = batteryRemaining <= 10
            text = critical ? "BATTERY CRITICAL \(batteryRemaining)%" : "BATTERY LOW \(batteryRemaining)%"
        }
        if text != warning { warning = text }
        if critical != warningCritical { warningCritical = critical }
    }

    static let alertWords = ["failsafe", "fence", "ekf", "battery", "crash", "leak", "terrain", "vibration", "gps glitch"]

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
        let lower = text.lowercased()
        if lower.contains("leak") {
            let cleared = lower.contains("clear")
            if leakDetected == cleared { leakDetected = !cleared }
        }
        messages.insert(StatusMessage(date: Date(), severity: sev, text: text), at: 0)
        // BUG-008: safety-relevant warnings become the HUD banner, not just a line in the Messages tab.
        if sev.rawValue <= MAVSeverity.warning.rawValue {
            let lower = text.lowercased()
            if Self.alertWords.contains(where: { lower.contains($0) }) { lastAlert = (text, Date()); updateWarning(now: Date()) }
        }
        if messages.count > Self.maxMessages { messages.removeLast(messages.count - Self.maxMessages) }
    }

    static func wrap360(_ deg: Double) -> Double {
        let d = deg.truncatingRemainder(dividingBy: 360)
        return d < 0 ? d + 360 : d
    }
}
