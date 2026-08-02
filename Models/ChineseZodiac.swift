// ChineseZodiac.swift

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

    var assetName: String {
        switch self {
        case .rat: return "zodiac_rat"
        case .ox: return "zodiac_ox"
        case .tiger: return "zodiac_tiger"
        case .rabbit: return "zodiac_rabbit"
        case .dragon: return "zodiac_dragon"
        case .snake: return "zodiac_snake"
        case .horse: return "zodiac_horse"
        case .goat: return "zodiac_goat"
        case .monkey: return "zodiac_monkey"
        case .rooster: return "zodiac_rooster"
        case .dog: return "zodiac_dog"
        case .pig: return "zodiac_pig"
        }
    }

    // MARK: - Cycle Mapping

    static func from(year: Int) -> ChineseZodiac {
        // Rat years: ..., 2008, 2020, 2032 ...
        let baseYear = 2020
        let offset = (year - baseYear) % 12
        let index = (offset + 12) % 12
        return ChineseZodiac.allCases[index]
    }

    static func from(date: Date, calendar: Calendar = .current) -> ChineseZodiac {
        let birthYear = calendar.component(.year, from: date)

        guard let chineseNewYear = chineseNewYearDate(forGregorianYear: birthYear, calendar: calendar) else {
            // Fallback if outside supported lookup range
            return from(year: birthYear)
        }

        let zodiacYear = date < chineseNewYear ? birthYear - 1 : birthYear
        return from(year: zodiacYear)
    }

    static func from(rawValue: String?) -> ChineseZodiac? {
        guard let rawValue else { return nil }
        return ChineseZodiac(rawValue: rawValue.lowercased())
    }

    // MARK: - Chinese New Year Lookup
    // These dates are the start dates of the lunar new year for the Gregorian year shown.
    // This directly fixes the Jan / early-Feb issue Suzanne White calls out.

    private static let chineseNewYearMonthDayByYear: [Int: (month: Int, day: Int)] = [
        1900: (1, 31), 1901: (2, 19), 1902: (2, 8), 1903: (1, 29), 1904: (2, 16),
        1905: (2, 4), 1906: (1, 25), 1907: (2, 13), 1908: (2, 2), 1909: (1, 22),
        1910: (2, 10), 1911: (1, 30), 1912: (2, 18), 1913: (2, 6), 1914: (1, 26),
        1915: (2, 14), 1916: (2, 3), 1917: (1, 23), 1918: (2, 11), 1919: (2, 1),
        1920: (2, 20), 1921: (2, 8), 1922: (1, 28), 1923: (2, 16), 1924: (2, 5),
        1925: (1, 24), 1926: (2, 13), 1927: (2, 2), 1928: (1, 23), 1929: (2, 10),
        1930: (1, 30), 1931: (2, 17), 1932: (2, 6), 1933: (1, 26), 1934: (2, 14),
        1935: (2, 4), 1936: (1, 24), 1937: (2, 11), 1938: (1, 31), 1939: (2, 19),
        1940: (2, 8), 1941: (1, 27), 1942: (2, 15), 1943: (2, 5), 1944: (1, 25),
        1945: (2, 13), 1946: (2, 2), 1947: (1, 22), 1948: (2, 10), 1949: (1, 29),
        1950: (2, 17), 1951: (2, 6), 1952: (1, 27), 1953: (2, 14), 1954: (2, 3),
        1955: (1, 24), 1956: (2, 12), 1957: (1, 31), 1958: (2, 18), 1959: (2, 8),
        1960: (1, 28), 1961: (2, 15), 1962: (2, 5), 1963: (1, 25), 1964: (2, 13),
        1965: (2, 2), 1966: (1, 21), 1967: (2, 9), 1968: (1, 30), 1969: (2, 17),
        1970: (2, 6), 1971: (1, 27), 1972: (2, 15), 1973: (2, 3), 1974: (1, 23),
        1975: (2, 11), 1976: (1, 31), 1977: (2, 18), 1978: (2, 7), 1979: (1, 28),
        1980: (2, 16), 1981: (2, 5), 1982: (1, 25), 1983: (2, 13), 1984: (2, 2),
        1985: (2, 20), 1986: (2, 9), 1987: (1, 29), 1988: (2, 17), 1989: (2, 6),
        1990: (1, 27), 1991: (2, 15), 1992: (2, 4), 1993: (1, 23), 1994: (2, 10),
        1995: (1, 31), 1996: (2, 19), 1997: (2, 7), 1998: (1, 28), 1999: (2, 16),
        2000: (2, 5), 2001: (1, 24), 2002: (2, 12), 2003: (2, 1), 2004: (1, 22),
        2005: (2, 9), 2006: (1, 29), 2007: (2, 18), 2008: (2, 7), 2009: (1, 26),
        2010: (2, 14), 2011: (2, 3), 2012: (1, 23), 2013: (2, 10), 2014: (1, 31),
        2015: (2, 19), 2016: (2, 8), 2017: (1, 28), 2018: (2, 16), 2019: (2, 5),
        2020: (1, 25), 2021: (2, 12), 2022: (2, 1), 2023: (1, 22), 2024: (2, 10),
        2025: (1, 29), 2026: (2, 17), 2027: (2, 6), 2028: (1, 26), 2029: (2, 13),
        2030: (2, 3), 2031: (1, 23), 2032: (2, 11), 2033: (1, 31), 2034: (2, 19),
        2035: (2, 8), 2036: (1, 28), 2037: (2, 15), 2038: (2, 4), 2039: (1, 24),
        2040: (2, 12), 2041: (2, 1), 2042: (1, 22), 2043: (2, 10), 2044: (1, 30),
        2045: (2, 17), 2046: (2, 6), 2047: (1, 26), 2048: (2, 14), 2049: (2, 2),
        2050: (1, 23)
    ]

    private static func chineseNewYearDate(forGregorianYear year: Int, calendar: Calendar) -> Date? {
        guard let monthDay = chineseNewYearMonthDayByYear[year] else { return nil }

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = monthDay.month
        components.day = monthDay.day
        components.hour = 12 // midday avoids DST edge weirdness

        return calendar.date(from: components)
    }
}
