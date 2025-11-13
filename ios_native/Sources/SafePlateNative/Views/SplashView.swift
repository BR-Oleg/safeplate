import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Carregando...")
                .foregroundColor(.secondary)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                appState.proceedFromSplash()
            }
        }
    }
}
