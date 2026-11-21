// REA Parity Source: MissionPlanner GCSViews/FlightData.cs "Telemetry Logs" tab (Load Log, Play/Pause,
// speed, tracking bar) and MAVLinkInterface logreadmode / readPacket from a .tlog.
// The replay is a MAVTransport, so recorded packets go through exactly the same parser, vehicle
// model, HUD and map as a live link. Nothing is ever sent.

import Foundation
import MAVLinkKit

final class ReplayController: ObservableObject {
    @Published private(set) var fileName = ""
    @Published private(set) var loaded = false
    @Published private(set) var playing = false
    @Published var speed: Double = 1 { didSet { transport?.setSpeed(speed) } }
    @Published private(set) var position: Double = 0 // 0...1
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var packetCount = 0

    fileprivate weak var transport: ReplayTransport?

    func playPause() { transport?.setPlaying(!playing) }
    func seek(to fraction: Double) { transport?.seek(fraction) }

    fileprivate func update(playing: Bool, elapsed: TimeInterval, duration: TimeInterval) {
        self.playing = playing
        self.elapsed = elapsed
        self.duration = duration
        position = duration > 0 ? min(1, elapsed / duration) : 0
    }

    fileprivate func didLoad(name: String, packets: Int, duration: TimeInterval) {
        fileName = name
        packetCount = packets
        self.duration = duration
        loaded = true
    }
}

final class ReplayTransport: MAVTransport {
    var onReceive: ((Data) -> Void)?
    var onStateChange: ((LinkState) -> Void)?
    /// Called on the main queue after a backwards seek (the caller resets the trail).
    var onSeekBack: (() -> Void)?

    let url: URL
    let controller: ReplayController
    private let queue = DispatchQueue(label: "link.replay")
    private var records: [TLogReader.Record] = []
    private var index = 0
    private var logTime: TimeInterval = 0   // seconds since first record
    private var playing = false
    private var speed = 1.0
    private var timer: DispatchSourceTimer?
    private var lastTick = Date()
    private var lastPublish = Date.distantPast

    init(url: URL, controller: ReplayController) {
        self.url = url
        self.controller = controller
        controller.transport = self
    }

    private var start: Date { records.first?.date ?? Date() }
    private var duration: TimeInterval {
        guard let a = records.first?.date, let b = records.last?.date else { return 0 }
        return b.timeIntervalSince(a)
    }

    func open() {
        onStateChange?(.connecting("Loading \(url.lastPathComponent)"))
        queue.async {
            let scoped = self.url.startAccessingSecurityScopedResource()
            defer { if scoped { self.url.stopAccessingSecurityScopedResource() } }
            do {
                let reader = try TLogReader(url: self.url)
                self.records = Array(reader)
            } catch {
                self.onStateChange?(.failed("Couldn't read log: \(error.localizedDescription)"))
                return
            }
            guard !self.records.isEmpty else {
                self.onStateChange?(.failed("No MAVLink packets in \(self.url.lastPathComponent)"))
                return
            }
            let n = self.records.count, d = self.duration, name = self.url.lastPathComponent
            DispatchQueue.main.async { self.controller.didLoad(name: name, packets: n, duration: d) }
            self.onStateChange?(.open("Replaying \(name)"))
            self.startTimer()
            self.setPlayingLocked(true)
        }
    }

    func close() {
        queue.async {
            self.timer?.cancel()
            self.timer = nil
            self.playing = false
            self.records = []
        }
    }

    func send(_ data: Data) {} // a log can't receive commands

    func setSpeed(_ s: Double) {
        queue.async { self.speed = max(0.1, s) }
    }

    func setPlaying(_ on: Bool) {
        queue.async { self.setPlayingLocked(on) }
    }

    private func setPlayingLocked(_ on: Bool) {
        playing = on
        lastTick = Date()
        publish(force: true)
    }

    func seek(_ fraction: Double) {
        queue.async {
            let target = max(0, min(1, fraction)) * self.duration
            let back = target < self.logTime
            self.logTime = target
            let startDate = self.start
            // first record at or after target
            var lo = 0, hi = self.records.count
            while lo < hi {
                let mid = (lo + hi) / 2
                if self.records[mid].date.timeIntervalSince(startDate) < target { lo = mid + 1 } else { hi = mid }
            }
            self.index = lo
            if back { DispatchQueue.main.async { self.onSeekBack?() } }
            self.publish(force: true)
        }
    }

    private func startTimer() {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: .milliseconds(20))
        t.setEventHandler { [weak self] in self?.step() }
        timer = t
        t.resume()
    }

    private func step() {
        let now = Date()
        let dt = now.timeIntervalSince(lastTick)
        lastTick = now
        guard playing, !records.isEmpty else { return }
        logTime += dt * speed
        let startDate = start
        var chunk = Data()
        var n = 0
        while index < records.count, records[index].date.timeIntervalSince(startDate) <= logTime, n < 2000 {
            chunk.append(contentsOf: records[index].packet.raw)
            index += 1
            n += 1
        }
        if !chunk.isEmpty { onReceive?(chunk) }
        if index >= records.count {
            playing = false
            publish(force: true)
        } else {
            publish(force: false)
        }
    }

    private func publish(force: Bool) {
        let now = Date()
        guard force || now.timeIntervalSince(lastPublish) > 0.25 else { return }
        lastPublish = now
        let p = playing, e = logTime, d = duration
        DispatchQueue.main.async { self.controller.update(playing: p, elapsed: e, duration: d) }
    }
}
