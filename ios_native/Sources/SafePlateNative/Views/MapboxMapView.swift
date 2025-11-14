import SwiftUI
import CoreLocation

#if canImport(MapboxMaps) && USE_MAPBOX
import MapboxMaps

struct MapboxMapView: View {
    var body: some View {
        Map(
            initialViewport: .camera(
                center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                zoom: 11
            )
        )
    }
}
#else
struct MapboxMapView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Text("Map unavailable")
                .foregroundColor(.secondary)
        }
    }
}
#endif
