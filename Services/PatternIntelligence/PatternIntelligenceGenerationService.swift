import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum PatternIntelligenceGenerationProviderKind: String, CaseIterable {
    case backendAI = "backend_ai"
    case appleFoundationModels = "apple_foundation_models"
    case fallback = "fallback"
}

enum PatternIntelligenceGenerationTask: Equatable {
    case earlyPatternSummary
    case patternShiftSummary
    case suggestedQuestionAnswerDraft(question: String)
}

struct PatternIntelligenceGenerationRequest {
    let task: PatternIntelligenceGenerationTask
    let preview: PatternIntelligencePreview
    let savedReads: [SavedDailyReading]
    let answerFacts: PatternIntelligenceAnswerFacts?
    let answerReasoning: PatternIntelligenceAnswerReasoning?

    init(
        task: PatternIntelligenceGenerationTask,
        preview: PatternIntelligencePreview,
        savedReads: [SavedDailyReading],
        answerFacts: PatternIntelligenceAnswerFacts? = nil,
        answerReasoning: PatternIntelligenceAnswerReasoning? = nil
    ) {
        self.task = task
        self.preview = preview
        self.savedReads = savedReads
        self.answerFacts = answerFacts
        self.answerReasoning = answerReasoning
    }
}

struct PatternIntelligenceAnswerFacts: Equatable {
    let questionID: String
    let questionText: String
    let primaryRecurringSignal: String?
    let primaryRecurringCount: Int?
    let secondarySignal: String?
    let earlierDominantSignal: String?
    let recentDominantSignal: String?
    let patternShiftSummary: String?
    let memoryCallback: String?
    let todayLensTitle: String?
    let todayLensSignal: String?
    let savedLensCount: Int
    let recentLensDateRange: String?
    let observations: [String]

    static func make(
        questionID: String,
        questionText: String,
        preview: PatternIntelligencePreview,
        savedReads: [SavedDailyReading]
    ) -> PatternIntelligenceAnswerFacts {
        let sortedReads = savedReads.sorted { $0.createdAt > $1.createdAt }
        let recentReads = Array(sortedReads.prefix(min(8, sortedReads.count)))
        let counts = labelCounts(from: recentReads)
        let sortedCounts = counts.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }

