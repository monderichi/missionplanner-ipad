// REA Parity Source: MissionPlanner GCSViews/FlightData.cs + FlightPlanner.cs map (GMap.NET):
// vehicle marker rotated to yaw, home "H", red flight trail, mission path with numbered markers,
// geofence polygons/circles, rally "R" points, survey polygon; in the planner, click to add and
// drag to move waypoints.

import MapKit
import MAVLinkKit
import SwiftUI

enum MapEditTarget: Equatable {
    case none
    case mission, fence, rally, survey
}

final class MapItemAnnotation: NSObject, MKAnnotation {
    enum Kind: Equatable { case vehicle, home, mission, fence, rally, survey }
    let kind: Kind
    var index: Int
    @objc dynamic var coordinate: CLLocationCoordinate2D // KVO: MapKit moves the marker when this changes
    var label: String
    var heading: Double = 0

    init(kind: Kind, index: Int, coordinate: CLLocationCoordinate2D, label: String) {
        self.kind = kind
        self.index = index
        self.coordinate = coordinate
        self.label = label
    }

    var title: String? { label }
}

final class TrailPolyline: MKPolyline {}
final class MissionPolyline: MKPolyline {}
final class SurveyPolygon: MKPolygon {}
final class FencePolygon: MKPolygon {}
final class FenceCircle: MKCircle {}

