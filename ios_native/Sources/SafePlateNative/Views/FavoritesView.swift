import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Seus favoritos")
                    .font(.headline)
                Text("Protótipo nativo - fase 1")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Favoritos")
        }
    }
}