            return $0.value > $1.value
        }
        let primary = sortedCounts.first
        let secondary = sortedCounts.dropFirst().first
        let splitCount = max(1, min(sortedReads.count, (sortedReads.count + 1) / 2))
        let recentDominant = dominantLabel(from: Array(sortedReads.prefix(splitCount)))
        let earlierDominant = dominantLabel(from: Array(sortedReads.dropFirst(splitCount)))
        let todayLens = sortedReads.first
        let primarySignal = sentenceFragment(for: primary?.key ?? preview.topSignal ?? preview.topSignals.first)
        let secondarySignal = sentenceFragment(for: secondary?.key ?? preview.topSignals.dropFirst().first)
        let earlierSignal = sentenceFragment(for: earlierDominant)
        let recentSignal = sentenceFragment(for: recentDominant)
        let todaySignal = sentenceFragment(
            for: todayLens.flatMap { normalizedSignalLabel($0.patternPrimarySignal) }
                ?? todayLens.flatMap { normalizedSignalLabel($0.theme) }
        )

        return PatternIntelligenceAnswerFacts(
            questionID: questionID,
            questionText: questionText,
            primaryRecurringSignal: primarySignal,
            primaryRecurringCount: primary?.value,
            secondarySignal: secondarySignal,
            earlierDominantSignal: earlierSignal,
            recentDominantSignal: recentSignal,
            patternShiftSummary: preview.patternShift ?? preview.patternShiftNarrative,
            memoryCallback: preview.memoryCallback,
            todayLensTitle: cleanDisplayValue(todayLens?.theme),
            todayLensSignal: todaySignal,
            savedLensCount: preview.savedCount,
            recentLensDateRange: dateRange(from: recentReads),
            observations: observations(
                primarySignal: primarySignal,
                primaryCount: primary?.value,
                secondarySignal: secondarySignal,
                earlierSignal: earlierSignal,
                recentSignal: recentSignal,
                todaySignal: todaySignal,
                preview: preview
            )
        )
    }

    var promptSummary: String {
        [
            "Question id: \(questionID)",
            "Question: \(questionText)",
            "Saved Lens count: \(savedLensCount)",
            "Recent Lens date range: \(recentLensDateRange ?? "not available")",
            "Primary recurring signal/theme: \(primaryRecurringSignal ?? "not available")",
            "Primary recurring count: \(primaryRecurringCount.map(String.init) ?? "not available")",
            "Secondary signal/theme: \(secondarySignal ?? "not available")",
            "Earlier dominant signal/theme: \(earlierDominantSignal ?? "not available")",
            "Recent dominant signal/theme: \(recentDominantSignal ?? "not available")",
            "Pattern shift summary: \(patternShiftSummary ?? "not available")",
            "Memory callback: \(memoryCallback ?? "not available")",
            "Today Lens title: \(todayLensTitle ?? "not available")",
            "Today Lens signal/theme: \(todayLensSignal ?? "not available")",
            "Grounded observations: \(observations.isEmpty ? "not available" : observations.joined(separator: " | "))"
        ].joined(separator: "\n")
    }

    private static func observations(
        primarySignal: String?,
        primaryCount: Int?,
        secondarySignal: String?,
        earlierSignal: String?,
        recentSignal: String?,
        todaySignal: String?,
        preview: PatternIntelligencePreview
    ) -> [String] {
        var values: [String] = []

        if let primarySignal {
            let primaryThread = sentenceStart(for: threadPhrase(for: primarySignal))
            if let primaryCount, primaryCount > 1 {
                values.append("\(primaryThread) appears in \(primaryCount) recent saved Lenses.")
            } else {
                values.append("\(primaryThread) is the clearest current signal.")
            }
        }

        if let earlierSignal,
           let recentSignal,
           earlierSignal.caseInsensitiveCompare(recentSignal) != .orderedSame {
            values.append("Earlier Lenses leaned toward \(threadPhrase(for: earlierSignal)); recent Lenses point more toward \(threadPhrase(for: recentSignal)).")
        }

        if let secondarySignal {
            values.append("\(sentenceStart(for: threadPhrase(for: secondarySignal))) is also present in the recent pattern.")
        }

        if let todaySignal {
            values.append("Today connects to \(threadPhrase(for: todaySignal)).")
        }

        if let patternShift = preview.patternShift ?? preview.patternShiftNarrative {
            values.append(patternShift)
        }

        return Array(values.prefix(4))
    }

    private static func labelCounts(from reads: [SavedDailyReading]) -> [String: Int] {
        var counts: [String: Int] = [:]

        for read in reads {
            for label in signalLabels(from: read) {
                counts[label, default: 0] += 1
            }
        }

        return counts
    }

    private static func dominantLabel(from reads: [SavedDailyReading]) -> String? {
        let counts = labelCounts(from: reads)
        return counts.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }

            return $0.value > $1.value
        }
        .first?
        .key
    }

    private static func signalLabels(from read: SavedDailyReading) -> [String] {
        var labels: [String] = []

        for signal in [read.patternPrimarySignal, read.patternSecondarySignal] {
            appendUnique(normalizedSignalLabel(signal), to: &labels)
        }

        for tag in read.patternThemeTags ?? [] {
            appendUnique(normalizedSignalLabel(tag), to: &labels)
        }

        appendUnique(normalizedSignalLabel(read.theme), to: &labels)

        return labels
    }

    private static func appendUnique(_ value: String?, to values: inout [String]) {
        guard let value,
              !values.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) else {
            return
        }

        values.append(value)
    }

    private static func normalizedSignalLabel(_ value: String?) -> String? {
        guard let value = cleanDisplayValue(value) else { return nil }

        switch value.lowercased() {
        case "ask questions", "question", "questions":
            return "Ask Questions"
        case "trust instincts", "trust instinct", "trust":
            return "Trust Instincts"
        case "being seen", "seen":
            return "Being Seen"
        case "quiet confidence", "confidence":
            return "Quiet Confidence"
        case "choose growth", "growth":
            return "Choose Growth"
        case "build momentum", "momentum":
            return "Build Momentum"
        default:
            return value
        }
    }

    private static func sentenceFragment(for value: String?) -> String? {
        guard let value = normalizedSignalLabel(value) ?? cleanDisplayValue(value) else { return nil }

        switch value.lowercased() {
        case "ask questions":
            return "questions"
        case "trust instincts":
            return "trust"
        case "being seen":
            return "being seen"
        case "quiet confidence":
            return "confidence"
        case "choose growth":
            return "growth"
        case "build momentum":
            return "momentum"
        default:
            return value.lowercased()
        }
    }

    private static func threadPhrase(for fragment: String) -> String {
        switch fragment.lowercased() {
        case "questions":
            return "questioning before action"
        case "trust":
            return "trusting your read"
        case "confidence":
            return "quiet confidence"
        case "being seen":
            return "letting yourself be seen"
        case "growth":
            return "choosing growth"
        case "momentum":
            return "building momentum"
        default:
            return fragment
        }
    }

    private static func sentenceStart(for fragment: String) -> String {
        guard let first = fragment.first else { return fragment }
        return String(first).uppercased() + fragment.dropFirst()
    }

    private static func cleanDisplayValue(_ value: String?) -> String? {
        let cleaned = value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        guard let cleaned, !cleaned.isEmpty else { return nil }
        return cleaned
    }

    private static func dateRange(from reads: [SavedDailyReading]) -> String? {
        let dateKeys = reads
            .map(\.dateKey)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted()

        guard let first = dateKeys.first, let last = dateKeys.last else { return nil }
        return first == last ? first : "\(first) to \(last)"
    }
}

