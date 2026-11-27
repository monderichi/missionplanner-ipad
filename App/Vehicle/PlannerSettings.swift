// REA Parity Source: MissionPlanner GCSViews/ConfigurationView/ConfigPlanner.cs
// (distance / speed / altitude units, speech on/off, keep the screen awake).

import Foundation
import UIKit

final class PlannerSettings: ObservableObject {
    static let shared = PlannerSettings()

    enum DistanceUnit: String, CaseIterable, Identifiable {
        case metric = "Metric (m, km)"
        case imperial = "Imperial (ft, mi)"
        var id: String { rawValue }
    }

    enum SpeedUnit: String, CaseIterable, Identifiable {
        case mps = "m/s"
        case kmh = "km/h"
        case mph = "mph"
        case knots = "knots"
        var id: String { rawValue }
    }

    enum AltitudeUnit: String, CaseIterable, Identifiable {
        case metres = "Metres"
        case feet = "Feet"
        var id: String { rawValue }
    }

    private let defaults = UserDefaults.standard

    @Published var distanceUnit: DistanceUnit {
        didSet { defaults.set(distanceUnit.rawValue, forKey: "planner.distanceUnit") }
    }
    @Published var speedUnit: SpeedUnit {
        didSet { defaults.set(speedUnit.rawValue, forKey: "planner.speedUnit") }
    }
    @Published var altitudeUnit: AltitudeUnit {
        didSet { defaults.set(altitudeUnit.rawValue, forKey: "planner.altitudeUnit") }
    }
    /// Same key as SpeechAlerts.enabled.
    @Published var speechEnabled: Bool {
        didSet { defaults.set(speechEnabled, forKey: "speech.enabled") }
    }
    @Published var keepScreenAwake: Bool {
        didSet {
            defaults.set(keepScreenAwake, forKey: "planner.keepAwake")
            applyIdleTimer()
        }
    }

    /// Set by the UI when a vehicle is attached; the idle timer is only disabled while connected.
    private(set) var connected = false

    private init() {
        let d = UserDefaults.standard
        distanceUnit = DistanceUnit(rawValue: d.string(forKey: "planner.distanceUnit") ?? "") ?? .metric
        speedUnit = SpeedUnit(rawValue: d.string(forKey: "planner.speedUnit") ?? "") ?? .mps
        altitudeUnit = AltitudeUnit(rawValue: d.string(forKey: "planner.altitudeUnit") ?? "") ?? .metres
        speechEnabled = d.object(forKey: "speech.enabled") as? Bool ?? true
        keepScreenAwake = d.object(forKey: "planner.keepAwake") as? Bool ?? false
    }

    func setConnected(_ value: Bool) {
        connected = value
        applyIdleTimer()
    }

    private func applyIdleTimer() {
        let on = keepScreenAwake && connected
        DispatchQueue.main.async { UIApplication.shared.isIdleTimerDisabled = on }
    }

    // MARK: formatting helpers

    func distance(_ metres: Double) -> String {
        switch distanceUnit {
        case .metric:
            return abs(metres) >= 1000 ? String(format: "%.2f km", metres / 1000) : String(format: "%.0f m", metres)
        case .imperial:
            let feet = metres * 3.280839895
            return abs(feet) >= 5280 ? String(format: "%.2f mi", feet / 5280) : String(format: "%.0f ft", feet)
        }
    }

    func speed(_ mps: Double) -> String {
        switch speedUnit {
        case .mps: return String(format: "%.1f m/s", mps)
        case .kmh: return String(format: "%.0f km/h", mps * 3.6)
        case .mph: return String(format: "%.0f mph", mps * 2.236936292)
        case .knots: return String(format: "%.0f kt", mps * 1.943844492)
        }
    }

    func altitude(_ m: Double) -> String {
        switch altitudeUnit {
        case .metres: return String(format: "%.0f m", m)
        case .feet: return String(format: "%.0f ft", m * 3.280839895)
        }
    }
}
