import Foundation

struct ZodiacIdentityContent: Codable, Identifiable {
    let id: String
    let westernSign: String
    let chineseSign: String
    let title: String
    let tagline: String
    let identitySummary: String
    let coreEnergy: String
    let strengths: [String]
    let growthEdges: [String]
    let loveStyle: String
    let friendshipStyle: String
    let workStyle: String
    let communicationStyle: String
    let emotionalPattern: String
    let shadowPattern: String
    let bestPractices: [String]
    let earlyExpression: String
    let matureExpression: String
    let shadowLoop: String
    let ritualPrompt: String
    let mantra: String

    private enum CodingKeys: String, CodingKey {
        case id
        case westernSign
        case chineseSign
        case title
        case tagline
        case identitySummary
        case identityNarrative
        case coreEnergy
        case strengths
        case growthEdges
        case loveStyle
        case friendshipStyle
        case workStyle
        case communicationStyle
        case emotionalPattern
        case shadowPattern
        case bestPractices
        case earlyExpression
        case matureExpression
        case shadowLoop
        case ritualPrompt
        case mantra
    }

    init(
        id: String,
        westernSign: String,
        chineseSign: String,
        title: String,
        tagline: String,
        identitySummary: String,
        coreEnergy: String,
        strengths: [String],
        growthEdges: [String],
        loveStyle: String,
        friendshipStyle: String,
        workStyle: String,
        communicationStyle: String,
        emotionalPattern: String,
        shadowPattern: String,
        bestPractices: [String],
        earlyExpression: String,
        matureExpression: String,
        shadowLoop: String,
        ritualPrompt: String,
        mantra: String
    ) {
        self.id = id
        self.westernSign = westernSign
        self.chineseSign = chineseSign
        self.title = title
        self.tagline = tagline
        self.identitySummary = identitySummary
        self.coreEnergy = coreEnergy
        self.strengths = strengths
        self.growthEdges = growthEdges
        self.loveStyle = loveStyle
        self.friendshipStyle = friendshipStyle
        self.workStyle = workStyle
        self.communicationStyle = communicationStyle
        self.emotionalPattern = emotionalPattern
        self.shadowPattern = shadowPattern
        self.bestPractices = bestPractices
        self.earlyExpression = earlyExpression
        self.matureExpression = matureExpression
        self.shadowLoop = shadowLoop
        self.ritualPrompt = ritualPrompt
        self.mantra = mantra
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let derivedSigns = Self.derivedSigns(from: id)
        let westernSign = try container.decodeIfPresent(String.self, forKey: .westernSign)
            ?? derivedSigns.western
        let chineseSign = try container.decodeIfPresent(String.self, forKey: .chineseSign)
            ?? derivedSigns.chinese
        let identitySummary = try container.decodeIfPresent(String.self, forKey: .identitySummary)
            ?? container.decodeIfPresent(String.self, forKey: .identityNarrative)
            ?? ""

        self = ZodiacIdentityContent(
            id: id,
            westernSign: westernSign,
            chineseSign: chineseSign,
            title: try container.decode(String.self, forKey: .title),
            tagline: try container.decode(String.self, forKey: .tagline),
            identitySummary: identitySummary,
            coreEnergy: try container.decodeIfPresent(String.self, forKey: .coreEnergy) ?? "",
            strengths: try container.decodeIfPresent([String].self, forKey: .strengths) ?? [],
            growthEdges: try container.decodeIfPresent([String].self, forKey: .growthEdges) ?? [],
            loveStyle: try container.decodeIfPresent(String.self, forKey: .loveStyle) ?? "",
            friendshipStyle: try container.decodeIfPresent(String.self, forKey: .friendshipStyle) ?? "",
            workStyle: try container.decodeIfPresent(String.self, forKey: .workStyle) ?? "",
            communicationStyle: try container.decodeIfPresent(String.self, forKey: .communicationStyle) ?? "",
            emotionalPattern: try container.decodeIfPresent(String.self, forKey: .emotionalPattern) ?? "",
            shadowPattern: try container.decodeIfPresent(String.self, forKey: .shadowPattern) ?? "",
            bestPractices: try container.decodeIfPresent([String].self, forKey: .bestPractices) ?? [],
            earlyExpression: try container.decodeIfPresent(String.self, forKey: .earlyExpression) ?? "",
            matureExpression: try container.decodeIfPresent(String.self, forKey: .matureExpression) ?? "",
            shadowLoop: try container.decodeIfPresent(String.self, forKey: .shadowLoop) ?? "",
            ritualPrompt: try container.decodeIfPresent(String.self, forKey: .ritualPrompt) ?? "",
            mantra: try container.decodeIfPresent(String.self, forKey: .mantra) ?? ""
        )
        .normalized()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(westernSign, forKey: .westernSign)
        try container.encode(chineseSign, forKey: .chineseSign)
        try container.encode(title, forKey: .title)
        try container.encode(tagline, forKey: .tagline)
        try container.encode(identitySummary, forKey: .identitySummary)
        try container.encode(coreEnergy, forKey: .coreEnergy)
        try container.encode(strengths, forKey: .strengths)
        try container.encode(growthEdges, forKey: .growthEdges)
        try container.encode(loveStyle, forKey: .loveStyle)
        try container.encode(friendshipStyle, forKey: .friendshipStyle)
        try container.encode(workStyle, forKey: .workStyle)
        try container.encode(communicationStyle, forKey: .communicationStyle)
        try container.encode(emotionalPattern, forKey: .emotionalPattern)
        try container.encode(shadowPattern, forKey: .shadowPattern)
        try container.encode(bestPractices, forKey: .bestPractices)
        try container.encode(earlyExpression, forKey: .earlyExpression)
        try container.encode(matureExpression, forKey: .matureExpression)
        try container.encode(shadowLoop, forKey: .shadowLoop)
        try container.encode(ritualPrompt, forKey: .ritualPrompt)
        try container.encode(mantra, forKey: .mantra)
    }
}