struct PatternIntelligenceAnswerReasoning: Equatable {
    enum ConfidenceLevel: String, Equatable {
        case early
        case moderate
        case strong
    }

    let primaryObservation: String
    let supportingEvidence: String
    let possibleInterpretation: String
    let todayConnection: String
    let surprisingContrast: String
    let blindSpot: String
    let confidenceLevel: ConfidenceLevel
    let recommendedWatch: String
    let personalizedQuestionSeeds: [String]

    static func make(from facts: PatternIntelligenceAnswerFacts) -> PatternIntelligenceAnswerReasoning {
        let primary = facts.primaryRecurringSignal ?? facts.todayLensSignal ?? "this pattern"
        let primarySubject = subjectPhrase(for: primary)
        let secondary = facts.secondarySignal ?? facts.recentDominantSignal
        let supportingEvidence: String
        if let count = facts.primaryRecurringCount, count > 1 {
            supportingEvidence = evidencePhrase(for: primary, subject: primarySubject, count: count)
        } else if let memoryCallback = facts.memoryCallback {
            supportingEvidence = memoryCallback
        } else {
            supportingEvidence = "\(sentenceStart(for: primarySubject)) is the clearest current signal."
        }

        let possibleInterpretation = interpretation(for: primary)
        let todayConnection = todayConnection(primary: primary, facts: facts)
        let surprisingContrast: String
        if let secondary {
            surprisingContrast = "\(primarySubject) and \(subjectPhrase(for: secondary)) are appearing together."
        } else {
            surprisingContrast = "\(primarySubject) is showing up through small repeated choices, not one dramatic moment."
        }

        let blindSpot = blindSpot(for: primary)
        let confidenceLevel: ConfidenceLevel
        if facts.savedLensCount >= 7, (facts.primaryRecurringCount ?? 0) >= 4 {
            confidenceLevel = .strong
        } else if facts.savedLensCount >= 5, (facts.primaryRecurringCount ?? 0) >= 2 {
            confidenceLevel = .moderate
        } else {
            confidenceLevel = .early
        }

        return PatternIntelligenceAnswerReasoning(
            primaryObservation: primaryObservation(for: primary, count: facts.primaryRecurringCount),
            supportingEvidence: supportingEvidence,
            possibleInterpretation: possibleInterpretation,
            todayConnection: todayConnection,
            surprisingContrast: surprisingContrast,
            blindSpot: blindSpot,
            confidenceLevel: confidenceLevel,
            recommendedWatch: recommendedWatch(for: primary),
            personalizedQuestionSeeds: personalizedQuestionSeeds(primary: primary, secondary: secondary)
        )
    }

