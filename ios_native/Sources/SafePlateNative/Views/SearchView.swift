import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                MapboxMapView()
                    .frame(height: 320)
                    .cornerRadius(12)
                Text("Mapa (Mapbox) - São Paulo centrado")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Buscar")
        }
    }
}
