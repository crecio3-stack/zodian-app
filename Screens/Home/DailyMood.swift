import SwiftUI

enum DailyMood: String, CaseIterable, Codable {
    case clarity
    case magnetism
    case restraint
    case devotion
    case momentum
    case softness

    var title: String {
        switch self {
        case .clarity: return "Clarity"
        case .magnetism: return "Magnetism"
        case .restraint: return "Restraint"
        case .devotion: return "Devotion"
        case .momentum: return "Momentum"
        case .softness: return "Softness"
        }
    }

    var symbol: String {
        switch self {
        case .clarity: return "eye.fill"
        case .magnetism: return "sparkles"
        case .restraint: return "moon.fill"
        case .devotion: return "heart.fill"
        case .momentum: return "flame.fill"
        case .softness: return "cloud.fill"
        }
    }

    var tint: Color {
        switch self {
        case .clarity: return ZD.Color.accent
        case .magnetism: return ZD.Color.premium
        case .restraint: return ZD.Color.olive
        case .devotion: return ZD.Color.error.opacity(0.9)
        case .momentum: return ZD.Color.warning
        case .softness: return ZD.Color.textSecondary
        }
    }
}
