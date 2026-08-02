import Foundation

enum PatternIntelligencePreviewBuilder {
    static func makePreview(from savedReads: [SavedDailyReading]) -> PatternIntelligencePreview {
        let sortedReads = savedReads.sorted { $0.createdAt > $1.createdAt }
        let savedCount = sortedReads.count

        switch savedCount {
        case 0:
            return PatternIntelligencePreview(
                state: .empty,
                savedCount: 0,
                sentence: headline(for: savedCount),
                supportingLine: nil,
                statusLabel: nil,
                topSignal: nil,
                topSignals: [],
                discoveries: [],
                earlyInsight: nil,
                patternShift: nil,
                suggestedQuestions: [],
                signature: signature(from: sortedReads, scores: .empty),
                scores: .empty
            )
        case 1:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let discoveries = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 1,
                allowScoreFallback: true
            )
            let primary = discoveries.first
            return PatternIntelligencePreview(
                state: .building,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: primary.map { observationLine(for: $0, savedCount: savedCount) },
                statusLabel: primary == nil ? nil : "Observation",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: nil,
                patternShift: nil,
                suggestedQuestions: [],
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        case 2:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let discoveries = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 1,
                allowScoreFallback: true
            )
            let primary = discoveries.first
            return PatternIntelligencePreview(
                state: .building,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: "Save one more Lens to preview your first pattern.",
                statusLabel: primary == nil ? nil : "First signal",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: nil,
                patternShift: nil,
                suggestedQuestions: [],
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        case 3...4:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let discoveries = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 1,
                allowScoreFallback: true
            )
            let primary = discoveries.first
            return PatternIntelligencePreview(
                state: .ready,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: "A few saved Lenses are starting to point in the same direction.",
                statusLabel: "Preview",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: earlyInsight(from: sortedReads, discoveries: discoveries),
                patternShift: nil,
                suggestedQuestions: [],
                memoryCallback: memoryCallback(from: sortedReads, discoveries: discoveries),
                earlyPatternNarrative: earlyPatternNarrative(from: sortedReads, discoveries: discoveries),
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        case 5...6:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let recurring = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 2,
                allowScoreFallback: true
            )
            let discoveries = recurring.isEmpty
                ? signalDiscoveries(
                    from: sortedReads,
                    scores: scores,
                    limit: 3,
                    minimumRecurrence: 1,
                    allowScoreFallback: true
                )
                : recurring
            let primary = discoveries.first
            return PatternIntelligencePreview(
                state: .ready,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: primary.map { "\(sentenceSubject(for: $0.label)) is becoming easier to see." },
                statusLabel: "Growing",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: earlyInsight(from: sortedReads, discoveries: discoveries),
                patternShift: patternShift(from: sortedReads),
                suggestedQuestions: [],
                memoryCallback: memoryCallback(from: sortedReads, discoveries: discoveries),
                earlyPatternNarrative: earlyPatternNarrative(from: sortedReads, discoveries: discoveries),
                patternShiftNarrative: patternShiftNarrative(from: sortedReads),
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        default:
            return conservativeDiscoveryPreview(from: sortedReads, savedCount: savedCount)
        }
    }

