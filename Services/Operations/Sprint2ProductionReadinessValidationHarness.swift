#if DEBUG
import Foundation
import SwiftData

@MainActor
enum Sprint2ProductionReadinessValidationHarness {
    private struct ValidationFailure: Error {
        let message: String
    }

    static func run(accountOwnership: AccountOwnershipController) {
        let checks: [(String, () throws -> Void)] = [
            ("development environment selected", {
                try require(AppConfiguration.environment == .development, "Debug did not resolve Development")
            }),
            ("crash service initialized", {
                try require(CrashReportingService.shared.isInitialized, "Crash service did not initialize")
            }),
            ("account analytics identity promoted", {
                try require(
                    AnalyticsService.shared.accountID == accountOwnership.accountID,
                    "Analytics did not adopt canonical Account ID"
                )
            }),
            ("analytics events are versioned and account-scoped", {
                let envelope = AnalyticsService.shared.validateEnvelope(
                    for: .returningDailyExperienceMessageShown
                )
                try require(envelope["event_id"] as? String != nil, "Event ID was missing")
                try require(envelope["event_schema_version"] as? Int == 1, "Schema version was missing")
                try require(envelope["environment"] as? String == "development", "Environment was missing")
                try require(envelope["identity_authority"] as? String == "account", "Account was not canonical")
            }),
            ("analytics privacy filter removes prohibited payloads", {
                let filtered = AnalyticsPrivacyFilter.filtered([
                    "identity_id": "allowed",
                    "birth_date": "1990-01-01",
                    "memory_evidence": "private",
                    "thread_content": "private",
                    "daily_read_body": "private",
                    "profile_text": "private"
                ])
                try require(filtered["identity_id"] as? String == "allowed", "Allowed metadata was removed")
                try require(
                    !AnalyticsPrivacyFilter.containsProhibitedKey(filtered),
                    "A prohibited analytics property survived filtering"
                )
            }),
            ("social flags default off", {
                let flags: [FeatureFlag] = [
                    .connectAvailability,
                    .realProfileDiscovery,
                    .profilePublication,
                    .connections,
                    .messaging,
                    .premiumCommerce,
                    .migration
                ]
                try require(
                    flags.allSatisfy { !FeatureFlagService.shared.isEnabled($0) },
                    "A sensitive capability did not fail closed"
                )
            }),
            ("retry policy is bounded", {
                let policy = NetworkRetryPolicy.standard
                try require(policy.maximumRetryCount == 3, "Unexpected retry count")
                try require(policy.delayNanoseconds(beforeRetry: 4) == nil, "Retry policy exceeded its bound")
            })
        ]

        var failures: [String] = []
        print("[Sprint2Validation] BEGIN")

        for (name, check) in checks {
            do {
                try check()
                print("[Sprint2Validation] PASS: \(name)")
            } catch {
                failures.append("\(name): \(error)")
                print("[Sprint2Validation] FAIL: \(name) — \(error)")
            }
        }

        if failures.isEmpty {
            print("[Sprint2Validation] RESULT: PASS (\(checks.count)/\(checks.count))")
        } else {
            print("[Sprint2Validation] RESULT: FAIL (\(checks.count - failures.count)/\(checks.count))")
            assertionFailure(failures.joined(separator: "\n"))
        }
    }

    static func runCleanInstallRegression(
        accountOwnership: AccountOwnershipController,
        store: AppStore,
        context: ModelContext
    ) async {
        print("[Sprint2CleanInstall] BEGIN")

        do {
            let profilesBefore = try context.fetchCount(FetchDescriptor<UserProfile>())
            try require(profilesBefore == 0, "Clean install already contained a profile")
            try require(accountOwnership.accountID != nil, "Anonymous Account was not acknowledged")

            let viewModel = OnboardingFlowViewModel()
            viewModel.name = "Sprint 2 QA"
            viewModel.birthday = Date(timeIntervalSince1970: 639_187_200)
            viewModel.computeSigns()
            viewModel.resolveIdentityContent()

            try require(viewModel.identityContent != nil, "Identity content did not resolve")

            let completed = await viewModel.completeOnboarding(
                accountOwnership: accountOwnership,
                store: store,
                context: context
            )
            try require(completed, "Onboarding did not complete")

            let profilesAfter = try context.fetch(FetchDescriptor<UserProfile>())
            try require(profilesAfter.count == 1, "Onboarding did not persist exactly one profile")
            try require(store.onboardingComplete, "Onboarding state was not completed")
            try require(store.currentUser != nil, "Current user was not loaded")

            guard
                let user = store.currentUser,
                ZodiacIdentityContentService.shared.content(
                    forWestern: user.westernSignRaw,
                    chinese: user.chineseSignRaw
                ) != nil
            else {
                throw ValidationFailure(message: "Pattern content did not resolve")
            }

            let dailyRead = await DailyRitualService.shared.fetchDailyRitual(
                westernSign: user.westernSignRaw,
                easternSign: user.chineseSignRaw
            )
            guard case .ready(let ritual) = dailyRead, ritual.isReadyForDisplay else {
                throw ValidationFailure(message: "Today’s Lens did not render from live or cached content")
            }

            print("[Sprint2CleanInstall] PASS: anonymous bootstrap acknowledged")
            print("[Sprint2CleanInstall] PASS: onboarding persisted after acknowledgment")
            print("[Sprint2CleanInstall] PASS: Pattern content resolved")
            print("[Sprint2CleanInstall] PASS: Today’s Lens resolved")
            print("[Sprint2CleanInstall] RESULT: PASS (4/4)")
        } catch {
            print("[Sprint2CleanInstall] RESULT: FAIL — \(error)")
            assertionFailure(String(describing: error))
        }
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        guard condition() else {
            throw ValidationFailure(message: message)
        }
    }
}
#endif
