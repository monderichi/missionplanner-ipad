// REA Parity Source: MissionPlanner ArduSub configuration (Frame type, Joystick gains/buttons BTNx_FUNCTION,
// leak detector and failsafe parameters from ArduSub.json metadata).

import SwiftUI

struct SubSetupPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore

    var body: some View {
        Form {
            Section("Live") {
                LabeledContent("Depth", value: String(format: "%.2f m", vehicle.depth))
                LabeledContent("Water temperature",
                               value: vehicle.waterTemperature.map { String(format: "%.1f °C", $0) } ?? "—")
                HStack {
                    Text("Leak")
                    Spacer()
                    Text(vehicle.leakDetected ? "LEAK DETECTED" : "No leak reported")
                        .fontWeight(.semibold)
                        .foregroundColor(vehicle.leakDetected ? .red : .green)
                    if vehicle.leakDetected {
                        Button("Clear") { vehicle.clearLeak() }.buttonStyle(.bordered)
                    }
                }
            }
            Section("Frame") {
                ParamAutoRow(name: "FRAME_CONFIG")
            }
            Section("Joystick gains") {
                ForEach(["JS_GAIN_DEFAULT", "JS_GAIN_MAX", "JS_GAIN_MIN", "JS_GAIN_STEPS", "JS_THR_GAIN", "JS_LIGHTS_STEPS"],
                        id: \.self) { ParamAutoRow(name: $0) }
            }
            Section("Depth and speed") {
                ForEach(["SURFACE_DEPTH", "PILOT_SPEED_UP", "PILOT_SPEED_DN", "WPNAV_SPEED_DN"], id: \.self) { ParamAutoRow(name: $0) }
            }
            Section("Failsafes") {
                ForEach(["FS_LEAK_ENABLE", "FS_PRESS_ENABLE", "FS_PRESS_MAX", "FS_TEMP_ENABLE", "FS_TEMP_MAX",
                         "FS_PILOT_INPUT", "FS_PILOT_TIMEOUT", "FS_GCS_ENABLE", "FS_EKF_ACTION"],
                        id: \.self) { ParamAutoRow(name: $0) }
            }
            Section("Leak detectors") {
                ForEach(["LEAK1_PIN", "LEAK1_LOGIC", "LEAK2_PIN", "LEAK2_LOGIC", "LEAK3_PIN", "LEAK3_LOGIC"],
                        id: \.self) { ParamAutoRow(name: $0) }
            }
            Section("Buttons (short press)") {
                ForEach(0..<16, id: \.self) { ParamAutoRow(name: "BTN\($0)_FUNCTION") }
            }
            Section("Buttons (long press)") {
                ForEach(0..<16, id: \.self) { ParamAutoRow(name: "BTN\($0)_SFUNCTION") }
            }
            if params.params["FRAME_CONFIG"] == nil {
                Section {
                    Text("Download the parameters first (Params screen). Rows only appear for parameters this vehicle has.")
                        .font(.footnote).foregroundColor(.secondary)
                }
            }
        }
    }
}
