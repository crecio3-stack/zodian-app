import Foundation

@MainActor
final class CrashReportingService {
    static let shared = CrashReportingService()

    private(set) var isInitialized = false
    private(set) var isTransportEnabled = false

    private init() {}

    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true

        OperationalLogger.info(
            "crash_reporting_initialized",
            category: .application,
            metadata: [
                "environment": AppConfiguration.environment.rawValue,
                "transport_enabled": "false"
            ]
        )
    }

    func setAccountIdentity(_ accountID: AccountID) {
        guard isTransportEnabled else { return }
    }

    func capture(_ error: OperationalError, metadata: [String: String]) {
        guard isTransportEnabled else { return }
    }
}