extension ZodiacIdentityContent {
    static var placeholder: ZodiacIdentityContent {
        fallback(westernSign: "unknown", chineseSign: "unknown", requestedID: "mystic-blend")
    }

    static func fallback(
        westernSign: String,
        chineseSign: String,
        requestedID: String? = nil
    ) -> ZodiacIdentityContent {
        let normalizedWestern = normalizedSignPart(westernSign, fallback: "unknown")
        let normalizedChinese = normalizedSignPart(chineseSign, fallback: "unknown")
        let fallbackID = requestedID?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let resolvedID = (fallbackID?.isEmpty == false)
            ? fallbackID!
            : "\(normalizedWestern)-\(normalizedChinese)"

        return ZodiacIdentityContent(
            id: resolvedID,
            westernSign: normalizedWestern,
            chineseSign: normalizedChinese,
            title: "The Hidden Pattern",
            tagline: "Quiet signal, strong pull",
            identitySummary: "You notice the shift early — and protect your read until it feels safe to show",
            coreEnergy: "You feel movement underneath before the room admits it",
            strengths: [
                "You catch the tone change before anyone names it",
                "You stay composed while reading what is actually happening",
                "You keep moving once the signal feels real"
            ],
            growthEdges: [
                "You hold back too long while waiting for cleaner proof",
                "You overread mixed signals and call it intuition",
                "You protect your pace so hard that people cannot meet you in it"
            ],
            loveStyle: "You need steadiness to stay open. You read subtle shifts early — and expect follow-through to match the words",
            friendshipStyle: "You show up through pattern recognition, quick honesty, and a low tolerance for performative closeness",
            workStyle: "You work best when the direction is real. You influence by spotting what is changing before everyone else adjusts",
            communicationStyle: "You speak with precision and restraint. It breaks down when you expect people to catch what you chose not to say",
            emotionalPattern: "People think you're calm. Reality: you're tracking more than you let anyone see",
            shadowPattern: "Discernment becomes distance",
            bestPractices: [
                "Say the real thing before your silence turns into strategy",
                "Name the pattern without waiting for perfect proof",
                "Let people support the version of you that is still forming"
            ],
            earlyExpression: "At first, you look contained and easy to read while your real read of the room stays protected",
            matureExpression: "With time, you stop hiding your precision. Your timing gets cleaner, your boundaries get clearer, and your decisions stop apologizing",
            shadowLoop: "Under pressure, you go watchful, go quiet, then let private conclusions harden before anyone gets a fair chance to meet you",
            ritualPrompt: "Trust the signal early",
            mantra: "I do not need more noise to trust what I know"
        )
    }

