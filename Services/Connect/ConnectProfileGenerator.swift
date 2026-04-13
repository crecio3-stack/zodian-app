import Foundation
import SwiftUI

struct ConnectProfileGenerator {
    static let shared = ConnectProfileGenerator()

    private init() {}

    private let names = [
        "Selene", "Orion", "Mira", "Rowan", "Luna", "Cassian",
        "Nova", "Sage", "Iris", "Kai", "Lyra", "Atlas",
        "Aria", "Jules", "Noah", "Skye", "Eden", "Ezra",
        "Cleo", "Zane", "Thea", "Nico", "Rhea", "Ari"
    ]

    private let intents = [
        "Dating",
        "Friendship",
        "Something intentional",
        "Slow-burn connection",
        "Open to chemistry",
        "Meaningful conversation",
        "Romantic alignment"
    ]

    private let imageNames = ["selene", "orion", "mira", "rowan", "luna", "cassian"]
    private let anchors: [UnitPoint] = [.center, .top, .topLeading, .topTrailing, .leading, .trailing]

    func generateProfiles(
        for user: UserProfile,
        count: Int = 24,
        excluding keysToAvoid: Set<String> = []
    ) -> [DeckProfile] {
        let userWestern = user.westernSign
        let userChinese = user.chineseSign

        let allWesterns = WesternZodiac.allCases
        let allChinese = ChineseZodiac.allCases

        var generated: [DeckProfile] = []
        var usedKeys = keysToAvoid
        var attempt = 0

        while generated.count < count && attempt < 800 {
            attempt += 1

            let western = allWesterns[westernIndex(seed: attempt, count: allWesterns.count)]
            let chinese = allChinese[chineseIndex(seed: attempt, count: allChinese.count)]

            // Avoid generating the user's exact same combo too often
            if western == userWestern && chinese == userChinese {
                continue
            }

            let archetype = ArchetypeService.shared.archetype(for: western, chinese: chinese)

            let name = names[(attempt * 7 + western.rawValue.count + chinese.rawValue.count) % names.count]
            let key = "\(archetype.id)|\(name)"

            guard !usedKeys.contains(key) else { continue }
            usedKeys.insert(key)

            let age = 24 + ((attempt * 3 + western.rawValue.count) % 11)
            let imageName = imageNames[attempt % imageNames.count]
            let anchor = anchors[attempt % anchors.count]

            let seedScore = seededPreviewScore(
                userWestern: userWestern,
                userChinese: userChinese,
                candidateWestern: western,
                candidateChinese: chinese
            )

            let style = previewStyle(for: seedScore)

            let profile = DeckProfile(
                name: name,
                age: age,
                archetypeId: archetype.id,
                archetypeTitle: archetype.title,
                combinedSigns: "\(western.displayName) × \(chinese.displayName)",
                westernSign: western,
                chineseSign: chinese,
                essence: makeEssence(archetype: archetype, style: style),
                connectionPrompt: makeConnectionPrompt(archetype: archetype, style: style),
                compatibilityScore: seedScore,
                matchStyle: style,
                matchReasons: previewReasons(for: style),
                frictionNote: previewFriction(for: style),
                imageName: imageName,
                imageAnchor: anchor,
                intent: intents[(attempt * 5 + chinese.rawValue.count) % intents.count]
            )

            generated.append(profile)
        }

        return generated.sorted { $0.compatibilityScore > $1.compatibilityScore }
    }

    // MARK: - Seeds

    private func westernIndex(seed: Int, count: Int) -> Int {
        (seed * 5 + 3) % count
    }

    private func chineseIndex(seed: Int, count: Int) -> Int {
        (seed * 7 + 1) % count
    }

    private func seededPreviewScore(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac
    ) -> Int {
        var score = 55

        if userWestern == candidateWestern {
            score += 14
        } else if isComplementary(userWestern, candidateWestern) {
            score += 10
        } else {
            score -= 6
        }

        if userChinese == candidateChinese {
            score += 10
        } else {
            let seed = abs("\(userChinese.rawValue)-\(candidateChinese.rawValue)".hashValue)
            let adjustments = [-6, -2, 0, 3, 6]
            score += adjustments[seed % adjustments.count]
        }

        return max(30, min(score, 92))
    }

    private func previewStyle(for score: Int) -> MatchStyle {
        switch score {
        case 82...100:
            return .harmonious
        case 72..<82:
            return .mirrored
        case 62..<72:
            return .growth
        case 52..<62:
            return .magnetic
        default:
            return .intense
        }
    }

    // MARK: - Copy

    private func makeEssence(archetype: Archetype, style: MatchStyle) -> String {
        let opening: String

        switch style {
        case .harmonious:
            opening = "Grounded, easy to trust, and naturally aligned."
        case .mirrored:
            opening = "Familiar, emotionally readable, and quietly resonant."
        case .magnetic:
            opening = "Chemically charged, expressive, and hard to ignore."
        case .growth:
            opening = "Different in the right ways, with real potential to expand you."
        case .intense:
            opening = "Compelling, layered, and likely to stir something deeper."
        }

        return "\(opening) \(archetype.tagline)"
    }

    private func makeConnectionPrompt(
        archetype: Archetype,
        style: MatchStyle
    ) -> String {
        let lead: String

        switch style {
        case .harmonious:
            lead = "This connection feels naturally easy."
        case .mirrored:
            lead = "This connection may feel familiar very quickly."
        case .magnetic:
            lead = "This connection has noticeable chemistry."
        case .growth:
            lead = "This connection could stretch you in the right direction."
        case .intense:
            lead = "This connection may be powerful, but not effortless."
        }

        return "\(lead) \(archetype.overview)"
    }

    private func previewReasons(for style: MatchStyle) -> [MatchReason] {
        switch style {
        case .harmonious:
            return [
                MatchReason(
                    title: "Easy Flow",
                    detail: "There is a natural ease in how your energy might meet."
                )
            ]
        case .mirrored:
            return [
                MatchReason(
                    title: "Shared Rhythm",
                    detail: "You may recognize parts of yourself in each other quickly."
                )
            ]
        case .magnetic:
            return [
                MatchReason(
                    title: "Strong Chemistry",
                    detail: "Differences here may create attraction and curiosity."
                )
            ]
        case .growth:
            return [
                MatchReason(
                    title: "Growth Potential",
                    detail: "This dynamic could challenge you in ways that feel worthwhile."
                )
            ]
        case .intense:
            return [
                MatchReason(
                    title: "High Voltage",
                    detail: "This may feel compelling, layered, and less predictable."
                )
            ]
        }
    }

    private func previewFriction(for style: MatchStyle) -> String {
        switch style {
        case .harmonious:
            return "Ease can still hide unspoken expectations."
        case .mirrored:
            return "Similarity may amplify the same blind spots."
        case .magnetic:
            return "Attraction may be strong, but pacing matters."
        case .growth:
            return "The fit may take time before it feels stable."
        case .intense:
            return "Strong reactions may come before mutual understanding."
        }
    }

    // MARK: - Helpers

    private func isComplementary(_ a: WesternZodiac, _ b: WesternZodiac) -> Bool {
        let pairs: [(WesternZodiac, WesternZodiac)] = [
            (.aries, .libra),
            (.taurus, .scorpio),
            (.gemini, .sagittarius),
            (.cancer, .capricorn),
            (.leo, .aquarius),
            (.virgo, .pisces)
        ]

        return pairs.contains { ($0.0 == a && $0.1 == b) || ($0.1 == a && $0.0 == b) }
    }
}
