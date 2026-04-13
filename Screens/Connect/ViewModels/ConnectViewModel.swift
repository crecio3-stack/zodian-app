import Foundation
import SwiftData
import Combine

@MainActor
final class ConnectViewModel: ObservableObject {
    @Published var selectedFilter: ConnectFilter = .compatible
    @Published var profiles: [DeckProfile] = []
    @Published var activeIndex: Int = 0
    @Published var showLimitBanner = false
    @Published var showUndoBanner = false
    @Published var celebrationMatch: DeckProfile?

    private let freeDailyLimit = 5

    func loadDeck(
        user: UserProfile?,
        savedMatches: [SavedMatch],
        passedProfiles: [PassedProfile],
        swipeEvents: [ConnectSwipeEvent]
    ) {
        guard let user else {
            profiles = []
            activeIndex = 0
            return
        }

        let excludedKeys = Set(
            savedMatches.map { "\($0.archetypeId)|\($0.name)" } +
            passedProfiles.map { "\($0.archetypeId)|\($0.name)" }
        )

        let generated = ConnectProfileGenerator.shared.generateProfiles(
            for: user,
            count: 30,
            excluding: excludedKeys
        )

        profiles = applyFilter(generated, filter: selectedFilter, user: user)
        activeIndex = swipeEvents.filter { Calendar.current.isDateInToday($0.createdAt) }.count
    }

    func reloadForFilter(
        user: UserProfile?,
        savedMatches: [SavedMatch],
        passedProfiles: [PassedProfile],
        swipeEvents: [ConnectSwipeEvent]
    ) {
        loadDeck(
            user: user,
            savedMatches: savedMatches,
            passedProfiles: passedProfiles,
            swipeEvents: swipeEvents
        )
    }

    func performLocalSwipe() {
        guard !profiles.isEmpty else { return }
        profiles.removeFirst()
    }

    func restoreProfile(_ profile: DeckProfile) {
        profiles.insert(profile, at: 0)
        showUndoBanner = true
    }

    func dismissUndoBannerSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.showUndoBanner = false
        }
    }

    func triggerLimitBanner() {
        showLimitBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.showLimitBanner = false
        }
    }

    func triggerUndoBanner() {
        showUndoBanner = true
    }

    func resetTransientState() {
        profiles = []
        activeIndex = 0
        showLimitBanner = false
        showUndoBanner = false
        celebrationMatch = nil
    }

    func showCelebration(for profile: DeckProfile) {
        celebrationMatch = profile
    }

    func dismissCelebration() {
        celebrationMatch = nil
    }

    func visibleProfiles(isPremium: Bool) -> [DeckProfile] {
        guard isPremium || !hasReachedFreeLimit(isPremium: isPremium) else { return [] }
        return Array(profiles.prefix(3))
    }

    func remainingCount(isPremium: Bool) -> Int {
        guard !isPremium else { return profiles.count }
        return max(freeDailyLimit - activeIndex, 0)
    }

    func deckStatusText(isPremium: Bool) -> String {
        if isPremium {
            return profiles.isEmpty ? "Premium deck clear" : "\(profiles.count) in your deck"
        }

        return "\(remainingCount(isPremium: false)) discoveries left"
    }

    func hasReachedFreeLimit(isPremium: Bool) -> Bool {
        !isPremium && activeIndex >= freeDailyLimit
    }

    private func applyFilter(
        _ profiles: [DeckProfile],
        filter: ConnectFilter,
        user: UserProfile
    ) -> [DeckProfile] {
        let result: [DeckProfile]

        switch filter {
        case .compatible:
            result = profiles.sorted { $0.compatibilityScore > $1.compatibilityScore }

        case .similar:
            result = profiles
                .filter {
                    $0.westernSign == user.westernSign || $0.chineseSign == user.chineseSign
                }
                .sorted { $0.compatibilityScore > $1.compatibilityScore }

        case .newEnergy:
            result = profiles
                .filter {
                    $0.westernSign != user.westernSign && $0.chineseSign != user.chineseSign
                }
                .sorted { $0.compatibilityScore > $1.compatibilityScore }
        }

        return result.isEmpty ? profiles : result
    }
}
