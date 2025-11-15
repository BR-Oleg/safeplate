import SwiftUI
import CoreLocation

#if canImport(MapboxMaps) && USE_MAPBOX
import MapboxMaps

struct MapboxMapView: View {
    let establishments: [Establishment]
    var onMarkerTap: ((Establishment) -> Void)? = nil

    private var initialCenter: CLLocationCoordinate2D {
        if let first = establishments.first {
            return first.coordinate
        } else {
            // São Paulo (fallback)
            return CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333)
        }
    }

    var body: some View {
        Map(
            initialViewport: .camera(
                center: initialCenter,
                zoom: 12
            )
        ) {
            ForEvery(establishments) { establishment in
                MapViewAnnotation(coordinate: establishment.coordinate) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.25))
                                .frame(width: 32, height: 32)
                            Circle()
                                .fill(Color.green)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .frame(width: 22, height: 22)
                        }
                        Text(establishment.name)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(6)
                    }
                    .onTapGesture {
                        onMarkerTap?(establishment)
                    }
                }
                .allowOverlap(true)
                .priority(1)
            }
        }
        .mapStyle(.standard)
    }
}
#else
struct MapboxMapView: View {
    let establishments: [Establishment]
    var onMarkerTap: ((Establishment) -> Void)? = nil

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Text("Map unavailable")
                .foregroundColor(.secondary)
        }
    }
}
#endif
