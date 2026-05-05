import Foundation

struct PatternProfile: Equatable {
    let id: String
    let title: String
    let baseDrive: String
    let tension: String
    let expressionStyle: String

    static let fallback = PatternProfile(
        id: "hidden-pattern",
        title: "The Hidden Pattern",
        baseDrive: "You move when something feels real, not when it just looks good.",
        tension: "You can sit in your own read so long that nobody else gets a chance to meet it.",
        expressionStyle: "Quiet at first, sharp once you're sure."
    )

    init(
        id: String,
        title: String,
        baseDrive: String,
        tension: String,
        expressionStyle: String
    ) {
        self.id = id
        self.title = title
        self.baseDrive = PatternProfile.cleanedLine(baseDrive)
        self.tension = PatternProfile.cleanedLine(tension)
        self.expressionStyle = PatternProfile.cleanedLine(expressionStyle)
    }

    init(identityContent: ZodiacIdentityContent) {
        self.init(
            id: identityContent.id,
            title: identityContent.title,
            baseDrive: identityContent.coreEnergy,
            tension: identityContent.shadowLoop.isEmpty ? identityContent.shadowPattern : identityContent.shadowLoop,
            expressionStyle: identityContent.communicationStyle.isEmpty ? identityContent.matureExpression : identityContent.communicationStyle
        )
    }

    init(archetype: Archetype) {
        self.init(
            id: archetype.id,
            title: archetype.title,
            baseDrive: archetype.howYouMove ?? archetype.overview,
            tension: archetype.shadows.first ?? archetype.growthPath,
            expressionStyle: archetype.emotionalPattern
        )
    }

    private static func cleanedLine(_ text: String) -> String {
        let compact = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !compact.isEmpty else { return fallback.baseDrive }
        return compact
    }
}

enum PatternState: String, CaseIterable {
    case aligned
    case drifting
    case reactive

    var displayTitle: String {
        switch self {
        case .aligned:
            return "Aligned"
        case .drifting:
            return "Drifting"
        case .reactive:
            return "Reactive"
        }
    }
}

struct PatternOutput: Equatable {
    let state: PatternState
    let headline: String
    let insight: String
    let actionCTA: String
}

enum PatternEngine {
    static func output(for profile: PatternProfile, date: Date) -> PatternOutput {
        let state = state(for: profile, date: date)

        switch state {
        case .aligned:
            return PatternOutput(
                state: state,
                headline: alignedHeadline(for: profile),
                insight: "You know what matters and you're not wasting energy pretending otherwise. That makes you effective today, but you can still get blunt enough to miss what needs a softer touch.",
                actionCTA: "Lock In"
            )
        case .drifting:
            return PatternOutput(
                state: state,
                headline: driftingHeadline(for: profile),
                insight: "You're picking up everything and committing to nothing, which keeps you flexible but also scattered. If you keep orbiting your real point, the day will feel busy without actually moving.",
                actionCTA: "Cut Noise"
            )
        case .reactive:
            return PatternOutput(
                state: state,
                headline: reactiveHeadline(for: profile),
                insight: "You're quick today, and that edge helps when something genuinely needs a fast read. The cost is that your guard can fire before the moment is actually dangerous.",
                actionCTA: "Slow Down"
            )
        }
    }

    static func state(for profile: PatternProfile, date: Date) -> PatternState {
        let calendar = Calendar(identifier: .gregorian)
        let dayIndex = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let seed = stableSeed(for: "\(profile.id)-\(year)-\(dayIndex)")

        switch seed % 3 {
        case 0:
            return .aligned
        case 1:
            return .drifting
        default:
            return .reactive
        }
    }

    private static func stableSeed(for input: String) -> Int {
        input.unicodeScalars.reduce(0) { partial, scalar in
            ((partial * 31) + Int(scalar.value)) % 1_000_003
        }
    }

    private static func alignedHeadline(for profile: PatternProfile) -> String {
        focusHeadline(
            primary: readableDrivePhrase(from: profile.baseDrive),
            fallback: "You're moving with clear instinct today."
        )
    }

    private static func driftingHeadline(for profile: PatternProfile) -> String {
        focusHeadline(
            primary: readableDriftPhrase(from: profile.baseDrive, tension: profile.tension),
            fallback: "You're circling the point instead of choosing it."
        )
    }

    private static func reactiveHeadline(for profile: PatternProfile) -> String {
        focusHeadline(
            primary: readableReactivePhrase(from: profile.tension, expressionStyle: profile.expressionStyle),
            fallback: "Your guard is reacting before the moment asks for it."
        )
    }

    private static func focusHeadline(primary: String?, fallback: String) -> String {
        guard let primary, !primary.isEmpty else { return fallback }
        return primary.hasSuffix(".") ? primary : primary + "."
    }

