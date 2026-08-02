import Foundation

struct DailyReading: Codable, Equatable {
    let date: Date
    let identity: String
    let insight: String
    let focus: String
    let caution: String
    let affirmation: String
    let energy: String?
    let energyKey: String?
    let themeKey: String?
    let toneKey: String?
    let reflectionTag: String?
    let moonPhase: String?
    let moonSign: WesternZodiac?
    let sunSign: WesternZodiac?
    let skyTheme: String?
    let skyTone: String?
    let westernSign: WesternZodiac
    let chineseSign: ChineseZodiac
    let streakContext: Int?

    init(
        date: Date = Date(),
        identity: String,
        insight: String,
        focus: String,
        caution: String,
        affirmation: String,
        energy: String? = nil,
        energyKey: String? = nil,
        themeKey: String? = nil,
        toneKey: String? = nil,
        reflectionTag: String? = nil,
        moonPhase: String? = nil,
        moonSign: WesternZodiac? = nil,
        sunSign: WesternZodiac? = nil,
        skyTheme: String? = nil,
        skyTone: String? = nil,
        westernSign: WesternZodiac,
        chineseSign: ChineseZodiac,
        streakContext: Int? = nil
    ) {
        self.date = date
        self.identity = identity
        self.insight = insight
        self.focus = focus
        self.caution = caution
        self.affirmation = affirmation
        self.energy = energy
        self.energyKey = energyKey
        self.themeKey = themeKey
        self.toneKey = toneKey
        self.reflectionTag = reflectionTag
        self.moonPhase = moonPhase
        self.moonSign = moonSign
        self.sunSign = sunSign
        self.skyTheme = skyTheme
        self.skyTone = skyTone
        self.westernSign = westernSign
        self.chineseSign = chineseSign
        self.streakContext = streakContext
    }
}

extension DailyReading {
    init(saved: SavedDailyReading) {
        let western = WesternZodiac.from(rawValue: saved.westernSignRaw) ?? .aries
        let chinese = ChineseZodiac.from(rawValue: saved.chineseSignRaw) ?? .rat

        self.init(
            date: saved.createdAt,
            identity: saved.identity ?? saved.theme,
            insight: saved.insight ?? saved.summary,
            focus: saved.focus ?? saved.growth,
            caution: saved.caution,
            affirmation: saved.affirmation ?? saved.opportunity,
            energy: saved.energy ?? DailyMood(rawValue: saved.mood.lowercased())?.title,
            energyKey: saved.energyKey ?? saved.mood,
            themeKey: saved.themeKey ?? saved.theme,
            toneKey: saved.toneKey ?? saved.energyKey ?? saved.mood,
            reflectionTag: saved.reflectionTag,
            moonPhase: saved.moonPhase,
            moonSign: WesternZodiac.from(rawValue: saved.moonSignRaw),
            sunSign: WesternZodiac.from(rawValue: saved.sunSignRaw),
            skyTheme: saved.skyTheme,
            skyTone: saved.skyTone,
            westernSign: western,
            chineseSign: chinese,
            streakContext: saved.streakContext
        )
    }

    var theme: String { identity }
    var summary: String { insight }
    var mood: String { energyKey ?? DailyMood.clarity.rawValue }
    var love: String { insight }
    var work: String { focus }
    var growth: String { affirmation }
    var opportunity: String { affirmation }
}
