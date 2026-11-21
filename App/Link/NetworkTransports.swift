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
final class NWClientTransport: MAVTransport {
    enum Proto { case udp, tcp }

    var onReceive: ((Data) -> Void)?
    var onStateChange: ((LinkState) -> Void)?

    private let host: String
    private let port: UInt16
    private let proto: Proto
    private let queue = DispatchQueue(label: "link.nw.client")
    private var connection: NWConnection?

    init(host: String, port: UInt16, proto: Proto) {
        self.host = host
        self.port = port
        self.proto = proto
    }

    private var label: String { "\(proto == .udp ? "UDP" : "TCP") \(host):\(port)" }

    func open() {
        guard let nwPort = NWEndpoint.Port(rawValue: port), !host.isEmpty else {
            onStateChange?(.failed("Invalid host or port"))
            return
        }
        onStateChange?(.connecting(label))
        let params: NWParameters
        switch proto {
        case .udp:
            params = .udp
        case .tcp:
            let tcp = NWProtocolTCP.Options()
            tcp.noDelay = true
            tcp.connectionTimeout = 10
            params = NWParameters(tls: nil, tcp: tcp)
        }
        let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: params)
        connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready: self.onStateChange?(.open(self.label))
            case .waiting(let error): self.onStateChange?(.connecting("\(self.label) (\(error.localizedDescription))"))
            case .failed(let error): self.onStateChange?(.failed(error.localizedDescription))
            case .cancelled: self.onStateChange?(.disconnected)
            default: break
            }
        }
        self.connection = connection
        connection.start(queue: queue)
        receive()
    }

    private func receive() {
        guard let connection else { return }
        switch proto {
        case .udp:
            connection.receiveMessage { [weak self] data, _, _, error in
                guard let self else { return }
                if let data, !data.isEmpty { self.onReceive?(data) }
                if error == nil { self.receive() }
            }
        case .tcp:
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
                guard let self else { return }
                if let data, !data.isEmpty { self.onReceive?(data) }
                if isComplete {
                    self.onStateChange?(.failed("Connection closed by remote"))
                } else if error == nil {
                    self.receive()
                }
            }
        }
    }

    func send(_ data: Data) {
        connection?.send(content: data, completion: .contentProcessed { _ in })
    }

    func close() {
        connection?.cancel()
        connection = nil
    }
}
