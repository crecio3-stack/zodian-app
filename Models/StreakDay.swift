import Foundation
import SwiftData

@Model
final class StreakDay {
    @Attribute(.unique) var id: UUID

    var date: Date
    var didReveal: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        didReveal: Bool = true
    ) {
        self.id = id
        self.date = date
        self.didReveal = didReveal
    }
}

// MARK: - Helpers

extension StreakDay {

    /// Normalized start-of-day for comparisons
    var day: Date {
        Calendar.current.startOfDay(for: date)
    }

    /// Check if this entry matches a specific date
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: other)
    }
}
