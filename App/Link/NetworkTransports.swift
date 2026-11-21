// REA Parity Source: MissionPlanner ExtLibs/Comms/CommsUdpSerial.cs (UdpSerial: listen on a port,
// reply to the endpoint the vehicle sent from), CommsUdpSerialConnect.cs (send to a fixed host
// first) and CommsTcpSerial.cs (TcpSerial client).
//
// Uses Network.framework. iPadOS shows the Local Network permission prompt the first time a
// socket talks to the LAN (NSLocalNetworkUsageDescription in Info.plist). Unicast only: UDP
// broadcast/multicast needs the restricted com.apple.developer.networking.multicast entitlement,
// which a free Sideloadly signing can't grant.

import Foundation
import Network

/// UDP server: listens on a local port and replies to every endpoint that has sent us data.
final class UDPListenTransport: MAVTransport {
    var onReceive: ((Data) -> Void)?
    var onStateChange: ((LinkState) -> Void)?

    private let port: UInt16
    private let queue = DispatchQueue(label: "link.udp.listen")
    private var listener: NWListener?
    private var peers: [NWEndpoint: NWConnection] = [:]

    init(port: UInt16) {
        self.port = port
    }

    func open() {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            onStateChange?(.failed("Invalid port \(port)"))
            return
        }
        onStateChange?(.connecting("UDP :\(port)"))
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        do {
            let listener = try NWListener(using: params, on: nwPort)
            listener.stateUpdateHandler = { [weak self] state in
                guard let self else { return }
                switch state {
                case .ready: self.onStateChange?(.open("Listening on UDP \(self.port)"))
                case .failed(let error): self.onStateChange?(.failed(error.localizedDescription))
                case .cancelled: self.onStateChange?(.disconnected)
                default: break
                }
            }
            listener.newConnectionHandler = { [weak self] connection in
                self?.accept(connection)
            }
            self.listener = listener
            listener.start(queue: queue)
        } catch {
            onStateChange?(.failed(error.localizedDescription))
        }
    }

    private func accept(_ connection: NWConnection) {
        let endpoint = connection.endpoint
        peers[endpoint]?.cancel()
        peers[endpoint] = connection
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed, .cancelled:
                self?.queue.async { self?.peers[endpoint] = nil }
            default:
                break
            }
        }
        connection.start(queue: queue)
        receive(on: connection)
    }

    private func receive(on connection: NWConnection) {
        connection.receiveMessage { [weak self, weak connection] data, _, _, error in
            guard let self, let connection else { return }
            if let data, !data.isEmpty {
                self.onReceive?(data)
            }
            if error == nil {
                self.receive(on: connection)
            }
        }
    }

    func send(_ data: Data) {
        queue.async {
            for connection in self.peers.values {
                connection.send(content: data, completion: .contentProcessed { _ in })
            }
        }
    }

    func close() {
        queue.async {
            self.peers.values.forEach { $0.cancel() }
            self.peers.removeAll()
            self.listener?.cancel()
            self.listener = nil
        }
    }
}

/// UDP "connect" or TCP client to a fixed host:port.
///
/// UDP with `localPort` (ExpressLRS backpack, MAVESP8266, DroneBridge): we bind that local port and
/// connect to the bridge. These bridges answer from their listen port to `<our IP>:<GCS port>`,
/// e.g. 10.0.0.1:14555 -> iPad:14550, which is exactly the peer of our connected socket.
/// Our 1 Hz GCS heartbeat is what makes the bridge learn our IP (until then it only broadcasts,
/// which a sideloaded app can't receive).
final class NWClientTransport: MAVTransport {
    enum Proto { case udp, tcp }

    var onReceive: ((Data) -> Void)?
    var onStateChange: ((LinkState) -> Void)?

    private let host: String
    private let port: UInt16
    private let proto: Proto
    /// UDP only: bind this local port instead of an ephemeral one. Needed for bridges that reply
    /// to a fixed GCS port rather than to the source port of our packets (ExpressLRS backpack).
    private let localPort: UInt16?
    /// Only use Wi-Fi (bridge hotspots have no internet; never let iPadOS pick cellular/VPN).
    private let wifiOnly: Bool
    private let queue = DispatchQueue(label: "link.nw.client")
    private var connection: NWConnection?
    private var closed = false
    private var generation = 0

