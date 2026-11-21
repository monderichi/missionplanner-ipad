// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Actions" tab (Set Mode combo +
// button, Arm/Disarm with confirmation, force disarm, reboot via MAV_CMD_PREFLIGHT_REBOOT_SHUTDOWN).

import MAVLinkKit
import SwiftUI

struct ActionsView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter

    @State private var selectedMode: UInt32 = 0
    @State private var confirmArm = false
    @State private var confirmDisarm = false
    @State private var confirmReboot = false

    struct ModeItem: Identifiable {
        let id: UInt32
        let name: String
    }

    private var modes: [ModeItem] {
        ArduPilotModes.table(for: MAVType(rawValue: vehicle.vehicleType))
            .sorted { $0.key < $1.key }
            .map { ModeItem(id: $0.key, name: $0.value) }
    }

    private var ready: Bool { commands.isAttached && vehicle.heartbeatAlive }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Flight mode") {
                HStack {
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(modes) { m in Text(m.name).tag(m.id) }
                    }
                    .pickerStyle(.menu)
                    Spacer()
                    Button("Set mode") {
                        let name = modes.first(where: { $0.id == selectedMode })?.name ?? "\(selectedMode)"
                        commands.setMode(selectedMode, name: name)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!ready || modes.isEmpty || commands.pending.contains(MAVCmd.doSetMode))
                }
                Text("Current: \(vehicle.modeName)").font(.caption).foregroundColor(.secondary)
            }

            GroupBox("Arming") {
                HStack(spacing: 12) {
                    Button {
                        confirmArm = true
                    } label: {
                        Label("Arm", systemImage: "bolt.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(!ready || vehicle.armed)

                    Button {
                        confirmDisarm = true
                    } label: {
                        Label("Disarm", systemImage: "bolt.slash.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!ready || !vehicle.armed)
                }
                Text(vehicle.armed ? "Motors ARMED" : "Disarmed")
                    .font(.caption).foregroundColor(vehicle.armed ? .red : .secondary)
            }

            GroupBox("Autopilot") {
                Button {
                    confirmReboot = true
                } label: {
                    Label("Reboot autopilot", systemImage: "power")
                }
                .disabled(!ready || vehicle.armed)
            }

            if let result = commands.lastResult {
                Label(result, systemImage: commands.lastResultOK ? "checkmark.circle" : "exclamationmark.triangle")
                    .foregroundColor(commands.lastResultOK ? .primary : .orange)
                    .font(.callout)
            }
            if !ready {
                Text("Connect to a vehicle to use these controls.").font(.caption).foregroundColor(.secondary)
            }
        }
        .onAppear { selectedMode = vehicle.customMode }
        .onChange(of: vehicle.customMode) { selectedMode = $0 }
        .alert("Arm motors?", isPresented: $confirmArm) {
            Button("Arm", role: .destructive) { commands.arm(true) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Propellers can start spinning. Make sure the area around the vehicle is clear and you can take control with the RC transmitter.")
        }
        .alert("Disarm motors?", isPresented: $confirmDisarm) {
            Button("Disarm") { commands.arm(false) }
            Button("Force disarm (emergency)", role: .destructive) { commands.arm(false, force: true) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Force disarm stops the motors even in flight: the vehicle will fall. Use it only in an emergency.")
        }
        .alert("Reboot autopilot?", isPresented: $confirmReboot) {
            Button("Reboot", role: .destructive) { commands.reboot() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The link drops for a few seconds while the flight controller restarts.")
        }
    }
}
