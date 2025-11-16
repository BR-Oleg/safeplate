import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    private let userRepository: UserRepositoryProtocol = UserRepository()

    var body: some View {
        NavigationView {
            List {
                if let user = appState.currentUser {
                    Section {
                        ProfileHeaderView(user: user)
                    }
                }

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

struct ProfileHeaderView: View {
    let user: AppUser

    private var displayName: String {
        if let name = user.name, !name.isEmpty {
            return name
        }
        return user.email
    }

    private var userTypeLabel: String {
        switch user.userType {
        case "business":
            return "Empresa"
        default:
            return "Usuário"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ProfileAvatarView(name: displayName, photoUrl: user.photoUrl)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text(userTypeLabel)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(999)

                    if user.isPremiumActive {
                        Text("Premium")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.15))
                            .foregroundColor(.yellow)
                            .cornerRadius(999)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ProfileAvatarView: View {
    let name: String
    let photoUrl: String?

    private var initials: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.15))
            Text(initials)
                .font(.headline)
                .foregroundColor(.green)
        }
        .frame(width: 56, height: 56)
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
