// REA Parity Source: MissionPlanner ExtLibs/Utilities/DFLog.cs + BinaryLog.cs (DataFlash .bin parser);
// Log/LogBrowse.cs (message/field list, MODE and PARM extraction).
// Record = 0xA3 0x95 <type> <payload>. FMT (type 128, 89 bytes) defines every other type. Foundation-only,
// single pass over the bytes, columnar storage, resyncs byte-by-byte over garbage.

import Foundation

public enum DataFlashError: Error, CustomStringConvertible {
    case noRecords
    public var description: String {
        switch self {
        case .noRecords: return "No DataFlash records found (is this a .bin log?)"
        }
    }
}

public struct DataFlashLog {
    public struct Format {
        public let type: UInt8
        public let length: Int          // total record length incl. 3 header bytes
        public let name: String
        public let format: String
        public let columns: [String]    // all labels, including string/array ones
    }

    /// Numeric columns of one message type (strings and arrays are skipped), stored columnar.
    public struct MessageSeries {
        public let name: String
        /// Labels of the numeric columns only, same order as `values`.
        public internal(set) var columns: [String]
        public internal(set) var values: [[Double]]
        public internal(set) var count: Int
        /// Index into `columns` of "TimeUS" (microseconds), if the message has one.
        public internal(set) var timeColumn: Int?
    }

    public struct ModeChange {
        public let time: Double     // seconds (absolute log time)
        public let mode: Int
        public let name: String
    }

    public struct TextMessage {
        public let time: Double
        public let text: String
    }

    public let formats: [UInt8: Format]
    public let messages: [String: MessageSeries]
    public let modeChanges: [ModeChange]
    /// PARM messages: name -> last value.
    public let parameters: [String: Double]
    public let texts: [TextMessage]
    /// Number of records successfully decoded (FMT included).
    public let recordCount: Int
    /// Bytes skipped while resyncing.
    public let skippedBytes: Int
    /// Smallest first TimeUS (seconds) over all messages; subtract for "seconds from log start".
    public let startTime: Double
    /// Largest last TimeUS (seconds).
    public let endTime: Double

    public var messageNames: [String] { messages.keys.sorted() }

    public func count(of message: String) -> Int { messages[message]?.count ?? 0 }

    /// Numeric column labels (TimeUS excluded).
    public func columns(of message: String) -> [String] {
        guard let m = messages[message] else { return [] }
        var out: [String] = []
        for (i, c) in m.columns.enumerated() where i != m.timeColumn { out.append(c) }
        return out
    }

    /// Time (seconds, absolute log time; falls back to the record index if the message has no TimeUS)
    /// and values of one column.
    public func values(message: String, column: String) -> (t: [Double], v: [Double]) {
        guard let m = messages[message], let ci = m.columns.firstIndex(of: column) else { return ([], []) }
        let v = m.values[ci]
        if let ti = m.timeColumn {
            return (m.values[ti].map { $0 * 1e-6 }, v)
        }
        return ((0..<v.count).map { Double($0) }, v)
    }

    // MARK: Decimation

    /// Min/max decimation: every bucket keeps its smallest and largest sample (in time order), so spikes
    /// survive. Result length <= maxPoints (maxPoints < 2 is treated as 2).
    public static func downsample(t: [Double], v: [Double], maxPoints: Int) -> (t: [Double], v: [Double]) {
        let n = min(t.count, v.count)
        let limit = max(2, maxPoints)
        if n <= limit { return (Array(t.prefix(n)), Array(v.prefix(n))) }
        let buckets = limit / 2
        var ot: [Double] = []
        var ov: [Double] = []
        ot.reserveCapacity(limit)
        ov.reserveCapacity(limit)
        for b in 0..<buckets {
            let lo = b * n / buckets
            let hi = (b + 1) * n / buckets
            if lo >= hi { continue }
            var iMin = lo
            var iMax = lo
            var vMin = v[lo]
            var vMax = v[lo]
            var i = lo + 1
            while i < hi {
                let x = v[i]
                if x < vMin { vMin = x; iMin = i }
                if x > vMax { vMax = x; iMax = i }
                i += 1
            }
            if iMin == iMax {
                ot.append(t[iMin]); ov.append(v[iMin])
            } else {
                let a = min(iMin, iMax)
                let c = max(iMin, iMax)
                ot.append(t[a]); ov.append(v[a])
                ot.append(t[c]); ov.append(v[c])
            }
        }
        return (ot, ov)
    }

    // MARK: Parser

    private enum Kind {
        case i8, u8, i16, u16, i32, u32, f32, f64, i64, u64
        case str, skip
    }

