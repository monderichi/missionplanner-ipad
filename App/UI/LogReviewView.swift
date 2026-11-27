// REA Parity Source: MissionPlanner Log/LogBrowse.cs (Review a Log: message list, field picker, graph,
// flight modes, parameters) on top of ExtLibs/Utilities/DFLog.cs (parser lives in MAVLinkKit/DataFlash.swift).

import SwiftUI
import Charts
import UniformTypeIdentifiers
import MAVLinkKit

// MARK: - Model (prefixed LR so they never clash with other files' types)

private struct LRPlotPoint: Identifiable {
    let id: Int
    let t: Double
    let v: Double
}

private struct LRPlotSeries: Identifiable {
    let id: String      // "ATT.Roll"
    let points: [LRPlotPoint]
}

private enum LRLoadState {
    case loading
    case failed(String)
    case loaded(DataFlashLog)
}

private enum LRTab: String, CaseIterable, Identifiable {
    case plot = "Graph"
    case modes = "Flight modes"
    case params = "Parameters"
    var id: String { rawValue }
}

// MARK: - Review one log

struct LogReviewView: View {
    let url: URL

    @State private var state: LRLoadState = .loading
    @State private var tab: LRTab = .plot
    @State private var selectedMessage: String?
    @State private var selectedColumns: [String] = []
    @State private var series: [LRPlotSeries] = []
    @State private var paramFilter = ""

