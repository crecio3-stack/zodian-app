import Foundation
import SwiftData
import Combine
import SwiftUI

@MainActor
final class ConnectViewModel: ObservableObject {
    @Published var selectedFilter: ConnectFilter = .compatible {
        didSet {
            guard selectedFilter != oldValue else { return }
            applySelectedFilterToLoadedDeck()
        }
    }
    @Published var profiles: [DeckProfile] = []
    @Published var activeIndex: Int = 0

    private let dailyDeckSize = 20
    private var loadedDeckDateKey: String?
    private var loadedUserSignature: String?
    private var loadedSourceProfiles: [DeckProfile] = []
    private var loadedUserForFiltering: UserProfile?

    func loadDeck(
        user: UserProfile?,
        isPremium: Bool,
        context: ModelContext,
        forceRefresh: Bool = false
    ) {
        let resolvedUser = user ?? fetchPrimaryUser(context: context) ?? fallbackUserProfile()

        let todayKey = deckDateKey(for: Date())
        let userSignature = deckUserSignature(for: resolvedUser)

        if !forceRefresh,
           !profiles.isEmpty,
           loadedDeckDateKey == todayKey,
           loadedUserSignature == userSignature {
            return
        }

        let existingEntries = fetchDeckEntries(
            dateKey: todayKey,
            context: context
        )

        if existingEntries.isEmpty {
            buildAndPersistDeck(
                for: resolvedUser,
                dateKey: todayKey,
                context: context
            )
        }

        let refreshedEntries = fetchDeckEntries(
            dateKey: todayKey,
            context: context
        )

        var undismissed = refreshedEntries
            .filter { !$0.isDismissed }
            .map(makeDeckProfile(from:))

        if undismissed.isEmpty {
            deleteDeckEntries(dateKey: todayKey, context: context)
            buildAndPersistDeck(
                for: resolvedUser,
                dateKey: todayKey,
                context: context
            )

            let rebuiltEntries = fetchDeckEntries(
                dateKey: todayKey,
                context: context
            )

            undismissed = rebuiltEntries
                .filter { !$0.isDismissed }
                .map(makeDeckProfile(from:))
        }
        let sourceProfiles: [DeckProfile]
        if undismissed.isEmpty {
            let exclusions = historicalExclusionKeys(context: context)
            var generated = ConnectProfileGenerator.shared.generateProfiles(
                for: resolvedUser,
                count: dailyDeckSize,
                excluding: exclusions
            )

            if generated.isEmpty {
                generated = ConnectProfileGenerator.shared.generateProfiles(
                    for: resolvedUser,
                    count: dailyDeckSize,
                    excluding: []
                )
            }

            sourceProfiles = generated
        } else {
            sourceProfiles = undismissed
        }

        loadedSourceProfiles = uniqueProfilesByImageName(sourceProfiles)
        loadedUserForFiltering = resolvedUser

        profiles = applyFilter(
            loadedSourceProfiles,
            filter: selectedFilter,
            user: resolvedUser
        )
        loadedDeckDateKey = todayKey
        loadedUserSignature = userSignature

        activeIndex = consumedCountForToday(context: context, dateKey: todayKey)
    }

    func resetForConnectRestart(defaultFilter: ConnectFilter = .compatible) {
        loadedDeckDateKey = nil
        loadedUserSignature = nil
        loadedSourceProfiles = []
        loadedUserForFiltering = nil
        profiles = []
        activeIndex = 0
        selectedFilter = defaultFilter
    }

    func applySwipe(
        action: SwipeAction,
        profile: DeckProfile,
        context: ModelContext
    ) {
        let todayKey = deckDateKey(for: Date())

        guard let entry = fetchDeckEntry(
            dateKey: todayKey,
            archetypeId: profile.archetypeId,
            name: profile.name,
            context: context
        ) else {
            return
        }

        entry.isDismissed = true
        entry.wasLiked = action == .like
        entry.wasPassed = action == .pass

        do {
            try context.save()
        } catch {
            print("❌ Failed to update deck entry swipe state: \(error)")
        }

        profiles.removeAll {
            $0.archetypeId == profile.archetypeId && $0.name == profile.name
        }

        loadedSourceProfiles.removeAll {
            $0.archetypeId == profile.archetypeId && $0.name == profile.name
        }

        activeIndex = consumedCountForToday(context: context, dateKey: todayKey)
    }

