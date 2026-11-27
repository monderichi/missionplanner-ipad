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
        case quick = "Quick", actions = "Actions", checklist = "Checklist", status = "Status", servo = "Servo", messages = "Messages"
        var id: String { rawValue }
    }

    enum Screen: String, CaseIterable, Identifiable {
        case data = "Data", plan = "Plan", setup = "Setup", config = "Params"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatusBar(showConnect: $showConnect, screen: $screen)
            switch screen {
            case .data: flightData
            case .plan: PlanView()
            case .setup: SetupView()
            case .config: ParametersView()
            }
            if link.isReplaying { ReplayBar() }
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
                                linkAlive: vehicle.heartbeatAlive || !link.state.isActive,
                                attitudeStale: vehicle.attitudeStale)
                            .frame(height: min(geo.size.height * 0.48, 340))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Tab.allCases) { t in
                                    Button(t.rawValue) { tab = t }
                                        .buttonStyle(.bordered)
                                        .tint(tab == t ? .accentColor : .gray)
                                        .fontWeight(tab == t ? .bold : .regular)
                                }
                            }
                        }
                        Group {
                            switch tab {
                            case .quick: ScrollView { QuickView() }
                            case .actions: ScrollView { ActionsView() }
                            case .checklist: ChecklistView()
                            case .servo: ScrollView { ServoView() }
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
    @EnvironmentObject var speech: SpeechAlerts
    @State private var showDiagnostics = false
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
            .frame(width: 280)

            Spacer()

            item("Mode", vehicle.modeName)
            item("State", vehicle.armed ? "ARMED" : "Disarmed", color: vehicle.armed ? .red : .green)
            item("GPS", "\(vehicle.gpsFixName) · \(vehicle.satellites)",
                 color: vehicle.gpsFixType >= 3 ? .primary : .orange)
            item("Battery", vehicle.batteryRemaining >= 0
                    ? String(format: "%.1fV %ld%%", vehicle.batteryVoltage, vehicle.batteryRemaining)
                    : String(format: "%.1fV", vehicle.batteryVoltage))
            item("Link", linkQuality)
            Button { showDiagnostics = true } label: { Image(systemName: "info.circle") }
                .accessibilityLabel("Diagnostics and feedback")
            Button { speech.enabled.toggle() } label: {
                Image(systemName: speech.enabled ? "speaker.wave.2.fill" : "speaker.slash")
            }
            .accessibilityLabel(speech.enabled ? "Voice alerts on" : "Voice alerts off")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
        .sheet(isPresented: $showDiagnostics) { DiagnosticsView() }
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

/// Playback controls shown while a .tlog is replayed.
struct ReplayBar: View {
    @EnvironmentObject var replay: ReplayController
    @EnvironmentObject var link: LinkManager
    @State private var scrub: Double?

    private func time(_ t: TimeInterval) -> String {
        let s = Int(t)
        return String(format: "%d:%02d:%02d", s / 3600, (s / 60) % 60, s % 60)
    }

    var body: some View {
        HStack(spacing: 14) {
            Button { replay.playPause() } label: {
                Image(systemName: replay.playing ? "pause.fill" : "play.fill").font(.title2)
            }
            .disabled(!replay.loaded)
            Text(time(scrub.map { $0 * replay.duration } ?? replay.elapsed)).monospacedDigit().font(.callout)
            Slider(value: Binding(get: { scrub ?? replay.position }, set: { scrub = $0 }), in: 0...1, onEditingChanged: { editing in
                if !editing, let s = scrub {
                    replay.seek(to: s)
                    scrub = nil
                }
            })
            Text(time(replay.duration)).monospacedDigit().font(.callout)
            Picker("Speed", selection: $replay.speed) {
                ForEach([0.5, 1, 2, 5, 10, 25], id: \.self) { s in Text("\(s < 1 ? String(s) : String(Int(s)))×").tag(s) }
            }
            .pickerStyle(.menu)
            Text(replay.fileName).font(.caption).lineLimit(1).frame(maxWidth: 200)
            Button("Stop") { link.disconnect() }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }
}