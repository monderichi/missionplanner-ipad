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
    /// Long-press menu target, and the distance tool's two points.
    @State private var menuPoint: GeoPoint?
    @State private var measureStart: GeoPoint?
    @State private var measureEnd: GeoPoint?

    private var source: TileSource { TileSource(rawValue: sourceRaw) ?? .appleHybrid }

    private var measureText: String? {
        guard let a = measureStart, let b = measureEnd else { return nil }
        let d = Geo.distance(a, b)
        let ds = d >= 1000 ? String(format: "%.2f km", d / 1000) : String(format: "%.0f m", d)
        return "\(ds) · bearing \(Int(Geo.bearing(a, b).rounded()))°"
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapCanvas(vehicle: vehicle, mission: mission, tileSource: source, follow: follow,
                      measureStart: measureStart, measureEnd: measureEnd,
                      onLongPress: { p in
                          if measureStart != nil && measureEnd == nil {
                              measureEnd = p   // second point of the distance tool
                          } else {
                              menuPoint = p
                          }
                      },
                      regionChanged: { rect, zoom in visible = (rect, zoom) })
                .ignoresSafeArea(edges: .bottom)
            if measureStart != nil {
                HStack(spacing: 8) {
                    Image(systemName: "ruler")
                    Text(measureText ?? "Long-press the second point")
                        .font(.callout).monospacedDigit()
                    Button {
                        measureStart = nil
                        measureEnd = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(10)
            }
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
        .confirmationDialog("Map point", isPresented: Binding(get: { menuPoint != nil }, set: { if !$0 { menuPoint = nil } }),
                            titleVisibility: .visible) {
            if let p = menuPoint {
                Button("Fly here (Guided)…") {
                    flyAlt = max(10, (vehicle.relativeAltitude / 5).rounded() * 5)
                    // let the dialog finish dismissing before the altitude alert appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { flyTarget = p }
                }
                .disabled(!mission.isAttached)
                Button("Point camera here (ROI)") {
                    // MAV_CMD_DO_SET_ROI_LOCATION: lat/lon travel as COMMAND_LONG floats, which only keep
                    // about 1 m of precision; fine for pointing a camera.
                    commands.command(195, params: [0, 0, 0, 0, Float(p.latitude), Float(p.longitude), 0],
                                     label: "Point camera at map position")
                }
                .disabled(!mission.isAttached)
                Button("Measure distance from here") {
                    measureStart = p
                    measureEnd = nil
                }
                Button("Cancel", role: .cancel) {}
            }
        } message: {
            if let p = menuPoint { Text(String(format: "%.6f, %.6f", p.latitude, p.longitude)) }
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

/// Map source picker + offline maps, shared by Flight Data and Plan.
struct MapToolsMenu: View {
    @Binding var sourceRaw: String
    var visible: (MKMapRect, Int)?
    @ObservedObject private var offline = OfflineMapStore.shared
    @State private var showOffline = false

    private var source: TileSource { TileSource(rawValue: sourceRaw) ?? .appleHybrid }

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Menu {
                Picker("Map", selection: $sourceRaw) {
                    ForEach(TileSource.allCases) { Text($0.rawValue).tag($0.rawValue) }
                }
                Button {
                    showOffline = true
                } label: {
                    Label("Offline maps…", systemImage: "square.and.arrow.down.on.square")
                }
            } label: {
                Label("Map", systemImage: "map")
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            if let d = offline.progress {
                HStack {
                    ProgressView(value: Double(d.done), total: Double(max(d.total, 1))).frame(width: 120)
                    Text("\(d.done)/\(d.total)").font(.caption).monospacedDigit()
                    Button("Stop") { offline.cancel() }
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            if let m = offline.message, !showOffline {
                Text(m).font(.caption).padding(6).frame(maxWidth: 320, alignment: .trailing)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { offline.message = nil }
            }
        }
        .sheet(isPresented: $showOffline) {
            OfflineMapSheet(sourceRaw: $sourceRaw, visible: visible)
        }
    }
}

/// Save a circle of map tiles for use without internet.
struct OfflineMapSheet: View {
    @EnvironmentObject var vehicle: VehicleModel
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var offline = OfflineMapStore.shared
    @Binding var sourceRaw: String
    var visible: (MKMapRect, Int)?

    enum Center: String, CaseIterable, Identifiable {
        case map = "Map centre", vehicle = "Drone", home = "Home"
        var id: String { rawValue }
    }

    @AppStorage("offline.radiusKm") private var radiusKm = 10.0
    @AppStorage("offline.maxZoom") private var maxZoom = 17
    @AppStorage("offline.detail") private var detail = true
    @State private var center = Center.map
    @State private var name = ""
    @State private var confirmClear = false
    @State private var spaceUsed: Int64 = 0

    private var source: TileSource { .esriImagery } // the provider that allows saving areas

    private var centerCoordinate: CLLocationCoordinate2D? {
        switch center {
        case .map:
            guard let v = visible else { return nil }
            return MKMapPoint(x: v.0.midX, y: v.0.midY).coordinate
        case .vehicle:
            return vehicle.position.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        case .home:
            return vehicle.home.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
    }

    private var estimate: Int {
        guard let c = centerCoordinate else { return 0 }
        return OfflineMapStore.plan(center: c, radiusKm: radiusKm, maxZoom: maxZoom, detail: detail).count
    }

    var body: some View {
        NavigationStack {
            Form {
                if sourceRaw != TileSource.esriImagery.rawValue {
                    Section {
                        Button {
                            sourceRaw = TileSource.esriImagery.rawValue
                        } label: {
                            Label("Switch the map to Esri Satellite", systemImage: "globe.europe.africa")
                        }
                    } footer: {
                        Text("Saved areas use Esri satellite imagery. Apple's maps can't be stored, so without internet they stay blank.")
                    }
                }
                Section {
                    Picker("Centre", selection: $center) {
                        ForEach(Center.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    if let c = centerCoordinate {
                        Text(String(format: "%.5f, %.5f", c.latitude, c.longitude)).font(.caption).foregroundColor(.secondary)
                    } else {
                        Text(center == .map ? "Move the map first" : "Not known yet (connect to the drone)")
                            .font(.caption).foregroundColor(.orange)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Radius")
                            Spacer()
                            Text("\(Int(radiusKm)) km").monospacedDigit()
                        }
                        Slider(value: $radiusKm, in: 1...20, step: 1)
                    }
                    Picker("Detail", selection: $maxZoom) {
                        Text("Normal (zoom 16)").tag(16)
                        Text("High (zoom 17)").tag(17)
                        Text("Very high (zoom 18)").tag(18)
                    }
                    Toggle("Extra detail within 2 km of the centre", isOn: $detail)
                    TextField("Name (e.g. flying field)", text: $name)
                } header: {
                    Text("Area to save")
                }
                Section {
                    LabeledContent("Tiles", value: "\(estimate)")
                    LabeledContent("About", value: ByteCountFormatter.string(fromByteCount: Int64(estimate * OfflineMapStore.bytesPerTile), countStyle: .file))
                    if let p = offline.progress {
                        ProgressView(value: Double(p.done), total: Double(max(p.total, 1)))
                        Text("\(p.done) / \(p.total)\(p.failed > 0 ? " · \(p.failed) failed" : "")").font(.caption).monospacedDigit()
                        Button("Stop", role: .destructive) { offline.cancel() }
                    } else {
                        Button {
                            guard let c = centerCoordinate else { return }
                            let n = name.trimmingCharacters(in: .whitespaces)
                            offline.downloadArea(name: n.isEmpty ? String(format: "%.3f, %.3f", c.latitude, c.longitude) : n,
                                                 center: c, radiusKm: radiusKm, maxZoom: maxZoom, detail: detail, source: source)
                            sourceRaw = TileSource.esriImagery.rawValue
                        } label: {
                            Label("Download for offline use", systemImage: "arrow.down.circle.fill")
                        }
                        .disabled(centerCoordinate == nil || estimate == 0 || estimate > OfflineMapStore.maxTiles)
                    }
                    if let m = offline.message { Text(m).font(.callout) }
                } footer: {
                    Text("Do this at home on internet Wi-Fi, before going to the field (the ExpressLRS hotspot has no internet). Keep the app open until it finishes; the screen stays on. Already-saved tiles are skipped, so Update only fetches what's missing.")
                }
                Section("Saved areas") {
                    if offline.areas.isEmpty { Text("None yet").foregroundColor(.secondary) }
                    ForEach(offline.areas) { a in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(a.name)
                                Text("\(Int(a.radiusKm)) km · zoom \(a.maxZoom)\(a.detailZoom.map { "+\($0) centre" } ?? "") · \(a.tileCount) tiles · \(a.date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Update") { offline.update(a) }
                                .disabled(offline.isDownloading)
                        }
                        .swipeActions {
                            Button("Remove", role: .destructive) { offline.remove(a) }
                        }
                    }
                    LabeledContent("Space used", value: ByteCountFormatter.string(fromByteCount: spaceUsed, countStyle: .file))
                    Button("Delete all offline map tiles", role: .destructive) { confirmClear = true }
                        .disabled(offline.isDownloading)
                }
            }
            .navigationTitle("Offline maps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .onAppear {
                if visible == nil { center = vehicle.position != nil ? .vehicle : .home }
                refreshSpace()
            }
            .onChange(of: offline.isDownloading) { _ in refreshSpace() }
            .confirmationDialog("Delete all offline tiles?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { offline.clearAll(source); refreshSpace() }
            } message: {
                Text("The map will need internet again until you re-download an area.")
            }
        }
    }

    private func refreshSpace() {
        let s = source
        DispatchQueue.global(qos: .utility).async {
            let bytes = TileCache.shared.size(s)
            DispatchQueue.main.async { spaceUsed = bytes }
        }
    }
}