    var promptSummary: String {
        [
            "Primary observation: \(primaryObservation)",
            "Supporting evidence: \(supportingEvidence)",
            "Possible interpretation: \(possibleInterpretation)",
            "Today connection: \(todayConnection)",
            "Surprising contrast: \(surprisingContrast)",
            "Blind spot: \(blindSpot)",
            "Confidence level: \(confidenceLevel.rawValue)",
            "Recommended watch: \(recommendedWatch)",
            "Personalized question seeds: \(personalizedQuestionSeeds.joined(separator: " | "))"
        ].joined(separator: "\n")
    }

    private static func primaryObservation(for primary: String, count: Int?) -> String {
        let primarySubject = subjectPhrase(for: primary)
        if primary.lowercased() == "questions" {
            return "Questions keep returning before action."
        }

        if let count, count > 1 {
            return "\(sentenceStart(for: primarySubject)) keeps returning across recent saved Lenses."
        }

        return "\(sentenceStart(for: primarySubject)) is becoming the clearest thread."
    }

    private static func interpretation(for primary: String) -> String {
        switch primary.lowercased() {
        case "questions":
            return "This is less about indecision and more about learning to pause before choosing."
        case "trust":
            return "This is less about certainty and more about acting before outside confirmation takes over."
        case "confidence":
            return "This is less about proving confidence and more about letting it become visible."
        case "being seen":
            return "This is less about attention and more about allowing the real signal to be noticed."
        case "growth":
            return "This is less about changing everything and more about choosing the next honest adjustment."
        case "momentum":
            return "This is less about speed and more about protecting forward motion once it starts."
        default:
            return "This looks less like a random repeat and more like a pattern asking for a clearer response."
        }
    }

    private static func todayConnection(primary: String, facts: PatternIntelligenceAnswerFacts) -> String {
        let today = facts.todayLensSignal ?? primary
        let primaryThread = threadPhrase(for: primary)
        let todayThread = threadPhrase(for: today)
        if today.caseInsensitiveCompare(primary) == .orderedSame {
            return "it reinforces \(primaryThread)"
        }

        return "it brings \(todayThread) into a recent thread shaped by \(primaryThread)"
    }

    private static func blindSpot(for primary: String) -> String {
        switch primary.lowercased() {
        case "questions":
            return "the moment a question changes the pace of the choice"
        case "trust":
            return "how quickly outside confirmation can become part of the choice"
        case "confidence":
            return "how often confidence is already present before it is announced"
        case "being seen":
            return "the difference between being noticed and making yourself clear"
        case "growth":
            return "the small adjustment that matters more than the big reinvention"
        case "momentum":
            return "the moment movement needs protection more than acceleration"
        default:
            return "the part of the pattern that happens before the visible choice"
        }
    }

    private static func recommendedWatch(for primary: String) -> String {
        switch primary.lowercased() {
        case "questions":
            return "the moment you start questioning before you act"
        case "trust":
            return "the moment you look for confirmation before trusting yourself"
        case "confidence":
            return "the moment quiet confidence is already present"
        case "being seen":
            return "the moment you choose whether to let yourself be seen"
        case "growth":
            return "the moment choosing growth asks for one concrete step"
        case "momentum":
            return "the moment building momentum needs protection"
        default:
            return "the moment this thread shows up before you react"
        }
    }

