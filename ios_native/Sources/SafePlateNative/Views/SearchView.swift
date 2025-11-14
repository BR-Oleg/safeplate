import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var showOnlyOpen: Bool = false
    @State private var sortByName: Bool = false

    private let repository = EstablishmentRepository()
    @State private var establishments: [Establishment] = []

    private var filteredEstablishments: [Establishment] {
        var result = establishments
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { est in
                est.name.lowercased().contains(query) ||
                est.description.lowercased().contains(query)
            }
        }
        if showOnlyOpen {
            // Simplified proxy: treat higher-rated places as "em destaque/abertos"
            result = result.filter { $0.rating >= 4.0 }
        }
        if sortByName {
            result = result.sorted { $0.name < $1.name }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                // Search bar + quick actions (simplified)
                HStack {
                    TextField("Buscar estabelecimentos", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Quick filter chips (very simplified vs Flutter)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(isSelected: $showOnlyOpen, systemIcon: "clock", label: "Abertos")
                        FilterChip(isSelected: $sortByName, systemIcon: "textformat", label: "Ordenar por nome")
                    }
                    .padding(.horizontal)
                }

                // Map + markers filling the rest
                MapboxMapView(establishments: filteredEstablishments) { establishment in
                    // Placeholder: could show a bottom sheet with details
                    print("Tapped \(establishment.name)")
                }
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("Buscar")
            .onAppear {
                if establishments.isEmpty {
                    establishments = repository.fetchAll()
                }
            }
        }
    }
}

struct FilterChip: View {
    @Binding var isSelected: Bool
    let systemIcon: String
    let label: String

    var body: some View {
        Button(action: { isSelected.toggle() }) {
            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                Text(label)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.green.opacity(0.15) : Color(.systemGray6))
            .foregroundColor(isSelected ? .green : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
