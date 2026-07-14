import Foundation
import SwiftData

/// DEBUG-only checks for the Read Someone contract. No account, network, writer,
/// or production data is involved.
enum ReadSomeoneValidationHarness {
    static func run() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let before2026NewYear = date(2026, 2, 16, calendar: calendar)
        let after2026NewYear = date(2026, 2, 17, calendar: calendar)
        precondition(AstrologyCalculator.chineseZodiac(forBirthDate: before2026NewYear, calendar: calendar) == .snake)
        precondition(AstrologyCalculator.chineseZodiac(forBirthDate: after2026NewYear, calendar: calendar) == .horse)

        let person = SavedPerson(
            name: "Validation Person",
            birthDate: date(1990, 5, 28, calendar: calendar),
            westernSignRaw: AstrologyCalculator.westernZodiac(from: date(1990, 5, 28, calendar: calendar), calendar: calendar).rawValue,
            chineseSignRaw: AstrologyCalculator.chineseZodiac(forBirthDate: date(1990, 5, 28, calendar: calendar), calendar: calendar).rawValue
        )
        let reading = DailyReadingGenerator.generate(context: .init(archetype: person.archetype, user: nil, streak: nil))
        precondition(reading.westernSign == person.westernSign)
        precondition(reading.chineseSign == person.chineseSign)
        precondition(person.lensCacheKey(on: before2026NewYear, calendar: calendar).contains(person.westernSignRaw))
        precondition(person.lensCacheKey(on: before2026NewYear, calendar: calendar).contains(person.chineseSignRaw))

        OperationalLogger.debug("read_someone_validation_passed", category: .persistence)
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}