    private static func conservativeDiscoveryPreview(
        from sortedReads: [SavedDailyReading],
        savedCount: Int
    ) -> PatternIntelligencePreview {
        switch savedCount {
        case 3...14:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let recurring = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 2,
                allowScoreFallback: true
            )
            let discoveries = recurring.isEmpty
                ? signalDiscoveries(
                    from: sortedReads,
                    scores: scores,
                    limit: 3,
                    minimumRecurrence: 1,
                    allowScoreFallback: true
                )
                : recurring
            let primary = discoveries.first
            let hasRecurringSignal = primary.map { $0.recurrenceCount >= 2 } ?? false
            return PatternIntelligencePreview(
                state: .ready,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: hasRecurringSignal
                    ? "Seen across your saved Lenses."
                    : primary.map { observationLine(for: $0, savedCount: savedCount) },
                statusLabel: hasRecurringSignal ? "Growing" : "Observation",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: earlyInsight(from: sortedReads, discoveries: discoveries),
                patternShift: savedCount >= 5 ? patternShift(from: sortedReads) : nil,
                suggestedQuestions: savedCount >= 7 ? suggestedQuestions : [],
                memoryCallback: memoryCallback(from: sortedReads, discoveries: discoveries),
                earlyPatternNarrative: earlyPatternNarrative(from: sortedReads, discoveries: discoveries),
                patternShiftNarrative: savedCount >= 5 ? patternShiftNarrative(from: sortedReads) : nil,
                askReadinessCopy: savedCount >= 7 ? askReadinessCopy : nil,
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        default:
            let scores = storedScores(from: sortedReads) ?? provisionalScores(from: sortedReads)
            let recurring = signalDiscoveries(
                from: sortedReads,
                scores: scores,
                limit: 3,
                minimumRecurrence: 2,
                allowScoreFallback: true
            )
            let discoveries = recurring.isEmpty
                ? signalDiscoveries(
                    from: sortedReads,
                    scores: scores,
                    limit: 3,
                    minimumRecurrence: 1,
                    allowScoreFallback: true
                )
                : recurring
            let primary = discoveries.first
            let hasRecurringSignal = primary.map { $0.recurrenceCount >= 2 } ?? false
            return PatternIntelligencePreview(
                state: .ready,
                savedCount: savedCount,
                sentence: headline(for: savedCount),
                supportingLine: hasRecurringSignal
                    ? "Part of your emerging pattern."
                    : primary.map { observationLine(for: $0, savedCount: savedCount) },
                statusLabel: hasRecurringSignal ? "Recurring" : "Observation",
                topSignal: primary?.label,
                topSignals: discoveries.map(\.label),
                discoveries: discoveries,
                earlyInsight: earlyInsight(from: sortedReads, discoveries: discoveries),
                patternShift: patternShift(from: sortedReads),
                suggestedQuestions: suggestedQuestions,
                memoryCallback: memoryCallback(from: sortedReads, discoveries: discoveries),
                earlyPatternNarrative: earlyPatternNarrative(from: sortedReads, discoveries: discoveries),
                patternShiftNarrative: patternShiftNarrative(from: sortedReads),
                askReadinessCopy: askReadinessCopy,
                signature: signature(from: sortedReads, scores: scores),
                scores: scores
            )
        }
    }

    private static func storedScores(from reads: [SavedDailyReading]) -> PatternIntelligenceSignalScores? {
        let values = reads.compactMap { read -> PatternIntelligenceSignalScores? in
            guard let confidence = read.patternConfidence,
                  let reflection = read.patternReflection,
                  let connection = read.patternConnection,
                  let growth = read.patternGrowth,
                  let momentum = read.patternMomentum else {
                return nil
            }

            return PatternIntelligenceSignalScores(
                confidence: clamped(confidence),
                reflection: clamped(reflection),
                connection: clamped(connection),
                growth: clamped(growth),
                momentum: clamped(momentum)
            )
        }

        guard !values.isEmpty else { return nil }

        return PatternIntelligenceSignalScores(
            confidence: average(values.map(\.confidence)),
            reflection: average(values.map(\.reflection)),
            connection: average(values.map(\.connection)),
            growth: average(values.map(\.growth)),
            momentum: average(values.map(\.momentum))
        )
    }

    // TODO: Replace this local heuristic with persisted AI-generated PatternIntelligenceScore records.
    private static func provisionalScores(from reads: [SavedDailyReading]) -> PatternIntelligenceSignalScores {
        guard !reads.isEmpty else { return .empty }

        let recentReads = Array(reads.prefix(8))
        let detectedThemeLabels = recentReads.flatMap { themeLabels(from: $0) }
        let repeatedThemeCount = Dictionary(grouping: detectedThemeLabels, by: { $0.lowercased() })
            .values
            .filter { $0.count > 1 }
            .count

        let reflectionHints = recentReads.filter { read in
            containsAny(
                [
                    read.reflectionTag,
                    read.reflectionNote,
                    read.insight,
                    read.focus,
                    read.summary
                ],
                terms: ["reflection", "notice", "observe", "truth", "clarity", "attention", "name"]
            )
        }.count

        let connectionHints = recentReads.filter { read in
            containsAny(
                [
                    read.theme,
                    read.themeKey,
                    read.identity,
                    read.love,
                    read.work,
                    read.opportunity
                ],
                terms: ["connection", "belonging", "trust", "communication", "attachment", "love", "relationship"]
            )
        }.count

        let growthHints = recentReads.filter { read in
            containsAny(
                [
                    read.growth,
                    read.affirmation,
                    read.opportunity,
                    read.focus
                ],
                terms: ["growth", "momentum", "change", "move", "practice", "choice", "action"]
            )
        }.count

        let confidenceBase = min(1, 0.28 + (Double(reads.count) * 0.12) + (Double(repeatedThemeCount) * 0.14))
        let reflectionBase = min(1, 0.24 + normalized(reflectionHints, total: recentReads.count) * 0.58)
        let connectionBase = min(1, 0.22 + normalized(connectionHints, total: recentReads.count) * 0.58)
        let growthBase = min(1, 0.20 + normalized(growthHints, total: recentReads.count) * 0.60)
        let momentumBase = min(1, 0.22 + recentMomentumScore(from: recentReads) * 0.58)

        return PatternIntelligenceSignalScores(
            confidence: confidenceBase,
            reflection: reflectionBase,
            connection: connectionBase,
            growth: growthBase,
            momentum: momentumBase
        )
    }

