import Foundation
import SwiftUI
import Combine
import SwiftData

enum AppTab: Hashable {
    case home
    case blueprint
    case connect
    case matches
    case profile
}

final class AppStore: ObservableObject {
    static let premiumCommerceEnabled = false

    @Published var onboardingComplete: Bool {
        didSet {
            UserDefaults.standard.set(onboardingComplete, forKey: Keys.onboardingComplete)
        }
    }

    @Published var currentUser: UserProfile?

    @Published var points: Int {
        didSet {
            UserDefaults.standard.set(points, forKey: Keys.points)
        }
    }

    @Published var streak: Int {
        didSet {
            UserDefaults.standard.set(streak, forKey: Keys.streak)
        }
    }

    @Published var premiumStatus: SubscriptionStatus {
        didSet {
            UserDefaults.standard.set(premiumStatus.rawValue, forKey: Keys.premiumStatus)
        }
    }

    @Published var premiumPreviewExpiresAt: Date? {
        didSet {
            UserDefaults.standard.set(premiumPreviewExpiresAt, forKey: Keys.premiumPreviewExpiresAt)
        }
    }

    @Published var lastRevealDate: Date? {
        didSet {
            UserDefaults.standard.set(lastRevealDate, forKey: Keys.lastRevealDate)
        }
    }

    @Published var lastRitualCompletionDate: Date? {
        didSet {
            UserDefaults.standard.set(lastRitualCompletionDate, forKey: Keys.lastRitualCompletionDate)
        }
    }

