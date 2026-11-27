// REA Parity Source: MissionPlanner Controls/MAVLinkInspector.cs (per sys/comp/msg count, rate and fields).
// Records every packet cheaply and publishes a snapshot at most 4 times a second.

import Foundation
import MAVLinkKit

struct InspectorEntry: Identifiable {
    let sysID: UInt8
    let compID: UInt8
    let msgID: UInt32
    let name: String
    var count = 0
    var rate = 0.0
    var lastPacket: MAVLinkPacket?
    var lastDate = Date.distantPast

    var id: String { "\(sysID)/\(compID)/\(msgID)" }
    var source: String { "\(sysID)/\(compID)" }
}

final class MessageInspector: ObservableObject {
    @Published private(set) var entries: [InspectorEntry] = []

    private var table: [String: InspectorEntry] = [:]
    private var lastCounts: [String: Int] = [:]
    /// (time, cumulative count) samples per key over the last window seconds.
    private var history: [String: [(Date, Int)]] = [:]
    static let window: TimeInterval = 5
    private var lastTick = Date()
    private var dirty = false
    private var timer: Timer?

    init() {
        let t = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in self?.publish() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    deinit { timer?.invalidate() }

    /// Main thread. Cheap: a dictionary update, no decoding.
    func record(_ p: MAVLinkPacket) {
        let key = "\(p.systemID)/\(p.componentID)/\(p.messageID)"
        var e = table[key] ?? InspectorEntry(sysID: p.systemID, compID: p.componentID, msgID: p.messageID, name: p.name)
        e.count += 1
        e.lastPacket = p
        e.lastDate = Date()
        table[key] = e
        dirty = true
    }

    func clear() {
        table = [:]
        lastCounts = [:]
        history = [:]
        entries = []
        dirty = false
    }

    private func publish() {
        let now = Date()
        let dt = now.timeIntervalSince(lastTick)
        guard dt > 0 else { return }
        lastTick = now
        // Rates decay even when nothing arrives, so refresh while any entry is still non-zero.
        // Rate = messages received in the last `window` seconds / window (Mission Planner's
        // inspector counts over a window too). An exponential average per 0.25 s tick read far too
        // low for bursty streams (1 Hz heartbeats, batched attitude over ELRS).
        var anyActive = dirty
        for (key, entry) in table {
            var e = entry
            var hist = history[key] ?? []
            hist.append((now, e.count))
            while let first = hist.first, now.timeIntervalSince(first.0) > Self.window { hist.removeFirst() }
            history[key] = hist
            if let first = hist.first, let last = hist.last, last.0 > first.0 {
                let span = max(last.0.timeIntervalSince(first.0), 1)
                e.rate = Double(last.1 - first.1) / span
            }
            if e.rate < 0.01 { e.rate = 0 }
            if e.rate > 0 { anyActive = true }
            table[key] = e
        }
        guard anyActive else { return }
        dirty = false
        entries = table.values.sorted {
            if $0.sysID != $1.sysID { return $0.sysID < $1.sysID }
            if $0.compID != $1.compID { return $0.compID < $1.compID }
            return $0.msgID < $1.msgID
        }
    }
}
