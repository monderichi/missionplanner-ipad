// In-process fuzzer: random-payload frames with VALID CRC for every message id the app knows, fed through
// MAVLinkParser and routed exactly like LinkManager.process (LinkManager.swift:309-339) into the real
// VehicleModel and stores. A Swift trap prints the last message id from the SIGTRAP handler.

import Darwin
import Foundation
import MAVLinkKit

var fuzzLastID: UInt32 = 0
var fuzzIteration = 0

private func fuzzTrapHandler(_ sig: Int32) {
    let s = "FUZZ CRASH at iteration \(fuzzIteration) msgid \(fuzzLastID) (\(MAVLinkMessages.info(for: fuzzLastID)?.name ?? "?"))\n"
    _ = s.withCString { write(2, $0, strlen($0)) }
    signal(sig, SIG_DFL)
    raise(sig)
}

enum Fuzz {
    static func run(_ c: Ctx) {
        signal(SIGTRAP, fuzzTrapHandler)
        signal(SIGILL, fuzzTrapHandler)
        let n = Int(c.args.extra["iterations"] ?? "200000") ?? 200_000
        var rng = SystemRandomNumberGenerator()
        let skip = Set((c.args.extra["skip"] ?? "").split(separator: ",").compactMap { UInt32($0) })
        let ids = (0..<UInt32(65536)).filter { MAVLinkMessages.info(for: $0) != nil && !skip.contains($0) }
        c.note("fuzzing \(ids.count) message ids x \(n) frames, skipping \(skip.sorted())")
        let link = c.link, v = c.vehicle
        let parser = MAVLinkParser()
        // lock onto sys 1 / comp 1 and attach the sessions, as vehicleAppeared() does
        let hb = MAVLinkSender(systemID: 1, componentID: 1).pack(MAV.Heartbeat(customMode: 0, type: 2, autopilot: 3, baseMode: 0x81, systemStatus: 3, mavlinkVersion: 3))
        for p in parser.parse(hb) { _ = v.handle(p) }
        link.params.attach(systemID: 1, componentID: 1, vehicleType: 2, narrowLink: false)
        link.commands.attach(systemID: 1, componentID: 1, narrowLink: false)
        link.mission.attach(systemID: 1, componentID: 1, vehicleType: 2, narrowLink: false)
        link.logs.attach(systemID: 1, componentID: 1)
        link.mission.read(.mission)   // make the mission session busy so MISSION_* frames are processed
        link.logs.refresh()
        var seq: UInt8 = 0
        let t0 = Date()
        for i in 0..<n {
            fuzzIteration = i
            let id = ids.randomElement(using: &rng)!
            let info = MAVLinkMessages.info(for: id)!
            let len = Int.random(in: 1...max(1, info.length), using: &rng)
            var payload = (0..<len).map { _ in UInt8.random(in: 0...255, using: &rng) }
            if Int.random(in: 0..<4, using: &rng) == 0 { // bias floats toward NaN/Inf/huge
                for k in stride(from: 0, to: payload.count - 3, by: 4) where Bool.random(using: &rng) {
                    let f: Float = [.nan, .infinity, -.infinity, 3e38, -3e38, 1e10, -1].randomElement(using: &rng)!
                    withUnsafeBytes(of: f.bitPattern.littleEndian) { payload.replaceSubrange(k..<k + 4, with: $0) }
                }
            }
            let sys: UInt8 = Int.random(in: 0..<10, using: &rng) == 0 ? UInt8.random(in: 0...255, using: &rng) : 1
            seq &+= 1
            let frame = MAVLinkFraming.encodeV2(messageID: id, crcExtra: info.crcExtra, payload: payload, sequence: seq,
                                                systemID: sys, componentID: 1)
            for p in parser.parse(frame) {
                fuzzLastID = p.messageID
                if p.messageID == MAV.RadioStatus.mavInfo.id { v.handleRadio(p) }
                _ = v.handle(p)
                guard p.systemID == 1 else { continue }
                if p.messageID == MAV.ParamValue.mavInfo.id, let m = p.decode(MAV.ParamValue.self) { link.params.handle(m) }
                else if p.messageID == MAV.CommandAck.mavInfo.id, let m = p.decode(MAV.CommandAck.self) { link.commands.handle(m) }
                else if p.messageID == MAV.CommandLong.mavInfo.id, let m = p.decode(MAV.CommandLong.self) { link.calibration.handle(m) }
                else if LinkManager.missionMessageIDs.contains(p.messageID) { link.mission.handle(p) }
                else if p.messageID == MAV.LogEntry.mavInfo.id || p.messageID == MAV.LogData.mavInfo.id { link.logs.handle(p) }
            }
            if i % 500 == 0 { link.params.tick(); link.commands.tick(); link.mission.tick(); link.logs.tick(); v.tick() }
            if i % 20_000 == 0 && link.mission.busy == nil { link.mission.read(.mission) }
        }
        c.metric("fuzz_frames", n); c.metric("fuzz_s", String(format: "%.1f", Date().timeIntervalSince(t0)))
        c.metric("parsed", parser.stats.packetsReceived)
        c.check("no trap in VehicleModel/stores for \(n) random valid-CRC frames", true)
        c.note("after fuzz: roll=\(v.roll) lat=\(String(describing: v.latitude)) messages=\(v.messages.count) params=\(link.params.params.count) esc=\(v.escCount)")
        c.check("model left with finite HUD values", Probes.intConvertible(v.roll) && Probes.intConvertible(v.pitch) && v.heading.isFinite,
                "roll=\(v.roll) pitch=\(v.pitch) heading=\(v.heading)")
    }
}
