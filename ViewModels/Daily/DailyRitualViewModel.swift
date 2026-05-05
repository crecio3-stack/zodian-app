import Foundation
import Combine

@MainActor
final class DailyRitualViewModel: ObservableObject {
    enum LoadState: Equatable {
        case loading
        case loaded(DailyRitualResponse)
        case empty
        case failed(String)
    }

    @Published private(set) var state: LoadState = .loading

    var phase: Phase {
        switch state {
        case .loading:
            return .loading
        case .loaded:
            return .loaded
        case .empty:
            return .empty
        case .failed(let message):
            return .failed(message)
        }
    }

    enum Phase: Equatable {
        case loading
        case loaded
        case empty
        case failed(String)
    }

    func requestKey(for user: UserProfile?) -> String {
        guard let user else { return "daily-ritual.no-user" }
        return [
            "daily-ritual",
            utcDateString(Date()),
            user.westernSign.displayName.lowercased(),
            user.chineseSign.displayName.lowercased()
        ].joined(separator: "")
    }

    func load(for user: UserProfile?) async {
        guard let user else {
            state = .loading
            return
        }

        let westernSign = user.westernSign.displayName
        let easternSign = user.chineseSign.displayName

        state = .loading

        do {
            let ritual = try await DailyRitualService.shared.fetchDailyRitual(
                westernSign: westernSign,
                easternSign: easternSign
            )

            if let ritual {
                state = .loaded(ritual)
            } else if let fallback = fallbackRitual(for: user) {
                state = .loaded(fallback)
            } else {
                state = .empty
            }
        } catch {
            if let fallback = fallbackRitual(for: user) {
                state = .loaded(fallback)
            } else {
                state = .failed(
                    (error as? LocalizedError)?.errorDescription
                    ?? error.localizedDescription
                )
            }
        }
    }

    func reload(for user: UserProfile?) async {
        await load(for: user)
    }

    private func utcDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func fallbackRitual(for user: UserProfile) -> DailyRitualResponse? {
        guard let archetype = ArchetypeService.shared.archetypeIfLoaded(forId: user.archetypeId) else {
            return nil
        }

        let date = Date()
        let reading = DailyReadingGenerator.generate(
            context: .init(
                archetype: archetype,
                user: user,
                streak: nil,
                date: date,
                skyContext: DailySkyContextProvider.context(for: date)
            )
        )

        let ritualText = [
            reading.insight,
            reading.focus,
            reading.caution
        ]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return DailyRitualResponse(
            id: "local-\(utcDateString(date))-\(archetype.id)",
            ritualDate: utcDateString(date),
            westernSign: reading.westernSign.displayName,
            easternSign: reading.chineseSign.displayName,
            title: "\(reading.westernSign.displayName) × \(reading.chineseSign.displayName): Today's Pattern",
            ritualText: ritualText,
            actionText: reading.affirmation,
            createdAt: nil
        )
    }
}
