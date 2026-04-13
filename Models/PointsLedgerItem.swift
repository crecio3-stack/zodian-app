import Foundation
import SwiftData

@Model
final class PointsLedgerItem {
    @Attribute(.unique) var id: UUID

    var date: Date
    var amount: Int
    var reasonRaw: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Int,
        reason: PointsReason
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.reasonRaw = reason.rawValue
    }
}

// MARK: - Reason Enum

enum PointsReason: String, Codable, CaseIterable {
    case dailyReveal
    case streakMilestone
    case share
    case inviteAccepted
    case adWatch
    case purchase

    var displayName: String {
        switch self {
        case .dailyReveal: return "Daily Reveal"
        case .streakMilestone: return "Streak Milestone"
        case .share: return "Shared Content"
        case .inviteAccepted: return "Invite Accepted"
        case .adWatch: return "Watched Ad"
        case .purchase: return "Purchase"
        }
    }
}

// MARK: - Helpers

extension PointsLedgerItem {
    var reason: PointsReason {
        PointsReason(rawValue: reasonRaw) ?? .dailyReveal
    }
}