    init(host: String, port: UInt16, proto: Proto, localPort: UInt16? = nil, wifiOnly: Bool = false) {
        self.host = host
        self.port = port
        self.proto = proto
        self.localPort = localPort
        self.wifiOnly = wifiOnly
    }

    private var label: String {
        let local = localPort.map { " (iPad :\($0))" } ?? ""
        return "\(proto == .udp ? "UDP" : "TCP") \(host):\(port)\(local)"
    }

    func open() {
        guard NWEndpoint.Port(rawValue: port) != nil, !host.isEmpty else {
            onStateChange?(.failed("Invalid host or port"))
            return
        }
        queue.async {
            self.closed = false
            self.start()
        }
    }

    /// Runs on `queue`.
    private func start() {
        guard !closed, let nwPort = NWEndpoint.Port(rawValue: port) else { return }
        generation += 1
        let gen = generation
        onStateChange?(.connecting(label))

        let params: NWParameters
        switch proto {
        case .udp:
            params = NWParameters(dtls: nil, udp: NWProtocolUDP.Options())
            if let localPort, let lp = NWEndpoint.Port(rawValue: localPort) {
                params.requiredLocalEndpoint = .hostPort(host: .ipv4(.any), port: lp)
                params.allowLocalEndpointReuse = true
            }
        case .tcp:
            let tcp = NWProtocolTCP.Options()
            tcp.noDelay = true
            tcp.connectionTimeout = 10
            params = NWParameters(tls: nil, tcp: tcp)
        }
        if wifiOnly { params.requiredInterfaceType = .wifi }

        let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: params)
        connection.stateUpdateHandler = { [weak self, weak connection] state in
            guard let self, gen == self.generation, !self.closed else { return }
            switch state {
            case .ready:
                self.onStateChange?(.open(self.label))
            case .waiting(let error):
                // No Wi-Fi yet, Local Network permission pending/denied, or no route.
                // NWConnection doesn't always recover by itself, so nudge it.
                self.onStateChange?(.connecting("\(self.label): \(Self.explain(error))"))
                self.queue.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self, gen == self.generation, !self.closed else { return }
                    connection?.restart()
                }
            case .failed(let error):
                self.onStateChange?(.failed(Self.explain(error)))
                if self.proto == .udp { self.retryLater(gen) } // UDP has no session to lose: just reopen
            case .cancelled:
                break
            default:
                break
            }
        }
        self.connection = connection
        connection.start(queue: queue)
        receive(on: connection, gen: gen)
    }

    private func retryLater(_ gen: Int) {
        queue.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self, gen == self.generation, !self.closed else { return }
            self.connection?.cancel()
            self.start()
        }
    }

    private func receive(on connection: NWConnection, gen: Int) {
        switch proto {
        case .udp:
            connection.receiveMessage { [weak self] data, _, _, error in
                guard let self, gen == self.generation, !self.closed else { return }
                if let data, !data.isEmpty { self.onReceive?(data) }
                if error == nil {
                    self.receive(on: connection, gen: gen)
                } else {
                    // e.g. ICMP port unreachable while the bridge boots: keep listening
                    self.queue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let self, gen == self.generation, !self.closed else { return }
                        self.receive(on: connection, gen: gen)
                    }
                }
            }
        case .tcp:
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
                guard let self, gen == self.generation, !self.closed else { return }
                if let data, !data.isEmpty { self.onReceive?(data) }
                if isComplete {
                    self.onStateChange?(.failed("Connection closed by remote"))
                } else if error == nil {
                    self.receive(on: connection, gen: gen)
                }
            }
        }
    }

    func send(_ data: Data) {
        queue.async {
            self.connection?.send(content: data, completion: .contentProcessed { _ in })
        }
    }

    func close() {
        queue.async {
            self.closed = true
            self.connection?.cancel()
            self.connection = nil
        }
    }

    private static func explain(_ error: NWError) -> String {
        if case .dns(let code) = error, code == -65570 { // kDNSServiceErr_PolicyDenied
            return "Local Network access denied (Settings › Mission Planner › Local Network)"
        }
        if case .posix(let code) = error {
            switch code {
            case .EADDRINUSE: return "iPad port already in use. Close other GCS apps or change the iPad port."
            case .ENETUNREACH, .EHOSTUNREACH: return "Not reachable. Is the iPad joined to the vehicle's Wi-Fi?"
            case .ECONNREFUSED: return "Connection refused (nothing listening on that port)"
            default: break
            }
        }
        return error.localizedDescription
    }
}