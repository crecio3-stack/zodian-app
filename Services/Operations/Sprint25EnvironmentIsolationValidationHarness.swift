#if DEBUG
import Foundation

@MainActor
enum Sprint25EnvironmentIsolationValidationHarness {
    private struct ValidationFailure: Error {
        let message: String
    }

    static func run(accountOwnership: AccountOwnershipController) {
        let checks: [(String, () throws -> Void)] = [
            ("Debug resolves Development", {
                try require(AppConfiguration.environment == .development, "Debug environment was not Development")
            }),
            ("Development backend configuration is explicit", {
                try require(AppConfiguration.supabaseConfiguration != nil, "Development did not resolve the configured shared launch backend")
                try require(AppConfiguration.supabaseURL?.scheme == "https", "Development backend URL was not HTTPS")
                try require(AppConfiguration.supabaseAnonKey != nil, "Development backend client key was missing")
            }),
            ("missing configuration fails safely", {
                guard case .failed(let failure) = accountOwnership.state else {
                    throw ValidationFailure(message: "Account ownership did not fail closed")
                }
                try require(failure.kind == .configuration, "Missing configuration was misclassified")
                try require(AnalyticsService.shared.accountID == nil, "Analytics adopted an Account without bootstrap")
            }),
            ("project-ref mismatch is rejected", {
                let configuration = AppConfiguration.makeSupabaseConfiguration(
                    projectRef: "development-ref",
                    urlString: "https://different-ref.supabase.co",
                    clientKey: legacyJWT(role: "anon")
                )
                try require(configuration == nil, "Mismatched Supabase host was accepted")
            }),
            ("service-role client key is rejected", {
                let configuration = AppConfiguration.makeSupabaseConfiguration(
                    projectRef: "development-ref",
                    urlString: "https://development-ref.supabase.co",
                    clientKey: legacyJWT(role: "service_role")
                )
                try require(configuration == nil, "Service-role key was accepted by the client")
            }),
            ("publishable and anon client keys are accepted", {
                let publishable = AppConfiguration.makeSupabaseConfiguration(
                    projectRef: "development-ref",
                    urlString: "https://development-ref.supabase.co",
                    clientKey: "sb_publishable_validation"
                )
                let legacyAnon = AppConfiguration.makeSupabaseConfiguration(
                    projectRef: "development-ref",
                    urlString: "https://development-ref.supabase.co",
                    clientKey: legacyJWT(role: "anon")
                )
                try require(publishable != nil && legacyAnon != nil, "A permitted client key was rejected")
            })
        ]

        var failures: [String] = []
        print("[Sprint25EnvironmentValidation] BEGIN")

        for (name, check) in checks {
            do {
                try check()
                print("[Sprint25EnvironmentValidation] PASS: \(name)")
            } catch {
                failures.append("\(name): \(error)")
                print("[Sprint25EnvironmentValidation] FAIL: \(name) — \(error)")
            }
        }

        if failures.isEmpty {
            print("[Sprint25EnvironmentValidation] RESULT: PASS (\(checks.count)/\(checks.count))")
        } else {
            print("[Sprint25EnvironmentValidation] RESULT: FAIL (\(checks.count - failures.count)/\(checks.count))")
            assertionFailure(failures.joined(separator: "\n"))
        }
    }

    private static func legacyJWT(role: String) -> String {
        let payload = #"{"role":"\#(role)"}"#
        return "e30.\(base64URL(payload)).signature"
    }

    private static func base64URL(_ value: String) -> String {
        Data(value.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        guard condition() else {
            throw ValidationFailure(message: message)
        }
    }
}
#endif
