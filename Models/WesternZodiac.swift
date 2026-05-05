import Foundation

enum WesternZodiac: String, Codable, CaseIterable, Identifiable {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    var symbolName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    var glyph: String {
        switch self {
        case .aries: return "♈︎"
        case .taurus: return "♉︎"
        case .gemini: return "♊︎"
        case .cancer: return "♋︎"
        case .leo: return "♌︎"
        case .virgo: return "♍︎"
        case .libra: return "♎︎"
        case .scorpio: return "♏︎"
        case .sagittarius: return "♐︎"
        case .capricorn: return "♑︎"
        case .aquarius: return "♒︎"
        case .pisces: return "♓︎"
        }
    }

    var dateRangeText: String {
        switch self {
        case .aries: return "Mar 21 – Apr 19"
        case .taurus: return "Apr 20 – May 20"
        case .gemini: return "May 21 – Jun 20"
        case .cancer: return "Jun 21 – Jul 22"
        case .leo: return "Jul 23 – Aug 22"
        case .virgo: return "Aug 23 – Sep 22"
        case .libra: return "Sep 23 – Oct 22"
        case .scorpio: return "Oct 23 – Nov 21"
        case .sagittarius: return "Nov 22 – Dec 21"
        case .capricorn: return "Dec 22 – Jan 19"
        case .aquarius: return "Jan 20 – Feb 18"
        case .pisces: return "Feb 19 – Mar 20"
        }
    }

    static func from(rawValue: String?) -> WesternZodiac? {
        guard let rawValue else { return nil }
        return WesternZodiac(rawValue: rawValue.lowercased())
    }
}