    @Published var unlockedRewards: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(unlockedRewards), forKey: Keys.unlockedRewards)
        }
    }

    @Published private(set) var connectResetToken = UUID()
    @Published private(set) var onboardingResetToken = UUID()
    @Published private(set) var dailyRevealResetToken = UUID()
    @Published var selectedTab: AppTab = .home
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: Keys.dailyReminderEnabled)
            refreshNotificationScheduling()
        }
    }
    @Published var streakSaverEnabled: Bool {
        didSet {
            UserDefaults.standard.set(streakSaverEnabled, forKey: Keys.streakSaverEnabled)
            refreshNotificationScheduling()
        }
    }
    @Published var preferredReminderTime: Date {
        didSet {
            UserDefaults.standard.set(preferredReminderTime, forKey: Keys.preferredReminderTime)
            refreshNotificationScheduling()
        }
    }
    @Published private(set) var notificationStatus: ZodianNotificationStatus = .notDetermined
    @Published var showNotificationPrePrompt = false
    @Published private(set) var hasSeenNotificationPrePrompt: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenNotificationPrePrompt, forKey: Keys.hasSeenNotificationPrePrompt)
        }
    }

    init() {
        self.onboardingComplete = UserDefaults.standard.bool(forKey: Keys.onboardingComplete)
        self.points = UserDefaults.standard.integer(forKey: Keys.points)
        self.streak = UserDefaults.standard.integer(forKey: Keys.streak)

        if let raw = UserDefaults.standard.string(forKey: Keys.premiumStatus),
           let status = SubscriptionStatus(rawValue: raw) {
            self.premiumStatus = status
        } else {
            self.premiumStatus = .free
        }

        self.premiumPreviewExpiresAt = UserDefaults.standard.object(forKey: Keys.premiumPreviewExpiresAt) as? Date

        self.lastRevealDate = UserDefaults.standard.object(forKey: Keys.lastRevealDate) as? Date
        self.lastRitualCompletionDate = UserDefaults.standard.object(forKey: Keys.lastRitualCompletionDate) as? Date

        let storedRewards = UserDefaults.standard.stringArray(forKey: Keys.unlockedRewards) ?? []
        self.unlockedRewards = Set(storedRewards)
        self.dailyReminderEnabled = UserDefaults.standard.object(forKey: Keys.dailyReminderEnabled) as? Bool ?? true
        self.streakSaverEnabled = UserDefaults.standard.object(forKey: Keys.streakSaverEnabled) as? Bool ?? true
        self.preferredReminderTime = UserDefaults.standard.object(forKey: Keys.preferredReminderTime) as? Date ?? Self.defaultReminderTime()
        self.hasSeenNotificationPrePrompt = UserDefaults.standard.bool(forKey: Keys.hasSeenNotificationPrePrompt)

        self.premiumStatus = PremiumAccessService.normalizedSubscriptionStatus(
            premiumStatus,
            commerceEnabled: Self.premiumCommerceEnabled
        )
        self.premiumPreviewExpiresAt = PremiumAccessService.sanitizedPreviewExpiry(premiumPreviewExpiresAt)

        normalizeLoadedStreakIfNeeded()

        Task { @MainActor in
            await refreshNotificationAuthorizationStatus()
            refreshNotificationScheduling()
        }
    }

    var todayRevealed: Bool {
        guard let lastRevealDate else { return false }
        return Calendar.current.isDateInToday(lastRevealDate)
    }

    var ritualCompletedToday: Bool {
        guard let lastRitualCompletionDate else { return false }
        return Calendar.current.isDateInToday(lastRitualCompletionDate)
    }

    var currentArchetype: Archetype? {
        guard let currentUser else { return nil }
        return ArchetypeService.shared.archetypeIfLoaded(forId: currentUser.archetypeId)
    }

    var hasPremiumTrialUnlocked: Bool {
        PremiumAccessService.hasPremiumTrialUnlocked(premiumAccessState)
    }

    var hasRewardPreviewUnlocked: Bool {
        unlockedRewards.contains(RewardKey.preview14Day)
    }

    var hasActivePremiumPreview: Bool {
        PremiumAccessService.hasActivePremiumPreview(premiumAccessState)
    }

    var effectivePremiumAccess: Bool {
        PremiumAccessService.effectivePremiumAccess(premiumAccessState)
    }

    var premiumPurchaseAvailable: Bool {
        Self.premiumCommerceEnabled
    }

    var premiumAccessBadgeTitle: String {
        PremiumAccessService.accessBadgeTitle(premiumAccessState)
    }

    var premiumPreviewStatusLine: String {
        PremiumAccessService.previewStatusLine(premiumAccessState)
    }

    var nextRewardTitle: String {
        RewardProgressService.nextRewardTitle(for: streak)
    }

    var nextRewardSubtitle: String {
        RewardProgressService.nextRewardSubtitle(for: streak)
    }

    var daysUntilNextReward: Int {
        RewardProgressService.daysUntilNextReward(for: streak)
    }

    var nextRewardProgress: Double {
        RewardProgressService.nextRewardProgress(for: streak)
    }

    func completeOnboarding() {
        selectedTab = .home
        onboardingComplete = true
        refreshNotificationScheduling()
    }

    func updatePremiumStatus(_ status: SubscriptionStatus) {
        premiumStatus = status
    }

    func activatePremiumPreview() {
        guard !effectivePremiumAccess else { return }
        premiumPreviewExpiresAt = Self.endOfDay(from: Date())
    }

    private var premiumAccessState: PremiumAccessState {
        PremiumAccessState(
            commerceEnabled: Self.premiumCommerceEnabled,
            subscriptionStatus: premiumStatus,
            unlockedRewards: unlockedRewards,
            previewExpiresAt: premiumPreviewExpiresAt
        )
    }

    func disablePremiumAccessForDebug() {
        premiumStatus = .free
        premiumPreviewExpiresAt = nil
        unlockedRewards.remove(RewardKey.preview14Day)
        unlockedRewards.remove(RewardKey.premiumTrial30Day)
    }

    func spendPoints(_ amount: Int) -> Bool {
        guard points >= amount else { return false }
        points -= amount
        return true
    }

    func redeemPremiumPreviewWithPoints(cost: Int = 50) -> Bool {
        guard !effectivePremiumAccess else { return false }
        guard spendPoints(cost) else { return false }

        premiumPreviewExpiresAt = Self.endOfDay(from: Date())
        return true
    }

    func awardDailyRevealPoints(context: ModelContext?, amount: Int = 10) {
        guard !todayRevealed else { return }

        let previousStreak = streak
        let previousProgressDate = latestStreakProgressDate
        points += amount
        lastRevealDate = Date()

        updateStreak(previousDate: previousProgressDate)
        applyRewardUnlocksIfNeeded(previousStreak: previousStreak, context: context)

        if let context {
            let entry = PointsLedgerItem(amount: amount, reason: .dailyReveal)
            context.insert(entry)

            insertOrReuseStreakDay(for: Date(), context: context)

            do {
                try context.save()
            } catch {
                print("❌ Failed saving points/streak: \(error)")
            }
        }

        refreshNotificationScheduling()
    }
    func resetTodayRevealForDebug(context: ModelContext) {
        lastRevealDate = nil
        lastRitualCompletionDate = nil
        dailyRevealResetToken = UUID()
        selectedTab = .home
        UserDefaults.standard.removeObject(forKey: "dailyRitualDraft.\(DailyReadingStore.dateKey())")

        do {
            try context.save()
        } catch {
            print("Failed to reset daily reveal: \(error)")
        }

        refreshNotificationScheduling()
    }
    func completeDailyRitual(context: ModelContext?, reward: Int = 5) {
        guard !ritualCompletedToday else { return }

        let previousStreak = streak
        let previousProgressDate = latestStreakProgressDate
        points += reward
        lastRitualCompletionDate = Date()
        updateStreak(previousDate: previousProgressDate)

        if let context {
            insertOrReuseStreakDay(for: Date(), context: context)
        }

        applyRewardUnlocksIfNeeded(previousStreak: previousStreak, context: context)

        if let context {
            do {
                try context.save()
            } catch {
                print("❌ Failed saving ritual completion: \(error)")
            }
        }

        presentNotificationPrePromptIfEligible()
        refreshNotificationScheduling()
    }

    @MainActor
    func refreshNotificationAuthorizationStatus() async {
        notificationStatus = await NotificationService.authorizationStatus()
    }

    func requestNotificationPermissionFromPrePrompt() {
        hasSeenNotificationPrePrompt = true
        showNotificationPrePrompt = false
        requestNotificationPermission()
    }

    func dismissNotificationPrePrompt() {
        hasSeenNotificationPrePrompt = true
        showNotificationPrePrompt = false
    }

    func ensureNotificationPermissionForSettings() {
        Task { @MainActor in
            await refreshNotificationAuthorizationStatus()

            if notificationStatus == .notDetermined {
                requestNotificationPermission()
            } else if notificationStatus == .denied {
                dailyReminderEnabled = false
                streakSaverEnabled = false
            } else {
                refreshNotificationScheduling()
            }
        }
    }

    func refreshNotificationScheduling() {
        let context = NotificationScheduleContext(
            dailyReminderEnabled: dailyReminderEnabled,
            streakSaverEnabled: streakSaverEnabled,
            preferredReminderTime: preferredReminderTime,
            streak: streak,
            ritualCompletedToday: ritualCompletedToday,
            skyTone: DailySkyContextProvider.context(for: Date()).tone
        )

        Task {
            await NotificationService.refreshSchedules(using: context)
        }
    }

    private var latestStreakProgressDate: Date? {
        [lastRevealDate, lastRitualCompletionDate]
            .compactMap { $0 }
            .max()
    }

    private func normalizeLoadedStreakIfNeeded() {
        guard streak == 0 else { return }
        guard latestStreakProgressDate != nil else { return }
        streak = 1
    }

    private func updateStreak(previousDate: Date?) {
        let calendar = Calendar.current
        let today = Date()

        guard let last = previousDate else {
            streak = 1
            return
        }

        if calendar.isDate(last, inSameDayAs: today) {
            if streak == 0 {
                streak = 1
            }
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            streak = max(streak, 1) + 1
        } else {
            streak = 1
        }
    }

    private func applyRewardUnlocksIfNeeded(previousStreak: Int, context: ModelContext?) {
        let result = RewardProgressService.milestoneResult(
            previousStreak: previousStreak,
            currentState: RewardProgressState(
                streak: streak,
                unlockedRewards: unlockedRewards
            )
        )

        guard !result.rewardsToUnlock.isEmpty || result.bonusPointsAwarded > 0 else { return }

        unlockedRewards.formUnion(result.rewardsToUnlock)
        points += result.bonusPointsAwarded

        if result.rewardsToUnlock.contains(RewardKey.preview14Day),
           !effectivePremiumAccess {
            premiumPreviewExpiresAt = Self.endOfDay(from: Date())
        }

        if result.shouldInsertStreakMilestoneLedgerEntry, let context {
            let bonusEntry = PointsLedgerItem(amount: result.bonusPointsAwarded, reason: .streakMilestone)
            context.insert(bonusEntry)
        }
    }

    private func insertOrReuseStreakDay(for date: Date, context: ModelContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            context.insert(StreakDay(date: date, didReveal: true))
            return
        }

        let descriptor = FetchDescriptor<StreakDay>(
            predicate: #Predicate { item in
                item.date >= startOfDay && item.date < endOfDay
            },
            sortBy: [SortDescriptor(\StreakDay.date, order: .forward)]
        )

        do {
            let streakDays: [StreakDay] = try context.fetch(descriptor)
            if let primaryStreakDay = streakDays.first {
                primaryStreakDay.didReveal = true

                for duplicate in streakDays.dropFirst() {
                    context.delete(duplicate)
                }
            } else {
                context.insert(StreakDay(date: date, didReveal: true))
            }
        } catch {
            print("❌ Failed to fetch streak day: \(error)")
            context.insert(StreakDay(date: date, didReveal: true))
        }
    }

    func loadUserIfNeeded(context: ModelContext) {
        guard currentUser == nil else { return }

        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\UserProfile.createdAt, order: .forward)]
        )
        do {
            let users = try context.fetch(descriptor)
            guard let primaryUser = users.first else { return }

            if users.count > 1 {
                for duplicate in users.dropFirst() {
                    context.delete(duplicate)
                }
                try context.save()
            }

            currentUser = primaryUser
            refreshNotificationScheduling()
        } catch {
            print("❌ Failed to fetch user: \(error)")
        }
    }

    func resetConnectHistory(context: ModelContext) {
        do {
            let chatMessages = try context.fetch(FetchDescriptor<ChatMessage>())
            for message in chatMessages {
                context.delete(message)
            }

            let matches = try context.fetch(FetchDescriptor<SavedMatch>())
            for match in matches {
                context.delete(match)
            }

            let passedProfiles = try context.fetch(FetchDescriptor<PassedProfile>())
            for profile in passedProfiles {
                context.delete(profile)
            }

            let swipeEvents = try context.fetch(FetchDescriptor<ConnectSwipeEvent>())
            for event in swipeEvents {
                context.delete(event)
            }

            let deckEntries = try context.fetch(FetchDescriptor<ConnectDeckEntry>())
            for entry in deckEntries {
                context.delete(entry)
            }

            try context.save()
            connectResetToken = UUID()
        } catch {
            print("❌ Failed to reset connect history: \(error)")
        }
    }

    func resetOnboardingExperience(context: ModelContext) {
        do {
            let connectProfiles = try context.fetch(FetchDescriptor<ConnectUserProfile>())
            for profile in connectProfiles {
                if let photoFileName = profile.photoFileName {
                    deleteConnectProfileImage(named: photoFileName)
                }
                context.delete(profile)
            }

            let chatMessages = try context.fetch(FetchDescriptor<ChatMessage>())
            for message in chatMessages {
                context.delete(message)
            }

            let matches = try context.fetch(FetchDescriptor<SavedMatch>())
            for match in matches {
                context.delete(match)
            }

            let passedProfiles = try context.fetch(FetchDescriptor<PassedProfile>())
            for profile in passedProfiles {
                context.delete(profile)
            }

            let swipeEvents = try context.fetch(FetchDescriptor<ConnectSwipeEvent>())
            for event in swipeEvents {
                context.delete(event)
            }

            let users = try context.fetch(FetchDescriptor<UserProfile>())
            for user in users {
                context.delete(user)
            }

            let savedReadings = try context.fetch(FetchDescriptor<SavedDailyReading>())
            for reading in savedReadings {
                context.delete(reading)
            }

            let ledgerItems = try context.fetch(FetchDescriptor<PointsLedgerItem>())
            for item in ledgerItems {
                context.delete(item)
            }

            let streakDays = try context.fetch(FetchDescriptor<StreakDay>())
            for day in streakDays {
                context.delete(day)
            }

            try context.save()
        } catch {
            print("❌ Failed to reset onboarding experience: \(error)")
        }

        currentUser = nil
        selectedTab = .home
        onboardingComplete = false
        points = 0
        streak = 0
        lastRevealDate = nil
        lastRitualCompletionDate = nil
        unlockedRewards = []
        premiumStatus = .free
        premiumPreviewExpiresAt = nil
        hasSeenNotificationPrePrompt = false
        connectResetToken = UUID()
        onboardingResetToken = UUID()
        showNotificationPrePrompt = false
        refreshNotificationScheduling()
    }

    private func deleteConnectProfileImage(named fileName: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func requestNotificationPermission() {
        Task { @MainActor in
            let granted = await NotificationService.requestAuthorization()
            await refreshNotificationAuthorizationStatus()

            if granted {
                dailyReminderEnabled = true
                streakSaverEnabled = true
                refreshNotificationScheduling()
            } else if notificationStatus == .denied {
                dailyReminderEnabled = false
                streakSaverEnabled = false
            }
        }
    }

    private func presentNotificationPrePromptIfEligible() {
        guard !hasSeenNotificationPrePrompt else { return }
        guard notificationStatus == .notDetermined else { return }
        guard streak >= 1 || lastRitualCompletionDate != nil else { return }
        showNotificationPrePrompt = true
    }

    private static func defaultReminderTime() -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private static func endOfDay(from date: Date) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        return startOfTomorrow.addingTimeInterval(-1)
    }
}

private enum Keys {
    static let onboardingComplete = "zodian.onboardingComplete"
    static let points = "zodian.points"
    static let streak = "zodian.streak"
    static let premiumStatus = "zodian.premiumStatus"
    static let premiumPreviewExpiresAt = "zodian.premiumPreviewExpiresAt"
    static let lastRevealDate = "zodian.lastRevealDate"
    static let lastRitualCompletionDate = "zodian.lastRitualCompletionDate"
    static let unlockedRewards = "zodian.unlockedRewards"
    static let dailyReminderEnabled = "zodian.dailyReminderEnabled"
    static let streakSaverEnabled = "zodian.streakSaverEnabled"
    static let preferredReminderTime = "zodian.preferredReminderTime"
    static let hasSeenNotificationPrePrompt = "zodian.hasSeenNotificationPrePrompt"
}

enum RewardKey {
    static let bonus7DayClaimed = "bonus_7_day_claimed"
    static let preview14Day = "preview_14_day"
    static let premiumTrial30Day = "premium_trial_30_day"
}
