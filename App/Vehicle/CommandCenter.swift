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

    func handle(_ ack: MAV.CommandAck) {
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
        switch cmd {
        case MAVCmd.componentArmDisarm: return "Arm/disarm"
        case MAVCmd.doSetMode: return "Mode change"
        case MAVCmd.preflightRebootShutdown: return "Reboot"
        default: return "Command \(cmd)"
        }
    }

    private func apply(_ e: CommandSession.Event) {
        switch e {
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
