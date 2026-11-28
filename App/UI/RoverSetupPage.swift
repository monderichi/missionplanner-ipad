// REA Parity Source: MissionPlanner ConfigurationView/ConfigFrameType.cs and ConfigMotorTest.cs for ArduRover:
// FRAME_CLASS / FRAME_TYPE, which SERVOn_FUNCTION carries steering (26) and throttle (70, or 73/74 for skid steer),
// and the MOT_* output settings. Wheel-direction check list from the ArduPilot Rover "first drive" wiki page.

import MAVLinkKit
import SwiftUI

struct RoverSetupPage: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore

    /// SERVOn_FUNCTION values that matter for driving.
    private static let functionNames: [Int: String] = [
        26: "Ground steering", 70: "Throttle", 73: "Throttle left (skid steer)", 74: "Throttle right (skid steer)",
    ]

    private struct DriveOutput: Identifiable {
        let index: Int
        let function: Int
        var id: Int { index }
    }

    private var driveOutputs: [DriveOutput] {
        (1...16).compactMap { n in
            guard let f = params.params["SERVO\(n)_FUNCTION"]?.value else { return nil }
            guard f.isFinite else { return nil } // BUG-005: a non-finite parameter value must not trap
            let fn = Int(f.rounded())
            return RoverSetupPage.functionNames[fn] != nil ? DriveOutput(index: n, function: fn) : nil
        }
    }

    private func pwm(_ index: Int) -> Int {
        let i = index - 1
        return i >= 0 && i < vehicle.servoOutputs.count ? Int(vehicle.servoOutputs[i]) : 0
    }

    private func reversed(_ index: Int) -> Bool {
        (params.params["SERVO\(index)_REVERSED"]?.value ?? 0) != 0
    }

    var body: some View {
        Form {
            if params.params.isEmpty {
                Text("Waiting for parameters…").foregroundColor(.secondary)
            }
            ParamOptionRow(name: "FRAME_CLASS")
            ParamOptionRow(name: "FRAME_TYPE")
            Section {
                if driveOutputs.isEmpty {
                    Text(params.params.isEmpty
                         ? "Waiting for parameters…"
                         : "No output is set to Ground steering (26) or Throttle (70 / 73 / 74). Set SERVOn_FUNCTION on the Servo output page.")
                        .foregroundColor(.orange)
                }
                ForEach(driveOutputs) { o in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("OUT \(o.index)").font(.headline).frame(width: 64, alignment: .leading)
                            Text("\(RoverSetupPage.functionNames[o.function] ?? "Function \(o.function)")\(reversed(o.index) ? " · reversed" : "")")
                            Spacer()
                            Text(pwm(o.index) == 0 ? "—" : "\(pwm(o.index)) µs").monospacedDigit()
                        }
                        ProgressView(value: Double(min(max(pwm(o.index), 800), 2200) - 800), total: 1400)
                    }
                }
            } header: {
                Text("Steering & throttle outputs (live PWM)")
            } footer: {
                Text("Steering is function 26, throttle is 70. A skid-steer (tank) vehicle uses 73 (left) and 74 (right) instead and no steering output.")
            }
            ParamAutoRow(name: "MOT_PWM_TYPE")
            ParamAutoRow(name: "MOT_THR_MIN")
            ParamAutoRow(name: "MOT_THR_MAX")
            Section("Check before the first drive") {
                Text("Wheels off the ground, vehicle disarmed. Arm it (the safety switch must be pressed, if fitted) in MANUAL mode.")
                Text("Steering: in MANUAL, move the steering stick right. The wheels (or rudder) must turn right. If not, toggle SERVOn_REVERSED on the steering output (Servo output page).")
                Text("Throttle: push the throttle stick forward. The wheels must turn forward. If not, toggle SERVOn_REVERSED on the throttle output, or swap two motor wires.")
                Text("Skid steer: stick right must make the left wheel go forward and the right wheel backward. Fix each side with SERVOn_REVERSED on outputs 73 / 74.")
                Text("Use Motor test (Setup) to spin Throttle and Steering individually, then calibrate the radio and set the failsafe before driving.")
            }
            Section {
                EmptyView()
            } footer: {
                Text("FRAME_CLASS and FRAME_TYPE need a reboot to take effect (Parameters › Reboot).")
            }
        }
    }
}
