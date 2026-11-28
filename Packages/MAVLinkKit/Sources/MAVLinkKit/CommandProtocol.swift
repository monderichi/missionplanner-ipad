// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Mavlink/MAVLinkInterface.cs doCommand()
// (COMMAND_LONG, wait for COMMAND_ACK with the same command id, resend with confirmation+1),
// doARM() (MAV_CMD_COMPONENT_ARM_DISARM, param2 21196 = force) and setMode().
// Pure state machine like ParameterSession: caller supplies `now` and does the I/O.

import Foundation

public final class CommandSession {
    public struct Config {
        public var timeout: TimeInterval = 1.5
        public var attempts = 3
        public init() {}
        public static var narrowLink: Config {
            var c = Config()
            c.timeout = 3
            c.attempts = 4
            return c
        }
    }

    public enum Event: Equatable {
        case accepted(command: UInt16)
        case inProgress(command: UInt16, progress: UInt8)
        /// result is MAV_RESULT (1 temporarily rejected, 2 denied, 3 unsupported, 4 failed, ...)
        case rejected(command: UInt16, result: UInt8)
        case timedOut(command: UInt16)
    }

    public let targetSystem: UInt8
    public let targetComponent: UInt8
    public var config: Config

    private struct Pending {
        var message: MAV.CommandLong
        var attempts: Int
        var lastSent: TimeInterval
        /// BUG-002: ACKs before this time may belong to the command this one superseded (COMMAND_ACK has no request id):
        /// they don't resolve it. It is confirmed by a later ACK, or by vehicle state (`confirmByState`).
        var ambiguousUntil: TimeInterval = -.infinity
    }
    private var pending: [UInt16: Pending] = [:]
    /// BUG-002 (review 1): commands whose param1 selects *what* is addressed (servo channel, relay, motor, message id)
    /// wait in order behind an in-flight command with the same id; every one of them is sent.
    private var queued: [UInt16: [MAV.CommandLong]] = [:]

    /// BUG-002: for these, the newest request replaces the in-flight one at once (the pilot changed their mind):
    /// arm/disarm and flight mode. The old one is never resent again.
    public static let supersedable: Set<UInt16> = [MAVCmd.componentArmDisarm, MAVCmd.doSetMode]

    public init(targetSystem: UInt8, targetComponent: UInt8 = 1, config: Config = Config()) {
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
        self.config = config
    }

    public var pendingCommands: [UInt16] { Set(pending.keys).union(queued.filter { !$0.value.isEmpty }.keys).sorted() }

    /// The in-flight message for a command id (to know what an event refers to).
    public func inFlight(_ command: UInt16) -> MAV.CommandLong? { pending[command]?.message }

    /// Seconds until ACKs / vehicle state may confirm the in-flight command with this id (0 = now).
    public func ambiguityRemaining(_ command: UInt16, now: TimeInterval) -> TimeInterval {
        max(0, (pending[command]?.ambiguousUntil ?? -.infinity) - now)
    }

    /// Number of commands with this id waiting behind the in-flight one.
    public func queuedCount(_ command: UInt16) -> Int { queued[command]?.count ?? 0 }

    public func send(_ command: UInt16, params p: [Float] = [], now: TimeInterval) -> [MAVLinkMessage] {
        let v = p + [Float](repeating: 0, count: max(0, 7 - p.count))
        let msg = MAV.CommandLong(param1: v[0], param2: v[1], param3: v[2], param4: v[3],
                                  param5: v[4], param6: v[5], param7: v[6], command: command,
                                  targetSystem: targetSystem, targetComponent: targetComponent, confirmation: 0)
        if pending[command] != nil {
            if Self.supersedable.contains(command) {
                // BUG-002 (review 1): send the newer arm/disarm or mode change immediately and stop retrying the
                // superseded one (a late ARM retry could re-arm after DISARM). ACKs within one timeout are ambiguous.
                pending[command] = Pending(message: msg, attempts: 1, lastSent: now, ambiguousUntil: now + config.timeout)
                return [msg]
            }
            queued[command, default: []].append(msg) // FIFO: each servo/relay/motor/message request goes out
            return []
        }
        pending[command] = Pending(message: msg, attempts: 1, lastSent: now)
        return [msg]
    }

    /// BUG-002: the vehicle's own state (HEARTBEAT armed flag / custom mode) shows the in-flight command took effect.
    public func confirmByState(_ command: UInt16, now: TimeInterval) -> [Event] {
        // review 2: not inside the ambiguity window either: a heartbeat from before the superseded command took effect
        // could otherwise "confirm" a lost DISARM.
        guard let p = pending[command], now >= p.ambiguousUntil else { return [] }
        pending[command] = nil
        releaseQueued(command)
        return [.accepted(command: command)]
    }

