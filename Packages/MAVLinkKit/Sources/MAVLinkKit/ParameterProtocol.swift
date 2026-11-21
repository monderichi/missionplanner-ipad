// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Mavlink/MAVLinkInterface.cs
//   getParamList(): PARAM_REQUEST_LIST, collect PARAM_VALUE by param_index, and when the stream
//   goes quiet re-request the missing indices with PARAM_REQUEST_READ (index, empty name).
//   setParam(): PARAM_SET with the type the vehicle reported, wait for the echoed PARAM_VALUE
//   (param_index 65535 is allowed), retry, then compare the returned value.
//   ArduPilot sends values as plain floats (MAV_PROTOCOL_CAPABILITY_PARAM_FLOAT), not byte unions.
//
// Pure state machine: no timers or I/O. The caller passes `now`, sends what it returns and
// feeds PARAM_VALUE messages back in. That keeps it unit-testable with a simulated lossy link.

import Foundation

public struct ParamEntry: Equatable {
    public var name: String
    public var value: Float
    /// MAV_PARAM_TYPE as reported by the vehicle (1 = UINT8 ... 9 = REAL32).
    public var type: UInt8
    public var index: Int

    public var isInteger: Bool { type >= 1 && type <= 8 }
}

public enum MAVParamType {
    public static let uint8: UInt8 = 1, int8: UInt8 = 2, uint16: UInt8 = 3, int16: UInt8 = 4
    public static let uint32: UInt8 = 5, int32: UInt8 = 6, real32: UInt8 = 9
}

public final class ParameterSession {
    public struct Config {
        /// No new PARAM_VALUE for this long -> the initial stream is over (or was lost);
        /// re-send the list request, or start filling gaps.
        public var idleTimeout: TimeInterval = 1.0
        /// Gap filling: PARAM_REQUEST_READs per batch, and time between batches.
        public var batchSize = 20
        public var batchInterval: TimeInterval = 0.3
        /// Give up after this many consecutive rounds (list re-requests or batches) with no progress.
        public var maxStalledRounds = 8
        /// PARAM_SET retry interval and attempts.
        public var setTimeout: TimeInterval = 1.5
        public var setAttempts = 3

        public init() {}

        /// Settings for ExpressLRS / BLE class links (a few kB/s, high latency).
        public static var narrowLink: Config {
            var c = Config()
            c.idleTimeout = 2.5
            c.batchSize = 10
            c.batchInterval = 1.0
            c.maxStalledRounds = 15
            c.setTimeout = 3
            c.setAttempts = 4
            return c
        }
    }

    public enum DownloadState: Equatable {
        case idle
        case downloading(received: Int, total: Int?)
        case complete(total: Int)
        case failed(received: Int, total: Int?)
    }

    public enum Event: Equatable {
        case progress(received: Int, total: Int)
        case downloadComplete(total: Int)
        case downloadFailed(missing: Int)
        /// `ok` is false when the vehicle answered with a different value (clamped or refused).
        case setResult(name: String, requested: Float, actual: Float, ok: Bool)
        case setTimedOut(name: String)
        /// A value changed outside a pending set (another GCS, or the vehicle itself).
        case valueChanged(name: String, value: Float)
    }

    public let targetSystem: UInt8
    public let targetComponent: UInt8
    public var config: Config

    public private(set) var params: [String: ParamEntry] = [:]
    public private(set) var downloadState: DownloadState = .idle
    public private(set) var total: Int?

    private var receivedIndices = Set<Int>()
    private var lastProgress: TimeInterval = 0
    private var stalledRounds = 0
    private var listRequests = 0
    private var filling = false
    private var lastBatch: TimeInterval = 0
    private var progressSinceBatch = false

    private struct PendingSet {
        var value: Float
        var type: UInt8
        var attempts: Int
        var lastSent: TimeInterval
    }
    private var pendingSets: [String: PendingSet] = [:]

    public init(targetSystem: UInt8, targetComponent: UInt8 = 1, config: Config = Config()) {
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
        self.config = config
    }