    private static func topSignal(from reads: [SavedDailyReading]) -> String? {
        if let storedSignal = reads.compactMap({ normalizedSignalLabel($0.patternPrimarySignal) }).first {
            return storedSignal
        }

        if let storedTag = reads.flatMap({ $0.patternThemeTags ?? [] }).compactMap({ normalizedSignalLabel($0) }).first {
            return storedTag
        }

        let labels = reads.flatMap { themeLabels(from: $0) }
        let grouped = Dictionary(grouping: labels, by: { $0 })
        return grouped
            .sorted {
                if $0.value.count == $1.value.count {
                    return $0.key < $1.key
                }

                return $0.value.count > $1.value.count
            }
            .first?
            .key
    }

    private static func topSignals(
        from reads: [SavedDailyReading],
        scores: PatternIntelligenceSignalScores,
        limit: Int
    ) -> [String] {
        signalDiscoveries(
            from: reads,
            scores: scores,
            limit: limit,
            minimumRecurrence: 1,
            allowScoreFallback: true
        )
        .map(\.label)
    }

    private static func signalDiscoveries(
        from reads: [SavedDailyReading],
        scores: PatternIntelligenceSignalScores,
        limit: Int,
        minimumRecurrence: Int,
        allowScoreFallback: Bool
    ) -> [PatternIntelligenceSignalDiscovery] {
        guard limit > 0 else { return [] }

        let recentReads = Array(reads.prefix(min(8, max(1, reads.count))))
        let total = recentReads.count
        var counts: [String: Int] = [:]
        var firstSeen: [String: Int] = [:]

        for (index, read) in recentReads.enumerated() {
            let labels = signalLabels(from: read)
            for label in labels {
                counts[label, default: 0] += 1
                firstSeen[label] = min(firstSeen[label] ?? index, index)
            }
        }

        let exactDiscoveries = counts.map { label, count in
            PatternIntelligenceSignalDiscovery(
                label: label,
                recurrenceCount: count,
                sampleSize: total,
                isApproximate: false
            )
        }
        .sorted {
            if $0.recurrenceCount == $1.recurrenceCount {
                return (firstSeen[$0.label] ?? Int.max) < (firstSeen[$1.label] ?? Int.max)
            }

            return $0.recurrenceCount > $1.recurrenceCount
        }

        let recurringDiscoveries = exactDiscoveries.filter { $0.recurrenceCount >= minimumRecurrence }
        if !recurringDiscoveries.isEmpty {
            return Array(recurringDiscoveries.prefix(limit))
        }

        guard allowScoreFallback, counts.isEmpty else { return [] }

        var fallbackDiscoveries: [PatternIntelligenceSignalDiscovery] = []
        for scoredSignal in scoredSignalValues(scores) where fallbackDiscoveries.count < limit {
            let count = approximateCount(for: scoredSignal.value, total: total)
            guard count >= minimumRecurrence,
                  !fallbackDiscoveries.contains(where: { $0.label.caseInsensitiveCompare(scoredSignal.label) == .orderedSame }) else {
                continue
            }

            fallbackDiscoveries.append(
                PatternIntelligenceSignalDiscovery(
                    label: scoredSignal.label,
                    recurrenceCount: count,
                    sampleSize: total,
                    isApproximate: true
                )
            )
        }

        return fallbackDiscoveries
    }

    private static func signalLabels(from read: SavedDailyReading) -> [String] {
        var labels: [String] = []

        for signal in [read.patternPrimarySignal, read.patternSecondarySignal] {
            appendUnique(normalizedSignalLabel(signal), to: &labels, limit: 6)
        }

        for tag in read.patternThemeTags ?? [] {
            appendUnique(normalizedSignalLabel(tag), to: &labels, limit: 6)
        }

        for theme in themeLabels(from: read) {
            appendUnique(normalizedSignalLabel(theme), to: &labels, limit: 6)
        }

        return labels
    }

    private static func scoredSignalLabels(_ scores: PatternIntelligenceSignalScores) -> [String] {
        scoredSignalValues(scores).map(\.label)
    }

