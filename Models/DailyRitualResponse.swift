import Foundation

enum DailyRitualSource: String, Equatable {
    case structuredSupabaseRow
    case legacySupabaseRow
    case localFallback
    case notReadyFallback

    var debugDescription: String {
        switch self {
        case .structuredSupabaseRow:
            return "structured Supabase row"
        case .legacySupabaseRow:
            return "legacy Supabase row"
        case .localFallback:
            return "local fallback"
        case .notReadyFallback:
            return "not-ready fallback"
        }
    }
}

struct DailyReadContinuityMetadata: Codable, Equatable {
    let focusKey: String?
    let perspectiveKey: String?
    let comparisonSummary: String?

    init(
        focusKey: String? = nil,
        perspectiveKey: String? = nil,
        comparisonSummary: String? = nil
    ) {
        self.focusKey = focusKey
        self.perspectiveKey = perspectiveKey
        self.comparisonSummary = comparisonSummary
    }

    enum CodingKeys: String, CodingKey {
        case focusKey = "focus_key"
        case perspectiveKey = "perspective_key"
        case comparisonSummary = "comparison_summary"
    }
}

struct DailyReadPatternIntelligenceMetadata: Codable, Equatable {
    let confidence: Double?
    let reflection: Double?
    let connection: Double?
    let growth: Double?
    let momentum: Double?
    let primarySignal: String?
    let secondarySignal: String?
    let emotionalTone: String?
    let themeTags: [String]

    init(
        confidence: Double? = nil,
        reflection: Double? = nil,
        connection: Double? = nil,
        growth: Double? = nil,
        momentum: Double? = nil,
        primarySignal: String? = nil,
        secondarySignal: String? = nil,
        emotionalTone: String? = nil,
        themeTags: [String] = []
    ) {
        self.confidence = Self.clampedScore(confidence)
        self.reflection = Self.clampedScore(reflection)
        self.connection = Self.clampedScore(connection)
        self.growth = Self.clampedScore(growth)
        self.momentum = Self.clampedScore(momentum)
        self.primarySignal = primarySignal
        self.secondarySignal = secondarySignal
        self.emotionalTone = emotionalTone
        self.themeTags = Self.normalizedThemeTags(themeTags)
    }

    enum CodingKeys: String, CodingKey {
        case confidence
        case reflection
        case connection
        case growth
        case momentum
        case primarySignal = "primary_signal"
        case secondarySignal = "secondary_signal"
        case emotionalTone = "emotional_tone"
        case themeTags = "theme_tags"
    }

    var hasAnyValue: Bool {
        confidence != nil
            || reflection != nil
            || connection != nil
            || growth != nil
            || momentum != nil
            || primarySignal != nil
            || secondarySignal != nil
            || emotionalTone != nil
            || !themeTags.isEmpty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        confidence = Self.clampedScore(Self.decodeScore(from: container, forKey: .confidence))
        reflection = Self.clampedScore(Self.decodeScore(from: container, forKey: .reflection))
        connection = Self.clampedScore(Self.decodeScore(from: container, forKey: .connection))
        growth = Self.clampedScore(Self.decodeScore(from: container, forKey: .growth))
        momentum = Self.clampedScore(Self.decodeScore(from: container, forKey: .momentum))
        primarySignal = Self.decodeString(from: container, forKey: .primarySignal)
        secondarySignal = Self.decodeString(from: container, forKey: .secondarySignal)
        emotionalTone = Self.decodeString(from: container, forKey: .emotionalTone)
        themeTags = Self.decodeThemeTags(from: container)
    }

    private static func decodeScore(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double? {
        if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
            return value
        }

        if let string = try? container.decodeIfPresent(String.self, forKey: key),
           let value = Double(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return value
        }

        return nil
    }

    private static func decodeString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        guard let value = try? container.decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        return value.nilIfBlank
    }

    private static func decodeThemeTags(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let tags = try? container.decodeIfPresent([LossyString].self, forKey: .themeTags) {
            return normalizedThemeTags(tags.compactMap(\.value))
        }

        if let tagList = try? container.decodeIfPresent(String.self, forKey: .themeTags) {
            return normalizedThemeTags(
                tagList
                    .split(separator: ",")
                    .map(String.init)
            )
        }

        return []
    }

    private static func normalizedThemeTags(_ tags: [String]) -> [String] {
        tags
            .compactMap(\.nilIfBlank)
            .reduce(into: []) { result, tag in
                guard !result.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
                result.append(tag)
            }
    }

    private static func clampedScore(_ value: Double?) -> Double? {
        guard let value, value.isFinite else { return nil }
        return min(1, max(0, value))
    }

    fileprivate struct LossyString: Decodable {
        let value: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let string = try? container.decode(String.self) {
                value = string.nilIfBlank
            } else {
                value = nil
            }
        }
    }
}