    func restoreDeckEntry(
        for event: ConnectSwipeEvent,
        context: ModelContext
    ) {
        let todayKey = deckDateKey(for: Date())

        if let entry = fetchDeckEntry(
            dateKey: todayKey,
            archetypeId: event.archetypeId,
            name: event.name,
            context: context
        ) {
            entry.isDismissed = false
            entry.wasLiked = false
            entry.wasPassed = false
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to restore deck entry: \(error)")
        }

        activeIndex = consumedCountForToday(context: context, dateKey: todayKey)
    }

    func resetTransientState() {
        profiles = []
        loadedSourceProfiles = []
        loadedUserForFiltering = nil
        activeIndex = 0
        loadedDeckDateKey = nil
        loadedUserSignature = nil
    }

    func visibleProfiles(isPremium: Bool) -> [DeckProfile] {
        return Array(
            visiblySortedProfiles(
                profiles,
                filter: selectedFilter
            )
            .prefix(3)
        )
    }

    private func visiblySortedProfiles(
        _ profiles: [DeckProfile],
        filter: ConnectFilter
    ) -> [DeckProfile] {
        switch filter {
        case .compatible:
            return profiles.sorted { lhs, rhs in
                if lhs.compatibilityScore == rhs.compatibilityScore {
                    return lhs.name < rhs.name
                }
                return lhs.compatibilityScore > rhs.compatibilityScore
            }

        case .similar:
            return profiles.sorted { lhs, rhs in
                let lhsScore = visibleFamiliarityScore(lhs)
                let rhsScore = visibleFamiliarityScore(rhs)

                if lhsScore == rhsScore {
                    if lhs.compatibilityScore == rhs.compatibilityScore {
                        return lhs.name < rhs.name
                    }
                    return lhs.compatibilityScore > rhs.compatibilityScore
                }

                return lhsScore > rhsScore
            }

        case .newEnergy:
            return profiles.sorted { lhs, rhs in
                let lhsScore = visibleElectricScore(lhs)
                let rhsScore = visibleElectricScore(rhs)

                if lhsScore == rhsScore {
                    if lhs.compatibilityScore == rhs.compatibilityScore {
                        return lhs.name < rhs.name
                    }
                    return lhs.compatibilityScore < rhs.compatibilityScore
                }

                return lhsScore > rhsScore
            }
        }
    }

    private func visibleFamiliarityScore(_ profile: DeckProfile) -> Int {
        var score = profile.compatibilityScore
        let text = visibleScoringText(for: profile)

        if text.contains("steady") { score += 18 }
        if text.contains("calm") { score += 18 }
        if text.contains("soft") { score += 14 }
        if text.contains("slow") { score += 14 }
        if text.contains("real") { score += 12 }
        if text.contains("shared") { score += 12 }
        if text.contains("loyal") { score += 10 }
        if text.contains("ground") { score += 10 }
        if text.contains("gentle") { score += 8 }
        if text.contains("comfortable") { score += 8 }

        return score
    }

    private func visibleElectricScore(_ profile: DeckProfile) -> Int {
        var score = max(0, 100 - profile.compatibilityScore)
        let text = visibleScoringText(for: profile)

        if text.contains("electric") { score += 24 }
        if text.contains("chaos") { score += 24 }
        if text.contains("spark") { score += 20 }
        if text.contains("fast") { score += 18 }
        if text.contains("different") { score += 18 }
        if text.contains("bold") { score += 14 }
        if text.contains("wild") { score += 14 }
        if text.contains("new") { score += 12 }
        if text.contains("creative") { score += 10 }
        if text.contains("charge") { score += 10 }

        return score
    }

    private func visibleScoringText(for profile: DeckProfile) -> String {
        let signalText = profile.signals
            .map { String(describing: $0) }
            .joined(separator: " ")

        return "\(profile.name) \(profile.archetypeTitle) \(profile.essence) \(profile.connectionPrompt) \(profile.frictionNote) \(profile.intent) \(signalText)"
            .lowercased()
    }

