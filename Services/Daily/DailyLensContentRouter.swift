import Foundation

protocol DailyLensCandidateProviding {
    func fetchCandidate(
        date: String,
        westernSign: String,
        easternSign: String
    ) async -> DailyLensCandidateV1?
}

/// Canonical title/read routing for DEBUG, Beta, and Release. A candidate
/// provider is available only to explicit DEBUG fixture overrides.
struct DailyLensContentRouter {
    enum Policy: Equatable {
        case productionControlOnly
        case candidateThenProductionControl
    }

    enum Outcome: Equatable {
        case ready(DailyLensContent)
        case notReady
        case failed(String)
    }

    let policy: Policy
    let candidateProvider: DailyLensCandidateProviding?

    init(
        policy: Policy = .productionControlOnly,
        candidateProvider: DailyLensCandidateProviding? = nil
    ) {
        self.policy = policy
        self.candidateProvider = candidateProvider
    }

    func fetch(
        date: String,
        westernSign: String,
        easternSign: String
    ) async -> Outcome {
        switch await DailyRitualService.shared.fetchTodaysLens(
            westernSign: westernSign,
            easternSign: easternSign
        ) {
        case .ready(let content, _):
            if let control = content.control {
                return .ready(await resolve(
                    control: control,
                    date: date,
                    westernSign: westernSign,
                    easternSign: easternSign
                ))
            }
            return .ready(content)
        case .notReady:
            return .notReady
        case .failed(let message):
            return .failed(message)
        }
    }

    /// Read-only legacy adapter used by historical archives and explicit DEBUG
    /// fixtures. Live Beta/Release fetches never enter this path.
    func resolve(
        control: DailyRitualResponse,
        date: String,
        westernSign: String,
        easternSign: String
    ) async -> DailyLensContent {
        if policy == .candidateThenProductionControl,
           let candidateProvider,
           let candidate = await candidateProvider.fetchCandidate(
               date: date,
               westernSign: westernSign,
               easternSign: easternSign
           ),
           let content = candidate.acceptedContent,
            content.isReadyForDisplay {
            return content
        }

        return DailyLensContent(control: control)
    }
}

#if DEBUG
/// Local-only provenance shown beside the shared Today’s Lens card during
/// Zodian Editorial Voice v1 review. It deliberately records whether cache/persistence
/// was bypassed, rather than inferring source from the rendered strings.
struct DailyLensDebugRoutingDiagnostics: Equatable {
    let sourceRequested: String
    let selectedSource: String
    let identity: String
    let arena: String
    let caseID: String
    let exactFixtureMatch: Bool
    let fallbackOccurred: Bool
    let fallbackReason: String?
    let origin: String
    let cacheAndPersistence: String

    static func spokenVoiceV1(
        selection: TodaysLensSpokenVoiceV1.Selection,
        displayed: DailyLensContent,
        control: DailyRitualResponse
    ) -> DailyLensDebugRoutingDiagnostics {
        let fixture = selection.fixture
        let isSpoken = displayed.version == .todaysLensZodianEditorialVoiceV1
        let isFrozenComparison = displayed.version == .productionCandidateFrozenWriterV1
        let fallback = !selection.isExactMatch || (!isSpoken && !isFrozenComparison)
        let controlWesternSign = control.westernSign ?? "unknown"
        let controlEasternSign = control.easternSign ?? "unknown"
        return DailyLensDebugRoutingDiagnostics(
            sourceRequested: "Zodian Editorial Voice v1",
            selectedSource: isSpoken ? "Zodian Editorial Voice v1" : "Frozen v5",
            identity: fixture?.identity ?? "\(controlWesternSign) × \(controlEasternSign)",
            arena: fixture?.arena ?? "unsupported",
            caseID: fixture?.id ?? "unsupported",
            exactFixtureMatch: selection.isExactMatch,
            fallbackOccurred: fallback,
            fallbackReason: fallback ? (selection.fallbackReason ?? "fixture did not resolve") : nil,
            origin: isSpoken || isFrozenComparison ? "fixture" : "frozen control fixture",
            cacheAndPersistence: "bypassed"
        )
    }
}

