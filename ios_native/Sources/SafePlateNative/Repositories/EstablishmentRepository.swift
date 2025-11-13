import Foundation

protocol EstablishmentRepositoryProtocol {
    func fetchAll() -> [Establishment]
}

struct EstablishmentRepository: EstablishmentRepositoryProtocol {
    func fetchAll() -> [Establishment] {
        guard let url = Bundle.main.url(forResource: "establishments", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        do {
            return try JSONDecoder().decode([Establishment].self, from: data)
        } catch {
            return []
        }
    }
}
