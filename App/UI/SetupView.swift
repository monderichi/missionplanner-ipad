// REA Parity Source: MissionPlanner GCSViews/InitialSetup.cs + ConfigurationView/*:
// ConfigFrameType, ConfigAccelerometerCalibration, ConfigHWCompass2 (onboard mag cal),
// ConfigRadioInput (radio calibration -> RCn_MIN/MAX/TRIM), ConfigFlightModes (FLTMODE1..6 /
// MODE1..6 on FLTMODE_CH / MODE_CH), ConfigMotorTest, and the pre-arm / sensor status.

import MAVLinkKit
import SwiftUI

enum SetupPage: String, CaseIterable, Identifiable {
    case prearm = "Pre-arm & sensors"
    case frame = "Frame type"
    case roversetup = "Rover setup"
    case subsetup = "ROV setup"
    case fence = "Geofence & max altitude"
    case battery = "Battery monitor"
    case failsafe = "Failsafe"
    case tuning = "Tuning"
    case logs = "DataFlash logs"
    case accel = "Accelerometer"
    case compass = "Compass"
    case radio = "Radio calibration"
    case modes = "Flight modes"
    case motors = "Motor test"
    case servo = "Servo output"
    case othercal = "Other calibrations"
    case rangefinder = "Rangefinder"
    case airspeed = "Airspeed sensor"
    case flow = "Optical flow"
    case gps = "GPS"
    case compasscfg = "Compass config"
    case serial = "Serial ports"
    case planner = "Planner settings"

    var id: String { rawValue }

    /// Which firmware the page makes sense for. `nil` / `.other` (no vehicle yet, or an unknown type) shows
    /// every generic page, which then asks for a connection.
    func applies(to fw: MAVType.Firmware?) -> Bool {
        let f = fw ?? .other
        switch self {
        case .roversetup: return f == .rover
        case .subsetup: return f == .sub
        case .frame: return f == .copter || f == .other
        case .fence, .failsafe, .tuning: return f == .copter || f == .plane || f == .rover || f == .other
        case .modes: return f == .copter || f == .plane || f == .rover || f == .other
        case .motors: return f == .copter || f == .rover || f == .sub || f == .other
        case .rangefinder: return f != .tracker
        case .airspeed: return f == .plane || f == .other
        case .flow: return f == .copter || f == .plane || f == .rover || f == .other
        default: return true // prearm, battery, logs, accel, compass, radio, servo, othercal, gps, compasscfg, serial, planner
        }
    }

    /// REA Parity Source: MissionPlanner ConfigFailSafe.cs / ConfigBatteryMonitoring.cs.
    /// Names the vehicle doesn't have are skipped by ParamAutoRow, so a few renamed aliases are listed.
    static func failsafeParams(for fw: MAVType.Firmware?) -> [String] {
        switch fw {
        case .plane:
            return [
                "THR_FAILSAFE", "THR_FS_VALUE", "FS_SHORT_ACTN", "FS_SHORT_TIMEOUT", "FS_LONG_ACTN", "FS_LONG_TIMEOUT",
                "FS_GCS_ENABL", "BATT_FS_LOW_ACT", "BATT_LOW_VOLT", "BATT_LOW_MAH", "BATT_FS_CRT_ACT", "BATT_CRT_VOLT",
                "BATT_CRT_MAH", "FS_EKF_THRESH",
            ]
        case .rover:
            return [
                "FS_ACTION", "FS_TIMEOUT", "FS_THR_ENABLE", "FS_THR_VALUE", "FS_GCS_ENABLE", "FS_CRASH_CHECK",
                "FS_EKF_ACTION", "FS_EKF_THRESH", "FS_OPTIONS", "BATT_FS_LOW_ACT", "BATT_LOW_VOLT", "BATT_LOW_MAH",
                "BATT_FS_CRT_ACT", "BATT_CRT_VOLT", "BATT_CRT_MAH",
            ]
        default: // Copter
            return [
                "FS_THR_ENABLE", "FS_THR_VALUE", "BATT_FS_LOW_ACT", "BATT_LOW_VOLT", "BATT_LOW_MAH",
                "BATT_FS_CRT_ACT", "BATT_CRT_VOLT", "BATT_CRT_MAH", "FS_GCS_ENABLE", "FS_GCS_TIMEOUT",
                "FS_EKF_ACTION", "FS_EKF_THRESH", "FS_CRASH_CHECK", "FS_VIBE_ENABLE", "FS_DR_ENABLE", "FS_OPTIONS",
            ]
        }
    }

