// More Flight Data tabs from Mission Planner: Preflight checklist (checklistDefault.xml),
// Servo/Relay (FlightData.cs "Servo" tab: Low/Mid/High/Toggle via MAV_CMD_DO_SET_SERVO, relays via
// MAV_CMD_DO_SET_RELAY), and ESC/battery details for the Status tab.

import MAVLinkKit
import SwiftUI

// MARK: - Preflight checklist

/// REA Parity Source: Mission Planner checklistDefault.xml (GPS fix >= 3, sats >= 5, telemetry
/// signal > 95%, battery voltage, mode, altitude < 5 m) plus the manual items.
struct ChecklistView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var link: LinkManager
    @EnvironmentObject var params: ParameterStore
    @AppStorage("checklist.minVolts") private var minVolts = 0.0
    @State private var ticked: Set<String> = []

    static let manualItems = [
        "Propellers secure and undamaged",
        "Frame, arms and payload secured",
        "Battery strapped down, connectors checked",
        "Compass/GPS clear of the battery wires",
        "Transmitter on, failsafe tested",
        "Flight area clear, home position correct",
    ]

    private var linkQuality: Double {
        let s = link.stats
        let total = s.packetsReceived + s.packetsLost
        return total > 0 ? 100 * Double(s.packetsReceived) / Double(total) : 0
    }

    /// Battery threshold: the user's value, else BATT_ARM_VOLT / BATT_LOW_VOLT from the vehicle.
    private var batteryThreshold: Double {
        if minVolts > 0 { return minVolts }
        let arm = Double(params.params["BATT_ARM_VOLT"]?.value ?? 0)
        let low = Double(params.params["BATT_LOW_VOLT"]?.value ?? 0)
        return max(arm, low)
    }

    var body: some View {
        List {
            Section("Automatic") {
                auto("GPS fix", value: vehicle.gpsFixName, ok: vehicle.gpsFixType >= 3)
                auto("Satellites", value: "\(vehicle.satellites)", ok: vehicle.satellites >= 5)
                auto("Telemetry signal", value: String(format: "%.0f %%", linkQuality), ok: linkQuality > 95)
                auto("Battery", value: String(format: "%.2f V (min %.1f)", vehicle.batteryVoltage, batteryThreshold),
                     ok: batteryThreshold > 0 ? vehicle.batteryVoltage > batteryThreshold : vehicle.batteryVoltage > 0)
                auto("Mode", value: vehicle.modeName, ok: nil)
                auto("Altitude", value: String(format: "%.1f m (< 5 m)", vehicle.relativeAltitude), ok: abs(vehicle.relativeAltitude) < 5)
                auto("EKF", value: vehicle.ekfVariances.allSatisfy({ $0 < 0.8 }) ? "OK" : "High variance",
                     ok: vehicle.ekfVariances.allSatisfy { $0 < 0.8 })
                auto("Pre-arm", value: vehicle.sensorsHealthy & (1 << 28) != 0 ? "Passing" : "Not passing",
                     ok: vehicle.sensorsPresent & (1 << 28) == 0 ? nil : vehicle.sensorsHealthy & (1 << 28) != 0)
            }
            Section {
                ForEach(Self.manualItems, id: \.self) { item in
                    Button {
                        if ticked.contains(item) { ticked.remove(item) } else { ticked.insert(item) }
                    } label: {
                        Label(item, systemImage: ticked.contains(item) ? "checkmark.square.fill" : "square")
                            .foregroundColor(ticked.contains(item) ? .green : .primary)
                    }
                }
                Button("Reset checklist") { ticked = [] }
            } header: {
                Text("Manual")
            }
            Section {
                HStack {
                    Text("Minimum battery voltage")
                    Spacer()
                    TextField("auto", value: $minVolts, format: .number)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 70)
                    Text("V")
                }
            } footer: {
                Text("0 = use BATT_ARM_VOLT / BATT_LOW_VOLT from the vehicle.")
            }
        }
        .listStyle(.insetGrouped)
    }

    private func auto(_ title: String, value: String, ok: Bool?) -> some View {
        HStack {
            Image(systemName: ok == nil ? "info.circle" : (ok! ? "checkmark.circle.fill" : "xmark.circle.fill"))
                .foregroundColor(ok == nil ? .secondary : (ok! ? .green : .red))
            Text(title)
            Spacer()
            Text(value).foregroundColor(.secondary).monospacedDigit()
        }
    }
}

// MARK: - Servo / relay

