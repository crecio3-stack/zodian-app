import Foundation
import OSLog

protocol AnalyticsProvider {
    func track(name: String, properties: [String: String])
}

struct ConsoleAnalyticsProvider: AnalyticsProvider {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Zodian",
        category: "analytics"
    )

    func track(name: String, properties: [String: String]) {
        if properties.isEmpty {
            logger.log("event=\(name, privacy: .public)")
            return
        }

        let payload = properties
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ", ")

        logger.log("event=\(name, privacy: .public) properties=\(payload, privacy: .public)")
    }
}

enum AnalyticsEvent {
    case onboardingCompleted(identityID: String, westernSign: String, chineseSign: String, nameProvided: Bool)
    case identitySharePresented(identityID: String, title: String, source: String)
    case dailyRevealCompleted(identityID: String, streak: Int, points: Int)
    case dailyRitualCompleted(identityID: String, streak: Int, points: Int)
    case swipePerformed(action: String, archetypeID: String, score: Int, filter: String, isPremium: Bool)
    case matchSaved(archetypeID: String, score: Int, matchStyle: String, intent: String, source: String)
    case matchDeleted(matchID: String, archetypeID: String, hadChatHistory: Bool)
    case chatOpened(matchID: String, archetypeID: String, unreadCount: Int, messageCount: Int)
    case firstMessageSent(matchID: String, archetypeID: String)
    case paywallViewed(source: String, premiumActive: Bool)
    case premiumActivated(source: String)

    var name: String {
        switch self {
        case .onboardingCompleted: return "onboarding_completed"
        case .identitySharePresented: return "identity_share_presented"
        case .dailyRevealCompleted: return "daily_reveal_completed"
        case .dailyRitualCompleted: return "daily_ritual_completed"
        case .swipePerformed: return "swipe_performed"
        case .matchSaved: return "match_saved"
        case .matchDeleted: return "match_deleted"
        case .chatOpened: return "chat_opened"
        case .firstMessageSent: return "first_message_sent"
        case .paywallViewed: return "paywall_viewed"
        case .premiumActivated: return "premium_activated"
        }
    }

    var properties: [String: String] {
        switch self {
        case let .onboardingCompleted(identityID, westernSign, chineseSign, nameProvided):
            return [
                "identity_id": identityID,
                "western_sign": westernSign,
                "chinese_sign": chineseSign,
                "name_provided": String(nameProvided)
            ]

        case let .identitySharePresented(identityID, title, source):
            return [
                "identity_id": identityID,
                "identity_title": title,
                "source": source
            ]

        case let .dailyRevealCompleted(identityID, streak, points):
            return [
                "identity_id": identityID,
                "streak": String(streak),
                "points": String(points)
            ]

        case let .dailyRitualCompleted(identityID, streak, points):
            return [
                "identity_id": identityID,
                "streak": String(streak),
                "points": String(points)
            ]

        case let .swipePerformed(action, archetypeID, score, filter, isPremium):
            return [
                "action": action,
                "archetype_id": archetypeID,
                "compatibility_score": String(score),
                "filter": filter,
                "is_premium": String(isPremium)
            ]

        case let .matchSaved(archetypeID, score, matchStyle, intent, source):
            return [
                "archetype_id": archetypeID,
                "compatibility_score": String(score),
                "match_style": matchStyle,
                "intent": intent,
                "source": source
            ]

        case let .matchDeleted(matchID, archetypeID, hadChatHistory):
            return [
                "match_id": matchID,
                "archetype_id": archetypeID,
                "had_chat_history": String(hadChatHistory)
            ]

        case let .chatOpened(matchID, archetypeID, unreadCount, messageCount):
            return [
                "match_id": matchID,
                "archetype_id": archetypeID,
                "unread_count": String(unreadCount),
                "message_count": String(messageCount)
            ]

        case let .firstMessageSent(matchID, archetypeID):
            return [
                "match_id": matchID,
                "archetype_id": archetypeID
            ]

        case let .paywallViewed(source, premiumActive):
            return [
                "source": source,
                "premium_active": String(premiumActive)
            ]

        case let .premiumActivated(source):
            return [
                "source": source
            ]
        }
    }
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private let providers: [AnalyticsProvider]

    private init(providers: [AnalyticsProvider] = [ConsoleAnalyticsProvider()]) {
        self.providers = providers
    }

    func track(_ event: AnalyticsEvent) {
        providers.forEach { $0.track(name: event.name, properties: event.properties) }
    }
}
