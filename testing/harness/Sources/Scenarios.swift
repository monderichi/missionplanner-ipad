// Scenarios for the headless harness. Each one pairs with a fake-drone (or SITL) setup started by
// testing/scenarios/run.py (see SCENARIOS there for the drone arguments).

import Foundation
import MAVLinkKit

enum Scenarios {
    static let all: [String: (Ctx) -> Void] = [
        "connect": connect, "params": params, "param_set": paramSet, "param_file_roundtrip": paramFileRoundtrip,
        "arm_disarm": armDisarm, "reject_arm": rejectArm, "no_ack": noAck, "mode_change": modeChange,
        "guided_takeoff": guidedTakeoff, "mission_roundtrip": missionRoundtrip, "auto_mission": autoMission,
        "fence_rally": fenceRally, "link_loss": linkLoss, "tcp_drop": tcpDrop, "stale_after_disconnect": staleAfterDisconnect,
        "nan_values": nanValues, "bad_latlon": badLatLon, "gps_loss": gpsLoss, "malformed": malformed,
        "dup_reorder": dupReorder, "second_vehicle": secondVehicle, "other_gcs": otherGCS, "reboot": reboot,
        "disconnect_on_arm": disconnectOnArm, "battery_failsafe": batteryFailsafe, "statustext_flood": statustextFlood,
        "high_rate": highRate, "large_mission": largeMission, "log_download": logDownload, "replay": replay,
        "connect_spam": connectSpam, "disconnect_mid_transfer": disconnectMidTransfer, "fly_here": flyHere,
        "param_nan": paramNaN, "mode_change_mid_mission": modeChangeMidMission, "lossy_link": lossyLink,
        "compid_switch": compidSwitch, "long_session": longSession, "sitl_smoke": sitlSmoke,
        "link_loss_proxy": linkLossProxy, "sitl_arm": sitlArm, "servo_before_params": servoBeforeParams,
    ].merging(Probes.all, uniquingKeysWith: { a, _ in a })

    // MARK: B. connection

    static func connect(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(2.5)
        c.snapshot("connected")
        c.check("B1 firmware shown", c.vehicle.vehicleTypeName == "ArduCopter", c.vehicle.vehicleTypeName)
        c.check("B1 mode shown", c.vehicle.modeName != "—", c.vehicle.modeName)
        c.check("B1 GPS shown", c.vehicle.gpsFixType >= 3, "fix=\(c.vehicle.gpsFixType) sats=\(c.vehicle.satellites)")
        c.check("B2 attitude flowing (no NO ATTITUDE banner)", !c.vehicle.attitudeStale, "stale=\(c.vehicle.attitudeStale)")
        c.check("B3 battery plausible", c.vehicle.batteryVoltage > 10 && c.vehicle.batteryVoltage < 60, "\(c.vehicle.batteryVoltage) V")
        c.check("B3 position plausible", c.vehicle.position != nil, "\(String(describing: c.vehicle.position))")
        let src = c.vehicle.heartbeatSources
        c.check("B6 heartbeat sources list FC", src["1/1"] != nil, "\(src)")
        c.check("B6 ATTITUDE counted", (c.vehicle.messageCounts["ATTITUDE"] ?? 0) > 5, "\(c.vehicle.messageCounts["ATTITUDE"] ?? 0)")
        c.check("tlog recorded", c.link.tlogURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
                c.link.tlogURL?.path ?? "nil")
    }

    // MARK: C. parameters

    static func params(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.waitParams(timeout: Double(c.args.extra["param-timeout"] ?? "40") ?? 40)
        let expected = Int(c.args.extra["expect-params"] ?? "0") ?? 0
        if expected > 0 {
            c.check("C1 count matches vehicle", c.link.params.params.count == expected, "\(c.link.params.params.count) vs \(expected)")
        }
        c.note("banner: \(c.link.params.banner ?? "nil")")
        c.check("C4 metadata loaded for FRAME_CLASS", c.waitUntil(5) { c.link.params.metadata["FRAME_CLASS"] != nil } != nil,
                "meta=\(c.link.params.metadata.count)")
    }

    static func paramSet(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        let name = c.args.extra["param"] ?? "SR6_EXTRA1"
        let old = c.link.params.params[name]?.value ?? 0
        c.link.params.set(name, old + 1)
        let ok = c.waitUntil(5) { c.link.params.params[name]?.value == old + 1 && c.link.params.pendingNames.isEmpty }
        c.check("C3 write confirmed", ok != nil, "banner=\(c.link.params.banner ?? "nil")")
        c.link.params.set(name, old)
        c.waitUntil(5) { c.link.params.params[name]?.value == old && c.link.params.pendingNames.isEmpty }
        c.check("C3 set back", c.link.params.params[name]?.value == old, "\(String(describing: c.link.params.params[name]?.value))")
        // input validation: non-finite values must not reach the vehicle
        c.link.params.set(name, .nan)
        c.pump(0.5)
        c.check("C3 NaN write is refused locally", !c.link.params.pendingNames.contains(name),
                "pending=\(c.link.params.pendingNames) banner=\(c.link.params.banner ?? "nil")")
        c.waitUntil(10) { c.link.params.pendingNames.isEmpty }
        c.note("after NaN: banner=\(c.link.params.banner ?? "nil")")
        c.link.params.set("NOT_A_PARAM_X", 1)
        let unknown = c.waitUntil(12) { c.link.params.pendingNames.isEmpty }
        c.note("unknown param write: settled in \(unknown.map { String(format: "%.1f", $0) } ?? "timeout") s banner=\(c.link.params.banner ?? "nil")")
        c.check("unknown-name write reports a failure", (c.link.params.banner ?? "").contains("NOT_A_PARAM_X"),
                c.link.params.banner ?? "nil")
    }

