// REA Parity Source: MissionPlanner Log/LogDownloadMavLink.cs + MAVLinkInterface.GetLogList /
// GetLog: LOG_REQUEST_LIST -> LOG_ENTRY x numLogs; LOG_REQUEST_DATA(id, ofs, count) -> LOG_DATA
// (90-byte chunks, count < 90 marks the end); re-request missing ranges; LOG_REQUEST_END when done
// so ArduPilot resumes normal logging; LOG_ERASE to clear the card.
// Pure state machines (caller supplies `now`, sends what they return).

import Foundation

public struct LogEntryInfo: Equatable, Identifiable {
    public let id: UInt16
    public let size: UInt32
    /// UTC seconds since 1970, 0 if the vehicle had no GPS time.
    public let timeUtc: UInt32

    public init(id: UInt16, size: UInt32, timeUtc: UInt32) {
        self.id = id
        self.size = size
        self.timeUtc = timeUtc
    }

    public var date: Date? { timeUtc > 0 ? Date(timeIntervalSince1970: TimeInterval(timeUtc)) : nil }
}

public final class LogListSession {
    public enum Event: Equatable {
        case listed([LogEntryInfo])
        case failed(String)
    }

    public let targetSystem: UInt8
    public let targetComponent: UInt8
    public var timeout: TimeInterval = 3
    public var retries = 5

    private var entries: [UInt16: LogEntryInfo] = [:]
    private var expected: Int?
    private var lastActivity: TimeInterval = 0
    private var attempts = 0
    public private(set) var active = false

    public init(targetSystem: UInt8, targetComponent: UInt8 = 1) {
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
    }

    public func start(now: TimeInterval) -> [MAVLinkMessage] {
        entries = [:]
        expected = nil
        attempts = 0
        lastActivity = now
        active = true
        return [request()]
    }

    private func request() -> MAVLinkMessage {
        MAV.LogRequestList(start: 0, end: 0xFFFF, targetSystem: targetSystem, targetComponent: targetComponent)
    }

    public func handle(_ e: MAV.LogEntry, now: TimeInterval) -> [Event] {
        guard active else { return [] }
        lastActivity = now
        attempts = 0
        expected = Int(e.numLogs)
        if e.numLogs == 0 {
            active = false
            return [.listed([])]
        }
        entries[e.id] = LogEntryInfo(id: e.id, size: e.size, timeUtc: e.timeUtc)
        if entries.count >= Int(e.numLogs) {
            active = false
            return [.listed(entries.values.sorted { $0.id < $1.id })]
        }
        return []
    }

    public func tick(now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        guard active, now - lastActivity >= timeout else { return ([], []) }
        lastActivity = now
        attempts += 1
        if attempts > retries {
            active = false
            // a partial list is still useful
            if !entries.isEmpty { return ([], [.listed(entries.values.sorted { $0.id < $1.id })]) }
            return ([], [.failed("No answer from vehicle")])
        }
        return ([request()], [])
    }
}

public final class LogDownloadSession {
    public enum Event: Equatable {
        case progress(received: Int, total: Int)
        case finished(Data)
        /// BUG-019: file-backed session (`fileURL` given): the log is complete in that file.
        case finishedFile(URL, bytes: Int)
        case failed(String)
    }

    public static let chunk = 90

    public let entry: LogEntryInfo
    public let targetSystem: UInt8
    public let targetComponent: UInt8
    /// Silence before re-requesting the first gap.
    public var timeout: TimeInterval = 2
    /// Bytes asked for per gap re-request (ArduPilot streams the whole range).
    public var gapRequestBytes = 90 * 256
    public var maxStalls = 15

    private var buffer: [UInt8]
    /// BUG-019: when set, chunks are written at their offset in this file instead of being kept in RAM
    /// (the in-memory buffer stays empty; `have` costs 1 byte per 90-byte chunk).
    public let fileURL: URL?
    private var file: FileHandle?
    private var have: [Bool]
    private var size: Int
    private var receivedBytes = 0
    private var lastActivity: TimeInterval = 0
    private var stalls = 0
    private var progressSinceTick = false
    public private(set) var active = false

