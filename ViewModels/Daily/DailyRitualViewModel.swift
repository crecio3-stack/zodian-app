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
#if DEBUG
    @Published private(set) var debugLensRoutingDiagnostics: DailyLensDebugRoutingDiagnostics?
    @Published private(set) var debugEditorialVoiceV2RecognitionDiagnostics:
        TodaysLensEditorialVoiceV2RecognitionDiagnostics?
    @Published private(set) var debugEditorialVoiceV21Diagnostics: TodaysLensEditorialVoiceV21Amendment1Diagnostics?
    @Published private(set) var debugFreshnessMetadata: DailyRitualFetchMetadata?
#endif
    private var lastSuccessfulLoadKey: String?
    private var lastSuccessfulContent: DailyLensContent?
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
            AppConfiguration.environment.rawValue,
            localDateString(Date()),
            user.westernSign.displayName.lowercased(),
            user.chineseSign.displayName.lowercased()
        ].joined(separator: "")
    }

    func load(for user: UserProfile?) async {
#if DEBUG
        debugFreshnessMetadata = nil
        debugEditorialVoiceV2RecognitionDiagnostics = nil
        debugEditorialVoiceV21Diagnostics = nil
#endif
        guard let user else {
            state = .loading
            return
        }

        let westernSign = user.westernSign.displayName
        let easternSign = user.chineseSign.displayName
        let loadKey = requestKey(for: user)

#if DEBUG
        if DailyLensCandidateRuntimeFixture.isEditorialVoiceV2RecognitionEnabled {
            let date = localDateString(Date())
            let selection = TodaysLensEditorialVoiceV2RecognitionPreview.selection()
            guard let fixture = selection.fixture else {
                state = .empty
                resolvedLensContent = nil
                return
            }
            let fixtureControl =
                DailyLensCandidateRuntimeFixture.editorialVoiceV2RecognitionControlResponse(
                    fixture: fixture,
                    date: date
                )
            state = .loaded(fixtureControl)
            resolvedLensContent = await contentRouter.resolve(
                control: fixtureControl,
                date: date,
                westernSign: fixtureControl.westernSign ?? westernSign,
                easternSign: fixtureControl.easternSign ?? easternSign
            )
            debugEditorialVoiceV2RecognitionDiagnostics =
                TodaysLensEditorialVoiceV2RecognitionDiagnostics.make(
                    selection: selection
                )
            return
        }

        if DailyLensCandidateRuntimeFixture.isEditorialVoiceV21Amendment1Enabled {
            let date = localDateString(Date())
            let selection = TodaysLensEditorialVoiceV21Amendment1Preview.selection(
                date: date,
                westernSign: westernSign,
                easternSign: easternSign
            )

            guard let fixture = selection.fixture else {
                state = .empty
                resolvedLensContent = nil
                return
            }

            let fixtureControl = DailyLensCandidateRuntimeFixture.editorialVoiceV21Amendment1ControlResponse(
                fixture: fixture,
                date: date
            )
            state = .loaded(fixtureControl)
            resolvedLensContent = await contentRouter.resolve(
                control: fixtureControl,
                date: date,
                westernSign: fixtureControl.westernSign ?? westernSign,
                easternSign: fixtureControl.easternSign ?? easternSign
            )
            debugEditorialVoiceV21Diagnostics = TodaysLensEditorialVoiceV21Amendment1Diagnostics.make(
                selection: selection
            )
            return
        }

        if DailyLensCandidateRuntimeFixture.isSpokenVoiceV1Enabled {
            let date = localDateString(Date())
            let selection = TodaysLensSpokenVoiceV1.selection()
            let fixtureControl: DailyRitualResponse
            let fixtureWesternSign: String
            let fixtureEasternSign: String

            if let fixture = selection.fixture {
                fixtureControl = DailyLensCandidateRuntimeFixture.spokenVoiceV1ControlResponse(
                    fixture: fixture,
                    date: date,
                    westernSign: westernSign,
                    easternSign: easternSign
                )
                fixtureWesternSign = fixtureControl.westernSign ?? westernSign
                fixtureEasternSign = fixtureControl.easternSign ?? easternSign
            } else {
                // Unsupported DEBUG cases deliberately receive the frozen
                // fixture control. This branch occurs before both memory and
                // persisted cache restoration, so an old saved Lens cannot
                // mask the recorded fallback.
                fixtureControl = DailyLensCandidateRuntimeFixture.frozenV5ControlResponse(
                    date: date,
                    westernSign: westernSign,
                    easternSign: easternSign
                )
                fixtureWesternSign = fixtureControl.westernSign ?? westernSign
                fixtureEasternSign = fixtureControl.easternSign ?? easternSign
            }
            state = .loaded(fixtureControl)
            let resolved = await contentRouter.resolve(
                control: fixtureControl,
                date: date,
                westernSign: fixtureWesternSign,
                easternSign: fixtureEasternSign
            )
            resolvedLensContent = resolved
            debugLensRoutingDiagnostics = DailyLensDebugRoutingDiagnostics.spokenVoiceV1(
                selection: selection,
                displayed: resolved,
                control: fixtureControl
            )
            return
        }

        if DailyLensCandidateRuntimeFixture.isFrozenV5Enabled {
            let date = localDateString(Date())
            let fixtureControl = DailyLensCandidateRuntimeFixture.frozenV5ControlResponse(
                date: date,
                westernSign: westernSign,
                easternSign: easternSign
            )
            state = .loaded(fixtureControl)
            resolvedLensContent = await contentRouter.resolve(
                control: fixtureControl,
                date: date,
                westernSign: westernSign,
                easternSign: easternSign
            )
            return
        }
#endif

        if let cached = cachedContent(for: loadKey) ?? persistedContent(for: user) {
            rememberLoadedContent(cached, for: loadKey)
            log("cached read used before fetch")
            logLens("cached", content: cached)
            resolvedLensContent = cached
            state = .loaded(presentationEnvelope(for: cached))
            logLens("final rendered", content: cached)
            trackRuntimeLoad(content: cached, cacheResult: "hit")
#if DEBUG
            debugFreshnessMetadata = DailyRitualFetchMetadata(
                requestedDate: localDateString(Date()),
                returnedDate: cached.metadata.ritualDate ?? localDateString(Date()),
                freshness: cached.metadata.ritualDate == localDateString(Date()) ? .exact : .staleFallback,
                origin: .deviceCache,
                requestScope: .selfRead
            )
#endif
        } else {
            state = .loading
        }

        let outcome = await DailyRitualService.shared.fetchTodaysLens(
            westernSign: westernSign,
            easternSign: easternSign
        )

        switch outcome {
        case .ready(let content, let metadata):
            rememberLoadedContent(content, for: loadKey)
            logLens("network", content: content)
            resolvedLensContent = content
            state = .loaded(presentationEnvelope(for: content))
            logLens("final rendered", content: content)
            trackRuntimeLoad(content: content, cacheResult: "miss")
#if DEBUG
            debugFreshnessMetadata = metadata
#endif

        case .notReady:
            if let cached = cachedContent(for: loadKey) ?? persistedContent(for: user) {
                log("cached read used after incomplete response")
                logLens("cached fallback", content: cached)
                resolvedLensContent = cached
                state = .loaded(presentationEnvelope(for: cached))
                logLens("final rendered", content: cached)
                trackRuntimeLoad(content: cached, cacheResult: "fallback-hit")
            } else {
                state = .empty
                resolvedLensContent = nil
            }

        case .failed(let message):
            if let cached = cachedContent(for: loadKey) ?? persistedContent(for: user) {
                log("cached read used after failed fetch")
                logLens("cached fallback", content: cached)
                resolvedLensContent = cached
                state = .loaded(presentationEnvelope(for: cached))
                logLens("final rendered", content: cached)
                trackRuntimeLoad(content: cached, cacheResult: "fallback-hit")
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
        // `ritual` is a presentation envelope for existing view call sites.
        // The renderer always receives canonical title/read content.
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

    private func cachedContent(for loadKey: String) -> DailyLensContent? {
        guard lastSuccessfulLoadKey == loadKey else { return nil }
        return lastSuccessfulContent
    }

    private func rememberLoadedContent(_ content: DailyLensContent, for loadKey: String) {
        lastSuccessfulLoadKey = loadKey
        lastSuccessfulContent = content
        persistContent(content, for: loadKey)
    }

    private func persistContent(_ content: DailyLensContent, for loadKey: String) {
        cacheStore.saveRuntimeContent(
            content.runtime,
            metadata: content.metadata,
            for: persistenceKey(for: loadKey)
        )
    }

    private func persistedContent(for user: UserProfile) -> DailyLensContent? {
        guard let record = cacheStore.loadRuntimeRecord(
            for: persistenceKey(for: requestKey(for: user))
        ) else {
            return nil
        }
        if let legacy = record.legacyResponse {
            return LegacyDailyRitualAdapter.content(from: legacy)
        }
        return DailyLensContent(
            version: .editorialVoiceV21Amendment1,
            runtime: record.content,
            provenance: .candidate,
            metadata: record.metadata ?? TodaysLensRuntimeMetadata(
                generationResult: "cache-restored",
                validationResult: "previously-accepted",
                retryState: "cached-fallback"
            )
        )
    }

    private func presentationEnvelope(for content: DailyLensContent) -> DailyRitualResponse {
        DailyRitualResponse(
            id: content.metadata.id,
            ritualDate: content.metadata.ritualDate,
            westernSign: content.metadata.westernSign,
            easternSign: content.metadata.easternSign,
            title: content.title ?? "",
            intro: "",
            pullQuote: "",
            deeperRead: "",
            watchFor: "",
            move: "",
            ritualText: content.read,
            actionText: "",
            createdAt: content.metadata.createdAt,
            source: .structuredSupabaseRow
        )
    }

    private func trackRuntimeLoad(content: DailyLensContent, cacheResult: String) {
        let words = content.read.split(whereSeparator: \.isWhitespace).count
        let groups = content.read
            .components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
        AnalyticsService.shared.track(
            .todaysLensRuntimeLoaded(
                editorialVoiceVersion: content.metadata.editorialVoiceVersion,
                runtimeContractVersion: content.metadata.runtimeContractVersion,
                providerModel: content.metadata.providerModel,
                contentEnvironment: content.metadata.environment ?? "unknown",
                generationResult: content.metadata.generationResult,
                cacheResult: cacheResult,
                validationResult: content.metadata.validationResult,
                retryState: content.metadata.retryState,
                wordCount: words,
                thoughtGroupCount: groups
            )
        )
    }

    private func persistenceKey(for loadKey: String) -> String {
        "daily-ritual.last-good.\(loadKey)"
    }

    private func debugLogSource(_ source: DailyRitualSource) {
        print("[DailyRitualViewModel] Today’s Lens source: \(source.debugDescription)")
    }

    private func logLens(_ stage: String, content: DailyLensContent) {
#if DEBUG || BETA
        print(
            "[DailyRitualViewModel] \(stage) title/read: " +
            "\(String(reflecting: content.title)) / \(String(reflecting: content.read))"
        )
#endif
    }

    private func log(_ message: String) {
        print("[DailyRitualViewModel] \(message)")
    }
}
