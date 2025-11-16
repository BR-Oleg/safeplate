import SwiftUI
import UIKit

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let userRepository: UserRepositoryProtocol = UserRepository()

    var body: some View {
        VStack(spacing: 24) {
            Text("Prato Seguro")
                .font(.largeTitle)
                .bold()
            Text(isSignUp ? "Crie sua conta" : "Entre para continuar")
                .foregroundColor(.secondary)

            if let msg = errorMessage {
                Text(msg)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Senha", text: $password)
                    .textContentType(.password)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }

            Button(action: submit) {
                HStack {
                    if isLoading { ProgressView() }
                    Text(isLoading ? (isSignUp ? "Criando..." : "Entrando...") : (isSignUp ? "Criar conta" : "Entrar"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isLoading)
            .accessibilityIdentifier("loginButton")

            Button(action: { isSignUp.toggle() }) {
                Text(isSignUp ? "Já tenho conta" : "Criar nova conta")
                    .font(.subheadline)
            }

            Button(action: signInWithGoogle) {
                HStack {
                    Image(systemName: "g.circle")
                    Text("Entrar com Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(8)
            }
            .disabled(isLoading)

            Button(action: {
                appState.login()
            }) {
                Text("Continuar offline")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear { FirebaseManager.configure() }
    }

    private func submit() {
        errorMessage = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty || !trimmedEmail.contains("@") {
            errorMessage = "Informe um email válido"
            return
        }
        if password.count < 6 {
            errorMessage = "A senha deve ter pelo menos 6 caracteres"
            return
        }

        isLoading = true

        let completion: (Bool, Error?) -> Void = { success, error in
            if !success {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error?.localizedDescription ?? "Falha na autenticação"
                }
                return
            }

            handleAuthSuccess()
        }

        if isSignUp {
            AuthManager.signUp(email: trimmedEmail, password: password, completion: completion)
        } else {
            AuthManager.signIn(email: trimmedEmail, password: password, completion: completion)
        }
    }

    private func signInWithGoogle() {
        errorMessage = nil
        guard let root = rootViewController() else {
            errorMessage = "Não foi possível encontrar uma janela para o login Google"
            return
        }
        isLoading = true
        GoogleAuthManager.signIn(presenting: root) { success, error in
            if !success {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error?.localizedDescription ?? "Falha ao entrar com Google"
                }
                return
            }

            handleAuthSuccess()
        }
    }

    private func handleAuthSuccess() {
        userRepository.fetchCurrentUser { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let user):
                    appState.applyUser(user)
                    appState.login()
                case .failure(let fetchError):
                    errorMessage = fetchError.localizedDescription
                }
            }
        }
    }

    private func rootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
}