    private static func scoredSignalValues(_ scores: PatternIntelligenceSignalScores) -> [(label: String, value: Double)] {
        [
            ("Quiet Confidence", scores.confidence),
            ("Self Reflect", scores.reflection),
            ("Seek Connection", scores.connection),
            ("Choose Growth", scores.growth),
            ("Build Momentum", scores.momentum)
        ]
        .sorted {
            if $0.1 == $1.1 {
                return $0.0 < $1.0
            }

            return $0.1 > $1.1
        }
        .map { (label: $0.0, value: $0.1) }
    }

    private static func approximateCount(for value: Double, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return max(1, min(total, Int((clamped(value) * Double(total)).rounded())))
    }

    private static func observationLine(
        for discovery: PatternIntelligenceSignalDiscovery,
        savedCount: Int
    ) -> String {
        let phrase = sentenceFragment(for: discovery.label)
        if savedCount <= 1 {
            return "This first Lens points toward \(phrase)."
        }

        return "Your saved Lenses are starting to point toward \(phrase)."
    }

    private static var suggestedQuestions: [String] {
        [
            "Why does this keep showing up?",
            "What changed this week?",
            "What should I watch tomorrow?"
        ]
    }

    private static func earlyInsight(
        from reads: [SavedDailyReading],
        discoveries: [PatternIntelligenceSignalDiscovery]
    ) -> String? {
        guard reads.count >= 3 else { return nil }

        if let recurring = discoveries.first(where: { $0.recurrenceCount >= 2 }) {
            return earlyPatternInsight(for: recurring.label)
        }

        if let signal = discoveries.first?.label ?? topSignal(from: reads) {
            return earlyPatternInsight(for: signal)
        }

        return "Your first pattern is beginning to form."
    }

    private static func earlyPatternNarrative(
        from reads: [SavedDailyReading],
        discoveries: [PatternIntelligenceSignalDiscovery]
    ) -> String? {
        guard reads.count >= 3 else { return nil }

        if let recurring = discoveries.first(where: { $0.recurrenceCount >= 2 }) {
            return supportLine(for: recurring)
        }

        if discoveries.first?.label ?? topSignal(from: reads) != nil {
            return "It isn’t tied to one day. It keeps resurfacing across different situations."
        }

        return "Across your saved Lenses, a first pattern is beginning to take shape."
    }

    private static func memoryCallback(
        from reads: [SavedDailyReading],
        discoveries: [PatternIntelligenceSignalDiscovery]
    ) -> String? {
        guard reads.count >= 3,
              let recurring = discoveries.first(where: { !$0.isApproximate && $0.recurrenceCount >= 2 }) else {
            return nil
        }

        let phrase = sentenceFragment(for: recurring.label)
        if recurring.recurrenceCount >= 3 {
            return "This is the \(ordinal(recurring.recurrenceCount)) time \(phrase) \(appearanceVerb(for: recurring.label)) appeared across your saved Lenses."
        }

        return "This theme appeared earlier, then returned in another saved Lens."
    }

    private static func patternShift(from reads: [SavedDailyReading]) -> String? {
        patternShiftInsight(from: reads)?.headline
    }

    private static func headline(for savedCount: Int) -> String {
        switch savedCount {
        case 0:
            return "Start saving Lenses to reveal your Pattern Intelligence."
        case 1...2:
            return "One thing we've noticed..."
        case 3...4:
            return "A pattern is starting to emerge."
        case 5...6:
            return "We're starting to connect the dots."
        default:
            return "Your strongest pattern so far."
        }
    }

    private static func patternShiftNarrative(from reads: [SavedDailyReading]) -> String? {
        patternShiftInsight(from: reads)?.narrative
    }

    private struct PatternShiftInsight {
        let headline: String
        let narrative: String
    }

