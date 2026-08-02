import Foundation
import OSLog

enum OperationalCategory: String, Sendable {
    case account
    case analytics
    case application
    case configuration
    case content
    case featureFlags = "feature_flags"
    case network
    case notifications
    case persistence
}

enum OperationalErrorKind: String, Sendable {
    case authentication
    case configuration
    case decoding
    case invariantViolation = "invariant_violation"
    case network
    case notFound = "not_found"
    case permission
    case persistence
    case rateLimited = "rate_limited"
    case server
    case timeout
    case unavailable
    case unknown
}

struct OperationalError: Error, Sendable {
    let kind: OperationalErrorKind
    let category: OperationalCategory
    let code: String
    let underlyingType: String?

    init(
        kind: OperationalErrorKind,
        category: OperationalCategory,
        code: String,
        underlyingError: Error? = nil
    ) {
        self.kind = kind
        self.category = category
        self.code = code
        self.underlyingType = underlyingError.map { String(reflecting: type(of: $0)) }
    }
}

enum OperationalLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.zodian.app"

    static func debug(
        _ message: String,
        category: OperationalCategory,
        metadata: [String: String] = [:]
    ) {
#if DEBUG
        logger(for: category).debug("\(formatted(message, metadata: metadata), privacy: .public)")
#endif
    }

    static func info(
        _ message: String,
        category: OperationalCategory,
        metadata: [String: String] = [:]
    ) {
        logger(for: category).info("\(formatted(message, metadata: metadata), privacy: .public)")
    }

    static func warning(
        _ message: String,
        category: OperationalCategory,
        metadata: [String: String] = [:]
    ) {
        logger(for: category).warning("\(formatted(message, metadata: metadata), privacy: .public)")
    }

    static func error(
        _ error: OperationalError,
        metadata: [String: String] = [:]
    ) {
        var safeMetadata = metadata
        safeMetadata["error_kind"] = error.kind.rawValue
        safeMetadata["error_code"] = error.code
        if let underlyingType = error.underlyingType {
            safeMetadata["underlying_type"] = underlyingType
        }

        logger(for: error.category).error(
            "\(formatted("operation_failed", metadata: safeMetadata), privacy: .public)"
        )

        CrashReportingService.shared.capture(error, metadata: safeMetadata)
    }

    private static func logger(for category: OperationalCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    private static func formatted(_ message: String, metadata: [String: String]) -> String {
        let safeMessage = sanitize(message)
        guard !metadata.isEmpty else { return safeMessage }

        let suffix = metadata
            .sorted { $0.key < $1.key }
            .map { "\(sanitize($0.key))=\(sanitize($0.value))" }
            .joined(separator: " ")

        return "\(safeMessage) \(suffix)"
    }

    private static func sanitize(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .prefix(240)
            .description
    }
}
