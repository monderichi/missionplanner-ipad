// REA Parity Source: MissionPlanner MainV2 speech (Config > Planner > Speech: mode change,
// armed/disarmed, warning/critical STATUSTEXT, low battery, link lost).

import AVFoundation
import Combine
import Foundation
import MAVLinkKit

final class SpeechAlerts: ObservableObject {
    @Published var enabled: Bool = UserDefaults.standard.object(forKey: "speech.enabled") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(enabled, forKey: "speech.enabled")
            if !enabled { synth.stopSpeaking(at: .immediate) }
        }
    }

    private let synth = AVSpeechSynthesizer()
    private var bag = Set<AnyCancellable>()
    private var lastSpoken: [String: Date] = [:]
    private var lastBattery = Date.distantPast

    func observe(_ v: VehicleModel) {
        bag.removeAll()
        v.$customMode.removeDuplicates().dropFirst()
            .sink { [weak self, weak v] _ in
                guard let v, v.heartbeatAlive else { return }
                DispatchQueue.main.async { self?.say("Mode \(v.modeName)") }
            }
            .store(in: &bag)
        v.$armed.removeDuplicates().dropFirst()
            .sink { [weak self] armed in self?.say(armed ? "Armed" : "Disarmed") }
            .store(in: &bag)
        v.$heartbeatAlive.removeDuplicates().dropFirst()
            .sink { [weak self] alive in self?.say(alive ? "Link restored" : "Telemetry lost") }
            .store(in: &bag)
        v.$messages.compactMap { $0.first }
            .removeDuplicates { $0.id == $1.id }
            .sink { [weak self] m in
                guard m.severity.rawValue <= MAVSeverity.warning.rawValue else { return }
                self?.say(m.text, minInterval: 60) // ArduPilot repeats PreArm text every 30 s
            }
            .store(in: &bag)
        v.$batteryRemaining.removeDuplicates()
            .sink { [weak self] pct in
                guard let self, pct >= 0, pct <= 20, Date().timeIntervalSince(self.lastBattery) > 60 else { return }
                self.lastBattery = Date()
                self.say("Battery \(pct) percent")
            }
            .store(in: &bag)
    }

    func say(_ text: String, minInterval: TimeInterval = 2) {
        guard enabled else { return }
        let now = Date()
        if let last = lastSpoken[text], now.timeIntervalSince(last) < minInterval { return }
        lastSpoken[text] = now
        let spoken = text.replacingOccurrences(of: "_", with: " ")
        let u = AVSpeechUtterance(string: spoken)
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 1.05
        synth.speak(u)
    }
}
