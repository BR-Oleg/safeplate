import Foundation

struct AppUser {
    let id: String
    let email: String
    let name: String?
    let points: Int
    let isPremium: Bool
    let premiumExpiresAt: Date?
    let preferredLanguageCode: String?
    let userType: String?
    let photoUrl: String?

    var isPremiumActive: Bool {
        if !isPremium { return false }
        guard let expires = premiumExpiresAt else { return true }
        return Date() < expires
    }
}
