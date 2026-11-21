// Connection sheet: the iPad equivalent of Mission Planner's top-right COM port / baud / Connect box.

import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var link: LinkManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scanner = BLEScanner()

    @AppStorage("link.kind") private var kindRaw = LinkKind.udpListen.rawValue
    @AppStorage("link.host") private var host = "192.168.4.1"
    @AppStorage("link.port") private var portText = "14550"
    @AppStorage("link.localPort") private var localPortText = "14550"
    @AppStorage("link.ble") private var bleIDText = ""

    private var kind: LinkKind { LinkKind(rawValue: kindRaw) ?? .udpListen }

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
                        Text("Backpack port = its MAVLink listen port, iPad port = its send port. Check them at http://10.0.0.1/mavlink in Safari if the link stays silent.")
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
                            link.disconnect()
                        }
                    }
                    Button(link.state.isActive ? "Reconnect" : "Connect") {
                        link.connect(kind: kind, host: host.trimmingCharacters(in: .whitespaces),
                                     port: UInt16(portText) ?? kind.defaultPort,
                                     localPort: UInt16(localPortText) ?? 14550,
                                     bleDevice: UUID(uuidString: bleIDText))
                        dismiss()
                    }
                    .disabled(kind == .ble && UUID(uuidString: bleIDText) == nil)
                }
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
