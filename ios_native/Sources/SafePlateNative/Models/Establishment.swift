import Foundation
import CoreLocation

struct Establishment: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let categories: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
