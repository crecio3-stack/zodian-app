import Foundation

enum AppEnvironment: String, CaseIterable, Sendable {
    case development
    case beta
    case production

    static var current: AppEnvironment {
        guard
            let value = AppConfiguration.string(for: "ZODIAN_ENVIRONMENT"),
            let environment = AppEnvironment(rawValue: value.lowercased())
        else {
#if DEBUG
            return .development
#else
            return .production
#endif
        }

        return environment
    }

    var isProduction: Bool {
        self == .production
    }
}

enum AppConfiguration {
    struct SupabaseClientConfiguration: Equatable, Sendable {
        let projectRef: String
        let url: URL
        let clientKey: String
    }

    static var environment: AppEnvironment {
        AppEnvironment.current
    }

    static var supabaseConfiguration: SupabaseClientConfiguration? {
        supabaseConfiguration(bundle: .main)
    }

    static func supabaseConfiguration(bundle: Bundle) -> SupabaseClientConfiguration? {
        guard
            let projectRef = string(for: "SUPABASE_PROJECT_REF", bundle: bundle),
            let urlString = string(for: "SUPABASE_URL", bundle: bundle),
            let clientKey = string(for: "SUPABASE_ANON_KEY", bundle: bundle)
        else {
            return nil
        }

        return makeSupabaseConfiguration(
            projectRef: projectRef,
            urlString: urlString,
            clientKey: clientKey
        )
    }

    static func makeSupabaseConfiguration(
        projectRef: String,
        urlString: String,
        clientKey: String
    ) -> SupabaseClientConfiguration? {
        guard
            let url = URL(string: urlString),
            url.scheme == "https",
            url.host?.lowercased() == "\(projectRef.lowercased()).supabase.co",
            isPermittedClientKey(clientKey)
        else {
            return nil
        }

        return SupabaseClientConfiguration(
            projectRef: projectRef,
            url: url,
            clientKey: clientKey
        )
    }

    static var supabaseURL: URL? {
        supabaseConfiguration?.url
    }

    static var supabaseAnonKey: String? {
        supabaseConfiguration?.clientKey
    }

    static var postHogProjectToken: String? {
        string(for: "POSTHOG_PROJECT_TOKEN")
    }

    static var postHogHost: URL {
        URL(string: string(for: "POSTHOG_HOST") ?? "https://us.i.posthog.com")!
    }

    static var sentryDSN: String? {
        string(for: "SENTRY_DSN")
    }

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
    }

    static func string(for key: String, bundle: Bundle = .main) -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment[key] {
            let trimmed = normalized(environmentValue)
            if let trimmed { return trimmed }
        }

        guard let bundleValue = bundle.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        return normalized(bundleValue)
    }

    private static func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmed.isEmpty,
            !trimmed.hasPrefix("$("),
            trimmed != "MISSING"
        else {
            return nil
        }

        return trimmed
    }

    private static func isPermittedClientKey(_ key: String) -> Bool {
        if key.hasPrefix("sb_publishable_") {
            return true
        }

        if key.hasPrefix("sb_secret_") {
            return false
        }

        let segments = key.split(separator: ".")
        guard segments.count == 3,
              let payloadData = base64URLDecoded(String(segments[1])),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let role = payload["role"] as? String else {
            return false
        }

        return role == "anon"
    }

    private static func base64URLDecoded(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder != 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }

        return Data(base64Encoded: base64)
    }
}
