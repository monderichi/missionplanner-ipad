// REA Parity Source: MissionPlanner ExtLibs/ArduPilot/Mavlink/MAVLinkInterface.cs
//   - Open(): heartbeat wait, then getDatastream / requestDatastream for each MAV_DATA_STREAM
//   - SerialReader loop: readPacket -> logfile (tlog, both directions) -> MAVState update
//   - GCS identity sysid 255 / compid 190, GCS heartbeat once per second
//   - Link-lost detection from heartbeat silence
//
// Threading: transports call back on their own queues; parsing and tlog writes happen on
// `ioQueue`; model updates are hopped to the main queue for SwiftUI.

import Foundation
import MAVLinkKit

final class LinkManager: ObservableObject {
    @Published private(set) var state: LinkState = .disconnected
    @Published private(set) var stats = MAVLinkParser.Stats()
    @Published private(set) var tlogURL: URL?
    @Published private(set) var bytesReceived = 0
    @Published var recordTLog = true

    let vehicle = VehicleModel()

    /// Stream rates in Hz requested on connect, like Mission Planner's defaults
    /// (Config > Planner > Telemetry rates / SRx_* params).
    var streamRates: [MAVDataStream: UInt16] = [
        .rawSensors: 2, .extendedStatus: 2, .rcChannels: 2, .position: 3,
        .extra1: 10, .extra2: 10, .extra3: 2,
    ]

    private var transport: MAVTransport?
    private let parser = MAVLinkParser()
    private let sender = MAVLinkSender(systemID: 255, componentID: 190)
    private let ioQueue = DispatchQueue(label: "link.io")
    private var tlog: TLogWriter?
    private var heartbeatTimer: DispatchSourceTimer?
    private var pendingBytes = 0

    // MARK: connect / disconnect

    func connect(kind: LinkKind, host: String, port: UInt16, bleDevice: UUID?) {
        disconnect()
        let t: MAVTransport
        switch kind {
        case .udpListen: t = UDPListenTransport(port: port)
        case .udpConnect: t = NWClientTransport(host: host, port: port, proto: .udp)
        case .tcp: t = NWClientTransport(host: host, port: port, proto: .tcp)
        case .ble:
            guard let id = bleDevice else {
                state = .failed("Pick a Bluetooth device first")
                return
            }
            t = BLETransport(deviceID: id)
        }

        ioQueue.sync {
            parser.reset()
            pendingBytes = 0
        }
        vehicle.reset()
        stats = MAVLinkParser.Stats()
        bytesReceived = 0

        if recordTLog {
            do {
                let writer = try TLogWriter(directory: DocumentsStore.shared.tlogs)
                ioQueue.sync { tlog = writer }
                tlogURL = writer.url
            } catch {
                tlogURL = nil
            }
        }

        t.onStateChange = { [weak self] s in
            DispatchQueue.main.async { self?.state = s }
        }
        t.onReceive = { [weak self] data in
            self?.ioQueue.async { self?.process(data) }
        }
        transport = t
        t.open()
        startHeartbeat()
    }

    func disconnect() {
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
        transport?.onReceive = nil
        transport?.close()
        transport = nil
        ioQueue.sync {
            tlog?.close()
            tlog = nil
        }
        state = .disconnected
        vehicle.tick(now: .distantFuture)
    }

    // MARK: sending

    func send<M: MAVLinkMessage>(_ message: M) {
        guard let transport else { return }
        let bytes = sender.pack(message)
        ioQueue.async {
            self.tlog?.write(raw: bytes) // Mission Planner logs outgoing packets too
            transport.send(Data(bytes))
        }
    }

    /// REQUEST_DATA_STREAM for each stream, as MAVLinkInterface.requestDatastream does.
    func requestDataStreams() {
        guard let sys = vehicle.systemID else { return }
        let comp = vehicle.componentID
        for (stream, rate) in streamRates.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            send(MAV.RequestDataStream(reqMessageRate: rate, targetSystem: sys, targetComponent: comp,
                                       reqStreamId: stream.rawValue, startStop: rate > 0 ? 1 : 0))
        }
    }

    // MARK: internals

    private func startHeartbeat() {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            // GCS heartbeat (MAV_TYPE_GCS, MAV_AUTOPILOT_INVALID, MAV_STATE_ACTIVE). UDP-connect
            // bridges only start forwarding once they've heard from us.
            self.send(MAV.Heartbeat(customMode: 0, type: MAVType.gcs.rawValue, autopilot: MAVAutopilot.invalid,
                                    baseMode: 0, systemStatus: MAVState.active.rawValue, mavlinkVersion: 3))
            self.vehicle.tick()
            self.ioQueue.async {
                let s = self.parser.stats
                let n = self.pendingBytes
                DispatchQueue.main.async {
                    self.stats = s
                    self.bytesReceived = n
                }
            }
        }
        heartbeatTimer = timer
        timer.resume()
    }

    /// Runs on ioQueue.
    private func process(_ data: Data) {
        pendingBytes += data.count
        let packets = parser.parse(data)
        guard !packets.isEmpty else { return }
        if let tlog {
            for p in packets { tlog.write(p) }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var newVehicle = false
            for p in packets {
                if p.messageID == MAV.RadioStatus.mavInfo.id {
                    self.vehicle.handleRadio(p)
                }
                if self.vehicle.handle(p) { newVehicle = true }
            }
            if newVehicle { self.requestDataStreams() }
        }
    }
}
