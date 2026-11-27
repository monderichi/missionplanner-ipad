// REA Parity Source: MissionPlanner Controls/MAVLinkInspector.cs (Ctrl+F "MAVLink Inspector").

import MAVLinkKit
import SwiftUI

struct InspectorView: View {
    @EnvironmentObject var inspector: MessageInspector
    @State private var search = ""
    @State private var expanded: Set<String> = []

    private var filtered: [InspectorEntry] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return inspector.entries }
        return inspector.entries.filter { $0.name.lowercased().contains(q) }
    }

    private var sources: [String] {
        var seen: [String] = []
        for e in filtered where !seen.contains(e.source) { seen.append(e.source) }
        return seen
    }

    var body: some View {
        List {
            if filtered.isEmpty {
                Text(inspector.entries.isEmpty ? "No packets received yet" : "No message matches the filter")
                    .foregroundColor(.secondary)
            }
            ForEach(sources, id: \.self) { src in
                Section("sys/comp \(src)") {
                    ForEach(filtered.filter { $0.source == src }) { e in
                        row(e)
                        if expanded.contains(e.id) {
                            fields(e)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $search, prompt: "Filter by message name")
        .navigationTitle("MAVLink Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Clear") { inspector.clear() } } }
    }

    private func row(_ e: InspectorEntry) -> some View {
        Button {
            if expanded.contains(e.id) { expanded.remove(e.id) } else { expanded.insert(e.id) }
        } label: {
            HStack {
                Image(systemName: expanded.contains(e.id) ? "chevron.down" : "chevron.right")
                    .font(.caption).foregroundColor(.secondary).frame(width: 14)
                Text(e.name).foregroundColor(.primary)
                Text("#\(e.msgID)").font(.caption2).foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f Hz", e.rate)).monospacedDigit().foregroundColor(.secondary)
                Text("\(e.count)").monospacedDigit().frame(minWidth: 64, alignment: .trailing)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func fields(_ e: InspectorEntry) -> some View {
        let items = InspectorFormat.fields(of: e.lastPacket)
        if items.isEmpty {
            Text("No decoder for this message").font(.caption).foregroundColor(.secondary)
        } else {
            ForEach(items, id: \.name) { f in
                HStack(alignment: .top) {
                    Text(f.name).font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text(f.value).font(.caption.monospacedDigit()).multilineTextAlignment(.trailing)
                }
                .padding(.leading, 22)
            }
        }
    }
}

enum InspectorFormat {
    struct Field {
        let name: String
        let value: String
    }

    static func fields(of packet: MAVLinkPacket?) -> [Field] {
        guard let packet, let msg = packet.decode() else { return [] }
        var out: [Field] = []
        for child in Mirror(reflecting: msg).children {
            guard let label = child.label else { continue }
            out.append(Field(name: label, value: format(label, child.value)))
        }
        return out
    }

    private static func scalar(_ v: Any) -> String {
        if let d = v as? Double { return String(format: "%.5g", d) }
        if let f = v as? Float { return String(format: "%.5g", Double(f)) }
        return "\(v)"
    }

    static func format(_ name: String, _ value: Any) -> String {
        if let bytes = value as? [UInt8] {
            let lower = name.lowercased()
            if lower.contains("text") || lower.contains("id") || lower.contains("name") {
                let body = bytes.prefix { $0 != 0 }
                if !body.isEmpty && body.allSatisfy({ $0 >= 32 && $0 < 127 }) {
                    return "\"" + MAVString.decode(bytes) + "\""
                }
            }
            return compact(bytes.map { "\($0)" })
        }
        let m = Mirror(reflecting: value)
        if m.displayStyle == .collection {
            return compact(m.children.map { scalar($0.value) })
        }
        return scalar(value)
    }

    private static func compact(_ items: [String]) -> String {
        if items.count <= 8 { return "[" + items.joined(separator: ", ") + "]" }
        return "[" + items.prefix(8).joined(separator: ", ") + ", … +\(items.count - 8)]"
    }
}