    /// REA Parity Source: MissionPlanner ConfigArducopter.cs (Extended Tuning) / ConfigArduplane.cs / ConfigArdurover.cs.
    static func tuningParams(for fw: MAVType.Firmware?) -> [String] {
        switch fw {
        case .plane:
            return [
                "RLL_RATE_P", "RLL_RATE_I", "RLL_RATE_D", "PTCH_RATE_P", "PTCH_RATE_I", "PTCH_RATE_D",
                "RLL2SRV_TCONST", "PTCH2SRV_TCONST", "AIRSPEED_CRUISE", "TRIM_ARSPD_CM", "ARSPD_FBW_MIN", "ARSPD_FBW_MAX",
                "TRIM_THROTTLE", "THR_MIN", "THR_MAX", "LIM_ROLL_CD", "LIM_PITCH_MAX", "TECS_CLMB_MAX", "TECS_SINK_MAX",
                "TECS_SPDWEIGHT", "TECS_TIME_CONST", "NAVL1_PERIOD",
            ]
        case .rover:
            return [
                "ATC_STR_RAT_P", "ATC_STR_RAT_I", "ATC_STR_RAT_D", "ATC_STR_RAT_FF", "ATC_STR_RAT_MAX", "ATC_STR_ANG_P",
                "ATC_SPEED_P", "ATC_SPEED_I", "ATC_SPEED_D", "ATC_ACCEL_MAX", "ATC_DECEL_MAX", "ATC_STR_ACC_MAX",
                "ATC_TURN_MAX_G", "CRUISE_SPEED", "CRUISE_THROTTLE", "WP_SPEED", "WP_RADIUS", "WP_OVERSHOOT",
                "TURN_RADIUS", "TURN_MAX_G", "NAVL1_PERIOD", "MOT_THR_MIN", "MOT_THR_MAX", "MOT_SLEWRATE",
                "PILOT_STEER_TYPE",
            ]
        default: // Copter. PSC_NE_* / PSC_D_* are the 4.7+ names of PSC_VELXY/POSXY/ACCZ.
            return [
                "ATC_RAT_RLL_P", "ATC_RAT_RLL_I", "ATC_RAT_RLL_D", "ATC_RAT_PIT_P", "ATC_RAT_PIT_I", "ATC_RAT_PIT_D",
                "ATC_RAT_YAW_P", "ATC_RAT_YAW_I", "ATC_RAT_YAW_D", "ATC_ANG_RLL_P", "ATC_ANG_PIT_P", "ATC_ANG_YAW_P",
                "ATC_INPUT_TC", "ATC_ACCEL_R_MAX", "ATC_ACCEL_P_MAX", "ATC_ACCEL_Y_MAX",
                "INS_GYRO_FILTER", "INS_ACCEL_FILTER", "MOT_THST_HOVER", "MOT_THST_EXPO", "MOT_SPIN_ARM", "MOT_SPIN_MIN",
                "PSC_ACCZ_P", "PSC_ACCZ_I", "PSC_D_ACC_P", "PSC_D_ACC_I", "PSC_VELXY_P", "PSC_NE_VEL_P",
                "PSC_POSXY_P", "PSC_NE_POS_P", "ANGLE_MAX", "PILOT_SPEED_UP", "PILOT_SPEED_DN",
                "WPNAV_SPEED", "WPNAV_SPEED_UP", "WPNAV_SPEED_DN", "WPNAV_RADIUS", "LOIT_SPEED", "RTL_ALT", "RTL_SPEED",
                "LAND_SPEED", "AUTOTUNE_AXES", "AUTOTUNE_AGGR",
            ]
        }
    }

    /// REA Parity Source: MissionPlanner ConfigRangeFinder.cs / ConfigOpticalFlow.cs / ConfigHWAirspeed.cs / ConfigHWCompass.cs.
    static let rangefinderParams = [
        "RNGFND1_TYPE", "RNGFND1_ORIENT", "RNGFND1_MIN_CM", "RNGFND1_MIN", "RNGFND1_MAX_CM", "RNGFND1_MAX",
        "RNGFND1_GNDCLEAR", "RNGFND1_SCALING", "RNGFND1_OFFSET", "RNGFND1_PIN",
    ]
    static let airspeedParams = ["ARSPD_TYPE", "ARSPD_USE", "ARSPD_PIN", "ARSPD_RATIO", "ARSPD_OFFSET", "ARSPD_AUTOCAL", "ARSPD_BUS"]
    static let flowParams = ["FLOW_TYPE", "FLOW_ORIENT_YAW", "FLOW_FXSCALER", "FLOW_FYSCALER", "FLOW_POS_X", "FLOW_POS_Y", "FLOW_POS_Z"]
    static let gpsParams = [
        "GPS_TYPE", "GPS1_TYPE", "GPS_TYPE2", "GPS2_TYPE", "GPS_AUTO_CONFIG", "GPS_GNSS_MODE", "GPS1_GNSS_MODE",
        "GPS_GNSS_MODE2", "GPS2_GNSS_MODE", "GPS_RATE_MS", "GPS_RATE_MS2", "GPS_AUTO_SWITCH", "GPS_PRIMARY",
    ]
    static let compassParams = [
        "COMPASS_ENABLE", "COMPASS_USE", "COMPASS_USE2", "COMPASS_USE3", "COMPASS_ORIENT", "COMPASS_ORIENT2",
        "COMPASS_EXTERNAL", "COMPASS_AUTODEC", "COMPASS_DEC", "COMPASS_LEARN",
    ]
    static let serialParams: [String] = (0...8).flatMap { ["SERIAL\($0)_PROTOCOL", "SERIAL\($0)_BAUD"] }

    /// The Planner settings page is local to this iPad and works without a vehicle.
    var needsVehicle: Bool { self != .planner }

    var icon: String {
        switch self {
        case .prearm: return "checklist"
        case .frame: return "airplane"
        case .roversetup: return "car.fill"
        case .subsetup: return "water.waves"
        case .fence: return "arrow.up.to.line"
        case .battery: return "battery.75"
        case .failsafe: return "exclamationmark.shield"
        case .tuning: return "slider.horizontal.3"
        case .logs: return "doc.text.magnifyingglass"
        case .accel: return "gyroscope"
        case .compass: return "location.north.circle"
        case .radio: return "dot.radiowaves.left.and.right"
        case .modes: return "switch.2"
        case .motors: return "fanblades"
        case .servo: return "slider.vertical.3"
        case .othercal: return "scope"
        case .rangefinder: return "ruler"
        case .airspeed: return "wind"
        case .flow: return "camera.metering.center.weighted"
        case .gps: return "location.fill"
        case .compasscfg: return "safari"
        case .serial: return "cable.connector"
        case .planner: return "gearshape"
        }
    }
}

