import Foundation

enum PatternMemoryLabelFormatter {
    private static let labels: [String: String] = [
        "fairness": "Fairness",
        "structure": "Structure",
        "guarded_vulnerability": "Guarded vulnerability",
        "guarded vulnerability": "Guarded vulnerability",
        "strategic_restraint": "Strategic restraint",
        "strategic restraint": "Strategic restraint",
        "emotional_protection": "Emotional protection",
        "emotional protection": "Emotional protection",
        "decision_pressure": "Decision pressure",
        "decision pressure": "Decision pressure",
        "careful_timing": "Careful timing",
        "careful timing": "Careful timing",
        "recognition": "Recognition",
        "belonging": "Belonging",
        "momentum": "Momentum",
        "attention": "Attention",
        "ambition": "Ambition",
        "trust": "Trust",
        "independence": "Independence",
        "adaptability": "Adaptability",
        "communication": "Communication",
        "self_image": "Self-image",
        "self-image": "Self-image",
        "attachment": "Attachment",
        "control": "Control",
        "routine": "Routine",
        "creativity": "Creativity",
        "curiosity": "Curiosity",
        "leadership": "Leadership",
        "uncertainty": "Uncertainty",
        "influence": "Influence"
    ]

    private static let internalFragments = [
        "supabase",
        "structuredrow",
        "legacyrow",
        "localfallback",
        "notreadyfallback",
        "model",
        "object",
        "entity",
        "table",
        "uuid"
    ]

    static func humanLabel(for rawValue: String?) -> String? {
        guard let rawValue else { return nil }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let lookupKey = normalizedLookupKey(trimmed)
        guard !isInternal(lookupKey) else { return nil }

        if let mapped = labels[lookupKey] {
            return mapped
        }

        return nil
    }

    static func themeLabels(from values: [String?], limit: Int = 3) -> [String] {
        var results: [String] = []
        var seen = Set<String>()

        for value in values.compactMap({ $0 }) {
            guard !isInternal(normalizedLookupKey(value)) else { continue }

            let normalized = value
                .lowercased()
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")

            for (key, label) in labels {
                let phrase = key.replacingOccurrences(of: "_", with: " ")
                guard normalized.localizedCaseInsensitiveContains(phrase) else { continue }
                guard seen.insert(label.lowercased()).inserted else { continue }
                results.append(label)
                if results.count == limit { return results }
            }

        }

        return results
    }

    private static func normalizedLookupKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .lowercased()
    }

    private static func isInternal(_ value: String) -> Bool {
        let compact = value
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")

        return internalFragments.contains { compact.contains($0) }
    }
}

enum PatternMemoryEventType: String, Codable, CaseIterable {
    case dailyReadOpened
    case dailyReadExpanded
    case dailyReadSaved
    case dailyReadUnsaved
    case dailyReadShared
    case patternScreenOpened
    case patternArchiveOpened
    case savedReadOpenedFromArchive
    case lensSelected
    case profileViewed
    case profileSaved
    case profileUnsaved
    case threadProfileOpened
    case startThreadTapped
    case patternArchiveViewed
    case archivePreviewViewed
    case archiveItemOpened
}

struct PatternMemoryEvent: Codable, Identifiable, Equatable {
    let id: UUID
    let type: PatternMemoryEventType
    let entityID: String?
    let timestamp: Date
    let dateKey: String?
    let identity: String?
    let title: String?
    let theme: String?
    let focus: String?
    let isSaved: Bool?
    let lens: String?
    let profileIdentity: String?
    let signal: String?
    let openTo: String?

    init(
        id: UUID = UUID(),
        type: PatternMemoryEventType,
        entityID: String? = nil,
        timestamp: Date = Date(),
        dateKey: String? = nil,
        identity: String? = nil,
        title: String? = nil,
        theme: String? = nil,
        focus: String? = nil,
        isSaved: Bool? = nil,
        lens: String? = nil,
        profileIdentity: String? = nil,
        signal: String? = nil,
        openTo: String? = nil
    ) {
        self.id = id
        self.type = type
        self.entityID = entityID
        self.timestamp = timestamp
        self.dateKey = dateKey
        self.identity = identity
        self.title = title
        self.theme = theme
        self.focus = focus
        self.isSaved = isSaved
        self.lens = lens
        self.profileIdentity = profileIdentity
        self.signal = signal
        self.openTo = openTo
    }
}

