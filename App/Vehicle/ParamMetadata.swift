// REA Parity Source: Mission Planner ParameterMetaDataBackup.xml (converted by tools/gen_param_meta.py
// into App/Resources/ParamMeta/<Firmware>.json). Same fields Mission Planner's Full Parameter
// List shows: display name, description, units, range, increment, value list, bitmask, reboot flag.

import Foundation
import MAVLinkKit

struct ParamMeta: Decodable {
    struct Option: Decodable, Hashable, Identifiable {
        let code: Double
        let label: String
        var id: Double { code }

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            code = try c.decode(Double.self)
            label = try c.decode(String.self)
        }
    }

    let n: String?
    let d: String?
    let u: String?
    let r: [Double]?
    let i: Double?
    let v: [Option]?
    let b: [Option]?
    let rb: Int?
    let ro: Int?
    let a: Int?

    var displayName: String { n ?? "" }
    var summary: String { d ?? "" }
    var units: String? { u }
    var range: ClosedRange<Double>? {
        guard let r, r.count == 2, r[0] <= r[1] else { return nil }
        return r[0]...r[1]
    }
    var increment: Double? { i }
    var values: [Option] { v ?? [] }
    var bits: [Option] { b ?? [] }
    var rebootRequired: Bool { rb == 1 }
    var readOnly: Bool { ro == 1 }
    var advanced: Bool { a == 1 }

    func label(for value: Float) -> String? {
        values.first { $0.code == Double(value) }?.label
    }
}

enum ParamMetadataRepository {
    private static var cache: [String: [String: ParamMeta]] = [:]
    private static let lock = NSLock()

    static func firmwareName(vehicleType: UInt8) -> String? {
        switch MAVType(rawValue: vehicleType)?.firmware {
        case .copter: return "ArduCopter"
        case .plane: return "ArduPlane"
        case .rover: return "ArduRover"
        case .sub: return "ArduSub"
        case .tracker: return "AntennaTracker"
        default: return nil
        }
    }

    /// Loads (and caches) the bundled metadata for one firmware. Empty if unknown.
    static func load(firmware: String) -> [String: ParamMeta] {
        lock.lock()
        defer { lock.unlock() }
        if let hit = cache[firmware] { return hit }
        let url = Bundle.main.url(forResource: firmware, withExtension: "json")
            ?? Bundle.main.url(forResource: firmware, withExtension: "json", subdirectory: "ParamMeta")
        guard let url, let data = try? Data(contentsOf: url),
              let meta = try? JSONDecoder().decode([String: ParamMeta].self, from: data) else {
            return [:]
        }
        cache[firmware] = meta
        return meta
    }
}
