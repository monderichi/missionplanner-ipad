// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Tuning" tab (live zedgraph of selected values).

import Charts
import SwiftUI

struct GraphView: View {
    @EnvironmentObject var history: TelemetryHistory
    @State private var normalise = false

    private struct Point: Identifiable {
        let id: String
        let name: String
        let t: Double
        let v: Double
    }

    private func points(now: Date) -> [Point] {
        _ = history.revision // re-render on every new sample
        var out: [Point] = []
        for sid in history.selected {
            guard let def = TelemetryCatalogue.def(sid) else { continue }
            let s = history.samples(for: sid)
            if s.isEmpty { continue }
            var lo = 0.0
            var hi = 1.0
            if normalise {
                lo = s.map { $0.value }.min() ?? 0
                hi = s.map { $0.value }.max() ?? 1
                if hi - lo < 1e-9 { hi = lo + 1 }
            }
            for p in s {
                let v = normalise ? (p.value - lo) / (hi - lo) : p.value
                out.append(Point(id: "\(sid)-\(p.id)", name: def.label, t: p.time.timeIntervalSince(now), v: v))
            }
        }
        return out
    }

    var body: some View {
        content(points(now: Date()))
    }

    private func content(_ pts: [Point]) -> some View {
        VStack(spacing: 6) {
            HStack {
                Menu {
                    ForEach(TelemetryCatalogue.all) { d in
                        Button {
                            history.toggle(d.id)
                        } label: {
                            if history.isSelected(d.id) {
                                Label("\(d.label) (\(d.unit))", systemImage: "checkmark")
                            } else {
                                Text("\(d.label) (\(d.unit))")
                            }
                        }
                    }
                } label: {
                    Label("Series (\(history.selected.count)/\(TelemetryHistory.maxSelected))", systemImage: "checklist")
                }
                Toggle("Normalise", isOn: $normalise).toggleStyle(.button).font(.caption)
                Spacer()
                Button { history.paused.toggle() } label: {
                    Image(systemName: history.paused ? "play.fill" : "pause.fill")
                }
                .accessibilityLabel(history.paused ? "Resume" : "Pause")
                Button { history.clear() } label: { Image(systemName: "trash") }
                    .accessibilityLabel("Clear graph")
            }
            .buttonStyle(.bordered)
            .font(.caption)

            if pts.isEmpty {
                Spacer()
                Text(history.selected.isEmpty ? "Choose series from the menu" : "Waiting for data…")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                Chart {
                    ForEach(pts) { p in
                        LineMark(x: .value("t", p.t), y: .value("v", p.v))
                            .foregroundStyle(by: .value("series", p.name))
                    }
                }
                .chartXScale(domain: -TelemetryHistory.windowSeconds ... 0.0)
                .chartLegend(position: .bottom)
                .frame(minHeight: 200)
            }
        }
    }
}
