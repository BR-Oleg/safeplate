import Foundation

struct Coupon: Identifiable {
    enum Status {
        case active
        case used
        case expired
    }

    let id: String
    let title: String
    let description: String
    let pointsCost: Int
    let discount: Double
    let isActive: Bool
    let isUsed: Bool
    let expiresAt: Date
    let usedAt: Date?

    var status: Status {
        if isUsed { return .used }
        if Date() > expiresAt { return .expired }
        return isActive ? .active : .expired
    }
}

struct AvailableCoupon: Identifiable {
    let id: String
    let title: String
    let description: String
    let discount: Double
    let pointsCost: Int
    let validityDays: Int
    let establishmentId: String?
    let establishmentName: String?
}
