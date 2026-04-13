import Foundation

enum ChineseZodiac: String, Codable, CaseIterable, Identifiable {
    case rat
    case ox
    case tiger
    case rabbit
    case dragon
    case snake
    case horse
    case goat
    case monkey
    case rooster
    case dog
    case pig

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rat: return "Rat"
        case .ox: return "Ox"
        case .tiger: return "Tiger"
        case .rabbit: return "Rabbit"
        case .dragon: return "Dragon"
        case .snake: return "Snake"
        case .horse: return "Horse"
        case .goat: return "Goat"
        case .monkey: return "Monkey"
        case .rooster: return "Rooster"
        case .dog: return "Dog"
        case .pig: return "Pig"
        }
    }

    var emoji: String {
        switch self {
        case .rat: return "🐀"
        case .ox: return "🐂"
        case .tiger: return "🐅"
        case .rabbit: return "🐇"
        case .dragon: return "🐉"
        case .snake: return "🐍"
        case .horse: return "🐎"
        case .goat: return "🐐"
        case .monkey: return "🐒"
        case .rooster: return "🐓"
        case .dog: return "🐕"
        case .pig: return "🐖"
        }
    }

    /// Converts a birth year into the correct Chinese zodiac sign
    static func from(year: Int) -> ChineseZodiac {
        // Chinese zodiac cycle starts at Rat and repeats every 12 years.
        // 2020 = Rat, so we anchor to that.
        let baseYear = 2020
        let offset = (year - baseYear) % 12

        let index = (offset + 12) % 12 // ensure positive index

        return ChineseZodiac.allCases[index]
    }

    static func from(rawValue: String?) -> ChineseZodiac? {
        guard let rawValue else { return nil }
        return ChineseZodiac(rawValue: rawValue.lowercased())
    }
}