    /// The earlier command with this id is resolved: the next queued one goes out on the next tick
    /// (attempts 0, lastSent far in the past) and is then retried on its own.
    private func releaseQueued(_ command: UInt16) {
        guard var q = queued[command], !q.isEmpty else { return }
        let next = q.removeFirst()
        queued[command] = q.isEmpty ? nil : q
        pending[command] = Pending(message: next, attempts: 0, lastSent: -.infinity)
    }

    // Convenience builders for the commands the app uses.

    public func arm(_ arm: Bool, force: Bool = false, now: TimeInterval) -> [MAVLinkMessage] {
        send(MAVCmd.componentArmDisarm, params: [arm ? 1 : 0, force ? 21196 : 0], now: now)
    }

    /// ArduPilot: MAV_CMD_DO_SET_MODE, param1 = MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, param2 = custom mode.
    public func setMode(_ customMode: UInt32, now: TimeInterval) -> [MAVLinkMessage] {
        send(MAVCmd.doSetMode, params: [Float(MAVModeFlag.customModeEnabled), Float(customMode)], now: now)
    }

    /// MAV_CMD_PREFLIGHT_REBOOT_SHUTDOWN param1 = 1 (reboot autopilot).
    public func reboot(now: TimeInterval) -> [MAVLinkMessage] {
        send(MAVCmd.preflightRebootShutdown, params: [1], now: now)
    }

    public func handle(_ ack: MAV.CommandAck, now: TimeInterval) -> [Event] {
        guard let p = pending[ack.command] else { return [] }
        // BUG-002: may be the superseded command's ACK. Ignore; a later ACK (after our resend) or the vehicle state decides.
        if now < p.ambiguousUntil { return [] }
        switch ack.result {
        case MAVResult.accepted.rawValue:
            pending[ack.command] = nil
            releaseQueued(ack.command)
            return [.accepted(command: ack.command)]
        case MAVResult.inProgress.rawValue:
            pending[ack.command]?.lastSent = now // keep waiting, don't resend
            return [.inProgress(command: ack.command, progress: ack.progress)]
        default:
            pending[ack.command] = nil
            releaseQueued(ack.command)
            return [.rejected(command: ack.command, result: ack.result)]
        }
    }

    public func tick(now: TimeInterval) -> (messages: [MAVLinkMessage], events: [Event]) {
        var out: [MAVLinkMessage] = []
        var events: [Event] = []
        for (cmd, item) in pending where now - item.lastSent >= config.timeout {
            var p = item
            if p.attempts >= config.attempts {
                pending[cmd] = nil
                events.append(.timedOut(command: cmd))
                releaseQueued(cmd)
            } else {
                // review 2: a released queued command's first send: a duplicate ACK of the previous one (same id) may
                // still arrive, so its ACKs only count after a short window.
                if p.attempts == 0 { p.ambiguousUntil = now + min(0.5, config.timeout / 3) }
                p.attempts += 1
                p.lastSent = now
                p.message.confirmation = UInt8(min(255, max(0, p.attempts - 1))) // MAVLink: increment on resend
                pending[cmd] = p
                out.append(p.message)
            }
        }
        return (out, events)
    }

    public static func resultText(_ result: UInt8) -> String {
        switch MAVResult(rawValue: result) {
        case .accepted: return "Accepted"
        case .temporarilyRejected: return "Temporarily rejected"
        case .denied: return "Denied"
        case .unsupported: return "Unsupported"
        case .failed: return "Failed"
        case .inProgress: return "In progress"
        case .cancelled: return "Cancelled"
        case .none: return "Result \(result)"
        }
    }
}

extension MAVLinkSender {
    /// Packs a message whose concrete type is only known at runtime.
    public func pack(any message: MAVLinkMessage) -> [UInt8] {
        let info = type(of: message).mavInfo
        let seq = takeSequence()
        let payload = message.payloadBytes()
        if version == .v1, let v1 = MAVLinkFraming.encodeV1(messageID: info.id, crcExtra: info.crcExtra, payload: payload,
                                                            sequence: seq, systemID: systemID, componentID: componentID) {
            return v1
        }
        return MAVLinkFraming.encodeV2(messageID: info.id, crcExtra: info.crcExtra, payload: payload,
                                       sequence: seq, systemID: systemID, componentID: componentID)
    }
}
