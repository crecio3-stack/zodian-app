import Foundation
import SwiftData

@MainActor
enum DailyReadingStore {
    struct MemoryContext {
        let recentIdentities: [String]
        let recentThemes: [String]
        let recentTones: [String]
        let lastReflectionTag: String?
    }

    static func dateKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func fetchOrCreate(
        for archetype: Archetype,
        user: UserProfile?,
        streak: Int?,
        context: ModelContext,
        date: Date = Date()
    ) -> DailyReading {
        let key = dateKey(for: date)
        let descriptor = FetchDescriptor<SavedDailyReading>(
            predicate: #Predicate { item in
                item.dateKey == key && item.archetypeId == archetype.id
            },
            sortBy: [SortDescriptor(\SavedDailyReading.createdAt, order: .forward)]
        )

        if let existing = fetchExistingReading(using: descriptor, context: context) {
            return DailyReading(saved: existing)
        }

        let recentReadings = recentSavedReadings(
            for: archetype.id,
            excluding: key,
            limit: 4,
            context: context
        )

        let memory = memoryContext(from: recentReadings)
        let skyContext = DailySkyContextProvider.context(for: date)

        let reading = DailyReadingGenerator.generate(
            context: .init(
                archetype: archetype,
                user: user,
                streak: streak,
                date: date,
                previousIdentities: memory.recentIdentities,
                recentThemes: memory.recentThemes,
                recentTones: memory.recentTones,
                lastReflectionTag: memory.lastReflectionTag,
                skyContext: skyContext
            )
        )

        let saved = SavedDailyReading(
            dateKey: key,
            archetypeId: archetype.id,
            theme: reading.identity,
            summary: reading.insight,
            mood: reading.energyKey ?? DailyMood.clarity.rawValue,
            themeKey: reading.themeKey,
            toneKey: reading.toneKey,
            identity: reading.identity,
            insight: reading.insight,
            focus: reading.focus,
            affirmation: reading.affirmation,
            energy: reading.energy,
            energyKey: reading.energyKey,
            reflectionTag: reading.reflectionTag,
            moonPhase: reading.moonPhase,
            moonSignRaw: reading.moonSign?.rawValue,
            sunSignRaw: reading.sunSign?.rawValue,
            skyTheme: reading.skyTheme,
            skyTone: reading.skyTone,
            westernSignRaw: reading.westernSign.rawValue,
            chineseSignRaw: reading.chineseSign.rawValue,
            streakContext: reading.streakContext,
            love: reading.insight,
            work: reading.focus,
            growth: reading.affirmation,
            caution: reading.caution,
            opportunity: reading.affirmation,
            createdAt: date
        )

        context.insert(saved)

        do {
            try context.save()
        } catch {
            print("Failed to save daily reading: \(error)")
        }

        return reading
    }

    static func updateReflection(
        note: String,
        for archetypeId: String,
        context: ModelContext,
        date: Date = Date()
    ) {
        let key = dateKey(for: date)
        let descriptor = FetchDescriptor<SavedDailyReading>(
            predicate: #Predicate { item in
                item.dateKey == key && item.archetypeId == archetypeId
            },
            sortBy: [SortDescriptor(\SavedDailyReading.createdAt, order: .forward)]
        )

        guard let reading = fetchExistingReading(using: descriptor, context: context) else { return }
        reading.reflectionNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        reading.reflectionTag = inferReflectionTag(from: note)

        do {
            try context.save()
        } catch {
            print("Failed to save reflection metadata: \(error)")
        }
    }

    static func fetchHistory(context: ModelContext, limit: Int = 14) -> [DailyReading] {
        let descriptor = FetchDescriptor<SavedDailyReading>(
            sortBy: [SortDescriptor(\SavedDailyReading.createdAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
                .prefix(limit)
                .map(DailyReading.init(saved:))
        } catch {
            print("Failed to fetch reading history: \(error)")
            return []
        }
    }

    private static func recentSavedReadings(
        for archetypeId: String,
        excluding dateKey: String,
        limit: Int,
        context: ModelContext
    ) -> [SavedDailyReading] {
        let descriptor = FetchDescriptor<SavedDailyReading>(
            predicate: #Predicate { item in
                item.archetypeId == archetypeId && item.dateKey != dateKey
            },
            sortBy: [SortDescriptor(\SavedDailyReading.createdAt, order: .reverse)]
        )

        do {
            return Array(try context.fetch(descriptor).prefix(limit))
        } catch {
            print("Failed to fetch recent readings: \(error)")
            return []
        }
    }

    private static func fetchExistingReading(
        using descriptor: FetchDescriptor<SavedDailyReading>,
        context: ModelContext
    ) -> SavedDailyReading? {
        do {
            let readings = try context.fetch(descriptor)
            guard let primaryReading = readings.first else { return nil }

            if readings.count > 1 {
                for duplicate in readings.dropFirst() {
                    context.delete(duplicate)
                }
                try context.save()
            }

            return primaryReading
        } catch {
            print("Failed to fetch daily reading: \(error)")
            return nil
        }
    }

    private static func memoryContext(from readings: [SavedDailyReading]) -> MemoryContext {
        MemoryContext(
            recentIdentities: readings.compactMap { $0.identity ?? $0.theme },
            recentThemes: readings.compactMap { $0.themeKey ?? $0.theme }.prefix(4).map { $0 },
            recentTones: readings.compactMap { $0.toneKey ?? $0.energyKey ?? $0.mood }.prefix(4).map { $0 },
            lastReflectionTag: readings.compactMap(\.reflectionTag).first
        )
    }

    private static func inferReflectionTag(from note: String) -> String? {
        let lowered = note.lowercased()
        guard !lowered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        if ["work", "job", "career", "project", "goal", "focus"].contains(where: lowered.contains) {
            return "work"
        }

        if ["love", "dating", "relationship", "partner", "heart", "text"].contains(where: lowered.contains) {
            return "love"
        }

        if ["self", "body", "rest", "boundary", "me", "myself"].contains(where: lowered.contains) {
            return "self"
        }

        return "general"
    }
}
