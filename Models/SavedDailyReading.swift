import Foundation
import SwiftData

@Model
final class SavedDailyReading {
    @Attribute(.unique) var id: UUID

    var dateKey: String
    var archetypeId: String

    var theme: String
    var summary: String
    var mood: String

    var love: String
    var work: String
    var growth: String
    var caution: String
    var opportunity: String

    var createdAt: Date

    init(
        id: UUID = UUID(),
        dateKey: String,
        archetypeId: String,
        theme: String,
        summary: String,
        mood: String,
        love: String,
        work: String,
        growth: String,
        caution: String,
        opportunity: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dateKey = dateKey
        self.archetypeId = archetypeId
        self.theme = theme
        self.summary = summary
        self.mood = mood
        self.love = love
        self.work = work
        self.growth = growth
        self.caution = caution
        self.opportunity = opportunity
        self.createdAt = createdAt
    }
}
