import Foundation

struct AstrologyCalculator {

    // MARK: - Western Zodiac

    static func westernZodiac(forMonth month: Int, day: Int) -> WesternZodiac {
        switch (month, day) {
        case (3, 21...31), (4, 1...19):
            return .aries
        case (4, 20...30), (5, 1...20):
            return .taurus
        case (5, 21...31), (6, 1...20):
            return .gemini
        case (6, 21...30), (7, 1...22):
            return .cancer
        case (7, 23...31), (8, 1...22):
            return .leo
        case (8, 23...31), (9, 1...22):
            return .virgo
        case (9, 23...30), (10, 1...22):
            return .libra
        case (10, 23...31), (11, 1...21):
            return .scorpio
        case (11, 22...30), (12, 1...21):
            return .sagittarius
        case (12, 22...31), (1, 1...19):
            return .capricorn
        case (1, 20...31), (2, 1...18):
            return .aquarius
        case (2, 19...29), (3, 1...20):
            return .pisces
        default:
            return .aries // fallback safety
        }
    }

    static func westernZodiac(from date: Date) -> WesternZodiac {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return westernZodiac(forMonth: month, day: day)
    }

    // MARK: - Chinese Zodiac

    static func chineseZodiac(forYear year: Int) -> ChineseZodiac {
        return ChineseZodiac.from(year: year)
    }

    static func chineseZodiac(from date: Date) -> ChineseZodiac {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return chineseZodiac(forYear: year)
    }

    // MARK: - Combined Helper

    static func combinedSigns(from date: Date) -> (western: WesternZodiac, chinese: ChineseZodiac) {
        let western = westernZodiac(from: date)
        let chinese = chineseZodiac(from: date)
        return (western, chinese)
    }
}
