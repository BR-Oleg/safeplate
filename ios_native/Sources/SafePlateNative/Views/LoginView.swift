import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text("Prato Seguro")
                .font(.largeTitle)
                .bold()
            Text("Entre para continuar")
                .foregroundColor(.secondary)

            if let msg = errorMessage {
                Text(msg)
                    .foregroundColor(.red)
            }

            Button(action: signIn) {
                HStack {
                    if isLoading { ProgressView().tint(.white) }
                    Text(isLoading ? "Entrando..." : "Entrar")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isLoading)
            .accessibilityIdentifier("loginButton")
        }
        .padding()
        .onAppear { FirebaseManager.configure() }
    }

    private func signIn() {
        errorMessage = nil
        isLoading = true
        AuthManager.signInAnonymously { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    appState.login()
                } else {
                    errorMessage = error?.localizedDescription ?? "Falha ao entrar (continuando offline)"
                    appState.login() // fallback para fluxo offline / testes
                }
            }
        }
    }
}
