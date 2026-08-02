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
            "\(signCombination) — \(archetype)",
            coreSynthesis,
            "Strength: \(strength)",
            "Shadow: \(shadow)"
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
            // ZodiacIdentityContent does not currently contain a decision-making
            // source field. Do not reuse matureExpression to fill this section.
            decisionMaking: nil,
            workAndPurpose: optional(content.workStyle),
            underPressure: optional(content.emotionalPattern),
            restoration: optional(content.ritualPrompt),
            growth: optional(firstNonEmpty(content.bestPractices)),
            closingSynthesis: optional(content.mantra)
        )
    }

    static func make(from editorial: IdentityEditorialRecord) -> IdentityPresentation {
        IdentityPresentation(
            id: editorial.id,
            signCombination: "\(editorial.westernSign) × \(editorial.chineseSign)",
            archetype: editorial.hero.archetypeTitle,
            coreSynthesis: editorial.hero.centralSynthesis,
            tell: editorial.hero.tell,
            strength: editorial.hero.strength,
            shadow: editorial.hero.shadow,
            howItShowsUp: editorialSectionText(editorial.sections.howItShowsUp),
            whatGetsInTheWay: editorialSectionText(editorial.sections.whatGetsInTheWay),
            loveAndFriendship: editorialSectionText(editorial.sections.loveAndFriendship),
            trustAndCloseness: editorialSectionText(editorial.sections.trustAndCloseness),
            decisionMaking: editorialSectionText(editorial.sections.decisionMaking),
            workAndPurpose: editorialSectionText(editorial.sections.workAndPurpose),
            underPressure: editorialSectionText(editorial.sections.underPressure),
            restoration: editorialSectionText(editorial.sections.restoration),
            growth: editorialSectionText(editorial.sections.growth),
            closingSynthesis: editorialSectionText(editorial.sections.closingSynthesis)
        )
    }

    static func editorialSectionText(_ section: IdentityEditorialRecord.Section) -> String {
        [sentence(section.lead), section.detail.trimmingCharacters(in: .whitespacesAndNewlines)]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
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
        guard !values.isEmpty else { return nil }
        return values
            .map { value in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let last = trimmed.last,
                      ".!?".contains(last) else {
                    return trimmed + "."
                }
                return trimmed
            }
            .joined(separator: " ")
    }

    private static func sentence(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.last, !".!?".contains(last) else { return trimmed }
        return trimmed + "."
    }
}
