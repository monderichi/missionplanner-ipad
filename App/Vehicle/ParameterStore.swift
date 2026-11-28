// App-side wrapper around MAVLinkKit.ParameterSession: owns the session for the current vehicle,
// throttles SwiftUI updates during download, queues bulk writes (loading a .param file) so a
// narrow link isn't flooded, and saves/loads Mission Planner .param files in Documents/params.

import Foundation
import MAVLinkKit

final class ParameterStore: ObservableObject {
    @Published private(set) var params: [String: ParamEntry] = [:]
    @Published private(set) var downloadState: ParameterSession.DownloadState = .idle
    @Published private(set) var pendingNames: Set<String> = []
    @Published private(set) var queuedWrites = 0
    @Published private(set) var metadata: [String: ParamMeta] = [:]
    @Published private(set) var firmware: String?
    /// A reboot-required parameter was written since the last reboot.
    @Published private(set) var rebootNeeded = false
    /// Latest result line, shown as a banner in the parameter screen.
    @Published var banner: String?

    var send: ((MAVLinkMessage) -> Void)?

    private var session: ParameterSession?
    private var dirty = false
    private var writeQueue: [(String, Float)] = []
    private var maxInFlight = 10
    private var failures: [String] = []

    var isAttached: Bool { session != nil }

    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }

    // MARK: lifecycle

    func attach(systemID: UInt8, componentID: UInt8, vehicleType: UInt8, narrowLink: Bool) {
        session = ParameterSession(targetSystem: systemID, targetComponent: componentID,
                                   config: narrowLink ? .narrowLink : ParameterSession.Config())
        maxInFlight = narrowLink ? 3 : 10
        params = [:]
        pendingNames = []
        writeQueue = []
        queuedWrites = 0
        rebootNeeded = false
        firmware = ParamMetadataRepository.firmwareName(vehicleType: vehicleType)
        let fw = firmware
        DispatchQueue.global(qos: .userInitiated).async {
            let meta = fw.map { ParamMetadataRepository.load(firmware: $0) } ?? [:]
            DispatchQueue.main.async { self.metadata = meta }
        }
        download()
    }

    func detach() {
        session = nil
        downloadState = .idle
        pendingNames = []
        writeQueue = []
        queuedWrites = 0
    }

    // MARK: actions

    func download() {
        guard let session else { return }
        session.startDownload(now: now).forEach { send?($0) }
        downloadState = session.downloadState
        params = [:]
    }

    func set(_ name: String, _ value: Float) {
        guard let session else { return }
        // BUG-020: ArduPilot ignores non-finite PARAM_SETs, so they only time out after retries: refuse here.
        guard value.isFinite else { banner = "\(name): not a valid number, not written"; return }
        session.set(name, value: value, now: now).forEach { send?($0) }
        pendingNames = Set(session.pendingSetNames)
    }

    /// Queue many writes; they're sent a few at a time from tick().
    func setMany(_ values: [String: Float]) {
        writeQueue += values.filter { $0.value.isFinite }.sorted { $0.key < $1.key }.map { ($0.key, $0.value) } // BUG-020
        queuedWrites = writeQueue.count
        failures = []
        pump()
    }

    func refresh(_ name: String) {
        session?.refresh(name).forEach { send?($0) }
    }

    func markRebooted() {
        rebootNeeded = false
    }

    // MARK: input (main queue)

    func handle(_ m: MAV.ParamValue) {
        guard let session else { return }
        for e in session.handle(m, now: now) { apply(e) }
        dirty = true
    }

    /// Main-queue timer, ~4 Hz.
    func tick() {
        guard let session else { return }
        let r = session.tick(now: now)
        r.messages.forEach { send?($0) }
        r.events.forEach { apply($0) }
        pump()
        if dirty || !r.events.isEmpty {
            params = session.params
            downloadState = session.downloadState
            pendingNames = Set(session.pendingSetNames)
            dirty = false
        }
    }

    private func pump() {
        guard let session else { return }
        while !writeQueue.isEmpty && session.pendingSetNames.count < maxInFlight {
            let (name, value) = writeQueue.removeFirst()
            session.set(name, value: value, now: now).forEach { send?($0) }
        }
        queuedWrites = writeQueue.count
        pendingNames = Set(session.pendingSetNames)
    }

    private func apply(_ e: ParameterSession.Event) {
        switch e {
        case .progress:
            break
        case .downloadComplete(let total):
            banner = "Downloaded \(total) parameters"
        case .downloadFailed(let missing):
            banner = "Parameter download incomplete: \(missing) missing. Tap Refresh to retry."
        case .setResult(let name, let requested, let actual, let ok):
            if ok {
                if metadata[name]?.rebootRequired == true { rebootNeeded = true }
                banner = "\(name) = \(ParamFile.formatValue(actual))"
            } else {
                failures.append(name)
                banner = "\(name): vehicle kept \(ParamFile.formatValue(actual)) (asked \(ParamFile.formatValue(requested)))"
            }
        case .setTimedOut(let name):
            failures.append(name)
            banner = "\(name): no answer from vehicle, not written"
        case .valueChanged(let name, let value):
            banner = "\(name) changed to \(ParamFile.formatValue(value))"
        }
    }

    /// Names that failed (timed out or kept a different value) since the last bulk write.
    var failedWrites: [String] { failures }

    // MARK: files

    var paramsDirectory: URL { DocumentsStore.shared.params }

    func save(note: String? = nil) throws -> URL {
        let values = params.mapValues { $0.value }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let stamp = f.string(from: Date())
        let name = "\(firmware ?? "params") \(stamp).param"
        let url = paramsDirectory.appendingPathComponent(name)
        let text = ParamFile.format(values, note: note ?? "\(stamp) Mission Planner iPad, \(values.count) params")
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func savedFiles() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(at: paramsDirectory, includingPropertiesForKeys: nil,
                                                                  options: [.skipsHiddenFiles])) ?? []
        return urls.filter { $0.pathExtension.lowercased() == "param" || $0.pathExtension.lowercased() == "parm" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    struct Difference: Identifiable {
        let name: String
        let current: Float
        let file: Float
        var id: String { name }
    }

    /// Compares a file against the vehicle. Names the vehicle doesn't have are reported separately.
    func differences(from file: [String: Float]) -> (changes: [Difference], unknown: [String]) {
        var changes: [Difference] = []
        var unknown: [String] = []
        for (name, value) in file {
            guard let cur = params[name] else { unknown.append(name); continue }
            if cur.value.isNaN && value.isNaN { continue } // BUG-020: NaN == NaN for the compare view
            if !ParameterSession.same(cur.value, value, isInteger: cur.isInteger) {
                changes.append(Difference(name: name, current: cur.value, file: value))
            }
        }
        return (changes.sorted { $0.name < $1.name }, unknown.sorted())
    }
}
