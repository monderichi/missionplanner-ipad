// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/CurrentState.cs (the fast-changing cs.* fields:
// roll/pitch/yaw, groundspeed, alt, lat/lng, rc channels, servo outputs, vibration, ESC telemetry).
//
// BUG-037 (round 3): the high-rate fields live in their own ObservableObject. VehicleModel used to publish
// them together with the low-rate state, so every 10 Hz batch invalidated every view that observed the
// vehicle (Data tabs, map, setup pages). Now only views that display these fields observe FastTelemetry;
// the rest observe VehicleModel, which publishes only when a low-rate value really changes.

import Foundation
import MAVLinkKit

final class FastTelemetry: ObservableObject {
    // attitude (ATTITUDE), degrees
    /// Written only by VehicleModel.
    @Published var roll = 0.0
    /// Written only by VehicleModel.
    @Published var pitch = 0.0
    /// Written only by VehicleModel.
    @Published var yaw = 0.0

    // VFR_HUD (written only by VehicleModel)
    @Published var airspeed = 0.0
    @Published var groundspeed = 0.0
    @Published var heading = 0.0
    @Published var throttle = 0
    @Published var altitudeMSL = 0.0
    @Published var climbRate = 0.0

    // GLOBAL_POSITION_INT (written only by VehicleModel)
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var relativeAltitude = 0.0

    /// Flight path (appended when the vehicle moved more than ~1 m), newest last. Written only by VehicleModel.
    @Published var trail: [GeoPoint] = []

    // RC_CHANNELS / SERVO_OUTPUT_RAW (PWM, index 0 = channel 1). Written only by VehicleModel.
    @Published var rcChannels: [UInt16] = Array(repeating: 0, count: 18)
    @Published var rcChannelCount = 0
    @Published var servoOutputs: [UInt16] = Array(repeating: 0, count: 16)

    // VIBRATION. Written only by VehicleModel.
    @Published var vibration: [Double] = [0, 0, 0]
    @Published var clipping: [UInt32] = [0, 0, 0]

    // ESC_TELEMETRY_1_TO_4 / 5_TO_8, index 0 = motor 1. Written only by VehicleModel.
    @Published var escs: [VehicleModel.ESCInfo] = Array(repeating: VehicleModel.ESCInfo(), count: 8)
    @Published var escCount = 0

    var position: GeoPoint? {
        guard let la = latitude, let lo = longitude else { return nil }
        return GeoPoint(latitude: la, longitude: lo)
    }
}