struct MapCanvas: UIViewRepresentable {
    @ObservedObject var vehicle: VehicleModel
    @ObservedObject var mission: MissionStore
    var tileSource: TileSource
    var editTarget: MapEditTarget = .none
    var follow: Bool = false
    var showMission: Bool = true
    var onTap: ((GeoPoint) -> Void)?
    var onMove: ((MapEditTarget, Int, GeoPoint) -> Void)?
    var onSelect: ((MapEditTarget, Int) -> Void)?
    /// Long-press anywhere (Flight Data: "Fly here").
    var onLongPress: ((GeoPoint) -> Void)?
    /// Lets parents read the visible area (e.g. for tile download).
    var regionChanged: ((MKMapRect, Int) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsCompass = true
        map.showsScale = true
        map.isPitchEnabled = false
        map.pointOfInterestFilter = .excludingAll
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(_:)))
        tap.delegate = context.coordinator
        map.addGestureRecognizer(tap)
        let long = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPressed(_:)))
        long.minimumPressDuration = 0.6
        map.addGestureRecognizer(long)
        context.coordinator.map = map
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.sync(map)
    }

    final class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapCanvas
        weak var map: MKMapView?
        private var tileOverlay: CachedTileOverlay?
        private var appliedSource: TileSource?
        private let vehicleAnnotation = MapItemAnnotation(kind: .vehicle, index: 0, coordinate: .init(), label: "Vehicle")
        private let homeAnnotation = MapItemAnnotation(kind: .home, index: 0, coordinate: .init(), label: "Home")
        private var planAnnotations: [MapItemAnnotation] = []
        private var planOverlays: [MKOverlay] = []
        private var trailOverlay: TrailPolyline?
        private var trailCount = -1
        private var drawnVersion = -1
        private var drawnEditTarget: MapEditTarget?
        private var drawnShowMission: Bool?
        private var centeredOnce = false

        /// Red vehicle arrow, rendered once into a bitmap so no tint can turn it black.
        static let vehicleImage: UIImage? = {
            let cfg = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
                .applying(UIImage.SymbolConfiguration(paletteColors: [.systemRed]))
            guard let sym = UIImage(systemName: "location.north.fill", withConfiguration: cfg) else { return nil }
            let renderer = UIGraphicsImageRenderer(size: sym.size)
            let img = renderer.image { _ in
                sym.withTintColor(.systemRed, renderingMode: .alwaysOriginal).draw(in: CGRect(origin: .zero, size: sym.size))
            }
            return img.withRenderingMode(.alwaysOriginal)
        }()

        init(_ parent: MapCanvas) { self.parent = parent }

        // MARK: sync

        func sync(_ map: MKMapView) {
            applyTiles(map)
            syncVehicle(map)
            syncTrail(map)
            if parent.mission.version != drawnVersion || parent.editTarget != drawnEditTarget
                || parent.showMission != drawnShowMission {
                drawPlan(map)
            }
        }

        private func applyTiles(_ map: MKMapView) {
            guard appliedSource != parent.tileSource else { return }
            appliedSource = parent.tileSource
            if let o = tileOverlay { map.removeOverlay(o) }
            tileOverlay = nil
            switch parent.tileSource {
            case .appleHybrid: map.mapType = .hybrid
            case .appleStandard: map.mapType = .standard
            case .esriImagery, .openStreetMap:
                map.mapType = .standard
                let o = CachedTileOverlay(source: parent.tileSource)
                map.addOverlay(o, level: .aboveRoads)
                tileOverlay = o
            }
        }

        private func syncVehicle(_ map: MKMapView) {
            let v = parent.vehicle
            if let p = v.position {
                let c = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
                vehicleAnnotation.coordinate = c
                vehicleAnnotation.heading = v.yaw
                if !map.annotations.contains(where: { $0 === vehicleAnnotation }) { map.addAnnotation(vehicleAnnotation) }
                if let view = map.view(for: vehicleAnnotation) {
                    view.transform = CGAffineTransform(rotationAngle: CGFloat((v.yaw - map.camera.heading) * .pi / 180))
                }
                if !centeredOnce {
                    centeredOnce = true
                    map.setRegion(MKCoordinateRegion(center: c, latitudinalMeters: 400, longitudinalMeters: 400), animated: false)
                } else if parent.follow {
                    map.setCenter(c, animated: false)
                }
            } else if map.annotations.contains(where: { $0 === vehicleAnnotation }) {
                map.removeAnnotation(vehicleAnnotation)
            }
            if let h = v.home {
                homeAnnotation.coordinate = CLLocationCoordinate2D(latitude: h.latitude, longitude: h.longitude)
                if !map.annotations.contains(where: { $0 === homeAnnotation }) { map.addAnnotation(homeAnnotation) }
            }
        }

        private func syncTrail(_ map: MKMapView) {
            let trail = parent.vehicle.trail
            guard trail.count != trailCount else { return }
            trailCount = trail.count
            if let t = trailOverlay { map.removeOverlay(t) }
            trailOverlay = nil
            guard trail.count > 1 else { return }
            let coords = trail.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let line = TrailPolyline(coordinates: coords, count: coords.count)
            map.addOverlay(line, level: .aboveLabels)
            trailOverlay = line
        }

        private func drawPlan(_ map: MKMapView) {
            drawnVersion = parent.mission.version
            drawnEditTarget = parent.editTarget
            drawnShowMission = parent.showMission
            map.removeAnnotations(planAnnotations)
            map.removeOverlays(planOverlays)
            planAnnotations = []
            planOverlays = []
            guard parent.showMission else { return }
            let store = parent.mission
            let coord = { (it: MissionItem) in CLLocationCoordinate2D(latitude: it.latitude, longitude: it.longitude) }

            // mission: markers + path (home excluded from the path start like MP draws from home)
            var path: [CLLocationCoordinate2D] = []
            for (i, it) in store.mission.enumerated() where it.hasLocation {
                if i == 0 {
                    // the vehicle's own home marker is drawn separately; show plan home only if none
                    if parent.vehicle.home == nil {
                        planAnnotations.append(MapItemAnnotation(kind: .home, index: 0, coordinate: coord(it), label: "Home"))
                    }
                    path.append(coord(it))
                    continue
                }
                planAnnotations.append(MapItemAnnotation(kind: .mission, index: i, coordinate: coord(it), label: "\(i)"))
                path.append(coord(it))
            }
            if path.count > 1 { planOverlays.append(MissionPolyline(coordinates: path, count: path.count)) }

            // fence
            var group: [CLLocationCoordinate2D] = []
            var groupCmd: UInt16?
            func flush() {
                if group.count >= 3 { planOverlays.append(FencePolygon(coordinates: group, count: group.count)) }
                group = []
                groupCmd = nil
            }
            for (i, it) in store.fence.enumerated() {
                switch it.command {
                case MissionCmd.fencePolygonInclusion, MissionCmd.fencePolygonExclusion:
                    if groupCmd != it.command { flush(); groupCmd = it.command }
                    group.append(coord(it))
                case MissionCmd.fenceCircleInclusion, MissionCmd.fenceCircleExclusion:
                    flush()
                    planOverlays.append(FenceCircle(center: coord(it), radius: CLLocationDistance(it.param1)))
                default:
                    flush()
                }
                planAnnotations.append(MapItemAnnotation(kind: .fence, index: i, coordinate: coord(it), label: "F\(i + 1)"))
            }
            flush()

            for (i, it) in store.rally.enumerated() {
                planAnnotations.append(MapItemAnnotation(kind: .rally, index: i, coordinate: coord(it), label: "R\(i + 1)"))
            }

            if !store.surveyPolygon.isEmpty {
                let pts = store.surveyPolygon.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                if pts.count >= 3 { planOverlays.append(SurveyPolygon(coordinates: pts, count: pts.count)) }
                for (i, p) in pts.enumerated() {
                    planAnnotations.append(MapItemAnnotation(kind: .survey, index: i, coordinate: p, label: "S\(i + 1)"))
                }
            }
            map.addOverlays(planOverlays, level: .aboveLabels)
            map.addAnnotations(planAnnotations)
        }

        // MARK: gestures

        @objc func tapped(_ g: UITapGestureRecognizer) {
            guard let map, parent.editTarget != .none, let onTap = parent.onTap else { return }
            let c = map.convert(g.location(in: map), toCoordinateFrom: map)
            onTap(GeoPoint(latitude: c.latitude, longitude: c.longitude))
        }

        @objc func longPressed(_ g: UILongPressGestureRecognizer) {
            guard g.state == .began, let map, let cb = parent.onLongPress else { return }
            let c = map.convert(g.location(in: map), toCoordinateFrom: map)
            cb(GeoPoint(latitude: c.latitude, longitude: c.longitude))
        }

        func gestureRecognizer(_ g: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // taps on markers select them instead of adding a point
            var v: UIView? = touch.view
            while let view = v {
                if view is MKAnnotationView { return false }
                v = view.superview
            }
            return true
        }

        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }

        private func target(for kind: MapItemAnnotation.Kind) -> MapEditTarget? {
            switch kind {
            case .mission: return .mission
            case .fence: return .fence
            case .rally: return .rally
            case .survey: return .survey
            default: return nil
            }
        }

        // MARK: MKMapViewDelegate

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let a = annotation as? MapItemAnnotation else { return nil }
            switch a.kind {
            case .vehicle:
                let id = "vehicle"
                let v = mapView.dequeueReusableAnnotationView(withIdentifier: id) ?? MKAnnotationView(annotation: a, reuseIdentifier: id)
                v.annotation = a
                v.image = Coordinator.vehicleImage
                v.layer.shadowColor = UIColor.black.cgColor
                v.layer.shadowOpacity = 0.8
                v.layer.shadowRadius = 2
                v.layer.shadowOffset = .zero
                v.displayPriority = .required
                v.zPriority = .max
                return v
            default:
                let id = "item"
                let v = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView)
                    ?? MKMarkerAnnotationView(annotation: a, reuseIdentifier: id)
                v.annotation = a
                v.glyphText = a.kind == .home ? "H" : a.label
                v.titleVisibility = .hidden
                v.displayPriority = .required
                v.canShowCallout = false
                switch a.kind {
                case .home: v.markerTintColor = .systemBlue
                case .mission: v.markerTintColor = .systemGreen
                case .fence: v.markerTintColor = .systemRed
                case .rally: v.markerTintColor = .systemOrange
                case .survey: v.markerTintColor = .systemPurple
                case .vehicle: break
                }
                let editable = target(for: a.kind).map { $0 == parent.editTarget } ?? false
                v.isDraggable = editable
                return v
            }
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard newState == .ending || newState == .canceling else { return }
            view.dragState = .none
            guard newState == .ending, let a = view.annotation as? MapItemAnnotation, let t = target(for: a.kind) else { return }
            parent.onMove?(t, a.index, GeoPoint(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let a = view.annotation as? MapItemAnnotation else { return }
            mapView.deselectAnnotation(a, animated: false)
            if let t = target(for: a.kind) { parent.onSelect?(t, a.index) }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let t = overlay as? MKTileOverlay { return MKTileOverlayRenderer(tileOverlay: t) }
            if let l = overlay as? TrailPolyline {
                let r = MKPolylineRenderer(polyline: l)
                r.strokeColor = .systemRed
                r.lineWidth = 2
                return r
            }
            if let l = overlay as? MissionPolyline {
                let r = MKPolylineRenderer(polyline: l)
                r.strokeColor = .systemYellow
                r.lineWidth = 3
                return r
            }
            if let p = overlay as? FencePolygon {
                let r = MKPolygonRenderer(polygon: p)
                r.strokeColor = .systemRed
                r.fillColor = UIColor.systemRed.withAlphaComponent(0.08)
                r.lineWidth = 2
                return r
            }
            if let c = overlay as? FenceCircle {
                let r = MKCircleRenderer(circle: c)
                r.strokeColor = .systemRed
                r.fillColor = UIColor.systemRed.withAlphaComponent(0.08)
                r.lineWidth = 2
                return r
            }
            if let p = overlay as? SurveyPolygon {
                let r = MKPolygonRenderer(polygon: p)
                r.strokeColor = .systemPurple
                r.fillColor = UIColor.systemPurple.withAlphaComponent(0.15)
                r.lineWidth = 2
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoom = Int(log2(360 * Double(mapView.frame.width) / 256 / max(mapView.region.span.longitudeDelta, 1e-9)))
            parent.regionChanged?(mapView.visibleMapRect, zoom)
        }
    }
}
