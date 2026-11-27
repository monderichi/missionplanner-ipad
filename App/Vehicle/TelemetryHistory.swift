// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Tuning" live graph (selectable CurrentState fields).
// Samples chosen VehicleModel values at 5 Hz into 120 s ring buffers; also the value catalogue for Quick tiles.

import Foundation

struct TelemetrySeriesDef: Identifiable {
    let id: String
    let label: String
    let unit: String
    let value: (VehicleModel) -> Double
}

enum TelemetryCatalogue {
    static func pwm(_ a: [UInt16], _ i: Int) -> Double { i < a.count ? Double(a[i]) : 0 }
    static func rpm(_ v: VehicleModel, _ i: Int) -> Double { i < v.escs.count ? Double(v.escs[i].rpm) : 0 }
    static func vib(_ v: VehicleModel, _ i: Int) -> Double { i < v.vibration.count ? v.vibration[i] : 0 }

    static let all: [TelemetrySeriesDef] = [
        TelemetrySeriesDef(id: "roll", label: "Roll", unit: "deg", value: { $0.roll }),
        TelemetrySeriesDef(id: "pitch", label: "Pitch", unit: "deg", value: { $0.pitch }),
        TelemetrySeriesDef(id: "yaw", label: "Yaw", unit: "deg", value: { $0.yaw }),
        TelemetrySeriesDef(id: "alt", label: "Altitude", unit: "m", value: { $0.relativeAltitude }),
        TelemetrySeriesDef(id: "climb", label: "Vertical speed", unit: "m/s", value: { $0.climbRate }),
        TelemetrySeriesDef(id: "gs", label: "Ground speed", unit: "m/s", value: { $0.groundspeed }),
        TelemetrySeriesDef(id: "as", label: "Airspeed", unit: "m/s", value: { $0.airspeed }),
        TelemetrySeriesDef(id: "thr", label: "Throttle", unit: "%", value: { Double($0.throttle) }),
        TelemetrySeriesDef(id: "batv", label: "Battery", unit: "V", value: { $0.batteryVoltage }),
        TelemetrySeriesDef(id: "bati", label: "Battery current", unit: "A", value: { $0.batteryCurrent }),
        TelemetrySeriesDef(id: "vibx", label: "Vibration X", unit: "m/s/s", value: { TelemetryCatalogue.vib($0, 0) }),
        TelemetrySeriesDef(id: "viby", label: "Vibration Y", unit: "m/s/s", value: { TelemetryCatalogue.vib($0, 1) }),
        TelemetrySeriesDef(id: "vibz", label: "Vibration Z", unit: "m/s/s", value: { TelemetryCatalogue.vib($0, 2) }),
        TelemetrySeriesDef(id: "sats", label: "Satellites", unit: "", value: { Double($0.satellites) }),
        TelemetrySeriesDef(id: "hdop", label: "HDOP", unit: "", value: { $0.hdop }),
        TelemetrySeriesDef(id: "rc1", label: "RC1", unit: "us", value: { TelemetryCatalogue.pwm($0.rcChannels, 0) }),
        TelemetrySeriesDef(id: "rc2", label: "RC2", unit: "us", value: { TelemetryCatalogue.pwm($0.rcChannels, 1) }),
        TelemetrySeriesDef(id: "rc3", label: "RC3", unit: "us", value: { TelemetryCatalogue.pwm($0.rcChannels, 2) }),
        TelemetrySeriesDef(id: "rc4", label: "RC4", unit: "us", value: { TelemetryCatalogue.pwm($0.rcChannels, 3) }),
        TelemetrySeriesDef(id: "sv1", label: "Servo1", unit: "us", value: { TelemetryCatalogue.pwm($0.servoOutputs, 0) }),
        TelemetrySeriesDef(id: "sv2", label: "Servo2", unit: "us", value: { TelemetryCatalogue.pwm($0.servoOutputs, 1) }),
        TelemetrySeriesDef(id: "sv3", label: "Servo3", unit: "us", value: { TelemetryCatalogue.pwm($0.servoOutputs, 2) }),
        TelemetrySeriesDef(id: "sv4", label: "Servo4", unit: "us", value: { TelemetryCatalogue.pwm($0.servoOutputs, 3) }),
        TelemetrySeriesDef(id: "esc1", label: "ESC1 rpm", unit: "rpm", value: { TelemetryCatalogue.rpm($0, 0) }),
        TelemetrySeriesDef(id: "esc2", label: "ESC2 rpm", unit: "rpm", value: { TelemetryCatalogue.rpm($0, 1) }),
        TelemetrySeriesDef(id: "esc3", label: "ESC3 rpm", unit: "rpm", value: { TelemetryCatalogue.rpm($0, 2) }),
        TelemetrySeriesDef(id: "esc4", label: "ESC4 rpm", unit: "rpm", value: { TelemetryCatalogue.rpm($0, 3) }),
    ]

    /// Extra id usable only by Quick tiles.
    static let waypointDistanceID = "wpdist"
    static let waypointDistance = TelemetrySeriesDef(id: "wpdist", label: "Dist to WP", unit: "m", value: { $0.waypointDistance })

    static func def(_ id: String) -> TelemetrySeriesDef? {
        if id == waypointDistanceID { return waypointDistance }
        return all.first { $0.id == id }
    }

    /// Everything a Quick tile can show.
    static var quickChoices: [TelemetrySeriesDef] { all + [waypointDistance] }
}

struct TelemetrySample: Identifiable {
    let id: Int
    let time: Date
    let value: Double
}

final class TelemetryHistory: ObservableObject {
    static let windowSeconds = 120.0
    static let maxSelected = 6
    private static let defaultsKey = "graph.series"

    @Published private(set) var selected: [String]
    @Published private(set) var revision = 0
    @Published var paused = false

    private var buffers: [String: [TelemetrySample]] = [:]
    private var nextID = 0
    private var timer: Timer?
    private weak var vehicle: VehicleModel?

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: TelemetryHistory.defaultsKey) ?? []
        let valid = saved.filter { TelemetryCatalogue.def($0) != nil && $0 != TelemetryCatalogue.waypointDistanceID }
        selected = valid.isEmpty ? ["roll", "pitch"] : Array(valid.prefix(TelemetryHistory.maxSelected))
    }

    func start(vehicle: VehicleModel) {
        self.vehicle = vehicle
        timer?.invalidate()
        let t = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in self?.sample() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func isSelected(_ id: String) -> Bool { selected.contains(id) }

    func toggle(_ id: String) {
        if let i = selected.firstIndex(of: id) {
            selected.remove(at: i)
            buffers[id] = nil
        } else if selected.count < TelemetryHistory.maxSelected {
            selected.append(id)
        }
        UserDefaults.standard.set(selected, forKey: TelemetryHistory.defaultsKey)
        revision += 1
    }

    func clear() {
        buffers = [:]
        revision += 1
    }

    func samples(for id: String) -> [TelemetrySample] { buffers[id] ?? [] }

    private func sample() {
        guard !paused, let vehicle else { return }
        let now = Date()
        let cutoff = now.addingTimeInterval(-TelemetryHistory.windowSeconds)
        for id in selected {
            guard let def = TelemetryCatalogue.def(id) else { continue }
            var buf = buffers[id] ?? []
            buf.append(TelemetrySample(id: nextID, time: now, value: def.value(vehicle)))
            nextID += 1
            if let first = buf.firstIndex(where: { $0.time >= cutoff }), first > 0 {
                buf.removeFirst(first)
            }
            buffers[id] = buf
        }
        revision += 1
    }
}