    private static func patternShiftInsight(from reads: [SavedDailyReading]) -> PatternShiftInsight? {
        guard reads.count >= 5 else { return nil }

        let recentCount = max(2, (reads.count + 1) / 2)
        let recentReads = Array(reads.prefix(recentCount))
        let olderReads = Array(reads.dropFirst(recentCount))

        guard !recentReads.isEmpty, !olderReads.isEmpty else {
            return PatternShiftInsight(
                headline: "Your pattern is still forming.",
                narrative: "Looking across your recent saves, there’s a subtle change in direction."
            )
        }

        let recentCounts = labelCounts(from: recentReads)
        let olderCounts = labelCounts(from: olderReads)
        let earlierTheme = dominantLabel(from: olderCounts)
        let recentTheme = dominantLabel(from: recentCounts)

        let rising = recentCounts
            .map { label, recentCount in
                (
                    label: label,
                    recentCount: recentCount,
                    olderCount: olderCounts[label] ?? 0,
                    delta: recentCount - (olderCounts[label] ?? 0)
                )
            }
            .filter { $0.recentCount >= 2 || $0.delta > 0 }
            .sorted {
                if $0.delta == $1.delta {
                    if $0.recentCount == $1.recentCount {
                        return $0.label < $1.label
                    }

                    return $0.recentCount > $1.recentCount
                }

                return $0.delta > $1.delta
            }
            .first

        guard let rising, rising.delta > 0 || rising.recentCount >= 2 else {
            return PatternShiftInsight(
                headline: "Your pattern is still forming.",
                narrative: "Earlier reflections leaned one way. Your most recent ones suggest something new is emerging."
            )
        }

        let headline: String
        let narrative: String
        if let earlierTheme,
           let recentTheme,
           earlierTheme.caseInsensitiveCompare(recentTheme) != .orderedSame {
            headline = shiftLine(from: earlierTheme, to: recentTheme)
            narrative = "Earlier Lenses leaned toward \(shiftEvidencePhrase(for: earlierTheme)). Recent ones point more toward \(shiftEvidencePhrase(for: recentTheme))."
        } else {
            headline = shiftMovementLine(for: rising.label)
            narrative = shiftSupportLine(olderCount: rising.olderCount, recentCount: rising.recentCount)
        }

        return PatternShiftInsight(headline: headline, narrative: narrative)
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

    private static func dominantLabel(from counts: [String: Int]) -> String? {
        counts
            .sorted {
                if $0.value == $1.value {
                    return $0.key < $1.key
                }

                return $0.value > $1.value
            }
            .first?
            .key
    }

    private static func shiftLine(from earlier: String, to recent: String) -> String {
        switch (earlier.lowercased(), recent.lowercased()) {
        case ("ask questions", "trust instincts"):
            return "Questions are still present, but trust is becoming easier to see."
        case ("trust instincts", "ask questions"):
            return "Trust is becoming more deliberate, not less certain."
        case ("ask questions", "quiet confidence"):
            return "You’re moving from questioning the moment to carrying more quiet confidence."
        case ("quiet confidence", "ask questions"):
            return "Confidence is becoming more deliberate, not less certain."
        case ("ask questions", "being seen"), ("ask questions", "seen"):
            return "You’re moving from questioning the moment to letting yourself be seen."
        case ("being seen", "ask questions"), ("seen", "ask questions"):
            return "Being seen is becoming more deliberate, not less certain."
        case ("being seen", "quiet confidence"), ("seen", "quiet confidence"):
            return "Being seen is becoming less about proving yourself and more about owning the moment."
        case ("quiet confidence", "being seen"), ("quiet confidence", "seen"):
            return "Confidence is becoming visible without needing to announce itself."
        case ("choose growth", "build momentum"):
            return "Growth is starting to turn into momentum."
        case ("build momentum", "choose growth"):
            return "Momentum is asking for a more intentional kind of growth."
        case ("ask questions", "self reflect"):
            return "You’re moving from asking the question to pausing before you commit."
        case ("build momentum", "self reflect"):
            return "You’re moving from acting quickly to pausing before you commit."
        default:
            return "You’re moving from \(shiftEvidencePhrase(for: earlier)) toward \(shiftEvidencePhrase(for: recent))."
        }
    }

    private static func shiftMovementLine(for label: String) -> String {
        switch label.lowercased() {
        case "ask questions":
            return "You’re beginning to pause where you once reacted immediately."
        case "trust instincts":
            return "Trust is starting to arrive before outside proof."
        case "quiet confidence":
            return "Confidence is becoming quieter, and more available."
        case "being seen", "seen":
            return "Visibility is becoming possible without as much overexplaining."
        case "choose growth":
            return "Small discomfort is starting to turn into growth."
        case "build momentum":
            return "Small choices are starting to turn into movement."
        case "self reflect":
            return "Reflection is starting to arrive before the decision."
        case "seek connection":
            return "Connection is starting to become part of the choice."
        case "find clarity":
            return "Clarity is starting to arrive before reaction takes over."
        case "notice details":
            return "The details are starting to slow the reaction down."
        default:
            return "Something that was subtle before is becoming easier to act on."
        }
    }

    private static func earlyPatternInsight(for label: String) -> String {
        switch label.lowercased() {
        case "ask questions":
            return "You’re becoming quicker to pause before committing."
        case "trust instincts":
            return "You’re starting to trust your read before looking for proof."
        case "quiet confidence":
            return "Confidence is showing up more quietly than dramatically."
        case "being seen", "seen":
            return "You’re letting yourself be visible without overexplaining it."
        case "choose growth":
            return "You’re choosing growth in small, repeatable ways."
        case "build momentum":
            return "Small choices are starting to create forward motion."
        case "self reflect":
            return "You’re making more room to notice what is really happening."
        case "seek connection":
            return "You’re letting connection matter without losing yourself."
        case "find clarity":
            return "You’re choosing clarity before reacting."
        case "notice details":
            return "You’re noticing details before deciding what they mean."
        default:
            return "You’re starting to notice how \(sentenceFragment(for: label)) shapes your choices."
        }
    }

    private static func supportLine(for discovery: PatternIntelligenceSignalDiscovery) -> String {
        if discovery.recurrenceCount >= 3 {
            return "Different days. Different situations. The same behavior keeps finding its way back."
        }

        return "It isn’t tied to one day. It keeps resurfacing across different situations."
    }

    private static func shiftSupportLine(olderCount: Int, recentCount: Int) -> String {
        if olderCount == 0 {
            return "This wasn’t visible at first, but your more recent Lenses are beginning to tell a different story."
        }

        if recentCount >= 2 {
            return "Looking across your recent saves, there’s a subtle change in direction."
        }

        return "Earlier reflections leaned one way. Your most recent ones suggest something new is emerging."
    }

    private static func shiftEvidencePhrase(for label: String) -> String {
        switch label.lowercased() {
        case "ask questions":
            return "questioning before action"
        case "trust instincts":
            return "trusting your read"
        case "quiet confidence":
            return "quiet confidence"
        case "being seen", "seen":
            return "letting yourself be seen"
        case "choose growth":
            return "choosing growth"
        case "build momentum":
            return "building momentum"
        case "self reflect":
            return "pausing before choice"
        case "seek connection":
            return "letting connection matter"
        case "find clarity":
            return "choosing clarity"
        case "notice details":
            return "noticing the details"
        default:
            return sentenceFragment(for: label)
        }
    }

    private static var askReadinessCopy: String {
        "Your saved Lenses now contain enough history to begin asking deeper questions about recurring patterns."
    }

    private static func discoverySentence(for label: String?, savedCount: Int) -> String {
        guard let label else { return "One theme keeps returning." }

        switch label.lowercased() {
        case "ask questions":
            return "Questions keep coming up."
        case "trust instincts":
            return savedCount >= 15 ? "Trust keeps returning." : "Trust has surfaced more than once."
        case "quiet confidence":
            return "Confidence is becoming easier to see."
        case "being seen":
            return "Being seen keeps showing up."
        case "choose growth":
            return "Growth keeps showing up."
        case "build momentum":
            return "Momentum is becoming easier to see."
        case "notice details":
            return "Details keep coming up."
        default:
            return savedCount >= 15
                ? "\(sentenceSubject(for: label)) keeps returning."
                : "\(sentenceSubject(for: label)) has surfaced more than once."
        }
    }

    private static func sentenceSubject(for label: String?) -> String {
        guard let label else { return "This" }

        switch label.lowercased() {
        case "trust instincts":
            return "Trusting your instincts"
        case "ask questions":
            return "Asking questions"
        case "quiet confidence":
            return "Quiet confidence"
        case "self reflect":
            return "Self-reflection"
        case "seek connection":
            return "Connection"
        case "build momentum":
            return "Momentum"
        case "find clarity":
            return "Clarity"
        case "notice details":
            return "Noticing details"
        case "notice patterns":
            return "Noticing patterns"
        case "hold boundaries":
            return "Holding boundaries"
        case "stay independent":
            return "Independence"
        case "choose growth":
            return "Growth"
        case "make joy":
            return "Joy"
        case "choose rest":
            return "Rest"
        case "seek balance":
            return "Balance"
        case "being seen":
            return "Being seen"
        case "seen":
            return "Being seen"
        case "practice patience":
            return "Patience"
        default:
            return label
        }
    }

    private static func sentenceFragment(for label: String) -> String {
        switch label.lowercased() {
        case "trust instincts":
            return "trust"
        case "ask questions":
            return "questions"
        case "quiet confidence":
            return "confidence"
        case "self reflect":
            return "self-reflection"
        case "seek connection":
            return "connection"
        case "build momentum":
            return "momentum"
        case "find clarity":
            return "clarity"
        case "notice details":
            return "details"
        case "notice patterns":
            return "patterns"
        case "hold boundaries":
            return "boundaries"
        case "stay independent":
            return "independence"
        case "choose growth":
            return "growth"
        case "make joy":
            return "joy"
        case "choose rest":
            return "rest"
        case "seek balance":
            return "balance"
        case "being seen":
            return "being seen"
        case "seen":
            return "being seen"
        case "practice patience":
            return "patience"
        default:
            return label.lowercased()
        }
    }

    private static func appearanceVerb(for label: String) -> String {
        switch label.lowercased() {
        case "ask questions", "notice details", "notice patterns":
            return "have"
        default:
            return "has"
        }
    }

    private static func humanThemePhrase(for label: String) -> String {
        switch label.lowercased() {
        case "trust instincts":
            return "trusting your instincts before looking for outside confirmation"
        case "ask questions":
            return "slowing down long enough to ask the better question"
        case "quiet confidence":
            return "trusting what you know without needing to prove it"
        case "being seen":
            return "letting yourself be visible without downplaying it"
        case "choose growth":
            return "choosing growth even when it asks for discomfort"
        case "build momentum":
            return "turning small choices into forward motion"
        case "notice details":
            return "noticing the details before deciding what they mean"
        case "find clarity":
            return "choosing clarity before reacting"
        case "self reflect":
            return "making room to notice what is really happening"
        case "seek connection":
            return "letting connection matter without losing yourself"
        default:
            return "\(sentenceFragment(for: label)) showing up across your saved Lenses"
        }
    }

    private static func ordinal(_ value: Int) -> String {
        let suffix: String
        let tens = value % 100
        if (11...13).contains(tens) {
            suffix = "th"
        } else {
            switch value % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default:
                suffix = "th"
            }
        }

        return "\(value)\(suffix)"
    }