    private struct Op {
        var kind: Kind
        var offset: Int        // from record start
        var size: Int
        var scale: Double      // 0 = none
        var column: Int        // index into numeric columns, -1 for str/skip
    }

    private final class Builder {
        let format: Format
        let ops: [Op]
        let columnNames: [String]
        var values: [[Double]]
        var count = 0
        let timeColumn: Int?
        let nameOp: Op?
        let valueColumn: Int
        let isParm: Bool
        let isMsg: Bool
        let isMode: Bool

        init(format: Format, ops: [Op], columnNames: [String], timeColumn: Int?, nameOp: Op?, valueColumn: Int) {
            self.format = format
            self.ops = ops
            self.columnNames = columnNames
            self.values = Array(repeating: [], count: columnNames.count)
            self.timeColumn = timeColumn
            self.nameOp = nameOp
            self.valueColumn = valueColumn
            self.isParm = format.name == "PARM"
            self.isMsg = format.name == "MSG"
            self.isMode = format.name == "MODE"
        }
    }

    private static func charInfo(_ c: Character) -> (Kind, Int, Double)? {
        switch c {
        case "b": return (.i8, 1, 0)
        case "B", "M": return (.u8, 1, 0)
        case "h": return (.i16, 2, 0)
        case "H": return (.u16, 2, 0)
        case "i": return (.i32, 4, 0)
        case "I": return (.u32, 4, 0)
        case "f": return (.f32, 4, 0)
        case "d": return (.f64, 8, 0)
        case "n": return (.str, 4, 0)
        case "N": return (.str, 16, 0)
        case "Z": return (.str, 64, 0)
        case "c": return (.i16, 2, 0.01)
        case "C": return (.u16, 2, 0.01)
        case "e": return (.i32, 4, 0.01)
        case "E": return (.u32, 4, 0.01)
        case "L": return (.i32, 4, 1e-7)
        case "q": return (.i64, 8, 0)
        case "Q": return (.u64, 8, 0)
        case "a": return (.skip, 64, 0)
        default: return nil
        }
    }

    private static func makeBuilder(_ f: Format) -> Builder? {
        let chars = Array(f.format)
        var ops: [Op] = []
        var names: [String] = []
        var offset = 3
        var timeCol: Int?
        var nameOp: Op?
        var valueCol = -1
        for (i, ch) in chars.enumerated() {
            guard let info = charInfo(ch) else { return nil }
            let label = i < f.columns.count ? f.columns[i] : "col\(i)"
            var op = Op(kind: info.0, offset: offset, size: info.1, scale: info.2, column: -1)
            switch info.0 {
            case .str:
                if nameOp == nil && (label == "Name" || label == "Message") { nameOp = op }
            case .skip:
                break
            default:
                op.column = names.count
                if label == "TimeUS" && timeCol == nil { timeCol = names.count }
                if label == "Value" { valueCol = names.count }
                names.append(label)
            }
            ops.append(op)
            offset += info.1
        }
        if offset != f.length { return nil }
        return Builder(format: f, ops: ops, columnNames: names, timeColumn: timeCol, nameOp: nameOp, valueColumn: valueCol)
    }

