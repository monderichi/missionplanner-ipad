// REA Parity Source: MissionPlanner ExtLibs/Mavlink/MavlinkParse.cs (ReadPacket,
// GenerateMAVLinkPacket10, GenerateMAVLinkPacket20) and ExtLibs/Mavlink/MAVLinkMessage.cs.
//
// MAVLink 1 frame: FE len seq sys comp msgid(1) payload crc(2)
// MAVLink 2 frame: FD len incompat compat seq sys comp msgid(3, LE) payload crc(2) [signature(13)]
// CRC = X.25 over everything after the STX up to the end of the payload, then CRC_EXTRA.
// Byte-for-byte parity with Mission Planner is checked by Tests/MAVLinkKitTests/FixtureTests.swift.

import Foundation

public enum MAVLinkConstants {
    public static let stxV1: UInt8 = 0xFE
    public static let stxV2: UInt8 = 0xFD
    public static let headerLengthV1 = 6
    public static let headerLengthV2 = 10
    public static let signatureLength = 13
    public static let incompatFlagSigned: UInt8 = 0x01
}

public struct MAVLinkPacket: Equatable {
    public enum Version: UInt8 { case v1 = 1, v2 = 2 }

    public let version: Version
    public let sequence: UInt8
    public let systemID: UInt8
    public let componentID: UInt8
    public let messageID: UInt32
    public let incompatFlags: UInt8
    public let compatFlags: UInt8
    /// Payload as received (MAVLink 2 payloads may be truncated; decoding zero-extends them).
    public let payload: [UInt8]
    /// 13-byte signature block if the packet was signed (not verified in this build).
    public let signature: [UInt8]?
    /// The complete frame, STX to end, exactly as received. This is what goes into a .tlog.
    public let raw: [UInt8]

    public var info: MAVMessageInfo? { MAVLinkMessages.info(for: messageID) }
    public var name: String { info?.name ?? "UNKNOWN_\(messageID)" }
    public var isSigned: Bool { signature != nil }

    /// Decode into the generated struct for this message ID.
    public func decode() -> MAVLinkMessage? {
        MAVLinkMessages.decode(id: messageID, payload: payload)
    }

    /// Decode as a specific type; `nil` if the message ID doesn't match.
    public func decode<M: MAVLinkMessage>(_ type: M.Type) -> M? {
        guard messageID == M.mavInfo.id else { return nil }
        return M(payload: MAVLinkPayloadReader(payload, length: M.mavInfo.length))
    }
}

public enum MAVLinkFraming {
    public enum FrameResult {
        /// Not enough bytes yet to decide.
        case needMoreData
        /// Byte at `start` doesn't begin a valid frame (no STX, bad CRC or unknown message ID).
        case invalid(FrameError)
        case frame(MAVLinkPacket, length: Int)
    }

    public enum FrameError: Equatable {
        case notStartByte
        case badCRC
        case unknownMessage(UInt32)
    }

