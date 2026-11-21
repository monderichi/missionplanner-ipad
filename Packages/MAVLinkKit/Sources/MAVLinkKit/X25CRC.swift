// REA Parity Source: MissionPlanner ExtLibs/Mavlink/MavlinkCRC.cs (crc_accumulate / crc_calculate)
// CRC-16/MCRF4XX ("X.25" in MAVLink docs), seed 0xFFFF. Check value for "123456789" is 0x6F91.

public enum X25CRC {
    public static let seed: UInt16 = 0xFFFF

    @inline(__always)
    public static func accumulate(_ byte: UInt8, _ crc: UInt16) -> UInt16 {
        var tmp = byte ^ UInt8(truncatingIfNeeded: crc)
        tmp ^= tmp << 4 // UInt8 shift: overflowing bits are discarded, as in the C implementation
        let t = UInt16(tmp)
        return (crc >> 8) ^ (t << 8) ^ (t << 3) ^ (t >> 4)
    }

    public static func calculate<S: Sequence>(_ bytes: S, seed: UInt16 = X25CRC.seed) -> UInt16
        where S.Element == UInt8 {
        var crc = seed
        for b in bytes { crc = accumulate(b, crc) }
        return crc
    }
}
