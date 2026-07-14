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
    @Published private(set) var resolvedLensContent: DailyLensContent?
    private var lastSuccessfulLoadKey: String?
    private var lastSuccessfulRitual: DailyRitualResponse?
    private let cacheStore = DailyRitualCacheStore.shared
    private let contentRouter: DailyLensContentRouter

    init(contentRouter: DailyLensContentRouter? = nil) {
        self.contentRouter = contentRouter ?? Self.defaultContentRouter()
    }

    private static func defaultContentRouter() -> DailyLensContentRouter {
#if DEBUG
        return DailyLensCandidateRuntimeFixture.routerIfRequested()
            ?? DailyLensContentRouter()
#else
        return DailyLensContentRouter()
#endif
    }

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
            "daily-ritual-v2",
            localDateString(Date()),
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
        let loadKey = requestKey(for: user)

        if let cached = cachedRitual(for: loadKey) ?? persistedRitual(for: user) {
            rememberLoadedRitual(cached, for: loadKey)
            log("cached read used before fetch")
            debugLogSource(cached.source)
            state = .loaded(cached)
            resolvedLensContent = DailyLensContent(control: cached)
        } else {
            state = .loading
        }

        let outcome = await DailyRitualService.shared.fetchDailyRitual(
            westernSign: westernSign,
            easternSign: easternSign
        )

        switch outcome {
        case .ready(let ritual):
            rememberLoadedRitual(ritual, for: loadKey)
            debugLogSource(ritual.source)
            state = .loaded(ritual)
            resolvedLensContent = await contentRouter.resolve(
                control: ritual,
                date: localDateString(Date()),
                westernSign: westernSign,
                easternSign: easternSign
            )

        case .notReady:
            if let cached = cachedRitual(for: loadKey) ?? persistedRitual(for: user) {
                log("cached read used after incomplete response")
                debugLogSource(cached.source)
                state = .loaded(cached)
                resolvedLensContent = DailyLensContent(control: cached)
            } else {
                state = .empty
                resolvedLensContent = nil
            }

        case .failed(let message):
            if let cached = cachedRitual(for: loadKey) ?? persistedRitual(for: user) {
                log("cached read used after failed fetch")
                debugLogSource(cached.source)
                state = .loaded(cached)
                resolvedLensContent = DailyLensContent(control: cached)
            } else {
                state = .failed(message)
                resolvedLensContent = nil
            }
        }
    }

    func reload(for user: UserProfile?) async {
        await load(for: user)
    }

    func lensContent(for ritual: DailyRitualResponse) -> DailyLensContent {
        // A stale candidate must never survive a refreshed or cached control
        // row. The control is the safe default for every unresolved state.
        resolvedLensContent ?? DailyLensContent(control: ritual)
    }

    private func localDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func cachedRitual(for loadKey: String) -> DailyRitualResponse? {
        guard lastSuccessfulLoadKey == loadKey else { return nil }
        return lastSuccessfulRitual
    }

    private func rememberLoadedRitual(_ ritual: DailyRitualResponse, for loadKey: String) {
        lastSuccessfulLoadKey = loadKey
        lastSuccessfulRitual = ritual
        persistRitual(ritual, for: loadKey)
    }

    private func persistRitual(_ ritual: DailyRitualResponse, for loadKey: String) {
        cacheStore.save(ritual, for: persistenceKey(for: loadKey))
    }

    private func persistedRitual(for user: UserProfile) -> DailyRitualResponse? {
        cacheStore.load(for: persistenceKey(for: requestKey(for: user)))
    }

    private func persistenceKey(for loadKey: String) -> String {
        "daily-ritual.last-good.\(loadKey)"
    }

    private func debugLogSource(_ source: DailyRitualSource) {
        print("[DailyRitualViewModel] Today’s Lens source: \(source.debugDescription)")
    }

    private func log(_ message: String) {
        print("[DailyRitualViewModel] \(message)")
    }
}