    func remainingCount(isPremium: Bool) -> Int {
        profiles.count
    }

    func hasReachedFreeLimit(isPremium: Bool) -> Bool {
        false
    }
    private func fetchRealUsers(
        context: ModelContext,
        currentUser: UserProfile
    ) -> [DeckProfile] {

        let descriptor = FetchDescriptor<ConnectUserProfile>()

        guard let users = try? context.fetch(descriptor) else { return [] }

        return users
            .filter { $0.isVisible }
            .filter {
                $0.displayName.caseInsensitiveCompare(currentUser.name) != ComparisonResult.orderedSame
            }
            .map {
                ConnectProfileAdapter.makeDeckProfile(
                    from: $0,
                    currentUser: currentUser
                )
            }
    }
    private func applySelectedFilterToLoadedDeck() {
        guard let user = loadedUserForFiltering else { return }
        guard !loadedSourceProfiles.isEmpty else { return }

        profiles = applyFilter(
            uniqueProfilesByImageName(loadedSourceProfiles),
            filter: selectedFilter,
            user: user
        )
    }
    // MARK: - Deck Building

    private func buildAndPersistDeck(
        for user: UserProfile,
        dateKey: String,
        context: ModelContext
    ) {
        let historicalExclusions = historicalExclusionKeys(context: context)

        var generated = ConnectProfileGenerator.shared.generateProfiles(
            for: user,
            count: dailyDeckSize,
            excluding: historicalExclusions
        )

        if generated.isEmpty {
            generated = ConnectProfileGenerator.shared.generateProfiles(
                for: user,
                count: dailyDeckSize,
                excluding: []
            )
        }

        for (index, profile) in generated.enumerated() {
            let primaryReason = profile.matchReasons.first
            let secondaryReason = profile.matchReasons.dropFirst().first

            let entry = ConnectDeckEntry(
                deckDateKey: dateKey,
                position: index,
                name: profile.name,
                archetypeId: profile.archetypeId,
                archetypeTitle: profile.archetypeTitle,
                westernSignRaw: profile.westernSign.rawValue,
                chineseSignRaw: profile.chineseSign.rawValue,
                compatibilityScore: profile.compatibilityScore,
                matchStyleRaw: profile.matchStyle.rawValue,
                essence: profile.essence,
                connectionPrompt: profile.connectionPrompt,
                frictionNote: profile.frictionNote,
                intent: profile.intent,
                signalsRaw: signalsRaw(from: profile.signals),
                imageName: profile.imageName,
                imageAnchorRaw: imageAnchorRaw(for: profile.imageAnchor),
                primaryReasonTitle: primaryReason?.title ?? "Energetic Alignment",
                primaryReasonDetail: primaryReason?.detail ?? "There is something naturally compelling about this connection",
                secondaryReasonTitle: secondaryReason?.title ?? "",
                secondaryReasonDetail: secondaryReason?.detail ?? ""
            )

            context.insert(entry)
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to save generated deck entries: \(error)")
        }
    }

    // MARK: - Fetching

    private func fetchDeckEntries(
        dateKey: String,
        context: ModelContext
    ) -> [ConnectDeckEntry] {
        let descriptor = FetchDescriptor<ConnectDeckEntry>(
            predicate: #Predicate<ConnectDeckEntry> {
                $0.deckDateKey == dateKey
            },
            sortBy: [SortDescriptor(\ConnectDeckEntry.position, order: .forward)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch deck entries: \(error)")
            return []
        }
    }

