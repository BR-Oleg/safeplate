import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.phase {
            case .splash:
                SplashView()
            case .unauthenticated:
                LoginView()
            case .authenticated:
                HomeView()
            }
        }
    }
}