extension DailyLensCandidateRuntimeFixture {
    static let editorialVoiceV2RecognitionLaunchArgument =
        TodaysLensEditorialVoiceV2RecognitionPreview.launchArgument
    static let editorialVoiceV2RecognitionCaseIDArgument =
        TodaysLensEditorialVoiceV2RecognitionPreview.caseIDLaunchArgument

    static var isEditorialVoiceV2RecognitionEnabled: Bool {
        TodaysLensEditorialVoiceV2RecognitionPreview.isRuntimeRequested()
    }

    static func editorialVoiceV2RecognitionControlResponse(
        fixture: TodaysLensEditorialVoiceV2RecognitionPreview.Case,
        date: String
    ) -> DailyRitualResponse {
        TodaysLensEditorialVoiceV2RecognitionPreview.controlResponse(
            for: fixture,
            date: date
        )
    }

    static let editorialVoiceV21Amendment1LaunchArgument = TodaysLensEditorialVoiceV21Amendment1Preview.launchArgument
    static let editorialVoiceV21Amendment1CaseIDArgument = TodaysLensEditorialVoiceV21Amendment1Preview.caseIDLaunchArgument

    static var isEditorialVoiceV21Amendment1Enabled: Bool {
        TodaysLensEditorialVoiceV21Amendment1Preview.isRuntimeRequested()
    }

    static var editorialVoiceV21Amendment1Selection: TodaysLensEditorialVoiceV21Amendment1Preview.Selection {
        TodaysLensEditorialVoiceV21Amendment1Preview.selection(
            date: localPreviewDateString(Date()),
            westernSign: "unknown",
            easternSign: "unknown"
        )
    }

    static func editorialVoiceV21Amendment1ControlResponse(
        fixture: TodaysLensEditorialVoiceV21Amendment1Preview.Case,
        date: String
    ) -> DailyRitualResponse {
        TodaysLensEditorialVoiceV21Amendment1Preview.controlResponse(for: fixture, date: date)
    }

    static func editorialVoiceV21Amendment1CandidateIsAvailable(
        date: String,
        westernSign: String,
        easternSign: String
    ) -> Bool {
        guard isEditorialVoiceV21Amendment1Enabled else { return true }
        return TodaysLensEditorialVoiceV21Amendment1Preview.isCandidateAvailable(
            date: date,
            westernSign: westernSign,
            easternSign: easternSign
        )
    }

    private static func localPreviewDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

/// Local-only candidate responses for simulator visual QA. This is deliberately
/// reachable only through an explicit launch argument and is compiled out of
/// Beta/Release builds. It exercises the same provider boundary used by a
/// future authenticated candidate transport without embedding a secret or
/// changing the production-control default.
enum DailyLensCandidateRuntimeFixture {
    static let launchArgument = "-ZodianDailyLensCandidateFixture"
    static let frozenV5LaunchArgument = "-ZodianDailyLensFrozenV5Fixture"
    static let frozenV5IndexArgument = "-ZodianDailyLensFrozenV5FixtureIndex"
    static let spokenVoiceV1LaunchArgument = "-ZodianTodaysLensSpokenVoiceV1"
    static let zodianEditorialVoiceV1LaunchArgument = "-ZodianTodaysLensZodianEditorialVoiceV1"
    static let spokenVoiceV1IndexArgument = "-ZodianTodaysLensSpokenVoiceV1Index"
    /// Optional QA-only selector. It makes an unsupported-case fallback
    /// testable without changing any fixture or the signed-in user.
    static let spokenVoiceV1FixtureIDArgument = "-ZodianTodaysLensSpokenVoiceV1FixtureID"
    static let spokenVoiceV1UnavailableArgument = "-ZodianTodaysLensSpokenVoiceV1Unavailable"
    static let fullDailyLaunchArgument = "-ZodianDailyLensOpenFullDaily"

    static var shouldOpenFullDaily: Bool {
        ProcessInfo.processInfo.arguments.contains(fullDailyLaunchArgument)
    }

