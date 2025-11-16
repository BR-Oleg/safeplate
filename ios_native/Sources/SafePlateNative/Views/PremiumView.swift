import SwiftUI

struct PremiumView: View {
    @EnvironmentObject var appState: AppState

    private let userRepository: UserRepositoryProtocol = UserRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                benefitsSection
                howItWorksSection
                actionSection
            }
            .padding()
        }
        .navigationTitle("Conta Premium")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SafePlate Premium")
                .font(.title2)
                .fontWeight(.bold)
            Text("Mais segurança, conveniência e vantagens para quem tem restrições alimentares.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benefícios")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Label("Filtros avançados por restrição alimentar", systemImage: "line.3.horizontal.decrease.circle")
                Label("Locais verificados com mais detalhes", systemImage: "checkmark.seal")
                Label("Cupons e recompensas exclusivos", systemImage: "gift")
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como funciona")
                .font(.headline)

            Text("No protótipo nativo, o Premium funciona apenas como visual e não realiza cobrança real. Use para demonstrar a jornada e explicar o valor para o usuário.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if appState.isPremium {
                Text("Status atual: Premium ativo")
                    .font(.subheadline)
                    .foregroundColor(.green)

                Button {
                    updatePremium(isPremium: false)
                } label: {
                    Text("Voltar para versão gratuita")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            } else {
                Text("Status atual: Conta padrão")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button {
                    updatePremium(isPremium: true)
                } label: {
                    Text("Ativar conta Premium (demo)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.top, 8)
    }

    private func updatePremium(isPremium: Bool) {
        guard let userId = appState.userId else {
            appState.setPremium(isPremium)
            return
        }

        let expiresAt: Date?
        if isPremium {
            expiresAt = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        } else {
            expiresAt = nil
        }

        userRepository.updatePremium(userId: userId, isPremium: isPremium, expiresAt: expiresAt) { _ in
            userRepository.fetchCurrentUser { result in
                DispatchQueue.main.async {
                    if case .success(let user) = result {
                        appState.applyUser(user)
                    } else {
                        appState.setPremium(isPremium)
                    }
                }
            }
        }
    }
}