struct SetupView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter
    @State private var selected = SetupPage.allCases.first { "\($0)" == UserDefaults.standard.string(forKey: "MPSetupPage") } ?? .prearm

    private var firmware: MAVType.Firmware? { MAVType(rawValue: vehicle.vehicleType)?.firmware }
    private var visiblePages: [SetupPage] { SetupPage.allCases.filter { $0.applies(to: firmware) } }
    /// The remembered page may not exist for this firmware (e.g. after switching vehicles): fall back to the first one.
    private var page: SetupPage { visiblePages.contains(selected) ? selected : (visiblePages.first ?? .prearm) }

    var body: some View {
        HStack(spacing: 0) {
            List {
                ForEach(visiblePages) { p in
                    Button {
                        selected = p
                    } label: {
                        Label(p.rawValue, systemImage: p.icon).fontWeight(page == p ? .bold : .regular)
                    }
                    .listRowBackground(page == p ? Color.accentColor.opacity(0.15) : Color.clear)
                }
            }
            .listStyle(.plain)
            .frame(width: 240)
            Divider()
            VStack(spacing: 0) {
                if let r = commands.lastResult {
                    Label(r, systemImage: commands.lastResultOK ? "checkmark.circle" : "exclamationmark.triangle")
                        .font(.callout)
                        .foregroundColor(commands.lastResultOK ? .primary : .orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.10))
                }
                if page.needsVehicle && !commands.isAttached {
                    Text("Connect to a vehicle to use Setup.").foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch page {
                    case .prearm: PrearmPage()
                    case .frame: FramePage()
                    case .roversetup: RoverSetupPage()
                    case .subsetup: SubSetupPage()
                    case .fence: FencePage()
                    case .battery: BatteryPage()
                    case .failsafe: ParamListPage(title: "Failsafe", names: SetupPage.failsafeParams(for: firmware),
                                                  footer: "FS_GCS_ENABLE reacts to losing this iPad's heartbeat; over ExpressLRS short dropouts are normal, so use a timeout (FS_GCS_TIMEOUT) of several seconds.")
                    case .tuning: ParamListPage(title: "Tuning", names: SetupPage.tuningParams(for: firmware),
                                                footer: "Change one value at a time in small steps and test-drive or test-fly. Parameters › Save first to keep a backup.")
                    case .logs: LogsPage()
                    case .accel: AccelPage()
                    case .compass: CompassPage()
                    case .radio: RadioPage()
                    case .modes: FlightModesPage()
                    case .motors: MotorTestPage()
                    case .servo: ServoPage()
                    case .othercal: OtherCalPage()
                    case .rangefinder: ParamListPage(title: "Rangefinder", names: SetupPage.rangefinderParams,
                                                     footer: "Only parameters the firmware has are shown. Reboot after changing the sensor type.")
                    case .airspeed: ParamListPage(title: "Airspeed", names: SetupPage.airspeedParams,
                                                  footer: "Airspeed parameters exist only on firmware with an airspeed library (Plane, VTOL, and Copter builds that include it). Reboot after changing the sensor type.")
                    case .flow: ParamListPage(title: "Optical flow", names: SetupPage.flowParams,
                                              footer: "Reboot after enabling the sensor. Position offsets are relative to the flight controller, in metres.")
                    case .gps: ParamListPage(title: "GPS", names: SetupPage.gpsParams,
                                             footer: "Reboot after changing the GPS type. Newer firmware names these GPS1_TYPE / GPS1_GNSS_MODE; only the ones this vehicle has are shown.")
                    case .compasscfg: ParamListPage(title: "Compass config", names: SetupPage.compassParams,
                                                    footer: "Calibrate on the Compass page. Reboot after changing which compasses are used or their orientation.")
                    case .serial: ParamListPage(title: "Serial ports", names: SetupPage.serialParams,
                                                footer: "Take care: changing the protocol of the port this link uses (for example SERIAL6 for ExpressLRS) can cut your connection. A reboot is needed.")
                    case .planner: PlannerSettingsPage()
                    }
                }
            }
        }
    }
}

// MARK: - Pre-arm

