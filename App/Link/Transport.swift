// REA Parity Source: MissionPlanner ExtLibs/Comms (ICommsSerial, UdpSerial, UdpSerialConnect,
// TcpSerial). Mission Planner's USB serial (SerialPort) has no equivalent here: iPadOS doesn't
// let sideloaded apps open USB CDC/ACM devices, so the supported links are UDP, TCP and BLE.

import Foundation

enum LinkState: Equatable {
    case disconnected
    case connecting(String)
    /// Transport is open (socket listening/connected, BLE characteristic subscribed).
    /// Whether a vehicle is actually talking is tracked separately via heartbeats.
    case open(String)
    case failed(String)

    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting(let s): return "Connecting \(s)…"
        case .open(let s): return s
        case .failed(let s): return "Failed: \(s)"
        }
    }

    var isActive: Bool {
        switch self {
        case .connecting, .open: return true
        case .disconnected, .failed: return false
        }
    }
}

/// A byte pipe to the vehicle. Callbacks may arrive on any queue.
protocol MAVTransport: AnyObject {
    var onReceive: ((Data) -> Void)? { get set }
    var onStateChange: ((LinkState) -> Void)? { get set }
    func open()
    func close()
    func send(_ data: Data)
}

enum LinkKind: String, CaseIterable, Identifiable, Codable {
    case udpListen = "UDP listen"
    case udpConnect = "UDP connect"
    case tcp = "TCP"
    case ble = "Bluetooth LE"

    var id: String { rawValue }

    var help: String {
        switch self {
        case .udpListen:
            return "Waits for the vehicle on this iPad's port (default 14550). Use for ESP8266/ESP32 telemetry, MAVLink-Router or SITL sending to the iPad's IP."
        case .udpConnect:
            return "Sends to a fixed host:port first, then talks to whoever answers. Use for bridges that wait for a GCS (e.g. DroneBridge, 192.168.4.1:14550)."
        case .tcp:
            return "Connects to a TCP server, e.g. SITL on 5760 or a companion computer / ESP bridge on 5760/2000."
        case .ble:
            return "Bluetooth LE serial bridges using the Nordic UART service or HM-10 style FFE0/FFE1."
        }
    }

    var defaultPort: UInt16 {
        switch self {
        case .udpListen, .udpConnect: return 14550
        case .tcp: return 5760
        case .ble: return 0
        }
    }
}