    static var isFrozenV5Enabled: Bool {
        ProcessInfo.processInfo.arguments.contains(frozenV5LaunchArgument)
    }

    static var isSpokenVoiceV1Enabled: Bool {
        ProcessInfo.processInfo.arguments.contains(spokenVoiceV1LaunchArgument)
            || ProcessInfo.processInfo.arguments.contains(zodianEditorialVoiceV1LaunchArgument)
    }

    static var frozenV5Metadata: String {
        let fixture = DailyLensFrozenV5Fixture.selected
        return "\(DailyLensFrozenV5Fixture.selectedIndex + 1)/\(DailyLensFrozenV5Fixture.cases.count) · \(fixture.identity) · \(fixture.arena)"
    }

    static func moveFrozenV5Fixture(by offset: Int) {
        DailyLensFrozenV5Fixture.move(by: offset)
    }

    static var spokenVoiceV1Metadata: String {
        let selection = TodaysLensSpokenVoiceV1.selection()
        guard let fixture = selection.fixture else {
            return "Frozen v5 fallback · \(selection.fallbackReason ?? "unsupported fixture")"
        }
        let index = TodaysLensSpokenVoiceV1.cases.firstIndex(of: fixture).map { $0 + 1 } ?? 0
        return "\(index)/\(TodaysLensSpokenVoiceV1.cases.count) · \(fixture.identity) · \(fixture.arena)"
    }

    static var spokenVoiceV1VariantLabel: String {
        TodaysLensSpokenVoiceV1.selectedVariant.label
    }

    static func moveSpokenVoiceV1Fixture(by offset: Int) {
        TodaysLensSpokenVoiceV1.move(by: offset)
    }

    static func toggleSpokenVoiceV1Variant() {
        TodaysLensSpokenVoiceV1.toggleVariant()
    }

