// REA Parity Source: MissionPlanner Joystick/JoystickBase.cs (axis scaling, deadzone, expo, button mask,
// 10 Hz MANUAL_CONTROL loop) and ArduSub's MAVLink MANUAL_CONTROL (msg 69) handling as used by
// QGroundControl's joystick.
//
// Axis mapping (stick values are -1...1, up = +1, then deadzone, expo and gain are applied):
//   ArduSub  : x = forward/back  (right stick up/down)    -1000...1000
//              y = lateral       (right stick left/right) -1000...1000
//              z = throttle/heave (left stick up/down)    0...1000, 500 = neutral (1000 = up)
//              r = yaw           (left stick left/right)  -1000...1000
//   ArduRover: (Rover/GCS_MAVLink_Rover.cpp handle_manual_control_axes, verified 2026-11-27)
//              y = steering (right stick left/right) -1000...1000, z = throttle (left stick up/down)
//              -1000...1000, 0 = centre/stop; x and r are not used by Rover.
// Buttons bitmask: A=0 B=1 X=2 Y=3 L1=4 R1=5 menu=6 options=7 dpad up/down/left/right=8-11 L2=12 R2=13 L3=14 R3=15.

import Combine
import CoreGraphics
import Foundation
import GameController
import MAVLinkKit
import UIKit

final class ManualControl: ObservableObject {
    struct Frame: Equatable {
        var x = 0, y = 0, z = 0, r = 0
        var buttons: UInt16 = 0
    }

    // wiring (set by LinkManager)
    weak var vehicle: VehicleModel?
    var send: ((MAV.ManualControl) -> Void)?
    var linkActive: () -> Bool = { false }

    /// Explicit per-session opt-in. Never persisted.
    @Published private(set) var enabled = false
    /// Local scale applied to every axis (ArduSub also has JS_GAIN_* on the vehicle).
    @Published var gain: Double = {
        let g = UserDefaults.standard.object(forKey: "manual.gain") as? Double ?? 1.0
        return min(1.0, max(0.1, g))
    }() {
        didSet { UserDefaults.standard.set(gain, forKey: "manual.gain") }
    }
    /// On-screen sticks: x right, y up, both -1...1 (the pads write these).
    @Published var leftStick = CGPoint.zero
    @Published var rightStick = CGPoint.zero
    @Published private(set) var gamepadName: String?
    /// Use the connected game controller when there is one (off = on-screen sticks even with a pad).
    // bool(forKey:) also reads a "-manual.useGamepad NO" launch argument (the simulator CI uses it).
    @Published var useGamepad: Bool = (UserDefaults.standard.object(forKey: "manual.useGamepad") == nil
        ? true : UserDefaults.standard.bool(forKey: "manual.useGamepad")) {
        didSet { UserDefaults.standard.set(useGamepad, forKey: "manual.useGamepad") }
    }
    /// True when the sticks come from a game controller rather than the on-screen pads.
    var usingGamepad: Bool { useGamepad && gamepadName != nil }
    /// The frame that is (or would be) sent, for the live bars.
    @Published private(set) var frame = Frame()

    static let deadzone = 0.05
    static let expo = 0.2
    static let rate: TimeInterval = 0.1

    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var pad: GCController?

