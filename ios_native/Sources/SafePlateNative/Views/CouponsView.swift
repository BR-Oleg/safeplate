import SwiftUI

struct CouponsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Seus cupons")
                    .font(.headline)
                Text("Protótipo nativo - fase 1")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Cupons")
        }
    }
}