    public init(entry: LogEntryInfo, targetSystem: UInt8, targetComponent: UInt8 = 1, fileURL: URL? = nil) {
        self.entry = entry
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
        self.fileURL = fileURL
        size = Int(entry.size)
        buffer = fileURL == nil ? [UInt8](repeating: 0, count: size) : []
        have = [Bool](repeating: false, count: (size + Self.chunk - 1) / Self.chunk)
    }

    public var received: Int { receivedBytes }

    public func start(now: TimeInterval) -> [MAVLinkMessage] {
        active = true
        lastActivity = now
        if let url = fileURL {
            // An empty file of the final size; chunks are written in place as they arrive (any order).
            guard FileManager.default.createFile(atPath: url.path, contents: nil),
                  let h = try? FileHandle(forWritingTo: url) else {
                active = false
                startError = "Can't create \(url.lastPathComponent)"
                return []
            }
            file = h
        }
        if size == 0 {
            active = false
            closeFile() // review R2-1: nothing to download; don't keep the handle open
            return [end()]
        }
        return [request(ofs: 0, count: size)]
    }

    /// Set when `start` couldn't open the file (no messages are sent then).
    public private(set) var startError: String?

    public func cancel() -> [MAVLinkMessage] {
        active = false
        closeFile()
        return [end()]
    }

    private func closeFile() {
        try? file?.close()
        file = nil
    }

    private func request(ofs: Int, count: Int) -> MAVLinkMessage {
        MAV.LogRequestData(ofs: UInt32(ofs), count: UInt32(count), id: entry.id,
                           targetSystem: targetSystem, targetComponent: targetComponent)
    }

    private func end() -> MAVLinkMessage {
        MAV.LogRequestEnd(targetSystem: targetSystem, targetComponent: targetComponent)
    }

    public func handle(_ d: MAV.LogData, now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        guard active, d.id == entry.id else { return ([], []) }
        let ofs = Int(d.ofs), n = Int(d.count)
        lastActivity = now
        // short chunk = end of file; the real file may be shorter than LOG_ENTRY said
        if n < Self.chunk && ofs + n < size {
            size = ofs + n
            have = Array(have.prefix((size + Self.chunk - 1) / Self.chunk))
            if fileURL == nil { buffer = Array(buffer.prefix(size)) }
        }
        guard ofs % Self.chunk == 0, ofs < size || (n == 0 && ofs == size) else { return ([], []) }
        if n > 0 {
            let idx = ofs / Self.chunk
            if idx < have.count && !have[idx] {
                let len = min(n, size - ofs)
                if let file {
                    do {
                        try file.seek(toOffset: UInt64(ofs))
                        try file.write(contentsOf: Data(d.data.prefix(len)))
                    } catch {
                        active = false
                        closeFile()
                        return ([end()], [.failed("Write failed: \(error.localizedDescription)")])
                    }
                } else {
                    for k in 0..<len { buffer[ofs + k] = d.data[k] }
                }
                have[idx] = true
                receivedBytes += len
                stalls = 0
                progressSinceTick = true
            }
        }
        if !have.contains(false) {
            active = false
            if let file, let url = fileURL {
                do { try file.truncate(atOffset: UInt64(size)) } catch {} // the log may be shorter than LOG_ENTRY said
                closeFile()
                return ([end()], [.finishedFile(url, bytes: size)])
            }
            return ([end()], [.finished(Data(buffer))])
        }
        return ([], [.progress(received: receivedBytes, total: size)])
    }

    /// First gap as (offset, length in bytes), capped at gapRequestBytes.
    private func firstGap() -> (Int, Int)? {
        guard let first = have.firstIndex(of: false) else { return nil }
        var last = first
        while last + 1 < have.count && !have[last + 1] && (last + 1 - first + 1) * Self.chunk <= gapRequestBytes {
            last += 1
        }
        let ofs = first * Self.chunk
        return (ofs, min(size, (last + 1) * Self.chunk) - ofs)
    }

    public func tick(now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        guard active, now - lastActivity >= timeout else { return ([], []) }
        lastActivity = now
        if !progressSinceTick { stalls += 1 }
        progressSinceTick = false
        if stalls > maxStalls {
            active = false
            closeFile()
            return ([end()], [.failed("No data from vehicle (\(receivedBytes) of \(size) bytes)")])
        }
        guard let gap = firstGap() else { return ([], []) }
        return ([request(ofs: gap.0, count: gap.1)], [])
    }
}
