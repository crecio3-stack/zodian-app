import Foundation

struct PremiumAccessState {
    let commerceEnabled: Bool
    let subscriptionStatus: SubscriptionStatus
    let unlockedRewards: Set<String>
    let previewExpiresAt: Date?
}

enum PremiumAccessService {
    static func normalizedSubscriptionStatus(
        _ status: SubscriptionStatus,
        commerceEnabled: Bool
    ) -> SubscriptionStatus {
        guard commerceEnabled || !status.isPremium else {
            return .free
        }

        return status
    }

    static func sanitizedPreviewExpiry(_ expiry: Date?, now: Date = Date()) -> Date? {
        guard let expiry else { return nil }
        return expiry > now ? expiry : nil
    }

    static func hasPremiumTrialUnlocked(_ state: PremiumAccessState) -> Bool {
        state.unlockedRewards.contains(RewardKey.premiumTrial30Day)
    }

    static func hasActivePremiumPreview(_ state: PremiumAccessState, now: Date = Date()) -> Bool {
        guard let previewExpiresAt = state.previewExpiresAt else { return false }
        return previewExpiresAt > now
    }

    static func effectivePremiumAccess(_ state: PremiumAccessState, now: Date = Date()) -> Bool {
        let paidAccess = state.commerceEnabled && state.subscriptionStatus.isPremium
        return paidAccess
            || hasPremiumTrialUnlocked(state)
            || hasActivePremiumPreview(state, now: now)
    }

    static func accessBadgeTitle(_ state: PremiumAccessState, now: Date = Date()) -> String {
        if hasPremiumTrialUnlocked(state) {
            return "Premium"
        }

        if hasActivePremiumPreview(state, now: now) {
            return "Preview"
        }

        return "Free"
    }

    static func previewStatusLine(_ state: PremiumAccessState, now: Date = Date()) -> String {
        guard hasActivePremiumPreview(state, now: now),
              let previewExpiresAt = state.previewExpiresAt else {
            return "Ends tonight."
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "Preview active until \(formatter.string(from: previewExpiresAt))."
    }
}
