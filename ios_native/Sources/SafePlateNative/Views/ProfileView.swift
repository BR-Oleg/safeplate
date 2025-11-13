import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Conta")) {
                    Button("Sair") { appState.logout() }
                }
                Section(header: Text("App")) {
                    NavigationLink("Modo offline (stub)") { Text("Em breve") }
                    NavigationLink("Premium (stub)") { Text("Em breve") }
                    NavigationLink("Indicar estabelecimento (stub)") { Text("Em breve") }
                }
            }
            .navigationTitle("Perfil")
        }
    }
}
