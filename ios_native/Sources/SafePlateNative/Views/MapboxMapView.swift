import SwiftUI
import CoreLocation

#if canImport(MapboxMaps) && USE_MAPBOX
import MapboxMaps

struct MapboxMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MapView {
        MapboxManager.configure()
        let resourceOptions = ResourceOptions(accessToken: MapboxManager.accessToken)
        let options = MapInitOptions(resourceOptions: resourceOptions, cameraOptions: CameraOptions(center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), zoom: 11))
        let mapView = MapView(frame: .zero, mapInitOptions: options)
        return mapView
    }

    func updateUIView(_ uiView: MapView, context: Context) {}
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