    public var missingIndices: [Int] {
        guard let total else { return [] }
        return (0..<total).filter { !receivedIndices.contains($0) }
    }

    public var isDownloading: Bool {
        if case .downloading = downloadState { return true }
        return false
    }

    public var pendingSetNames: [String] { pendingSets.keys.sorted() }

    // MARK: download

    public func startDownload(now: TimeInterval) -> [MAVLinkMessage] {
        params.removeAll()
        receivedIndices.removeAll()
        total = nil
        stalledRounds = 0
        listRequests = 1
        filling = false
        progressSinceBatch = false
        lastProgress = now
        downloadState = .downloading(received: 0, total: nil)
        return [requestList()]
    }

    private func requestList() -> MAVLinkMessage {
        MAV.ParamRequestList(targetSystem: targetSystem, targetComponent: targetComponent)
    }

    private func requestRead(index: Int) -> MAVLinkMessage {
        MAV.ParamRequestRead(paramIndex: Int16(truncatingIfNeeded: index), targetSystem: targetSystem,
                             targetComponent: targetComponent, paramId: [UInt8](repeating: 0, count: 16))
    }

    // MARK: set

    /// Builds a PARAM_SET. Uses the type the vehicle reported for this name (REAL32 if unknown).
    public func set(_ name: String, value: Float, now: TimeInterval) -> [MAVLinkMessage] {
        let type = params[name]?.type ?? MAVParamType.real32
        pendingSets[name] = PendingSet(value: value, type: type, attempts: 1, lastSent: now)
        return [paramSet(name, value, type)]
    }

    private func paramSet(_ name: String, _ value: Float, _ type: UInt8) -> MAVLinkMessage {
        MAV.ParamSet(paramValue: value, targetSystem: targetSystem, targetComponent: targetComponent,
                     paramId: MAVString.encode(name, length: 16), paramType: type)
    }

    /// Re-read one parameter by name.
    public func refresh(_ name: String) -> [MAVLinkMessage] {
        [MAV.ParamRequestRead(paramIndex: -1, targetSystem: targetSystem, targetComponent: targetComponent,
                              paramId: MAVString.encode(name, length: 16))]
    }

    // MARK: input

    public func handle(_ m: MAV.ParamValue, now: TimeInterval) -> [Event] {
        let name = MAVString.decode(m.paramId)
        guard !name.isEmpty else { return [] }
        var events: [Event] = []
        let index = Int(m.paramIndex)
        let previous = params[name]

        var entry = ParamEntry(name: name, value: m.paramValue, type: m.paramType,
                               index: previous?.index ?? index)
        if m.paramIndex != UInt16.max { entry.index = index }
        params[name] = entry

        if let pending = pendingSets.removeValue(forKey: name) {
            let ok = Self.same(pending.value, m.paramValue, isInteger: entry.isInteger)
            events.append(.setResult(name: name, requested: pending.value, actual: m.paramValue, ok: ok))
        } else if let previous, previous.value != m.paramValue, !isDownloading {
            events.append(.valueChanged(name: name, value: m.paramValue))
        }

        if isDownloading {
            if m.paramCount > 0 && m.paramCount != UInt16.max { total = Int(m.paramCount) }
            if m.paramIndex != UInt16.max && !receivedIndices.contains(index) {
                receivedIndices.insert(index)
                lastProgress = now
                stalledRounds = 0
                progressSinceBatch = true
            }
            if let total {
                downloadState = .downloading(received: receivedIndices.count, total: total)
                events.append(.progress(received: receivedIndices.count, total: total))
                if receivedIndices.count >= total {
                    downloadState = .complete(total: total)
                    events.append(.downloadComplete(total: total))
                }
            }
        }
        return events
    }

