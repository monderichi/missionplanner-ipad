// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Actions" tab: mode buttons (Auto,
// Loiter, RTL...), Set Mode combo, Arm/Disarm (+ force), Takeoff (MAV_CMD_NAV_TAKEOFF in GUIDED),
// Change Speed (MAV_CMD_DO_CHANGE_SPEED), Change Alt (guided WP at the current position),
// Restart Mission (MISSION_SET_CURRENT 1), Set Home Here (MAV_CMD_DO_SET_HOME), reboot.

import MAVLinkKit
import SwiftUI

struct ActionsView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter
    @EnvironmentObject var mission: MissionStore

    @State private var selectedMode: UInt32 = 0
    @State private var confirmArm = false
    @State private var confirmDisarm = false
    @State private var confirmReboot = false
    @State private var confirmTakeoff = false
    @State private var confirmHome = false
    @AppStorage("actions.takeoffAlt") private var takeoffAlt = 10.0
    @AppStorage("actions.speed") private var speed = 5.0
    @AppStorage("actions.alt") private var newAlt = 30.0

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
    private var isCopter: Bool { MAVType(rawValue: vehicle.vehicleType)?.firmware == .copter }
    private var guidedMode: UInt32? { ArduPilotModes.guided(for: vehicle.vehicleType) }
    private var inGuided: Bool { guidedMode == vehicle.customMode }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Flight mode") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 92))], spacing: 8) {
                    ForEach(ArduPilotModes.quickModes(for: vehicle.vehicleType), id: \.self) { m in
                        let name = ArduPilotModes.name(customMode: m, vehicleType: vehicle.vehicleType)
                        Button(name) { commands.setMode(m, name: name) }
                            .buttonStyle(.bordered)
                            .tint(vehicle.customMode == m ? .green : .accentColor)
                            .disabled(!ready)
                    }
                }
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
                    Button { confirmArm = true } label: {
                        Label("Arm", systemImage: "bolt.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(!ready || vehicle.armed)

                    Button { confirmDisarm = true } label: {
                        Label("Disarm", systemImage: "bolt.slash.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!ready || !vehicle.armed)
                }
                Text(vehicle.armed ? "Motors ARMED" : "Disarmed")
                    .font(.caption).foregroundColor(vehicle.armed ? .red : .secondary)
            }

            if isCopter {
                GroupBox("Guided takeoff") {
                    HStack {
                        Text("Altitude")
                        TextField("m", value: $takeoffAlt, format: .number)
                            .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 70)
                        Text("m")
                        Spacer()
                        Button("Takeoff") { confirmTakeoff = true }
                            .buttonStyle(.borderedProminent)
                            .disabled(!ready || !vehicle.armed || !inGuided || takeoffAlt < 1)
                    }
                    Text("Switch to Guided and arm first, then Takeoff (Mission Planner does the same).")
                        .font(.caption).foregroundColor(.secondary)
                }
            }

            GroupBox("In flight") {
                HStack {
                    Text("Speed")
                    TextField("m/s", value: $speed, format: .number)
                        .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 70)
                    Text("m/s")
                    Spacer()
                    Button("Change speed") {
                        commands.command(MissionCmd.doChangeSpeed, params: [1, Float(speed), -1, 0],
                                         label: "Change speed to \(Int(speed)) m/s")
                    }
                    .disabled(!ready || speed <= 0)
                }
                HStack {
                    Text("Altitude")
                    TextField("m", value: $newAlt, format: .number)
                        .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 70)
                    Text("m")
                    Spacer()
                    Button("Change altitude") {
                        if let p = vehicle.position { mission.guidedGoTo(p, altitude: Float(newAlt)) }
                    }
                    .disabled(!ready || !inGuided || vehicle.position == nil)
                }
                HStack {
                    Button("Restart mission") { mission.setCurrent(1) }
                        .disabled(!ready)
                    Spacer()
                    Button("Set home here") { confirmHome = true }
                        .disabled(!ready || vehicle.position == nil)
                }
                Text("Change altitude works in Guided. Long-press the map to fly to a point.")
                    .font(.caption).foregroundColor(.secondary)
            }

            GroupBox("Autopilot") {
                Button { confirmReboot = true } label: { Label("Reboot autopilot", systemImage: "power") }
                    .disabled(!ready || vehicle.armed)
            }

            GimbalView()

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
        .alert("Take off to \(Int(takeoffAlt)) m?", isPresented: $confirmTakeoff) {
            Button("Take off", role: .destructive) {
                commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, Float(takeoffAlt)],
                                 label: "Takeoff to \(Int(takeoffAlt)) m")
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The vehicle climbs vertically and holds position in Guided.")
        }
        .alert("Set home to the current position?", isPresented: $confirmHome) {
            Button("Set home") {
                commands.command(179, params: [1], label: "Set home")  // MAV_CMD_DO_SET_HOME, use current
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { commands.requestMessage(242) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("RTL will return here. Relative altitudes are measured from the new home.")
        }
        .alert("Reboot autopilot?", isPresented: $confirmReboot) {
            Button("Reboot", role: .destructive) { commands.reboot() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The link drops for a few seconds while the flight controller restarts.")
        }
    }
}
