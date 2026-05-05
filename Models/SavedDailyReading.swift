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
    var themeKey: String?
    var toneKey: String?
    var identity: String?
    var insight: String?
    var focus: String?
    var affirmation: String?
    var energy: String?
    var energyKey: String?
    var reflectionTag: String?
    var reflectionNote: String?
    var moonPhase: String?
    var moonSignRaw: String?
    var sunSignRaw: String?
    var skyTheme: String?
    var skyTone: String?
    var westernSignRaw: String?
    var chineseSignRaw: String?
    var streakContext: Int?

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
        themeKey: String? = nil,
        toneKey: String? = nil,
        identity: String? = nil,
        insight: String? = nil,
        focus: String? = nil,
        affirmation: String? = nil,
        energy: String? = nil,
        energyKey: String? = nil,
        reflectionTag: String? = nil,
        reflectionNote: String? = nil,
        moonPhase: String? = nil,
        moonSignRaw: String? = nil,
        sunSignRaw: String? = nil,
        skyTheme: String? = nil,
        skyTone: String? = nil,
        westernSignRaw: String? = nil,
        chineseSignRaw: String? = nil,
        streakContext: Int? = nil,
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
        self.themeKey = themeKey
        self.toneKey = toneKey
        self.identity = identity
        self.insight = insight
        self.focus = focus
        self.affirmation = affirmation
        self.energy = energy
        self.energyKey = energyKey
        self.reflectionTag = reflectionTag
        self.reflectionNote = reflectionNote
        self.moonPhase = moonPhase
        self.moonSignRaw = moonSignRaw
        self.sunSignRaw = sunSignRaw
        self.skyTheme = skyTheme
        self.skyTone = skyTone
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.streakContext = streakContext
        self.love = love
        self.work = work
        self.growth = growth
        self.caution = caution
        self.opportunity = opportunity
        self.createdAt = createdAt
    }
}
