//
//  DailyReadingStore.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//


import Foundation
import SwiftData

enum DailyReadingStore {
    static func dateKey(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func fetchOrCreate(
        for archetype: Archetype,
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

        let reading = DailyReadingGenerator.generate(for: archetype)
        let saved = SavedDailyReading(
            dateKey: key,
            archetypeId: archetype.id,
            theme: reading.theme,
            summary: reading.summary,
            mood: reading.mood,
            love: reading.love,
            work: reading.work,
            growth: reading.growth,
            caution: reading.caution,
            opportunity: reading.opportunity
        )

        context.insert(saved)

        do {
            try context.save()
        } catch {
            print("Failed to save daily reading: \(error)")
        }

        return reading
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
}