    var body: some View {
        Group {
            switch state {
            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Parsing \(url.lastPathComponent)...").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.orange)
                    Text(message).multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let log):
                loadedBody(log)
            }
        }
        .navigationTitle(url.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    // MARK: Loading

    private func load() async {
        let target = url
        let result: Result<DataFlashLog, Error> = await Task.detached(priority: .userInitiated) {
            let scoped = target.startAccessingSecurityScopedResource()
            defer { if scoped { target.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: target, options: .mappedIfSafe)
                return Result<DataFlashLog, Error>.success(try DataFlashLog.parse(data))
            } catch {
                return Result<DataFlashLog, Error>.failure(error)
            }
        }.value
        switch result {
        case .success(let log):
            state = .loaded(log)
            if selectedMessage == nil {
                selectedMessage = log.messageNames.contains("ATT") ? "ATT" : log.messageNames.first
            }
        case .failure(let error):
            state = .failed("Could not read the log: \(error)")
        }
    }

    // MARK: Loaded content

    @ViewBuilder
    private func loadedBody(_ log: DataFlashLog) -> some View {
        VStack(spacing: 0) {
            Picker("View", selection: $tab) {
                ForEach(LRTab.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .padding(8)
            summaryLine(log)
            Divider()
            switch tab {
            case .plot: plotTab(log)
            case .modes: modesTab(log)
            case .params: paramsTab(log)
            }
        }
    }

    private func summaryLine(_ log: DataFlashLog) -> some View {
        let dur = max(0, log.endTime - log.startTime)
        var text = "\(log.messageNames.count) message types, \(log.recordCount) records, \(String(format: "%.0f", dur)) s"
        if log.skippedBytes > 0 { text += ", \(log.skippedBytes) bytes skipped" }
        return Text(text).font(.caption).foregroundStyle(.secondary).padding(.bottom, 4)
    }

    // MARK: Graph

    private func plotTab(_ log: DataFlashLog) -> some View {
        HStack(spacing: 0) {
            List(log.messageNames, id: \.self, selection: $selectedMessage) { name in
                HStack {
                    Text(name).font(.body.monospaced())
                    Spacer()
                    Text("\(log.count(of: name))").font(.caption).foregroundStyle(.secondary)
                }
                .tag(name)
            }
            .listStyle(.plain)
            .frame(width: 190)
            .onChange(of: selectedMessage) { _ in
                selectedColumns = []
                series = []
            }
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                if let msg = selectedMessage {
                    columnPicker(log, msg)
                    chart()
                } else {
                    Text("Select a message type").foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(8)
        }
    }

    private func columnPicker(_ log: DataFlashLog, _ msg: String) -> some View {
        let cols = log.columns(of: msg)
        return VStack(alignment: .leading, spacing: 4) {
            Text("\(msg) fields (max 4)").font(.caption).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(cols, id: \.self) { col in
                        Button {
                            toggle(col, log: log, msg: msg)
                        } label: {
                            let on = selectedColumns.contains(col)
                            Text(col)
                                .font(.callout)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(on ? Color.accentColor : Color.secondary.opacity(0.15), in: Capsule())
                                .foregroundColor(on ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func toggle(_ col: String, log: DataFlashLog, msg: String) {
        if let i = selectedColumns.firstIndex(of: col) {
            selectedColumns.remove(at: i)
        } else if selectedColumns.count < 4 {
            selectedColumns.append(col)
        }
        rebuildSeries(log: log, msg: msg)
    }

    private func rebuildSeries(log: DataFlashLog, msg: String) {
        var out: [LRPlotSeries] = []
        for col in selectedColumns {
            let raw = log.values(message: msg, column: col)
            let d = DataFlashLog.downsample(t: raw.t, v: raw.v, maxPoints: 2000)
            var pts: [LRPlotPoint] = []
            pts.reserveCapacity(d.t.count)
            for i in 0..<d.t.count {
                if d.v[i].isFinite {
                    pts.append(LRPlotPoint(id: i, t: d.t[i] - log.startTime, v: d.v[i]))
                }
            }
            out.append(LRPlotSeries(id: "\(msg).\(col)", points: pts))
        }
        series = out
    }

    @ViewBuilder
    private func chart() -> some View {
        if series.isEmpty {
            Text("Pick up to four fields to plot").foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart {
                ForEach(series) { s in
                    ForEach(s.points) { p in
                        LineMark(x: .value("Time (s)", p.t), y: .value("Value", p.v), series: .value("Series", s.id))
                            .foregroundStyle(by: .value("Series", s.id))
                    }
                }
            }
            .chartXAxisLabel("seconds from log start")
            .chartLegend(position: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: Flight modes

    private func modesTab(_ log: DataFlashLog) -> some View {
        Group {
            if log.modeChanges.isEmpty {
                Text("No MODE messages in this log").foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(log.modeChanges.enumerated()), id: \.offset) { item in
                        modeRow(log, item.offset, item.element)
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func modeRow(_ log: DataFlashLog, _ i: Int, _ m: DataFlashLog.ModeChange) -> some View {
        let start = m.time - log.startTime
        let endAbs = i + 1 < log.modeChanges.count ? log.modeChanges[i + 1].time : log.endTime
        let len = max(0, endAbs - m.time)
        return HStack {
            Text(m.name).font(.headline)
            Spacer()
            Text(String(format: "%.1f s  (%.1f s)", start, len))
                .font(.callout.monospacedDigit()).foregroundStyle(.secondary)
        }
    }

    // MARK: Parameters

    private func paramsTab(_ log: DataFlashLog) -> some View {
        let all = log.parameters.keys.sorted()
        let shown = paramFilter.isEmpty ? all : all.filter { $0.localizedCaseInsensitiveContains(paramFilter) }
        return VStack(spacing: 0) {
            TextField("Search parameters", text: $paramFilter)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(8)
            if all.isEmpty {
                Text("No PARM messages in this log").foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(shown, id: \.self) { name in
                    HStack {
                        Text(name).font(.body.monospaced())
                        Spacer()
                        Text(formatParam(log.parameters[name] ?? 0)).font(.body.monospacedDigit())
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func formatParam(_ v: Double) -> String {
        if v == v.rounded() && abs(v) < 1e9 { return String(format: "%.0f", v) }
        return String(format: "%g", v)
    }
}

// MARK: - Picker

struct LogReviewPicker: View {
    @State private var files: [URL] = []
    @State private var path: [URL] = []
    @State private var importing = false

    private var folder: URL { DocumentsStore.shared.tlogs.appendingPathComponent("dataflash", isDirectory: true) }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Logs in Files > Mission Planner > logs > dataflash") {
                    if files.isEmpty {
                        Text("No .bin logs here yet. Copy one in with the Files app or use Open below.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(files, id: \.self) { url in
                        NavigationLink(value: url) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                VStack(alignment: .leading) {
                                    Text(url.lastPathComponent)
                                    Text(sizeText(url)).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                Section {
                    Button { importing = true } label: { Label("Open .bin from Files...", systemImage: "folder") }
                }
            }
            .navigationTitle("Review a Log")
            .navigationDestination(for: URL.self) { u in LogReviewView(url: u) }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { refresh() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .onAppear { refresh() }
            .fileImporter(isPresented: $importing,
                          allowedContentTypes: [UTType(filenameExtension: "bin") ?? UTType.data, UTType.data]) { result in
                if case .success(let u) = result { path.append(u) }
            }
        }
    }

    private func refresh() {
        let fm = FileManager.default
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        let urls = (try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil,
                                                options: [.skipsHiddenFiles])) ?? []
        files = urls.filter { $0.pathExtension.lowercased() == "bin" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    private func sizeText(_ url: URL) -> String {
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}
