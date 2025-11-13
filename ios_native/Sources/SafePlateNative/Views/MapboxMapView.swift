import SwiftUI
import MapboxMaps
import CoreLocation

struct MapboxMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MapView {
        MapboxManager.configure()
        let options = MapInitOptions(cameraOptions: CameraOptions(center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), zoom: 11))
        let mapView = MapView(frame: .zero, mapInitOptions: options)
        return mapView
    }

    func updateUIView(_ uiView: MapView, context: Context) {}
}