    private static func appendUnique(_ label: String?, to labels: inout [String], limit: Int) {
        guard labels.count < limit,
              let label,
              !labels.contains(where: { $0.caseInsensitiveCompare(label) == .orderedSame }) else {
            return
        }

        labels.append(label)
    }

    private static func normalizedSignalLabel(_ value: String?) -> String? {
        guard let raw = value?.nilIfBlankForPatternIntelligence else { return nil }

        let curatedMatches: [(String, String)] = [
            ("curiosity", "Ask Questions"),
            ("question", "Ask Questions"),
            ("confidence", "Quiet Confidence"),
            ("recognition", "Being Seen"),
            ("seen", "Being Seen"),
            ("visible", "Being Seen"),
            ("visibility", "Being Seen"),
            ("reflection", "Self Reflect"),
            ("connection", "Seek Connection"),
            ("momentum", "Build Momentum"),
            ("trust", "Trust Instincts"),
            ("instinct", "Trust Instincts"),
            ("intuition", "Trust Instincts"),
            ("patience", "Practice Patience"),
            ("clarity", "Find Clarity"),
            ("observation", "Notice Details"),
            ("noticing", "Notice Details"),
            ("pattern", "Notice Patterns"),
            ("boundary", "Hold Boundaries"),
            ("independence", "Stay Independent"),
            ("growth", "Choose Growth"),
            ("joy", "Make Joy"),
            ("rest", "Choose Rest"),
            ("balance", "Seek Balance")
        ]

        let lowered = raw.lowercased()
        if let match = curatedMatches.first(where: { lowered.contains($0.0) }) {
            return match.1
        }

        return compactSignalLabel(from: raw)
    }