    var recognitionLines: [String] {
        IdentityDescriptionFormatter.recognitionLines(
            summary: identitySummary,
            coreEnergy: coreEnergy,
            emotionalPattern: emotionalPattern,
            shadowPattern: shadowPattern
        )
    }

    var formattedIdentitySummary: String {
        IdentityDescriptionFormatter.identitySummary(
            summary: identitySummary,
            coreEnergy: coreEnergy,
            emotionalPattern: emotionalPattern,
            shadowPattern: shadowPattern
        )
    }

    var revealPrimaryBody: String {
        identitySummary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func normalized() -> ZodiacIdentityContent {
        let fallback = Self.fallback(
            westernSign: westernSign,
            chineseSign: chineseSign,
            requestedID: id
        )

        return ZodiacIdentityContent(
            id: Self.normalizedValue(id, fallback: fallback.id),
            westernSign: Self.normalizedSignPart(westernSign, fallback: fallback.westernSign),
            chineseSign: Self.normalizedSignPart(chineseSign, fallback: fallback.chineseSign),
            title: Self.normalizedValue(title, fallback: fallback.title),
            tagline: Self.normalizedValue(tagline, fallback: fallback.tagline),
            identitySummary: Self.normalizedValue(identitySummary, fallback: fallback.identitySummary),
            coreEnergy: Self.normalizedValue(coreEnergy, fallback: fallback.coreEnergy),
            strengths: Self.normalizedItems(strengths, fallback: fallback.strengths),
            growthEdges: Self.normalizedItems(growthEdges, fallback: fallback.growthEdges),
            loveStyle: Self.normalizedValue(loveStyle, fallback: fallback.loveStyle),
            friendshipStyle: Self.normalizedValue(friendshipStyle, fallback: fallback.friendshipStyle),
            workStyle: Self.normalizedValue(workStyle, fallback: fallback.workStyle),
            communicationStyle: Self.normalizedValue(communicationStyle, fallback: fallback.communicationStyle),
            emotionalPattern: Self.normalizedValue(emotionalPattern, fallback: fallback.emotionalPattern),
            shadowPattern: Self.normalizedValue(shadowPattern, fallback: fallback.shadowPattern),
            bestPractices: Self.normalizedItems(bestPractices, fallback: fallback.bestPractices),
            earlyExpression: Self.normalizedValue(earlyExpression, fallback: fallback.earlyExpression),
            matureExpression: Self.normalizedValue(matureExpression, fallback: fallback.matureExpression),
            shadowLoop: Self.normalizedValue(shadowLoop, fallback: fallback.shadowLoop),
            ritualPrompt: Self.normalizedValue(ritualPrompt, fallback: fallback.ritualPrompt),
            mantra: Self.normalizedValue(mantra, fallback: fallback.mantra)
        )
    }

    private static func normalizedValue(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func normalizedItems(_ items: [String], fallback: [String]) -> [String] {
        let cleaned = items
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return cleaned.isEmpty ? fallback : cleaned
    }

    private static func normalizedSignPart(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func derivedSigns(from id: String) -> (western: String, chinese: String) {
        let parts = id
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .split(separator: "-", maxSplits: 1)
            .map(String.init)

        guard parts.count == 2 else {
            return ("unknown", "unknown")
        }

        return (parts[0], parts[1])
    }
}

extension ZodiacIdentityContent {
    static func fromArchetype(
        _ archetype: Archetype,
        western: WesternZodiac,
        chinese: ChineseZodiac
    ) -> ZodiacIdentityContent {
        ZodiacIdentityContent(
            id: archetype.id,
            westernSign: western.rawValue,
            chineseSign: chinese.rawValue,
            title: archetype.title,
            tagline: archetype.tagline,
            identitySummary: archetype.overview,
            coreEnergy: archetype.tagline,
            strengths: archetype.strengths,
            growthEdges: archetype.shadows,
            loveStyle: archetype.loveStyle,
            friendshipStyle: archetype.friendshipStyle,
            workStyle: archetype.workStyle,
            communicationStyle: archetype.compatibilityNotes,
            emotionalPattern: archetype.emotionalPattern,
            // The legacy archetype source does not provide these distinct
            // canonical fields. Keep them empty so optional Identity sections
            // are omitted instead of repeating overview/growth text.
            shadowPattern: "",
            bestPractices: [],
            earlyExpression: archetype.howYouMove ?? "",
            matureExpression: "",
            shadowLoop: "",
            ritualPrompt: "",
            mantra: ""
        )
    }
}

enum IdentityDescriptionFormatter {
    static func recognitionLines(
        summary: String,
        coreEnergy: String,
        emotionalPattern: String,
        shadowPattern: String
    ) -> [String] {
        let prioritized = [
            tensionPair(
                summary: summary,
                coreEnergy: coreEnergy,
                emotionalPattern: emotionalPattern,
                shadowPattern: shadowPattern
            ),
            fallbackTensionPair(
                summary: summary,
                coreEnergy: coreEnergy,
                emotionalPattern: emotionalPattern,
                shadowPattern: shadowPattern
            )
        ]
        .flatMap { $0 }
        .compactMap { constrainedTensionLine(from: $0) }
        .filter { !$0.isEmpty }
        .reduce(into: [String]()) { result, line in
            let key = normalizedKey(for: line)
            guard !result.contains(where: { normalizedKey(for: $0) == key }) else { return }
            result.append(line)
        }

        return Array(prioritized.prefix(2))
    }

    static func identitySummary(
        summary: String,
        coreEnergy: String,
        emotionalPattern: String,
        shadowPattern: String
    ) -> String {
        let lines = recognitionLines(
            summary: summary,
            coreEnergy: coreEnergy,
            emotionalPattern: emotionalPattern,
            shadowPattern: shadowPattern
        ) + [
            compactLine(from: coreEnergy),
            compactLine(from: shadowPattern),
            compactLine(from: summary)
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .reduce(into: [String]()) { result, line in
            let key = normalizedKey(for: line)
            guard !result.contains(where: { normalizedKey(for: $0) == key }) else { return }
            result.append(capitalize(line.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        .prefix(4)

        return lines.joined(separator: "\n")
    }

    static func format(_ raw: String) -> String {
        let normalized = raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "—", with: ". ")
            .replacingOccurrences(of: "–", with: ". ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let blendFormat = formattedBlendSummary(from: normalized) {
            return blendFormat
        }

        let sentences = normalized
            .split(whereSeparator: \.isNewline)
            .flatMap { chunk in
                chunk
                    .split(separator: "")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }

        let lines = sentences
            .prefix(4)
            .map { sentence in
                let cleaned = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                return cleaned.hasSuffix("") ? cleaned : cleaned + ""
            }

        return lines.joined(separator: "\n")
    }

    private static func compactLine(from raw: String) -> String {
        compactLine(from: raw, maxWords: 12)
    }

    private static func compactLine(from raw: String, maxWords: Int) -> String {
        let normalized = raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "—", with: ". ")
            .replacingOccurrences(of: "–", with: ". ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let blendFormat = formattedBlendSummary(from: normalized)?
            .components(separatedBy: "\n")
            .first {
            return blendFormat
        }

        let firstSentence = normalized
            .split(separator: "")
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? normalized

        let short = firstSentence
            .replacingOccurrences(of: "You are ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "You ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "Your ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "At times, ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "Often, ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "guided by ", with: "with ")
            .replacingOccurrences(of: "creating a presence that feels ", with: "")
            .replacingOccurrences(of: "This combination ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedWords = short.split(separator: " ").prefix(maxWords).joined(separator: " ")
        guard !trimmedWords.isEmpty else { return "" }
        let cleaned = capitalizeLeadingCharacter(
            in: trimmedWords.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return cleaned.hasSuffix("") ? cleaned : cleaned + ""
    }

    private static func capitalizeLeadingCharacter(in value: String) -> String {
        guard let first = value.first else { return value }
        return first.uppercased() + value.dropFirst()
    }

    private static func tensionPair(
        summary: String,
        coreEnergy: String,
        emotionalPattern: String,
        shadowPattern: String
    ) -> [String] {
        let visible = visibleTensionLine(
            emotionalPattern: emotionalPattern,
            coreEnergy: coreEnergy,
            summary: summary
        )
        let hidden = hiddenTensionLine(
            emotionalPattern: emotionalPattern,
            shadowPattern: shadowPattern,
            summary: summary
        )

        return [visible, hidden]
    }

    private static func fallbackTensionPair(
        summary: String,
        coreEnergy: String,
        emotionalPattern: String,
        shadowPattern: String
    ) -> [String] {
        let normalized = normalizedSentence(
            from: [summary, coreEnergy, emotionalPattern, shadowPattern]
                .joined(separator: " ")
        )

        if containsAny(normalized, ["quiet", "gentle", "refined", "calm", "steady"]) {
            return [
                "Looks calm from the outside",
                "Keeps more than gets shown"
            ]
        }

        if containsAny(normalized, ["bold", "bright", "fearless", "radiant", "impossible to ignore"]) {
            return [
                "Comes in strong right away",
                "Pressure builds before it shows"
            ]
        }

        return [
            "Looks settled from the outside",
            "Still carrying more than shows"
        ]
    }

    private static func visibleTensionLine(
        emotionalPattern: String,
        coreEnergy: String,
        summary: String
    ) -> String {
        let emotionalClauses = clauses(from: emotionalPattern)
        if let first = emotionalClauses.first {
            if let normalized = normalizedSurfaceClause(first) {
                return normalized
            }
        }

        let coreClauses = clauses(from: coreEnergy)
        if let first = coreClauses.first {
            if let normalized = normalizedSurfaceClause(first) {
                return normalized
            }
        }

        let normalized = normalizedSentence(
            from: [emotionalPattern, coreEnergy, summary].joined(separator: " ")
        )

        if containsAny(normalized, ["quiet", "gentle", "steady", "calm"]) {
            return "Looks calm from the outside"
        }
        if containsAny(normalized, ["bold", "bright", "fearless", "radiant"]) {
            return "Comes in strong right away"
        }

        return "Looks composed from the outside"
    }

    private static func hiddenTensionLine(
        emotionalPattern: String,
        shadowPattern: String,
        summary: String
    ) -> String {
        let emotionalClauses = clauses(from: emotionalPattern)
        if emotionalClauses.count > 1 {
            for clause in emotionalClauses.dropFirst() {
                if let normalized = normalizedHiddenClause(clause) {
                    return normalized
                }
            }
        }

        let shadowClauses = clauses(from: shadowPattern)
        for clause in shadowClauses {
            if let normalized = normalizedHiddenClause(clause) {
                return normalized
            }
        }

        let normalized = normalizedSentence(
            from: [emotionalPattern, shadowPattern, summary].joined(separator: " ")
        )

        if containsAny(normalized, ["mistaking urgency for truth", "impulsiveness", "frustration with delay"]) {
            return "Still rushes past the truth"
        }
        if containsAny(normalized, ["avoidance after intensity"]) {
            return "Pulls back after the impact"
        }
        if containsAny(normalized, ["self-doubt after action"]) {
            return "Second guesses the move later"
        }
        if containsAny(normalized, ["emotional reserve"]) {
            return "Keeps more than gets shown"
        }
        if containsAny(normalized, ["over-analysis", "perfectionism"]) {
            return "Doubt keeps editing the answer"
        }
        if containsAny(normalized, ["carrying too much responsibility alone", "too much responsibility alone"]) {
            return "Still carries too much alone"
        }
        if containsAny(normalized, ["resistance to change"]) {
            return "Change still feels a little risky"
        }
        if containsAny(normalized, ["comfort-zone attachment"]) {
            return "Familiar still wins too often"
        }
        if containsAny(normalized, ["overindulgence"]) {
            return "Relief can run the choices"
        }
        if containsAny(normalized, ["escaping complexity through distance"]) {
            return "Distance steps in when pressed"
        }
        if containsAny(normalized, ["bluntness"]) {
            return "Truth lands before the pause"
        }
        if containsAny(normalized, ["restlessness"]) {
            return "Still outruns the harder feeling"
        }
        if containsAny(normalized, ["difficulty yielding control", "yielding control"]) {
            return "Control tightens under pressure"
        }
        if containsAny(normalized, ["ego sensitivity"]) {
            return "Praise matters more than admitted"
        }
        if containsAny(normalized, ["overwhelms others", "intensity that overwhelms others"]) {
            return "Intensity can outrun the room"
        }
        if containsAny(normalized, ["detachment", "disconnection", "contrarian distance"]) {
            return "Distance passes for independence"
        }
        if containsAny(normalized, ["rigidity"]) {
            return "Softness gets held in place"
        }
        if containsAny(normalized, ["achievement", "over-identification with achievement"]) {
            return "Worth still tracks the result"
        }
        if containsAny(normalized, ["inconsistency"]) {
            return "Commitment takes a second look"
        }
        if containsAny(normalized, ["resistance to containment"]) {
            return "Limits still feel like threats"
        }
        if containsAny(normalized, ["inner conflict"]) {
            return "Both instincts pull at once"
        }
        if containsAny(normalized, ["distance", "held back", "beneath the surface"]) {
            return "Something stays held underneath"
        }

        return "Still carrying more than shows"
    }

    private static func clauses(from raw: String) -> [String] {
        normalizedSentence(from: raw)
            .split(whereSeparator: { ".;:".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func normalizedSurfaceClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.hasPrefix("you look steady") {
            return "Looks steady at first"
        }
        if lowered.hasPrefix("moves bold") {
            return "Moves bold in the moment"
        }
        if lowered.hasPrefix("you stay soft and see every edge") {
            return "Stays soft at first"
        }
        if lowered.hasPrefix("leads with warmth") {
            return "Leads with warmth first"
        }
        if lowered.hasPrefix("needs motion") {
            return "Needs motion to stay clear"
        }
        if lowered.hasPrefix("tests loyalty before fully relaxing") {
            return "Tests loyalty before relaxing"
        }
        if lowered.hasPrefix("takes up space") {
            return "Takes up space easily"
        }
        if lowered.hasPrefix("starts first") {
            return "Starts first in the room"
        }
        if lowered.hasPrefix("shows brightly") {
            return "Shows brightly in the room"
        }
        if lowered.hasPrefix("follows truth") {
            return "Follows truth past approval"
        }
        if lowered.hasPrefix("moves slowly") {
            return "Moves slowly on the surface"
        }
        if lowered.hasPrefix("builds quietly") {
            return "Builds quietly from the start"
        }
        if lowered.hasPrefix("tracks patterns early") {
            return "Tracks the pattern early"
        }

        let cleaned = clause
            .replacingOccurrences(of: "You ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "Your ", with: "", options: [.caseInsensitive, .anchored])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return nil }
        return capitalize(cleaned)
    }

    private static func normalizedHiddenClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.hasPrefix("pressure builds underneath") {
            return "Pressure builds underneath it"
        }
        if lowered.hasPrefix("expects a real response") {
            return nil
        }
        if lowered.hasPrefix("meaning catches up later") {
            return "Meaning catches up later"
        }
        if lowered.hasPrefix("keeps the weight private") {
            return "The weight stays private"
        }
        if lowered.hasPrefix("feels more than it shows") {
            return "More stays hidden than shown"
        }
        if lowered.hasPrefix("keeps stronger boundaries") {
            return "Boundaries stay stronger than warmth"
        }
        if lowered.hasPrefix("you can soften the point too much") {
            return "Softens the point too much"
        }
        if lowered.hasPrefix("second thoughts come later") {
            return "Second thoughts come later"
        }
        if lowered.hasPrefix("competence can hide the need") {
            return "Competence can hide the need"
        }
        if lowered.hasPrefix("warmth invites too much") {
            return "Warmth invites too much in"
        }
        if lowered.hasPrefix("distance can masquerade as clarity") {
            return "Distance can pass as clarity"
        }
        if lowered.hasPrefix("testing never fully stops") {
            return "Testing never fully stops"
        }
        if lowered.hasPrefix("impact outruns context") {
            return "Impact outruns the context"
        }
        if lowered.hasPrefix("freedom can outrun depth") {
            return "Freedom outruns the deeper part"
        }
        if lowered.hasPrefix("pride can answer before softness") {
            return "Pride answers before softness"
        }
        if lowered.hasPrefix("control can look like calm") {
            return "Control can pass as calm"
        }
        if lowered.hasPrefix("resists any easy containment") {
            return "Resists any easy containment"
        }
        if lowered.hasPrefix("care can tighten into control") {
            return "Care tightens into control"
        }
        if lowered.hasPrefix("the room gets crowded") {
            return "Need gets crowded out"
        }

        let cleaned = clause
            .replacingOccurrences(of: "You ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "Your ", with: "", options: [.caseInsensitive, .anchored])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return nil }
        return capitalize(cleaned)
    }

    private static func constrainedTensionLine(from raw: String) -> String? {
        let cleaned = raw
            .replacingOccurrences(of: "—", with: " ")
            .replacingOccurrences(of: "–", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return nil }

        let words = cleaned.split(separator: " ")
        guard !words.isEmpty else { return nil }

        let trimmed = words.prefix(8).joined(separator: " ")
        let count = trimmed.split(separator: " ").count
        guard count >= 4 else { return nil }
        let capitalized = capitalize(trimmed.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !capitalized.isEmpty else { return nil }
        return capitalized.hasSuffix("") ? capitalized : capitalized + ""
    }

    private static func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }

    private static func normalizedSentence(from raw: String) -> String {
        raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "—", with: ". ")
            .replacingOccurrences(of: "–", with: ". ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func firstSentence(in raw: String) -> String {
        let normalized = normalizedSentence(from: raw)
        return normalized
            .split(separator: "")
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""
    }

    private static func formattedBlendSummary(from text: String) -> String? {
        let pattern = #"^You blend (.+?) with (.+?), creating a presence that feels (.+?)\.(?: This combination (?:.+?) your path through (.+?)\.)?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let firstRange = Range(match.range(at: 1), in: text),
              let secondRange = Range(match.range(at: 2), in: text),
              let traitRange = Range(match.range(at: 3), in: text) else {
            return nil
        }

        let first = text[firstRange].trimmingCharacters(in: .whitespacesAndNewlines)
        let second = text[secondRange].trimmingCharacters(in: .whitespacesAndNewlines)
        let traits = text[traitRange].trimmingCharacters(in: .whitespacesAndNewlines)

        var lines = [
            "\(capitalize(first)) meets \(second)",
            "Your energy feels \(traits)"
        ]

        if let pathRange = Range(match.range(at: 4), in: text) {
            let path = text[pathRange].trimmingCharacters(in: .whitespacesAndNewlines)
            if !path.isEmpty {
                lines.append("It shapes how you move through \(path)")
            }
        }

        return lines.prefix(4).joined(separator: "\n")
    }

    private static func capitalize(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    private static func normalizedKey(for line: String) -> String {
        line.lowercased()
            .replacingOccurrences(of: "", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
