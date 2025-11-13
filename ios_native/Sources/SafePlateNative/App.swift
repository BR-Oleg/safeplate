import SwiftUI

@main
struct SafePlateNativeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(appState)
        }
    }
}
