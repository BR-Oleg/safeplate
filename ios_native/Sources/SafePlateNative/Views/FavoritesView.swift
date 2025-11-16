import SwiftUI
import CoreLocation
import UIKit

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState

    private let repository = EstablishmentRepository()
    private let favoritesRepository: FavoritesRepositoryProtocol = FavoritesRepository()
    @State private var establishments: [Establishment] = []
    @State private var favoriteIDs: Set<String> = []
    @State private var routeEstablishment: Establishment?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private var favorites: [Establishment] {
        establishments.filter { favoriteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Text(appState.localized("nav_favorites"))
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    if !favorites.isEmpty {
                        Text("\(favorites.count) favoritos")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if favorites.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Nenhum favorito ainda")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        MapboxMapView(establishments: favorites) { establishment in
                            routeEstablishment = establishment
                        }
                        .frame(height: 260)

                        List {
                            ForEach(favorites) { establishment in
                                FavoriteRow(establishment: establishment, isFavorite: favoriteIDs.contains(establishment.id)) {
                                    toggleFavorite(establishment)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(appState.localized("nav_favorites"))
            .onAppear {
                if establishments.isEmpty {
                    establishments = repository.fetchAll()
                }
                loadFavorites()
            }
            .alert(item: $routeEstablishment) { establishment in
                Alert(
                    title: Text(establishment.name),
                    message: Text("Deseja abrir a rota para este local no Mapas?"),
                    primaryButton: .default(Text("Gerar rota")) {
                        openRoute(to: establishment)
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
        }
    }

    private func toggleFavorite(_ establishment: Establishment) {
        guard let userId = appState.userId else {
            if favoriteIDs.contains(establishment.id) {
                favoriteIDs.remove(establishment.id)
            } else {
                favoriteIDs.insert(establishment.id)
            }
            return
        }

        let newValue = !favoriteIDs.contains(establishment.id)
        favoritesRepository.setFavorite(establishmentId: establishment.id, userId: userId, isFavorite: newValue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if newValue {
                        favoriteIDs.insert(establishment.id)
                    } else {
                        favoriteIDs.remove(establishment.id)
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadFavorites() {
        guard let userId = appState.userId else {
            favoriteIDs = Set(establishments.map { $0.id })
            return
        }
        isLoading = true
        errorMessage = nil
        favoritesRepository.fetchFavoriteIDs(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let ids):
                    favoriteIDs = ids
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    favoriteIDs = Set(establishments.map { $0.id })
                }
            }
        }
    }

    private func openRoute(to establishment: Establishment) {
        let coordinate = establishment.coordinate
        let urlString = "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

struct FavoriteRow: View {
    let establishment: Establishment
    let isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(establishment.name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.green)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(establishment.name)
                    .font(.headline)
                Text(establishment.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Label(String(format: "%.1f", establishment.rating), systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    if !establishment.categories.isEmpty {
                        Text(establishment.categories.joined(separator: " · "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