struct DailyRitualResponse: Codable, Equatable {
    let id: String?
    let ritualDate: String?
    let westernSign: String?
    let easternSign: String?
    let title: String
    let intro: String
    let pullQuote: String
    let deeperRead: String
    let watchFor: String
    let move: String
    let ritualText: String
    let actionText: String
    let createdAt: String?
    let source: DailyRitualSource
    let continuity: DailyReadContinuityMetadata?
    let patternIntelligence: DailyReadPatternIntelligenceMetadata?

    init(
        id: String? = nil,
        ritualDate: String? = nil,
        westernSign: String? = nil,
        easternSign: String? = nil,
        title: String,
        intro: String,
        pullQuote: String,
        deeperRead: String,
        watchFor: String,
        move: String,
        ritualText: String,
        actionText: String,
        createdAt: String? = nil,
        source: DailyRitualSource = .structuredSupabaseRow,
        continuity: DailyReadContinuityMetadata? = nil,
        patternIntelligence: DailyReadPatternIntelligenceMetadata? = nil
    ) {
        self.id = id
        self.ritualDate = ritualDate
        self.westernSign = westernSign
        self.easternSign = easternSign
        self.title = title
        self.intro = intro
        self.pullQuote = pullQuote
        self.deeperRead = deeperRead
        self.watchFor = watchFor
        self.move = move
        self.ritualText = ritualText
        self.actionText = actionText
        self.createdAt = createdAt
        self.source = source
        self.continuity = continuity
        self.patternIntelligence = patternIntelligence?.hasAnyValue == true ? patternIntelligence : nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ritualDate = "ritual_date"
        case westernSign = "western_sign"
        case easternSign = "eastern_sign"
        case title
        case intro
        case pullQuote = "pull_quote"
        case deeperRead = "deeper_read"
        case watchFor = "watch_for"
        case move
        case ritualText = "ritual_text"
        case actionText = "action_text"
        case createdAt = "created_at"
        case continuity
        case patternIntelligence = "pattern_intelligence"
        case confidence
        case reflection
        case connection
        case growth
        case momentum
        case primarySignal = "primary_signal"
        case secondarySignal = "secondary_signal"
        case emotionalTone = "emotional_tone"
        case themeTags = "theme_tags"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        ritualDate = try container.decodeIfPresent(String.self, forKey: .ritualDate)
        westernSign = try container.decodeIfPresent(String.self, forKey: .westernSign)
        easternSign = try container.decodeIfPresent(String.self, forKey: .easternSign)
        title = try container.decode(String.self, forKey: .title)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        continuity = try container.decodeIfPresent(DailyReadContinuityMetadata.self, forKey: .continuity)
        patternIntelligence = try Self.patternIntelligenceMetadata(in: container)

        // Preserve the authored legacy body byte-for-byte for the canonical
        // title/read adapter. A normalized copy is used only to derive missing
        // historical section fields.
        let rawLegacyRitualText = try container.decodeIfPresent(String.self, forKey: .ritualText) ?? ""
        let legacyRitualText = rawLegacyRitualText.trimmedAndCollapsed
        let legacyActionText = try container.decodeIfPresent(String.self, forKey: .actionText)?.trimmedAndCollapsed ?? ""
        let sentences = Self.splitSentences(from: legacyRitualText)
        let structuredFieldsPresent = try Self.structuredFieldsPresent(in: container)

        let decodedIntro = try container.decodeIfPresent(String.self, forKey: .intro)
            ?? sentences.first
            ?? legacyRitualText

        let decodedPullQuote = try container.decodeIfPresent(String.self, forKey: .pullQuote)
            ?? Self.meaningful(sentences.dropFirst().first, comparedTo: [decodedIntro])
            ?? ""

        let remainingLegacyText = Array(sentences.dropFirst(2)).joined(separator: " ")
        let decodedDeeperRead = try container.decodeIfPresent(String.self, forKey: .deeperRead)
            ?? Self.meaningful(remainingLegacyText, comparedTo: [decodedIntro, decodedPullQuote])
            ?? ""

        let decodedWatchFor = try container.decodeIfPresent(String.self, forKey: .watchFor) ?? ""
        let decodedMove = try container.decodeIfPresent(String.self, forKey: .move)
            ?? legacyActionText

        intro = decodedIntro.trimmedAndCollapsed
        pullQuote = decodedPullQuote.trimmedAndCollapsed
        deeperRead = decodedDeeperRead.trimmedAndCollapsed
        watchFor = decodedWatchFor.trimmedAndCollapsed
        move = decodedMove.trimmedAndCollapsed

        ritualText = rawLegacyRitualText.nilIfBlankPreservingWhitespace
            ?? [intro, pullQuote, deeperRead]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " ")