struct PrearmPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var calibration: CalibrationStore

    private var prearmMessages: [StatusMessage] {
        vehicle.messages.filter { $0.text.localizedCaseInsensitiveContains("prearm") || $0.text.localizedCaseInsensitiveContains("arm:") }
    }

    var body: some View {
        List {
            Section {
                Button { calibration.runPrearmChecks() } label: { Label("Run pre-arm checks now", systemImage: "play.circle") }
            } footer: {
                Text("ArduPilot answers with \"PreArm: …\" messages for every problem that blocks arming.")
            }
            Section("Pre-arm messages (newest first)") {
                if prearmMessages.isEmpty {
                    Text("None received").foregroundColor(.secondary)
                }
                ForEach(prearmMessages.prefix(30)) { m in
                    Text(m.text).foregroundColor(.orange)
                }
            }
            Section("Sensors (SYS_STATUS)") {
                ForEach(SensorBits.names, id: \.bit) { s in
                    let mask = UInt32(1) << UInt32(s.bit)
                    if vehicle.sensorsPresent & mask != 0 {
                        HStack {
                            Text(s.name)
                            Spacer()
                            if vehicle.sensorsEnabled & mask == 0 {
                                Text("disabled").foregroundColor(.secondary)
                            } else if vehicle.sensorsHealthy & mask != 0 {
                                Label("OK", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                            } else {
                                Label("Unhealthy", systemImage: "xmark.octagon.fill").foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            Section("EKF / vibration") {
                LabeledContent("EKF variances (vel / posH / posV / compass / terrain)",
                               value: vehicle.ekfVariances.map { String(format: "%.2f", $0) }.joined(separator: " / "))
                LabeledContent("Vibration X / Y / Z", value: vehicle.vibration.map { String(format: "%.1f", $0) }.joined(separator: " / "))
                LabeledContent("Clipping", value: vehicle.clipping.map { "\($0)" }.joined(separator: " / "))
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Frame

struct FramePage: View {
    @EnvironmentObject var params: ParameterStore
    @EnvironmentObject var vehicle: VehicleModel

    var body: some View {
        Form {
            if params.params.isEmpty {
                Text("Waiting for parameters…").foregroundColor(.secondary)
            }
            ParamOptionRow(name: "FRAME_CLASS")
            ParamOptionRow(name: "FRAME_TYPE")
            Section {
                EmptyView()
            } footer: {
                Text("Frame changes need a reboot. Use Parameters › Reboot after writing.")
            }
        }
    }
}

/// A picker for one parameter that has a value list in Mission Planner's metadata.
struct ParamOptionRow: View {
    @EnvironmentObject var params: ParameterStore
    let name: String

    var body: some View {
        if let p = params.params[name] {
            let meta = params.metadata[name]
            Section(meta?.displayName ?? name) {
                Picker(name, selection: Binding(get: { Double(p.value) }, set: { params.set(name, Float($0)) })) {
                    ForEach(meta?.values ?? []) { o in Text("\(Int(o.code)): \(o.label)").tag(o.code) }
                    if meta?.label(for: p.value) == nil { Text("\(ParamFile.formatValue(p.value))").tag(Double(p.value)) }
                }
                .pickerStyle(.menu)
                if params.pendingNames.contains(name) { ProgressView() }
            }
        }
    }
}

// MARK: - Accelerometer

struct AccelPage: View {
    @EnvironmentObject var calibration: CalibrationStore
    @EnvironmentObject var vehicle: VehicleModel

    var body: some View {
        Form {
            Section {
                switch calibration.accel {
                case .idle:
                    Text("Calibrates all accelerometers in 6 positions. Keep the vehicle still in each position.")
                    Button { calibration.startAccel() } label: { Label("Calibrate accelerometer", systemImage: "play.fill") }
                        .disabled(vehicle.armed)
                case .starting:
                    HStack { ProgressView(); Text("Waiting for the flight controller…") }
                    Button("Reset") { calibration.resetAccel() }
                case .place(let p):
                    Text(CalibrationStore.positionName(p)).font(.title2.bold())
                    Text(CalibrationStore.positionHelp(p))
                    Button {
                        calibration.confirmPosition()
                    } label: {
                        Label("Vehicle is in position: continue", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                case .success:
                    Label("Accelerometer calibration successful", systemImage: "checkmark.seal.fill").foregroundColor(.green)
                    Text("Reboot the flight controller (Parameters › Reboot) before flying.")
                    Button("Done") { calibration.resetAccel() }
                case .failed:
                    Label("Calibration failed", systemImage: "xmark.octagon.fill").foregroundColor(.red)
                    Text("Check Messages for the reason, then try again keeping the vehicle completely still.")
                    Button("Try again") { calibration.resetAccel() }
                }
            } header: {
                Text("Accelerometer (6 positions)")
            }
            Section {
                Button { calibration.calibrateLevel() } label: { Label("Calibrate level", systemImage: "level") }
                    .disabled(vehicle.armed)
            } header: {
                Text("Level")
            } footer: {
                Text("Place the vehicle in its normal flying attitude (level) first. Sets the AHRS trim.")
            }
            Section("Latest messages") {
                ForEach(vehicle.messages.prefix(6)) { m in Text(m.text).font(.callout) }
            }
        }
    }
}

// MARK: - Compass

struct CompassPage: View {
    @EnvironmentObject var calibration: CalibrationStore
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter

    var body: some View {
        Form {
            Section {
                Text("Start, then rotate the vehicle around all axes (each side down, nose up/down, full turns) until every bar reaches 100%. With good results the offsets are saved automatically.")
                HStack {
                    Button { calibration.startCompass() } label: { Label("Start", systemImage: "play.fill") }
                        .buttonStyle(.borderedProminent)
                        .disabled(vehicle.armed)
                    Button("Accept") { calibration.acceptCompass() }
                        .disabled(vehicle.magCalReports.isEmpty)
                    Button("Cancel", role: .destructive) { calibration.cancelCompass() }
                }
            } header: {
                Text("Onboard compass calibration")
            }
            Section("Progress") {
                if vehicle.magCalProgress.isEmpty {
                    Text(calibration.compassRunning ? "Waiting for progress from the flight controller…" : "Not running")
                        .foregroundColor(.secondary)
                }
                ForEach(vehicle.magCalProgress.keys.sorted(), id: \.self) { id in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Compass \(Int(id) + 1)")
                            Spacer()
                            Text("\(vehicle.magCalProgress[id] ?? 0)%").monospacedDigit()
                        }
                        ProgressView(value: Double(vehicle.magCalProgress[id] ?? 0), total: 100)
                        if let r = vehicle.magCalReports[id] {
                            Text("\(CalibrationStore.magStatus(r.calStatus)) · fitness \(String(format: "%.1f", r.fitness)) · offsets \(String(format: "%.0f, %.0f, %.0f", r.ofsX, r.ofsY, r.ofsZ))\(r.autosaved != 0 ? " · saved" : "")")
                                .font(.caption)
                                .foregroundColor(r.calStatus == 4 ? .green : .red)
                        }
                    }
                }
            }
            FixedYawCalSection()
            Section {
                EmptyView()
            } footer: {
                Text("Reboot the flight controller after a successful compass calibration. Over ExpressLRS the progress updates slowly; that's normal.")
            }
        }
    }
}

// MARK: - Radio

struct RadioPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore
    @State private var capturing = false
    @State private var mins: [UInt16] = Array(repeating: 2200, count: 18)
    @State private var maxs: [UInt16] = Array(repeating: 800, count: 18)
    @State private var message: String?

    private var channels: Int { max(8, min(16, vehicle.rcChannelCount)) }
    private var centredThrottle: Bool {
        let fw = MAVType(rawValue: vehicle.vehicleType)?.firmware
        return fw == .rover || fw == .sub
    }

    var body: some View {
        Form {
            Section {
                ForEach(0..<channels, id: \.self) { i in
                    let v = vehicle.rcChannels[i]
                    HStack {
                        Text("CH\(i + 1)").frame(width: 46, alignment: .leading).monospacedDigit()
                        ProgressView(value: Double(min(max(Int(v), 800), 2200) - 800), total: 1400)
                        Text(v == 0 || v == UInt16.max ? "—" : "\(v)").frame(width: 50, alignment: .trailing).monospacedDigit()
                        if capturing && maxs[i] > mins[i] {
                            Text("\(mins[i])–\(maxs[i])").font(.caption).frame(width: 90).monospacedDigit()
                        }
                    }
                }
            } header: {
                Text("RC inputs (\(vehicle.rcChannelCount) channels)")
            } footer: {
                if vehicle.rcChannelCount == 0 {
                    Text("No RC input. Is the receiver powered (battery in) and the transmitter on?")
                }
            }
            Section {
                if !capturing {
                    Button { start() } label: { Label("Calibrate radio", systemImage: "play.fill") }
                        .disabled(vehicle.rcChannelCount == 0 || vehicle.armed)
                } else {
                    Text("Move all sticks and switches to their full extents, then centre the sticks and put throttle down.")
                    Button { save() } label: { Label("Save calibration", systemImage: "checkmark.circle.fill") }
                        .buttonStyle(.borderedProminent)
                    Button("Cancel", role: .cancel) { capturing = false }
                }
                if let m = message { Text(m).font(.caption) }
            }
        }
        .onChange(of: vehicle.rcChannels) { values in
            guard capturing else { return }
            for i in 0..<min(values.count, 18) where values[i] > 800 && values[i] < 2200 {
                mins[i] = min(mins[i], values[i])
                maxs[i] = max(maxs[i], values[i])
            }
        }
    }

    private func start() {
        mins = Array(repeating: 2200, count: 18)
        maxs = Array(repeating: 800, count: 18)
        message = nil
        capturing = true
    }

    private func save() {
        let throttleCh = Int(params.params["RCMAP_THROTTLE"]?.value ?? 3)
        var out: [String: Float] = [:]
        for i in 0..<channels where maxs[i] > mins[i] && maxs[i] - mins[i] > 300 {
            let ch = i + 1
            let cur = vehicle.rcChannels[i]
            // Copter/plane throttle rests at its minimum; rover/sub throttle is centre-sprung like the other sticks.
            let trim = (ch == throttleCh && !centredThrottle) ? mins[i] : min(max(cur, mins[i]), maxs[i])
            out["RC\(ch)_MIN"] = Float(mins[i])
            out["RC\(ch)_MAX"] = Float(maxs[i])
            out["RC\(ch)_TRIM"] = Float(trim)
        }
        capturing = false
        if out.isEmpty {
            message = "No channel moved enough (need > 300 µs travel). Nothing written."
        } else {
            params.setMany(out)
            message = "Writing \(out.count / 3) channels: watch the Parameters banner for confirmation."
        }
    }
}

// MARK: - Flight modes

struct FlightModesPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore

    private var isRover: Bool { MAVType(rawValue: vehicle.vehicleType)?.firmware == .rover }
    private var prefix: String { isRover ? "MODE" : "FLTMODE" }
    private var channelParam: String { isRover ? "MODE_CH" : "FLTMODE_CH" }
    private var channel: Int { Int(params.params[channelParam]?.value ?? (isRover ? 8 : 5)) }

    private var activeSlot: Int? {
        guard channel >= 1 && channel <= vehicle.rcChannels.count else { return nil }
        let pwm = Int(vehicle.rcChannels[channel - 1])
        guard pwm > 800 && pwm < 2200 else { return nil }
        switch pwm {
        case ..<1231: return 1
        case ..<1361: return 2
        case ..<1491: return 3
        case ..<1621: return 4
        case ..<1750: return 5
        default: return 6
        }
    }

    private var modes: [(UInt32, String)] {
        ArduPilotModes.table(for: MAVType(rawValue: vehicle.vehicleType)).sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("Mode switch channel", value: "CH\(channel) (\(channelParam))")
                LabeledContent("Current PWM", value: channel <= vehicle.rcChannels.count ? "\(vehicle.rcChannels[channel - 1])" : "—")
                LabeledContent("Current mode", value: vehicle.modeName)
            }
            Section("Switch positions") {
                ForEach(1...6, id: \.self) { slot in
                    let name = "\(prefix)\(slot)"
                    if let p = params.params[name] {
                        HStack {
                            Text("Position \(slot)").fontWeight(activeSlot == slot ? .bold : .regular)
                            if activeSlot == slot { Image(systemName: "arrowtriangle.left.fill").foregroundColor(.green) }
                            Spacer()
                            Picker(name, selection: Binding(get: { UInt32(p.value) }, set: { params.set(name, Float($0)) })) {
                                ForEach(modes.indices, id: \.self) { i in Text(modes[i].1).tag(modes[i].0) }
                            }
                            .pickerStyle(.menu)
                            if params.pendingNames.contains(name) { ProgressView() }
                        }
                        .listRowBackground(activeSlot == slot ? Color.green.opacity(0.12) : nil)
                    } else {
                        Text("\(name): waiting for parameters…").foregroundColor(.secondary)
                    }
                }
            }
            Section {
                EmptyView()
            } footer: {
                Text("PWM ranges: 1 ≤1230, 2 ≤1360, 3 ≤1490, 4 ≤1620, 5 ≤1749, 6 ≥1750. Each change is written immediately and confirmed.")
            }
        }
    }
}

// MARK: - Motor test

struct MotorTestPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore
    @EnvironmentObject var calibration: CalibrationStore
    @State private var throttle = 5.0
    @State private var duration = 2.0
    @State private var propsOff = false

    private var firmware: MAVType.Firmware? { MAVType(rawValue: vehicle.vehicleType)?.firmware }
    private var isRover: Bool { firmware == .rover }
    private var isSub: Bool { firmware == .sub }

    /// REA Parity Source: ArduCopter AP_MotorsMatrix frame classes (FRAME_CLASS -> motor count).
    private var copterMotorCount: Int {
        switch Int(params.params["FRAME_CLASS"]?.value ?? 1) {
        case 2, 5: return 6      // hexa, Y6
        case 3, 4: return 8      // octa, octa-quad
        case 7: return 3         // tri
        case 9, 10: return 2     // coax, bicopter
        case 12: return 12       // dodeca-hexa
        case 14: return 10       // deca
        default: return 4        // quad, heli-quad (13)
        }
    }

    /// ArduSub FRAME_CONFIG -> thruster count.
    private var subMotorCount: Int {
        switch Int(params.params["FRAME_CONFIG"]?.value ?? 1) {
        case 4: return 3
        case 5: return 4
        case 6: return 5
        case 0, 1: return 6
        default: return 8
        }
    }

    private func outputHas(function: Float) -> Bool {
        (1...16).contains { params.params["SERVO\($0)_FUNCTION"]?.value == function }
    }

    /// Rover skid steering: throttle left (73) / right (74) outputs exist.
    private var skidSteer: Bool { outputHas(function: 73) || outputHas(function: 74) }

    /// Button label per ArduPilot motor-test sequence number.
    private var targets: [(seq: Int, label: String)] {
        if isRover {
            // AP_MotorsUGV::output_test_seq: 1 = throttle (left), 2 = steering (right).
            return skidSteer ? [(1, "Left"), (2, "Right")] : [(1, "Throttle"), (2, "Steering")]
        }
        if isSub { return (1...subMotorCount).map { (seq: $0, label: "M\($0)") } }
        return (1...copterMotorCount).map { (seq: $0, label: CalibrationStore.motorLetter($0)) }
    }

    private var throttleRange: ClosedRange<Double> { isRover ? -100...100 : 1...30 }
    private var throttleStep: Double { isRover ? 5 : 1 }

    var body: some View {
        Form {
            Section {
                Toggle(isRover ? "I have LIFTED THE WHEELS OFF THE GROUND" : "I have REMOVED THE PROPELLERS", isOn: $propsOff)
                    .tint(.red)
            } footer: {
                Text(isRover
                     ? "The wheels or propeller spin during this test. Keep the vehicle clear of people and obstacles."
                     : "Motors spin during this test. Never test with propellers fitted.")
            }
            Section("Settings") {
                HStack {
                    Text("Throttle")
                    Slider(value: $throttle, in: throttleRange, step: throttleStep)
                    Text("\(Int(throttle)) %").monospacedDigit().frame(width: 60)
                }
                HStack {
                    Text("Duration")
                    Slider(value: $duration, in: 1...5, step: 0.5)
                    Text(String(format: "%.1f s", duration)).monospacedDigit().frame(width: 50)
                }
            }
            Section(isRover
                    ? "Outputs (negative throttle = reverse / steer left)"
                    : (isSub ? "Thrusters (test order by motor number)" : "Motors (test order A, B, C… as in the ArduPilot frame diagrams)")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: isRover ? 110 : 70))], spacing: 12) {
                    ForEach(targets.indices, id: \.self) { i in
                        let t = targets[i]
                        Button(t.label) {
                            calibration.motorTest(motor: t.seq, throttle: Float(throttle), duration: Float(duration))
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title3.bold())
                    }
                }
                .padding(.vertical, 6)
                if !isRover {
                    Button("Test all motors in sequence") {
                        calibration.motorTest(motor: 1, throttle: Float(throttle), duration: Float(duration), count: targets.count)
                    }
                }
            }
            .disabled(!propsOff || vehicle.armed)
        }
        .onAppear { if isRover { throttle = 10 } }
    }
}

