import Foundation
import OSLog
import PostHog

protocol AnalyticsProvider {
    func track(name: String, properties: [String: Any])
    func identify(accountID: AccountID)
}

struct ConsoleAnalyticsProvider: AnalyticsProvider {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Zodian",
        category: "analytics"
    )

    func track(name: String, properties: [String: Any]) {
        let schemaVersion = properties["event_schema_version"] as? Int ?? 0
        let taxonomyVersion = properties["event_taxonomy_version"] as? Int ?? 0
        let environment = properties["environment"] as? String ?? "unknown"
        let identityAuthority = properties["identity_authority"] as? String ?? "unknown"
        let message = [
            "event=\(name)",
            "schema=\(schemaVersion)",
            "taxonomy=\(taxonomyVersion)",
            "environment=\(environment)",
            "identity_authority=\(identityAuthority)"
        ].joined(separator: " ")

        logger.log("\(message, privacy: .public)")
    }

    func identify(accountID: AccountID) {
        _ = accountID
        logger.log("analytics_identity=account")
    }
}

struct PostHogAnalyticsProvider: AnalyticsProvider {
    func track(name: String, properties: [String: Any]) {
        PostHogSDK.shared.capture(name, properties: properties)
    }

    func identify(accountID: AccountID) {
        PostHogSDK.shared.identify(accountID.rawValue)
    }
}

enum AnalyticsEvent {
    case onboardingCompleted(identityID: String, westernSign: String, chineseSign: String, nameProvided: Bool)
    case identitySharePresented(identityID: String, title: String, source: String)
    case dailyRevealCompleted(identityID: String, streak: Int, points: Int)
    case dailyRitualCompleted(identityID: String, streak: Int, points: Int)
    case dailyReadCompleted(identityID: String, count: Int, streak: Int)
    case todaysLensRuntimeLoaded(
        editorialVoiceVersion: String,
        runtimeContractVersion: String,
        providerModel: String,
        contentEnvironment: String,
        generationResult: String,
        cacheResult: String,
        validationResult: String,
        retryState: String,
        wordCount: Int,
        thoughtGroupCount: Int
    )
    case dailyReadMilestone(count: Int, stage: String, identityID: String)
    case dailyReadCompletedMilestone(count: Int, identityID: String)
    case notificationOpened(identifier: String)
    case dailyReadOpenedFromNotification(identifier: String)
    case dailyLensFeedbackSubmitted(context: DailyLensFeedbackContext, response: DailyLensFeedbackResponse)
    case dailyLensFeedbackChanged(context: DailyLensFeedbackContext, response: DailyLensFeedbackResponse)
    case dailyLensFeedbackReasonSelected(context: DailyLensFeedbackContext, reason: DailyLensFeedbackReason)
    case homeCompletedStateSeen(dateKey: String, identityID: String)
    case returningDailyExperienceMessageShown
    case returningDailyExperienceMessageCTATapped
    case swipePerformed(action: String, archetypeID: String, score: Int, filter: String, isPremium: Bool)
    case matchSaved(archetypeID: String, score: Int, matchStyle: String, intent: String, source: String)
    case matchDeleted(matchID: String, archetypeID: String, hadChatHistory: Bool)
    case chatOpened(matchID: String, archetypeID: String, unreadCount: Int, messageCount: Int)
    case firstMessageSent(matchID: String, archetypeID: String)
    case paywallViewed(source: String, premiumActive: Bool)
    case premiumActivated(source: String)
    case premiumPreviewActivated(source: String)
    case readSomeoneOpened
    case readSomeoneStarted
    case savedPersonSaved(identityID: String)
    case savedPersonOpened(identityID: String)
    case savedPersonEdited(identityID: String)
    case savedPersonRemoved(identityID: String)
    case savedPersonIdentityViewed(identityID: String)
    case savedPersonLensViewed(identityID: String)
    case savedPersonShared(identityID: String)
    case compatibilityTeaserTapped(identityID: String, premiumActive: Bool)
    case compatibilityNotifyInterest(identityID: String)

    var schemaVersion: Int {
        1
    }