        actionText = legacyActionText.nilIfBlank ?? move
        source = title.isDailyReadUnavailableTitle ? .notReadyFallback : (structuredFieldsPresent ? .structuredSupabaseRow : .legacySupabaseRow)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(ritualDate, forKey: .ritualDate)
        try container.encodeIfPresent(westernSign, forKey: .westernSign)
        try container.encodeIfPresent(easternSign, forKey: .easternSign)
        try container.encode(title, forKey: .title)
        try container.encode(intro, forKey: .intro)
        try container.encode(pullQuote, forKey: .pullQuote)
        try container.encode(deeperRead, forKey: .deeperRead)
        try container.encode(watchFor, forKey: .watchFor)
        try container.encode(move, forKey: .move)
        try container.encode(ritualText, forKey: .ritualText)
        try container.encode(actionText, forKey: .actionText)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(continuity, forKey: .continuity)
        try container.encodeIfPresent(patternIntelligence, forKey: .patternIntelligence)
    }

    private static func splitSentences(from text: String) -> [String] {
        let trimmed = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        guard !trimmed.isEmpty else { return [] }

        let sentenceEndings = CharacterSet(charactersIn: ".!?")
        let sentences = trimmed
            .components(separatedBy: sentenceEndings)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { sentence -> String in
                guard let range = trimmed.range(of: sentence),
                      let nextCharacter = trimmed[range.upperBound...].first,
                      ".!?".contains(nextCharacter) else {
                    return sentence
                }

                return "\(sentence)\(nextCharacter)"
            }

        return sentences.isEmpty ? [trimmed] : sentences
    }

    private static func structuredFieldsPresent(in container: KeyedDecodingContainer<CodingKeys>) throws -> Bool {
        let values = [
            try container.decodeIfPresent(String.self, forKey: .intro),
            try container.decodeIfPresent(String.self, forKey: .pullQuote),
            try container.decodeIfPresent(String.self, forKey: .deeperRead),
            try container.decodeIfPresent(String.self, forKey: .watchFor),
            try container.decodeIfPresent(String.self, forKey: .move)
        ]

        return values.contains { ($0?.nilIfBlank) != nil }
    }

    private static func patternIntelligenceMetadata(in container: KeyedDecodingContainer<CodingKeys>) throws -> DailyReadPatternIntelligenceMetadata? {
        if let nested = try? container.decodeIfPresent(DailyReadPatternIntelligenceMetadata.self, forKey: .patternIntelligence),
           nested.hasAnyValue {
            return nested
        }

        let metadata = DailyReadPatternIntelligenceMetadata(
            confidence: topLevelPatternScore(in: container, forKey: .confidence),
            reflection: topLevelPatternScore(in: container, forKey: .reflection),
            connection: topLevelPatternScore(in: container, forKey: .connection),
            growth: topLevelPatternScore(in: container, forKey: .growth),
            momentum: topLevelPatternScore(in: container, forKey: .momentum),
            primarySignal: topLevelPatternString(in: container, forKey: .primarySignal),
            secondarySignal: topLevelPatternString(in: container, forKey: .secondarySignal),
            emotionalTone: topLevelPatternString(in: container, forKey: .emotionalTone),
            themeTags: topLevelPatternThemeTags(in: container)
        )

        return metadata.hasAnyValue ? metadata : nil
    }

    private static func topLevelPatternScore(
        in container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double? {
        if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
            return value
        }

        if let string = try? container.decodeIfPresent(String.self, forKey: key),
           let value = Double(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return value
        }

        return nil
    }

    private static func topLevelPatternString(
        in container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        guard let value = try? container.decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        return value.nilIfBlank
    }

    private static func topLevelPatternThemeTags(in container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let tags = try? container.decodeIfPresent([DailyReadPatternIntelligenceMetadata.LossyString].self, forKey: .themeTags) {
            return tags.compactMap(\.value)
        }

        if let tagList = try? container.decodeIfPresent(String.self, forKey: .themeTags) {
            return tagList
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return []
    }

    private static func meaningful(_ value: String?, comparedTo nearbyValues: [String]) -> String? {
        guard let value = value?.nilIfBlank else { return nil }
        let fingerprint = value.dailyReadFingerprint
        guard !nearbyValues.contains(where: { $0.dailyReadFingerprint == fingerprint }) else {
            return nil
        }

        return value
    }
}

