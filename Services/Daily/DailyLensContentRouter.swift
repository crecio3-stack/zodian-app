import Foundation

protocol DailyLensCandidateProviding {
    func fetchCandidate(
        date: String,
        westernSign: String,
        easternSign: String
    ) async -> DailyLensCandidateV1?
}

/// Candidate routing is opt-in. Production continues to use the existing
/// six-field endpoint until an authenticated candidate provider is supplied.
/// Every non-accepted candidate result falls back to the production control.
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
        switch await DailyRitualService.shared.fetchDailyRitual(
            westernSign: westernSign,
            easternSign: easternSign
        ) {
        case .ready(let control):
            return .ready(await resolve(
                control: control,
                date: date,
                westernSign: westernSign,
                easternSign: easternSign
            ))
        case .notReady:
            return .notReady
        case .failed(let message):
            return .failed(message)
        }
    }

    /// Resolves an already-fetched production control row. UI callers must use
    /// this rather than deriving title/read from the control: only an accepted
    /// candidate is permitted to replace the six-field presentation.
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
/// Local-only candidate responses for simulator visual QA. This is deliberately
/// reachable only through an explicit launch argument and is compiled out of
/// Beta/Release builds. It exercises the same provider boundary used by a
/// future authenticated candidate transport without embedding a secret or
/// changing the production-control default.
enum DailyLensCandidateRuntimeFixture {
    static let launchArgument = "-ZodianDailyLensCandidateFixture"
    static let fullDailyLaunchArgument = "-ZodianDailyLensOpenFullDaily"

    static var shouldOpenFullDaily: Bool {
        ProcessInfo.processInfo.arguments.contains(fullDailyLaunchArgument)
    }

    static func routerIfRequested(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> DailyLensContentRouter? {
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