    public static func parse(_ data: Data, maxRecords: Int = 5_000_000) throws -> DataFlashLog {
        var builders = [Builder?](repeating: nil, count: 256)
        var order: [Builder] = []
        var formats: [UInt8: Format] = [:]
        var parameters: [String: Double] = [:]
        var texts: [TextMessage] = []
        var rawModes: [(Double, Int)] = []
        var records = 0
        var skipped = 0

        data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
            let n = raw.count
            guard n >= 3, let base = raw.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            let p = UnsafeBufferPointer<UInt8>(start: base, count: n)

            func u16(_ o: Int) -> UInt16 { UInt16(p[o]) | (UInt16(p[o + 1]) << 8) }
            func u32(_ o: Int) -> UInt32 {
                UInt32(p[o]) | (UInt32(p[o + 1]) << 8) | (UInt32(p[o + 2]) << 16) | (UInt32(p[o + 3]) << 24)
            }
            func u64(_ o: Int) -> UInt64 { UInt64(u32(o)) | (UInt64(u32(o + 4)) << 32) }
            func str(_ o: Int, _ len: Int) -> String {
                var e = o
                while e < o + len && p[e] != 0 { e += 1 }
                return String(decoding: UnsafeBufferPointer<UInt8>(start: base + o, count: e - o), as: UTF8.self)
            }

            var pos = 0
            while pos + 3 <= n && records < maxRecords {
                if p[pos] != 0xA3 || p[pos + 1] != 0x95 { pos += 1; skipped += 1; continue }
                let type = Int(p[pos + 2])
                if type == 128 {
                    if pos + 89 > n { break }
                    let ty = p[pos + 3]
                    let ln = Int(p[pos + 4])
                    let labels = str(pos + 25, 64).split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
                    let fm = Format(type: ty, length: ln, name: str(pos + 5, 4), format: str(pos + 9, 16), columns: labels)
                    if ty != 128 && ln >= 3 {
                        var known = false
                        if let old = builders[Int(ty)], old.format.format == fm.format && old.format.name == fm.name { known = true }
                        if !known, let b = makeBuilder(fm) {
                            builders[Int(ty)] = b
                            formats[ty] = fm
                            order.append(b)
                        }
                    }
                    records += 1
                    pos += 89
                    continue
                }
                guard let b = builders[type] else { pos += 1; skipped += 1; continue }
                let ln = b.format.length
                if pos + ln > n { break }
                for op in b.ops where op.column >= 0 {
                    let o = pos + op.offset
                    var x: Double
                    switch op.kind {
                    case .i8: x = Double(Int8(bitPattern: p[o]))
                    case .u8: x = Double(p[o])
                    case .i16: x = Double(Int16(bitPattern: u16(o)))
                    case .u16: x = Double(u16(o))
                    case .i32: x = Double(Int32(bitPattern: u32(o)))
                    case .u32: x = Double(u32(o))
                    case .f32: x = Double(Float(bitPattern: u32(o)))
                    case .f64: x = Double(bitPattern: u64(o))
                    case .i64: x = Double(Int64(bitPattern: u64(o)))
                    case .u64: x = Double(u64(o))
                    default: x = 0
                    }
                    if op.scale != 0 { x *= op.scale }
                    b.values[op.column].append(x)
                }
                if b.isParm {
                    if let no = b.nameOp, b.valueColumn >= 0, let last = b.values[b.valueColumn].last {
                        parameters[str(pos + no.offset, no.size)] = last
                    }
                } else if b.isMsg {
                    if let no = b.nameOp {
                        var tt = 0.0
                        if let tc = b.timeColumn, let tv = b.values[tc].last { tt = tv * 1e-6 }
                        texts.append(TextMessage(time: tt, text: str(pos + no.offset, no.size)))
                    }
                } else if b.isMode {
                    var mi: Int? = b.columnNames.firstIndex(of: "Mode")
                    if mi == nil { mi = b.columnNames.firstIndex(of: "ModeNum") }
                    if let tc = b.timeColumn, let mi = mi, let tv = b.values[tc].last, let mv = b.values[mi].last {
                        rawModes.append((tv * 1e-6, Int(mv)))
                    }
                }
                b.count += 1
                records += 1
                pos += ln
            }
        }

        if records == 0 { throw DataFlashError.noRecords }

        var messages: [String: MessageSeries] = [:]
        var tmin = Double.infinity
        var tmax = -Double.infinity
        for b in order where b.count > 0 {
            if let existing = messages[b.format.name], existing.count >= b.count { continue }
            messages[b.format.name] = MessageSeries(name: b.format.name, columns: b.columnNames, values: b.values,
                                                    count: b.count, timeColumn: b.timeColumn)
            if let tc = b.timeColumn, let f = b.values[tc].first, let l = b.values[tc].last {
                tmin = min(tmin, f * 1e-6)
                tmax = max(tmax, l * 1e-6)
            }
        }
        if tmin == Double.infinity { tmin = 0; tmax = 0 }
        let modes = rawModes.map { ModeChange(time: $0.0, mode: $0.1, name: DataFlashLog.copterModeName($0.1)) }
        return DataFlashLog(formats: formats, messages: messages, modeChanges: modes, parameters: parameters,
                            texts: texts, recordCount: records, skippedBytes: skipped,
                            startTime: tmin, endTime: tmax)
    }

    /// ArduCopter custom mode numbers (other vehicles show "Mode N").
    public static func copterModeName(_ m: Int) -> String {
        let names: [Int: String] = [
            0: "Stabilize", 1: "Acro", 2: "AltHold", 3: "Auto", 4: "Guided", 5: "Loiter", 6: "RTL",
            7: "Circle", 9: "Land", 11: "Drift", 13: "Sport", 14: "Flip", 15: "AutoTune", 16: "PosHold",
            17: "Brake", 18: "Throw", 19: "Avoid_ADSB", 20: "Guided_NoGPS", 21: "Smart_RTL",
            22: "FlowHold", 23: "Follow", 24: "ZigZag", 25: "SystemID", 26: "Heli_Autorotate", 27: "Auto RTL",
        ]
        return names[m] ?? "Mode \(m)"
    }
}
