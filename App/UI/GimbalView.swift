// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Payload Control" tab (gimbal pitch/yaw
// via MAV_CMD_DO_MOUNT_CONTROL, camera shutter via MAV_CMD_DO_DIGICAM_CONTROL, video record).

import MAVLinkKit
import SwiftUI

struct GimbalView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter

    @State private var pitch: Double = 0
    @State private var yaw: Double = 0
    @State private var recording = false

    private var ready: Bool { commands.isAttached && vehicle.heartbeatAlive }

    var body: some View {
        GroupBox("Camera / gimbal") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Pitch")
                    Slider(value: $pitch, in: -90...30, step: 1, onEditingChanged: { editing in
                        if !editing { sendAngles() }
                    })
                    Text("\(Int(pitch))°").monospacedDigit().frame(width: 52, alignment: .trailing)
                }
                HStack {
                    Text("Yaw")
                    Slider(value: $yaw, in: -180...180, step: 1, onEditingChanged: { editing in
                        if !editing { sendAngles() }
                    })
                    Text("\(Int(yaw))°").monospacedDigit().frame(width: 52, alignment: .trailing)
                }
                HStack {
                    Button("Centre") {
                        pitch = 0
                        yaw = 0
                        sendAngles()
                    }
                    Button("Look down") {
                        pitch = -90
                        sendAngles()
                    }
                    Spacer()
                    Button {
                        // MAV_CMD_DO_DIGICAM_CONTROL: param5 = 1 shoots
                        commands.command(203, params: [0, 0, 0, 0, 1, 0, 0], label: "Take photo")
                    } label: { Label("Take photo", systemImage: "camera") }
                    Button {
                        if recording {
                            // MAV_CMD_VIDEO_STOP_CAPTURE, param1 = stream id 0
                            commands.command(2501, params: [0], label: "Stop video")
                        } else {
                            // MAV_CMD_VIDEO_START_CAPTURE, param1 = stream id 0, param2 = status frequency 0
                            commands.command(2500, params: [0, 0], label: "Start video")
                        }
                        recording.toggle()
                    } label: {
                        Label(recording ? "Stop video" : "Start video", systemImage: recording ? "stop.circle" : "video")
                    }
                    .tint(recording ? .red : .accentColor)
                }
                .buttonStyle(.bordered)
                .disabled(!ready)
                Text("Angles are sent when you release a slider. Long-press the map and choose Point camera here to set a region of interest.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    /// MAV_CMD_DO_MOUNT_CONTROL: p1 pitch, p2 roll, p3 yaw, p7 mode 2 = MAV_MOUNT_MODE_MAVLINK_TARGETING.
    private func sendAngles() {
        guard ready else { return }
        commands.command(205, params: [Float(pitch), 0, Float(yaw), 0, 0, 0, 2],
                         label: "Gimbal pitch \(Int(pitch))° yaw \(Int(yaw))°")
    }
}
