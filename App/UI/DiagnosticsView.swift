// Diagnostics for testers: build stamp, link and vehicle state, heartbeat sources, message rates,
// recent messages, and one-tap sharing of the latest .tlog and a plain-text report
// (attach both to feedback; tools/mavlink_ref.py and the tlog analyser read them on the PC).

import MAVLinkKit
import SwiftUI
import UIKit

struct DiagnosticsView: View {
    @EnvironmentObject var link: LinkManager
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var params: ParameterStore
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [URL] = []

    static var appVersion: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let v = info["CFBundleShortVersionString"] as? String ?? "?"
        let b = info["CFBundleVersion"] as? String ?? "?"
        let c = (info["GitCommit"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "local"
        return "\(v) (build \(b), \(c))"
    }

    var report: String {
        var s = "Mission Planner iPad diagnostics\n"
        s += "Date: \(Date().formatted(date: .numeric, time: .standard))\n"
        s += "App: \(Self.appVersion)\n"
        s += "iPad: \(UIDevice.current.model), iPadOS \(UIDevice.current.systemVersion)\n"
        s += "Link: \(link.state.description)\n"
        if let b = link.backpackInfo { s += "Backpack: \(b.summary)\n" }
        let st = link.stats
        s += "Packets: \(st.packetsReceived) received, \(st.packetsLost) lost, \(st.crcErrors) CRC errors, \(link.bytesReceived) bytes\n"
        s += "Vehicle: \(vehicle.systemID.map { "sys \($0)" } ?? "none") comp \(vehicle.componentID), \(vehicle.vehicleTypeName), mode \(vehicle.modeName), \(vehicle.armed ? "ARMED" : "disarmed")\n"
        s += "Heartbeat alive: \(vehicle.heartbeatAlive), attitude stale: \(vehicle.attitudeStale)\n"
        s += String(format: "Attitude: roll %.1f pitch %.1f yaw %.1f\n", vehicle.roll, vehicle.pitch, vehicle.yaw)
        s += "GPS: \(vehicle.gpsFixName), \(vehicle.satellites) sats; battery \(String(format: "%.2f", vehicle.batteryVoltage)) V\n"
        s += "Parameters: \(params.params.count) (\(params.firmware ?? "?"))\n"
        s += "Heartbeat sources:\n"
        for (k, v) in vehicle.heartbeatSources.sorted(by: { $0.key < $1.key }) { s += "  \(k): \(v)\n" }
        s += "Messages received:\n"
        for (k, v) in vehicle.messageCounts.sorted(by: { $0.value > $1.value }).prefix(40) { s += "  \(k): \(v)\n" }
        s += "Recent STATUSTEXT:\n"
        for m in vehicle.messages.prefix(25) { s += "  [\(m.severity.label)] \(m.text)\n" }
        return s
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Send feedback") {
                    ShareLink(item: report) { Label("Share diagnostics report (text)", systemImage: "doc.text") }
                    if let latest = logs.first {
                        ShareLink(item: latest) { Label("Share latest telemetry log (\(latest.lastPathComponent))", systemImage: "square.and.arrow.up") }
                    } else {
                        Text("No telemetry logs yet (connect once with Record .tlog on)").foregroundColor(.secondary)
                    }
                }
                Section("App") {
                    LabeledContent("Version", value: Self.appVersion)
                    LabeledContent("iPad", value: "\(UIDevice.current.model), iPadOS \(UIDevice.current.systemVersion)")
                }
                Section("Link") {
                    LabeledContent("State", value: link.state.description)
                    if let b = link.backpackInfo { Text(b.summary).font(.caption) }
                    LabeledContent("Packets", value: "\(link.stats.packetsReceived) ok · \(link.stats.packetsLost) lost · \(link.stats.crcErrors) CRC")
                    LabeledContent("Bytes", value: "\(link.bytesReceived)")
                }
                Section("Vehicle") {
                    LabeledContent("Locked on", value: vehicle.systemID.map { "sys \($0) / comp \(vehicle.componentID)" } ?? "—")
                    LabeledContent("Firmware", value: vehicle.vehicleTypeName)
                    LabeledContent("Attitude data", value: vehicle.attitudeStale ? "STALE" : "OK")
                    ForEach(vehicle.heartbeatSources.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                        LabeledContent("Heartbeat \(item.key)", value: item.value)
                    }
                }
                Section("Messages received") {
                    ForEach(vehicle.messageCounts.sorted(by: { $0.value > $1.value }).prefix(30), id: \.key) { item in
                        LabeledContent(item.key, value: "\(item.value)")
                    }
                }
                Section("Telemetry logs on this iPad") {
                    ForEach(logs.prefix(15), id: \.self) { url in
                        ShareLink(item: url) { Label(url.lastPathComponent, systemImage: "doc") }
                    }
                }
            }
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .onAppear { logs = DocumentsStore.shared.tlogFiles() }
        }
    }
}
