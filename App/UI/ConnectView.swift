// Connection sheet: the iPad equivalent of Mission Planner's top-right COM port / baud / Connect box.

import SwiftUI
import UniformTypeIdentifiers

struct ConnectView: View {
    @EnvironmentObject var link: LinkManager
    @EnvironmentObject var vehicle: VehicleModel
    /// BUG-013: an action that would drop the link to an ARMED vehicle, waiting for confirmation.
    @State private var confirmArmed: (title: String, action: () -> Void)?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = BLEScanner()
    @State private var showLogImporter = false

    @AppStorage("link.kind") private var kindRaw = LinkKind.udpListen.rawValue
    @AppStorage("link.host") private var host = "192.168.4.1"
    @AppStorage("link.port") private var portText = "14550"
    @AppStorage("link.localPort") private var localPortText = "14550"
    @AppStorage("link.ble") private var bleIDText = ""

    private var kind: LinkKind { LinkKind(rawValue: kindRaw) ?? .udpListen }

    /// BUG-024: out-of-range ports used to fall back to the default silently.
    private var portError: String? {
        guard kind != .ble else { return nil }
        if (UInt16(portText.trimmingCharacters(in: .whitespaces)) ?? 0) == 0 { return "Port must be 1–65535" }
        if kind == .udpConnect || kind == .elrs,
           (UInt16(localPortText.trimmingCharacters(in: .whitespaces)) ?? 0) == 0 { return "iPad port must be 1–65535" }
        return nil
    }

    /// BUG-013: Disconnect, Reconnect and Replay drop the live link; ask first when the vehicle is armed.
    private func guarded(_ title: String, _ action: @escaping () -> Void) {
        if vehicle.armed && vehicle.heartbeatAlive { confirmArmed = (title, action) } else { action() }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Connection", selection: $kindRaw) {
                        ForEach(LinkKind.allCases) { k in Text(k.rawValue).tag(k.rawValue) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: kindRaw) { _ in
                        portText = "\(kind.defaultPort)"
                        if kind == .elrs {
                            host = "10.0.0.1"
                            localPortText = "14550"
                        }
                        if kind == .ble { scanner.start() } else { scanner.stop() }
                    }
                } footer: {
                    Text(kind.help)
                }

                switch kind {
                case .udpListen:
                    Section("Local port") {
                        TextField("14550", text: $portText).keyboardType(.numberPad)
                    }
                case .udpConnect, .tcp:
                    Section("Remote") {
                        TextField("Host or IP", text: $host)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        TextField("Port", text: $portText).keyboardType(.numberPad)
                        if kind == .udpConnect {
                            LabeledContent("iPad port") {
                                TextField("14550", text: $localPortText).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                            }
                        }
                    }
                case .elrs:
                    Section {
                        TextField("Backpack IP", text: $host)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        LabeledContent("Backpack port") {
                            TextField("14555", text: $portText).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        }
                        LabeledContent("iPad port") {
                            TextField("14550", text: $localPortText).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        }
                    } header: {
                        Text("ExpressLRS backpack")
                    } footer: {
                        if let info = link.backpackInfo {
                            Text("Read from the backpack: \(info.summary). These ports are used automatically.")
                        } else {
                            Text("On Connect the app reads the real ports from http://\(host)/mavlink and uses them. The fields above are only used if that page can't be read.")
                        }
                    }
                case .ble:
                    Section {
                        if scanner.devices.isEmpty {
                            Text(scanner.status).foregroundColor(.secondary)
                        }
                        ForEach(scanner.devices) { d in
                            Button {
                                bleIDText = d.id.uuidString
                            } label: {
                                HStack {
                                    Text(d.name)
                                    Spacer()
                                    Text("\(d.rssi) dBm").foregroundColor(.secondary)
                                    if bleIDText == d.id.uuidString {
                                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Bluetooth LE devices")
                    } footer: {
                        Text("Shows devices advertising the Nordic UART (6E400001…) or HM-10 (FFE0) service.")
                    }
                }

                Section {
                    Toggle("Record telemetry log (.tlog)", isOn: $link.recordTLog)
                } footer: {
                    Text("Logs are saved to Files › On My iPad › Mission Planner › logs and open in desktop Mission Planner.")
                }

                Section {
                    if link.state.isActive {
                        Button("Disconnect", role: .destructive) {
                            guarded("Disconnect") { link.disconnect() }
                        }
                    }
                    Button(link.state.isActive ? "Reconnect" : "Connect") {
                        let go = {
                            link.connect(kind: kind, host: host.trimmingCharacters(in: .whitespaces),
                                         port: UInt16(portText.trimmingCharacters(in: .whitespaces)) ?? kind.defaultPort,
                                         localPort: UInt16(localPortText.trimmingCharacters(in: .whitespaces)) ?? 14550,
                                         bleDevice: UUID(uuidString: bleIDText))
                            dismiss()
                        }
                        if link.state.isActive { guarded("Reconnect", go) } else { go() }
                    }
                    .disabled(portError != nil || (kind == .ble && UUID(uuidString: bleIDText) == nil)) // BUG-024
                    if let e = portError { Text(e).font(.caption).foregroundColor(.red) }
                }

                Section {
                    let logs = DocumentsStore.shared.tlogFiles()
                    if logs.isEmpty {
                        Text("No recorded logs yet.").foregroundColor(.secondary)
                    }
                    ForEach(logs.prefix(8), id: \.self) { url in
                        Button {
                            guarded("Replay") { link.startReplay(url: url); dismiss() } // BUG-013
                        } label: {
                            Label(url.lastPathComponent, systemImage: "play.rectangle")
                        }
                    }
                    Button { showLogImporter = true } label: { Label("Open a .tlog from Files…", systemImage: "folder") }
                } header: {
                    Text("Replay a telemetry log")
                } footer: {
                    Text("Plays a .tlog (from this iPad or desktop Mission Planner) through the HUD and map. Nothing is sent to any vehicle.")
                }
            }
            .fileImporter(isPresented: $showLogImporter, allowedContentTypes: [.item]) { result in
                if case .success(let url) = result {
                    guarded("Replay") { link.startReplay(url: url); dismiss() } // BUG-013
                }
            }
            .alert("Vehicle is ARMED", isPresented: Binding(get: { confirmArmed != nil }, set: { if !$0 { confirmArmed = nil } })) {
                Button(confirmArmed?.title ?? "Continue", role: .destructive) { confirmArmed?.action(); confirmArmed = nil }
                Button("Cancel", role: .cancel) { confirmArmed = nil }
            } message: {
                Text("\(confirmArmed?.title ?? "This") drops the live link to an armed vehicle. You will lose telemetry and control from this iPad.")
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            .onAppear { if kind == .ble { scanner.start() } }
            .onDisappear { scanner.stop() }
        }
    }
}
