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
    @Published var selectedTab: AppTab = .home

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

        self.lastRevealDate = UserDefaults.standard.object(forKey: Keys.lastRevealDate) as? Date
        self.lastRitualCompletionDate = UserDefaults.standard.object(forKey: Keys.lastRitualCompletionDate) as? Date

        let storedRewards = UserDefaults.standard.stringArray(forKey: Keys.unlockedRewards) ?? []
        self.unlockedRewards = Set(storedRewards)
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
        return ArchetypeService.shared.archetype(forId: currentUser.archetypeId)
    }

    var hasExtendedReadingDiscount: Bool {
        unlockedRewards.contains(RewardKey.discount3Day)
    }

    var hasHiddenInsightUnlocked: Bool {
        unlockedRewards.contains(RewardKey.hiddenInsight14Day)
    }

    var hasPremiumTrialUnlocked: Bool {
        unlockedRewards.contains(RewardKey.premiumTrial30Day)
    }

    var effectivePremiumAccess: Bool {
        premiumStatus.isPremium || hasPremiumTrialUnlocked
    }

    var extendedReadingCost: Int {
        hasExtendedReadingDiscount ? 10 : 15
    }
    
    var nextRewardTitle: String {
        if streak < 3 {
            return "3-Day Reward"
        } else if streak < 7 {
            return "7-Day Bonus"
        } else if streak < 14 {
            return "14-Day Hidden Insight"
        } else if streak < 30 {
            return "30-Day Premium Trial"
        } else {
            return "All milestone rewards unlocked"
        }
    }

    var nextRewardSubtitle: String {
        if streak < 3 {
            return "Unlock an extended reading discount."
        } else if streak < 7 {
            return "Earn a 25-point streak milestone bonus."
        } else if streak < 14 {
            return "Unlock your Hidden Insight section."
        } else if streak < 30 {
            return "Unlock premium access trial."
        } else {
            return "You’ve completed the current streak roadmap."
        }
    }

    var daysUntilNextReward: Int {
        if streak < 3 {
            return 3 - streak
        } else if streak < 7 {
            return 7 - streak
        } else if streak < 14 {
            return 14 - streak
        } else if streak < 30 {
            return 30 - streak
        } else {
            return 0
        }
    }

    var nextRewardProgress: Double {
        let target: Double
        let start: Double

        if streak < 3 {
            start = 0
            target = 3
        } else if streak < 7 {
            start = 3
            target = 7
        } else if streak < 14 {
            start = 7
            target = 14
        } else if streak < 30 {
            start = 14
            target = 30
        } else {
            return 1.0
        }

        let normalized = (Double(streak) - start) / (target - start)
        return min(max(normalized, 0), 1)
    }

    func completeOnboarding() {
        onboardingComplete = true
    }

    func updatePremiumStatus(_ status: SubscriptionStatus) {
        premiumStatus = status
    }

    func spendPoints(_ amount: Int) -> Bool {
        guard points >= amount else { return false }
        points -= amount
        return true
    }

    func awardDailyRevealPoints(context: ModelContext?, amount: Int = 10) {
        guard !todayRevealed else { return }

        let previousStreak = streak

        points += amount
        lastRevealDate = Date()

        updateStreak()
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
    }
    func resetTodayRevealForDebug(context: ModelContext) {
        lastRevealDate = nil
        lastRitualCompletionDate = nil

        do {
            try context.save()
        } catch {
            print("Failed to reset daily reveal: \(error)")
        }
    }
    func completeDailyRitual(context: ModelContext?, reward: Int = 5) {
        guard !ritualCompletedToday else { return }

        points += reward
        lastRitualCompletionDate = Date()

        if let context {
            do {
                try context.save()
            } catch {
                print("❌ Failed saving ritual completion: \(error)")
            }
        }
    }

    private func updateStreak() {
        let calendar = Calendar.current

        guard let last = lastRevealDate else {
            streak = 1
            return
        }

        if calendar.isDateInToday(last) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
           calendar.isDate(last, inSameDayAs: yesterday) {
            streak += 1
        } else {
            streak = 1
        }
    }

    private func applyRewardUnlocksIfNeeded(previousStreak: Int, context: ModelContext?) {
        guard streak != previousStreak else { return }

        if streak >= 3 {
            unlockedRewards.insert(RewardKey.discount3Day)
        }

        if streak >= 7, !unlockedRewards.contains(RewardKey.bonus7DayClaimed) {
            unlockedRewards.insert(RewardKey.bonus7DayClaimed)
            points += 25

            if let context {
                let bonusEntry = PointsLedgerItem(amount: 25, reason: .streakMilestone)
                context.insert(bonusEntry)
            }
        }

        if streak >= 14 {
            unlockedRewards.insert(RewardKey.hiddenInsight14Day)
        }

        if streak >= 30 {
            unlockedRewards.insert(RewardKey.premiumTrial30Day)
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
        onboardingComplete = false
        points = 0
        streak = 0
        lastRevealDate = nil
        lastRitualCompletionDate = nil
        unlockedRewards = []
        premiumStatus = .free
        connectResetToken = UUID()
        onboardingResetToken = UUID()
    }

    private func deleteConnectProfileImage(named fileName: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

private enum Keys {
    static let onboardingComplete = "zodian.onboardingComplete"
    static let points = "zodian.points"
    static let streak = "zodian.streak"
    static let premiumStatus = "zodian.premiumStatus"
    static let lastRevealDate = "zodian.lastRevealDate"
    static let lastRitualCompletionDate = "zodian.lastRitualCompletionDate"
    static let unlockedRewards = "zodian.unlockedRewards"
}

private enum RewardKey {
    static let discount3Day = "discount_3_day"
    static let bonus7DayClaimed = "bonus_7_day_claimed"
    static let hiddenInsight14Day = "hidden_insight_14_day"
    static let premiumTrial30Day = "premium_trial_30_day"
}