    private static func evidencePhrase(for primary: String, subject: String, count: Int) -> String {
        switch primary.lowercased() {
        case "questions":
            return "That pause before action appeared in \(count) recent saved Lenses."
        default:
            return "\(sentenceStart(for: subject)) appeared in \(count) recent saved Lenses."
        }
    }

    private static func personalizedQuestionSeeds(primary: String, secondary: String?) -> [String] {
        var seeds: [String] = []

        switch primary.lowercased() {
        case "questions":
            seeds.append("Why do questions keep showing up before action?")
        case "trust":
            seeds.append("What keeps pulling me back to trust?")
        case "confidence":
            seeds.append("Is confidence replacing hesitation?")
        default:
            seeds.append("Am I repeating this pattern or resolving it?")
        }

        if let secondary {
            seeds.append("How are \(threadPhrase(for: primary)) and \(threadPhrase(for: secondary)) connected?")
        }

        seeds.append("What changes when I notice this sooner?")
        return Array(seeds.prefix(3))
    }

    private static func subjectPhrase(for fragment: String) -> String {
        switch fragment.lowercased() {
        case "questions":
            return "pausing before action"
        case "trust":
            return "trusting yourself"
        case "confidence":
            return "quiet confidence"
        case "being seen":
            return "letting yourself be seen"
        case "growth":
            return "choosing growth"
        case "momentum":
            return "building momentum"
        default:
            return fragment
        }
    }

    private static func threadPhrase(for fragment: String) -> String {
        switch fragment.lowercased() {
        case "questions":
            return "questioning before action"
        case "trust":
            return "trusting yourself"
        case "confidence":
            return "quiet confidence"
        case "being seen":
            return "letting yourself be seen"
        case "growth":
            return "choosing growth"
        case "momentum":
            return "building momentum"
        default:
            return fragment
        }
    }

    private static func sentenceStart(for fragment: String) -> String {
        guard let first = fragment.first else { return fragment }
        return String(first).uppercased() + fragment.dropFirst()
    }
}

struct PatternIntelligenceGeneratedSummary: Equatable {
    let text: String
    let provider: PatternIntelligenceGenerationProviderKind
    let isFallback: Bool
    let privacyNote: String
}

enum PatternIntelligenceGenerationAvailability: Equatable {
    case available
    case unavailable(reason: String)
}

enum PatternIntelligenceGenerationError: Error, Equatable {
    case unavailable(String)
    case emptyResponse
}

protocol PatternIntelligenceGenerationProvider {
    var kind: PatternIntelligenceGenerationProviderKind { get }
    var availability: PatternIntelligenceGenerationAvailability { get }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary
}

final class PatternIntelligenceGenerationService {
    static let shared = PatternIntelligenceGenerationService()

    private let backendProvider: PatternIntelligenceGenerationProvider
    private let appleProvider: PatternIntelligenceGenerationProvider
    private let fallbackProvider: PatternIntelligenceGenerationProvider

    init(
        backendProvider: PatternIntelligenceGenerationProvider = PatternIntelligenceBackendAIProvider(),
        appleProvider: PatternIntelligenceGenerationProvider = PatternIntelligenceAppleFoundationModelsProvider(),
        fallbackProvider: PatternIntelligenceGenerationProvider = PatternIntelligenceFallbackGenerationProvider()
    ) {
        self.backendProvider = backendProvider
        self.appleProvider = appleProvider
        self.fallbackProvider = fallbackProvider
    }

    func availability(for preferredProvider: PatternIntelligenceGenerationProviderKind) -> PatternIntelligenceGenerationAvailability {
        provider(for: preferredProvider).availability
    }

    func generate(
        _ request: PatternIntelligenceGenerationRequest,
        preferredProvider: PatternIntelligenceGenerationProviderKind
    ) async -> PatternIntelligenceGeneratedSummary {
        let provider = provider(for: preferredProvider)

        if case .available = provider.availability,
           let generated = try? await provider.generate(request) {
            return generated
        }

        return await fallbackResult(for: request)
    }

