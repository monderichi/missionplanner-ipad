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
        entries = []
        dirty = false
    }

    private func publish() {
        let now = Date()
        let dt = now.timeIntervalSince(lastTick)
        guard dt > 0 else { return }
        lastTick = now
        // Rates decay even when nothing arrives, so refresh while any entry is still non-zero.
        var anyActive = dirty
        for (key, entry) in table {
            var e = entry
            let prev = lastCounts[key] ?? 0
            let inst = Double(e.count - prev) / dt
            lastCounts[key] = e.count
            e.rate = e.rate == 0 ? inst : e.rate * 0.7 + inst * 0.3
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
