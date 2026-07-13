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
        if policy == .candidateThenProductionControl,
           let candidateProvider,
           let candidate = await candidateProvider.fetchCandidate(
               date: date,
               westernSign: westernSign,
               easternSign: easternSign
           ),
           let content = candidate.acceptedContent,
           content.isReadyForDisplay {
            return .ready(content)
        }

        switch await DailyRitualService.shared.fetchDailyRitual(
            westernSign: westernSign,
            easternSign: easternSign
        ) {
        case .ready(let control):
            return .ready(DailyLensContent(control: control))
        case .notReady:
            return .notReady
        case .failed(let message):
            return .failed(message)
        }
    }
}