// MARK: - Geofence / maximum altitude

/// REA Parity Source: MissionPlanner GCSViews/ConfigurationView/ConfigAC_Fence.cs
/// (FENCE_ENABLE, FENCE_TYPE bitmask, FENCE_ACTION, FENCE_ALT_MAX, FENCE_RADIUS, FENCE_MARGIN).
struct FencePage: View {
    @EnvironmentObject var params: ParameterStore
    @State private var quickAlt = 120.0

    @EnvironmentObject var vehicle: VehicleModel

    private var firmware: MAVType.Firmware? { MAVType(rawValue: vehicle.vehicleType)?.firmware }
    /// The quick maximum-altitude preset only makes sense when the vehicle flies.
    private var hasAltitudePreset: Bool {
        (firmware == .copter || firmware == .plane) && params.params["FENCE_ALT_MAX"] != nil
    }
    private var available: Bool { params.params["FENCE_ENABLE"] != nil || params.params["FENCE_ALT_MAX"] != nil }

    var body: some View {
        Form {
            if params.params.isEmpty {
                Text("Waiting for parameters…").foregroundColor(.secondary)
            } else if !available {
                Text("This firmware has no geofence parameters.").foregroundColor(.secondary)
            } else {
                if hasAltitudePreset {
                Section {
                    HStack {
                        Text("Maximum altitude")
                        Spacer()
                        TextField("m", value: $quickAlt, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("m above home")
                    }
                    Button {
                        limitAltitude()
                    } label: {
                        Label("Apply altitude limit", systemImage: "arrow.up.to.line")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(quickAlt < 10 || quickAlt > 1000)
                } header: {
                    Text("Quick setup")
                } footer: {
                    Text("Writes FENCE_ALT_MAX, turns on the altitude fence (FENCE_TYPE bit 0), sets FENCE_ENABLE = 1 and, if it was \"Report only\", FENCE_ACTION = RTL or Land. If the vehicle climbs above this height it returns or lands. Keep the circle/polygon fences as they are, or adjust them below.")
                }
                }
                ParamOptionRow(name: "FENCE_ENABLE")
                ParamBitmaskRow(name: "FENCE_TYPE")
                if firmware != .rover { ParamNumberRow(name: "FENCE_ALT_MAX") }
                ParamOptionRow(name: "FENCE_ACTION")
                ParamNumberRow(name: "FENCE_RADIUS")
                ParamNumberRow(name: "FENCE_MARGIN")
                ParamOptionRow(name: "FENCE_AUTOENABLE")
                Section {
                    EmptyView()
                } footer: {
                    Text(firmware == .rover
                         ? "The circle and polygon fences need a GPS fix to arm. Draw the polygon in Plan › Fence. Test the fence at low speed first."
                         : "The circle and polygon fences need a GPS fix to arm. The altitude fence is measured from home (where the vehicle armed). Test the limit at a safe height first.")
                }
            }
        }
        .onAppear {
            if let v = params.params["FENCE_ALT_MAX"]?.value { quickAlt = Double(v) }
        }
    }

    private func limitAltitude() {
        var out: [String: Float] = ["FENCE_ALT_MAX": Float(quickAlt), "FENCE_ENABLE": 1]
        let type = UInt32(max(0, params.params["FENCE_TYPE"]?.value ?? 0))
        out["FENCE_TYPE"] = Float(type | 1)
        if (params.params["FENCE_ACTION"]?.value ?? 0) == 0 { out["FENCE_ACTION"] = 1 }
        params.setMany(out)
    }
}

/// Numeric parameter with range/units from the metadata and an explicit Write button.
struct ParamNumberRow: View {
    @EnvironmentObject var params: ParameterStore
    let name: String
    @State private var text = ""

    var body: some View {
        if let p = params.params[name] {
            let meta = params.metadata[name]
            Section {
                HStack {
                    TextField(name, text: $text)
                        .keyboardType(.numbersAndPunctuation)
                        .font(.system(.body, design: .monospaced))
                    if let u = meta?.units { Text(u).foregroundColor(.secondary) }
                    if params.pendingNames.contains(name) {
                        ProgressView()
                    } else {
                        Button("Write") {
                            if let v = Float(text.replacingOccurrences(of: ",", with: ".")), v.isFinite { params.set(name, v) }
                        }
                        .disabled(Float(text.replacingOccurrences(of: ",", with: ".")) == nil
                                  || Float(text.replacingOccurrences(of: ",", with: ".")) == p.value)
                    }
                }
            } header: {
                Text("\(meta?.displayName ?? name) (\(name))")
            } footer: {
                if let r = meta?.range {
                    Text("Range \(ParamFile.formatValue(Float(r.lowerBound))) … \(ParamFile.formatValue(Float(r.upperBound))). Current \(ParamFile.formatValue(p.value)).")
                }
            }
            .onAppear { text = ParamFile.formatValue(p.value) }
            .onChange(of: p.value) { text = ParamFile.formatValue($0) }
        }
    }
}

/// Bitmask parameter as toggles; each change is written immediately.
struct ParamBitmaskRow: View {
    @EnvironmentObject var params: ParameterStore
    let name: String

    var body: some View {
        if let p = params.params[name], let bits = params.metadata[name]?.bits, !bits.isEmpty {
            let value = UInt32(max(0, p.value))
            Section("\(params.metadata[name]?.displayName ?? name) (\(name))") {
                ForEach(bits) { b in
                    let mask = UInt32(1) << UInt32(b.code)
                    Toggle(b.label, isOn: Binding(get: { value & mask != 0 }, set: { on in
                        params.set(name, Float(on ? value | mask : value & ~mask))
                    }))
                }
                if params.pendingNames.contains(name) { ProgressView() }
            }
        }
    }
}
// MARK: - Generic parameter pages

/// Picks the right editor from the metadata: list -> picker, bitmask -> checkboxes, else number.
struct ParamAutoRow: View {
    @EnvironmentObject var params: ParameterStore
    let name: String

    var body: some View {
        let meta = params.metadata[name]
        if params.params[name] == nil {
            EmptyView()
        } else if let m = meta, !m.values.isEmpty {
            ParamOptionRow(name: name)
        } else if let m = meta, !m.bits.isEmpty {
            ParamBitmaskRow(name: name)
        } else {
            ParamNumberRow(name: name)
        }
    }
}

struct ParamListPage: View {
    @EnvironmentObject var params: ParameterStore
    let title: String
    let names: [String]
    let footer: String

    var body: some View {
        Form {
            if params.params.isEmpty {
                Text("Waiting for parameters…").foregroundColor(.secondary)
            }
            ForEach(names, id: \.self) { ParamAutoRow(name: $0) }
            Section {
                EmptyView()
            } footer: {
                Text(footer)
            }
        }
    }
}

// MARK: - Battery monitor

/// REA Parity Source: MissionPlanner ConfigBatteryMonitoring.cs: monitor type, capacity, and the
/// "measured voltage" / "measured current" calibration that rescales BATT_VOLT_MULT / BATT_AMP_PERVLT.
struct BatteryPage: View {
    @EnvironmentObject var params: ParameterStore
    @EnvironmentObject var vehicle: VehicleModel
    @State private var measuredVolts = 0.0
    @State private var measuredAmps = 0.0
    @State private var note: String?

    var body: some View {
        Form {
            Section("Live") {
                LabeledContent("Voltage", value: String(format: "%.2f V", vehicle.batteryVoltage))
                LabeledContent("Current", value: String(format: "%.1f A", vehicle.batteryCurrent))
                LabeledContent("Remaining", value: vehicle.batteryRemaining >= 0 ? "\(vehicle.batteryRemaining) %" : "—")
                if let mah = vehicle.batteryConsumedMah { LabeledContent("Consumed", value: "\(mah) mAh") }
            }
            ParamAutoRow(name: "BATT_MONITOR")
            ParamAutoRow(name: "BATT_CAPACITY")
            ParamAutoRow(name: "BATT_ARM_VOLT")
            Section {
                HStack {
                    Text("Measured with a multimeter")
                    Spacer()
                    TextField("V", value: $measuredVolts, format: .number)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80)
                    Text("V")
                }
                Button("Calibrate voltage") { calibrateVolts() }
                    .disabled(measuredVolts <= 0 || vehicle.batteryVoltage <= 0 || params.params["BATT_VOLT_MULT"] == nil)
                HStack {
                    Text("Measured current")
                    Spacer()
                    TextField("A", value: $measuredAmps, format: .number)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80)
                    Text("A")
                }
                Button("Calibrate current") { calibrateAmps() }
                    .disabled(measuredAmps <= 0 || vehicle.batteryCurrent <= 0.2 || params.params["BATT_AMP_PERVLT"] == nil)
                if let n = note { Text(n).font(.caption) }
            } header: {
                Text("Calibration")
            } footer: {
                Text("Measure the battery voltage at the connector, enter it and tap Calibrate. The app rescales BATT_VOLT_MULT so the reading matches (current: BATT_AMP_PERVLT, under a steady load).")
            }
            ParamAutoRow(name: "BATT_VOLT_MULT")
            ParamAutoRow(name: "BATT_AMP_PERVLT")
            ParamAutoRow(name: "BATT_AMP_OFFSET")
        }
    }

