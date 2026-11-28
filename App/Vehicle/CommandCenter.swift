// App-side wrapper around MAVLinkKit.CommandSession: arm/disarm, flight mode, reboot.

import Foundation
import MAVLinkKit

final class CommandCenter: ObservableObject {
    @Published private(set) var pending: Set<UInt16> = []
    @Published var lastResult: String?
    @Published private(set) var lastResultOK = true

    var send: ((MAVLinkMessage) -> Void)?
    /// Called after the vehicle accepts a reboot, so parameter state can be reset.
    var onRebootAccepted: (() -> Void)?

    private var session: CommandSession?
    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }

    var isAttached: Bool { session != nil }

    /// BUG-017: set by LinkManager; used to check the vehicle's real state when an ACK never arrives.
    weak var vehicle: VehicleModel?
    private var requestedMode: UInt32?
    private var requestedArm: Bool?

    /// BUG-027: a session replaced/removed while commands were in flight: say so instead of "Arming…" forever.
    private func abandonPending() {
        defer { labelQueue = [:]; sentAt = [:]; quiet = [:] }
        // review R2-1: background (quiet) requests such as HOME_POSITION don't get a red banner
        if let s = session, let cmd = s.pendingCommands.first(where: { quiet[$0] == nil }) {
            lastResult = "\(name(cmd)): link changed, not confirmed"
            lastResultOK = false
        }
    }

    func attach(systemID: UInt8, componentID: UInt8, narrowLink: Bool) {
        abandonPending()
        session = CommandSession(targetSystem: systemID, targetComponent: componentID,
                                 config: narrowLink ? .narrowLink : CommandSession.Config())
        pending = []
    }

    func detach() {
        abandonPending()
        session = nil
        pending = []
    }

    func arm(_ arm: Bool, force: Bool = false) {
        guard let session else { return }
        session.arm(arm, force: force, now: now).forEach { send?($0) }
        markSent(MAVCmd.componentArmDisarm)
        requestedArm = arm
        lastResult = arm ? "Arming…" : (force ? "Force disarming…" : "Disarming…")
        refreshPending()
    }

    func setMode(_ mode: UInt32, name: String) {
        guard let session else { return }
        session.setMode(mode, now: now).forEach { send?($0) }
        markSent(MAVCmd.doSetMode)
        requestedMode = mode
        lastResult = "Changing mode to \(name)…"
        refreshPending()
    }

    func reboot() {
        guard let session else { return }
        session.reboot(now: now).forEach { send?($0) }
        lastResult = "Rebooting autopilot…"
        refreshPending()
    }

    /// Generic tracked command (retried until COMMAND_ACK).
    func command(_ command: UInt16, params: [Float], label: String) {
        guard let session else { return }
        let out = session.send(command, params: params, now: now)
        out.forEach { send?($0) }
        if out.isEmpty {
            // BUG-002 (review 1): queued behind an in-flight command with the same id; keep its label in order so the
            // results name the right servo/relay/motor.
            labelQueue[command, default: []].append(label)
            lastResult = "\(label)… (queued)"
        } else {
            names[command] = label
            lastResult = "\(label)…"
        }
        markSent(command)
        refreshPending()
    }

    /// Earliest heartbeat time that may confirm the in-flight command: 0.3 s after sending, or the end of its
    /// ambiguity window (review 2) when it superseded another command.
    private func markSent(_ cmd: UInt16) {
        guard let session else { return }
        sentAt[cmd] = Date().addingTimeInterval(max(0.3, session.ambiguityRemaining(cmd, now: now)))
    }

    /// Labels of commands queued behind an in-flight one with the same id (FIFO, mirrors CommandSession's queue).
    private var labelQueue: [UInt16: [String]] = [:]
    /// Per command id: only a HEARTBEAT received at/after this time may confirm the in-flight command (see markSent).
    private var sentAt: [UInt16: Date] = [:]

    /// BUG-002: confirm arm/disarm and mode changes from the vehicle's HEARTBEAT (COMMAND_ACKs are ambiguous after a
    /// superseded command and may be lost on ELRS). Only a heartbeat received ≥ 0.3 s after the send counts.
    private func confirmFromVehicleState() {
        guard let session, let v = vehicle, v.heartbeatAlive, let hb = v.lastHeartbeat else { return }
        for cmd in [MAVCmd.componentArmDisarm, MAVCmd.doSetMode] {
            // review 2: the heartbeat must postdate the send by the ambiguity window (≥ 0.3 s), so it reflects what the
            // vehicle did after *this* command, not the state before a superseded one took effect.
            guard let m = session.inFlight(cmd), let after = sentAt[cmd], hb >= after else { continue }
            let reached = cmd == MAVCmd.componentArmDisarm ? v.armed == (m.param1 == 1) : v.customMode == UInt32(exactly: m.param2)
            if reached { session.confirmByState(cmd, now: now).forEach { apply($0) } }
        }
    }

    /// Sent exactly once, never retried: for commands where a repeat would restart something
    /// (accelerometer calibration, MAV_CMD_ACCELCAL_VEHICLE_POS answers). ACKs still update lastResult.
    func sendOnce(_ command: UInt16, params p: [Float], label: String) {
        guard let session else { return }
        let v = p + [Float](repeating: 0, count: max(0, 7 - p.count))
        send?(MAV.CommandLong(param1: v[0], param2: v[1], param3: v[2], param4: v[3], param5: v[4], param6: v[5],
                              param7: v[6], command: command, targetSystem: session.targetSystem,
                              targetComponent: session.targetComponent, confirmation: 0))
        names[command] = label
        untracked.insert(command)
        lastResult = "\(label)…"
    }

    /// Fire-and-forget COMMAND_LONG with no banner and no retry (background stream requests).
    func sendQuiet(_ command: UInt16, params p: [Float]) {
        guard let session else { return }
        let v = p + [Float](repeating: 0, count: max(0, 7 - p.count))
        send?(MAV.CommandLong(param1: v[0], param2: v[1], param3: v[2], param4: v[3], param5: v[4], param6: v[5],
                              param7: v[6], command: command, targetSystem: session.targetSystem,
                              targetComponent: session.targetComponent, confirmation: 0))
        quietAcks.insert(command)
    }

    /// MAV_CMD_SET_MESSAGE_INTERVAL (511): param1 message id, param2 interval in microseconds.
    func setMessageInterval(_ id: UInt32, hz: Double) {
        sendQuiet(MAVCmd.setMessageInterval, params: [Float(id), Float(hz > 0 ? 1_000_000 / hz : -1)])
    }

    private var quietAcks: Set<UInt16> = []

    /// MAV_CMD_REQUEST_MESSAGE (e.g. HOME_POSITION = 242).
    func requestMessage(_ id: UInt32) {
        guard let session else { return }
        session.send(MAVCmd.requestMessage, params: [Float(id)], now: now).forEach { send?($0) }
        names[MAVCmd.requestMessage] = "Request message"
        quiet[MAVCmd.requestMessage, default: 0] += 1 // review 5: count, so overlapping requests all stay quiet
        refreshPending()
    }

    private var names: [UInt16: String] = [:]
    private var untracked: Set<UInt16> = []
    /// Commands whose results aren't worth a banner (background requests).
    private var quiet: [UInt16: Int] = [:] // outstanding quiet results per command id

    func handle(_ ack: MAV.CommandAck) {
        if quietAcks.contains(ack.command) && session?.pendingCommands.contains(ack.command) != true {
            return // ACK of a background request: nothing to show
        }
        if untracked.contains(ack.command) {
            untracked.remove(ack.command)
            let label = names[ack.command] ?? "Command \(ack.command)"
            lastResultOK = ack.result == MAVResult.accepted.rawValue || ack.result == MAVResult.inProgress.rawValue
            lastResult = "\(label): \(CommandSession.resultText(ack.result))"
            return
        }
        guard let session else { return }
        for e in session.handle(ack, now: now) { apply(e) }
        refreshPending()
    }

    func tick() {
        guard let session else { return }
        let r = session.tick(now: now)
        r.messages.forEach { send?($0) }
        r.events.forEach { apply($0) }
        confirmFromVehicleState()
        if !r.events.isEmpty || !r.messages.isEmpty { refreshPending() }
    }

    private func refreshPending() {
        pending = Set(session?.pendingCommands ?? [])
    }

    private func name(_ cmd: UInt16) -> String {
        if let n = names[cmd] { return n }
        switch cmd {
        case MAVCmd.componentArmDisarm: return "Arm/disarm"
        case MAVCmd.doSetMode: return "Mode change"
        case MAVCmd.preflightRebootShutdown: return "Reboot"
        default: return "Command \(cmd)"
        }
    }

    private func apply(_ e: CommandSession.Event) {
        applyResult(e)
        // BUG-002 (review 1): the next queued command with this id goes out now: show it as sending, with its own label.
        switch e {
        case .accepted(let cmd), .rejected(let cmd, _), .timedOut(let cmd):
            if var q = labelQueue[cmd], !q.isEmpty {
                let next = q.removeFirst()
                labelQueue[cmd] = q.isEmpty ? nil : q
                names[cmd] = next
                lastResult = "\(next)…"
                lastResultOK = true
            }
        case .inProgress: break
        }
        refreshPending()
    }

    private func applyResult(_ e: CommandSession.Event) {
        switch e {
        case .accepted(let cmd) where quiet[cmd] != nil,
             .rejected(let cmd, _) where quiet[cmd] != nil,
             .timedOut(let cmd) where quiet[cmd] != nil:
            let left = (quiet[cmd] ?? 1) - 1
            quiet[cmd] = left > 0 ? left : nil
            return
        case .accepted(let cmd):
            lastResult = "\(name(cmd)): accepted"
            lastResultOK = true
            if cmd == MAVCmd.preflightRebootShutdown { onRebootAccepted?() }
        case .inProgress(let cmd, let progress):
            lastResult = "\(name(cmd)): in progress \(progress)%"
            lastResultOK = true
        case .rejected(let cmd, let result):
            // ArduPilot explains arming refusals in STATUSTEXT ("PreArm: ..."), see Messages.
            lastResult = "\(name(cmd)): \(CommandSession.resultText(result)). Check Messages for the reason."
            lastResultOK = false
        case .timedOut(let cmd):
            // BUG-017: the ACKs may be lost while the command worked: check the heartbeat state before failing.
            if cmd == MAVCmd.doSetMode, let m = requestedMode, let v = vehicle, v.heartbeatAlive, v.customMode == m {
                lastResult = "\(name(cmd)): no ACK, but the vehicle is now in \(v.modeName)"
                lastResultOK = true
            } else if cmd == MAVCmd.componentArmDisarm, let a = requestedArm, let v = vehicle, v.heartbeatAlive, v.armed == a {
                lastResult = "\(name(cmd)): no ACK, but the vehicle is now \(a ? "armed" : "disarmed")"
                lastResultOK = true
            } else {
                lastResult = "\(name(cmd)): no answer from vehicle"
                lastResultOK = false
            }
        }
    }
}