    private static func compactSignalLabel(from raw: String) -> String? {
        let separators = CharacterSet.alphanumerics.inverted
        let fillerWords: Set<String> = [
            "a", "an", "and", "are", "about", "being", "for", "from", "into", "of", "the", "to", "your"
        ]
        let words = raw
            .components(separatedBy: separators)
            .map { $0.lowercased() }
            .filter { !$0.isEmpty && !fillerWords.contains($0) }
            .prefix(3)

        guard !words.isEmpty else { return nil }

        let titleCased = words
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")

        if titleCased.count <= 18 {
            return titleCased
        }

        let shorter = words
            .prefix(2)
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")

        return shorter.isEmpty ? nil : shorter
    }

    private static func signature(
        from reads: [SavedDailyReading],
        scores: PatternIntelligenceSignalScores
    ) -> PatternIntelligenceVisualSignature {
        let savedCount = reads.count
        let signatureText = reads.prefix(40).map { read in
            [
                read.dateKey,
                read.archetypeId,
                read.themeKey,
                read.theme,
                read.identity,
                read.patternPrimarySignal,
                read.patternSecondarySignal,
                read.patternEmotionalTone,
                read.patternThemeTags?.joined(separator: "|")
            ]
            .compactMap { $0?.nilIfBlankForPatternIntelligence }
            .joined(separator: "/")
        }
        .joined(separator: "::")

        let seed = stableHash(signatureText.isEmpty ? "zodian-pattern-empty" : signatureText)
        let phase = unitValue(seed, shift: 8)
        let secondaryPhase = unitValue(seed, shift: 24)
        let tertiaryPhase = unitValue(seed, shift: 40)
        let dominantScore = max(scores.confidence, scores.reflection, scores.connection, scores.growth, scores.momentum)

        return PatternIntelligenceVisualSignature(
            seed: seed,
            rotationOffset: -28 + (phase * 56),
            verticalBias: 0.58 + (secondaryPhase * 0.22),
            nodeDrift: -0.07 + (tertiaryPhase * 0.14),
            pulseStrength: min(1, 0.20 + dominantScore * 0.55 + min(0.22, Double(savedCount) * 0.012))
        )
    }