    /// Call periodically (e.g. every 0.25-0.5 s). Returns retries to send and any timeouts.
    public func tick(now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        var out: [MAVLinkMessage] = []
        var events: [Event] = []

        if isDownloading {
            if total == nil {
                // Nothing at all yet: the list request (or every reply) was lost. Ask again.
                if now - lastProgress >= config.idleTimeout {
                    lastProgress = now
                    stalledRounds += 1
                    if stalledRounds > config.maxStalledRounds {
                        failDownload(&events)
                    } else {
                        listRequests += 1
                        out.append(requestList())
                    }
                }
            } else if filling || now - lastProgress >= config.idleTimeout {
                // Initial stream is over: request the gaps, one batch per batchInterval.
                if now - lastBatch >= config.batchInterval {
                    if filling && !progressSinceBatch { stalledRounds += 1 }
                    filling = true
                    progressSinceBatch = false
                    lastBatch = now
                    if stalledRounds > config.maxStalledRounds {
                        failDownload(&events)
                    } else {
                        // Cycle through the gaps so a short tail is requested several times per batch.
                        let miss = missingIndices
                        if !miss.isEmpty {
                            let n = min(config.batchSize, miss.count * 3)
                            for k in 0..<n { out.append(requestRead(index: miss[k % miss.count])) }
                        }
                    }
                }
            }
        }

        for (name, pending) in pendingSets where now - pending.lastSent >= config.setTimeout {
            var p = pending
            if p.attempts >= config.setAttempts {
                pendingSets[name] = nil
                events.append(.setTimedOut(name: name))
            } else {
                p.attempts += 1
                p.lastSent = now
                pendingSets[name] = p
                out.append(paramSet(name, p.value, p.type))
            }
        }
        return (out, events)
    }

    private func failDownload(_ events: inout [Event]) {
        downloadState = .failed(received: receivedIndices.count, total: total)
        events.append(.downloadFailed(missing: missingIndices.count))
    }

    /// Value comparison used to confirm a PARAM_SET (integers exact after rounding, floats ~1e-6 relative).
    public static func same(_ a: Float, _ b: Float, isInteger: Bool) -> Bool {
        if isInteger { return a.rounded() == b.rounded() }
        return abs(a - b) <= max(1e-6, abs(a) * 1e-6)
    }
}

// MARK: - .param files

/// Mission Planner .param files: "NAME,VALUE" per line, '#' comments. Loading also accepts
/// space/tab separators and QGroundControl's "sysid compid NAME VALUE type" rows
/// (MissionPlanner/Utilities/ParamFile.cs loadParamFile/SaveParamFile).
public enum ParamFile {
    public static func format(_ params: [String: Float], note: String? = nil) -> String {
        var s = ""
        if let note { s += "#NOTE: \(note)\n" }
        for name in params.keys.sorted() {
            s += "\(name),\(formatValue(params[name]!))\n"
        }
        return s
    }

    public static func formatValue(_ v: Float) -> String {
        if v.rounded() == v && abs(v) < 1e9 { return String(Int64(v)) }
        return String(describing: v) // shortest round-trip representation, e.g. 0.15
    }

    public static func parse(_ text: String) -> [String: Float] {
        var out: [String: Float] = [:]
        // Character.isNewline: in Swift "\r\n" (Windows files, e.g. saved by desktop Mission Planner)
        // is ONE Character, so comparing against "\n" / "\r" would never split those lines.
        for raw in text.split(whereSeparator: { $0.isNewline }) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            let cols = line.split(whereSeparator: { $0 == "," || $0 == "\t" || $0 == " " }).map(String.init)
            let name: String, valueText: String
            if cols.count >= 5, Int(cols[0]) != nil, Int(cols[1]) != nil {
                name = cols[2]; valueText = cols[3]          // QGC: sysid compid name value type
            } else if cols.count >= 2 {
                name = cols[0]; valueText = cols[1]
            } else {
                continue
            }
            guard let v = Float(valueText), isValidName(name) else { continue }
            out[name] = v
        }
        return out
    }

    public static func isValidName(_ name: String) -> Bool {
        !name.isEmpty && name.utf8.count <= 16 &&
            name.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_") }
    }
}
