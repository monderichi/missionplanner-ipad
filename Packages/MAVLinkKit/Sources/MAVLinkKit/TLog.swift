// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Mavlink/MAVLinkInterface.cs (logfile writes:
// BitConverter.GetBytes(usec) reversed = big-endian, followed by the raw packet) and
// MissionPlanner/Log/LogPlayback (readPacket: 8-byte timestamp, then one MAVLink frame).
//
// .tlog record = [UInt64 big-endian microseconds since 1970-01-01 UTC][raw MAVLink frame]
// Files are named like Mission Planner's: "yyyy-MM-dd HH-mm-ss.tlog".

import Foundation

public enum TLog {
    public static func timestamp(_ date: Date) -> UInt64 {
        let usec = date.timeIntervalSince1970 * 1_000_000
        return usec > 0 ? UInt64(usec) : 0
    }

    public static func date(fromTimestamp usec: UInt64) -> Date {
        Date(timeIntervalSince1970: Double(usec) / 1_000_000)
    }

    public static func record(_ rawPacket: [UInt8], at date: Date = Date()) -> [UInt8] {
        let usec = timestamp(date)
        var out = [UInt8]()
        out.reserveCapacity(8 + rawPacket.count)
        for k in stride(from: 56, through: 0, by: -8) {
            out.append(UInt8(truncatingIfNeeded: usec >> UInt64(k)))
        }
        out += rawPacket
        return out
    }

    public static func fileName(for date: Date = Date()) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return f.string(from: date) + ".tlog"
    }
}

/// Appends records to a .tlog file on a background queue.
public final class TLogWriter {
    public let url: URL
    private let handle: FileHandle
    private let queue = DispatchQueue(label: "MAVLinkKit.TLogWriter")
    private var closed = false
    public private(set) var packetsWritten = 0

    public init(url: URL) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if !fm.fileExists(atPath: url.path) {
            fm.createFile(atPath: url.path, contents: nil)
        }
        handle = try FileHandle(forWritingTo: url)
        try handle.seekToEnd()
        self.url = url
    }

    /// Creates "<directory>/yyyy-MM-dd HH-mm-ss.tlog".
    public convenience init(directory: URL, date: Date = Date()) throws {
        try self.init(url: directory.appendingPathComponent(TLog.fileName(for: date)))
    }

    public func write(_ packet: MAVLinkPacket, at date: Date = Date()) {
        write(raw: packet.raw, at: date)
    }

    public func write(raw: [UInt8], at date: Date = Date()) {
        let record = Data(TLog.record(raw, at: date))
        queue.async {
            guard !self.closed else { return }
            try? self.handle.write(contentsOf: record)
            self.packetsWritten += 1
        }
    }

    public func close() {
        queue.sync {
            guard !closed else { return }
            closed = true
            try? handle.synchronize()
            try? handle.close()
        }
    }

    deinit {
        // No queued writes can remain (each one retains self), and deinit may itself run
        // on `queue`, so close directly instead of queue.sync (which would deadlock).
        if !closed {
            try? handle.synchronize()
            try? handle.close()
        }
    }
}

/// Reads a .tlog (from this app or desktop Mission Planner). Resyncs on corrupt records.
public struct TLogReader: Sequence {
    public struct Record {
        public let date: Date
        public let packet: MAVLinkPacket
    }

    public let bytes: [UInt8]

    public init(bytes: [UInt8]) { self.bytes = bytes }
    public init(url: URL) throws { bytes = [UInt8](try Data(contentsOf: url)) }

    public func makeIterator() -> Iterator { Iterator(bytes: bytes) }

    public struct Iterator: IteratorProtocol {
        let bytes: [UInt8]
        var offset = 0

        public mutating func next() -> Record? {
            while offset + 8 < bytes.count {
                var usec: UInt64 = 0
                for k in 0..<8 { usec = (usec << 8) | UInt64(bytes[offset + k]) }
                switch MAVLinkFraming.frame(in: bytes, at: offset + 8) {
                case .frame(let packet, let length):
                    offset += 8 + length
                    return Record(date: TLog.date(fromTimestamp: usec), packet: packet)
                case .needMoreData:
                    return nil // truncated tail
                case .invalid:
                    offset += 1
                }
            }
            return nil
        }
    }
}
