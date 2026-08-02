import Foundation

enum SubscriptionStatus: String, Codable, CaseIterable {
    case free
    case premium
    case lifetime

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .lifetime: return "Lifetime"
        }
    }

    var isPremium: Bool {
        switch self {
        case .free:
            return false
        case .premium, .lifetime:
            return true
        }
    }
}
