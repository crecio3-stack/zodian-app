import Foundation

struct DailyReading: Codable, Equatable {
    let theme: String
    let summary: String
    let mood: String

    let love: String
    let work: String
    let growth: String
    let caution: String
    let opportunity: String

    init(
        theme: String,
        summary: String,
        mood: String,
        love: String,
        work: String,
        growth: String,
        caution: String,
        opportunity: String
    ) {
        self.theme = theme
        self.summary = summary
        self.mood = mood
        self.love = love
        self.work = work
        self.growth = growth
        self.caution = caution
        self.opportunity = opportunity
    }
}

extension DailyReading {
    init(saved: SavedDailyReading) {
        self.init(
            theme: saved.theme,
            summary: saved.summary,
            mood: saved.mood,
            love: saved.love,
            work: saved.work,
            growth: saved.growth,
            caution: saved.caution,
            opportunity: saved.opportunity
        )
    }
}
