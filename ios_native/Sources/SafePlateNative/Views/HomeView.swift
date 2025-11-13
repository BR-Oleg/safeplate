import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
                .accessibilityIdentifier("tabSearch")

            FavoritesView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart")
                }
                .accessibilityIdentifier("tabFavorites")

            CouponsView()
                .tabItem {
                    Label("Cupons", systemImage: "tag")
                }
                .accessibilityIdentifier("tabCoupons")

            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
                .accessibilityIdentifier("tabProfile")
        }
    }
}
