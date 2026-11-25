// REA Parity Source: MissionPlanner ExtLibs/GMap.NET (map providers, disk tile cache, "Prefetch"
// of a selected area). On the iPad, the ExpressLRS hotspot has no internet, so the map at the
// field only works from tiles cached beforehand. Every tile that's shown is cached automatically,
// and "Download area" pre-fetches the visible region.
//
// Cache: Documents/tiles/<provider>/<z>/<x>/<y>.<ext> (survives Sideloadly re-signs, visible in Files).

import Foundation
import MapKit
import UIKit

enum TileSource: String, CaseIterable, Identifiable {
    case appleHybrid = "Apple Satellite"
    case appleStandard = "Apple Map"
    case esriImagery = "Esri Satellite (offline)"
    case openStreetMap = "OpenStreetMap"

    var id: String { rawValue }

    var template: String? {
        switch self {
        case .esriImagery:
            return "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
        case .openStreetMap:
            return "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        default:
            return nil
        }
    }

    var folder: String {
        switch self {
        case .esriImagery: return "esri_world_imagery"
        case .openStreetMap: return "osm"
        default: return "apple"
        }
    }

    var fileExtension: String { self == .openStreetMap ? "png" : "jpg" }
    var maxZoom: Int { self == .openStreetMap ? 19 : 19 }

    /// Bulk pre-fetch is only allowed where the provider's terms permit it
    /// (the OpenStreetMap tile usage policy forbids bulk downloading).
    var allowsAreaDownload: Bool { self == .esriImagery }

    var attribution: String? {
        switch self {
        case .esriImagery: return "Imagery © Esri, Maxar, Earthstar Geographics"
        case .openStreetMap: return "© OpenStreetMap contributors"
        default: return nil
        }
    }
}

final class TileCache {
    static let shared = TileCache()

    let root = DocumentsStore.shared.tiles
    let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 6
        config.timeoutIntervalForRequest = 15
        config.requestCachePolicy = .reloadIgnoringLocalCacheData // we keep our own cache
        config.httpAdditionalHeaders = ["User-Agent": "MissionPlannerPad/0.3 (iPadOS ground control station)"]
        session = URLSession(configuration: config)
    }

    func fileURL(_ source: TileSource, z: Int, x: Int, y: Int) -> URL {
        root.appendingPathComponent(source.folder)
            .appendingPathComponent("\(z)/\(x)/\(y).\(source.fileExtension)")
    }

    func cached(_ source: TileSource, z: Int, x: Int, y: Int) -> Data? {
        try? Data(contentsOf: fileURL(source, z: z, x: x, y: y))
    }

    func store(_ data: Data, _ source: TileSource, z: Int, x: Int, y: Int) {
        let url = fileURL(source, z: z, x: x, y: y)
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }

    func remoteURL(_ source: TileSource, z: Int, x: Int, y: Int) -> URL? {
        guard let t = source.template else { return nil }
        return URL(string: t.replacingOccurrences(of: "{z}", with: "\(z)")
            .replacingOccurrences(of: "{x}", with: "\(x)")
            .replacingOccurrences(of: "{y}", with: "\(y)"))
    }

    /// Cache first, then network (and store). Completion on an arbitrary queue.
    func load(_ source: TileSource, z: Int, x: Int, y: Int, completion: @escaping (Data?) -> Void) {
        if let d = cached(source, z: z, x: x, y: y) { return completion(d) }
        guard let url = remoteURL(source, z: z, x: x, y: y) else { return completion(nil) }
        session.dataTask(with: url) { [weak self] data, response, _ in
            guard let data, !data.isEmpty, (response as? HTTPURLResponse)?.statusCode == 200 else { return completion(nil) }
            self?.store(data, source, z: z, x: x, y: y)
            completion(data)
        }.resume()
    }

    // MARK: area download

    struct TileKey: Hashable { let z: Int, x: Int, y: Int }

    static func tiles(in rect: MKMapRect, zooms: ClosedRange<Int>) -> [TileKey] {
        var out: [TileKey] = []
        let world = MKMapRect.world
        for z in zooms {
            let n = 1 << z
            let tileSize = world.size.width / Double(n)
            let x0 = max(0, Int((rect.minX - world.minX) / tileSize))
            let x1 = min(n - 1, Int((rect.maxX - world.minX) / tileSize))
            let y0 = max(0, Int((rect.minY - world.minY) / tileSize))
            let y1 = min(n - 1, Int((rect.maxY - world.minY) / tileSize))
            guard x0 <= x1, y0 <= y1 else { continue }
            for x in x0...x1 {
                for y in y0...y1 { out.append(TileKey(z: z, x: x, y: y)) }
            }
        }
        return out
    }

    /// Downloads missing tiles; progress(done, total) on the main queue. Returns a cancel handle.
    @discardableResult
    func download(_ source: TileSource, tiles: [TileKey], progress: @escaping (Int, Int, Int) -> Void,
                  done: @escaping (Int, Int) -> Void) -> () -> Void {
        var cancelled = false
        let lock = NSLock()
        let total = tiles.count
        var finished = 0, failed = 0
        let sem = DispatchSemaphore(value: 6)
        DispatchQueue.global(qos: .utility).async {
            let group = DispatchGroup()
            for t in tiles {
                lock.lock(); let stop = cancelled; lock.unlock()
                if stop { break }
                if FileManager.default.fileExists(atPath: self.fileURL(source, z: t.z, x: t.x, y: t.y).path) {
                    lock.lock(); finished += 1; let f = finished, e = failed; lock.unlock()
                    if f % 25 == 0 { DispatchQueue.main.async { progress(f, total, e) } }
                    continue
                }
                sem.wait()
                group.enter()
                self.load(source, z: t.z, x: t.x, y: t.y) { data in
                    lock.lock()
                    finished += 1
                    if data == nil { failed += 1 }
                    let f = finished, e = failed
                    lock.unlock()
                    DispatchQueue.main.async { progress(f, total, e) }
                    sem.signal()
                    group.leave()
                }
            }
            group.wait()
            lock.lock(); let f = finished, e = failed; lock.unlock()
            DispatchQueue.main.async { done(f, e) }
        }
        return {
            lock.lock()
            cancelled = true
            lock.unlock()
        }
    }

    /// Bytes used by the cache for one provider.
    func size(_ source: TileSource) -> Int64 {
        let dir = root.appendingPathComponent(source.folder)
        guard let e = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        var total: Int64 = 0
        for case let url as URL in e {
            total += Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        }
        return total
    }

    func clear(_ source: TileSource) {
        try? FileManager.default.removeItem(at: root.appendingPathComponent(source.folder))
    }
}

