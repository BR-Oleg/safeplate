import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    private let userRepository: UserRepositoryProtocol = UserRepository()

    var body: some View {
        NavigationView {
            List {
                if appState.isPremium {
                    Section {
                        PremiumBannerRow()
                    }
                } else {
                    Section {
                        NavigationLink(destination: PremiumView()) {
                            BecomePremiumRow()
                        }
                    }
                }

                Section(header: Text("Pontos")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Seus pontos")
                                .font(.headline)
                            Text("\(appState.points) pts")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }

                Section(header: Text("Idioma")) {
                    Picker("Idioma", selection: Binding(
                        get: { appState.language },
                        set: { updateLanguage($0) }
                    )) {
                        Text("Português").tag(AppState.Language.pt)
                        Text("English").tag(AppState.Language.en)
                        Text("Español").tag(AppState.Language.es)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Ações")) {
                    NavigationLink("Meus cupons") {
                        CouponsView()
                            .environmentObject(appState)
                    }
                    NavigationLink("Modo offline") {
                        Text("Em breve")
                    }
                    NavigationLink("Indicar estabelecimento") {
                        Text("Em breve")
                    }
                }

                Section(header: Text("Conta")) {
                    Button("Sair") {
                        AuthManager.signOut { _ in
                            DispatchQueue.main.async {
                                appState.logout()
                            }
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(appState.localized("nav_profile"))
        }
    }
}

extension ProfileView {
    private func updateLanguage(_ lang: AppState.Language) {
        appState.setLanguage(lang)
        guard let userId = appState.userId else { return }
        userRepository.updatePreferredLanguage(userId: userId, languageCode: lang.rawValue) { _ in }
    }
}

struct PremiumBannerRow: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 48, height: 48)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Conta Premium ativa")
                    .font(.headline)
                Text("Você tem acesso aos filtros avançados e benefícios exclusivos.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct BecomePremiumRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 48, height: 48)
                Image(systemName: "star")
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Tornar-se Premium")
                    .font(.headline)
                Text("Desbloqueie filtros avançados e cupons exclusivos.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
