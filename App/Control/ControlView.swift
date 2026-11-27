// REA Parity Source: MissionPlanner Joystick/JoystickBase.cs + the Joystick setup screen (live axis bars,
// button indicators, enable switch); QGroundControl's ArduSub manual control.

import SwiftUI

struct ControlView: View {
    @EnvironmentObject var manual: ManualControl
    @EnvironmentObject var vehicle: VehicleModel

    private var kind: ManualControl.Kind { ManualControl.kind(vehicleType: vehicle.vehicleType) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if kind == .unsupported {
                Text("Manual control is available for ArduSub and ArduRover.")
                    .font(.callout).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
            } else {
                Toggle("Enable manual control", isOn: Binding(get: { manual.enabled }, set: { manual.setEnabled($0) }))
                    .disabled(!vehicle.heartbeatAlive)
                Text(manual.enabled
                        ? "Sending MANUAL_CONTROL at 10 Hz. Turns off by itself if the link drops."
                        : "Off. Nothing is sent until you enable it (every session).")
                    .font(.caption).foregroundColor(manual.enabled ? .orange : .secondary)
                if let pad = manual.gamepadName {
                    Toggle("Use game controller (\(pad))", isOn: $manual.useGamepad)
                }
                LabeledContent("Source", value: manual.usingGamepad ? (manual.gamepadName ?? "") : "On-screen sticks")
                HStack {
                    Text("Gain")
                    Slider(value: $manual.gain, in: 0.1...1.0)
                    Text(String(format: "%.0f%%", manual.gain * 100)).monospacedDigit().frame(width: 44, alignment: .trailing)
                }
                axisBars
                buttonsRow
                if !manual.usingGamepad {
                    HStack(spacing: 24) {
                        Spacer()
                        JoystickPad(value: $manual.leftStick, title: kind == .sub ? "Heave / yaw" : "Throttle")
                        JoystickPad(value: $manual.rightStick, title: kind == .sub ? "Forward / lateral" : "Steering")
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var axisBars: some View {
        let f = manual.frame
        return VStack(spacing: 6) {
            if kind == .sub {
                bar("X forward", Double(f.x) / 1000, "\(f.x)")
                bar("Y lateral", Double(f.y) / 1000, "\(f.y)")
                bar("Z heave", Double(f.z - 500) / 500, "\(f.z)")
                bar("R yaw", Double(f.r) / 1000, "\(f.r)")
            } else {
                bar("Z throttle", Double(f.z) / 1000, "\(f.z)")
                bar("Y steering", Double(f.y) / 1000, "\(f.y)")
            }
        }
    }

    private func bar(_ title: String, _ v: Double, _ text: String) -> some View {
        HStack {
            Text(title).font(.caption).frame(width: 78, alignment: .leading)
            GeometryReader { geo in
                let w: CGFloat = geo.size.width
                let clamped: CGFloat = CGFloat(max(-1, min(1, v)))
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color(.tertiarySystemFill))
                    RoundedRectangle(cornerRadius: 3).fill(Color.accentColor)
                        .frame(width: abs(clamped) * w / 2, height: geo.size.height)
                        .offset(x: clamped >= 0 ? w / 2 : w / 2 + clamped * w / 2)
                    Rectangle().fill(Color.secondary).frame(width: 1).offset(x: w / 2)
                }
            }
            .frame(height: 12)
            Text(text).font(.caption.monospacedDigit()).frame(width: 44, alignment: .trailing)
        }
    }

    private var buttonsRow: some View {
        let mask = manual.frame.buttons
        return HStack(spacing: 4) {
            Text("Buttons").font(.caption).frame(width: 78, alignment: .leading)
            ForEach(0..<16, id: \.self) { b in
                let on = ((mask >> UInt16(b)) & 1) == 1
                Text("\(b)").font(.system(size: 10, weight: .bold).monospacedDigit())
                    .frame(width: 20, height: 20)
                    .background(on ? Color.accentColor : Color(.tertiarySystemFill), in: Circle())
                    .foregroundColor(on ? .white : .secondary)
            }
        }
    }
}
