// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Common.cs (getModesList) and
// ExtLibs/Mavlink/Mavlink.cs enums (MAV_TYPE, MAV_MODE_FLAG, MAV_CMD, MAV_DATA_STREAM, MAV_SEVERITY).
// Only the values the app currently uses are listed.

public enum MAVType: UInt8 {
    case generic = 0, fixedWing = 1, quadrotor = 2, coaxial = 3, helicopter = 4, antennaTracker = 5, gcs = 6
    case airship = 7, freeBalloon = 8, rocket = 9, groundRover = 10, surfaceBoat = 11, submarine = 12
    case hexarotor = 13, octorotor = 14, tricopter = 15, flappingWing = 16, kite = 17, onboardController = 18
    case vtolTailsitterDuorotor = 19, vtolTailsitterQuadrotor = 20, vtolTiltrotor = 21, vtolFixedrotor = 22
    case vtolTailsitter = 23, vtolTiltwing = 24, vtolReserved5 = 25, gimbal = 26, adsb = 27, parafoil = 28
    case dodecarotor = 29, camera = 30, chargingStation = 31, flarm = 32, servo = 33, odid = 34
    case decarotor = 35, battery = 36, parachute = 37, log = 38, osd = 39, imu = 40, gps = 41, winch = 42

    public enum Firmware { case copter, plane, rover, sub, tracker, other }

    /// Which ArduPilot firmware's mode table applies (Common.getModesList).
    public var firmware: Firmware {
        switch self {
        case .quadrotor, .coaxial, .helicopter, .hexarotor, .octorotor, .tricopter, .dodecarotor, .decarotor:
            return .copter
        case .fixedWing, .vtolTailsitterDuorotor, .vtolTailsitterQuadrotor, .vtolTiltrotor, .vtolFixedrotor,
             .vtolTailsitter, .vtolTiltwing, .vtolReserved5:
            return .plane
        case .groundRover, .surfaceBoat: return .rover
        case .submarine: return .sub
        case .antennaTracker: return .tracker
        default: return .other
        }
    }
}

public enum MAVAutopilot {
    public static let generic: UInt8 = 0
    public static let ardupilotmega: UInt8 = 3
    public static let invalid: UInt8 = 8
}

public enum MAVModeFlag {
    public static let customModeEnabled: UInt8 = 1
    public static let safetyArmed: UInt8 = 128
}

public enum MAVState: UInt8 {
    case uninit = 0, boot, calibrating, standby, active, critical, emergency, poweroff, flightTermination
}

public enum MAVSeverity: UInt8, CaseIterable {
    case emergency = 0, alert, critical, error, warning, notice, info, debug
    public var label: String {
        ["EMERGENCY", "ALERT", "CRITICAL", "ERROR", "WARNING", "NOTICE", "INFO", "DEBUG"][Int(rawValue)]
    }
}

public enum MAVCmd {
    public static let componentArmDisarm: UInt16 = 400
    public static let setMessageInterval: UInt16 = 511
    public static let requestMessage: UInt16 = 512
    public static let preflightCalibration: UInt16 = 241
    public static let preflightRebootShutdown: UInt16 = 246
    public static let doSetMode: UInt16 = 176
}

public enum MAVResult: UInt8 {
    case accepted = 0, temporarilyRejected, denied, unsupported, failed, inProgress, cancelled
}

/// MAV_DATA_STREAM ids used with REQUEST_DATA_STREAM (what Mission Planner's SRx_* rates map to).
public enum MAVDataStream: UInt8, CaseIterable {
    case all = 0, rawSensors = 1, extendedStatus = 2, rcChannels = 3, rawController = 4
    case position = 6, extra1 = 10, extra2 = 11, extra3 = 12
}

/// ArduPilot custom_mode -> name, per firmware (Mission Planner Common.getModesList).
public enum ArduPilotModes {
    public static let copter: [UInt32: String] = [
        0: "Stabilize", 1: "Acro", 2: "AltHold", 3: "Auto", 4: "Guided", 5: "Loiter", 6: "RTL", 7: "Circle",
        9: "Land", 11: "Drift", 13: "Sport", 14: "Flip", 15: "AutoTune", 16: "PosHold", 17: "Brake",
        18: "Throw", 19: "Avoid_ADSB", 20: "Guided_NoGPS", 21: "Smart_RTL", 22: "FlowHold", 23: "Follow",
        24: "ZigZag", 25: "SystemID", 26: "Heli_Autorotate", 27: "Auto RTL", 28: "Turtle",
    ]
    public static let plane: [UInt32: String] = [
        0: "Manual", 1: "Circle", 2: "Stabilize", 3: "Training", 4: "Acro", 5: "FBWA", 6: "FBWB", 7: "Cruise",
        8: "Autotune", 10: "Auto", 11: "RTL", 12: "Loiter", 13: "Takeoff", 14: "Avoid_ADSB", 15: "Guided",
        17: "QStabilize", 18: "QHover", 19: "QLoiter", 20: "QLand", 21: "QRTL", 22: "QAutotune", 23: "QAcro",
        24: "Thermal", 25: "Loiter to QLand", 26: "Autoland",
    ]
    public static let rover: [UInt32: String] = [
        0: "Manual", 1: "Acro", 3: "Steering", 4: "Hold", 5: "Loiter", 6: "Follow", 7: "Simple", 8: "Dock",
        9: "Circle", 10: "Auto", 11: "RTL", 12: "SmartRTL", 15: "Guided",
    ]
    public static let sub: [UInt32: String] = [
        0: "Stabilize", 1: "Acro", 2: "Depth Hold", 3: "Auto", 4: "Guided", 7: "Circle", 9: "Surface",
        16: "PosHold", 19: "Manual", 20: "Motor Detect", 21: "SurfTrak",
    ]
    public static let tracker: [UInt32: String] = [
        0: "Manual", 1: "Stop", 2: "Scan", 3: "Servo Test", 4: "Guided", 10: "Auto", 16: "Initialising",
    ]

    public static func table(for type: MAVType?) -> [UInt32: String] {
        switch type?.firmware {
        case .copter: return copter
        case .plane: return plane
        case .rover: return rover
        case .sub: return sub
        case .tracker: return tracker
        default: return [:]
        }
    }

    /// GUIDED custom mode for the firmware (Copter 4, Plane/Rover 15, Sub 4).
    public static func guided(for vehicleType: UInt8) -> UInt32? {
        switch MAVType(rawValue: vehicleType)?.firmware {
        case .copter, .sub: return 4
        case .plane, .rover: return 15
        default: return nil
        }
    }

    /// One-tap modes shown in the Actions tab, per firmware (Mission Planner Actions tab buttons).
    public static func quickModes(for vehicleType: UInt8) -> [UInt32] {
        switch MAVType(rawValue: vehicleType)?.firmware {
        case .copter: return [5, 2, 6, 9, 3, 4, 17, 0]      // Loiter AltHold RTL Land Auto Guided Brake Stabilize
        case .plane: return [11, 12, 10, 5, 15, 0]         // RTL Loiter Auto FBWA Guided Manual
        case .rover: return [4, 11, 10, 15, 0]             // Hold RTL Auto Guided Manual
        case .sub: return [2, 0, 19, 16]
        default: return []
        }
    }

    public static func name(customMode: UInt32, vehicleType: UInt8) -> String {
        table(for: MAVType(rawValue: vehicleType))[customMode] ?? "Mode \(customMode)"
    }
}