    var name: String {
        switch self {
        case .onboardingCompleted: return "onboarding_completed"
        case .identitySharePresented: return "identity_share_presented"
        case .dailyRevealCompleted: return "daily_reveal_completed"
        case .dailyRitualCompleted: return "daily_ritual_completed"
        case .dailyReadCompleted: return "daily_read_completed"
        case .todaysLensRuntimeLoaded: return "todays_lens_runtime_loaded"
        case let .dailyReadMilestone(count, _, _): return "daily_read_count_\(count)"
        case let .dailyReadCompletedMilestone(count, _): return "daily_read_completed_\(count)"
        case .notificationOpened: return "notification_opened"
        case .dailyReadOpenedFromNotification: return "daily_read_opened_from_notification"
        case .dailyLensFeedbackSubmitted: return "daily_lens_feedback_submitted"
        case .dailyLensFeedbackChanged: return "daily_lens_feedback_changed"
        case .dailyLensFeedbackReasonSelected: return "todays_lens_feedback_reason_selected"
        case .homeCompletedStateSeen: return "home_completed_state_seen"
        case .returningDailyExperienceMessageShown: return "returning_daily_experience_message_shown"
        case .returningDailyExperienceMessageCTATapped: return "returning_daily_experience_message_cta_tapped"
        case .swipePerformed: return "swipe_performed"
        case .matchSaved: return "match_saved"
        case .matchDeleted: return "match_deleted"
        case .chatOpened: return "chat_opened"
        case .firstMessageSent: return "first_message_sent"
        case .paywallViewed: return "paywall_viewed"
        case .premiumActivated: return "premium_activated"
        case .premiumPreviewActivated: return "premium_preview_activated"
        case .readSomeoneOpened: return "read_someone_opened"
        case .readSomeoneStarted: return "read_someone_started"
        case .savedPersonSaved: return "saved_person_saved"
        case .savedPersonOpened: return "saved_person_opened"
        case .savedPersonEdited: return "saved_person_edited"
        case .savedPersonRemoved: return "saved_person_removed"
        case .savedPersonIdentityViewed: return "saved_person_identity_viewed"
        case .savedPersonLensViewed: return "saved_person_lens_viewed"
        case .savedPersonShared: return "saved_person_shared"
        case .compatibilityTeaserTapped: return "compatibility_teaser_tapped"
        case .compatibilityNotifyInterest: return "compatibility_notify_interest"
        }
    }

