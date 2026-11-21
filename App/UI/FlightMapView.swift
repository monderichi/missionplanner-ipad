// Phase 2 map: Apple Maps view with the vehicle marker rotated to heading. Flight trail, offline
// tile caching and the Mission Planner tile providers (GMap.NET) come in Phase 4.

import MapKit
import SwiftUI

struct VehicleAnnotation: Identifiable {
    let id = "vehicle"
    let coordinate: CLLocationCoordinate2D
    let heading: Double
}

struct FlightMapView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120))
    @State private var follow = true
    @State private var hasCentered = false

    private var annotations: [VehicleAnnotation] {
        guard let lat = vehicle.latitude, let lon = vehicle.longitude else { return [] }
        return [VehicleAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), heading: vehicle.yaw)]
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: annotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 2)
                        .rotationEffect(.degrees(item.heading))
                }
            }
            .ignoresSafeArea(edges: .bottom)

            Button {
                follow.toggle()
                if follow { recenter(zoom: false) }
            } label: {
                Label(follow ? "Following" : "Follow", systemImage: follow ? "location.fill" : "location")
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(10)
        }
        .onChange(of: vehicle.latitude) { _ in
            if !hasCentered { recenter(zoom: true) } else if follow { recenter(zoom: false) }
        }
    }

    private func recenter(zoom: Bool) {
        guard let lat = vehicle.latitude, let lon = vehicle.longitude else { return }
        let c = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        region = MKCoordinateRegion(center: c, span: zoom ? MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) : region.span)
        hasCentered = true
    }
}
