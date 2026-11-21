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
    let params = ParameterStore()
    let commands = CommandCenter()

    /// Stream rates in Hz requested on connect, like Mission Planner's defaults
    /// (Config > Planner > Telemetry rates / SRx_* params).
    static let defaultStreamRates: [MAVDataStream: UInt16] = [
        .rawSensors: 2, .extendedStatus: 2, .rcChannels: 2, .position: 3,
        .extra1: 10, .extra2: 10, .extra3: 2,
    ]

    /// ExpressLRS MAVLink telemetry is a few kB/s at best (shared with RC on a 1:2 ratio).
    /// REQUEST_DATA_STREAM overrides the FC's SRx_* rates for that port, so ask for little:
    /// HUD at 4 Hz, status/position at 1-2 Hz, and stop RAW_SENSORS (IMU/baro) entirely.
    static let narrowLinkStreamRates: [MAVDataStream: UInt16] = [
        .rawSensors: 0, .extendedStatus: 1, .rcChannels: 1, .position: 2,
        .extra1: 4, .extra2: 2, .extra3: 1,
    ]

    var streamRates: [MAVDataStream: UInt16] = LinkManager.defaultStreamRates

    private var transport: MAVTransport?
    private let parser = MAVLinkParser()
    private let sender = MAVLinkSender(systemID: 255, componentID: 190)
    private let ioQueue = DispatchQueue(label: "link.io")
    private var tlog: TLogWriter?
    private var heartbeatTimer: DispatchSourceTimer?
    private var controlTimer: DispatchSourceTimer?
    private var pendingBytes = 0
    private var narrowLink = false
    /// sysid the parameter/command sessions are attached to (survives short link dropouts).
    private var attachedSystem: UInt8?
    private var redownloadAfterReboot = false

    init() {
        params.send = { [weak self] m in self?.send(any: m) }
        commands.send = { [weak self] m in self?.send(any: m) }
        commands.onRebootAccepted = { [weak self] in
            self?.redownloadAfterReboot = true
            self?.params.markRebooted()
        }
    }

    // MARK: connect / disconnect

    func connect(kind: LinkKind, host: String, port: UInt16, localPort: UInt16 = 14550, bleDevice: UUID?) {
        disconnect()
        let t: MAVTransport
        switch kind {
        case .udpListen: t = UDPListenTransport(port: port)
        case .udpConnect: t = NWClientTransport(host: host, port: port, proto: .udp, localPort: localPort)
        case .tcp: t = NWClientTransport(host: host, port: port, proto: .tcp)
        case .elrs: t = NWClientTransport(host: host, port: port, proto: .udp, localPort: localPort, wifiOnly: true)
        case .ble:
            guard let id = bleDevice else {
                state = .failed("Pick a Bluetooth device first")
                return
            }
            t = BLETransport(deviceID: id)
        }
        narrowLink = kind == .elrs || kind == .ble
        streamRates = narrowLink ? Self.narrowLinkStreamRates : Self.defaultStreamRates

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
        controlTimer?.cancel()
        controlTimer = nil
        params.detach()
        commands.detach()
        attachedSystem = nil
        redownloadAfterReboot = false
        transport?.onReceive = nil
        transport?.onStateChange = nil // a late callback from the old link must not overwrite the new state
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

    /// For messages whose concrete type is only known at runtime (parameter/command sessions).
    func send(any message: MAVLinkMessage) {
        guard let transport else { return }
        let bytes = sender.pack(any: message)
        ioQueue.async {
            self.tlog?.write(raw: bytes)
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

        // 4 Hz: parameter/command retries and timeouts
        let control = DispatchSource.makeTimerSource(queue: .main)
        control.schedule(deadline: .now() + 0.25, repeating: 0.25)
        control.setEventHandler { [weak self] in
            self?.params.tick()
            self?.commands.tick()
        }
        controlTimer = control
        control.resume()
    }

    /// Main queue. A vehicle (re)appeared: attach sessions the first time we see this sysid,
    /// re-download parameters after a reboot, and (re)request streams every time.
    private func vehicleAppeared() {
        guard let sys = vehicle.systemID else { return }
        let comp = vehicle.componentID
        if attachedSystem != sys {
            attachedSystem = sys
            params.attach(systemID: sys, componentID: comp, vehicleType: vehicle.vehicleType, narrowLink: narrowLink)
            commands.attach(systemID: sys, componentID: comp, narrowLink: narrowLink)
        } else if redownloadAfterReboot {
            redownloadAfterReboot = false
            params.download()
        }
        requestDataStreams()
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
                guard p.systemID == self.attachedSystem else { continue }
                if p.messageID == MAV.ParamValue.mavInfo.id, let m = p.decode(MAV.ParamValue.self) {
                    self.params.handle(m)
                } else if p.messageID == MAV.CommandAck.mavInfo.id, let m = p.decode(MAV.CommandAck.self) {
                    self.commands.handle(m)
                }
            }
            if newVehicle { self.vehicleAppeared() }
        }
    }
}