    var properties: [String: String] {
        switch self {
        case let .onboardingCompleted(identityID, westernSign, chineseSign, nameProvided):
            _ = westernSign
            _ = chineseSign
            return [
                "identity_id": identityID,
                "name_provided": String(nameProvided)
            ]

        case let .identitySharePresented(identityID, title, source):
            return [
                "identity_id": identityID,
                "identity_title_present": String(!title.isEmpty),
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

        case let .dailyReadCompleted(identityID, count, streak):
            return [
                "identity_id": identityID,
                "daily_read_count": String(count),
                "streak": String(streak)
            ]

        case let .todaysLensRuntimeLoaded(
            editorialVoiceVersion,
            runtimeContractVersion,
            providerModel,
            contentEnvironment,
            generationResult,
            cacheResult,
            validationResult,
            retryState,
            wordCount,
            thoughtGroupCount
        ):
            return [
                "editorial_voice_version": editorialVoiceVersion,
                "runtime_contract_version": runtimeContractVersion,
                "provider_model": providerModel,
                "content_environment": contentEnvironment,
                "generation_result": generationResult,
                "cache_result": cacheResult,
                "validation_result": validationResult,
                "retry_state": retryState,
                "word_count": String(wordCount),
                "thought_group_count": String(thoughtGroupCount)
            ]

        case let .dailyReadMilestone(count, stage, identityID):
            return [
                "daily_read_count": String(count),
                "milestone": stage,
                "identity_id": identityID
            ]

        case let .dailyReadCompletedMilestone(count, identityID):
            return [
                "daily_read_count": String(count),
                "identity_id": identityID
            ]

        case .readSomeoneOpened, .readSomeoneStarted:
            return [:]

        case let .savedPersonSaved(identityID), let .savedPersonOpened(identityID),
            let .savedPersonEdited(identityID), let .savedPersonRemoved(identityID),
            let .savedPersonIdentityViewed(identityID), let .savedPersonLensViewed(identityID),
            let .savedPersonShared(identityID):
            return ["identity_id": identityID]

        case let .compatibilityTeaserTapped(identityID, premiumActive):
            return ["identity_id": identityID, "premium_active": String(premiumActive)]

        case let .compatibilityNotifyInterest(identityID):
            return ["identity_id": identityID]

        case let .notificationOpened(identifier):
            return ["notification_identifier": identifier]

        case let .dailyReadOpenedFromNotification(identifier):
            return ["notification_identifier": identifier]

        case let .dailyLensFeedbackSubmitted(context, response),
             let .dailyLensFeedbackChanged(context, response):
            return [
                "response": response.rawValue,
                "content_date": context.contentDate,
                "sign_pair": "\(context.westernSign) × \(context.chineseSign)",
                "theme": context.selectedTheme ?? "unknown",
                "batch_id": context.batchID,
                "lens_id": context.lensID,
            ]

        case let .dailyLensFeedbackReasonSelected(context, reason):
            return [
                "reason": reason.rawValue,
                "content_date": context.contentDate,
                "sign_pair": "\(context.westernSign) × \(context.chineseSign)",
                "theme": context.selectedTheme ?? "unknown",
            ]

        case let .homeCompletedStateSeen(dateKey, identityID):
            return [
                "date_key": dateKey,
                "identity_id": identityID
            ]

        case .returningDailyExperienceMessageShown,
             .returningDailyExperienceMessageCTATapped:
            return [:]

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

        case let .premiumPreviewActivated(source):
            return [
                "source": source
            ]
        }
    }
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private var providers: [AnalyticsProvider] = [ConsoleAnalyticsProvider()]
    private var isConfigured = false
    private(set) var accountID: AccountID?

    private init() {}

    func configure() {
        guard !isConfigured else { return }
        isConfigured = true

        guard let projectToken = AppConfiguration.postHogProjectToken else {
            FeatureFlagService.shared.configure(remoteProviderAvailable: false)
            OperationalLogger.info(
                "analytics_provider_disabled",
                category: .configuration,
                metadata: ["environment": AppConfiguration.environment.rawValue]
            )
            return
        }

        let config = PostHogConfig(
            projectToken: projectToken,
            host: AppConfiguration.postHogHost.absoluteString
        )
        config.captureApplicationLifecycleEvents = false
        config.captureScreenViews = false
        config.captureElementInteractions = false
        config.enableSwizzling = false
        config.sessionReplay = false
        config.personProfiles = .identifiedOnly
        config.sendFeatureFlagEvent = true
        config.preloadFeatureFlags = true
        config.flushAt = 20
        config.maxQueueSize = 1_000
#if DEBUG
        config.debug = true
#endif

        PostHogSDK.shared.setup(config)
        providers.append(PostHogAnalyticsProvider())
        FeatureFlagService.shared.configure(remoteProviderAvailable: true)

        OperationalLogger.info(
            "analytics_provider_initialized",
            category: .analytics,
            metadata: ["environment": AppConfiguration.environment.rawValue]
        )
    }

    func track(_ event: AnalyticsEvent) {
        let properties = eventEnvelope(for: event)
        providers.forEach { $0.track(name: event.name, properties: properties) }
    }

    private func eventEnvelope(for event: AnalyticsEvent) -> [String: Any] {
        var properties = AnalyticsPrivacyFilter.filtered(event.properties)
        properties["event_id"] = UUID().uuidString.lowercased()
        properties["event_schema_version"] = event.schemaVersion
        properties["event_taxonomy_version"] = 1
        properties["occurred_at"] = ISO8601DateFormatter().string(from: Date())
        properties["app_version"] = AppConfiguration.appVersion
        properties["build_number"] = AppConfiguration.buildNumber
        properties["environment"] = AppConfiguration.environment.rawValue
        properties["identity_authority"] = accountID == nil ? "anonymous" : "account"
        return properties
    }

    func identify(accountID: AccountID) {
        guard self.accountID != accountID else { return }
        self.accountID = accountID

        providers.forEach { $0.identify(accountID: accountID) }
        FeatureFlagService.shared.setAccountIdentity(accountID)
        CrashReportingService.shared.setAccountIdentity(accountID)

        OperationalLogger.info(
            "analytics_identity_promoted",
            category: .analytics,
            metadata: ["identity_authority": "account"]
        )
    }

#if DEBUG
    func validateEnvelope(for event: AnalyticsEvent) -> [String: Any] {
        eventEnvelope(for: event)
    }
#endif
}

enum AnalyticsPrivacyFilter {
    private static let prohibitedKeys: Set<String> = [
        "birth_date",
        "birth_time",
        "birth_place",
        "timezone",
        "email",
        "access_token",
        "auth_token",
        "provider_id",
        "installation_id",
        "device_registration_id",
        "daily_read_body",
        "pattern_copy",
        "reflection_text",
        "memory_evidence",
        "observation_text",
        "archive_content",
        "thread_content",
        "message_content",
        "profile_photo",
        "profile_text",
        "moderation_narrative"
    ]

    static func filtered(_ properties: [String: String]) -> [String: Any] {
        properties.reduce(into: [String: Any]()) { result, entry in
            let normalizedKey = entry.key.lowercased()
            guard !prohibitedKeys.contains(normalizedKey) else {
                OperationalLogger.warning(
                    "analytics_property_removed",
                    category: .analytics,
                    metadata: ["property": normalizedKey]
                )
                return
            }

            result[entry.key] = entry.value
        }
    }

#if DEBUG
    static func containsProhibitedKey(_ properties: [String: Any]) -> Bool {
        properties.keys.contains { prohibitedKeys.contains($0.lowercased()) }
    }
#endif
}