    private func fetchPrimaryUser(context: ModelContext) -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\UserProfile.createdAt, order: .forward)]
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Failed to fetch primary user for Connect: \(error)")
            return nil
        }
    }

    private func fallbackUserProfile() -> UserProfile {
        let western: WesternZodiac = .libra
        let chinese: ChineseZodiac = .dog
        let archetype = ArchetypeService.shared.archetype(for: western, chinese: chinese)

        return UserProfile(
            name: "Friend",
            birthday: Date(timeIntervalSince1970: 622684800),
            westernSignRaw: western.rawValue,
            chineseSignRaw: chinese.rawValue,
            archetypeId: archetype.id
        )
    }

    private func fetchDeckEntry(
        dateKey: String,
        archetypeId: String,
        name: String,
        context: ModelContext
    ) -> ConnectDeckEntry? {
        let descriptor = FetchDescriptor<ConnectDeckEntry>(
            predicate: #Predicate<ConnectDeckEntry> {
                $0.deckDateKey == dateKey &&
                $0.archetypeId == archetypeId &&
                $0.name == name
            },
            sortBy: [SortDescriptor(\ConnectDeckEntry.position, order: .forward)]
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Failed to fetch deck entry: \(error)")
            return nil
        }
    }

    private func deleteDeckEntries(
        dateKey: String,
        context: ModelContext
    ) {
        let entries = fetchDeckEntries(dateKey: dateKey, context: context)
        guard !entries.isEmpty else { return }

        for entry in entries {
            context.delete(entry)
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to delete stale deck entries: \(error)")
        }
    }

    private func consumedCountForToday(
        context: ModelContext,
        dateKey: String
    ) -> Int {
        let descriptor = FetchDescriptor<ConnectDeckEntry>(
            predicate: #Predicate<ConnectDeckEntry> {
                $0.deckDateKey == dateKey && $0.isDismissed == true
            }
        )

        do {
            let entries = try context.fetch(descriptor)
            let uniqueKeys = Set(entries.map { "\($0.archetypeId)|\($0.name)" })
            return uniqueKeys.count
        } catch {
            print("❌ Failed to fetch consumed deck entries: \(error)")
            return 0
        }
    }

    private func historicalExclusionKeys(context: ModelContext) -> Set<String> {
        var keys = Set<String>()

        do {
            let savedMatches = try context.fetch(FetchDescriptor<SavedMatch>())
            savedMatches.forEach { keys.insert("\($0.archetypeId)|\($0.name)") }
        } catch {
            print("❌ Failed to fetch saved matches for exclusions: \(error)")
        }

        do {
            let passedProfiles = try context.fetch(FetchDescriptor<PassedProfile>())
            passedProfiles.forEach { keys.insert("\($0.archetypeId)|\($0.name)") }
        } catch {
            print("❌ Failed to fetch passed profiles for exclusions: \(error)")
        }

        return keys
    }

    // MARK: - Mapping

    private func makeDeckProfile(from entry: ConnectDeckEntry) -> DeckProfile {
        let westernSign = WesternZodiac.from(rawValue: entry.westernSignRaw) ?? .aries
        let chineseSign = ChineseZodiac.from(rawValue: entry.chineseSignRaw) ?? .rat

        let secondaryReasons: [MatchReason]
        if !entry.secondaryReasonTitle.isEmpty || !entry.secondaryReasonDetail.isEmpty {
            secondaryReasons = [
                MatchReason(
                    title: entry.secondaryReasonTitle,
                    detail: entry.secondaryReasonDetail
                )
            ]
        } else {
            secondaryReasons = []
        }

        return DeckProfile(
            name: entry.name,
            age: 27,
            archetypeId: entry.archetypeId,
            archetypeTitle: entry.archetypeTitle,
            combinedSigns: "\(westernSign.displayName) × \(chineseSign.displayName)",
            westernSign: westernSign,
            chineseSign: chineseSign,
            essence: entry.essence,
            connectionPrompt: entry.connectionPrompt,
            compatibilityScore: entry.compatibilityScore,
            matchStyle: MatchStyle(rawValue: entry.matchStyleRaw) ?? .harmonious,
            matchReasons: [
                MatchReason(
                    title: entry.primaryReasonTitle,
                    detail: entry.primaryReasonDetail
                )
            ] + secondaryReasons,
            frictionNote: entry.frictionNote,
            imageName: entry.imageName,
            imageAnchor: imageAnchor(from: entry.imageAnchorRaw),
            intent: entry.intent,
            signals: signals(from: entry.signalsRaw)
        )
    }

    private func signalsRaw(from signals: [ConnectProfileSignal]) -> String {
        ConnectProfileSignal.storageString(from: signals)
    }

    private func signals(from raw: String) -> [ConnectProfileSignal] {
        ConnectProfileSignal.parseRaw(raw)
    }

    private func imageAnchor(from raw: String) -> UnitPoint {
        switch raw {
        case "top": return .top
        case "bottom": return .bottom
        case "leading": return .leading
        case "trailing": return .trailing
        case "topLeading": return .topLeading
        case "topTrailing": return .topTrailing
        case "bottomLeading": return .bottomLeading
        case "bottomTrailing": return .bottomTrailing
        default: return .center
        }
    }

    private func imageAnchorRaw(for anchor: UnitPoint) -> String {
        switch anchor {
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .topLeading: return "topLeading"
        case .topTrailing: return "topTrailing"
        case .bottomLeading: return "bottomLeading"
        case .bottomTrailing: return "bottomTrailing"
        default: return "center"
        }
    }

    // MARK: - Filtering

    private func applyFilter(
        _ profiles: [DeckProfile],
        filter: ConnectFilter,
        user: UserProfile
    ) -> [DeckProfile] {
        let uniqueProfiles = uniqueProfilesByImageName(profiles)
        let sorted: [DeckProfile]

        switch filter {
        case .compatible:
            sorted = uniqueProfiles.sorted { $0.compatibilityScore > $1.compatibilityScore }

        case .similar:
            sorted = uniqueProfiles.sorted {
                similarityScore($0, user: user) > similarityScore($1, user: user)
            }

        case .newEnergy:
            sorted = uniqueProfiles.sorted {
                noveltyScore($0, user: user) > noveltyScore($1, user: user)
            }
        }

        return emotionallySequence(sorted)
    }
    private func emotionallySequence(_ profiles: [DeckProfile]) -> [DeckProfile] {
        guard profiles.count > 3 else { return profiles }

        let easy = profiles.filter {
            $0.matchStyle == .harmonious || $0.matchStyle == .mirrored
        }

        let curious = profiles.filter {
            $0.matchStyle == .growth || $0.matchStyle == .magnetic
        }

        let charged = profiles.filter {
            $0.matchStyle == .intense
        }

        var result: [DeckProfile] = []
        var easyQueue = easy
        var curiousQueue = curious
        var chargedQueue = charged
        var attempt = 0
        let hardLimit = profiles.count + 1

        while (!easyQueue.isEmpty || !curiousQueue.isEmpty || !chargedQueue.isEmpty) && attempt < hardLimit {
            attempt += 1

            if !easyQueue.isEmpty {
                result.append(easyQueue.removeFirst())
            }

            if !curiousQueue.isEmpty {
                result.append(curiousQueue.removeFirst())
            }

            if !chargedQueue.isEmpty {
                result.append(chargedQueue.removeFirst())
            }
        }

        let remaining = profiles.filter { profile in
            !result.contains(where: { $0.id == profile.id })
        }

        return result + remaining
    }

    private func similarityScore(_ profile: DeckProfile, user: UserProfile) -> Int {
        var score = profile.compatibilityScore

        if profile.westernSign == user.westernSign {
            score += 15
        }

        if profile.chineseSign == user.chineseSign {
            score += 10
        }

        return score
    }

    private func noveltyScore(_ profile: DeckProfile, user: UserProfile) -> Int {
        var score = profile.compatibilityScore

        if profile.westernSign != user.westernSign {
            score += 12
        }

        if profile.chineseSign != user.chineseSign {
            score += 8
        }

        return score
    }

    private func uniqueProfilesByImageName(_ profiles: [DeckProfile]) -> [DeckProfile] {
        var seen = Set<String>()
        var unique: [DeckProfile] = []

        for profile in profiles {
            guard seen.insert(profile.imageName).inserted else { continue }
            unique.append(profile)
        }

        return unique
    }

    // MARK: - Utilities

    private func deckDateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func deckUserSignature(for user: UserProfile) -> String {
        "\(user.westernSign.rawValue)|\(user.chineseSign.rawValue)|\(user.archetypeId)"
    }
}
