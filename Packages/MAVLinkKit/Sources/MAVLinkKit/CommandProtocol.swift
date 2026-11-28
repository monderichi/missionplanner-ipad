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
    }
    private var pending: [UInt16: Pending] = [:]
    /// BUG-002: COMMAND_ACK carries only the command id, so two in-flight commands with the same id can't be told apart
    /// (an ARM's ACK used to "confirm" a DISARM sent right after it). A second command with the same id therefore waits
    /// here until the first one is resolved, then goes out (via tick) and is tracked and retried on its own.
    private var queued: [UInt16: MAV.CommandLong] = [:]

    public init(targetSystem: UInt8, targetComponent: UInt8 = 1, config: Config = Config()) {
        self.targetSystem = targetSystem
        self.targetComponent = targetComponent
        self.config = config
    }

    public var pendingCommands: [UInt16] { Set(pending.keys).union(queued.keys).sorted() }

    public func send(_ command: UInt16, params p: [Float] = [], now: TimeInterval) -> [MAVLinkMessage] {
        let v = p + [Float](repeating: 0, count: max(0, 7 - p.count))
        let msg = MAV.CommandLong(param1: v[0], param2: v[1], param3: v[2], param4: v[3],
                                  param5: v[4], param6: v[5], param7: v[6], command: command,
                                  targetSystem: targetSystem, targetComponent: targetComponent, confirmation: 0)
        if pending[command] != nil {
            // BUG-002: emergency force-disarm never waits behind another arm/disarm.
            let forceDisarm = command == MAVCmd.componentArmDisarm && v[0] == 0 && v[1] == 21196
            if !forceDisarm {
                queued[command] = msg // the newest request wins; an older queued one is dropped
                return []
            }
            queued[command] = nil
        }
        pending[command] = Pending(message: msg, attempts: 1, lastSent: now)
        return [msg]
    }

    /// BUG-002: the earlier command with this id is resolved: release the queued one. tick() sends it at once
    /// (attempts 0 and lastSent far in the past) and from then on it is retried like any other command.
    private func releaseQueued(_ command: UInt16) {
        guard let next = queued.removeValue(forKey: command) else { return }
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
        guard pending[ack.command] != nil else { return [] }
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
