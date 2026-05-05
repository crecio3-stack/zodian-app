import Foundation

struct FamousPattern: Identifiable, Equatable {
    let id: String
    let name: String
    let western: WesternZodiac?
    let chinese: ChineseZodiac?
    let patternTitle: String
    let line: String

    init(
        name: String,
        western: WesternZodiac? = nil,
        chinese: ChineseZodiac? = nil,
        line: String
    ) {
        self.name = name
        self.western = western
        self.chinese = chinese
        self.patternTitle = FamousPatternCatalog.patternTitle(western: western, chinese: chinese)
        self.line = line
        self.id = "\(name)-\(patternTitle)"
    }
}

enum FamousPatternCatalog {
    static func exactPattern(for profileID: String) -> FamousPattern? {
        let pair = parseProfileID(profileID)

        guard let western = pair.western,
              let chinese = pair.chinese else {
            return nil
        }

        return exactMatches.first(where: { $0.western == western && $0.chinese == chinese })
    }

    static func pattern(for profileID: String) -> FamousPattern {
        let pair = parseProfileID(profileID)

        if let western = pair.western,
           let chinese = pair.chinese,
           let exact = exactMatches.first(where: { $0.western == western && $0.chinese == chinese }) {
            return exact
        }

        if let western = pair.western,
           let westernFallback = westernFallbacks.first(where: { $0.western == western }) {
            return westernFallback
        }

        if let chinese = pair.chinese,
           let chineseFallback = chineseFallbacks.first(where: { $0.chinese == chinese }) {
            return chineseFallback
        }

        return FamousPattern(
            name: "Famous pattern",
            western: nil,
            chinese: nil,
            line: "More curated matches are still being added"
        )
    }

    static func patternTitle(western: WesternZodiac?, chinese: ChineseZodiac?) -> String {
        switch (western, chinese) {
        case let (.some(western), .some(chinese)):
            return "\(western.displayName) × \(chinese.displayName)"
        case let (.some(western), .none):
            return western.displayName
        case let (.none, .some(chinese)):
            return chinese.displayName
        case (.none, .none):
            return "Unknown Pattern"
        }
    }

    private static func parseProfileID(_ id: String) -> (western: WesternZodiac?, chinese: ChineseZodiac?) {
        let parts = id
            .lowercased()
            .split(separator: "-", maxSplits: 1)
            .map(String.init)

        guard parts.count == 2 else {
            return (nil, nil)
        }

        return (
            WesternZodiac(rawValue: parts[0]),
            ChineseZodiac(rawValue: parts[1])
        )
    }

    private static let exactMatches = FamousPatternData.exactMatches

    private static let westernFallbacks: [FamousPattern] = [
        FamousPattern(name: "Lady Gaga", western: .aries, line: "Aries moves first and lets the room catch up"),
        FamousPattern(name: "Adele", western: .taurus, line: "Taurus makes feeling tangible, rich, and impossible to rush"),
        FamousPattern(name: "Kanye West", western: .gemini, line: "Gemini turns contradiction into a whole language"),
        FamousPattern(name: "Ariana Grande", western: .cancer, line: "Cancer leads with feeling, but controls what gets seen"),
        FamousPattern(name: "Jennifer Lopez", western: .leo, line: "Leo knows presence is not an accident"),
        FamousPattern(name: "Beyoncé", western: .virgo, line: "Virgo turns detail into power"),
        FamousPattern(name: "Kim Kardashian", western: .libra, line: "Libra understands image, balance, and the power of being watched"),
        FamousPattern(name: "Drake", western: .scorpio, line: "Scorpio remembers everything and turns feeling into strategy"),
        FamousPattern(name: "Taylor Swift", western: .sagittarius, line: "Sagittarius keeps reaching for the bigger story"),
        FamousPattern(name: "Michelle Obama", western: .capricorn, line: "Capricorn carries authority without needing to announce it"),
        FamousPattern(name: "Megan Thee Stallion", western: .aquarius, line: "Aquarius refuses the box and builds a new lane instead"),
        FamousPattern(name: "Rihanna", western: .pisces, line: "Pisces makes mystery feel effortless")
    ]

    private static let chineseFallbacks: [FamousPattern] = [
        FamousPattern(name: "Zendaya", chinese: .rat, line: "Rat energy notices the opening before anyone says it out loud"),
        FamousPattern(name: "Barack Obama", chinese: .ox, line: "Ox energy moves with patience, weight, and long-game control"),
        FamousPattern(name: "Lady Gaga", chinese: .tiger, line: "Tiger energy does not ask permission to take up space"),
        FamousPattern(name: "David Beckham", chinese: .rabbit, line: "Rabbit energy understands style, restraint, and social timing"),
        FamousPattern(name: "Rihanna", chinese: .dragon, line: "Dragon energy pulls focus even when it is standing still"),
        FamousPattern(name: "Kim Kardashian", chinese: .snake, line: "Snake energy watches, waits, and moves when the room is ready"),
        FamousPattern(name: "Denzel Washington", chinese: .horse, line: "Horse energy needs freedom, momentum, and room to move"),
        FamousPattern(name: "Bill Gates", chinese: .goat, line: "Goat energy builds through sensitivity, taste, and quiet persistence"),
        FamousPattern(name: "Selena Gomez", chinese: .monkey, line: "Monkey energy adapts fast and rarely misses the shift"),
        FamousPattern(name: "Beyoncé", chinese: .rooster, line: "Rooster energy sharpens the details until the whole room feels it"),
        FamousPattern(name: "Bad Bunny", chinese: .dog, line: "Dog energy reads trust first and remembers what feels real"),
        FamousPattern(name: "Megan Thee Stallion", chinese: .pig, line: "Pig energy gives generously, but only where it feels respected")
    ]
}