    private static func readableDrivePhrase(from text: String) -> String? {
        let normalized = normalizedTraitText(text)
        guard !normalized.isEmpty else { return nil }

        if containsAny(normalized, ["acts fast", "trusts instinct", "moves first", "ignition", "impulse"]) {
            return "You're moving with clear instinct today"
        }

        if containsAny(normalized, ["reads the room", "reads social dynamics", "subtext", "notices shifts", "tone"]) {
            return "You're noticing the shift before anyone says it"
        }

        if containsAny(normalized, ["composed", "deliberate", "steady", "holds a clear line", "stands ground"]) {
            return "You're holding your line without forcing it"
        }

        if containsAny(normalized, ["presence", "dominance", "authority", "style", "bold impressions"]) {
            return "You're taking up space without chasing it"
        }

        if containsAny(normalized, ["soft", "gentle", "tender", "sensitive"]) {
            return "You're softer on the surface than the room expects"
        }

        if containsAny(normalized, ["freedom", "momentum", "movement", "space"]) {
            return "You're strongest when you stop fighting your own momentum"
        }

        if containsAny(normalized, ["precision", "clear", "organized", "structure"]) {
            return "You're sharper when you trust your own read"
        }

        if containsAny(normalized, ["direct", "honest", "truth"]) {
            return "You're moving with straight intent today"
        }

        return sentenceFromClause("You're moving with \(descriptorPhrase(from: normalized)) today")
    }

    private static func readableDriftPhrase(from drive: String, tension: String) -> String? {
        let driveText = normalizedTraitText(drive)
        let tensionText = normalizedTraitText(tension)

        if containsAny(tensionText, ["second-guess", "hesitant", "uncertain", "overthinking"]) {
            return "You're circling the point instead of choosing it"
        }

        if containsAny(tensionText, ["mixed signals", "too many angles", "holds options", "plays both sides"]) {
            return "You're keeping too many doors open at once"
        }

        if containsAny(tensionText, ["withdraws", "pulls back", "slips away", "goes quiet"]) {
            return "You're stepping back before the moment is actually over"
        }

        if containsAny(tensionText, ["distance", "isolation", "withholding", "harder to reach"]) {
            return "You're holding back when the day needs a clearer move"
        }

        if containsAny(tensionText, ["overpowers others", "pushes influence", "takes up more room than needed"]) {
            return "You're leaning too hard on presence instead of letting it land"
        }

        if containsAny(driveText, ["space", "movement", "freedom"]) {
            return "You're moving a lot without landing anywhere yet"
        }

        return sentenceFromClause("You're spending time around \(descriptorPhrase(from: tensionText.isEmpty ? driveText : tensionText))")
    }

    private static func readableReactivePhrase(from tension: String, expressionStyle: String) -> String? {
        let tensionText = normalizedTraitText(tension)
        let expressionText = normalizedTraitText(expressionStyle)

        if containsAny(tensionText, ["guard", "defensive", "protect", "watchful"]) {
            return "Your guard is reacting before the moment asks for it"
        }

        if containsAny(tensionText, ["depth becomes isolation", "isolation", "withdrawn", "withholding"]) {
            return "You're pulling inward before anyone can really reach you"
        }

        if containsAny(tensionText, ["holds too much inside", "keeps too much inside", "keeps cards close"]) {
            return "You're holding too much back for the day to stay clear"
        }

        if containsAny(tensionText, ["dominance", "pushes harder", "takes slights", "overbearing"]) {
            return "You're pushing harder than the moment actually needs"
        }

        if containsAny(tensionText, ["acts fast", "impulsive", "runs hot", "strikes fast"]) {
            return "You're quicker to react than to check the room"
        }

        if containsAny(expressionText, ["sharp", "precise", "controlled", "quiet once sure"]) {
            return "You're sharper when you slow the first response"
        }

        return sentenceFromClause("You're reacting from \(descriptorPhrase(from: tensionText.isEmpty ? expressionText : tensionText))")
    }

    private static func descriptorPhrase(from text: String) -> String {
        if text.isEmpty {
            return "instinct instead of clarity"
        }

        let cleaned = text
            .replacingOccurrences(of: "you ", with: "")
            .replacingOccurrences(of: "your ", with: "")
            .replacingOccurrences(of: "this identity ", with: "")
            .replacingOccurrences(of: "under stress, ", with: "")
            .replacingOccurrences(of: "under stress ", with: "")
            .replacingOccurrences(of: "together, ", with: "")
            .split(whereSeparator: { ".!?,".contains($0) })
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? text

        let lower = cleaned.lowercased()
        if lower.hasPrefix("acts ") || lower.hasPrefix("expresses ") || lower.hasPrefix("moves ") {
            return cleaned
                .split(separator: " ")
                .dropFirst()
                .joined(separator: " ")
        }

        return cleaned
    }

    private static func normalizedTraitText(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "—", with: " ")
            .replacingOccurrences(of: "–", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }

    private static func sentenceFromClause(_ text: String) -> String? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
    }
}
