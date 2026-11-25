// Flight Data map: vehicle, home, trail, the current mission/fence/rally, with map tools.

import MapKit
import MAVLinkKit
import SwiftUI

struct FlightMapView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var mission: MissionStore
    @EnvironmentObject var commands: CommandCenter
    @AppStorage("map.source") private var sourceRaw = TileSource.appleHybrid.rawValue
    @State private var follow = true
    @State private var flyTarget: GeoPoint?
    @State private var flyAlt: Double = 20
    @State private var visible: (MKMapRect, Int)?

    private var source: TileSource { TileSource(rawValue: sourceRaw) ?? .appleHybrid }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapCanvas(vehicle: vehicle, mission: mission, tileSource: source, follow: follow,
                      onLongPress: { p in
                          guard mission.isAttached else { return }
                          flyAlt = max(10, (vehicle.relativeAltitude / 5).rounded() * 5)
                          flyTarget = p
                      },
                      regionChanged: { rect, zoom in visible = (rect, zoom) })
                .ignoresSafeArea(edges: .bottom)
            VStack(alignment: .trailing, spacing: 8) {
                MapToolsMenu(sourceRaw: $sourceRaw, visible: visible)
                Button {
                    follow.toggle()
                } label: {
                    Label(follow ? "Following" : "Follow", systemImage: follow ? "location.fill" : "location")
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                Button {
                    vehicle.clearTrail()
                } label: {
                    Label("Clear trail", systemImage: "scribble")
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(10)
            if let b = mission.banner {
                Text(b).font(.caption).padding(6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 10)
                    .onTapGesture { mission.banner = nil }
            }
            if let a = source.attribution {
                Text(a).font(.caption2).padding(4).background(.ultraThinMaterial)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .alert("Fly here?", isPresented: Binding(get: { flyTarget != nil }, set: { if !$0 { flyTarget = nil } })) {
            TextField("Altitude (m above home)", value: $flyAlt, format: .number)
                .keyboardType(.decimalPad)
            Button("Fly here") { flyHere() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(vehicle.armed
                 ? "The vehicle switches to GUIDED and flies to the pressed point at this altitude (above home)."
                 : "The vehicle is not armed. In Copter, arm and take off in GUIDED first (Actions tab).")
        }
    }

    private func flyHere() {
        guard let p = flyTarget else { return }
        flyTarget = nil
        if let g = ArduPilotModes.guided(for: vehicle.vehicleType), vehicle.customMode != g {
            commands.setMode(g, name: "Guided")
        }
        // give the mode change a moment on slow links, then send the guided target
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            mission.guidedGoTo(p, altitude: Float(flyAlt))
        }
    }
}

/// Map source picker + offline area download, shared by Flight Data and Plan.
struct MapToolsMenu: View {
    @Binding var sourceRaw: String
    var visible: (MKMapRect, Int)?
    @State private var downloading: (done: Int, total: Int, failed: Int)?
    @State private var cancel: (() -> Void)?
    @State private var confirm: [TileCache.TileKey]?
    @State private var message: String?

    private var source: TileSource { TileSource(rawValue: sourceRaw) ?? .appleHybrid }

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Menu {
                Picker("Map", selection: $sourceRaw) {
                    ForEach(TileSource.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                if source.allowsAreaDownload {
                    Button {
                        prepareDownload()
                    } label: {
                        Label("Download visible area for offline use", systemImage: "arrow.down.circle")
                    }
                    Button {
                        let bytes = TileCache.shared.size(source)
                        message = "Offline tiles: \(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file))"
                    } label: {
                        Label("Offline tiles size", systemImage: "internaldrive")
                    }
                    Button(role: .destructive) {
                        TileCache.shared.clear(source)
                        message = "Offline tiles deleted"
                    } label: {
                        Label("Delete offline tiles", systemImage: "trash")
                    }
                }
            } label: {
                Label("Map", systemImage: "map")
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            if let d = downloading {
                HStack {
                    ProgressView(value: Double(d.done), total: Double(max(d.total, 1))).frame(width: 120)
                    Text("\(d.done)/\(d.total)").font(.caption).monospacedDigit()
                    Button("Stop") { cancel?(); downloading = nil }
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            if let m = message {
                Text(m).font(.caption).padding(6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { message = nil }
            }
        }
        .alert("Download offline map?", isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } })) {
            Button("Download") { if let t = confirm { start(t) } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(confirm?.count ?? 0) tiles of the visible area, from this zoom to 4 levels closer (max 19). Do this at home on internet Wi-Fi; at the field the ExpressLRS hotspot has no internet.")
        }
    }

    private func prepareDownload() {
        guard let v = visible else { return }
        let rect = v.0, zoom = v.1
        let z0 = max(1, min(zoom, 18))
        var z1 = min(source.maxZoom, z0 + 4)
        var tiles = TileCache.tiles(in: rect, zooms: z0...z1)
        while tiles.count > 6000 && z1 > z0 { // keep it reasonable (and polite to the provider)
            z1 -= 1
            tiles = TileCache.tiles(in: rect, zooms: z0...z1)
        }
        if tiles.count > 6000 {
            message = "Area too large: zoom in further and try again"
        } else {
            confirm = tiles
        }
    }

    private func start(_ tiles: [TileCache.TileKey]) {
        downloading = (0, tiles.count, 0)
        cancel = TileCache.shared.download(source, tiles: tiles, progress: { done, total, failed in
            downloading = (done, total, failed)
        }, done: { done, failed in
            downloading = nil
            message = failed > 0 ? "Saved \(done - failed) tiles, \(failed) failed (no internet?)" : "Saved \(done) tiles for offline use"
        })
    }
}
