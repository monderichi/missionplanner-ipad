// REA Parity Source: MissionPlanner ExtLibs/Mavlink/MavlinkUtil.cs (ByteArrayToStructure /
// StructureToByteArray). MAVLink payloads are little-endian, packed, fields in wire order.

import Foundation

/// Static description of one message type (from Mission Planner's MAVLINK_MESSAGE_INFOS).
public struct MAVMessageInfo: Equatable, Sendable {
    public let id: UInt32
    public let name: String
    /// CRC_EXTRA seed byte appended to the checksum; derived from the message definition.
    public let crcExtra: UInt8
    /// Length without MAVLink 2 extension fields (what a MAVLink 1 receiver expects).
    public let minLength: Int
    /// Full length including extension fields.
    public let length: Int

    public init(id: UInt32, name: String, crcExtra: UInt8, minLength: Int, length: Int) {
        self.id = id
        self.name = name
        self.crcExtra = crcExtra
        self.minLength = minLength
        self.length = length
    }
}

/// Every generated message struct (see Generated/MAVLinkMessages.swift) conforms to this.
public protocol MAVLinkMessage {
    static var mavInfo: MAVMessageInfo { get }
    init(payload: MAVLinkPayloadReader)
    func encode(into writer: inout MAVLinkPayloadWriter)
}

extension MAVLinkMessage {
    public var mavInfo: MAVMessageInfo { Self.mavInfo }

    /// Full-length (untruncated) payload bytes.
    public func payloadBytes() -> [UInt8] {
        var w = MAVLinkPayloadWriter(length: Self.mavInfo.length)
        encode(into: &w)
        return w.bytes
    }
}

/// Little-endian reader over a payload, zero-extended to the message's full length
/// (MAVLink 2 senders strip trailing zero bytes).
public struct MAVLinkPayloadReader {
    public let bytes: [UInt8]

    public init(_ payload: [UInt8], length: Int) {
        if payload.count >= length {
            bytes = payload
        } else {
            bytes = payload + [UInt8](repeating: 0, count: length - payload.count)
        }
    }

    @inline(__always) public func uint8(_ o: Int) -> UInt8 { bytes[o] }
    @inline(__always) public func int8(_ o: Int) -> Int8 { Int8(bitPattern: bytes[o]) }
    @inline(__always) public func uint16(_ o: Int) -> UInt16 {
        UInt16(bytes[o]) | (UInt16(bytes[o + 1]) << 8)
    }
    @inline(__always) public func int16(_ o: Int) -> Int16 { Int16(bitPattern: uint16(o)) }
    @inline(__always) public func uint32(_ o: Int) -> UInt32 {
        UInt32(bytes[o]) | (UInt32(bytes[o + 1]) << 8) | (UInt32(bytes[o + 2]) << 16) | (UInt32(bytes[o + 3]) << 24)
    }
    @inline(__always) public func int32(_ o: Int) -> Int32 { Int32(bitPattern: uint32(o)) }
    @inline(__always) public func uint64(_ o: Int) -> UInt64 {
        UInt64(uint32(o)) | (UInt64(uint32(o + 4)) << 32)
    }
    @inline(__always) public func int64(_ o: Int) -> Int64 { Int64(bitPattern: uint64(o)) }
    @inline(__always) public func float(_ o: Int) -> Float { Float(bitPattern: uint32(o)) }
    @inline(__always) public func double(_ o: Int) -> Double { Double(bitPattern: uint64(o)) }
}

/// Little-endian writer producing a full-length payload.
public struct MAVLinkPayloadWriter {
    public private(set) var bytes: [UInt8]

    public init(length: Int) {
        bytes = [UInt8](repeating: 0, count: length)
    }

    public mutating func put(_ v: UInt8, _ o: Int) { bytes[o] = v }
    public mutating func put(_ v: Int8, _ o: Int) { bytes[o] = UInt8(bitPattern: v) }
    public mutating func put(_ v: UInt16, _ o: Int) {
        bytes[o] = UInt8(truncatingIfNeeded: v)
        bytes[o + 1] = UInt8(truncatingIfNeeded: v >> 8)
    }
    public mutating func put(_ v: Int16, _ o: Int) { put(UInt16(bitPattern: v), o) }
    public mutating func put(_ v: UInt32, _ o: Int) {
        for k in 0..<4 { bytes[o + k] = UInt8(truncatingIfNeeded: v >> (8 * k)) }
    }
    public mutating func put(_ v: Int32, _ o: Int) { put(UInt32(bitPattern: v), o) }
    public mutating func put(_ v: UInt64, _ o: Int) {
        for k in 0..<8 { bytes[o + k] = UInt8(truncatingIfNeeded: v >> (8 * k)) }
    }
    public mutating func put(_ v: Int64, _ o: Int) { put(UInt64(bitPattern: v), o) }
    public mutating func put(_ v: Float, _ o: Int) { put(v.bitPattern, o) }
    public mutating func put(_ v: Double, _ o: Int) { put(v.bitPattern, o) }
}

/// Helpers for MAVLink `char[N]` fields (param_id, STATUSTEXT text, ...), which the
/// generated structs expose as `[UInt8]`. They are NUL-padded and not necessarily NUL-terminated.
public enum MAVString {
    public static func decode(_ bytes: [UInt8]) -> String {
        let trimmed = bytes.prefix { $0 != 0 }
        return String(decoding: trimmed, as: UTF8.self)
    }

    public static func encode(_ string: String, length: Int) -> [UInt8] {
        var out = Array(string.utf8.prefix(length))
        if out.count < length { out += [UInt8](repeating: 0, count: length - out.count) }
        return out
    }
}
