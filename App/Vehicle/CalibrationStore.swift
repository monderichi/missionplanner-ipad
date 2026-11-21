// REA Parity Source: MissionPlanner GCSViews/ConfigurationView/ConfigAccelerometerCalibration.cs
// (MAV_CMD_PREFLIGHT_CALIBRATION param5=1 starts the 6-axis cal; the vehicle then sends
//  COMMAND_LONG MAV_CMD_ACCELCAL_VEHICLE_POS(42429) with the wanted position in param1 and the GCS
//  answers with the same command once the user placed the vehicle; 16777215 = success,
//  16777216 = failed), ConfigAccelerometerCalibration "Calibrate Level" (param5=2),
//  ConfigHWCompass2.cs onboard mag cal (MAV_CMD_DO_START_MAG_CAL 42424 / ACCEPT 42425 / CANCEL 42426,
//  MAG_CAL_PROGRESS / MAG_CAL_REPORT), ConfigMotorTest.cs (MAV_CMD_DO_MOTOR_TEST 209) and
//  the pre-arm check (MAV_CMD_RUN_PREARM_CHECKS 401).

import Foundation
import MAVLinkKit

enum AccelCalCmd {
    static let preflightCalibration: UInt16 = 241
    static let vehiclePos: UInt16 = 42429
    static let success: UInt32 = 16_777_215
    static let failed: UInt32 = 16_777_216
}

final class CalibrationStore: ObservableObject {
    enum AccelState: Equatable {
        case idle
        case starting
        case place(position: UInt32)
        case success
        case failed
    }

    @Published private(set) var accel: AccelState = .idle
    @Published private(set) var compassRunning = false

    weak var commands: CommandCenter?
    weak var vehicle: VehicleModel?

    static func positionName(_ p: UInt32) -> String {
        switch p {
        case 1: return "Level"
        case 2: return "On its LEFT side"
        case 3: return "On its RIGHT side"
        case 4: return "Nose DOWN"
        case 5: return "Nose UP"
        case 6: return "On its BACK (upside down)"
        default: return "Position \(p)"
        }
    }

    static func positionHelp(_ p: UInt32) -> String {
        switch p {
        case 1: return "Place the vehicle level on a flat surface."
        case 2: return "Roll the vehicle so its left side faces down."
        case 3: return "Roll the vehicle so its right side faces down."
        case 4: return "Point the nose straight down."
        case 5: return "Point the nose straight up."
        case 6: return "Turn the vehicle upside down."
        default: return ""
        }
    }

    // MARK: accelerometer

    func startAccel() {
        accel = .starting
        commands?.sendOnce(AccelCalCmd.preflightCalibration, params: [0, 0, 0, 0, 1, 0, 0], label: "Accelerometer calibration")
    }

    func confirmPosition() {
        guard case .place(let p) = accel else { return }
        commands?.sendOnce(AccelCalCmd.vehiclePos, params: [Float(p)], label: "\(Self.positionName(p)) done")
    }

    func calibrateLevel() {
        commands?.sendOnce(AccelCalCmd.preflightCalibration, params: [0, 0, 0, 0, 2, 0, 0], label: "Level calibration")
    }

    func resetAccel() { accel = .idle }

    /// COMMAND_LONG sent by the vehicle to the GCS.
    func handle(_ cmd: MAV.CommandLong) {
        guard cmd.command == AccelCalCmd.vehiclePos else { return }
        let p = UInt32(cmd.param1)
        switch p {
        case AccelCalCmd.success: accel = .success
        case AccelCalCmd.failed: accel = .failed
        default: accel = .place(position: p)
        }
    }

    // MARK: compass

    func startCompass() {
        vehicle?.resetMagCal()
        compassRunning = true
        // all compasses, retry on failure, autosave, no delay, no autoreboot
        commands?.command(42424, params: [0, 1, 1, 0, 0], label: "Compass calibration")
    }

    func acceptCompass() {
        commands?.command(42425, params: [0], label: "Accept compass calibration")
        compassRunning = false
    }

    func cancelCompass() {
        commands?.command(42426, params: [0], label: "Cancel compass calibration")
        compassRunning = false
    }

    static func magStatus(_ s: UInt8) -> String {
        switch s {
        case 0: return "Not started"
        case 1: return "Waiting to start"
        case 2: return "Step 1: rotate"
        case 3: return "Step 2: rotate"
        case 4: return "Success"
        case 5: return "Failed"
        case 6: return "Bad orientation"
        case 7: return "Bad radius"
        default: return "Status \(s)"
        }
    }

    // MARK: motor test / pre-arm

    /// motor: 1-based test-order index (A = 1). throttle in percent, duration seconds.
    func motorTest(motor: Int, throttle: Float, duration: Float, count: Int = 0) {
        let name = count > 1 ? "Motor test, all \(count) in sequence" : "Motor \(Self.motorLetter(motor)) test"
        commands?.command(209, params: [Float(motor), 0, throttle, duration, Float(count), 0], label: name)
    }

    static func motorLetter(_ motor: Int) -> String {
        let letters = Array("ABCDEFGHIJKL")
        return motor >= 1 && motor <= letters.count ? String(letters[motor - 1]) : "\(motor)"
    }

    func runPrearmChecks() {
        commands?.command(401, params: [], label: "Pre-arm check")
    }
}

/// MAV_SYS_STATUS_SENSOR bit names (SYS_STATUS onboard_control_sensors_*).
enum SensorBits {
    static let names: [(bit: Int, name: String)] = [
        (0, "Gyro"), (1, "Accelerometer"), (2, "Compass"), (3, "Barometer"), (4, "Airspeed"), (5, "GPS"),
        (6, "Optical flow"), (7, "Vision position"), (8, "Laser position"), (10, "Rate control"),
        (11, "Attitude stabilisation"), (12, "Yaw position"), (13, "Altitude control"), (14, "XY position control"),
        (15, "Motor outputs"), (16, "RC receiver"), (17, "Gyro 2"), (18, "Accelerometer 2"), (19, "Compass 2"),
        (20, "Geofence"), (21, "AHRS"), (22, "Terrain"), (23, "Reverse motor"), (24, "Logging"), (25, "Battery"),
        (26, "Proximity"), (27, "Satcom"), (28, "Pre-arm check"), (29, "Obstacle avoidance"), (30, "Propulsion"),
    ]
}
