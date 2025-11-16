import SwiftUI
import CoreLocation

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText: String = ""
    @State private var showOnlyOpen: Bool = false
    @State private var showOnlyNearby: Bool = false
    @State private var hasSearchText: Bool = false
    @State private var searchHistory: [String] = []

    private enum SortOption {
        case distance
        case name
    }

    @State private var sortOption: SortOption = .distance

    private let repository = EstablishmentRepository()
    private let remoteRepository = FirestoreEstablishmentRepository()
    @State private var establishments: [Establishment] = []
    @State private var selectedEstablishment: Establishment?

    @State private var maxDistanceKm: Double = 10.0
    @State private var minRating: Double? = nil
    @State private var selectedCategories: Set<String> = []
    @State private var showingAdvancedFilters: Bool = false
    @State private var showingPremiumAlert: Bool = false

    // Ponto de referência aproximado (São Paulo) para simular distância do usuário
    private let userLocation = CLLocation(latitude: -23.5505, longitude: -46.6333)

    private var availableCategories: [String] {
        let all = establishments.flatMap { $0.categories }
        return Array(Set(all)).sorted()
    }

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
        if showOnlyNearby {
            result = result.filter { distance(from: $0) <= maxDistanceKm * 1000 }
        }
        if let minRating = minRating {
            result = result.filter { $0.rating >= minRating }
        }
        if !selectedCategories.isEmpty {
            result = result.filter { est in
                let categories = Set(est.categories)
                return !categories.isDisjoint(with: selectedCategories)
            }
        }

        switch sortOption {
        case .distance:
            result = result.sorted { distance(from: $0) < distance(from: $1) }
        case .name:
            result = result.sorted { $0.name < $1.name }
        }
        return result
    }

    private func distance(from establishment: Establishment) -> CLLocationDistance {
        let location = CLLocation(latitude: establishment.latitude, longitude: establishment.longitude)
        return location.distance(from: userLocation)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                // Search bar + botão de filtros avançados
                HStack {
                    TextField("Buscar estabelecimentos", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 4)
                        .padding(.leading, 4)
                        .onChange(of: searchText) { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            hasSearchText = !trimmed.isEmpty
                            if !trimmed.isEmpty {
                                addToHistory(trimmed)
                            }
                        }
                    if hasSearchText {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    } else if !searchHistory.isEmpty {
                        Menu {
                            ForEach(searchHistory, id: \\.self) { item in
                                Button(item) {
                                    searchText = item
                                }
                            }
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.secondary)
                        }
                    }
                    Button(action: {
                        if appState.isPremium {
                            showingAdvancedFilters = true
                        } else {
                            showingPremiumAlert = true
                        }
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)

                // Chips de ação rápida (Abertos, Perto, Ordenação)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(isSelected: $showOnlyOpen, systemIcon: "clock", label: "Abertos agora")
                        FilterChip(isSelected: $showOnlyNearby, systemIcon: "location", label: "Mais próximos")

                        Menu {
                            Button("Mais próximos") { sortOption = .distance }
                            Button("Nome (A-Z)") { sortOption = .name }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(sortOption == .distance ? "Ordenar por distância" : "Ordenar por nome")
                            }
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }

                Text("\(filteredEstablishments.count) locais encontrados")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // Map + markers filling the rest
                MapboxMapView(establishments: filteredEstablishments) { establishment in
                    selectedEstablishment = establishment
                }
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle(appState.localized("nav_search"))
            .onAppear {
                if establishments.isEmpty {
                    establishments = repository.fetchAll()
                }
                loadRemoteEstablishments()
            }
            .sheet(item: $selectedEstablishment) { establishment in
                EstablishmentQuickDetailView(establishment: establishment)
            }
            .sheet(isPresented: $showingAdvancedFilters) {
                AdvancedFiltersSheet(
                    maxDistanceKm: $maxDistanceKm,
                    minRating: $minRating,
                    allCategories: availableCategories,
                    selectedCategories: $selectedCategories
                )
            }
            .alert("Filtros Avançados", isPresented: $showingPremiumAlert) {
                Button("Fechar", role: .cancel) {}
            } message: {
                Text("Os filtros avançados são exclusivos para usuários Premium no protótipo Flutter. Use a tela de Perfil/Premium para simular o upgrade.")
            }
        }
    }

    private func addToHistory(_ query: String) {
        var history = searchHistory
        history.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
        history.insert(query, at: 0)
        if history.count > 5 {
            history = Array(history.prefix(5))
        }
        searchHistory = history
    }

    private func loadRemoteEstablishments() {
        remoteRepository.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let remote):
                    if !remote.isEmpty {
                        establishments = remote
                    }
                case .failure(let error):
                    print("Failed to load establishments from Firestore: \(error)")
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

struct EstablishmentQuickDetailView: View {
    let establishment: Establishment

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(establishment.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(establishment.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Label(String(format: "%.1f", establishment.rating), systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    if !establishment.categories.isEmpty {
                        Text(establishment.categories.joined(separator: " · "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(24)
    }
}

struct AdvancedFiltersSheet: View {
    @Binding var maxDistanceKm: Double
    @Binding var minRating: Double?
    let allCategories: [String]
    @Binding var selectedCategories: Set<String>

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Distância máxima: \(String(format: "%.1f", maxDistanceKm)) km")
                        .font(.headline)
                    Slider(
                        value: $maxDistanceKm,
                        in: 1...50,
                        step: 1
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Avaliação mínima: \(minRating.map { String(format: "%.1f", $0) } ?? "Qualquer")")
                        .font(.headline)
                    Slider(
                        value: Binding(
                            get: { minRating ?? 0 },
                            set: { newValue in
                                minRating = newValue > 0 ? newValue : nil
                            }
                        ),
                        in: 0...5,
                        step: 0.5
                    )
                }

                if !allCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categorias")
                            .font(.headline)
                        WrapCategories(allCategories: allCategories, selected: $selectedCategories)
                    }
                }

                Spacer()

                HStack {
                    Button("Limpar") {
                        maxDistanceKm = 10
                        minRating = nil
                        selectedCategories.removeAll()
                    }
                    Spacer()
                    Button("Aplicar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                }
            }
            .padding()
            .navigationTitle("Filtros avançados")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WrapCategories: View {
    let allCategories: [String]
    @Binding var selected: Set<String>

    var body: some View {
        FlexibleView(data: allCategories, spacing: 8, alignment: .leading) { category in
            let isSelected = selected.contains(category)
            Button(action: {
                if isSelected {
                    selected.remove(category)
                } else {
                    selected.insert(category)
                }
            }) {
                Text(category)
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
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            var width: CGFloat = 0
            var height: CGFloat = 0

            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                ForEach(Array(data), id: \.self) { element in
                    content(element)
                        .padding(.all, 4)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geometry.size.width {
                                width = 0
                                height -= d.height + spacing
                            }
                            let result = width
                            if let last = data.last, last == element {
                                width = 0
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if let last = data.last, last == element {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
