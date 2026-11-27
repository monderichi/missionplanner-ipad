// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Quick" tab (6 big numbers),
// "Status" tab (all CurrentState values) and "Messages" tab (STATUSTEXT history).

import MAVLinkKit
import SwiftUI

struct QuickTile: View {
    let title: String
    let value: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 2) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.system(size: 26, weight: .semibold).monospacedDigit()).foregroundColor(color)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct QuickView: View {
    @EnvironmentObject var vehicle: VehicleModel
    private static let defaultsKey = "quick.tiles"
    private static let defaultTiles = ["alt", "gs", "wpdist", "climb", "yaw", "batv"]
    /// ArduSub defaults: depth, heading, water temperature, battery, vertical speed, ground speed.
    private static let subTiles = ["depth", "yaw", "wtemp", "batv", "climb", "gs"]
    /// nil = the user has not customised the tiles, so the defaults follow the vehicle type.
    @State private var custom: [String]? = QuickView.loadCustom()

    private var tiles: [String] { custom ?? (vehicle.isSub ? QuickView.subTiles : QuickView.defaultTiles) }

    private static func loadCustom() -> [String]? {
        let saved = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
        if saved.count == 6 && saved != defaultTiles && saved.allSatisfy({ TelemetryCatalogue.def($0) != nil }) { return saved }
        return nil
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(0..<tiles.count, id: \.self) { i in
                tile(i)
            }
        }
    }

    @ViewBuilder
    private func tile(_ i: Int) -> some View {
        if let d = TelemetryCatalogue.def(tiles[i]) {
            QuickTile(title: d.unit.isEmpty ? d.label : "\(d.label) (\(d.unit))",
                      value: format(d),
                      color: d.id == "batv" && (0..<20).contains(vehicle.batteryRemaining) ? .red : .primary)
                .contextMenu {
                    ForEach(TelemetryCatalogue.quickChoices) { c in
                        Button(c.label) { setTile(i, c.id) }
                    }
                    Button("Reset tiles to default") { resetTiles() }
                }
        }
    }

    private func format(_ d: TelemetrySeriesDef) -> String {
        let v = d.value(vehicle)
        switch d.id {
        case "wpdist", "yaw", "thr", "sats", "rc1", "rc2", "rc3", "rc4", "sv1", "sv2", "sv3", "sv4",
             "esc1", "esc2", "esc3", "esc4":
            return String(format: "%.0f", v)
        case "climb": return String(format: "%+.1f", v)
        case "batv": return String(format: "%.2f", v)
        default: return String(format: "%.1f", v)
        }
    }

    private func setTile(_ i: Int, _ id: String) {
        var list = tiles
        guard i < list.count else { return }
        list[i] = id
        custom = list
        UserDefaults.standard.set(list, forKey: QuickView.defaultsKey)
    }

    private func resetTiles() {
        custom = nil
        UserDefaults.standard.removeObject(forKey: QuickView.defaultsKey)
    }
}

struct StatusListView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var link: LinkManager

    var body: some View {
        List {
            Section("Vehicle") {
                row("System ID", vehicle.systemID.map { "\($0)" } ?? "—")
                row("Firmware", vehicle.systemID == nil ? "—" : vehicle.vehicleTypeName)
                row("Mode", vehicle.modeName)
                row("Armed", vehicle.armed ? "Yes" : "No")
                row("Current WP", "\(vehicle.currentWaypoint)")
                row("Throttle", "\(vehicle.throttle) %")
            }
            Section("Attitude") {
                row("Roll", String(format: "%.1f°", vehicle.roll))
                row("Pitch", String(format: "%.1f°", vehicle.pitch))
                row("Yaw", String(format: "%.1f°", vehicle.yaw))
                row("Airspeed", String(format: "%.1f m/s", vehicle.airspeed))
                row("Alt (MSL)", String(format: "%.1f m", vehicle.altitudeMSL))
            }
            Section("GPS") {
                row("Fix", vehicle.gpsFixName)
                row("Satellites", "\(vehicle.satellites)")
                row("HDOP", String(format: "%.2f", vehicle.hdop))
                row("Lat", vehicle.latitude.map { String(format: "%.7f", $0) } ?? "—")
                row("Lon", vehicle.longitude.map { String(format: "%.7f", $0) } ?? "—")
            }
            Section("Battery") {
                row("Voltage", String(format: "%.2f V", vehicle.batteryVoltage))
                row("Current", String(format: "%.1f A", vehicle.batteryCurrent))
                row("Remaining", vehicle.batteryRemaining < 0 ? "—" : "\(vehicle.batteryRemaining) %")
            }
            Section("EKF / Vibration") {
                row("EKF flags", String(format: "0x%04X", vehicle.ekfFlags))
                row("Variances v/pH/pV/c/t", vehicle.ekfVariances.map { String(format: "%.2f", $0) }.joined(separator: " / "))
                row("Vibe X/Y/Z", vehicle.vibration.map { String(format: "%.1f", $0) }.joined(separator: " / "))
                row("Clipping 0/1/2", vehicle.clipping.map { "\($0)" }.joined(separator: " / "))
            }
            ESCStatusSection()
            Section("Link") {
                row("Packets", "\(link.stats.packetsReceived)")
                row("Lost (seq gaps)", "\(link.stats.packetsLost)")
                row("CRC errors", "\(link.stats.crcErrors)")
                row("Bytes", "\(link.bytesReceived)")
                row("Radio RSSI / remote", "\(vehicle.radioRSSI.map { "\($0)" } ?? "—") / \(vehicle.radioRemoteRSSI.map { "\($0)" } ?? "—")")
                row("TLog", link.tlogURL?.lastPathComponent ?? "off")
            }
            Section("Messages received") {
                ForEach(vehicle.messageCounts.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                    row(item.key, "\(item.value)")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundColor(.secondary).monospacedDigit()
        }
    }
}

struct MessagesView: View {
    @EnvironmentObject var vehicle: VehicleModel

    var body: some View {
        if vehicle.messages.isEmpty {
            VStack {
                Spacer()
                Text("No messages yet").foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            List(vehicle.messages) { m in
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.text).foregroundColor(color(m.severity))
                    Text("\(m.date.formatted(date: .omitted, time: .standard))  \(m.severity.label)")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
    }

    private func color(_ s: MAVSeverity) -> Color {
        switch s {
        case .emergency, .alert, .critical, .error: return .red
        case .warning: return .orange
        default: return .primary
        }
    }
}