    init() {
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
            self?.refreshGamepad()
        })
        observers.append(nc.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            self?.refreshGamepad()
        })
        observers.append(nc.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.setEnabled(false) // leaving the app: one neutral frame, then stop
        })
        refreshGamepad()
        let t = Timer(timeInterval: Self.rate, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    deinit {
        timer?.invalidate()
        for o in observers { NotificationCenter.default.removeObserver(o) }
    }

    // MARK: vehicle support

    enum Kind { case sub, rover, unsupported }

    static func kind(vehicleType: UInt8) -> Kind {
        guard let fw = MAVType(rawValue: vehicleType)?.firmware else { return .unsupported }
        switch fw {
        case .sub: return .sub
        case .rover: return .rover
        default: return .unsupported
        }
    }

    var kind: Kind {
        guard let v = vehicle else { return .unsupported }
        return Self.kind(vehicleType: v.vehicleType)
    }
    var isSupported: Bool { kind != .unsupported }

    // MARK: enable / disable

    func setEnabled(_ on: Bool) {
        if on {
            guard !enabled, isSupported, vehicle?.heartbeatAlive == true, linkActive() else { return }
            enabled = true
        } else if enabled {
            enabled = false
            sendFrame(neutral())
        }
    }

    // MARK: loop

    private struct Inputs {
        var lx = 0.0, ly = 0.0, rx = 0.0, ry = 0.0
        var buttons: UInt16 = 0
    }

    private func refreshGamepad() {
        pad = GCController.controllers().first { $0.extendedGamepad != nil }
        let name: String? = pad.map { $0.vendorName ?? "Game controller" }
        if name != gamepadName { gamepadName = name }
    }

    private func readInputs() -> Inputs {
        var i = Inputs()
        if useGamepad, let g = pad?.extendedGamepad {
            i.lx = Double(g.leftThumbstick.xAxis.value)
            i.ly = Double(g.leftThumbstick.yAxis.value)
            i.rx = Double(g.rightThumbstick.xAxis.value)
            i.ry = Double(g.rightThumbstick.yAxis.value)
            let optionsDown: Bool = g.buttonOptions?.isPressed ?? false
            let l3Down: Bool = g.leftThumbstickButton?.isPressed ?? false
            let r3Down: Bool = g.rightThumbstickButton?.isPressed ?? false
            let pressed: [Bool] = [
                g.buttonA.isPressed, g.buttonB.isPressed, g.buttonX.isPressed, g.buttonY.isPressed,
                g.leftShoulder.isPressed, g.rightShoulder.isPressed,
                g.buttonMenu.isPressed, optionsDown,
                g.dpad.up.isPressed, g.dpad.down.isPressed, g.dpad.left.isPressed, g.dpad.right.isPressed,
                g.leftTrigger.isPressed, g.rightTrigger.isPressed,
                l3Down, r3Down,
            ]
            var mask: UInt16 = 0
            for (bit, down) in pressed.enumerated() where down { mask |= UInt16(1) << UInt16(bit) }
            i.buttons = mask
        } else {
            i.lx = Double(leftStick.x)
            i.ly = Double(leftStick.y)
            i.rx = Double(rightStick.x)
            i.ry = Double(rightStick.y)
        }
        return i
    }

    /// Deadzone, then a blend of linear and cubic (expo), sign preserved.
    static func shape(_ v: Double) -> Double {
        guard v.isFinite else { return 0 } // BUG-038: NaN became full deflection via min/max clamping
        let a = abs(v)
        if a < deadzone { return 0 }
        let n = (min(a, 1) - deadzone) / (1 - deadzone)
        let e = (1 - expo) * n + expo * n * n * n
        return v < 0 ? -e : e
    }

    private func scaled(_ v: Double) -> Int {
        let s = max(-1.0, min(1.0, Self.shape(v) * gain))
        return Int((s * 1000).rounded())
    }

    private func neutral() -> Frame {
        var f = Frame()
        if kind == .sub { f.z = 500 }
        return f
    }

    private func compute() -> Frame {
        let k = kind
        if k == .unsupported { return Frame() }
        let i = readInputs()
        var f = Frame()
        f.buttons = i.buttons
        if k == .sub {
            f.x = scaled(i.ry)
            f.y = scaled(i.rx)
            f.r = scaled(i.lx)
            f.z = 500 + scaled(i.ly) / 2
        } else {
            // ArduRover GCS_MAVLINK_Rover::handle_manual_control_axes:
            //   manual_override(channel_steer, packet.y, 1000, 2000) / manual_override(channel_throttle, packet.z, 1000, 2000)
            // i.e. y = steering and z = throttle, both -1000...1000 with 0 = centre. x and r are ignored by Rover.
            f.y = scaled(i.rx)
            f.z = scaled(i.ly)
        }
        return f
    }

    private func tick() {
        if enabled && (!isSupported || vehicle?.heartbeatAlive != true || !linkActive()) {
            setEnabled(false) // link lost / disconnected / vehicle changed type
        }
        let f = compute()
        if f != frame { frame = f }
        if enabled { sendFrame(f) }
    }

    private func sendFrame(_ f: Frame) {
        guard let sys = vehicle?.systemID else { return }
        let m = MAV.ManualControl(x: Self.i16(f.x), y: Self.i16(f.y), z: Self.i16(f.z), r: Self.i16(f.r),
                                  buttons: f.buttons, target: sys)
        send?(m)
    }

    private static func i16(_ v: Int) -> Int16 { Int16(max(-1000, min(1000, v))) }
}
