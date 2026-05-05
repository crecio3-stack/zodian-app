import SwiftUI
import SwiftData

@main
struct ZodianApp: App {
    @StateObject private var store = AppStore()
    @State private var startupState: StartupState = .loading
    @State private var startupAttemptID = UUID()
    
    private let requiredOnboardingResetVersion = "phase-2-reset-2026-04-25"
    private let lastAppliedResetKey = "lastAppliedOnboardingResetVersion"

    var body: some Scene {
        WindowGroup {
            Group {
                switch startupState {
                case .loading:
                    launchLoadingView

                case .ready(let container):
                    ContentView()
                        .environmentObject(store)
                        .modelContainer(container)
                        .onAppear {
                            applyOneTimeOnboardingResetIfNeeded(container: container)
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
                bootstrapModelContainer()
            }
        }
    }

    private var launchLoadingView: some View {
        OnboardingSplashView()
    }

    @MainActor
    private func bootstrapModelContainer() {
        do {
            let container = try Self.makeModelContainer()
            startupState = .ready(container)
        } catch {
            let message = "Local data could not be loaded. \(error.localizedDescription)"
            print("❌ ModelContainer creation failed: \(error)")
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
        let defaults = UserDefaults.standard
        let lastApplied = defaults.string(forKey: lastAppliedResetKey)

        guard lastApplied != requiredOnboardingResetVersion else { return }

        let context = ModelContext(container)

        do {
            try context.delete(model: UserProfile.self)
            try context.delete(model: PointsLedgerItem.self)
            try context.delete(model: StreakDay.self)
            try context.delete(model: SavedDailyReading.self)
            try context.delete(model: SavedMatch.self)
            try context.delete(model: ChatMessage.self)
            try context.delete(model: ConnectUserProfile.self)
            try context.delete(model: ConnectDeckEntry.self)
            try context.delete(model: PassedProfile.self)
            try context.delete(model: ConnectSwipeEvent.self)

            try context.save()

            store.resetEphemeralStateForRecovery()
            defaults.set(requiredOnboardingResetVersion, forKey: lastAppliedResetKey)

            print("🔁 Applied onboarding reset for \(requiredOnboardingResetVersion)")
        } catch {
            print("❌ Failed to apply onboarding reset: \(error)")
        }
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            PointsLedgerItem.self,
            StreakDay.self,
            SavedDailyReading.self,
            SavedMatch.self,
            ChatMessage.self,
            ConnectUserProfile.self,
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
                    print("🧹 Removed local store file: \(fileName)")
                } catch {
                    print("⚠️ Failed to remove local store file \(fileName): \(error)")
                }
            }
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

private extension AppStore {
    func resetEphemeralStateForRecovery() {
        currentUser = nil
        onboardingComplete = false
        points = 0
        streak = 0
        premiumStatus = .free
        lastRevealDate = nil
        lastRitualCompletionDate = nil
        unlockedRewards = []
        dailyReminderEnabled = true
        streakSaverEnabled = true
        preferredReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        showNotificationPrePrompt = false
    }
}
