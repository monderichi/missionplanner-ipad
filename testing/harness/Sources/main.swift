// Headless driver for the app's real LinkManager / VehicleModel / stores (compiled for macOS).
// Usage: Harness <scenario> [--kind tcp|udpListen|udpConnect] [--host H] [--port P] [--local-port L]
//                [--ctrl 17001] [--secs N]
// Prints "CHECK PASS|FAIL <name> | <detail>", "NOTE ...", "METRIC k=v", and a final "SCENARIO" line.
// Exit 0 = all checks passed, 1 = a check failed, other = crash (signal) or usage error.

import Foundation
import MAVLinkKit

setvbuf(stdout, nil, _IOLBF, 0)

struct Args {
    var scenario = ""
    var kind = LinkKind.tcp
    var host = "127.0.0.1"
    var port: UInt16 = 5799
    var localPort: UInt16 = 14550
    var ctrl: UInt16 = 17001
    var secs: Double = 0
    var extra: [String: String] = [:]

    init() {
        var it = CommandLine.arguments.dropFirst().makeIterator()
        while let a = it.next() {
            switch a {
            case "--kind":
                switch it.next() ?? "" {
                case "udpListen": kind = .udpListen
                case "udpConnect": kind = .udpConnect
                case "elrs": kind = .elrs
                default: kind = .tcp
                }
            case "--host": host = it.next() ?? host
            case "--port": port = UInt16(it.next() ?? "") ?? port
            case "--local-port": localPort = UInt16(it.next() ?? "") ?? localPort
            case "--ctrl": ctrl = UInt16(it.next() ?? "") ?? ctrl
            case "--secs": secs = Double(it.next() ?? "") ?? 0
            case let s where s.hasPrefix("--"): extra[String(s.dropFirst(2))] = it.next() ?? ""
            case let s where s.hasPrefix("-"): _ = it.next() // NSUserDefaults argument domain (e.g. -speech.enabled)
            default: scenario = a
            }
        }
    }
}

final class Ctx {
    let args: Args
    let link = LinkManager()
    var vehicle: VehicleModel { link.vehicle }
    private(set) var passed = 0
    private(set) var failed = 0
    private let ctrlSock: Int32

    init(args: Args) {
        self.args = args
        ctrlSock = socket(AF_INET, SOCK_DGRAM, 0)
    }

    // MARK: timing

    /// Runs the main run loop (timers, Network.framework callbacks hop to main).
    func pump(_ seconds: Double) {
        let end = Date().addingTimeInterval(seconds)
        while Date() < end {
            RunLoop.main.run(mode: .default, before: min(end, Date().addingTimeInterval(0.05)))
        }
    }

    @discardableResult
    func waitUntil(_ timeout: Double, _ cond: () -> Bool) -> Double? {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if cond() { return Date().timeIntervalSince(start) }
            pump(0.05)
        }
        return cond() ? Date().timeIntervalSince(start) : nil
    }

    // MARK: reporting

    func check(_ name: String, _ ok: Bool, _ detail: @autoclosure () -> String = "") {
        if ok { passed += 1 } else { failed += 1 }
        print("CHECK \(ok ? "PASS" : "FAIL") \(name) | \(detail())")
    }

    func note(_ s: String) { print("NOTE \(s)") }
    func metric(_ k: String, _ v: Any) { print("METRIC \(k)=\(v)") }

    /// What RootView passes to the HUD as `linkAlive` (mirrors RootView after the BUG-001 fix). false => NO HEARTBEAT.
    var uiLinkAliveFlag: Bool { vehicle.heartbeatAlive || vehicle.systemID == nil }

    func snapshot(_ tag: String) {
        let v = vehicle
        let d: [String: Any] = [
            "tag": tag, "state": link.state.description, "active": link.state.isActive,
            "hbAlive": v.heartbeatAlive, "sys": v.systemID.map { Int($0) } ?? -1, "comp": Int(v.componentID),
            "type": v.vehicleTypeName, "mode": v.modeName, "armed": v.armed,
            "roll": String(v.roll), "pitch": String(v.pitch), "yaw": String(v.yaw), "alt": String(v.relativeAltitude),
            "lat": v.latitude.map { String($0) } ?? "nil", "lon": v.longitude.map { String($0) } ?? "nil",
            "gpsFix": Int(v.gpsFixType), "sats": Int(v.satellites), "batt": v.batteryVoltage, "battPct": v.batteryRemaining,
            "attStale": v.attitudeStale, "uiLinkAlive": uiLinkAliveFlag, "params": link.params.params.count,
            "paramState": "\(link.params.downloadState)", "cmd": link.commands.lastResult ?? "nil",
            "cmdOK": link.commands.lastResultOK, "msgs": v.messages.count, "wp": v.currentWaypoint,
            "rx": link.stats.packetsReceived, "lost": link.stats.packetsLost, "crcErr": link.stats.crcErrors,
            "missionBanner": link.mission.banner ?? "nil", "paramBanner": link.params.banner ?? "nil",
        ]
        let data = try! JSONSerialization.data(withJSONObject: d, options: [.sortedKeys])
        print("SNAPSHOT \(String(data: data, encoding: .utf8)!)")
    }

    // MARK: fake drone control (UDP text commands, see fake_drone.py)

    func drone(_ command: String) {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = args.ctrl.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")
        let bytes = Array(command.utf8)
        _ = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                sendto(ctrlSock, bytes, bytes.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        note("drone <- \(command)")
    }

    // MARK: common steps

    func connect(kind: LinkKind? = nil) {
        link.recordTLog = true
        link.connect(kind: kind ?? args.kind, host: args.host, port: args.port, localPort: args.localPort, bleDevice: nil)
    }

    @discardableResult
    func connectAndWaitForVehicle(timeout: Double = 8) -> Bool {
        connect()
        let t = waitUntil(timeout) { vehicle.heartbeatAlive && vehicle.systemID != nil }
        check("vehicle heartbeat within \(Int(timeout)) s", t != nil, "t=\(t.map { String(format: "%.2f", $0) } ?? "timeout") state=\(link.state.description)")
        return t != nil
    }

    @discardableResult
    func waitParams(timeout: Double = 30) -> Bool {
        let t = waitUntil(timeout) {
            if case .complete = link.params.downloadState { return true } else { return false }
        }
        metric("param_download_s", t.map { String(format: "%.2f", $0) } ?? "timeout")
        check("parameter download completes", t != nil, "count=\(link.params.params.count) state=\(link.params.downloadState)")
        return t != nil
    }

    func finish() -> Never {
        print("SCENARIO \(args.scenario): \(passed) pass, \(failed) fail")
        link.disconnect()
        pump(0.3)
        exit(failed == 0 ? 0 : 1)
    }
}

let args = Args()
guard let scenario = Scenarios.all[args.scenario] else {
    print("usage: Harness <scenario> ...\nscenarios: \(Scenarios.all.keys.sorted().joined(separator: " "))")
    exit(64)
}
let ctx = Ctx(args: args)
print("NOTE speech.enabled=\(ctx.link.speech.enabled) documents=\(DocumentsStore.shared.root.path)")
if ctx.link.speech.enabled { ctx.link.speech.enabled = false } // never talk out loud on the test Mac
scenario(ctx)
ctx.finish()
