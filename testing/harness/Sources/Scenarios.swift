// Scenarios for the headless harness. Each one pairs with a fake-drone (or SITL) setup started by
// testing/scenarios/run.py (see SCENARIOS there for the drone arguments).

import Foundation
import MAVLinkKit
import UIKit
import CoreGraphics

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
        "esc_telemetry": escTelemetry, "prearm_check": prearmCheck, "accel_cal": accelCal, "compass_cal": compassCal,
        "geofence_apply": geofenceApply, "fence_breach": fenceBreach, "motor_test": motorTest, "mission_edge": missionEdge, "sitl_manual": sitlManual, "manual_control": manualControl, "sitl_auto": sitlAuto, "sitl_accel_probe": sitlAccelProbe, "sitl_fence": sitlFence, "param_edge": paramEdge, "probe:fuzz_pipeline": Fuzz.run,
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
        c.check("timeout reported (BUG-017: with the real outcome)", (c.link.commands.lastResult ?? "").contains("no ACK")
                || (c.link.commands.lastResult ?? "").contains("no answer"), c.link.commands.lastResult ?? "nil")
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
        c.drone("quit") // fake drone process exits -> TCP RST/FIN; run.py restarts it 8 s later
        let banner = c.waitUntil(7.5) { !c.uiLinkAliveFlag }
        c.snapshot("after tcp drop")
        c.check("link failure visible as NO HEARTBEAT banner", banner != nil,
                "state=\(c.link.state.description) hbAlive=\(c.vehicle.heartbeatAlive) uiLinkAlive=\(c.uiLinkAliveFlag)")
        c.check("status bar shows no live values while the link is down", !c.vehicle.heartbeatAlive,
                "hbAlive=\(c.vehicle.heartbeatAlive) (RootView shows — when not live)")
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
        c.check("HUD label safe (HUDView.whole)", Probes.whole(v.roll) == Probes.whole(v.roll), "roll=\(v.roll)")
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
        c.check("position marked stale after GPS loss (BUG-015)", c.vehicle.positionStale || c.vehicle.position == nil,
                "positionStale=\(c.vehicle.positionStale) position=\(String(describing: c.vehicle.position)) before=\(String(describing: before))")
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
        let want = Int(c.args.extra["expect-logs"] ?? "2") ?? 2
        c.check("D9 list", want < 0 ? !c.link.logs.listing : c.link.logs.entries.count == want,
                "\(c.link.logs.entries.map { "\($0.id):\($0.size)" }) msg=\(c.link.logs.message ?? "nil")")
        guard let e = c.link.logs.entries.min(by: { $0.size < $1.size }) else { return }
        c.link.logs.start(e)
        c.waitUntil(Double(c.args.extra["dl-timeout"] ?? "20") ?? 20) { c.link.logs.downloading == nil }
        c.metric("log_bytes", e.size); c.metric("log_rate_Bps", Int(c.link.logs.rate))
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

    // MARK: round 2 (B4, D1, D2, D3, D6, D7, G4)

    static func escTelemetry(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(2)
        c.check("B4 four ESCs shown", c.vehicle.escCount == 4, "escCount=\(c.vehicle.escCount)")
        c.check("B4 0 RPM when disarmed, temperature shown", c.vehicle.escs.prefix(4).allSatisfy { $0.rpm == 0 && $0.temperature > 0 },
                "\(c.vehicle.escs.prefix(4).map { "\($0.rpm)rpm/\($0.temperature)C" })")
        c.link.commands.arm(true); c.waitUntil(5) { c.vehicle.armed }
        c.pump(2.5)
        c.check("B4 RPM when armed", c.vehicle.escs.prefix(4).allSatisfy { $0.rpm > 0 }, "\(c.vehicle.escs.prefix(4).map(\.rpm))")
        c.note("ESC slots 5-8 after only 1-4 reported: \(c.vehicle.escs.suffix(4).map(\.rpm)) escCount=\(c.vehicle.escCount)")
    }

    static func prearmCheck(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.calibration.runPrearmChecks()
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.pump(0.5)
        c.check("D1 command accepted", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
        c.check("D1 PreArm reason shown", c.vehicle.messages.contains { $0.text.hasPrefix("PreArm") }, c.vehicle.messages.first?.text ?? "none")
    }

    static func accelCal(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.pump(1)
        c.link.calibration.startAccel()
        var seen: [UInt32] = []
        let t0 = Date()
        let tapDelay = Double(c.args.extra["tap-delay"] ?? "0.5") ?? 0.5
        while Date().timeIntervalSince(t0) < Double(c.args.extra["timeout"] ?? "40") ?? 40 {
            c.pump(0.1)
            switch c.link.calibration.accel {
            case .place(let p):
                if seen.last != p { seen.append(p); c.pump(tapDelay); c.link.calibration.confirmPosition() }
                else if c.args.extra["retap"] != nil, Date().timeIntervalSince(t0) > Double(seen.count) * 6 {
                    c.note("no progress on position \(p): user taps again"); c.link.calibration.confirmPosition(); c.pump(2)
                }
            case .success, .failed: break
            default: continue
            }
            if c.link.calibration.accel == .success || c.link.calibration.accel == .failed { break }
        }
        c.metric("accel_cal_s", String(format: "%.1f", Date().timeIntervalSince(t0)))
        let expectFail = c.args.extra["expect"] == "failed"
        c.check("D2 asks positions 1-6 in order", expectFail ? seen == [1, 2, 3] : seen == [1, 2, 3, 4, 5, 6], "\(seen)")
        c.check("D2 ends \(expectFail ? "failed" : "successful")", c.link.calibration.accel == (expectFail ? .failed : .success),
                "\(c.link.calibration.accel) banner=\(c.link.commands.lastResult ?? "nil")")
    }

    static func compassCal(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.calibration.startCompass()
        let expectFail = c.args.extra["expect"] == "failed"
        let done = c.waitUntil(20) { c.vehicle.magCalReports.count == 2 }
        c.snapshot("magcal")
        c.check("D3 progress reaches 100% on compass 1", c.vehicle.magCalProgress[0] == 100, "\(c.vehicle.magCalProgress)")
        c.check("D3 reports for both compasses", done != nil, "\(c.vehicle.magCalReports.keys.sorted())")
        let statuses = c.vehicle.magCalReports.values.map(\.calStatus).sorted()
        c.check(expectFail ? "D3 failure reported" : "D3 success with fitness/offsets", expectFail ? statuses.contains(5) : statuses == [4, 4],
                "status=\(statuses) fitness=\(c.vehicle.magCalReports.values.map(\.fitness))")
        if expectFail {
            c.note("UI shows progress=\(c.vehicle.magCalProgress) for a FAILED compass (VehicleModel.swift:374 sets 100 on any report)")
            c.check("failed compass not shown as 100% complete", c.vehicle.magCalProgress[1] != 100, "\(c.vehicle.magCalProgress)")
        }
        c.link.calibration.acceptCompass()
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.check("D3 accept acknowledged", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
    }

    /// Same writes as FencePage.limitAltitude (SetupView.swift:590-596).
    static func fenceWrites(_ c: Ctx, alt: Float) -> [String: Float] {
        var out: [String: Float] = ["FENCE_ALT_MAX": alt, "FENCE_ENABLE": 1]
        let type = UInt32(max(0, c.link.params.params["FENCE_TYPE"]?.value ?? 0))
        out["FENCE_TYPE"] = Float(type | 1)
        if (c.link.params.params["FENCE_ACTION"]?.value ?? 0) == 0 { out["FENCE_ACTION"] = 1 }
        return out
    }

    static func geofenceApply(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        c.link.params.setMany(fenceWrites(c, alt: 60))
        c.waitUntil(10) { c.link.params.queuedWrites == 0 && c.link.params.pendingNames.isEmpty }
        let p = c.link.params.params
        c.check("D7 FENCE_ALT_MAX = 60", p["FENCE_ALT_MAX"]?.value == 60, "\(String(describing: p["FENCE_ALT_MAX"]?.value))")
        c.check("D7 FENCE_ENABLE = 1", p["FENCE_ENABLE"]?.value == 1)
        c.check("D7 FENCE_TYPE has bit 0", (Int(p["FENCE_TYPE"]?.value ?? 0) & 1) == 1, "\(String(describing: p["FENCE_TYPE"]?.value))")
        c.check("D7 no failed writes", c.link.params.failedWrites.isEmpty, "\(c.link.params.failedWrites)")
    }

    static func fenceBreach(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(), c.waitParams() else { return }
        c.link.commands.setMode(4, name: "Guided"); c.waitUntil(5) { c.vehicle.customMode == 4 }
        c.link.commands.arm(true); c.waitUntil(5) { c.vehicle.armed }
        c.link.commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, 40], label: "Takeoff to 40 m")
        c.waitUntil(30) { c.vehicle.relativeAltitude > 25 }
        // FencePage lets you apply a limit BELOW the current altitude while flying, with no warning:
        c.note("applying 20 m altitude fence while at \(String(format: "%.1f", c.vehicle.relativeAltitude)) m, armed=\(c.vehicle.armed)")
        c.link.params.setMany(fenceWrites(c, alt: 20))
        let rtl = c.waitUntil(10) { c.vehicle.customMode == 6 || c.vehicle.customMode == 9 }
        c.check("G4 fence action (RTL/Land) shown as mode", rtl != nil, c.vehicle.modeName)
        c.check("G4 breach message in Messages", c.vehicle.messages.contains { $0.text.contains("Fence") }, c.vehicle.messages.first?.text ?? "none")
        // Mirrors the fixed FencePage button (BUG-022): armed and limit < altitude + 10 m → confirmation first.
        let guarded = c.vehicle.armed && 20 < c.vehicle.relativeAltitude + 10
        c.check("applying a fence below the current altitude while armed is refused or confirmed", guarded,
                "FENCE_ALT_MAX=20 written at 26+ m while armed with no prompt -> immediate breach")
        c.waitUntil(60) { !c.vehicle.armed }
    }

    static func motorTest(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.calibration.motorTest(motor: 2, throttle: 5, duration: 2)
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.check("D6 motor test accepted", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
        c.link.calibration.motorTest(motor: 1, throttle: 5, duration: 2, count: 4)
        c.waitUntil(5) { c.link.commands.pending.isEmpty }
        c.check("D6 sequence test accepted", c.link.commands.lastResultOK, c.link.commands.lastResult ?? "nil")
    }

    static func missionEdge(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.link.mission.setItems(.mission, sampleMission(c, n: 8))
        c.link.mission.write(.mission)
        let done = c.waitUntil(20) { c.link.mission.busy == nil }
        c.check("upload finishes (no hang)", done != nil, "busy=\(String(describing: c.link.mission.busy))")
        let b = c.link.mission.banner ?? "nil"
        c.note("banner: \(b)")
        let expect = c.args.extra["expect"] ?? "accepted"
        c.check("banner reports '\(expect)'", b.lowercased().contains(expect), b)
    }

    static func paramEdge(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        c.waitParams(timeout: 40)
        let n = c.link.params.params.count
        c.note("count=\(n) state=\(c.link.params.downloadState) banner=\(c.link.params.banner ?? "nil")")
        if let name = c.args.extra["name"] {
            c.check("16-char name decoded", c.link.params.params[name]?.value == 42, "\(String(describing: c.link.params.params[name]))")
            c.link.params.set(name, 43)
            c.waitUntil(6) { c.link.params.pendingNames.isEmpty }
            c.check("16-char name writable", c.link.params.params[name]?.value == 43, c.link.params.banner ?? "nil")
        }
    }

    // MARK: SITL-only

    static func waitSITLReady(_ c: Ctx) -> Bool {
        guard c.connectAndWaitForVehicle(timeout: 30) else { return false }
        c.waitParams(timeout: 90)
        let ok = c.waitUntil(120) { c.vehicle.gpsFixType >= 3 && (c.vehicle.ekfFlags & 0x0010) != 0 }  // EKF pos horiz abs
        c.check("SITL GPS + EKF ready", ok != nil, "fix=\(c.vehicle.gpsFixType) ekf=0x\(String(c.vehicle.ekfFlags, radix: 16))")
        return ok != nil
    }

    static func armWithRetries(_ c: Ctx) -> Bool {
        for _ in 0..<8 {
            c.link.commands.arm(true)
            if c.waitUntil(8, { c.vehicle.armed }) != nil { return true }
            c.pump(4)
        }
        c.note("arm refused: \(c.link.commands.lastResult ?? "nil") msgs=\(c.vehicle.messages.prefix(4).map(\.text))")
        return false
    }

    static func sitlAuto(_ c: Ctx) {
        guard waitSITLReady(c) else { return }
        c.link.params.set("AUTO_OPTIONS", 7) // allow takeoff in AUTO without raising throttle (no RC in SITL)
        c.waitUntil(5) { c.link.params.pendingNames.isEmpty }
        c.link.mission.setItems(.mission, sampleMission(c, n: 2))
        c.link.mission.write(.mission)
        c.waitUntil(15) { c.link.mission.busy == nil }
        c.check("mission written to SITL", (c.link.mission.banner ?? "").contains("accepted"), c.link.mission.banner ?? "nil")
        c.link.commands.setMode(4, name: "Guided"); c.waitUntil(5) { c.vehicle.customMode == 4 }
        guard armWithRetries(c) else { return c.check("SITL arms", false) }
        c.link.commands.setMode(3, name: "Auto")
        c.check("G2 AUTO engaged on SITL", c.waitUntil(8) { c.vehicle.customMode == 3 } != nil, "\(c.vehicle.modeName) \(c.link.commands.lastResult ?? "")")
        let wp = c.waitUntil(120) { (c.vehicle.lastReachedWaypoint ?? 0) >= 3 }
        c.check("G2 SITL reaches the waypoints", wp != nil, "lastReached=\(String(describing: c.vehicle.lastReachedWaypoint)) cur=\(c.vehicle.currentWaypoint) alt=\(c.vehicle.relativeAltitude)")
        c.check("G1 trail drawn", c.vehicle.trail.count > 5, "\(c.vehicle.trail.count)")
        let landed = c.waitUntil(180) { !c.vehicle.armed }
        c.check("SITL RTL + land + disarm", landed != nil, "mode=\(c.vehicle.modeName) alt=\(c.vehicle.relativeAltitude)")
    }

    /// How does real ArduPilot drive the 6-position accel cal? (BUG-021: does it re-request positions?)
    static func sitlAccelProbe(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(timeout: 30) else { return }
        c.pump(5)
        let before = c.vehicle.messageCounts["COMMAND_LONG"] ?? 0
        c.link.calibration.startAccel()
        c.waitUntil(10) { if case .place = c.link.calibration.accel { return true } else { return false } }
        c.pump(10) // do NOT confirm: count position re-requests
        let requests = (c.vehicle.messageCounts["COMMAND_LONG"] ?? 0) - before
        c.metric("accelcal_position_requests_in_10s", requests)
        c.note("state=\(c.link.calibration.accel) msgs=\(c.vehicle.messages.prefix(3).map(\.text))")
        c.check("ArduPilot re-requests the position (so a lost request recovers)", requests >= 3, "\(requests) COMMAND_LONG in 10 s")
        c.link.calibration.confirmPosition()
        c.pump(6)
        c.note("after confirm: \(c.link.calibration.accel) msgs=\(c.vehicle.messages.prefix(3).map(\.text))")
        c.link.calibration.confirmPosition() // duplicate tap for the old position: ArduPilot must ignore it
        c.pump(4)
        c.note("after duplicate tap: \(c.link.calibration.accel) banner=\(c.link.commands.lastResult ?? "nil")")
    }

    static func sitlFence(_ c: Ctx) {
        guard waitSITLReady(c) else { return }
        c.link.commands.setMode(4, name: "Guided"); c.waitUntil(5) { c.vehicle.customMode == 4 }
        guard armWithRetries(c) else { return c.check("SITL arms", false) }
        c.link.commands.command(MissionCmd.takeoff, params: [0, 0, 0, 0, 0, 0, 30], label: "Takeoff to 30 m")
        c.waitUntil(60) { c.vehicle.relativeAltitude > 25 }
        c.note("applying a 15 m altitude fence at \(String(format: "%.1f", c.vehicle.relativeAltitude)) m (FencePage.limitAltitude writes)")
        c.link.params.setMany(fenceWrites(c, alt: 15))
        let act = c.waitUntil(20) { c.vehicle.customMode == 6 || c.vehicle.customMode == 9 }
        c.check("G4 real ArduPilot fence action shown", act != nil, "mode=\(c.vehicle.modeName) msgs=\(c.vehicle.messages.prefix(4).map(\.text))")
        c.note("BUG-022 on real firmware: \(act != nil ? "immediate breach after applying the fence in flight" : "no breach")")
        c.waitUntil(150) { !c.vehicle.armed }
    }

    // MARK: round 4 (code merged from origin/main)

    /// ManualControl (App/Control/ManualControl.swift): opt-in, 10 Hz frames, auto-off on link loss / backgrounding.
    static func manualControl(_ c: Ctx) {
        guard c.connectAndWaitForVehicle() else { return }
        let m = c.link.manual
        let rover = c.args.extra["expect"] != "unsupported"
        m.useGamepad = false
        m.setEnabled(true)
        c.pump(0.3)
        if !rover {
            c.check("manual control refused on a copter", !m.enabled, "enabled=\(m.enabled)")
            return
        }
        c.check("manual control enables on a rover", m.enabled)
        m.rightStick = CGPoint(x: 0.5, y: 0); m.leftStick = CGPoint(x: 0, y: 1)
        c.pump(1.2)
        c.check("frame follows the sticks (steer y, throttle z)", m.frame.y > 300 && m.frame.z > 900, "\(m.frame)")
        // NaN robustness: a NaN axis must not become full deflection
        m.rightStick = CGPoint(x: CGFloat.nan, y: 0)
        c.pump(0.3)
        c.check("NaN stick input is not sent as full deflection", abs(m.frame.y) < 1000, "frame.y=\(m.frame.y) for NaN input")
        m.rightStick = .zero; m.leftStick = .zero
        // backgrounding
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
        c.pump(0.3)
        c.check("leaving the app disables manual control", !m.enabled)
        // link loss
        m.setEnabled(true); c.pump(0.3)
        c.drone("silent 9")
        let off = c.waitUntil(9) { !m.enabled }
        c.check("link loss disables manual control", off != nil, "t=\(String(describing: off))")
        c.metric("manual_off_after_link_loss_s", off.map { String(format: "%.1f", $0) } ?? "never")
        c.waitUntil(12) { c.vehicle.heartbeatAlive }
        c.check("stays off after the link returns (needs a new opt-in)", !m.enabled)
    }

    /// S-R5/S-R6/S-S3 on real ArduRover / ArduSub SITL: arm in MANUAL, drive with ManualControl, link loss → off.
    static func sitlManual(_ c: Ctx) {
        guard c.connectAndWaitForVehicle(timeout: 30) else { return }
        c.waitParams(timeout: 90)
        let isSub = c.vehicle.vehicleTypeName == "ArduSub"
        c.note("vehicle \(c.vehicle.vehicleTypeName) mode \(c.vehicle.modeName)")
        c.waitUntil(90) { c.vehicle.gpsFixType >= 3 }
        c.link.commands.setMode(0, name: "Manual") // MANUAL is 0 for Rover; Sub MANUAL is 19
        if isSub { c.link.commands.setMode(19, name: "Manual") }
        c.pump(2)
        guard armWithRetries(c) else { return c.check("SITL arms in MANUAL", false, c.link.commands.lastResult ?? "nil") }
        let m = c.link.manual
        m.useGamepad = false
        m.setEnabled(true)
        c.check("manual control enabled", m.enabled)
        let p0 = c.vehicle.position, alt0 = c.vehicle.relativeAltitude
        if isSub { m.rightStick = CGPoint(x: 0, y: 0.8); m.leftStick = CGPoint(x: 0, y: -0.6) } // forward + descend
        else { m.leftStick = CGPoint(x: 0, y: 0.6); m.rightStick = CGPoint(x: 0.3, y: 0) }    // throttle + slight right
        c.pump(8)
        let moved = p0.flatMap { a in c.vehicle.position.map { Geo.distance(a, $0) } } ?? 0
        c.metric("moved_m", String(format: "%.1f", moved)); c.metric("alt_change_m", String(format: "%.2f", c.vehicle.relativeAltitude - alt0))
        c.check("vehicle moves under MANUAL_CONTROL (S-R5/S-S3)", moved > 2 || abs(c.vehicle.relativeAltitude - alt0) > 0.5,
                "moved=\(moved) m alt \(alt0)->\(c.vehicle.relativeAltitude) gs=\(c.vehicle.groundspeed) frame=\(m.frame)")
        let gsDriving = c.vehicle.groundspeed
        m.leftStick = .zero; m.rightStick = .zero
        c.pump(3)
        // MANUAL with zero throttle coasts (ArduRover), so only "slowing down" is expected, not an immediate stop
        c.check("sticks released: neutral frame sent and the vehicle slows", m.frame == ManualControl.Frame(x: 0, y: 0, z: isSub ? 500 : 0, r: 0)
                && c.vehicle.groundspeed < gsDriving, "gs \(gsDriving) -> \(c.vehicle.groundspeed) frame=\(m.frame)")
        m.setEnabled(false)
        c.link.commands.arm(false, force: true)
        c.waitUntil(5) { !c.vehicle.armed }
    }
}
