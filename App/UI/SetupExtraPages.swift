// REA Parity Source: MissionPlanner GCSViews/ConfigurationView/ConfigServoOutput.cs (Servo Output),
// ConfigPlanner.cs (Planner settings) and ConfigAccelerometerCalibration.cs / ConfigHWCompass2.cs
// (gyro, barometer, airspeed calibration).

import MAVLinkKit
import SwiftUI

// MARK: - Servo output

struct ServoPage: View {
    @EnvironmentObject var params: ParameterStore

    private var outputs: [Int] { (1...16).filter { params.params["SERVO\($0)_FUNCTION"] != nil } }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if params.params.isEmpty {
                    Text("Waiting for parameters…").foregroundColor(.secondary)
                } else if outputs.isEmpty {
                    Text("No SERVOn_FUNCTION parameters on this vehicle.").foregroundColor(.secondary)
                }
                ForEach(outputs, id: \.self) { n in
                    ServoRow(index: n)
                }
                Text("Function, Min, Trim and Max are written when you press Return. Reverse is written immediately. Output function changes need a reboot to take effect on some firmware.")
                    .font(.footnote).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
            }
            .padding(12)
        }
    }
}

struct ServoRow: View {
    @EnvironmentObject var params: ParameterStore
    @EnvironmentObject var vehicle: VehicleModel
    let index: Int

    private var pwm: Int {
        let i = index - 1
        return i >= 0 && i < vehicle.servoOutputs.count ? Int(vehicle.servoOutputs[i]) : 0
    }

    var body: some View {
        let fn = "SERVO\(index)_FUNCTION"
        let rev = "SERVO\(index)_REVERSED"
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("OUT \(index)").font(.headline).frame(width: 64, alignment: .leading)
                ProgressView(value: Double(min(max(pwm, 800), 2200) - 800), total: 1400)
                Text(pwm == 0 ? "—" : "\(pwm)").monospacedDigit().frame(width: 52, alignment: .trailing)
            }
            HStack(spacing: 12) {
                if let p = params.params[fn] {
                    let values = params.metadata[fn]?.values ?? []
                    if values.isEmpty {
                        Text("Function \(ParamFile.formatValue(p.value))").frame(minWidth: 140, alignment: .leading)
                    } else {
                        Picker(fn, selection: Binding(get: { Double(p.value) }, set: { params.set(fn, Float($0)) })) {
                            ForEach(values) { o in Text("\(Int(o.code)): \(o.label)").tag(o.code) }
                            if params.metadata[fn]?.label(for: p.value) == nil {
                                Text("\(ParamFile.formatValue(p.value))").tag(Double(p.value))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(minWidth: 170, alignment: .leading)
                    }
                    if params.pendingNames.contains(fn) { ProgressView() }
                }
                Spacer()
                ServoNumberField(name: "SERVO\(index)_MIN", caption: "Min")
                ServoNumberField(name: "SERVO\(index)_TRIM", caption: "Trim")
                ServoNumberField(name: "SERVO\(index)_MAX", caption: "Max")
                if let r = params.params[rev] {
                    Toggle("Rev", isOn: Binding(get: { r.value != 0 }, set: { params.set(rev, $0 ? 1 : 0) }))
                        .labelsHidden()
                    Text("Rev").font(.caption)
                    if params.pendingNames.contains(rev) { ProgressView() }
                }
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.10))
        .cornerRadius(10)
    }
}

/// Compact numeric field that writes on Return.
struct ServoNumberField: View {
    @EnvironmentObject var params: ParameterStore
    let name: String
    let caption: String
    @State private var text = ""

    var body: some View {
        if let p = params.params[name] {
            VStack(spacing: 2) {
                Text(caption).font(.caption2).foregroundColor(.secondary)
                HStack(spacing: 2) {
                    TextField(name, text: $text)
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 62)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { write(p.value) }
                    if params.pendingNames.contains(name) { ProgressView().scaleEffect(0.6) }
                }
            }
            .onAppear { text = ParamFile.formatValue(p.value) }
            .onChange(of: p.value) { text = ParamFile.formatValue($0) }
        }
    }

    private func write(_ current: Float) {
        let t = text.replacingOccurrences(of: ",", with: ".")
        if let v = Float(t), v.isFinite, v != current {
            params.set(name, v)
        } else {
            text = ParamFile.formatValue(current)
        }
    }
}