    static func paramFileRoundtrip(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        do {
            let url = try c.link.params.save()
            c.check("C2 .param saved", FileManager.default.fileExists(atPath: url.path), url.lastPathComponent)
            let text = try String(contentsOf: url)
            let file = ParamFile.parse(text)
            let d = c.link.params.differences(from: file)
            c.check("C5 reload shows 0 differences", d.changes.isEmpty && d.unknown.isEmpty,
                    "changes=\(d.changes.map(\.name).prefix(5)) unknown=\(d.unknown.prefix(5))")
        } catch {
            c.check("C2 .param saved", false, "\(error)")
        }
    }

    // MARK: F. actions

    static func armDisarm(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        c.link.commands.arm(true)
        let t = c.waitUntil(5) { c.vehicle.armed }
        c.check("F3 arm", t != nil, "result=\(c.link.commands.lastResult ?? "nil")")
        c.waitUntil(3) { c.link.commands.pending.isEmpty }
        c.check("F3 arm ACK shown", c.link.commands.lastResult == "Arm/disarm: accepted", c.link.commands.lastResult ?? "nil")
        c.link.commands.arm(false)
        c.check("F3 disarm", c.waitUntil(5) { !c.vehicle.armed } != nil, "result=\(c.link.commands.lastResult ?? "nil")")
        // double tap: arm twice quickly, then disarm immediately (arm ACK must not satisfy the disarm)
        c.link.commands.arm(true)
        c.link.commands.arm(true)
        c.link.commands.arm(false)
        c.waitUntil(6) { c.link.commands.pending.isEmpty }
        c.pump(1.5)
        c.snapshot("after arm,arm,disarm")
        c.check("rapid arm/arm/disarm ends disarmed", !c.vehicle.armed, "armed=\(c.vehicle.armed)")
    }

    static func rejectArm(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.arm(true)
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.pump(0.5)
        c.check("F3 refusal shown", c.link.commands.lastResultOK == false && (c.link.commands.lastResult ?? "").contains("Failed"),
                c.link.commands.lastResult ?? "nil")
        c.check("F3 PreArm reason in Messages", c.vehicle.messages.contains { $0.text.hasPrefix("PreArm") },
                c.vehicle.messages.first?.text ?? "none")
        c.check("still disarmed", !c.vehicle.armed)
    }

    static func noAck(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.setMode(5, name: "Loiter")
        let t = c.waitUntil(15) { c.link.commands.pending.isEmpty }
        c.metric("no_ack_timeout_s", t.map { String(format: "%.1f", $0) } ?? "never")
        c.check("timeout reported", (c.link.commands.lastResult ?? "").contains("no answer"), c.link.commands.lastResult ?? "nil")
        c.waitUntil(3) { c.vehicle.modeName == "Loiter" }
        c.note("mode actually is \(c.vehicle.modeName) while banner says '\(c.link.commands.lastResult ?? "nil")'")
        c.check("UI does not claim failure when the mode did change", !(c.vehicle.modeName == "Loiter" && c.link.commands.lastResultOK == false),
                "mode=\(c.vehicle.modeName) banner=\(c.link.commands.lastResult ?? "nil")")
    }

    static func modeChange(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        for (m, n) in [(UInt32(5), "Loiter"), (2, "AltHold"), (0, "Stabilize")] {
            c.link.commands.setMode(m, name: n)
            let ok = c.waitUntil(5) { c.vehicle.customMode == m && c.link.commands.pending.isEmpty }
            c.check("F2 mode \(n)", ok != nil, "mode=\(c.vehicle.modeName) result=\(c.link.commands.lastResult ?? "nil")")
        }
        // spam: tap 3 different modes within 50 ms; the last tap must win and the banner must name it
        c.link.commands.setMode(5, name: "Loiter")
        c.link.commands.setMode(6, name: "RTL")
        c.link.commands.setMode(2, name: "AltHold")
        c.waitUntil(6) { c.link.commands.pending.isEmpty }
        c.pump(1.2)
        c.check("mode spam: last tap wins", c.vehicle.customMode == 2, "mode=\(c.vehicle.modeName) banner=\(c.link.commands.lastResult ?? "nil")")
    }

