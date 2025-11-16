import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label(appState.localized("tab_search"), systemImage: "magnifyingglass")
                }
                .accessibilityIdentifier("tabSearch")

            FavoritesView()
                .tabItem {
                    Label(appState.localized("tab_favorites"), systemImage: "heart")
                }
                .accessibilityIdentifier("tabFavorites")

            CouponsView()
                .tabItem {
                    Label(appState.localized("tab_coupons"), systemImage: "tag")
                }
                .accessibilityIdentifier("tabCoupons")

            ProfileView()
                .tabItem {
                    Label(appState.localized("tab_profile"), systemImage: "person")
                }
                .accessibilityIdentifier("tabProfile")
        }
    }
}