/// MKTileOverlay backed by TileCache (works offline for cached tiles).
final class CachedTileOverlay: MKTileOverlay {
    let source: TileSource

    init(source: TileSource) {
        self.source = source
        super.init(urlTemplate: nil)
        canReplaceMapContent = true
        maximumZ = source.maxZoom
        tileSize = CGSize(width: 256, height: 256)
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let source = self.source
        TileCache.shared.load(source, z: path.z, x: path.x, y: path.y) { data in
            if let data { return result(data, nil) }
            // Offline and not saved at this zoom: enlarge the matching part of a saved parent tile.
            if let up = Self.overzoom(source, z: path.z, x: path.x, y: path.y) { return result(up, nil) }
            result(nil, URLError(.resourceUnavailable))
        }
    }

    /// Crops the quadrant of the nearest cached ancestor (up to 6 levels up) and scales it to 256 px.
    static func overzoom(_ source: TileSource, z: Int, x: Int, y: Int) -> Data? {
        for k in 1...6 where z - k >= 0 {
            guard let data = TileCache.shared.cached(source, z: z - k, x: x >> k, y: y >> k),
                  let image = UIImage(data: data)?.cgImage else { continue }
            let parts = 1 << k
            let w = CGFloat(image.width) / CGFloat(parts), h = CGFloat(image.height) / CGFloat(parts)
            let ox = CGFloat(x - ((x >> k) << k)) * w, oy = CGFloat(y - ((y >> k) << k)) * h
            guard let crop = image.cropping(to: CGRect(x: ox, y: oy, width: w, height: h).integral) else { continue }
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let out = UIGraphicsImageRenderer(size: CGSize(width: 256, height: 256), format: format).image { _ in
                UIImage(cgImage: crop).draw(in: CGRect(x: 0, y: 0, width: 256, height: 256))
            }
            return out.jpegData(compressionQuality: 0.85)
        }
        return nil
    }
}
