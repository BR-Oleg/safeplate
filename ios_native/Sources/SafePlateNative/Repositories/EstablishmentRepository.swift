import Foundation

protocol EstablishmentRepositoryProtocol {
    func fetchAll() -> [Establishment]
}

struct EstablishmentRepository: EstablishmentRepositoryProtocol {
    func fetchAll() -> [Establishment] {
        guard let url = Bundle.main.url(forResource: "establishments", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return Self.fallbackEstablishments
        }
        do {
            return try JSONDecoder().decode([Establishment].self, from: data)
        } catch {
            print("Failed to decode establishments.json: \(error)")
            return Self.fallbackEstablishments
        }
    }

    private static let fallbackEstablishments: [Establishment] = [
        Establishment(
            id: "1",
            name: "Café Verde",
            description: "Opções sem glúten e veganas",
            latitude: -23.561684,
            longitude: -46.625378,
            rating: 4.5,
            categories: ["cafe", "vegan"]
        ),
        Establishment(
            id: "2",
            name: "Padaria Segura",
            description: "Pães sem lactose e sem amendoim",
            latitude: -23.558704,
            longitude: -46.662325,
            rating: 4.2,
            categories: ["bakery"]
        ),
        Establishment(
            id: "3",
            name: "Restaurante do Centro",
            description: "Cardápio com selos Prato Seguro",
            latitude: -23.548943,
            longitude: -46.638818,
            rating: 4.7,
            categories: ["restaurant"]
        )
    ]
}
