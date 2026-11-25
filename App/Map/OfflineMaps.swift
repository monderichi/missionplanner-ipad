// Offline map areas. Mission Planner's GMap "Prefetch" downloads a selected rectangle; at the field the
// iPad is on the ExpressLRS hotspot with no internet, so here you save a circle (default 10 km) around
// the map centre / vehicle / home, at home on Wi-Fi, and the map then runs from Documents/tiles.

import Foundation
import MapKit
import UIKit

struct OfflineArea: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusKm: Double
    var maxZoom: Int
    /// Extra zoom level(s) for the inner 2 km (sharp imagery around the take-off spot), nil = none.
    var detailZoom: Int?
    var tileCount: Int
    var date: Date
    var source: String
}

final class OfflineMapStore: ObservableObject {
    static let shared = OfflineMapStore()

    @Published private(set) var areas: [OfflineArea] = []
    @Published private(set) var progress: (done: Int, total: Int, failed: Int)?
    @Published var message: String?

    /// Average Esri imagery tile size, for estimates only.
    static let bytesPerTile = 18 * 1024
    /// Hard cap per download (keeps it polite to the provider and the iPad's storage sane).
    static let maxTiles = 40_000
    static let detailRadiusKm = 2.0

    private var cancelHandle: (() -> Void)?
    private var pendingArea: OfflineArea?
    private let key = "offline.areas"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let list = try? JSONDecoder().decode([OfflineArea].self, from: data) {
            areas = list
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(areas) { UserDefaults.standard.set(data, forKey: key) }
    }

    var isDownloading: Bool { progress != nil }

    // MARK: tile sets

    /// Tiles whose area intersects a circle (radius in metres) around `center`, for each zoom.
    static func tiles(around center: CLLocationCoordinate2D, radiusMeters: Double, zooms: ClosedRange<Int>) -> [TileCache.TileKey] {
        let world = MKMapRect.world
        let c = MKMapPoint(center)
        let r = radiusMeters * MKMapPointsPerMeterAtLatitude(center.latitude)
        var out: [TileCache.TileKey] = []
        for z in zooms {
            let n = 1 << z
            let size = world.size.width / Double(n)
            let x0 = max(0, Int((c.x - r - world.minX) / size)), x1 = min(n - 1, Int((c.x + r - world.minX) / size))
            let y0 = max(0, Int((c.y - r - world.minY) / size)), y1 = min(n - 1, Int((c.y + r - world.minY) / size))
            guard x0 <= x1, y0 <= y1 else { continue }
            let slack = size * 0.71 // half the tile diagonal
            for x in x0...x1 {
                for y in y0...y1 {
                    let cx = world.minX + (Double(x) + 0.5) * size, cy = world.minY + (Double(y) + 0.5) * size
                    if hypot(cx - c.x, cy - c.y) <= r + slack { out.append(TileCache.TileKey(z: z, x: x, y: y)) }
                }
            }
        }
        return out
    }

    static func plan(center: CLLocationCoordinate2D, radiusKm: Double, maxZoom: Int, detail: Bool) -> [TileCache.TileKey] {
        var tiles = Self.tiles(around: center, radiusMeters: radiusKm * 1000, zooms: 6...maxZoom)
        if detail && maxZoom < 19 {
            tiles += Self.tiles(around: center, radiusMeters: min(radiusKm, detailRadiusKm) * 1000,
                                zooms: (maxZoom + 1)...min(19, maxZoom + 1))
        }
        return tiles
    }

    // MARK: downloads

    func downloadArea(name: String, center: CLLocationCoordinate2D, radiusKm: Double, maxZoom: Int, detail: Bool,
                      source: TileSource) {
        guard !isDownloading else { return }
        let tiles = Self.plan(center: center, radiusKm: radiusKm, maxZoom: maxZoom, detail: detail)
        guard tiles.count <= Self.maxTiles else {
            message = "\(tiles.count) tiles is too many (max \(Self.maxTiles)). Lower the radius or the zoom."
            return
        }
        pendingArea = OfflineArea(name: name, latitude: center.latitude, longitude: center.longitude, radiusKm: radiusKm,
                                  maxZoom: maxZoom, detailZoom: detail ? maxZoom + 1 : nil, tileCount: tiles.count,
                                  date: Date(), source: source.rawValue)
        run(tiles, source: source)
    }

    func downloadTiles(_ tiles: [TileCache.TileKey], source: TileSource) {
        guard !isDownloading else { return }
        pendingArea = nil
        run(tiles, source: source)
    }

    private func run(_ tiles: [TileCache.TileKey], source: TileSource) {
        progress = (0, tiles.count, 0)
        message = nil
        UIApplication.shared.isIdleTimerDisabled = true // keep the screen on: iOS pauses downloads in the background
        cancelHandle = TileCache.shared.download(source, tiles: tiles, progress: { [weak self] done, total, failed in
            self?.progress = (done, total, failed)
        }, done: { [weak self] done, failed in
            guard let self else { return }
            UIApplication.shared.isIdleTimerDisabled = false
            self.progress = nil
            self.cancelHandle = nil
            if var area = self.pendingArea, failed < done {
                area.date = Date()
                self.areas.removeAll { $0.name == area.name }
                self.areas.insert(area, at: 0)
                self.persist()
            }
            self.pendingArea = nil
            self.message = failed > 0
                ? "Saved \(done - failed) of \(done) tiles. \(failed) failed: check the internet connection and tap Update to fill the gaps."
                : "Saved \(done) tiles. This area now works without internet."
        })
    }

    func cancel() {
        cancelHandle?()
        cancelHandle = nil
        UIApplication.shared.isIdleTimerDisabled = false
        progress = nil
        pendingArea = nil
        message = "Download stopped. Tiles saved so far are kept; Update resumes."
    }

    func update(_ area: OfflineArea) {
        downloadArea(name: area.name, center: CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude),
                     radiusKm: area.radiusKm, maxZoom: area.maxZoom, detail: area.detailZoom != nil,
                     source: TileSource(rawValue: area.source) ?? .esriImagery)
    }

    /// Forgets the area in the list (tiles stay cached; other areas may share them).
    func remove(_ area: OfflineArea) {
        areas.removeAll { $0.id == area.id }
        persist()
    }

    func clearAll(_ source: TileSource) {
        TileCache.shared.clear(source)
        areas.removeAll { $0.source == source.rawValue }
        persist()
        message = "All offline tiles deleted"
    }
}