struct ServoView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter
    @EnvironmentObject var params: ParameterStore
    @State private var toggled: Set<Int> = []
    @State private var relays: Set<Int> = []

    private var channels: Int {
        let used = vehicle.servoOutputs.lastIndex(where: { $0 > 0 }).map { $0 + 1 } ?? 8
        return max(8, used)
    }

    private func pwm(_ ch: Int, _ suffix: String, _ fallback: Float) -> Float {
        params.params["SERVO\(ch)_\(suffix)"]?.value ?? fallback
    }

    private func set(_ ch: Int, _ value: Float) {
        commands.command(183, params: [Float(ch), value], label: "Servo \(ch) → \(Int(value))") // MAV_CMD_DO_SET_SERVO
    }

    private func function(_ ch: Int) -> String? {
        guard let p = params.params["SERVO\(ch)_FUNCTION"] else { return nil }
        return params.metadata["SERVO\(ch)_FUNCTION"]?.label(for: p.value) ?? "Function \(Int(p.value))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overriding an output that drives a motor can spin it. Only use outputs set to a servo, relay or RCPassThru function.")
                .font(.caption).foregroundColor(.orange)
            ForEach(1...channels, id: \.self) { ch in
                let out = vehicle.servoOutputs[safe: ch - 1] ?? 0
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Out \(ch)").font(.callout.bold()).frame(width: 56, alignment: .leading)
                        ProgressView(value: Double(min(max(Int(out), 800), 2200) - 800), total: 1400)
                        Text(verbatim: out > 0 ? String(out) : "—") /* BUG-036 */.monospacedDigit().frame(width: 44, alignment: .trailing)
                    }
                    HStack {
                        Text(function(ch) ?? "").font(.caption2).foregroundColor(.secondary).lineLimit(1)
                        Spacer()
                        Button("Low") { set(ch, pwm(ch, "MIN", 1100)) }
                        Button("Mid") { set(ch, pwm(ch, "TRIM", 1500)) }
                        Button("High") { set(ch, pwm(ch, "MAX", 1900)) }
                        Button("Toggle") {
                            let high = !toggled.contains(ch)
                            if high { toggled.insert(ch) } else { toggled.remove(ch) }
                            set(ch, high ? pwm(ch, "MAX", 1900) : pwm(ch, "MIN", 1100))
                        }
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .disabled(!commands.isAttached || isMotor(ch))
                }
            }
            Divider()
            Text("Relays").font(.headline)
            HStack {
                ForEach(0..<4, id: \.self) { r in
                    Button("Relay \(r) \(relays.contains(r) ? "ON" : "OFF")") {
                        let on = !relays.contains(r)
                        if on { relays.insert(r) } else { relays.remove(r) }
                        commands.command(181, params: [Float(r), on ? 1 : 0], label: "Relay \(r) \(on ? "on" : "off")")
                    }
                    .buttonStyle(.bordered)
                    .tint(relays.contains(r) ? .green : .accentColor)
                    .disabled(!commands.isAttached)
                }
            }
        }
    }

    /// SERVOn_FUNCTION 33..40 = Motor1..8, 82..85 = Motor9..12: never offer overrides on those.
    private func isMotor(_ ch: Int) -> Bool {
        // BUG-014: unknown (parameters not downloaded yet) counts as a motor: block until we know.
        guard let f = params.params["SERVO\(ch)_FUNCTION"]?.value else { return true }
        guard f.isFinite else { return true }
        let fn = Int(f.rounded())
        return (33...40).contains(fn) || (82...85).contains(fn)
    }
}

// MARK: - ESC / battery details (Status tab)

struct ESCStatusSection: View {
    @EnvironmentObject var vehicle: VehicleModel

    var body: some View {
        if vehicle.escCount > 0 {
            Section("ESC telemetry") {
                ForEach(0..<vehicle.escCount, id: \.self) { i in
                    let e = vehicle.escs[i]
                    if e.rpm > 0 || e.temperature > 0 || e.voltage > 0 {
                        HStack {
                            Text("Motor \(i + 1)")
                            Spacer()
                            Text(verbatim: "\(e.rpm) rpm · \(e.temperature) °C · \(String(format: "%.1f V %.1f A", e.voltage, e.current))") // BUG-036
                                .foregroundColor(e.temperature > 80 ? .red : .secondary).monospacedDigit()
                        }
                    }
                }
            }
        }
        if vehicle.batteryConsumedMah != nil || !vehicle.cellVoltages.isEmpty {
            Section("Battery details") {
                if let mah = vehicle.batteryConsumedMah {
                    HStack { Text("Consumed"); Spacer(); Text("\(mah) mAh").foregroundColor(.secondary) }
                }
                if !vehicle.cellVoltages.isEmpty {
                    HStack {
                        Text("Cells")
                        Spacer()
                        Text(vehicle.cellVoltages.map { String(format: "%.2f", $0) }.joined(separator: " / "))
                            .foregroundColor(.secondary).monospacedDigit()
                    }
                }
            }
        }
    }
}
