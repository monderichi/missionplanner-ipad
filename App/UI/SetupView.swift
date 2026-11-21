// REA Parity Source: MissionPlanner GCSViews/InitialSetup.cs + ConfigurationView/*:
// ConfigFrameType, ConfigAccelerometerCalibration, ConfigHWCompass2 (onboard mag cal),
// ConfigRadioInput (radio calibration -> RCn_MIN/MAX/TRIM), ConfigFlightModes (FLTMODE1..6 /
// MODE1..6 on FLTMODE_CH / MODE_CH), ConfigMotorTest, and the pre-arm / sensor status.

import MAVLinkKit
import SwiftUI

enum SetupPage: String, CaseIterable, Identifiable {
    case prearm = "Pre-arm & sensors"
    case frame = "Frame type"
    case accel = "Accelerometer"
    case compass = "Compass"
    case radio = "Radio calibration"
    case modes = "Flight modes"
    case motors = "Motor test"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .prearm: return "checklist"
        case .frame: return "airplane"
        case .accel: return "gyroscope"
        case .compass: return "location.north.circle"
        case .radio: return "dot.radiowaves.left.and.right"
        case .modes: return "switch.2"
        case .motors: return "fanblades"
        }
    }
}

struct SetupView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter
    @State private var page = SetupPage.prearm

    var body: some View {
        HStack(spacing: 0) {
            List {
                ForEach(SetupPage.allCases) { p in
                    Button {
                        page = p
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
                if !commands.isAttached {
                    Text("Connect to a vehicle to use Setup.").foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch page {
                    case .prearm: PrearmPage()
                    case .frame: FramePage()
                    case .accel: AccelPage()
                    case .compass: CompassPage()
                    case .radio: RadioPage()
                    case .modes: FlightModesPage()
                    case .motors: MotorTestPage()
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
                .pickerStyle(.navigationLink)
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
            let trim = ch == throttleCh ? mins[i] : min(max(cur, mins[i]), maxs[i])
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

    private var motorCount: Int {
        switch Int(params.params["FRAME_CLASS"]?.value ?? 1) {
        case 2, 5: return 6
        case 3, 4: return 8
        case 7: return 3
        case 10: return 2
        case 12: return 12
        case 14: return 10
        default: return 4
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle("I have REMOVED THE PROPELLERS", isOn: $propsOff)
                    .tint(.red)
            } footer: {
                Text("Motors spin during this test. Never test with propellers fitted.")
            }
            Section("Settings") {
                HStack {
                    Text("Throttle")
                    Slider(value: $throttle, in: 1...30, step: 1)
                    Text("\(Int(throttle)) %").monospacedDigit().frame(width: 50)
                }
                HStack {
                    Text("Duration")
                    Slider(value: $duration, in: 1...5, step: 0.5)
                    Text(String(format: "%.1f s", duration)).monospacedDigit().frame(width: 50)
                }
            }
            Section("Motors (test order A, B, C… as in the ArduPilot frame diagrams)") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(1...motorCount, id: \.self) { m in
                        Button(CalibrationStore.motorLetter(m)) {
                            calibration.motorTest(motor: m, throttle: Float(throttle), duration: Float(duration))
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title3.bold())
                    }
                }
                .padding(.vertical, 6)
                Button("Test all motors in sequence") {
                    calibration.motorTest(motor: 1, throttle: Float(throttle), duration: Float(duration), count: motorCount)
                }
            }
            .disabled(!propsOff || vehicle.armed)
        }
    }
}
