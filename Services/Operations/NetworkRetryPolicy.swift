import Foundation

struct NetworkRetryPolicy: Sendable {
    static let standard = NetworkRetryPolicy(
        maximumRetryCount: 3,
        initialDelay: 0.75,
        multiplier: 2,
        maximumDelay: 3
    )

    let maximumRetryCount: Int
    let initialDelay: TimeInterval
    let multiplier: Double
    let maximumDelay: TimeInterval

    func delayNanoseconds(beforeRetry retry: Int) -> UInt64? {
        guard retry > 0, retry <= maximumRetryCount else { return nil }
        let delay = min(initialDelay * pow(multiplier, Double(retry - 1)), maximumDelay)
        return UInt64(delay * 1_000_000_000)
    }

    func shouldRetry(statusCode: Int) -> Bool {
        statusCode == 408 || statusCode == 429 || (500...599).contains(statusCode)
    }

    func shouldRetry(error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }

        switch urlError.code {
        case .timedOut,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .networkConnectionLost,
             .notConnectedToInternet,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed:
            return true
        default:
            return false
        }
    }
}
