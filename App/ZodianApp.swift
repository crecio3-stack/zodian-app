import SwiftUI
import SwiftData
import UserNotifications

@main
struct ZodianApp: App {
    @UIApplicationDelegateAdaptor(ZodianAppDelegate.self) private var appDelegate
    @StateObject private var store = AppStore()
    @StateObject private var accountOwnership = AccountOwnershipController()
    @State private var startupState: StartupState = .loading
    @State private var startupAttemptID = UUID()

    private let minimumStartupLoadingDuration: TimeInterval = 1.55

    var body: some Scene {
        WindowGroup {
            Group {
                switch startupState {
                case .loading:
                    launchLoadingView

                case .ready(let container):
                    ContentView()
                        .environmentObject(store)
                        .environmentObject(accountOwnership)
                        .modelContainer(container)
                        .onAppear {
                            applyOneTimeOnboardingResetIfNeeded(container: container)
                            applyOneTimeConnectIntroReplayIfNeeded()
                        }
                        .task {
#if DEBUG
                            if ProcessInfo.processInfo.arguments.contains("-zodianRunAccountValidationHarness") {
                                await Sprint1AccountValidationHarness.run()
                            }
#endif
                            await accountOwnership.bootstrapForApplicationLaunch()
#if DEBUG
                            if ProcessInfo.processInfo.arguments.contains("-zodianRunSprint2ValidationHarness") {
                                Sprint2ProductionReadinessValidationHarness.run(
                                    accountOwnership: accountOwnership
                                )
                            }
                            if ProcessInfo.processInfo.arguments.contains("-zodianRunCleanInstallRegression") {
                                await Sprint2ProductionReadinessValidationHarness.runCleanInstallRegression(
                                    accountOwnership: accountOwnership,
                                    store: store,
                                    context: ModelContext(container)
                                )
                            }
                            if ProcessInfo.processInfo.arguments.contains("-zodianRunSprint25EnvironmentValidation") {
                                Sprint25EnvironmentIsolationValidationHarness.run(
                                    accountOwnership: accountOwnership
                                )
                            }
                            if ProcessInfo.processInfo.arguments.contains("-zodianRunReadSomeoneValidation") {
                                ReadSomeoneValidationHarness.run()
                            }
#endif
                        }

                case .failed(let message):
                    ModelContainerRecoveryView(
                        errorMessage: message,
                        onRetry: retryStartup,
                        onReset: resetLocalDataAndRetry
                    )
                }
            }
            .task(id: startupAttemptID) {
                guard case .loading = startupState else { return }
                await bootstrapModelContainer()
            }
        }
    }

    private var launchLoadingView: some View {
        OnboardingSplashView()
    }

    @MainActor
    private func bootstrapModelContainer() async {
        let loadingStartedAt = Date()

        do {
            let container = try Self.makeModelContainer()

            let context = ModelContext(container)
            store.loadUserIfNeeded(context: context)

            if store.onboardingComplete, store.currentUser == nil {
                OperationalLogger.warning(
                    "startup_user_missing",
                    category: .persistence
                )
                store.resetEphemeralStateForRecovery()
            }

            let elapsed = Date().timeIntervalSince(loadingStartedAt)
            let remainingDelay = minimumStartupLoadingDuration - elapsed
            if remainingDelay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingDelay * 1_000_000_000))
            }

            startupState = .ready(container)
        } catch {
            let message = "Local data could not be loaded. \(error.localizedDescription)"
            OperationalLogger.error(
                OperationalError(
                    kind: .persistence,
                    category: .persistence,
                    code: "model_container_creation_failed",
                    underlyingError: error
                )
            )
            startupState = .failed(message)
        }
    }

    private func retryStartup() {
        startupState = .loading
        startupAttemptID = UUID()
    }

    private func resetLocalDataAndRetry() {
        Self.resetLocalPersistence()
        store.resetEphemeralStateForRecovery()
        retryStartup()
    }

    @MainActor
    private func applyOneTimeOnboardingResetIfNeeded(container: ModelContainer) {
#if DEBUG
        let defaults = UserDefaults.standard
        let lastAppliedResetKey = "lastAppliedOnboardingResetVersion"
        let requiredOnboardingResetVersion = "phase-2-reset-2026-04-25"
        let lastApplied = defaults.string(forKey: lastAppliedResetKey)

        guard lastApplied != requiredOnboardingResetVersion else { return }

        let context = ModelContext(container)

        do {
            try context.delete(model: UserProfile.self)
            try context.delete(model: PointsLedgerItem.self)
            try context.delete(model: StreakDay.self)
            try context.delete(model: SavedDailyReading.self)
            try context.delete(model: PatternIntelligenceScore.self)
            try context.delete(model: SavedMatch.self)
            try context.delete(model: ChatMessage.self)
            try context.delete(model: ConnectUserProfile.self)
            try context.delete(model: SavedPerson.self)
            try context.delete(model: ConnectDeckEntry.self)
            try context.delete(model: PassedProfile.self)
            try context.delete(model: ConnectSwipeEvent.self)

            try context.save()

            store.resetEphemeralStateForRecovery()
            defaults.set(requiredOnboardingResetVersion, forKey: lastAppliedResetKey)

            OperationalLogger.debug(
                "debug_onboarding_reset_applied",
                category: .persistence,
                metadata: ["version": requiredOnboardingResetVersion]
            )
        } catch {
            OperationalLogger.error(
                OperationalError(
                    kind: .persistence,
                    category: .persistence,
                    code: "debug_onboarding_reset_failed",
                    underlyingError: error
                )
            )
        }
#else
        _ = container
#endif
    }

    private func applyOneTimeConnectIntroReplayIfNeeded() {
        store.requestConnectIntroReplayIfNeeded(version: "connect-intro-replay-2026-06-07")
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            PointsLedgerItem.self,
            StreakDay.self,
            SavedDailyReading.self,
            PatternIntelligenceScore.self,
            SavedMatch.self,
            ChatMessage.self,
            ConnectUserProfile.self,
            SavedPerson.self,
            ConnectDeckEntry.self,
            PassedProfile.self,
            ConnectSwipeEvent.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    private static func resetLocalPersistence() {
        let defaults = UserDefaults.standard
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }

        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first

        let candidateFileNames = [
            "default.store",
            "default.store-wal",
            "default.store-shm",
            "Zodian.store",
            "Zodian.store-wal",
            "Zodian.store-shm"
        ]

        candidateFileNames.forEach { fileName in
            guard let url = appSupportURL?.appendingPathComponent(fileName) else { return }
            if fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                    OperationalLogger.debug(
                        "local_store_file_removed",
                        category: .persistence,
                        metadata: ["file": fileName]
                    )
                } catch {
                    OperationalLogger.error(
                        OperationalError(
                            kind: .persistence,
                            category: .persistence,
                            code: "local_store_file_removal_failed",
                            underlyingError: error
                        ),
                        metadata: ["file": fileName]
                    )
                }
            }
        }
    }
}

