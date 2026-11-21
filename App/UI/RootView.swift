// Landscape iPad layout modelled on Mission Planner:
//   top status bar (connect, screen switch DATA / CONFIG, mode, armed, GPS, battery, link quality)
//   DATA:   left column HUD over the Quick/Actions/Status/Messages tabs, map on the right
//   CONFIG: full parameter list

import MAVLinkKit
import SwiftUI

struct RootView: View {
    @EnvironmentObject var link: LinkManager
    @EnvironmentObject var vehicle: VehicleModel
    @State private var showConnect = false
    @State private var tab = Tab.quick
    @State private var screen = Screen.data

    enum Tab: String, CaseIterable, Identifiable {
        case quick = "Quick", actions = "Actions", status = "Status", messages = "Messages"
        var id: String { rawValue }
    }

    enum Screen: String, CaseIterable, Identifiable {
        case data = "Flight Data", config = "Parameters"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatusBar(showConnect: $showConnect, screen: $screen)
            switch screen {
            case .data: flightData
            case .config: ParametersView()
            }
        }
        .sheet(isPresented: $showConnect) { ConnectView() }
        .onAppear { if !link.state.isActive { showConnect = true } }
    }

    private var flightData: some View {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        HUDView(roll: vehicle.roll, pitch: vehicle.pitch, heading: vehicle.heading,
                                airspeed: vehicle.airspeed, groundspeed: vehicle.groundspeed,
                                altitude: vehicle.relativeAltitude, climbRate: vehicle.climbRate,
                                armed: vehicle.armed, mode: vehicle.modeName,
                                linkAlive: vehicle.heartbeatAlive || !link.state.isActive)
                            .frame(height: min(geo.size.height * 0.48, 340))
                        Picker("Tab", selection: $tab) {
                            ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Group {
                            switch tab {
                            case .quick: ScrollView { QuickView() }
                            case .actions: ScrollView { ActionsView() }
                            case .status: StatusListView()
                            case .messages: MessagesView()
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .padding(8)
                    .frame(width: max(360, geo.size.width * 0.36))

                    FlightMapView()
                }
            }
    }
}

struct StatusBar: View {
    @EnvironmentObject var link: LinkManager
    @EnvironmentObject var vehicle: VehicleModel
    @Binding var showConnect: Bool
    @Binding var screen: RootView.Screen

    var body: some View {
        HStack(spacing: 16) {
            Button {
                showConnect = true
            } label: {
                Label(link.state.isActive ? "Link" : "Connect",
                      systemImage: link.state.isActive ? "antenna.radiowaves.left.and.right" : "bolt.horizontal.circle")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(linkColor)

            VStack(alignment: .leading, spacing: 0) {
                Text(link.state.description).font(.caption).lineLimit(1)
                Text(vehicle.heartbeatAlive ? "\(vehicle.vehicleTypeName) · sys \(vehicle.systemID.map { "\($0)" } ?? "?")"
                                            : (link.state.isActive ? "Waiting for heartbeat…" : " "))
                    .font(.caption2).foregroundColor(.secondary)
            }
            .frame(width: 220, alignment: .leading)

            Picker("Screen", selection: $screen) {
                ForEach(RootView.Screen.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(width: 240)

            Spacer()

            item("Mode", vehicle.modeName)
            item("State", vehicle.armed ? "ARMED" : "Disarmed", color: vehicle.armed ? .red : .green)
            item("GPS", "\(vehicle.gpsFixName) · \(vehicle.satellites)",
                 color: vehicle.gpsFixType >= 3 ? .primary : .orange)
            item("Battery", vehicle.batteryRemaining >= 0
                    ? String(format: "%.1fV %ld%%", vehicle.batteryVoltage, vehicle.batteryRemaining)
                    : String(format: "%.1fV", vehicle.batteryVoltage))
            item("Link", linkQuality)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
    }

    private var linkColor: Color {
        if !link.state.isActive { return .gray }
        return vehicle.heartbeatAlive ? .green : .orange
    }

    private var linkQuality: String {
        let s = link.stats
        let total = s.packetsReceived + s.packetsLost
        guard total > 0 else { return "—" }
        return String(format: "%.0f%%", 100 * Double(s.packetsReceived) / Double(total))
    }

    private func item(_ title: String, _ value: String, color: Color = .primary) -> some View {
        VStack(spacing: 0) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.subheadline.weight(.semibold)).foregroundColor(color).lineLimit(1)
        }
    }
}
