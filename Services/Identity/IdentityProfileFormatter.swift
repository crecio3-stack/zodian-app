import Foundation

// Legacy formatter retained for migration reference. New identity surfaces must
// consume IdentityCardContent instead.
enum IdentityProfileFormatter {
    static func displaySignCombo(
        western: WesternZodiac,
        chinese: ChineseZodiac
    ) -> String {
        "\(western.displayName) × \(chinese.displayName)"
    }

    static func revealCardContent(
        from entry: IdentityProfileEntry,
        includeCombinedSummary: Bool = true
    ) -> IdentityRevealProfileContent {
        let supportingLine = includeCombinedSummary
            ? shortSupportingLine(from: entry.profile)
            : nil

        return IdentityRevealProfileContent(
            signCombo: displaySignCombo(western: entry.westernSign, chinese: entry.chineseSign),
            title: entry.profile.title,
            thesis: entry.profile.thesis,
            supportingLine: supportingLine
        )
    }

    static func patternContent(from entry: IdentityProfileEntry) -> IdentityPatternContent {
        IdentityPatternContent(
            signCombo: displaySignCombo(western: entry.westernSign, chinese: entry.chineseSign),
            title: entry.profile.title,
            thesis: entry.profile.thesis,
            summary: entry.profile.combinedSummary,
            sections: [
                IdentityPatternSection(
                    id: "thesis",
                    title: "Identity Thesis",
                    body: [entry.profile.thesis, entry.profile.combinedSummary]
                ),
                IdentityPatternSection(
                    id: "forces",
                    title: "The Two Forces",
                    body: [entry.profile.westernContribution, entry.profile.chineseContribution]
                ),
                IdentityPatternSection(
                    id: "strengths",
                    title: "Strengths",
                    body: entry.profile.strengths
                ),
                IdentityPatternSection(
                    id: "shadows",
                    title: "Shadows",
                    body: entry.profile.shadows
                ),
                IdentityPatternSection(
                    id: "relationships",
                    title: "Relationship Style",
                    body: [entry.profile.relationshipStyle]
                ),
                IdentityPatternSection(
                    id: "stress",
                    title: "Stress Pattern",
                    body: [entry.profile.stressPattern]
                ),
                IdentityPatternSection(
                    id: "growth",
                    title: "Growth Edge",
                    body: [entry.profile.growthEdge]
                )
            ]
        )
    }

    static func revealCardContentModel(from entry: IdentityProfileEntry) -> ZodiacIdentityContent {
        let revealContent = revealCardContent(from: entry, includeCombinedSummary: true)
        let supportingLine = revealContent.supportingLine ?? ""

        return ZodiacIdentityContent(
            id: entry.id,
            westernSign: entry.westernSign.rawValue,
            chineseSign: entry.chineseSign.rawValue,
            title: entry.profile.title,
            tagline: revealContent.thesis,
            identitySummary: supportingLine,
            coreEnergy: entry.profile.combinedSummary,
            strengths: entry.profile.strengths,
            growthEdges: entry.profile.shadows,
            loveStyle: entry.profile.relationshipStyle,
            friendshipStyle: entry.profile.relationshipStyle,
            workStyle: entry.profile.westernContribution,
            communicationStyle: entry.profile.chineseContribution,
            emotionalPattern: entry.profile.stressPattern,
            shadowPattern: entry.profile.shadows.first ?? entry.profile.stressPattern,
            bestPractices: [entry.profile.growthEdge],
            earlyExpression: entry.profile.westernContribution,
            matureExpression: entry.profile.combinedSummary,
            shadowLoop: entry.profile.stressPattern,
            ritualPrompt: entry.profile.growthEdge,
            mantra: entry.profile.growthEdge
        )
    }

    private static func shortSupportingLine(from profile: LegacyIdentityProfile) -> String? {
        let candidate = firstSentence(from: profile.combinedSummary)
        let cleanedCandidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedThesis = profile.thesis.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedCandidate.isEmpty else { return nil }
        guard normalized(cleanedCandidate) != normalized(cleanedThesis) else { return nil }

        return cleanedCandidate
    }

    private static func firstSentence(from text: String) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return "" }

        let parts = cleaned.split(whereSeparator: { ".!?".contains($0) })
        guard let first = parts.first else { return cleaned }

        let sentence = String(first).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sentence.isEmpty else { return "" }
        return sentence.hasSuffix(".") ? sentence : sentence + "."
    }

    private static func normalized(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
