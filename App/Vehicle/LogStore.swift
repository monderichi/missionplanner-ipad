// DataFlash (.bin) log list/download over MAVLink (Mission Planner: Flight Data > DataFlash Logs >
// "Download DataFlash Log Via Mavlink"). Saved to Documents/logs/dataflash so they open in desktop
// Mission Planner / UAV Log Viewer. Slow over ExpressLRS (a few kB/s), fast over Wi-Fi bridges.

import Foundation
import MAVLinkKit

final class LogStore: ObservableObject {
    @Published private(set) var entries: [LogEntryInfo] = []
    @Published private(set) var listing = false
    @Published private(set) var downloading: LogEntryInfo?
    @Published private(set) var received = 0
    @Published private(set) var rate: Double = 0   // bytes/s
    @Published var message: String?
    /// BUG-019: downloads stream to a file now (no RAM copy); only keep this much disk space free for the system.
    static let reserveBytes: Int64 = 200 * 1_048_576

    var send: ((MAVLinkMessage) -> Void)?

    private var system: UInt8?
    private var component: UInt8 = 1
    private var list: LogListSession?
    private var download: LogDownloadSession?
    private var started = Date()
    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }

    var isAttached: Bool { system != nil }

    var directory: URL {
        let d = DocumentsStore.shared.tlogs.appendingPathComponent("dataflash", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }

    func attach(systemID: UInt8, componentID: UInt8) {
        system = systemID
        component = componentID
    }

    func detach() {
        if let d = download, d.active { d.cancel().forEach { send?($0) } }
        discardPartial()
        system = nil
        list = nil
        download = nil
        downloading = nil
        listing = false
    }

    func refresh() {
        guard let system else { return }
        let s = LogListSession(targetSystem: system, targetComponent: component)
        list = s
        listing = true
        entries = []
        s.start(now: now).forEach { send?($0) }
    }

    func start(_ entry: LogEntryInfo) {
        guard let system, download?.active != true else { return }
        // BUG-019: the log is written chunk by chunk to "<name>.partial" next to the final file, so its size is limited
        // by free disk space, not RAM.
        let dir = directory
        if let free = (try? dir.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]))?
            .volumeAvailableCapacityForImportantUsage, Int64(entry.size) > free - Self.reserveBytes {
            message = "Log \(entry.id) is \(entry.size / 1_048_576) MB, but only \(max(0, free) / 1_048_576) MB are free on this iPad."
            return
        }
        let partial = dir.appendingPathComponent(fileName(entry) + ".partial")
        let s = LogDownloadSession(entry: entry, targetSystem: system, targetComponent: component, fileURL: partial)
        download = s
        downloading = entry
        received = 0
        rate = 0
        started = Date()
        message = nil
        s.start(now: now).forEach { send?($0) }
        if let why = s.startError {
            message = "Download failed: \(why)"
            download = nil
            downloading = nil
        }
    }

    /// Removes the unfinished file of the current download (cancel, failure, link change).
    private func discardPartial() {
        if let url = download?.fileURL { try? FileManager.default.removeItem(at: url) }
    }

    func cancel() {
        download?.cancel().forEach { send?($0) }
        discardPartial()
        download = nil
        downloading = nil
        message = "Download cancelled"
    }

    /// MAV_CMD... LOG_ERASE: deletes every log on the flight controller's SD card.
    func eraseAll() {
        guard let system else { return }
        send?(MAV.LogErase(targetSystem: system, targetComponent: component))
        entries = []
        message = "Erase sent. Refresh in a few seconds."
    }

    func handle(_ p: MAVLinkPacket) {
        if let e = p.decode(MAV.LogEntry.self), let list {
            for ev in list.handle(e, now: now) { apply(ev) }
        } else if let d = p.decode(MAV.LogData.self), let download {
            let r = download.handle(d, now: now)
            r.messages.forEach { send?($0) }
            for ev in r.events { apply(ev) }
        }
    }

    func tick() {
        if let list {
            let r = list.tick(now: now)
            r.messages.forEach { send?($0) }
            r.events.forEach { apply($0) }
        }
        if let download {
            let r = download.tick(now: now)
            r.messages.forEach { send?($0) }
            r.events.forEach { apply($0) }
            received = download.received
            let dt = Date().timeIntervalSince(started)
            rate = dt > 1 ? Double(received) / dt : 0
        }
    }

    private func apply(_ e: LogListSession.Event) {
        listing = false
        switch e {
        case .listed(let l):
            entries = l
            message = l.isEmpty ? "No logs on the vehicle" : nil
        case .failed(let why):
            message = "Couldn't list logs: \(why)"
        }
    }

    private func apply(_ e: LogDownloadSession.Event) {
        switch e {
        case .progress(let got, _):
            received = got
        case .finished(let data):
            guard let entry = downloading else { return }
            let url = directory.appendingPathComponent(fileName(entry))
            do {
                try data.write(to: url, options: .atomic)
                message = "Saved \(url.lastPathComponent) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))"
            } catch {
                message = "Save failed: \(error.localizedDescription)"
            }
            downloading = nil
            download = nil
        case .finishedFile(let partial, let bytes):
            guard let entry = downloading else { return }
            let url = directory.appendingPathComponent(fileName(entry))
            do {
                if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
                try FileManager.default.moveItem(at: partial, to: url)
                message = "Saved \(url.lastPathComponent) (\(ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)))"
            } catch {
                message = "Save failed: \(error.localizedDescription)"
                try? FileManager.default.removeItem(at: partial)
            }
            downloading = nil
            download = nil
        case .failed(let why):
            message = "Download failed: \(why)"
            discardPartial()
            downloading = nil
            download = nil
        }
    }

    func fileName(_ e: LogEntryInfo) -> String {
        if let d = e.date {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "yyyy-MM-dd HH-mm-ss"
            return "\(f.string(from: d)) log\(e.id).bin"
        }
        return "log\(e.id).bin"
    }
}
