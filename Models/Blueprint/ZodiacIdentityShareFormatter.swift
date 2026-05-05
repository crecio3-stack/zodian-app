import Foundation

struct ZodiacIdentityShareContent: Equatable {
    let signCombo: String
    let title: String
    let lines: [String]
}

enum ZodiacIdentityShareFormatter {
    static func format(_ content: ZodiacIdentityContent) -> ZodiacIdentityShareContent {
        let western = normalizedWestern(content.westernSign)
        let chinese = normalizedChinese(content.chineseSign)

        let lines = [
            westernDriveLine(for: western),
            chineseStyleLine(for: chinese),
            tensionLine(for: western),
            recognitionLine(for: chinese)
        ]
        .map { cleanedLine($0) }
        .filter { !$0.isEmpty }

        return ZodiacIdentityShareContent(
            signCombo: "\(western.displayName) × \(chinese.displayName)",
            title: content.title,
            lines: Array(lines.prefix(4))
        )
    }

    static func format(reading: DailyReading) -> ZodiacIdentityShareContent {
        let lines = [
            compactLine(from: reading.insight),
            compactLine(from: reading.focus),
            compactLine(from: reading.caution),
            compactLine(from: reading.affirmation)
        ]
        .filter { !$0.isEmpty }

        return ZodiacIdentityShareContent(
            signCombo: "\(reading.westernSign.displayName) × \(reading.chineseSign.displayName)",
            title: reading.identity,
            lines: Array(lines.prefix(4))
        )
    }

    private static func westernDriveLine(for sign: WesternZodiac) -> String {
        switch sign {
        case .aries: return "Movement comes before certainty"
        case .taurus: return "Stability matters more than speed"
        case .gemini: return "Curiosity keeps everything moving"
        case .cancer: return "Care shapes every choice"
        case .leo: return "Expression needs room to breathe"
        case .virgo: return "Details decide what feels right"
        case .libra: return "Balance matters, even in tension"
        case .scorpio: return "Truth runs deeper than appearances"
        case .sagittarius: return "Freedom pulls harder than comfort"
        case .capricorn: return "Control feels safer than drift"
        case .aquarius: return "Distance makes the pattern clearer"
        case .pisces: return "Feeling arrives before language"
        }
    }

    private static func chineseStyleLine(for sign: ChineseZodiac) -> String {
        switch sign {
        case .rat: return "Reads the room before moving"
        case .ox: return "Builds quietly. Rarely rushes."
        case .tiger: return "Comes in strong. Stays alert."
        case .rabbit: return "Soft tone. Sharp instincts."
        case .dragon: return "Presence lands before words"
        case .snake: return "Keeps more than it shows"
        case .horse: return "Needs motion to feel clear"
        case .goat: return "Sensitivity hides in composure"
        case .monkey: return "Quick shifts. Fast patterning."
        case .rooster: return "Precision keeps things steady"
        case .dog: return "Loyal first. Open later."
        case .pig: return "Warmth stays, even with distance"
        }
    }

    private static func tensionLine(for sign: WesternZodiac) -> String {
        switch sign {
        case .aries: return "Fast start. Slow trust."
        case .taurus: return "Steady outside. Restless underneath."
        case .gemini: return "Quick mind. Split feelings."
        case .cancer: return "Soft edge. Strong memory."
        case .leo: return "Open heart. Guarded pride."
        case .virgo: return "Clear standards. Quiet doubt."
        case .libra: return "Seeks peace. Notices everything."
        case .scorpio: return "Deep feeling. Tight control."
        case .sagittarius: return "Needs space. Wants meaning."
        case .capricorn: return "Looks calm. Carries pressure."
        case .aquarius: return "Stays detached. Feels more underneath."
        case .pisces: return "Feels everything. Names little."
        }
    }

    private static func recognitionLine(for sign: ChineseZodiac) -> String {
        switch sign {
        case .rat: return "The pattern was always there"
        case .ox: return "This part takes time to notice"
        case .tiger: return "Most people catch only the surface"
        case .rabbit: return "The softer layer hides the sharp one"
        case .dragon: return "The charge lands before the words"
        case .snake: return "This part rarely gets named"
        case .horse: return "Stillness never tells the whole story"
        case .goat: return "The quiet layer runs deep"
        case .monkey: return "The shift happens before anyone sees it"
        case .rooster: return "The structure says more than expected"
        case .dog: return "The real signal takes time"
        case .pig: return "The warmth stays longer than expected"
        }
    }

    private static func cleanedLine(_ text: String) -> String {
        text
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func compactLine(from text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "…", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let sentence = cleaned
            .split(whereSeparator: { ".!?".contains($0) })
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? cleaned

        let words = sentence
            .split(separator: " ")
            .prefix(8)
            .map(String.init)

        guard !words.isEmpty else { return "" }

        let line = words.joined(separator: " ")
        return line.hasSuffix("") ? line : line + ""
    }

    private static func normalizedWestern(_ raw: String) -> WesternZodiac {
        WesternZodiac.from(rawValue: raw) ?? .aries
    }

    private static func normalizedChinese(_ raw: String) -> ChineseZodiac {
        ChineseZodiac.from(rawValue: raw) ?? .rat
    }
}
