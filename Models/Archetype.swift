import Foundation

struct IdentityCardContent: Equatable, Identifiable {
    let id: String
    let signCombination: String
    let identityName: String
    let descriptor: String
    let patternSummary: String

    static let placeholder = IdentityCardContent(
        id: "unknown-unknown",
        signCombination: "Western × Eastern",
        identityName: "The Hidden Pattern",
        descriptor: "Still coming into focus",
        patternSummary: "Two systems meet here. The pattern is still taking shape."
    )
}

struct Archetype: Codable, Identifiable, Equatable {
    let id: String

    let combinedName: String
    let title: String

    let overview: String

    let howYouMove: String?

    let strengths: [String]
    let shadows: [String]
    let strengthProfile: [String]?
    let shadowProfile: [String]?
    let dominantStrengthTrait: String?
    let dominantShadowTrait: String?

    let emotionalPattern: String
    let loveStyle: String
    let friendshipStyle: String
    let workStyle: String
    let growthPath: String

    let compatibilityNotes: String

    let tagline: String
    let hiddenInsight: String?

    var shareTitle: String {
        "\(combinedName) — \(title)"
    }

    var shortDescription: String {
        tagline
    }

    var identityCardContent: IdentityCardContent {
        IdentityCardContent(
            id: id,
            signCombination: combinedName,
            identityName: title,
            descriptor: tagline,
            patternSummary: overview
        )
    }

    var formattedOverview: String {
        IdentityDescriptionFormatter.identitySummary(
            summary: overview,
            coreEnergy: tagline,
            emotionalPattern: emotionalPattern,
            shadowPattern: growthPath
        )
    }

    static func fallback(western: WesternZodiac, chinese: ChineseZodiac) -> Archetype {
        Archetype(
            id: "\(western.rawValue)-\(chinese.rawValue)",
            combinedName: "\(western.displayName) × \(chinese.displayName)",
            title: "The Hidden Pattern",
            overview: "Two systems meet here. The pattern is still taking shape",
            howYouMove: nil,
            strengths: [
                "Adapts fast",
                "Reads subtext",
                "Strong instincts"
            ],
            shadows: [
                "Second-guessing",
                "Mixed signals",
                "Overthinking"
            ],
            strengthProfile: nil,
            shadowProfile: nil,
            dominantStrengthTrait: nil,
            dominantShadowTrait: nil,
            emotionalPattern: "You read between the lines. You feel more than you show",
            loveStyle: "You want something real. Space matters too",
            friendshipStyle: "You watch first. Then you open",
            workStyle: "You do your best work with room to move",
            growthPath: "Clarity comes when you trust your own read",
            compatibilityNotes: "You do well with people who bring steadiness and clarity",
            tagline: "Still coming into focus",
            hiddenInsight: "Your deeper lesson may be this: stay soft without losing your edge"
        )
    }
}