    static func guidedTakeoff(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.setMode(4, name: "Guided")
        c.waitUntil(5) { c.vehicle.customMode == 4 }
        c.link.commands.arm(true)
        c.waitUntil(5) { c.vehicle.armed }
        c.link.commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, 10], label: "Takeoff to 10 m")
        let up = c.waitUntil(20) { c.vehicle.relativeAltitude > 9 }
        c.check("takeoff reaches 10 m", up != nil, "alt=\(c.vehicle.relativeAltitude) result=\(c.link.commands.lastResult ?? "nil")")
        c.link.commands.command(MissionCmd.doChangeSpeed, params: [1, 3, -1, 0], label: "Change speed to 3 m/s")
        c.waitUntil(4) { c.link.commands.pending.isEmpty }
        c.check("change speed accepted", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
        c.link.commands.setMode(9, name: "Land")
        let down = c.waitUntil(30) { !c.vehicle.armed }
        c.check("land + auto disarm", down != nil, "alt=\(c.vehicle.relativeAltitude) armed=\(c.vehicle.armed)")
    }

    // MARK: E. planning

    static func sampleMission(_ c: Ctx, n: Int = 3) -> [MissionItem] {
        let home = c.vehicle.position ?? GeoPoint(latitude: -35.3632621, longitude: 149.1652374)
        var items = [MissionItem(frame: MAVFrame.global, command: MissionCmd.waypoint, latitude: home.latitude,
                                 longitude: home.longitude, altitude: 584)]
        items.append(MissionItem(command: MissionCmd.takeoff, altitude: 10))
        for i in 0..<n {
            items.append(MissionItem(command: MissionCmd.waypoint, param1: i == 0 ? 2 : 0,
                                     latitude: home.latitude + 0.0002 * Double(i + 1), longitude: home.longitude + 0.0001 * Double(i % 3),
                                     altitude: 15))
        }
        items.append(MissionItem(command: MissionCmd.returnToLaunch))
        return items
    }

    static func missionRoundtrip(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        let items = sampleMission(c)
        c.link.mission.setItems(.mission, items)
        c.link.mission.write(.mission)
        let w = c.waitUntil(15) { c.link.mission.busy == nil }
        c.check("E4 write", w != nil && (c.link.mission.banner ?? "").contains("accepted"), c.link.mission.banner ?? "nil")
        c.link.mission.clear(.mission)
        c.link.mission.read(.mission)
        c.waitUntil(15) { c.link.mission.busy == nil }
        let back = c.link.mission.mission
        c.check("E4 same mission comes back", back.count == items.count &&
                zip(back.dropFirst(), items.dropFirst()).allSatisfy { $0.command == $1.command && $0.x == $1.x && $0.y == $1.y && $0.z == $1.z },
                "sent \(items.count) got \(back.count) banner=\(c.link.mission.banner ?? "nil")")
        do {
            let url = try c.link.mission.save(name: "harness roundtrip")
            let parsed = try WaypointFile.parse(String(contentsOf: url))
            c.check("E5 .waypoints save/parse", parsed.count == back.count, "\(parsed.count) vs \(back.count)")
        } catch { c.check("E5 .waypoints save/parse", false, "\(error)") }
        // empty mission write
        c.link.mission.setItems(.mission, [])
        c.link.mission.write(.mission)
        c.waitUntil(10) { c.link.mission.busy == nil }
        c.note("empty mission write: banner=\(c.link.mission.banner ?? "nil") items=\(c.link.mission.mission.count)")
    }

    static func autoMission(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        c.link.mission.setItems(.mission, sampleMission(c, n: 2))
        c.link.mission.write(.mission)
        c.waitUntil(15) { c.link.mission.busy == nil }
        c.link.commands.setMode(4, name: "Guided")
        c.waitUntil(5) { c.vehicle.customMode == 4 }
        c.link.commands.arm(true)
        c.waitUntil(5) { c.vehicle.armed }
        c.link.commands.setMode(3, name: "Auto")
        c.check("G2 Auto engaged", c.waitUntil(5) { c.vehicle.customMode == 3 } != nil, c.vehicle.modeName)
        let reached = c.waitUntil(60) { (c.vehicle.lastReachedWaypoint ?? 0) >= 3 }
        c.check("G2 waypoints reached in order", reached != nil, "lastReached=\(String(describing: c.vehicle.lastReachedWaypoint)) wp=\(c.vehicle.currentWaypoint)")
        c.check("G1 trail drawn", c.vehicle.trail.count > 5, "trail=\(c.vehicle.trail.count)")
        let landed = c.waitUntil(90) { !c.vehicle.armed }
        c.check("RTL + land + disarm", landed != nil, "mode=\(c.vehicle.modeName) alt=\(c.vehicle.relativeAltitude)")
    }

    static func fenceRally(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let h = c.vehicle.position ?? GeoPoint(latitude: -35.36, longitude: 149.16)
        for (dx, dy) in [(0.001, 0.001), (0.001, -0.001), (-0.001, -0.001), (-0.001, 0.001)] {
            c.link.mission.add(.fence, at: GeoPoint(latitude: h.latitude + dx, longitude: h.longitude + dy))
        }
        c.link.mission.add(.rally, at: GeoPoint(latitude: h.latitude + 0.0005, longitude: h.longitude))
        let fence = c.link.mission.fence, rally = c.link.mission.rally
        c.link.mission.write(.fence)
        c.waitUntil(10) { c.link.mission.busy == nil }
        c.link.mission.write(.rally)
        c.waitUntil(10) { c.link.mission.busy == nil }
        c.link.mission.clear(.fence); c.link.mission.clear(.rally)
        c.link.mission.read(.fence)
        c.waitUntil(10) { c.link.mission.busy == nil }
        c.link.mission.read(.rally)
        c.waitUntil(10) { c.link.mission.busy == nil }
        c.check("E7 fence round-trips", c.link.mission.fence.count == fence.count && c.link.mission.fence.map(\.x) == fence.map(\.x),
                "\(c.link.mission.fence.count) vs \(fence.count); p1=\(c.link.mission.fence.map(\.param1))")
        c.check("E7 rally round-trips", c.link.mission.rally.count == rally.count, "\(c.link.mission.rally.count) vs \(rally.count)")
    }

    // MARK: robustness

    static func linkLoss(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        c.drone("silent 9")
        let lost = c.waitUntil(9) { !c.vehicle.heartbeatAlive }
        c.metric("link_lost_detect_s", lost.map { String(format: "%.1f", $0) } ?? "never")
        c.check("B5 NO HEARTBEAT shown within 7 s", lost != nil && lost! < 7 && !c.uiLinkAliveFlag, "t=\(String(describing: lost)) uiLinkAlive=\(c.uiLinkAliveFlag)")
        c.snapshot("during loss")
        c.note("during loss the HUD still shows roll=\(c.vehicle.roll) mode=\(c.vehicle.modeName) armed=\(c.vehicle.armed) attStale=\(c.vehicle.attitudeStale)")
        let back = c.waitUntil(12) { c.vehicle.heartbeatAlive }
        c.check("B5 recovers", back != nil, "state=\(c.link.state.description)")
        c.check("attitude resumes", c.waitUntil(6) { !c.vehicle.attitudeStale } != nil, "stale=\(c.vehicle.attitudeStale)")
    }

    static func tcpDrop(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        c.drone("quit") // fake drone process exits -> TCP RST/FIN
        c.waitUntil(4) { !c.link.state.isActive }
        c.pump(6)
        c.snapshot("after tcp drop")
        c.check("link failure visible as NO HEARTBEAT banner", !c.uiLinkAliveFlag,
                "state=\(c.link.state.description) hbAlive=\(c.vehicle.heartbeatAlive) uiLinkAlive=\(c.uiLinkAliveFlag)")
        c.check("stale ARMED/mode not presented as live", !(c.link.state.isActive == false && c.vehicle.modeName != "—"),
                "mode=\(c.vehicle.modeName) after link failure")
        // the runner restarts the drone after 3 s; does the app reconnect by itself?
        let back = c.waitUntil(15) { c.vehicle.heartbeatAlive }
        c.check("TCP auto-reconnect after remote restart", back != nil, "state=\(c.link.state.description)")
    }

    static func staleAfterDisconnect(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.arm(true)
        c.waitUntil(5) { c.vehicle.armed }
        c.pump(1)
        c.link.disconnect()
        c.pump(1.5)
        c.snapshot("after user disconnect")
        c.check("after Disconnect no ARMED/mode/attitude shown as live",
                !(c.vehicle.armed || c.vehicle.modeName != "—"),
                "armed=\(c.vehicle.armed) mode=\(c.vehicle.modeName) uiLinkAlive=\(c.uiLinkAliveFlag) battery=\(c.vehicle.batteryVoltage)")
    }

    static func nanValues(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(2)
        c.snapshot("nan")
        let v = c.vehicle
        c.check("attitude sanitised (finite)", v.roll.isFinite && v.pitch.isFinite && v.yaw.isFinite, "roll=\(v.roll) pitch=\(v.pitch) yaw=\(v.yaw)")
        c.check("VFR_HUD sanitised (finite)", v.groundspeed.isFinite && v.altitudeMSL.isFinite && v.climbRate.isFinite,
                "gs=\(v.groundspeed) alt=\(v.altitudeMSL) climb=\(v.climbRate)")
        // HUDView.swift:142 evaluates Int(roll), Int(pitch), Int(heading) on every render:
        c.check("HUD accessibility label would not trap", Probes.intConvertible(v.roll) && Probes.intConvertible(v.pitch),
                "Int(\(v.roll)) traps")
    }

    static func badLatLon(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(2)
        let la = c.vehicle.latitude ?? 0, lo = c.vehicle.longitude ?? 0
        c.check("out-of-range position rejected", abs(la) <= 90 && abs(lo) <= 180, "lat=\(la) lon=\(lo) trail=\(c.vehicle.trail.count)")
    }

    static func gpsLoss(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(2)
        let before = c.vehicle.position
        c.drone("fault gps_loss on")
        c.pump(3)
        c.snapshot("gps lost")
        c.check("GPS loss shown (No GPS)", c.vehicle.gpsFixType == 0, c.vehicle.gpsFixName)
        c.check("position marked stale/unknown after GPS loss", c.vehicle.position == nil || c.vehicle.position != before,
                "map still shows \(String(describing: c.vehicle.position)) as current position")
        c.drone("fault gps_loss off")
        c.check("GPS recovers", c.waitUntil(5) { c.vehicle.gpsFixType >= 3 } != nil)
    }

    static func malformed(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(10)
        c.snapshot("malformed")
        let s = c.link.stats
        c.metric("crc_errors", s.crcErrors); c.metric("unknown", s.unknownMessages); c.metric("discarded", s.bytesDiscarded)
        c.check("still alive under noise", c.vehicle.heartbeatAlive && !c.vehicle.attitudeStale, "")
        c.check("noise counted", s.crcErrors + s.unknownMessages + s.bytesDiscarded > 0, "\(s)")
        c.check("parameters still download under noise", c.waitParams(timeout: 30))
    }

    static func dupReorder(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(6)
        let s = c.link.stats
        let total = s.packetsReceived + s.packetsLost
        let q = total > 0 ? 100 * Double(s.packetsReceived) / Double(total) : 0
        c.metric("link_quality_pct", String(format: "%.1f", q))
        c.note("stats \(s)")
        c.check("duplicates/reordering do not show as heavy loss (Link >= 90%)", q >= 90, String(format: "%.1f%% lost=%d rx=%d", q, s.packetsLost, s.packetsReceived))
        c.check("params complete with dup/reorder", c.waitParams(timeout: 30))
    }

    static func secondVehicle(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(3)
        c.check("locks onto first vehicle (sys 1)", c.vehicle.systemID == 1, "sys=\(String(describing: c.vehicle.systemID))")
        c.check("ignores sys 2 attitude", abs(c.vehicle.roll) < 10, "roll=\(c.vehicle.roll)")
        c.drone("silent 12")  // only the fake's sys 1 goes quiet? (silent mutes both: documents behaviour)
        c.pump(8)
        c.note("after silence: sys=\(String(describing: c.vehicle.systemID)) hb=\(c.vehicle.heartbeatAlive)")
    }

    static func otherGCS(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(3)
        c.check("another GCS heartbeat is not taken as the vehicle", c.vehicle.systemID == 1 && c.vehicle.vehicleTypeName == "ArduCopter",
                "sys=\(String(describing: c.vehicle.systemID)) sources=\(c.vehicle.heartbeatSources)")
    }

    static func reboot(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        c.link.commands.reboot()
        c.waitUntil(5) { !c.vehicle.heartbeatAlive }
        let back = c.waitUntil(15) { c.vehicle.heartbeatAlive }
        c.check("vehicle back after reboot", back != nil)
        let redl = c.waitUntil(30) { if case .complete = c.link.params.downloadState { return c.link.params.params.count > 0 } else { return false } }
        c.check("params re-downloaded after reboot", redl != nil, "\(c.link.params.downloadState)")
    }

    static func disconnectOnArm(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.arm(true)
        c.pump(8)
        c.snapshot("drone went silent right after arm")
        c.check("arm result is not 'accepted'", c.link.commands.lastResult != "Arm/disarm: accepted", c.link.commands.lastResult ?? "nil")
        c.check("NO HEARTBEAT shown", !c.uiLinkAliveFlag)
        c.note("armed flag shown: \(c.vehicle.armed) (vehicle IS armed but app never heard it)")
    }

    static func batteryFailsafe(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.drone("fault battery_low on")
        c.pump(3)
        c.check("low battery visible", c.vehicle.batteryRemaining <= 20, "pct=\(c.vehicle.batteryRemaining) V=\(c.vehicle.batteryVoltage)")
        c.drone("fault battery_low off"); c.drone("fault battery_critical on")
        c.pump(3)
        c.note("critical: pct=\(c.vehicle.batteryRemaining) V=\(c.vehicle.batteryVoltage). UI: only Battery item text + speech (if enabled)")
    }

    static func statustextFlood(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let start = Probes.rssMB()
        c.pump(15)
        c.metric("messages_kept", c.vehicle.messages.count)
        c.metric("rss_growth_mb", String(format: "%.1f", Probes.rssMB() - start))
        c.check("message list capped", c.vehicle.messages.count <= VehicleModel.maxMessages, "\(c.vehicle.messages.count)")
        c.check("HUD still live under flood", !c.vehicle.attitudeStale)
    }

    static func highRate(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let cpu0 = Probes.cpuSeconds(), rss0 = Probes.rssMB(), t0 = Date()
        c.pump(c.args.secs > 0 ? c.args.secs : 20)
        let dt = Date().timeIntervalSince(t0)
        let cpu = (Probes.cpuSeconds() - cpu0) / dt * 100
        c.metric("cpu_pct", String(format: "%.0f", cpu)); c.metric("rss_mb", String(format: "%.1f", Probes.rssMB()))
        c.metric("rss_growth_mb", String(format: "%.1f", Probes.rssMB() - rss0))
        c.metric("attitude_msgs", c.vehicle.messageCounts["ATTITUDE"] ?? 0)
        c.check("keeps up with 50 Hz x 8 msgs (no stale)", !c.vehicle.attitudeStale && c.vehicle.heartbeatAlive)
        c.check("CPU (headless, no UI) < 50%", cpu < 50, String(format: "%.0f%%", cpu))
    }

    static func longSession(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let secs = c.args.secs > 0 ? c.args.secs : 300
        let rss0 = Probes.rssMB()
        var samples: [String] = []
        let t0 = Date()
        while Date().timeIntervalSince(t0) < secs {
            c.pump(30)
            samples.append(String(format: "%.0fs:%.1fMB", Date().timeIntervalSince(t0), Probes.rssMB()))
        }
        c.metric("rss_samples", samples.joined(separator: ","))
        let growth = Probes.rssMB() - rss0
        c.metric("rss_growth_mb", String(format: "%.1f", growth))
        c.metric("tlog_bytes", (try? FileManager.default.attributesOfItem(atPath: c.link.tlogURL?.path ?? "")[.size]) ?? "?")
        c.check("memory growth < 20 MB over session", growth < 20, String(format: "%.1f MB", growth))
    }

    static func largeMission(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let n = Int(c.args.extra["items"] ?? "700") ?? 700
        let items = sampleMission(c, n: n)
        c.link.mission.setItems(.mission, items)
        let t0 = Date()
        c.link.mission.write(.mission)
        let w = c.waitUntil(120) { c.link.mission.busy == nil }
        c.metric("upload_s", String(format: "%.1f", Date().timeIntervalSince(t0)))
        c.check("upload \(items.count) items", w != nil && (c.link.mission.banner ?? "").contains("accepted"), c.link.mission.banner ?? "nil")
        let t1 = Date()
        c.link.mission.read(.mission)
        c.waitUntil(120) { c.link.mission.busy == nil }
        c.metric("download_s", String(format: "%.1f", Date().timeIntervalSince(t1)))
        c.check("download \(items.count) items", c.link.mission.mission.count == items.count, "\(c.link.mission.mission.count)")
        c.metric("mission_distance_m", Int(c.link.mission.missionDistance))
    }

    static func logDownload(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.logs.refresh()
        c.waitUntil(10) { !c.link.logs.listing && !c.link.logs.entries.isEmpty }
        c.check("D9 list", c.link.logs.entries.count == 2, "\(c.link.logs.entries.map { "\($0.id):\($0.size)" })")
        guard let e = c.link.logs.entries.first else { return }
        c.link.logs.start(e)
        c.waitUntil(20) { c.link.logs.downloading == nil }
        let file = c.link.logs.directory.appendingPathComponent(c.link.logs.fileName(e))
        let size = (try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int) ?? -1
        c.check("D9 .bin written with right size", size == Int(e.size), "size=\(size) expected=\(e.size) msg=\(c.link.logs.message ?? "nil")")
    }

    static func replay(_ c: Ctx) {
        // record ~6 s, then replay it through the same pipeline
        guard c.connectAndWaitForVehicle() else { return }
        c.link.commands.arm(true)
        c.pump(6)
        guard let url = c.link.tlogURL else { return c.check("tlog exists", false) }
        c.link.disconnect()
        c.link.startReplay(url: url)
        c.waitUntil(3) { c.link.replay.loaded }
        if !c.link.replay.playing { c.link.replay.playPause() }
        c.link.replay.speed = 5
        let got = c.waitUntil(8) { c.vehicle.heartbeatAlive && c.vehicle.armed }
        c.check("F5 replay drives HUD", got != nil, "packets=\(c.link.replay.packetCount) dur=\(c.link.replay.duration)")
        c.link.replay.seek(to: 0.1)
        c.pump(0.5)
        c.check("F5 seek works", c.link.replay.position < 0.6, "pos=\(c.link.replay.position)")
        c.check("replay sends nothing to a vehicle", c.link.isReplaying)
        // garbage file
        let bad = FileManager.default.temporaryDirectory.appendingPathComponent("garbage.tlog")
        try? Data((0..<5000).map { _ in UInt8.random(in: 0...255) }).write(to: bad)
        c.link.startReplay(url: bad)
        c.pump(2)
        c.note("garbage replay: state=\(c.link.state.description) loaded=\(c.link.replay.loaded) packets=\(c.link.replay.packetCount) dur=\(c.link.replay.duration)")
        c.check("garbage tlog handled without crash", true)
        let empty = FileManager.default.temporaryDirectory.appendingPathComponent("empty.tlog")
        try? Data().write(to: empty)
        c.link.startReplay(url: empty)
        c.pump(1.5)
        c.check("empty tlog handled", true, "state=\(c.link.state.description) dur=\(c.link.replay.duration)")
        c.check("ReplayBar time() would not trap", Probes.intConvertible(c.link.replay.elapsed) && Probes.intConvertible(c.link.replay.duration),
                "elapsed=\(c.link.replay.elapsed) duration=\(c.link.replay.duration)")
    }

    static func connectSpam(_ c: Ctx) {
        for _ in 0..<40 {
            c.connect()
            c.pump(0.02)
            if Bool.random() { c.link.disconnect() }
        }
        c.connect()
        let ok = c.waitUntil(10) { c.vehicle.heartbeatAlive }
        c.check("connect spam: final connect works", ok != nil, "state=\(c.link.state.description)")
        c.check("connect spam: parameters complete", c.waitParams(timeout: 30))
        c.metric("open_fds", Probes.openFDs())
    }

    static func disconnectMidTransfer(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(0.4) // download in progress
        c.link.disconnect()
        c.pump(0.5)
        c.note("after disconnect during param download: state=\(c.link.params.downloadState) params=\(c.link.params.params.count)")
        c.connect()
        c.waitUntil(8) { c.vehicle.heartbeatAlive }
        c.check("params complete after reconnect", c.waitParams(timeout: 30))
        c.link.mission.setItems(.mission, sampleMission(c, n: 200))
        c.link.mission.write(.mission)
        c.pump(0.3)
        c.link.disconnect()
        c.pump(0.5)
        c.check("mission busy flag cleared on disconnect", c.link.mission.busy == nil, "busy=\(String(describing: c.link.mission.busy)) banner=\(c.link.mission.banner ?? "nil")")
    }

    static func flyHere(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let p = c.vehicle.position ?? GeoPoint(latitude: -35.36, longitude: 149.16)
        // not in Guided: the vehicle rejects; the app should say so
        c.link.mission.guidedGoTo(GeoPoint(latitude: p.latitude + 0.0005, longitude: p.longitude), altitude: 20)
        c.pump(2)
        c.check("G3 fly-here outside Guided reports the rejection", !(c.link.mission.banner ?? "").hasPrefix("Flying to"),
                c.link.mission.banner ?? "nil")
        c.link.commands.setMode(4, name: "Guided"); c.waitUntil(5) { c.vehicle.customMode == 4 }
        c.link.commands.arm(true); c.waitUntil(5) { c.vehicle.armed }
        c.link.commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, 10], label: "Takeoff")
        c.waitUntil(15) { c.vehicle.relativeAltitude > 9 }
        c.link.mission.guidedGoTo(GeoPoint(latitude: p.latitude + 0.0005, longitude: p.longitude), altitude: 20)
        let moved = c.waitUntil(30) { (c.vehicle.latitude ?? 0) > p.latitude + 0.0004 }
        c.check("G3 vehicle flies to the point", moved != nil, "lat=\(String(describing: c.vehicle.latitude))")
        c.link.commands.command(179, params: [1], label: "Set home")
        c.waitUntil(4) { c.link.commands.pending.isEmpty }
        c.check("set home accepted", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
    }

    static func paramNaN(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        let v = c.link.params.params["TEST_P001"]?.value
        c.note("TEST_P001 from vehicle = \(String(describing: v))")
        if let url = try? c.link.params.save(), let text = try? String(contentsOf: url) {
            let d = c.link.params.differences(from: ParamFile.parse(text))
            c.check("NaN param: saved file reloads with 0 differences", d.changes.isEmpty, "changes=\(d.changes.map(\.name))")
            c.note("line in file: \(text.split(separator: "\n").first { $0.hasPrefix("TEST_P001") } ?? "missing")")
        }
        c.check("FLTMODE_CH=0 page would not crash", Probes.flightModesPageSafe(c.link.params.params["FLTMODE_CH"]?.value, c.vehicle.rcChannels.count),
                "FLTMODE_CH=\(String(describing: c.link.params.params["FLTMODE_CH"]?.value))")
    }

    static func modeChangeMidMission(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.mission.setItems(.mission, sampleMission(c, n: 3))
        c.link.mission.write(.mission); c.waitUntil(15) { c.link.mission.busy == nil }
        c.link.commands.setMode(4, name: "Guided"); c.waitUntil(5) { c.vehicle.customMode == 4 }
        c.link.commands.arm(true); c.waitUntil(5) { c.vehicle.armed }
        c.link.commands.setMode(3, name: "Auto")
        let switched = c.waitUntil(60) { c.vehicle.customMode == 5 }
        c.check("mid-mission mode change (RC) reflected", switched != nil, c.vehicle.modeName)
        c.check("reason visible in Messages", c.vehicle.messages.contains { $0.text.contains("LOITER") })
        c.link.commands.setMode(9, name: "Land"); c.waitUntil(40) { !c.vehicle.armed }
    }

    static func lossyLink(_ c: Ctx) {
        // through testing/fake_drone/fault_proxy.py (loss/latency/jitter both ways)
        guard c.connectAndWaitForVehicle(timeout: 15) else { return }
        c.waitParams(timeout: Double(c.args.extra["param-timeout"] ?? "120") ?? 120)
        let s = c.link.stats
        c.metric("rx", s.packetsReceived); c.metric("lost", s.packetsLost)
        c.link.commands.setMode(5, name: "Loiter")
        let m = c.waitUntil(15) { c.vehicle.customMode == 5 && c.link.commands.pending.isEmpty }
        c.check("mode change over lossy link", m != nil, c.link.commands.lastResult ?? "nil")
        c.link.mission.setItems(.mission, sampleMission(c, n: 10))
        c.link.mission.write(.mission)
        c.waitUntil(60) { c.link.mission.busy == nil }
        c.check("mission upload over lossy link", (c.link.mission.banner ?? "").contains("accepted"), c.link.mission.banner ?? "nil")
        c.check("HUD not stuck stale on lossy link", !c.vehicle.attitudeStale)
    }

    static func compidSwitch(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(3)
        c.note("locked comp=\(c.vehicle.componentID) sources=\(c.vehicle.heartbeatSources)")
        c.check("telemetry from compid 2 autopilot shown", !c.vehicle.attitudeStale, "stale=\(c.vehicle.attitudeStale)")
    }

    static func sitlSmoke(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(timeout: 20) else { return }
        c.pump(3)
        c.snapshot("sitl")
        c.waitParams(timeout: 60)
        c.metric("sitl_param_count", c.link.params.params.count)
        c.check("SITL firmware ArduCopter", c.vehicle.vehicleTypeName == "ArduCopter")
        c.check("SITL attitude live", !c.vehicle.attitudeStale)
        let gps = c.waitUntil(60) { c.vehicle.gpsFixType >= 3 }
        c.check("SITL GPS fix", gps != nil, "fix=\(c.vehicle.gpsFixType)")
    }

    /// Blackout injected by fault_proxy.py (--blackout 4:8): nothing passes either way for 8 s.
    static func linkLossProxy(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let lost = c.waitUntil(12) { !c.vehicle.heartbeatAlive }
        c.metric("link_lost_detect_s", lost.map { String(format: "%.1f", $0) } ?? "never")
        c.check("B5 NO HEARTBEAT during proxy blackout", lost != nil && !c.uiLinkAliveFlag)
        let back = c.waitUntil(15) { c.vehicle.heartbeatAlive }
        c.check("B5 recovers after blackout (UDP listen)", back != nil, "state=\(c.link.state.description)")
    }

    /// Real ArduCopter SITL: arm in GUIDED, take off, RTL, plus a DO_SET_SERVO on a motor output.
    static func sitlArm(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(timeout: 20) else { return }
        c.waitParams(timeout: 90)
        let gps = c.waitUntil(90) { c.vehicle.gpsFixType >= 3 && (c.vehicle.ekfFlags & 0x0008) != 0 }
        c.check("SITL GPS + EKF ready", gps != nil, "fix=\(c.vehicle.gpsFixType) ekf=\(c.vehicle.ekfFlags)")
        // motor-output override: what ServoView would send before parameters arrived (BUG: guard is fail-open)
        c.link.commands.command(183, params: [1, 1900], label: "Servo 1 -> 1900")
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.note("DO_SET_SERVO on motor output 1: \(c.link.commands.lastResult ?? "nil"); msgs=\(c.vehicle.messages.prefix(3).map(\.text))")
        c.link.commands.setMode(4, name: "Guided")
        c.waitUntil(5) { c.vehicle.customMode == 4 }
        var armed: Double? = nil
        for _ in 0..<6 where armed == nil {
            c.link.commands.arm(true)
            armed = c.waitUntil(8) { c.vehicle.armed }
        }
        c.check("SITL arms in GUIDED", armed != nil, "result=\(c.link.commands.lastResult ?? "nil") msgs=\(c.vehicle.messages.prefix(4).map(\.text))")
        guard armed != nil else { return }
        c.link.commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, 10], label: "Takeoff to 10 m")
        let up = c.waitUntil(40) { c.vehicle.relativeAltitude > 9 }
        c.check("SITL takeoff to 10 m", up != nil, "alt=\(c.vehicle.relativeAltitude) result=\(c.link.commands.lastResult ?? "nil")")
        c.link.commands.arm(false) // normal disarm in flight: ArduPilot must refuse and the app must say so
        c.waitUntil(6) { c.link.commands.pending.isEmpty }
        c.check("in-flight disarm refused and explained", c.vehicle.armed && !c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
        c.link.commands.setMode(6, name: "RTL")
        let landed = c.waitUntil(90) { !c.vehicle.armed }
        c.check("SITL RTL lands and disarms", landed != nil, "alt=\(c.vehicle.relativeAltitude) mode=\(c.vehicle.modeName)")
    }

    /// ServoView.isMotor() returns false until SERVOn_FUNCTION is downloaded: are motor outputs exposed?
    static func servoBeforeParams(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let have = c.link.params.params["SERVO1_FUNCTION"] != nil
        let blocked = Probes.servoIsMotor(c.link.params.params["SERVO1_FUNCTION"]?.value)
        c.check("motor output 1 override blocked while params still downloading", blocked || have,
                "SERVO1_FUNCTION known=\(have) -> ServoView buttons enabled for Out 1")
    }
}