// MARK: - Other calibrations (gyro, barometer, airspeed)

struct OtherCalPage: View {
    @EnvironmentObject var calibration: CalibrationStore
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore

    private var hasAirspeed: Bool { (params.params["ARSPD_TYPE"]?.value ?? 0) != 0 }

    var body: some View {
        Form {
            Section {
                Button { calibration.calibrateGyro() } label: { Label("Calibrate gyros", systemImage: "gyroscope") }
                    .disabled(vehicle.armed)
            } header: {
                Text("Gyroscopes")
            } footer: {
                Text("Keep the vehicle completely still while the gyros calibrate (a few seconds).")
            }
            Section {
                Button { calibration.calibrateBaro() } label: { Label("Calibrate barometer", systemImage: "barometer") }
                    .disabled(vehicle.armed)
            } header: {
                Text("Barometer")
            } footer: {
                Text("Resets the ground pressure reference to the current pressure. Do it on the ground, before arming.")
            }
            if hasAirspeed {
                Section {
                    Button { calibration.calibrateAirspeed() } label: { Label("Calibrate airspeed", systemImage: "wind") }
                        .disabled(vehicle.armed)
                } header: {
                    Text("Airspeed")
                } footer: {
                    Text("Cover the pitot tube from the wind first. This re-zeros the airspeed sensor offset.")
                }
            }
            Section("Latest messages") {
                ForEach(vehicle.messages.prefix(6)) { m in Text(m.text).font(.callout) }
            }
        }
    }
}

// MARK: - Large-vehicle compass calibration

struct FixedYawCalSection: View {
    @EnvironmentObject var calibration: CalibrationStore
    @EnvironmentObject var vehicle: VehicleModel
    @State private var heading = 0.0

    var body: some View {
        Section {
            Text("For vehicles too big to rotate. Point the vehicle at a known true heading (for example aligned with a road or runway on the map), enter that heading and tap Calibrate. Needs a GPS position and the vehicle disarmed.")
            HStack {
                Text("True heading")
                Spacer()
                TextField("deg", value: $heading, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                Text("°")
                Button("Use current") { heading = vehicle.yaw }
            }
            Button {
                calibration.calibrateFixedYaw(heading: Float(heading))
            } label: {
                Label("Calibrate at this heading", systemImage: "location.north.line")
            }
            .disabled(vehicle.armed || vehicle.position == nil || heading < 0 || heading >= 360)
        } header: {
            Text("Large-vehicle compass calibration")
        } footer: {
            Text("The current compass heading is only a starting point: it is wrong before calibration, so type the real heading. Reboot after a successful calibration.")
        }
        .onAppear { heading = (vehicle.yaw * 10).rounded() / 10 }
    }
}

// MARK: - Planner settings

struct PlannerSettingsPage: View {
    @ObservedObject private var settings = PlannerSettings.shared
    @EnvironmentObject var speech: SpeechAlerts
    @EnvironmentObject var commands: CommandCenter

    var body: some View {
        Form {
            Section {
                Picker("Distance", selection: $settings.distanceUnit) {
                    ForEach(PlannerSettings.DistanceUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Speed", selection: $settings.speedUnit) {
                    ForEach(PlannerSettings.SpeedUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Altitude", selection: $settings.altitudeUnit) {
                    ForEach(PlannerSettings.AltitudeUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                LabeledContent("Preview", value: "\(settings.distance(1500)) · \(settings.speed(10)) · \(settings.altitude(100))")
            } header: {
                Text("Units")
            } footer: {
                Text("Parameters and setup values are always written in the vehicle's own units.")
            }
            Section {
                Toggle("Voice alerts", isOn: $speech.enabled) // same switch as the speaker icon in the top bar
                Toggle("Keep screen awake while connected", isOn: $settings.keepScreenAwake)
            } header: {
                Text("Behaviour")
            }
        }
        .onAppear { settings.setConnected(commands.isAttached) }
        .onChange(of: commands.isAttached) { settings.setConnected($0) }
    }
}