    func generate(
        _ request: PatternIntelligenceGenerationRequest,
        preferredProviders: [PatternIntelligenceGenerationProviderKind]
    ) async -> PatternIntelligenceGeneratedSummary {
        for providerKind in preferredProviders where providerKind != .fallback {
            let provider = provider(for: providerKind)
            guard case .available = provider.availability else { continue }

            if let generated = try? await provider.generate(request) {
                return generated
            }
        }

        return await fallbackResult(for: request)
    }

    private func provider(for kind: PatternIntelligenceGenerationProviderKind) -> PatternIntelligenceGenerationProvider {
        switch kind {
        case .backendAI:
            return backendProvider
        case .appleFoundationModels:
            return appleProvider
        case .fallback:
            return fallbackProvider
        }
    }

    private func fallbackResult(for request: PatternIntelligenceGenerationRequest) async -> PatternIntelligenceGeneratedSummary {
        if let generated = try? await fallbackProvider.generate(request) {
            return generated
        }

        return PatternIntelligenceGeneratedSummary(
            text: "Your saved Lenses are still forming a clearer pattern.",
            provider: .fallback,
            isFallback: true,
            privacyNote: PatternIntelligencePrivacyNotes.fallback
        )
    }
}

private struct PatternIntelligenceBackendAIProvider: PatternIntelligenceGenerationProvider {
    let kind: PatternIntelligenceGenerationProviderKind = .backendAI

    var availability: PatternIntelligenceGenerationAvailability {
        .unavailable(reason: "Pattern Intelligence backend generation endpoint is not wired yet.")
    }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary {
        throw PatternIntelligenceGenerationError.unavailable("Pattern Intelligence backend generation endpoint is not wired yet.")
    }
}

private struct PatternIntelligenceFallbackGenerationProvider: PatternIntelligenceGenerationProvider {
    let kind: PatternIntelligenceGenerationProviderKind = .fallback

    var availability: PatternIntelligenceGenerationAvailability {
        .available
    }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary {
        PatternIntelligenceGeneratedSummary(
            text: fallbackText(for: request),
            provider: .fallback,
            isFallback: true,
            privacyNote: PatternIntelligencePrivacyNotes.fallback
        )
    }

    private func fallbackText(for request: PatternIntelligenceGenerationRequest) -> String {
        switch request.task {
        case .earlyPatternSummary:
            return request.preview.earlyInsight
                ?? request.preview.earlyPatternNarrative
                ?? "Your saved Lenses are beginning to point toward a pattern."
        case .patternShiftSummary:
            return request.preview.patternShift
                ?? request.preview.patternShiftNarrative
                ?? "Looking across your recent saves, there’s a subtle change in direction."
        case .suggestedQuestionAnswerDraft(let question):
            let facts = request.answerFacts ?? PatternIntelligenceAnswerFacts.make(
                questionID: "guided-question",
                questionText: question,
                preview: request.preview,
                savedReads: request.savedReads
            )
            let reasoning = request.answerReasoning ?? PatternIntelligenceAnswerReasoning.make(from: facts)
            let cleanQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanQuestion.isEmpty {
                return "Your saved Lenses suggest a pattern is starting to come into focus."
            }

            return fallbackAnswer(from: facts, reasoning: reasoning)
        }
    }