extension DailyRitualResponse {
    var isUnavailableDailyRead: Bool {
        title.isDailyReadUnavailableTitle || isGenericPreparedCopy || source == .notReadyFallback || source == .localFallback
    }

    var isGenericPreparedCopy: Bool {
        let values = [
            title,
            intro,
            pullQuote,
            deeperRead,
            watchFor,
            move,
            ritualText,
            actionText
        ]
        .compactMap { $0.nilIfBlank }
        .map(\.dailyReadFingerprint)

        return values.contains { fingerprint in
            Self.placeholderFingerprints.contains(where: { fingerprint.contains($0) })
        }
    }

    var validPullQuote: String? {
        validStructuredField(pullQuote, excluding: [title, intro, deeperRead, watchFor, move])
    }

    var validDeeperRead: String? {
        validStructuredField(deeperRead, excluding: [title, intro, pullQuote, watchFor, move])
    }

    var validWatchFor: String? {
        validStructuredField(watchFor, excluding: [title, intro, pullQuote, deeperRead, move])
    }

    var validMove: String? {
        validStructuredField(move, excluding: [title, intro, pullQuote, deeperRead, watchFor])
    }

    var unavailableMessage: String {
        validStructuredField(intro, excluding: [title])
            ?? validStructuredField(deeperRead, excluding: [title, intro])
            ?? "Check back shortly."
    }

    var hasRealDailyReadContent: Bool {
        !isUnavailableDailyRead && (
            ritualText.nilIfBlankPreservingWhitespace != nil
            || [
            intro.nilIfBlank,
            validPullQuote,
            validDeeperRead,
            validWatchFor,
            validMove
            ].contains { $0 != nil }
        )
    }

    var isReadyForDisplay: Bool {
        !isUnavailableDailyRead && !isGenericPreparedCopy && hasRealDailyReadContent
    }

    var isIncompleteForDisplay: Bool {
        !isReadyForDisplay
    }

    private func validStructuredField(_ value: String, excluding nearbyValues: [String]) -> String? {
        guard let trimmed = value.nilIfBlank else { return nil }
        let fingerprint = trimmed.dailyReadFingerprint

        guard !Self.placeholderFingerprints.contains(where: { fingerprint.contains($0) }) else {
            return nil
        }

        guard !nearbyValues.contains(where: { !$0.isEmpty && $0.dailyReadFingerprint == fingerprint }) else {
            return nil
        }

        return trimmed
    }

    private static let placeholderFingerprints = [
        "your ritual is being prepared",
        "your read is being prepared",
        "your read is still being prepared",
        "your read is still forming",
        "your daily read is ready",
        "your daily read is complete",
        "your daily read will appear here",
        "todays lens is ready",
        "todays lens is complete",
        "todays lens will appear here",
        "todays read is ready",
        "todays read is being prepared",
        "todays signal is not ready yet",
        "check back shortly",
        "take a moment to breathe",
        "not ready yet",
        "the signal is still loading",
        "return later for todays read"
    ]
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var nilIfBlankPreservingWhitespace: String? {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }

    var trimmedAndCollapsed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var dailyReadFingerprint: String {
        trimmedAndCollapsed
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
    }

    var isDailyReadUnavailableTitle: Bool {
        let normalized = dailyReadFingerprint
        return normalized == "not ready yet" || normalized == "your read is still forming"
    }
}
