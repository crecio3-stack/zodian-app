import Foundation

/// The single presentation contract consumed by the Identity/Pattern screen.
/// It is deliberately derived from the canonical identity model; it is not a
/// second source of identity content.
struct IdentityPresentation: Equatable, Identifiable {
    let id: String
    let signCombination: String
    let archetype: String
    let coreSynthesis: String
    let tell: String
    let strength: String
    let shadow: String
    let howItShowsUp: String?
    let whatGetsInTheWay: String?
    let loveAndFriendship: String?
    let trustAndCloseness: String?
    let decisionMaking: String?
    let workAndPurpose: String?
    let underPressure: String?
    let restoration: String?
    let growth: String?
    let closingSynthesis: String?

    var shareableSummary: String {
        let parts = [
            "(signCombination) — (archetype)",
            coreSynthesis,
            "Strength: (strength)",
            "Shadow: (shadow)"
        ]
        return parts.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
    }

    static func make(from content: ZodiacIdentityContent) -> IdentityPresentation {
        let signCombination = [content.westernSign, content.chineseSign]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
            .joined(separator: " × ")

        let strength = content.strengths.first ?? "A clear instinct"
        let shadow = content.growthEdges.first ?? content.shadowPattern
        let tell = firstNonEmpty([content.coreEnergy, content.identitySummary])

        return IdentityPresentation(
            id: content.id,
            signCombination: signCombination,
            archetype: content.title,
            coreSynthesis: content.identitySummary,
            tell: tell,
            strength: strength,
            shadow: shadow,
            howItShowsUp: optional(content.earlyExpression),
            whatGetsInTheWay: optional(content.shadowLoop),
            loveAndFriendship: combined(content.loveStyle, content.friendshipStyle),
            trustAndCloseness: optional(content.communicationStyle),
            decisionMaking: optional(content.matureExpression),
            workAndPurpose: optional(content.workStyle),
            underPressure: optional(content.emotionalPattern),
            restoration: optional(content.ritualPrompt),
            growth: optional(firstNonEmpty(content.bestPractices + [content.matureExpression])),
            closingSynthesis: optional(content.mantra)
        )
    }

    private static func optional(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func firstNonEmpty(_ values: [String]) -> String {
        values.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? ""
    }

    private static func combined(_ first: String, _ second: String) -> String? {
        let values = [first, second].compactMap(optional)
        return values.isEmpty ? nil : values.joined(separator: " ")
    }
}