    /// Tries to read one frame starting exactly at `start`.
    public static func frame(in buf: [UInt8], at start: Int) -> FrameResult {
        let avail = buf.count - start
        guard avail >= 1 else { return .needMoreData }
        let stx = buf[start]
        guard stx == MAVLinkConstants.stxV1 || stx == MAVLinkConstants.stxV2 else {
            return .invalid(.notStartByte)
        }
        guard avail >= 2 else { return .needMoreData }
        let len = Int(buf[start + 1])
        let isV2 = stx == MAVLinkConstants.stxV2
        let hdr = isV2 ? MAVLinkConstants.headerLengthV2 : MAVLinkConstants.headerLengthV1
        guard avail >= hdr else { return .needMoreData }

        let incompat: UInt8 = isV2 ? buf[start + 2] : 0
        let compat: UInt8 = isV2 ? buf[start + 3] : 0
        let sigLen = (incompat & MAVLinkConstants.incompatFlagSigned) != 0 ? MAVLinkConstants.signatureLength : 0
        let msgID: UInt32 = isV2
            ? UInt32(buf[start + 7]) | (UInt32(buf[start + 8]) << 8) | (UInt32(buf[start + 9]) << 16)
            : UInt32(buf[start + 5])

        let total = hdr + len + 2 + sigLen
        guard avail >= total else { return .needMoreData }

        // Unknown IDs can't be CRC-checked. The table contains every message Mission
        // Planner knows, so treat them as line noise and let the caller resync.
        guard let info = MAVLinkMessages.info(for: msgID) else {
            return .invalid(.unknownMessage(msgID))
        }
        let crcEnd = start + hdr + len
        var crc = X25CRC.calculate(buf[(start + 1)..<crcEnd])
        crc = X25CRC.accumulate(info.crcExtra, crc)
        let received = UInt16(buf[crcEnd]) | (UInt16(buf[crcEnd + 1]) << 8)
        guard crc == received else { return .invalid(.badCRC) }

        let packet = MAVLinkPacket(
            version: isV2 ? .v2 : .v1,
            sequence: isV2 ? buf[start + 4] : buf[start + 2],
            systemID: isV2 ? buf[start + 5] : buf[start + 3],
            componentID: isV2 ? buf[start + 6] : buf[start + 4],
            messageID: msgID,
            incompatFlags: incompat,
            compatFlags: compat,
            payload: Array(buf[(start + hdr)..<crcEnd]),
            signature: sigLen > 0 ? Array(buf[(crcEnd + 2)..<(crcEnd + 2 + sigLen)]) : nil,
            raw: Array(buf[start..<(start + total)])
        )
        return .frame(packet, length: total)
    }

    /// MAVLink 2 frame. Trailing zero bytes of the payload are stripped (minimum one byte),
    /// exactly like MavlinkParse.GenerateMAVLinkPacket20.
    public static func encodeV2(messageID: UInt32, crcExtra: UInt8, payload: [UInt8],
                                sequence: UInt8, systemID: UInt8, componentID: UInt8) -> [UInt8] {
        var n = payload.count
        while n > 1 && payload[n - 1] == 0 { n -= 1 }
        var out: [UInt8] = [
            MAVLinkConstants.stxV2, UInt8(n), 0, 0, sequence, systemID, componentID,
            UInt8(truncatingIfNeeded: messageID),
            UInt8(truncatingIfNeeded: messageID >> 8),
            UInt8(truncatingIfNeeded: messageID >> 16),
        ]
        out.reserveCapacity(out.count + n + 2)
        out += payload[0..<n]
        let crc = X25CRC.accumulate(crcExtra, X25CRC.calculate(out[1...]))
        out.append(UInt8(truncatingIfNeeded: crc))
        out.append(UInt8(truncatingIfNeeded: crc >> 8))
        return out
    }

    /// MAVLink 1 frame (message IDs < 256 only). Mission Planner sends the full struct,
    /// extension fields included and untruncated; this matches it.
    public static func encodeV1(messageID: UInt32, crcExtra: UInt8, payload: [UInt8],
                                sequence: UInt8, systemID: UInt8, componentID: UInt8) -> [UInt8]? {
        guard messageID < 256, payload.count <= 255 else { return nil }
        var out: [UInt8] = [MAVLinkConstants.stxV1, UInt8(payload.count), sequence, systemID, componentID,
                            UInt8(messageID)]
        out += payload
        let crc = X25CRC.accumulate(crcExtra, X25CRC.calculate(out[1...]))
        out.append(UInt8(truncatingIfNeeded: crc))
        out.append(UInt8(truncatingIfNeeded: crc >> 8))
        return out
    }