    static func frozenV5ControlResponse(
        date: String,
        westernSign: String,
        easternSign: String
    ) -> DailyRitualResponse {
        let fixture = DailyLensFrozenV5Fixture.selected
        let identityParts = fixture.identity
            .split(separator: "×", maxSplits: 1, omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let fixtureWesternSign = identityParts.first ?? westernSign
        let fixtureEasternSign = identityParts.dropFirst().first ?? easternSign
        return DailyRitualResponse(
            id: fixture.id,
            ritualDate: date,
            westernSign: fixtureWesternSign,
            easternSign: fixtureEasternSign,
            title: fixture.title,
            intro: fixture.read,
            pullQuote: "",
            deeperRead: "",
            watchFor: "",
            move: "",
            ritualText: fixture.read,
            actionText: "",
            source: .structuredSupabaseRow
        )
    }

    static func spokenVoiceV1ControlResponse(
        fixture: TodaysLensSpokenVoiceV1.Case,
        date: String,
        westernSign: String,
        easternSign: String
    ) -> DailyRitualResponse {
        TodaysLensSpokenVoiceV1.controlResponse(
            for: fixture,
            date: date,
            westernSign: westernSign,
            easternSign: easternSign
        )
    }

    static func routerIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> DailyLensContentRouter? {
        if arguments.contains(editorialVoiceV2RecognitionLaunchArgument) {
            precondition(
                TodaysLensEditorialVoiceV2RecognitionPreview.isValid,
                "Recognition Pass must contain exactly 20 validated DEBUG fixtures."
            )
            if let caseIndex = arguments.firstIndex(
                of: editorialVoiceV2RecognitionCaseIDArgument
            ), arguments.indices.contains(caseIndex + 1) {
                _ = TodaysLensEditorialVoiceV2RecognitionPreview.select(
                    caseID: arguments[caseIndex + 1]
                )
            }
            return DailyLensContentRouter(
                policy: .candidateThenProductionControl,
                candidateProvider: TodaysLensEditorialVoiceV2RecognitionPreview.Provider(
                    arguments: arguments
                )
            )
        }

        if arguments.contains(editorialVoiceV21Amendment1LaunchArgument) {
            precondition(
                TodaysLensEditorialVoiceV21Amendment1Preview.isValid,
                "Editorial Voice v2.1 Amendment 1 must contain exactly 56 valid production-candidate fixtures."
            )

            if let caseArgumentIndex = arguments.firstIndex(of: editorialVoiceV21Amendment1CaseIDArgument),
               arguments.indices.contains(caseArgumentIndex + 1) {
                _ = TodaysLensEditorialVoiceV21Amendment1Preview.select(
                    caseID: arguments[caseArgumentIndex + 1]
                )
            }

            return DailyLensContentRouter(
                policy: .candidateThenProductionControl,
                candidateProvider: TodaysLensEditorialVoiceV21Amendment1Preview.Provider(arguments: arguments)
            )
        }

        if arguments.contains(spokenVoiceV1LaunchArgument) || arguments.contains(zodianEditorialVoiceV1LaunchArgument) {
            precondition(TodaysLensSpokenVoiceV1.isValid, "Zodian Editorial Voice v1 must contain exactly eight complete review fixtures.")
            if let indexArgument = arguments.firstIndex(of: spokenVoiceV1IndexArgument),
               arguments.indices.contains(indexArgument + 1),
               let index = Int(arguments[indexArgument + 1]) {
                TodaysLensSpokenVoiceV1.selectedIndex = index
            }
            // A comparison toggle from a previous simulator run must never
            // make a new Spoken Voice launch silently render frozen v5 copy.
            TodaysLensSpokenVoiceV1.selectedVariant = .spokenVoice

            return DailyLensContentRouter(
                policy: .candidateThenProductionControl,
                candidateProvider: TodaysLensSpokenVoiceV1.Provider(
                    arguments: arguments
                )
            )
        }

        if arguments.contains(frozenV5LaunchArgument) {
            precondition(DailyLensFrozenV5Fixture.isValid, "Frozen v5 UI fixture must contain exactly 31 non-empty cases.")
            if let indexArgument = arguments.firstIndex(of: frozenV5IndexArgument),
               arguments.indices.contains(indexArgument + 1),
               let index = Int(arguments[indexArgument + 1]) {
                DailyLensFrozenV5Fixture.selectedIndex = index
            }

            return DailyLensContentRouter(
                policy: .candidateThenProductionControl,
                candidateProvider: Provider(fixture: .frozenV5)
            )
        }

        guard let argumentIndex = arguments.firstIndex(of: launchArgument),
              arguments.indices.contains(argumentIndex + 1),
              let fixture = Fixture(rawValue: arguments[argumentIndex + 1]) else {
            return nil
        }

        return DailyLensContentRouter(
            policy: .candidateThenProductionControl,
            candidateProvider: Provider(fixture: fixture)
        )
    }

    private enum Fixture: String {
        case frozenV5
        case accepted
        case blocked
        case malformed
        case unavailable
    }

    private struct Provider: DailyLensCandidateProviding {
        let fixture: Fixture

        func fetchCandidate(
            date: String,
            westernSign: String,
            easternSign: String
        ) async -> DailyLensCandidateV1? {
            switch fixture {
            case .frozenV5:
                let frozen = DailyLensFrozenV5Fixture.selected
                return DailyLensCandidateV1(
                    version: .productionCandidateFrozenWriterV1,
                    status: .accepted,
                    title: frozen.title,
                    read: frozen.read,
                    reasonCode: frozen.id
                )
            case .accepted:
                return DailyLensCandidateV1(
                    version: .productionCandidateV1,
                    status: .accepted,
                    title: "Keep your own signal",
                    read: "You can meet the room without editing yourself down. Let your first clear instinct stand, then make only the adjustment that keeps the conversation honest.",
                    reasonCode: nil
                )
            case .blocked:
                return DailyLensCandidateV1(
                    version: .productionCandidateV1,
                    status: .blocked,
                    title: nil,
                    read: nil,
                    reasonCode: "qa_blocked"
                )
            case .malformed:
                return DailyLensCandidateV1(
                    version: .productionCandidateV1,
                    status: .accepted,
                    title: "Incomplete candidate",
                    read: nil,
                    reasonCode: "qa_malformed"
                )
            case .unavailable:
                return nil
            }
        }
    }
}
#endif
