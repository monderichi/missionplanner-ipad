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

    func attach(systemID: UInt8, componentID: UInt8, narrowLink: Bool) {
        session = CommandSession(targetSystem: systemID, targetComponent: componentID,
                                 config: narrowLink ? .narrowLink : CommandSession.Config())
        pending = []
    }

    func detach() {
        session = nil
        pending = []
    }

    func arm(_ arm: Bool, force: Bool = false) {
        guard let session else { return }
        session.arm(arm, force: force, now: now).forEach { send?($0) }
        lastResult = arm ? "Arming…" : (force ? "Force disarming…" : "Disarming…")
        refreshPending()
    }

    func setMode(_ mode: UInt32, name: String) {
        guard let session else { return }
        session.setMode(mode, now: now).forEach { send?($0) }
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
        session.send(command, params: params, now: now).forEach { send?($0) }
        names[command] = label
        lastResult = "\(label)…"
        refreshPending()
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
        quiet.insert(MAVCmd.requestMessage)
        refreshPending()
    }

    private var names: [UInt16: String] = [:]
    private var untracked: Set<UInt16> = []
    /// Commands whose results aren't worth a banner (background requests).
    private var quiet: Set<UInt16> = []

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
        switch e {
        case .accepted(let cmd) where quiet.contains(cmd),
             .rejected(let cmd, _) where quiet.contains(cmd),
             .timedOut(let cmd) where quiet.contains(cmd):
            quiet.remove(cmd)
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
            lastResult = "\(name(cmd)): no answer from vehicle"
            lastResultOK = false
        }
    }
}