    private static func stableHash(_ value: String) -> UInt64 {
        value.utf8.reduce(UInt64(14_695_981_039_346_656_037)) { result, byte in
            (result ^ UInt64(byte)).multipliedReportingOverflow(by: 1_099_511_628_211).partialValue
        }
    }

    private static func unitValue(_ seed: UInt64, shift: UInt64) -> Double {
        let shifted = seed >> shift
        return Double(shifted & 0xFFFF) / Double(UInt16.max)
    }

    private static func themeLabels(from read: SavedDailyReading) -> [String] {
        PatternMemoryLabelFormatter.themeLabels(
            from: [
                read.themeKey,
                read.theme,
                read.identity,
                read.summary,
                read.focus,
                read.growth
            ],
            limit: 2
        )
    }

    private static func containsAny(_ values: [String?], terms: [String]) -> Bool {
        let text = values
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")

        return terms.contains { text.contains($0) }
    }

    private static func normalized(_ count: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(1, Double(count) / Double(total))
    }

    private static func recentMomentumScore(from reads: [SavedDailyReading]) -> Double {
        guard let oldest = reads.last?.createdAt,
              let newest = reads.first?.createdAt else {
            return 0
        }

        let span = max(1, Calendar.current.dateComponents([.day], from: oldest, to: newest).day ?? 1)
        let density = Double(reads.count) / Double(span + 1)
        return min(1, density)
    }

    private static func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func clamped(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}

struct PatternIntelligencePreview {
    let state: PatternIntelligencePreviewState
    let savedCount: Int
    let sentence: String
    let supportingLine: String?
    let statusLabel: String?
    let topSignal: String?
    let topSignals: [String]
    let discoveries: [PatternIntelligenceSignalDiscovery]
    let earlyInsight: String?
    let patternShift: String?
    let suggestedQuestions: [String]
    let memoryCallback: String?
    let earlyPatternNarrative: String?
    let patternShiftNarrative: String?
    let askReadinessCopy: String?
    let signature: PatternIntelligenceVisualSignature
    let scores: PatternIntelligenceSignalScores

    init(
        state: PatternIntelligencePreviewState,
        savedCount: Int,
        sentence: String,
        supportingLine: String?,
        statusLabel: String?,
        topSignal: String?,
        topSignals: [String],
        discoveries: [PatternIntelligenceSignalDiscovery],
        earlyInsight: String?,
        patternShift: String?,
        suggestedQuestions: [String],
        memoryCallback: String? = nil,
        earlyPatternNarrative: String? = nil,
        patternShiftNarrative: String? = nil,
        askReadinessCopy: String? = nil,
        signature: PatternIntelligenceVisualSignature,
        scores: PatternIntelligenceSignalScores
    ) {
        self.state = state
        self.savedCount = savedCount
        self.sentence = sentence
        self.supportingLine = supportingLine
        self.statusLabel = statusLabel
        self.topSignal = topSignal
        self.topSignals = topSignals
        self.discoveries = discoveries
        self.earlyInsight = earlyInsight
        self.patternShift = patternShift
        self.suggestedQuestions = suggestedQuestions
        self.memoryCallback = memoryCallback
        self.earlyPatternNarrative = earlyPatternNarrative
        self.patternShiftNarrative = patternShiftNarrative
        self.askReadinessCopy = askReadinessCopy
        self.signature = signature
        self.scores = scores
    }
}

enum PatternIntelligencePreviewState: Equatable {
    case empty
    case building
    case ready
}

struct PatternIntelligenceSignalScores {
    let confidence: Double
    let reflection: Double
    let connection: Double
    let growth: Double
    let momentum: Double

    static let empty = PatternIntelligenceSignalScores(
        confidence: 0.08,
        reflection: 0.06,
        connection: 0.05,
        growth: 0.04,
        momentum: 0.03
    )
}

struct PatternIntelligenceSignalDiscovery: Equatable {
    let label: String
    let recurrenceCount: Int
    let sampleSize: Int
    let isApproximate: Bool
}

struct PatternIntelligenceVisualSignature {
    let seed: UInt64
    let rotationOffset: Double
    let verticalBias: Double
    let nodeDrift: Double
    let pulseStrength: Double
}

private extension String {
    var nilIfBlankForPatternIntelligence: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
