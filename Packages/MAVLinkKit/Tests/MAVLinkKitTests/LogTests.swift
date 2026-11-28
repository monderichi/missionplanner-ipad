import XCTest
@testable import MAVLinkKit

/// ArduPilot-like log server: streams LOG_DATA for the requested range, lossy both ways.
final class SimulatedLogVehicle {
    let logs: [UInt16: [UInt8]]
    var dropRate: Double
    /// LOG_ENTRY size can be larger than the real file (ArduPilot rounds); EOF is a short chunk.
    var reportedExtra = 0
    private var rng = SystemRandomNumberGenerator()
    private let sender = MAVLinkSender(systemID: 1, componentID: 1)
    private(set) var ended = false

    init(logs: [UInt16: [UInt8]], dropRate: Double) {
        self.logs = logs
        self.dropRate = dropRate
    }

    private func lost() -> Bool { Double.random(in: 0..<1, using: &rng) < dropRate }

    func receive(_ frames: [[UInt8]]) -> [[UInt8]] {
        var out: [MAVLinkMessage] = []
        let parser = MAVLinkParser()
        for f in frames where !lost() {
            for p in parser.parse(f) {
                if p.decode(MAV.LogRequestList.self) != nil {
                    for (i, id) in logs.keys.sorted().enumerated() {
                        out.append(MAV.LogEntry(timeUtc: 1_700_000_000 + UInt32(i), size: UInt32(logs[id]!.count + reportedExtra),
                                                id: id, numLogs: UInt16(logs.count), lastLogNum: logs.keys.max()!))
                    }
                } else if let r = p.decode(MAV.LogRequestData.self), let data = logs[r.id] {
                    var ofs = Int(r.ofs)
                    let end = min(data.count, Int(r.ofs) + Int(r.count))
                    while ofs < end {
                        let n = min(90, data.count - ofs)
                        var chunk = [UInt8](repeating: 0, count: 90)
                        for k in 0..<n { chunk[k] = data[ofs + k] }
                        out.append(MAV.LogData(ofs: UInt32(ofs), id: r.id, count: UInt8(n), data: chunk))
                        ofs += 90
                    }
                    if end == data.count && data.count % 90 == 0 {
                        out.append(MAV.LogData(ofs: UInt32(data.count), id: r.id, count: 0, data: [UInt8](repeating: 0, count: 90)))
                    }
                } else if p.decode(MAV.LogRequestEnd.self) != nil {
                    ended = true
                }
            }
        }
        return out.filter { _ in !lost() }.map { sender.pack(any: $0) }
    }
}

final class LogTests: XCTestCase {
    private let gcs = MAVLinkSender()

    func testListThenDownloadThroughLoss() {
        var bytes = [UInt8](repeating: 0, count: 50_000)
        for i in bytes.indices { bytes[i] = UInt8(truncatingIfNeeded: i * 7 + i / 300) }
        let v = SimulatedLogVehicle(logs: [3: bytes, 4: Array(bytes.prefix(1234))], dropRate: 0.2)
        v.reportedExtra = 50

        // list
        let list = LogListSession(targetSystem: 1)
        var toSend = list.start(now: 0)
        var listed: [LogEntryInfo]?
        let parser = MAVLinkParser()
        var t: TimeInterval = 0
        while listed == nil && t < 120 {
            for r in v.receive(toSend.map { gcs.pack(any: $0) }) {
                for p in parser.parse(r) {
                    if let e = p.decode(MAV.LogEntry.self) {
                        for ev in list.handle(e, now: t) { if case .listed(let l) = ev { listed = l } }
                    }
                }
            }
            t += 0.5
            let r = list.tick(now: t)
            toSend = r.messages
            for ev in r.events { if case .listed(let l) = ev { listed = l } }
        }
        XCTAssertEqual(listed?.map(\.id), [3, 4])

        // download log 3 (size reported 50 bytes too big; EOF = short chunk)
        let s = LogDownloadSession(entry: listed![0], targetSystem: 1)
        toSend = s.start(now: 0)
        var result: Data?
        t = 0
        while result == nil && t < 2000 {
            for r in v.receive(toSend.map { gcs.pack(any: $0) }) {
                for p in parser.parse(r) {
                    if let d = p.decode(MAV.LogData.self) {
                        let h = s.handle(d, now: t)
                        toSend += h.messages
                        for ev in h.events { if case .finished(let data) = ev { result = data } }
                    }
                }
            }
            if result != nil { break }
            t += 0.5
            let r = s.tick(now: t)
            toSend = r.messages
            for ev in r.events { if case .failed(let why) = ev { XCTFail(why); return } }
        }
        XCTAssertEqual(result.map { [UInt8]($0) }, bytes)
    }