    private func calibrateVolts() {
        guard let mult = params.params["BATT_VOLT_MULT"]?.value, vehicle.batteryVoltage > 0 else { return }
        let new = Double(mult) * measuredVolts / vehicle.batteryVoltage
        params.set("BATT_VOLT_MULT", Float(new))
        note = String(format: "BATT_VOLT_MULT %.4f → %.4f", mult, new)
    }

    private func calibrateAmps() {
        guard let per = params.params["BATT_AMP_PERVLT"]?.value, vehicle.batteryCurrent > 0 else { return }
        let new = Double(per) * measuredAmps / vehicle.batteryCurrent
        params.set("BATT_AMP_PERVLT", Float(new))
        note = String(format: "BATT_AMP_PERVLT %.3f → %.3f", per, new)
    }
}

// MARK: - DataFlash logs

struct LogsPage: View {
    @EnvironmentObject var logs: LogStore
    @EnvironmentObject var vehicle: VehicleModel
    @State private var confirmErase = false
    @State private var showReview = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Button { showReview = true } label: { Label("Review a downloaded log…", systemImage: "chart.xyaxis.line") }
                    Button { logs.refresh() } label: { Label("List logs on the vehicle", systemImage: "arrow.clockwise") }
                        .disabled(logs.listing || logs.downloading != nil)
                    if logs.listing { ProgressView() }
                }
                if let m = logs.message { Text(m).font(.callout) }
            } footer: {
                Text("Downloads .bin logs over MAVLink into Files › Mission Planner › logs › dataflash. Over ExpressLRS expect only a few kB/s (a 5 MB log takes 30+ minutes); over a Wi-Fi bridge it is much faster.")
            }
            if let d = logs.downloading {
                Section("Downloading log \(d.id)") {
                    ProgressView(value: Double(logs.received), total: Double(max(1, Int(d.size))))
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(logs.received), countStyle: .file)) of \(ByteCountFormatter.string(fromByteCount: Int64(d.size), countStyle: .file)) · \(String(format: "%.1f", logs.rate / 1024)) kB/s")
                        .font(.caption).monospacedDigit()
                    Button("Cancel", role: .destructive) { logs.cancel() }
                }
            }
            Section("Logs") {
                if logs.entries.isEmpty { Text("Tap List to read the log list").foregroundColor(.secondary) }
                ForEach(logs.entries) { e in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Log \(e.id)")
                            Text(e.date.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? "no date")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: Int64(e.size), countStyle: .file))
                            .foregroundColor(.secondary)
                        Button("Download") { logs.start(e) }
                            .disabled(logs.downloading != nil || vehicle.armed)
                    }
                }
            }
            Section {
                Button("Erase all logs on the vehicle", role: .destructive) { confirmErase = true }
                    .disabled(logs.entries.isEmpty || vehicle.armed)
            }
        }
        .sheet(isPresented: $showReview) { LogReviewPicker() }
        .onAppear {
            // Test automation only: -MPOpenLogReview YES opens the log review sheet.
            if UserDefaults.standard.bool(forKey: "MPOpenLogReview") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { showReview = true }
            }
        }
        .alert("Erase all logs?", isPresented: $confirmErase) {
            Button("Erase", role: .destructive) { logs.eraseAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Deletes every DataFlash log on the flight controller's SD card. This can't be undone.")
        }
    }
}