    private func fallbackAnswer(
        from facts: PatternIntelligenceAnswerFacts,
        reasoning: PatternIntelligenceAnswerReasoning
    ) -> String {
        let primary = facts.primaryRecurringSignal ?? facts.todayLensSignal ?? "this pattern"
        let primarySubject = subjectPhrase(for: primary)
        let secondary = facts.secondarySignal ?? facts.recentDominantSignal

        switch facts.questionID {
        case "why-repeat":
            return "What keeps returning is this: \(withoutTerminalPunctuation(reasoning.primaryObservation)). \(withoutTerminalPunctuation(reasoning.supportingEvidence)). \(reasoning.possibleInterpretation)"
        case "week-change":
            if let earlier = facts.earlierDominantSignal,
               let recent = facts.recentDominantSignal,
               earlier.caseInsensitiveCompare(recent) != .orderedSame {
                return "Earlier Lenses leaned toward \(subjectPhrase(for: earlier)); recent ones point more toward \(subjectPhrase(for: recent)). That gives your pattern a different shape this week."
            }

            return "This week, \(primarySubject) became easier to see. \(withoutTerminalPunctuation(reasoning.supportingEvidence)). \(reasoning.possibleInterpretation)"
        case "tomorrow-watch":
            return "Watch for \(reasoning.recommendedWatch). That is where this pattern becomes easiest to notice tomorrow."
        case "surprise":
            if secondary != nil {
                return "The surprising part is \(withoutTerminalPunctuation(reasoning.surprisingContrast)). That pairing gives the pattern more depth than a single theme would."
            }

            return "The surprising part is \(withoutTerminalPunctuation(reasoning.surprisingContrast)). It looks less like a dramatic shift and more like a steady pattern becoming easier to name."
        case "overlooking":
            return "You may be focused on the choice itself, but the easier-to-miss part is \(reasoning.blindSpot). \(reasoning.possibleInterpretation)"
        case "today-fit":
            return "Today fits because \(withoutTerminalPunctuation(reasoning.todayConnection)). It looks like another angle on the pattern your saved Lenses have already been building."
        default:
            return "Your saved Lenses suggest \(primarySubject) is one of the clearer threads in the pattern so far."
        }
    }

    private func subjectPhrase(for fragment: String) -> String {
        switch fragment.lowercased() {
        case "questions":
            return "pausing before action"
        case "trust":
            return "trusting yourself"
        case "confidence":
            return "quiet confidence"
        case "growth":
            return "choosing growth"
        case "momentum":
            return "building momentum"
        case "being seen":
            return "letting yourself be seen"
        default:
            return fragment
        }
    }

    private func withoutTerminalPunctuation(_ value: String) -> String {
        value.trimmingCharacters(in: CharacterSet(charactersIn: ".!?").union(.whitespacesAndNewlines))
    }
}

private enum PatternIntelligencePrivacyNotes {
    static let appleFoundationModels = "Runs locally through Apple Foundation Models when the system model is available. Saved Lens snippets stay on device for this provider."
    static let backendAI = "Uses the existing backend AI path when a Pattern Intelligence endpoint is explicitly wired."
    static let fallback = "Uses deterministic on-device fallback copy. No model request is made."
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
private struct PatternIntelligenceAppleFoundationModelsProviderAvailable: PatternIntelligenceGenerationProvider {
    let kind: PatternIntelligenceGenerationProviderKind = .appleFoundationModels

    private let model = SystemLanguageModel.default