    func testExactMultipleOf90AndEmptyLog() {
        let bytes = [UInt8](repeating: 0xAB, count: 900)
        let v = SimulatedLogVehicle(logs: [1: bytes], dropRate: 0)
        let s = LogDownloadSession(entry: LogEntryInfo(id: 1, size: 900, timeUtc: 0), targetSystem: 1)
        var result: Data?
        let parser = MAVLinkParser()
        for r in v.receive(s.start(now: 0).map { gcs.pack(any: $0) }) {
            for p in parser.parse(r) {
                if let d = p.decode(MAV.LogData.self) {
                    for ev in s.handle(d, now: 0).events { if case .finished(let data) = ev { result = data } }
                }
            }
        }
        XCTAssertEqual(result?.count, 900)
        XCTAssertFalse(s.active)

        let empty = LogDownloadSession(entry: LogEntryInfo(id: 9, size: 0, timeUtc: 0), targetSystem: 1)
        XCTAssertTrue(empty.start(now: 0).first is MAV.LogRequestEnd)
    }

    /// BUG-019: file-backed download through 20 % loss, size reported 50 bytes too big: the file holds exactly the log
    /// (chunks written in place, out of order), and nothing is kept in RAM.
    func testFileBackedDownloadThroughLoss() throws {
        var bytes = [UInt8](repeating: 0, count: 50_000)
        for i in bytes.indices { bytes[i] = UInt8(truncatingIfNeeded: i * 13 + i / 77) }
        let v = SimulatedLogVehicle(logs: [3: bytes], dropRate: 0.2)
        v.reportedExtra = 50
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("logtest-\(UUID().uuidString).bin.partial")
        defer { try? FileManager.default.removeItem(at: url) }
        let s = LogDownloadSession(entry: LogEntryInfo(id: 3, size: UInt32(bytes.count + 50), timeUtc: 0), targetSystem: 1,
                                   fileURL: url)
        var toSend = s.start(now: 0)
        XCTAssertNil(s.startError)
        var done: (URL, Int)?
        let parser = MAVLinkParser()
        var t: TimeInterval = 0
        while done == nil && t < 2000 {
            for r in v.receive(toSend.map { gcs.pack(any: $0) }) {
                for p in parser.parse(r) {
                    if let d = p.decode(MAV.LogData.self) {
                        let h = s.handle(d, now: t)
                        toSend += h.messages
                        for ev in h.events { if case .finishedFile(let u, let n) = ev { done = (u, n) } }
                    }
                }
            }
            if done != nil { break }
            t += 0.5
            let r = s.tick(now: t)
            toSend = r.messages
            for ev in r.events { if case .failed(let why) = ev { XCTFail(why); return } }
        }
        XCTAssertEqual(done?.0, url)
        XCTAssertEqual(done?.1, bytes.count)
        XCTAssertEqual([UInt8](try Data(contentsOf: url)), bytes)
    }

    /// BUG-019: a file that can't be created fails at start, without sending a request.
    func testFileBackedDownloadReportsUncreatableFile() {
        let url = URL(fileURLWithPath: "/nonexistent-dir-\(UUID().uuidString)/log.partial")
        let s = LogDownloadSession(entry: LogEntryInfo(id: 1, size: 900, timeUtc: 0), targetSystem: 1, fileURL: url)
        XCTAssertTrue(s.start(now: 0).isEmpty)
        XCTAssertNotNil(s.startError)
        XCTAssertFalse(s.active)
    }
}