struct PatternMemorySummary {
    let startDate: Date?
    let endDate: Date?
    let totalEvents: Int
    let totalSavedReads: Int
    let totalSavedProfiles: Int
    let mostUsedLens: String?
    let lensCounts: [String: Int]
    let topThemes: [(value: String, count: Int)]
    let topSavedReadThemes: [(value: String, count: Int)]
    let topSignals: [(value: String, count: Int)]
    let archiveVisits: Int
    let archiveItemOpens: Int
    let revisitedSavedReadThemes: [(value: String, count: Int)]
    let threadStarts: Int
    let threadStartedIdentities: [(value: String, count: Int)]
    let repeatedIdentities: [(value: String, count: Int)]
    let repeatedSavedIdentities: [(value: String, count: Int)]
}

struct PatternMemoryMonthlyReflection {
    let monthTitle: String
    let recurringThemes: [String]
    let mostUsedLens: String
    let repeatedSavedIdentities: [String]
    let archiveUsage: String
    let threadActivity: String
    let revisitedSavedReadThemes: [String]
    let threadStartedIdentities: [String]
    let reflectionLines: [String]
}

final class PatternMemoryService {
    static let shared = PatternMemoryService()

    private let defaults: UserDefaults
    private let storageKey = "zodian.patternMemory.events.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let calendar = Calendar.current
    private let maxStoredEvents = 2_000

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func track(event: PatternMemoryEvent) {
        var events = allEvents()

        if shouldDropDuplicate(event, existingEvents: events) {
            return
        }

        events.append(event)
        if events.count > maxStoredEvents {
            events = Array(events.suffix(maxStoredEvents))
        }

        save(events)
    }