final class ZodianAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        CrashReportingService.shared.initialize()
        AnalyticsService.shared.configure()
        NetworkHealthMonitor.shared.start()
        UNUserNotificationCenter.current().delegate = self

        OperationalLogger.info(
            "application_initialized",
            category: .application,
            metadata: [
                "environment": AppConfiguration.environment.rawValue,
                "analytics_enabled": String(AppConfiguration.postHogProjectToken != nil),
                "crash_reporting_enabled": String(CrashReportingService.shared.isTransportEnabled)
            ]
        )
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let identifier = response.notification.request.identifier
        AnalyticsService.shared.track(.notificationOpened(identifier: identifier))

        guard response.notification.request.content.userInfo["zodian_destination"] as? String == "daily_read" else {
            return
        }

        await MainActor.run {
            NotificationService.recordDailyReadNotificationOpen(identifier: identifier)
        }
    }
}

private enum StartupState {
    case loading
    case ready(ModelContainer)
    case failed(String)
}

private struct ModelContainerRecoveryView: View {
    let errorMessage: String
    let onRetry: () -> Void
    let onReset: () -> Void

    var body: some View {
        ZD.Color.bg
            .ignoresSafeArea()
            .overlay {
                VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                    VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                        Text("Zodian Needs Recovery")
                            .font(ZD.Font.title())
                            .foregroundStyle(ZD.Color.accent)

                        Text("Your local data could not be opened, so the app could not finish launching")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(errorMessage)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                        PrimaryButton(
                            title: "Retry Launch",
                            action: onRetry,
                            icon: "arrow.clockwise",
                            fullWidth: true
                        )

#if DEBUG
                        SecondaryButton(
                            title: "Reset Local Data (Development)",
                            action: onReset,
                            fullWidth: true
                        )
#endif
                    }

                    Text("If retry does not work, reset local data in development or reinstall the app on a test device")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(ZD.Spacing.l)
                .zCardStyle()
                .padding(ZD.Spacing.l)
            }
            .preferredColorScheme(.dark)
    }
}

extension AppStore {
    func resetEphemeralStateForRecovery() {
        currentUser = nil
        onboardingComplete = false
        selectedTab = .home
        points = 0
        streak = 0
        premiumStatus = .free
        premiumPreviewExpiresAt = nil
        lastRevealDate = nil
        lastRitualCompletionDate = nil
        unlockedRewards = []
        dailyReminderEnabled = true
        streakSaverEnabled = true
        preferredReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        showNotificationPrePrompt = false
        hasSeenConnectIntro = false
        hasCompletedConnectCard = false
        hasUnlockedFullConnect = false
        shouldReplayConnectIntro = false
        resetAllStateTokens()
        clearOnboardingPersistentCaches()
    }
}
