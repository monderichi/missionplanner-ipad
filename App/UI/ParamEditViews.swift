// REA Parity Source: MissionPlanner ConfigRawParams.cs (cell edit with range check and
// "value out of range" warning, Values drop-down, Bitmask checklist via MAVLinkBitmask editor,
// reboot-required notice) and ParamCompare.cs (load file -> tick the changes -> write).

import MAVLinkKit
import SwiftUI

struct ParamEditView: View {
    @EnvironmentObject var store: ParameterStore
    @Environment(\.dismiss) private var dismiss
    let param: ParamEntry

    @State private var text = ""
    @State private var confirmOutOfRange = false

    private var meta: ParamMeta? { store.metadata[param.name] }
    private var current: ParamEntry { store.params[param.name] ?? param }
    private var newValue: Float? {
        guard let v = Float(text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")), v.isFinite else { return nil }
        return v
    }

    private var outOfRange: Bool {
        guard let v = newValue, let r = meta?.range else { return false }
        return !r.contains(Double(v))
    }

    private var unchanged: Bool {
        guard let v = newValue else { return true }
        return ParameterSession.same(v, current.value, isInteger: current.isInteger)
    }

    var body: some View {
        NavigationStack {
            Form {
                infoSection
                valueSection
                Section {
                    Button {
                        if outOfRange { confirmOutOfRange = true } else { write() }
                    } label: {
                        Label("Write to vehicle", systemImage: "arrow.up.circle.fill").frame(maxWidth: .infinity)
                    }
                    .disabled(newValue == nil || unchanged || meta?.readOnly == true)
                } footer: {
                    if meta?.readOnly == true {
                        Text("Read-only: set by the autopilot.")
                    } else if store.pendingNames.contains(param.name) {
                        Text("Waiting for the vehicle to confirm…")
                    }
                }
            }
            .navigationTitle(param.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { store.refresh(param.name) } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .onAppear { text = ParamFile.formatValue(current.value) }
            .alert("Value outside the recommended range", isPresented: $confirmOutOfRange) {
                Button("Write anyway", role: .destructive) { write() }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let r = meta?.range {
                    Text("\(param.name) is normally \(fmt(r.lowerBound)) to \(fmt(r.upperBound)).")
                }
            }
        }
    }

    @ViewBuilder private var infoSection: some View {
        Section {
            if let meta {
                if !meta.displayName.isEmpty { Text(meta.displayName).font(.headline) }
                if !meta.summary.isEmpty { Text(meta.summary).font(.callout) }
                if let u = meta.units { LabeledContent("Units", value: u) }
                if let r = meta.range { LabeledContent("Range", value: "\(fmt(r.lowerBound)) … \(fmt(r.upperBound))") }
                if let i = meta.increment { LabeledContent("Increment", value: fmt(i)) }
                if meta.rebootRequired {
                    Label("Reboot required after changing", systemImage: "arrow.triangle.2.circlepath")
                        .foregroundColor(.orange)
                }
            } else {
                Text("No description available for this parameter.").foregroundColor(.secondary)
            }
            LabeledContent("Current value", value: ParamFile.formatValue(current.value))
        }
    }

    @ViewBuilder private var valueSection: some View {
        Section("New value") {
            if let options = meta?.values, !options.isEmpty {
                Picker("Option", selection: optionBinding) {
                    if optionBinding.wrappedValue == nil {
                        Text("Custom: \(text)").tag(Double?.none)
                    }
                    ForEach(options) { o in
                        Text("\(fmt(o.code)): \(o.label)").tag(Double?.some(o.code))
                    }
                }
                .pickerStyle(.navigationLink)
            }
            if let bits = meta?.bits, !bits.isEmpty {
                ForEach(bits) { b in
                    Toggle("\(fmt(b.code)): \(b.label)", isOn: bitBinding(Int(b.code)))
                }
            }
            HStack {
                TextField("Value", text: $text)
                    .keyboardType(.numbersAndPunctuation)
                    .font(.system(.body, design: .monospaced))
                    .autocorrectionDisabled()
                if let step = meta?.increment, step > 0 {
                    Stepper("Adjust", onIncrement: { nudge(step) }, onDecrement: { nudge(-step) })
                        .labelsHidden()
                }
            }
            if newValue == nil {
                Text("Not a number").foregroundColor(.red).font(.caption)
            } else if outOfRange {
                Text("Outside the recommended range").foregroundColor(.orange).font(.caption)
            }
        }
    }

    /// nil = the typed value isn't one of the listed options.
    private var optionBinding: Binding<Double?> {
        Binding(get: {
            guard let v = newValue else { return nil }
            let d = Double(v)
            return meta?.values.contains(where: { $0.code == d }) == true ? d : nil
        }, set: { code in
            if let code { text = fmt(code) }
        })
    }

    /// Current text as an unsigned bitmask (0 if empty, negative or not finite).
    private var maskValue: UInt32 {
        guard let v = newValue, v.isFinite, v >= 0 else { return 0 }
        return UInt32(clamping: Int64(min(Double(v.rounded()), 4_294_967_295)))
    }

    private func bitBinding(_ bit: Int) -> Binding<Bool> {
        Binding(get: {
            let v = maskValue
            return bit < 32 && (v & (UInt32(1) << UInt32(bit))) != 0
        }, set: { on in
            guard bit < 32 else { return }
            var v = maskValue
            if on { v |= UInt32(1) << UInt32(bit) } else { v &= ~(UInt32(1) << UInt32(bit)) }
            text = String(v)
        })
    }

    private func nudge(_ step: Double) {
        let base = newValue.map { Double($0) } ?? Double(current.value)
        guard base.isFinite else { return }
        let v = base + step
        let rounded = (v / step).rounded() * step
        text = fmt(rounded)
    }

    private func write() {
        guard let v = newValue else { return }
        store.set(param.name, v)
        dismiss()
    }

    private func fmt(_ d: Double) -> String {
        if d.rounded() == d && abs(d) < 1e9 { return String(Int64(d)) }
        return ParamFile.formatValue(Float(d))
    }
}

/// Picks a saved .param file from Documents/params, or browses Files.
struct ParamFilePicker: View {
    let files: [URL]
    let onPick: (URL) -> Void
    let onBrowse: () -> Void
    var title = "Load parameters"
    var folderName = "params"
    var fileKind = ".param"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { onBrowse() } label: { Label("Browse Files…", systemImage: "folder") }
                }
                Section("Saved on this iPad") {
                    if files.isEmpty {
                        Text("No \(fileKind) files in Mission Planner › \(folderName) yet.").foregroundColor(.secondary)
                    }
                    ForEach(files, id: \.self) { url in
                        Button(url.lastPathComponent) { onPick(url) }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}

/// Mission Planner's "Compare Params": shows what the file would change; write the ticked ones.
struct ParamCompareView: View {
    @EnvironmentObject var store: ParameterStore
    @Environment(\.dismiss) private var dismiss
    let fileName: String
    let values: [String: Float]
    @State private var selected: Set<String> = []
    @State private var initialised = false

    var body: some View {
        let diff = store.differences(from: values)
        NavigationStack {
            List {
                Section {
                    Text("\(values.count) parameters in file, \(diff.changes.count) differ from the vehicle.")
                    if !diff.unknown.isEmpty {
                        Text("\(diff.unknown.count) aren't on this vehicle and will be skipped: \(diff.unknown.prefix(8).joined(separator: ", "))\(diff.unknown.count > 8 ? "…" : "")")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                Section("Changes") {
                    ForEach(diff.changes) { d in
                        Button {
                            if selected.contains(d.name) { selected.remove(d.name) } else { selected.insert(d.name) }
                        } label: {
                            HStack {
                                Image(systemName: selected.contains(d.name) ? "checkmark.square.fill" : "square")
                                Text(d.name).font(.system(.body, design: .monospaced))
                                Spacer()
                                Text(ParamFile.formatValue(d.current)).foregroundColor(.secondary)
                                Image(systemName: "arrow.right").foregroundColor(.secondary)
                                Text(ParamFile.formatValue(d.file)).fontWeight(.semibold)
                                if store.metadata[d.name]?.rebootRequired == true {
                                    Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.orange)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Write \(selected.count)") {
                        store.setMany(values.filter { selected.contains($0.key) })
                        dismiss()
                    }
                    .disabled(selected.isEmpty)
                }
            }
            .onAppear {
                if !initialised {
                    selected = Set(diff.changes.map(\.name))
                    initialised = true
                }
            }
        }
    }
}