    func allEvents() -> [PatternMemoryEvent] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? decoder.decode([PatternMemoryEvent].self, from: data)) ?? []
    }

    func dailySummary(for date: Date = Date()) -> PatternMemorySummary {
        let events = allEvents().filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
        return summarize(events)
    }

    func monthlySummary(for date: Date = Date()) -> PatternMemorySummary {
        let components = calendar.dateComponents([.year, .month], from: date)
        let events = allEvents().filter {
            calendar.dateComponents([.year, .month], from: $0.timestamp) == components
        }
        return summarize(events)
    }

    func monthlyReflection(for date: Date = Date()) -> PatternMemoryMonthlyReflection {
        let summary = monthlySummary(for: date)
        return makeMonthlyReflection(from: summary, date: date)
    }

    func reset() {
        defaults.removeObject(forKey: storageKey)
    }

    private func save(_ events: [PatternMemoryEvent]) {
        guard let data = try? encoder.encode(events) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func summarize(_ events: [PatternMemoryEvent]) -> PatternMemorySummary {
        let sortedEvents = events.sorted { $0.timestamp < $1.timestamp }
        let lensCounts = counts(for: events.compactMap(\.lens))
        let themeCounts = rankedCounts(
            for: events.compactMap { PatternMemoryLabelFormatter.humanLabel(for: $0.theme) }
        )
        let signalCounts = rankedCounts(for: events.compactMap(\.signal))
        let archiveItemOpenCount = events.filter {
            $0.type == .savedReadOpenedFromArchive
        }.count
        let revisitedSavedReadThemeCounts = rankedCounts(
            for: events
                .filter { $0.type == .savedReadOpenedFromArchive }
                .compactMap {
                    PatternMemoryLabelFormatter.humanLabel(for: $0.theme)
                        ?? PatternMemoryLabelFormatter.themeLabels(
                            from: [$0.focus, $0.title],
                            limit: 1
                        ).first
                }
        )
        let threadStartedIdentityCounts = rankedCounts(
            for: events
                .filter { $0.type == .startThreadTapped }
                .compactMap(\.profileIdentity)
        )
        let identityCounts = rankedCounts(
            for: events.flatMap { [$0.identity, $0.profileIdentity].compactMap(normalizedValue) }
        )
        let repeatedIdentities = identityCounts.filter { $0.count > 1 }
        let savedReadThemeCounts = rankedCounts(
            for: activeValues(
                events: events,
                positive: .dailyReadSaved,
                negative: .dailyReadUnsaved,
                key: { event in
                    normalizedValue(event.entityID)
                        ?? normalizedValue(event.dateKey)
                        ?? normalizedValue(event.title)
                        ?? event.id.uuidString
                },
                value: { event in
                    PatternMemoryLabelFormatter.humanLabel(for: event.theme)
                        ?? PatternMemoryLabelFormatter.themeLabels(
                            from: [event.title, event.focus],
                            limit: 1
                        ).first
                }
            )
        )
        let savedIdentityCounts = rankedCounts(
            for: activeValues(
                events: events,
                positive: .profileSaved,
                negative: .profileUnsaved,
                key: { event in
                    normalizedValue(event.entityID)
                        ?? normalizedValue(event.profileIdentity)
                        ?? event.id.uuidString
                },
                value: { event in
                    normalizedValue(event.profileIdentity)
                }
            )
        )

        return PatternMemorySummary(
            startDate: sortedEvents.first?.timestamp,
            endDate: sortedEvents.last?.timestamp,
            totalEvents: events.count,
            totalSavedReads: netCount(
                events: events,
                positive: .dailyReadSaved,
                negative: .dailyReadUnsaved,
                key: { event in
                    normalizedValue(event.entityID)
                        ?? normalizedValue(event.dateKey)
                        ?? normalizedValue(event.title)
                        ?? event.id.uuidString
                }
            ),
            totalSavedProfiles: netCount(
                events: events,
                positive: .profileSaved,
                negative: .profileUnsaved,
                key: { event in
                    normalizedValue(event.entityID)
                        ?? normalizedValue(event.profileIdentity)
                        ?? normalizedValue(event.identity)
                        ?? event.id.uuidString
                }
            ),
            mostUsedLens: lensCounts.sorted { lhs, rhs in
                lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value
            }.first?.key,
            lensCounts: lensCounts,
            topThemes: Array(themeCounts.prefix(5)),
            topSavedReadThemes: Array(savedReadThemeCounts.prefix(5)),
            topSignals: Array(signalCounts.prefix(5)),
            archiveVisits: events.filter {
                $0.type == .patternArchiveOpened || $0.type == .patternArchiveViewed
            }.count,
            archiveItemOpens: archiveItemOpenCount,
            revisitedSavedReadThemes: Array(revisitedSavedReadThemeCounts.prefix(5)),
            threadStarts: events.filter { $0.type == .startThreadTapped }.count,
            threadStartedIdentities: Array(threadStartedIdentityCounts.prefix(5)),
            repeatedIdentities: Array(repeatedIdentities.prefix(5)),
            repeatedSavedIdentities: Array(savedIdentityCounts.filter { $0.count > 1 }.prefix(5))
        )
    }

    private func shouldDropDuplicate(
        _ event: PatternMemoryEvent,
        existingEvents: [PatternMemoryEvent]
    ) -> Bool {
        guard dedupeWindow(for: event.type) > 0 else { return false }
        guard let recent = existingEvents.last(where: { $0.type == event.type }) else { return false }
        guard dedupeKey(for: recent) == dedupeKey(for: event) else { return false }
        return event.timestamp.timeIntervalSince(recent.timestamp) < dedupeWindow(for: event.type)
    }

    private func dedupeWindow(for type: PatternMemoryEventType) -> TimeInterval {
        switch type {
        case .dailyReadOpened,
             .dailyReadExpanded,
             .patternScreenOpened,
             .patternArchiveOpened,
             .patternArchiveViewed,
             .archivePreviewViewed,
             .archiveItemOpened,
             .savedReadOpenedFromArchive,
             .lensSelected,
             .profileViewed,
             .threadProfileOpened:
            return 60
        case .dailyReadSaved,
             .dailyReadUnsaved,
             .dailyReadShared,
             .profileSaved,
             .profileUnsaved,
             .startThreadTapped:
            return 0
        }
    }

    private func dedupeKey(for event: PatternMemoryEvent) -> String {
        [
            event.type.rawValue,
            event.entityID,
            event.dateKey,
            event.identity,
            event.title,
            event.lens,
            event.profileIdentity,
            event.focus,
            event.signal,
            event.openTo
        ]
            .compactMap(normalizedValue)
            .joined(separator: "|")
    }

    private func netCount(
        events: [PatternMemoryEvent],
        positive: PatternMemoryEventType,
        negative: PatternMemoryEventType,
        key: (PatternMemoryEvent) -> String
    ) -> Int {
        var states: [String: Bool] = [:]
        for event in events.sorted(by: { $0.timestamp < $1.timestamp }) {
            if event.type == positive {
                states[key(event)] = true
            } else if event.type == negative {
                states[key(event)] = false
            }
        }

        return states.values.filter { $0 }.count
    }

    private func activeValues(
        events: [PatternMemoryEvent],
        positive: PatternMemoryEventType,
        negative: PatternMemoryEventType,
        key: (PatternMemoryEvent) -> String,
        value: (PatternMemoryEvent) -> String?
    ) -> [String] {
        var states: [String: String] = [:]
        for event in events.sorted(by: { $0.timestamp < $1.timestamp }) {
            if event.type == positive, let value = value(event) {
                states[key(event)] = value
            } else if event.type == negative {
                states.removeValue(forKey: key(event))
            }
        }

        return Array(states.values)
    }

    private func counts(for values: [String]) -> [String: Int] {
        Dictionary(grouping: values.compactMap(normalizedValue), by: { $0 }).mapValues(\.count)
    }

    private func rankedCounts(for values: [String]) -> [(value: String, count: Int)] {
        counts(for: values)
            .map { (value: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                lhs.count == rhs.count ? lhs.value < rhs.value : lhs.count > rhs.count
            }
    }

    private func makeMonthlyReflection(
        from summary: PatternMemorySummary,
        date: Date
    ) -> PatternMemoryMonthlyReflection {
        let recurringThemes = reflectionItems(
            from: summary.topSavedReadThemes,
            empty: "Nothing has repeated enough to name yet.",
            item: { theme, count in
                count > 2
                    ? "You seem to keep recognizing yourself around \(theme.lowercased())."
                    : "\(theme) may be one of the places your attention is starting to circle."
            }
        )

        let mostUsedLens = summary.mostUsedLens.map { lens in
            lensAttentionLine(for: lens)
        } ?? "No clear Connect pattern has taken shape yet."

        let repeatedSavedIdentities = reflectionItems(
            from: summary.repeatedSavedIdentities,
            empty: "The people you kept are still too varied to read clearly.",
            item: { identity, count in
                count > 2
                    ? "\(identity) seems to echo something you keep wanting near you."
                    : "\(identity) may be touching a quality you are learning to notice."
            }
        )

        let revisitedSavedReadThemes = reflectionItems(
            from: summary.revisitedSavedReadThemes,
            empty: "No saved read has asked for a return yet.",
            item: { theme, count in
                count > 2
                    ? "\(theme) seems to be asking for a second look."
                    : "\(theme) had enough charge for you to return to it."
            }
        )

        let threadStartedIdentities = reflectionItems(
            from: summary.threadStartedIdentities,
            empty: "No saved identity has turned into a conversation yet.",
            item: { identity, count in
                count > 2
                    ? "\(identity) keeps becoming someone you want to understand out loud."
                    : "\(identity) moved from curiosity into conversation."
            }
        )

        let archiveUsage = archiveUsageLine(summary.archiveVisits)
        let archiveSpecificity = archiveSpecificityLine(
            visits: summary.archiveVisits,
            itemOpens: summary.archiveItemOpens
        )
        let threadActivity = threadActivityLine(summary.threadStarts)

        return PatternMemoryMonthlyReflection(
            monthTitle: monthTitle(for: date),
            recurringThemes: recurringThemes,
            mostUsedLens: mostUsedLens,
            repeatedSavedIdentities: repeatedSavedIdentities,
            archiveUsage: archiveSpecificity ?? archiveUsage,
            threadActivity: threadActivity,
            revisitedSavedReadThemes: revisitedSavedReadThemes,
            threadStartedIdentities: threadStartedIdentities,
            reflectionLines: [
                recurringThemes.first,
                mostUsedLens,
                repeatedSavedIdentities.first,
                revisitedSavedReadThemes.first,
                archiveSpecificity ?? archiveUsage,
                threadStartedIdentities.first,
                threadActivity
            ].compactMap { $0 }
        )
    }

    private func reflectionItems(
        from rankedValues: [(value: String, count: Int)],
        empty: String,
        item: (String, Int) -> String
    ) -> [String] {
        let repeatedValues: [String] = rankedValues
            .filter { $0.count > 1 }
            .prefix(3)
            .compactMap { value -> String? in
                guard let label = PatternMemoryLabelFormatter.humanLabel(for: value.value) else {
                    return nil
                }
                return item(label, value.count)
            }

        return repeatedValues.isEmpty ? [empty] : repeatedValues
    }

    private func archiveUsageLine(_ visits: Int) -> String {
        switch visits {
        case 0:
            return "The archive has not become part of the pattern yet."
        case 1:
            return "One saved read asked for more than a first impression."
        default:
            return "You are beginning to revisit what stayed with you."
        }
    }

    private func archiveSpecificityLine(visits: Int, itemOpens: Int) -> String? {
        guard visits > 0 else { return nil }

        switch itemOpens {
        case 0:
            return "You kept the archive nearby without following one thread deeper."
        case 1:
            return "One saved read asked for more than a first impression."
        default:
            return "The reads you kept are starting to ask for closer attention."
        }
    }

    private func threadActivityLine(_ starts: Int) -> String {
        switch starts {
        case 0:
            return "No saved profile has asked for a conversation yet."
        case 1:
            return "One saved profile carried enough charge to become a conversation."
        default:
            return "Some profiles are becoming questions you want to stay with."
        }
    }

    private func lensAttentionLine(for lens: String) -> String {
        switch lens.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "ease":
            return "You seem to notice what feels easy to stay near."
        case "spark":
            return "You seem to notice what becomes alive quickly."
        case "depth":
            return "You seem to notice what takes longer to reveal itself."
        default:
            return "Your attention is starting to leave a recognizable trail."
        }
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func normalizedValue(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension PatternMemoryEvent {
    static func savedReadArchiveEvent(
        type: PatternMemoryEventType,
        reading: SavedDailyReading
    ) -> PatternMemoryEvent {
        PatternMemoryEvent(
            type: type,
            entityID: reading.id.uuidString,
            dateKey: reading.dateKey,
            title: reading.patternMemoryTitle,
            theme: reading.patternMemoryTheme,
            focus: reading.patternMemoryFocus
        )
    }

    static func savedProfileEvent(
        type: PatternMemoryEventType,
        match: SavedMatch,
        lens: String? = nil
    ) -> PatternMemoryEvent {
        PatternMemoryEvent(
            type: type,
            entityID: match.id.uuidString,
            lens: lens,
            profileIdentity: match.patternMemoryIdentity,
            signal: match.patternMemorySignal,
            openTo: match.intent
        )
    }
}

private extension SavedDailyReading {
    var patternMemoryTitle: String? {
        theme.patternMemoryNilIfBlank
            ?? identity?.patternMemoryNilIfBlank
            ?? summary.patternMemoryNilIfBlank
    }

    var patternMemoryTheme: String? {
        PatternMemoryLabelFormatter.themeLabels(
            from: [
                themeKey,
                theme,
                focus,
                insight,
                summary
            ],
            limit: 1
        ).first
    }

    var patternMemoryFocus: String? {
        focus?.patternMemoryNilIfBlank
            ?? insight?.patternMemoryNilIfBlank
            ?? summary.patternMemoryNilIfBlank
    }
}

private extension SavedMatch {
    var patternMemoryIdentity: String {
        guard let western = WesternZodiac(rawValue: westernSignRaw)?.displayName,
              let eastern = ChineseZodiac(rawValue: chineseSignRaw)?.displayName
        else {
            return "Saved profile"
        }

        return "\(western) × \(eastern)"
    }

    var patternMemorySignal: String? {
        signals.first?.displayText
            ?? primaryReasonTitle.patternMemoryNilIfBlank
            ?? archetypeTitle.patternMemoryNilIfBlank
    }
}

private extension String {
    var patternMemoryNilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