    public static func encode<M: MAVLinkMessage>(_ message: M, version: MAVLinkPacket.Version = .v2,
                                                 sequence: UInt8, systemID: UInt8, componentID: UInt8) -> [UInt8] {
        let info = M.mavInfo
        let payload = message.payloadBytes()
        if version == .v1, let v1 = encodeV1(messageID: info.id, crcExtra: info.crcExtra, payload: payload,
                                             sequence: sequence, systemID: systemID, componentID: componentID) {
            return v1
        }
        return encodeV2(messageID: info.id, crcExtra: info.crcExtra, payload: payload,
                        sequence: sequence, systemID: systemID, componentID: componentID)
    }
}

/// Streaming parser. Feed it whatever chunks the transport delivers (UDP datagrams,
/// TCP segments, 20-byte BLE notifications); it returns every complete, CRC-valid frame.
/// On a bad frame it drops a single byte and rescans, so a corrupted or fake STX never
/// swallows the real frames that follow.
public final class MAVLinkParser {
    public struct Stats: Equatable {
        public var packetsReceived = 0
        public var crcErrors = 0
        public var unknownMessages = 0
        public var bytesDiscarded = 0
        /// Estimated from sequence-number gaps, per (sysid, compid), like MAVState.packetslost.
        public var packetsLost = 0

        public init() {}
    }

    public private(set) var stats = Stats()
    private var buffer: [UInt8] = []
    private var start = 0
    private var lastSequence: [UInt16: UInt8] = [:]

    public init() {}

    public func reset() {
        buffer.removeAll()
        start = 0
        lastSequence.removeAll()
        stats = Stats()
    }

    public func parse(_ data: Data) -> [MAVLinkPacket] { parse([UInt8](data)) }

    public func parse(_ bytes: [UInt8]) -> [MAVLinkPacket] {
        buffer.append(contentsOf: bytes)
        var out: [MAVLinkPacket] = []
        scan: while start < buffer.count {
            switch MAVLinkFraming.frame(in: buffer, at: start) {
            case .needMoreData:
                break scan
            case .invalid(let err):
                switch err {
                case .badCRC: stats.crcErrors += 1
                case .unknownMessage: stats.unknownMessages += 1
                case .notStartByte: break
                }
                stats.bytesDiscarded += 1
                start += 1
            case .frame(let packet, let length):
                start += length
                stats.packetsReceived += 1
                trackSequence(packet)
                out.append(packet)
            }
        }
        if start >= buffer.count {
            buffer.removeAll(keepingCapacity: true)
            start = 0
        } else if start > 4096 {
            buffer.removeFirst(start)
            start = 0
        }
        return out
    }

    private func trackSequence(_ p: MAVLinkPacket) {
        let key = (UInt16(p.systemID) << 8) | UInt16(p.componentID)
        if let last = lastSequence[key] {
            let gap = Int(p.sequence &- (last &+ 1))
            // A huge "gap" is almost always a vehicle reboot / second link; don't count it.
            if gap > 0 && gap < 128 { stats.packetsLost += gap }
        }
        lastSequence[key] = p.sequence
    }
}

/// Stamps outgoing messages with our system/component ID and a rolling sequence number.
/// Defaults match Mission Planner's GCS identity (sysid 255, compid 190 = MAV_COMP_ID_MISSIONPLANNER).
public final class MAVLinkSender {
    public var systemID: UInt8
    public var componentID: UInt8
    public var version: MAVLinkPacket.Version
    public private(set) var nextSequence: UInt8 = 0
    private let lock = NSLock()

    public init(systemID: UInt8 = 255, componentID: UInt8 = 190, version: MAVLinkPacket.Version = .v2) {
        self.systemID = systemID
        self.componentID = componentID
        self.version = version
    }

    /// Returns the next sequence number and advances it (thread-safe).
    public func takeSequence() -> UInt8 {
        lock.lock()
        defer { lock.unlock() }
        let seq = nextSequence
        nextSequence &+= 1
        return seq
    }

    public func pack<M: MAVLinkMessage>(_ message: M) -> [UInt8] {
        let seq = takeSequence()
        return MAVLinkFraming.encode(message, version: version, sequence: seq,
                                     systemID: systemID, componentID: componentID)
    }
}