    var availability: PatternIntelligenceGenerationAvailability {
        switch model.availability {
        case .available:
            return .available
        case .unavailable(.deviceNotEligible):
            return .unavailable(reason: "Device is not eligible for Apple Intelligence.")
        case .unavailable(.appleIntelligenceNotEnabled):
            return .unavailable(reason: "Apple Intelligence is not enabled.")
        case .unavailable(.modelNotReady):
            return .unavailable(reason: "Apple Foundation Models are not ready yet.")
        @unknown default:
            return .unavailable(reason: "Apple Foundation Models are unavailable.")
        }
    }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary {
        guard case .available = availability else {
            throw PatternIntelligenceGenerationError.unavailable("Apple Foundation Models are unavailable.")
        }

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You are the language layer for Zodian Pattern Intelligence.
            The deterministic analysis has already been done; explain only the provided facts.
            Do not discover new patterns, invent events, diagnose, predict with certainty, mention scores, or use percentages.
            Do not say "you always."
            Write concise, grounded, premium prose in 2 to 4 short sentences.
            Be more direct than generic horoscope copy. Use varied openings such as "What keeps returning is", "The stronger signal is", "This is less about", "Your saved Lenses suggest", or "Today fits because".
            Do not overuse "may", "might", "perhaps", or "suggests".
            Avoid horoscope-generic phrasing and avoid raw field names.
            """
        )
        let response = try await session.respond(
            to: prompt(for: request),
            options: GenerationOptions(sampling: .greedy, temperature: 0.4, maximumResponseTokens: 110)
        )
        let text = normalized(response.content)
        guard !text.isEmpty else { throw PatternIntelligenceGenerationError.emptyResponse }

        return PatternIntelligenceGeneratedSummary(
            text: text,
            provider: .appleFoundationModels,
            isFallback: false,
            privacyNote: PatternIntelligencePrivacyNotes.appleFoundationModels
        )
    }

    private func prompt(for request: PatternIntelligenceGenerationRequest) -> String {
        if case .suggestedQuestionAnswerDraft(let question) = request.task {
            let facts = request.answerFacts ?? PatternIntelligenceAnswerFacts.make(
                questionID: "guided-question",
                questionText: question,
                preview: request.preview,
                savedReads: request.savedReads
            )
            let reasoning = request.answerReasoning ?? PatternIntelligenceAnswerReasoning.make(from: facts)

            return """
            Task: Turn the structured facts and deterministic reasoning below into a short guided Pattern Intelligence answer.
            Answer strategy: \(answerStrategy(for: facts.questionID))
            Use the reasoning as the interpretation. Do not invent a new interpretation.

            Structured facts:
            \(facts.promptSummary)

            Deterministic reasoning:
            \(reasoning.promptSummary)
            """
        }

        return """
        Task: \(taskInstruction(for: request.task))

        Saved Lens count: \(request.preview.savedCount)
        Strongest signal: \(request.preview.topSignal ?? "none yet")
        Signals: \(request.preview.topSignals.prefix(4).joined(separator: ", "))
        Current early summary: \(request.preview.earlyInsight ?? request.preview.earlyPatternNarrative ?? "none")
        Current shift summary: \(request.preview.patternShift ?? request.preview.patternShiftNarrative ?? "none")

        Grounded observations:
        \(PatternIntelligenceAnswerFacts.make(
            questionID: "summary",
            questionText: "Summarize the pattern.",
            preview: request.preview,
            savedReads: request.savedReads
        ).observations.joined(separator: "\n"))
        """
    }

    private func answerStrategy(for questionID: String) -> String {
        switch questionID {
        case "why-repeat":
            return "Explain recurrence. Use a grounded count if available."
        case "week-change":
            return "Explain movement from earlier dominant signal to recent dominant signal."
        case "tomorrow-watch":
            return "Give one lightweight watch prompt grounded in the primary signal."
        case "surprise":
            return "Name a contrast or unexpected pairing between primary and secondary signals."
        case "overlooking":
            return "Offer a gentle blind spot without therapy or diagnosis language."
        case "today-fit":
            return "Connect today's Lens signal to recent saved history."
        default:
            return "Answer the question using only the structured facts."
        }
    }

    private func taskInstruction(for task: PatternIntelligenceGenerationTask) -> String {
        switch task {
        case .earlyPatternSummary:
            return "Write an early pattern summary in one sentence."
        case .patternShiftSummary:
            return "Write a pattern shift summary in one sentence."
        case .suggestedQuestionAnswerDraft(let question):
            return "Draft a short answer to this user question: \(question)"
        }
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
#endif

private struct PatternIntelligenceAppleFoundationModelsProvider: PatternIntelligenceGenerationProvider {
    let kind: PatternIntelligenceGenerationProviderKind = .appleFoundationModels

    var availability: PatternIntelligenceGenerationAvailability {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return PatternIntelligenceAppleFoundationModelsProviderAvailable().availability
        }
        #endif

        return .unavailable(reason: "Apple Foundation Models require iOS 26 or a supported platform.")
    }

    func generate(_ request: PatternIntelligenceGenerationRequest) async throws -> PatternIntelligenceGeneratedSummary {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return try await PatternIntelligenceAppleFoundationModelsProviderAvailable().generate(request)
        }
        #endif

        throw PatternIntelligenceGenerationError.unavailable("Apple Foundation Models require iOS 26 or a supported platform.")
    }
}
