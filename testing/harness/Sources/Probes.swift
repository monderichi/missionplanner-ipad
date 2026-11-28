// Crash probes: each runs ONE suspicious code path in its own process (testing/scenarios/run.py
// runs them as `Harness probe:<name>`). A Swift runtime trap ends the process with SIGTRAP/SIGILL,
// which the runner reports as CRASH. "real" probes call the app's own code; "expr" probes evaluate
// the exact expression copied from a SwiftUI view (views can't be compiled without Xcode/UIKit).

import Darwin
import Foundation
import MAVLinkKit

/// Hides a constant from the optimiser so the trap happens at run time, as in the app.
@inline(never) func opaque<T>(_ x: T) -> T { x }

enum Probes {
    /// Built entry by entry in a function: as one dictionary literal (or one immediately-invoked closure) of closures it
    /// exceeded the CI compiler's type-check budget; function bodies are type-checked statement by statement.
    static let all: [String: (Ctx) -> Void] = makeAll()

    private static func makeAll() -> [String: (Ctx) -> Void] {
        var d = [String: (Ctx) -> Void]()
        // real app/MAVLinkKit code
        d["probe:accelcal_nan"] = { (c: Ctx) in accel(c, .nan) }
        d["probe:accelcal_neg"] = { (c: Ctx) in accel(c, -1) }
        d["probe:accelcal_huge"] = { (c: Ctx) in accel(c, 1e10) }
        d["probe:waypoint_file_nan"] = { (c: Ctx) in waypoint(c, lat: "nan") }
        d["probe:waypoint_file_huge_lat"] = { (c: Ctx) in waypoint(c, lat: "1e10") }
        d["probe:waypoint_file_unicode"] = { (c: Ctx) in
            let text = "QGC WPL 110\n0\t1\t0\t16\t0\t0\t0\t0\t-35.1\t149.1\t584\t1\n1\t0\t3\t16\t0\t0\t0\t0\t-35,1\t149.1\t50\t1\n"
            do { _ = try WaypointFile.parse(text); c.check("comma-decimal line rejected or parsed", true) }
            catch { c.check("comma-decimal line rejected with an error", true, "\(error)") }
            let emoji = "QGC WPL 110\n0\t1\t0\t16\t0\t0\t0\t0\t🚁\t149.1\t584\t1\n"
            c.check("emoji line rejected", (try? WaypointFile.parse(emoji)) == nil)
        }
        d["probe:waypoint_file_huge"] = { (c: Ctx) in
            var s = "QGC WPL 110\n"
            for i in 0..<70_000 { s += "\(i)\t0\t3\t16\t0\t0\t0\t0\t-35.1\t149.1\t50\t1\n" }
            let items = (try? WaypointFile.parse(s)) ?? []
            c.note("parsed \(items.count) items; now MissionStore.setItems (MissionStore.swift:196 UInt16(i))")
            c.link.mission.setItems(.mission, items)
            c.check("70k-line .waypoints loads without crash", true, "\(c.link.mission.mission.count)")
        }
        d["probe:param_file_nan"] = { (c: Ctx) in
            let f = ParamFile.parse("FOO_A,nan\nFOO_B,inf\nFOO_C,1e40\nWAY_TOO_LONG_PARAM_NAME_X,1\nÄÖ,1\n")
            c.check("non-finite values rejected by ParamFile.parse", f.values.allSatisfy(\.isFinite), "\(f)")
        }
        d["probe:mission_item_nan_coord"] = { (c: Ctx) in
            _ = MissionItem(latitude: .nan, longitude: 0)
            c.check("MissionItem(latitude: .nan) does not trap", true)
        }
        d["probe:survey_nan_angle"] = { (c: Ctx) in
            var o = SurveyGrid.Options(); o.angle = .nan
            let poly = [GeoPoint(latitude: -35.36, longitude: 149.16), GeoPoint(latitude: -35.361, longitude: 149.16),
                        GeoPoint(latitude: -35.361, longitude: 149.161)]
            let pts = SurveyGrid.generate(polygon: poly, options: o)
            c.note("\(pts.count) points, first=\(String(describing: pts.first))")
            c.link.mission.surveyPolygon = poly
            _ = c.link.mission.addSurvey(options: o, cameraTriggerDistance: 0)
            c.check("survey with NaN angle does not trap", true)
        }
        d["probe:survey_huge"] = { (c: Ctx) in
            var o = SurveyGrid.Options(); o.spacing = 0.6
            let poly = [GeoPoint(latitude: 0, longitude: 0), GeoPoint(latitude: 0.2, longitude: 0),
                        GeoPoint(latitude: 0.2, longitude: 0.2), GeoPoint(latitude: 0, longitude: 0.2)]
            c.link.mission.surveyPolygon = poly
            let t0 = Date()
            let n = c.link.mission.addSurvey(options: o, cameraTriggerDistance: 0)
            c.metric("survey_points", n); c.metric("survey_s", String(format: "%.1f", Date().timeIntervalSince(t0)))
            c.check("22 km survey at 0.6 m spacing handled (no trap)", true, "\(c.link.mission.mission.count) items")
        }
        // exact expressions from SwiftUI views
        d["probe:hud_label_nan"] = { (c: Ctx) in
            let roll = Double(opaque(Float.nan)) * 180 / .pi, pitch = 0.0, heading = 0.0
            // HUDView accessibility label, mirrors the fixed HUDView.whole() (BUG-003)
            let s = "Artificial horizon: roll \(Probes.whole(roll)), pitch \(Probes.whole(pitch)), heading \(Probes.whole(heading))"
            c.check("HUD label with NaN roll", true, s)
        }
        d["probe:hud_label_huge"] = { (c: Ctx) in
            let roll = Double(opaque(Float(3e38))) * 180 / .pi
            let s = "roll \(Probes.whole(roll))" // mirrors HUDView.whole (BUG-003)
            c.check("HUD label with 3e38 rad roll", true, s)
        }
        d["probe:fltmode_ch0"] = { (c: Ctx) in
            let rc = [UInt16](repeating: 1500, count: 18)
            let v = opaque(Float(0)) // FLTMODE_CH = 0 ("Disabled", a valid ArduCopter value)
            // mirrors the fixed FlightModesPage (BUG-005)
            let channel = v.isFinite ? Int(max(0, min(32, v.rounded()))) : 0
            let s = channel == 0 ? "Mode switch disabled" : (channel <= rc.count ? String(rc[channel - 1]) : "—")
            c.check("Flight modes page with FLTMODE_CH=0", true, s)
        }
        d["probe:takeoff_alt_huge"] = { (c: Ctx) in
            let takeoffAlt = opaque(1e20) // what TextField(.number) yields for "100000000000000000000"
            // mirrors the fixed ActionsView title (ActionLimits.text, BUG-006)
            let s = "Take off to \(takeoffAlt.isFinite ? String(format: "%.0f", takeoffAlt) : "?") m?"
            c.check("Actions tab with a 21-digit takeoff altitude", true, s)
        }
        d["probe:fltmode_picker_negative"] = { (c: Ctx) in
            let p = opaque(Float(-1)) // FLTMODEn read back as -1 (corrupt/unknown)
            let v = UInt32(exactly: p.rounded()) ?? 0 // mirrors the fixed flight-mode picker (BUG-005)
            c.check("Flight mode picker with value -1", true, "\(v)")
        }
        d["probe:waypoint_editor_lat_300"] = { (c: Ctx) in
            var item = MissionItem(latitude: -35.36, longitude: 149.16, altitude: 50)
            let typed = opaque(300.0) // user types 300 in Plan > waypoint > Latitude (PlanView.swift:345)
            item.latitude = typed
            c.check("waypoint editor latitude 300 does not trap", true, "\(item.x)")
        }
        d["probe:elrs_backpack_json"] = { (c: Ctx) in
            let cases = [#"{"ports":{"listen":0,"send":0}}"#, #"{"ports":{"listen":14555,"send":14550},"enabled":false}"#,
                         #"{"ports":{"listen":70000,"send":1}}"#, #"{"enabled":true}"#]
            for j in cases {
                let info = try? JSONDecoder().decode(ELRSBackpackInfo.self, from: Data(j.utf8))
                c.note("\(j) -> \(info.map { "listen=\($0.ports.listen) send=\($0.ports.send) summary=\($0.summary)" } ?? "nil (fallback to typed ports)")")
            }
            let zero = try? JSONDecoder().decode(ELRSBackpackInfo.self, from: Data(cases[0].utf8))
            // mirrors the fixed LinkManager.connect (BUG-023): port 0 falls back to the typed port
            let listen = zero.map { $0.ports.listen } ?? 0
            let used = listen != 0 ? listen : 14555
            c.check("ports 0/0 from backpack fall back to the typed ports", used == 14555, "would use \(used)")
        }
        // New DataFlash (.bin) parser from origin/main: mutate the real fixture and feed random data.
        d["probe:dataflash_fuzz"] = dataflashFuzz
        // MAVLinkKit command session: same-command-id overwrite
        d["probe:command_overwrite"] = { (c: Ctx) in
            let s = CommandSession(targetSystem: 1)
            _ = s.arm(true, now: 0)
            _ = s.arm(false, now: 0.1) // user hits Disarm before the arm ACK arrives
            let ev = s.handle(MAV.CommandAck(command: MAVCmd.componentArmDisarm, result: 0, progress: 0, resultParam2: 0,
                                             targetSystem: 255, targetComponent: 190), now: 0.2)
            let r = s.tick(now: 10)
            c.check("ACK of the ARM must not complete the pending DISARM",
                    !(ev == [.accepted(command: MAVCmd.componentArmDisarm)] && s.pendingCommands.isEmpty && r.messages.isEmpty),
                    "events=\(ev) pending=\(s.pendingCommands) resent=\(r.messages.count)")
        }
        return d
    }

    /// Separate, explicitly typed function: as an inline closure it exceeded the CI compiler's type-check budget.
    static func dataflashFuzz(_ c: Ctx) {
        signal(SIGTRAP, fuzzTrapHandler)
        signal(SIGILL, fuzzTrapHandler)
        let fallback = "Packages/MAVLinkKit/Tests/MAVLinkKitTests/Fixtures/sample.bin"
        let fixturePath: String = CommandLine.arguments.first(where: { (a: String) -> Bool in a.hasSuffix("sample.bin") }) ?? fallback
        let fixture = URL(fileURLWithPath: fixturePath)
        guard let base = try? Data(contentsOf: fixture) else { return c.check("fixture readable", false, fixture.path) }
        var rng = SystemRandomNumberGenerator()
        var ok = 0
        var threw = 0
        let n: Int = Int(c.args.extra["iterations"] ?? "20000") ?? 20000
        let t0 = Date()
        for i in 0..<n {
            fuzzIteration = i
            var d: [UInt8] = [UInt8](base)
            switch i % 4 {
            case 0:
                let flips: Int = Int.random(in: 1...20, using: &rng)
                for _ in 0..<flips {
                    let k: Int = Int.random(in: 0..<d.count, using: &rng)
                    d[k] = UInt8.random(in: 0...255, using: &rng)
                }
            case 1:
                let keep: Int = Int.random(in: 0..<d.count, using: &rng)
                d = Array(d.prefix(keep))
            case 2: // corrupt a FMT record's length/format fields (FMT = A3 95 80)
                var fmts: [Int] = []
                var k = 0
                while k < d.count - 6 {
                    if d[k] == 0xA3 && d[k + 1] == 0x95 && d[k + 2] == 0x80 { fmts.append(k) }
                    k += 1
                }
                if let f = fmts.randomElement(using: &rng) {
                    d[f + 4] = UInt8.random(in: 0...255, using: &rng)
                    d[f + 3] = UInt8.random(in: 0...255, using: &rng)
                }
            default:
                let len: Int = Int.random(in: 0...4000, using: &rng)
                var r: [UInt8] = []
                r.reserveCapacity(len)
                for _ in 0..<len { r.append(UInt8.random(in: 0...255, using: &rng)) }
                if r.count > 3 && Bool.random(using: &rng) { r[0] = 0xA3; r[1] = 0x95; r[2] = 0x80 }
                d = r
            }
            do { _ = try DataFlashLog.parse(Data(d)); ok += 1 } catch { threw += 1 }
        }
        c.metric("dataflash_inputs", n); c.metric("parsed", ok); c.metric("threw", threw)
        c.metric("seconds", String(format: "%.1f", Date().timeIntervalSince(t0)))
        c.check("\(n) mutated/random .bin inputs parsed or rejected without a trap", true)
    }

    static func accel(_ c: Ctx, _ p1: Float) {
        let cal = CalibrationStore()
        // LinkManager.swift:330 routes any COMMAND_LONG from the vehicle here
        cal.handle(MAV.CommandLong(param1: p1, param2: 0, param3: 0, param4: 0, param5: 0, param6: 0, param7: 0,
                                   command: 42429, targetSystem: 255, targetComponent: 190, confirmation: 0))
        c.check("ACCELCAL_VEHICLE_POS param1=\(p1) handled", true, "\(cal.accel)")
    }

    static func waypoint(_ c: Ctx, lat: String) {
        let text = "QGC WPL 110\n0\t1\t0\t16\t0\t0\t0\t0\t\(lat)\t149.1\t584\t1\n"
        let r = try? WaypointFile.parse(text)
        c.check(".waypoints with lat=\(lat) handled", true, "\(String(describing: r?.count))")
    }

    /// ServoView.isMotor (FlightDataTabs.swift:169-173): unknown function => not a motor (fail-open).
    static func servoIsMotor(_ f: Float?) -> Bool {
        guard let f, f.isFinite else { return true } // mirrors the fixed ServoView.isMotor (BUG-014)
        let fn = Int(f.rounded())
        return (33...40).contains(fn) || (82...85).contains(fn)
    }

    static func intConvertible(_ d: Double) -> Bool { d.isFinite && abs(d) < 9.2e18 }

    /// Mirrors HUDView.whole (BUG-003 fix).
    static func whole(_ v: Double) -> Int { v.isFinite ? Int(max(-1_000_000, min(1_000_000, v.rounded()))) : 0 }

    /// FlightModesPage (SetupView.swift:414-438) indexes rcChannels[channel-1] when channel <= count.
    static func flightModesPageSafe(_ value: Float?, _ count: Int) -> Bool {
        let v = value ?? 5 // mirrors the fixed FlightModesPage.channel (BUG-005): 0 means "disabled", never indexed
        let channel = v.isFinite ? Int(max(0, min(32, v.rounded()))) : 0
        return channel == 0 || (channel >= 1 && channel <= count) || channel > count
    }

    static func rssMB() -> Double {
        var info = mach_task_basic_info()
        var n = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(n)) { task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &n) }
        }
        return kr == KERN_SUCCESS ? Double(info.resident_size) / 1_048_576 : -1
    }

    static func cpuSeconds() -> Double {
        var u = rusage()
        getrusage(RUSAGE_SELF, &u)
        return Double(u.ru_utime.tv_sec) + Double(u.ru_utime.tv_usec) / 1e6 + Double(u.ru_stime.tv_sec) + Double(u.ru_stime.tv_usec) / 1e6
    }

    static func openFDs() -> Int {
        (try? FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count) ?? -1
    }
}
