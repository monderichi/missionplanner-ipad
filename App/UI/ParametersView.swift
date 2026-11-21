// REA Parity Source: MissionPlanner GCSViews/ConfigurationView/ConfigRawParams.cs (Full Parameter
// List: search, grouping by prefix, description/range/units/options columns, Write/Refresh,
// Save/Load .param, compare) and ConfigRawParamsTree.cs (prefix tree).

import MAVLinkKit
import SwiftUI
import UniformTypeIdentifiers

struct ParametersView: View {
    @EnvironmentObject var store: ParameterStore
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var commands: CommandCenter

    @State private var search = ""
    @State private var group: String? = nil
    @State private var editing: ParamEntry?
    @State private var showLoad = false
    @State private var showImporter = false
    @State private var loaded: LoadedFile?
    @State private var confirmReboot = false
    @State private var savedMessage: String?

    struct LoadedFile: Identifiable {
        let id = UUID()
        let name: String
        let values: [String: Float]
    }

    private var groups: [String] {
        Array(Set(store.params.keys.map(Self.prefix))).sorted()
    }

    static func prefix(_ name: String) -> String {
        if let i = name.firstIndex(of: "_") { return String(name[..<i]) }
        return name
    }

    private var filtered: [ParamEntry] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        return store.params.values
            .filter { group == nil || Self.prefix($0.name) == group }
            .filter { p in
                q.isEmpty || p.name.lowercased().contains(q)
                    || (store.metadata[p.name]?.displayName.lowercased().contains(q) ?? false)
                    || (store.metadata[p.name]?.summary.lowercased().contains(q) ?? false)
            }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            if let banner = store.banner {
                Text(banner)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .onTapGesture { store.banner = nil }
            }
            if store.rebootNeeded {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text("A changed parameter only takes effect after rebooting the autopilot.")
                    Spacer()
                    Button("Reboot now") { confirmReboot = true }.disabled(vehicle.armed)
                }
                .font(.callout)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.orange.opacity(0.15))
            }
            if !store.isAttached {
                placeholder("Connect to a vehicle to see its parameters.")
            } else if store.params.isEmpty {
                placeholder(downloadText)
            } else {
                HStack(spacing: 0) {
                    List {
                        groupRow(nil, title: "All", count: store.params.count)
                        ForEach(groups, id: \.self) { g in
                            groupRow(g, title: g, count: store.params.keys.filter { Self.prefix($0) == g }.count)
                        }
                    }
                    .listStyle(.plain)
                    .frame(width: 200)
                    Divider()
                    List(filtered, id: \.name) { p in
                        Button { editing = p } label: { ParamRow(param: p, meta: store.metadata[p.name],
                                                                 pending: store.pendingNames.contains(p.name)) }
                            .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .sheet(item: $editing) { p in
            ParamEditView(param: p).environmentObject(store)
        }
        .sheet(isPresented: $showLoad) {
            ParamFilePicker(files: store.savedFiles(), onPick: { url in
                showLoad = false
                load(url)
            }, onBrowse: {
                showLoad = false
                showImporter = true
            })
        }
        .sheet(item: $loaded) { file in
            ParamCompareView(fileName: file.name, values: file.values).environmentObject(store)
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            if case .success(let url) = result { load(url) }
        }
        .alert("Reboot autopilot?", isPresented: $confirmReboot) {
            Button("Reboot", role: .destructive) { commands.reboot() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The vehicle must be disarmed. The link drops for a few seconds, and parameters are re-downloaded afterwards.")
        }
        .alert(savedMessage ?? "", isPresented: Binding(get: { savedMessage != nil }, set: { if !$0 { savedMessage = nil } })) {
            Button("OK", role: .cancel) {}
        }
    }

    private var downloadText: String {
        switch store.downloadState {
        case .downloading(let received, let total):
            if let total { return "Downloading parameters… \(received) / \(total)" }
            return "Requesting parameters…"
        case .failed(let received, let total):
            return "Download incomplete (\(received) / \(total.map { "\($0)" } ?? "?")). Tap Refresh."
        default:
            return "No parameters yet. Tap Refresh."
        }
    }

    private var downloadProgress: (received: Int, total: Int)? {
        if case .downloading(let received, let total) = store.downloadState, let total, total > 0 {
            return (received, total)
        }
        return nil
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search name or description", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .frame(maxWidth: 320)
            Spacer()
            if let progress = downloadProgress {
                ProgressView(value: Double(progress.received), total: Double(progress.total)).frame(width: 140)
                Text("\(progress.received)/\(progress.total)").font(.caption).monospacedDigit()
            }
            if store.queuedWrites > 0 || !store.pendingNames.isEmpty {
                Label("Writing \(store.queuedWrites + store.pendingNames.count)", systemImage: "arrow.up.circle")
                    .font(.caption)
            }
            Button { store.download() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
                .disabled(!store.isAttached)
            Button {
                do {
                    let url = try store.save()
                    savedMessage = "Saved \(store.params.count) parameters to Files › Mission Planner › params › \(url.lastPathComponent)"
                } catch {
                    savedMessage = "Save failed: \(error.localizedDescription)"
                }
            } label: { Label("Save", systemImage: "square.and.arrow.down") }
                .disabled(store.params.isEmpty)
            Button { showLoad = true } label: { Label("Load", systemImage: "folder") }
                .disabled(store.params.isEmpty)
            Button { confirmReboot = true } label: { Label("Reboot", systemImage: "power") }
                .disabled(!commands.isAttached || vehicle.armed)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func groupRow(_ g: String?, title: String, count: Int) -> some View {
        Button {
            group = g
        } label: {
            HStack {
                Text(title).fontWeight(group == g ? .bold : .regular)
                Spacer()
                Text("\(count)").font(.caption).foregroundColor(.secondary)
            }
        }
        .listRowBackground(group == g ? Color.accentColor.opacity(0.15) : Color.clear)
    }

    private func placeholder(_ text: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            if store.isDownloading { ProgressView() }
            Text(text).foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func load(_ url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let text = (try? String(contentsOf: url, encoding: .utf8)) ?? (try? String(contentsOf: url, encoding: .isoLatin1))
        guard let text else {
            savedMessage = "Couldn't read \(url.lastPathComponent)"
            return
        }
        let values = ParamFile.parse(text)
        if values.isEmpty {
            savedMessage = "\(url.lastPathComponent) has no parameters in it"
        } else {
            loaded = LoadedFile(name: url.lastPathComponent, values: values)
        }
    }
}

extension ParameterStore {
    var isDownloading: Bool {
        if case .downloading = downloadState { return true }
        return false
    }
}

extension ParamEntry: Identifiable {
    public var id: String { name }
}

struct ParamRow: View {
    let param: ParamEntry
    let meta: ParamMeta?
    let pending: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(param.name).font(.system(.body, design: .monospaced)).fontWeight(.semibold)
                if let meta, !meta.displayName.isEmpty {
                    Text(meta.displayName).font(.caption).foregroundColor(.secondary).lineLimit(1)
                }
            }
            Spacer()
            if pending { ProgressView().scaleEffect(0.7) }
            VStack(alignment: .trailing, spacing: 2) {
                Text(ParamFile.formatValue(param.value) + (meta?.units.map { " \($0)" } ?? ""))
                    .font(.system(.body, design: .monospaced))
                if let label = meta?.label(for: param.value) {
                    Text(label).font(.caption).foregroundColor(.secondary).lineLimit(1)
                } else if meta?.rebootRequired == true {
                    Text("reboot required").font(.caption2).foregroundColor(.orange)
                }
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 2)
    }
}
