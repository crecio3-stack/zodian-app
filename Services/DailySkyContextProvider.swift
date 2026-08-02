import Foundation

struct DailySkyContext: Codable, Equatable {
    let date: Date
    let moonPhase: String
    let moonSign: WesternZodiac
    let sunSign: WesternZodiac
    let majorTheme: String
    let tone: String
}

enum DailySkyContextProvider {
    static func context(for date: Date = Date()) -> DailySkyContext {
        let sunLongitude = solarLongitude(for: date)
        let moonLongitude = lunarLongitude(for: date)
        let phaseAngle = normalizedDegrees(moonLongitude - sunLongitude)

        let moonPhase = moonPhaseLabel(for: phaseAngle)
        let moonSign = zodiacSign(forLongitude: moonLongitude)
        let sunSign = zodiacSign(forLongitude: sunLongitude)
        let tone = toneLabel(for: moonSign)
        let majorTheme = majorTheme(for: phaseAngle, moonSign: moonSign)

        return DailySkyContext(
            date: date,
            moonPhase: moonPhase,
            moonSign: moonSign,
            sunSign: sunSign,
            majorTheme: majorTheme,
            tone: tone
        )
    }

    private static func solarLongitude(for date: Date) -> Double {
        let d = daysSinceJ2000(for: date)
        let meanLongitude = normalizedDegrees(280.460 + 0.9856474 * d)
        let meanAnomaly = normalizedDegrees(357.528 + 0.9856003 * d)
        let anomalyRadians = meanAnomaly * .pi / 180

        return normalizedDegrees(
            meanLongitude
                + 1.915 * sin(anomalyRadians)
                + 0.020 * sin(2 * anomalyRadians)
        )
    }

    private static func lunarLongitude(for date: Date) -> Double {
        let d = daysSinceJ2000(for: date)
        let l0 = normalizedDegrees(218.316 + 13.176396 * d)
        let mMoon = normalizedDegrees(134.963 + 13.064993 * d)
        let mSun = normalizedDegrees(357.529 + 0.98560028 * d)
        let elongation = normalizedDegrees(297.850 + 12.190749 * d)

        let l0r = l0 * .pi / 180
        let mMoonR = mMoon * .pi / 180
        let mSunR = mSun * .pi / 180
        let elongationR = elongation * .pi / 180

        let longitude =
            l0r
            + (6.289 * .pi / 180) * sin(mMoonR)
            + (1.274 * .pi / 180) * sin(2 * elongationR - mMoonR)
            + (0.658 * .pi / 180) * sin(2 * elongationR)
            + (0.214 * .pi / 180) * sin(2 * mMoonR)
            - (0.186 * .pi / 180) * sin(mSunR)

        return normalizedDegrees(longitude * 180 / .pi)
    }

    private static func zodiacSign(forLongitude longitude: Double) -> WesternZodiac {
        let signs = WesternZodiac.allCases
        let index = Int(floor(normalizedDegrees(longitude) / 30.0)) % signs.count
        return signs[index]
    }

    private static func moonPhaseLabel(for phaseAngle: Double) -> String {
        switch phaseAngle {
        case 0..<22.5, 337.5..<360:
            return "New Moon"
        case 22.5..<67.5:
            return "Waxing Crescent"
        case 67.5..<112.5:
            return "First Quarter"
        case 112.5..<157.5:
            return "Waxing Gibbous"
        case 157.5..<202.5:
            return "Full Moon"
        case 202.5..<247.5:
            return "Waning Gibbous"
        case 247.5..<292.5:
            return "Last Quarter"
        default:
            return "Waning Crescent"
        }
    }

    private static func toneLabel(for moonSign: WesternZodiac) -> String {
        switch moonSign {
        case .aries, .leo, .sagittarius:
            return "bold"
        case .taurus, .virgo, .capricorn:
            return "steady"
        case .gemini, .libra, .aquarius:
            return "social"
        case .cancer, .scorpio, .pisces:
            return "deep"
        }
    }

    private static func majorTheme(for phaseAngle: Double, moonSign: WesternZodiac) -> String {
        let phaseTheme: String

        switch phaseAngle {
        case 0..<67.5:
            phaseTheme = "reset"
        case 67.5..<157.5:
            phaseTheme = "build"
        case 157.5..<247.5:
            phaseTheme = "feel"
        default:
            phaseTheme = "release"
        }

        let signTheme: String
        switch moonSign {
        case .aries, .leo, .sagittarius:
            signTheme = "courage"
        case .taurus, .virgo, .capricorn:
            signTheme = "grounding"
        case .gemini, .libra, .aquarius:
            signTheme = "clarity"
        case .cancer, .scorpio, .pisces:
            signTheme = "emotion"
        }

        return "\(phaseTheme)-\(signTheme)"
    }

    private static func daysSinceJ2000(for date: Date) -> Double {
        let reference = Date(timeIntervalSince1970: 946728000) // 2000-01-01 12:00:00 UTC
        return date.timeIntervalSince(reference) / 86400
    }

    private static func normalizedDegrees(_ value: Double) -> Double {
        let normalized = value.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
}
