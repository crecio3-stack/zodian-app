import Foundation
import PostHog

enum FeatureFlag: String, CaseIterable, Sendable {
    case connectAvailability = "connect-availability"
    case realProfileDiscovery = "real-profile-discovery"
    case profilePublication = "profile-publication"
    case connections = "connections"
    case messaging = "messaging"
    case premiumCommerce = "premium-commerce"
    case observationGenerationV2 = "observation-generation-v2"
    case dailyReadEditorialV2 = "daily-read-editorial-v2"
    case migration = "migration"
    case emergencyContentKillSwitch = "emergency-content-kill-switch"
    case emergencySocialKillSwitch = "emergency-social-kill-switch"

    var safeDefault: Bool {
        switch self {
        case .connectAvailability,
             .realProfileDiscovery,
             .profilePublication,
             .connections,
             .messaging,
             .premiumCommerce,
             .observationGenerationV2,
             .dailyReadEditorialV2,
             .migration,
             .emergencyContentKillSwitch,
             .emergencySocialKillSwitch:
            return false
        }
    }
}

@MainActor
final class FeatureFlagService {
    static let shared = FeatureFlagService()

#if DEBUG
    private enum Keys {
        static let debugOverrides = "zodian.featureFlags.debugOverrides.v1"
    }
#endif

    private var remoteProviderAvailable = false
    private var accountID: AccountID?

    private init() {}

    func configure(remoteProviderAvailable: Bool) {
        self.remoteProviderAvailable = remoteProviderAvailable
    }

    func setAccountIdentity(_ accountID: AccountID) {
        self.accountID = accountID
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
#if DEBUG
        if let override = debugOverrides()[flag.rawValue] {
            return override
        }
#endif

        guard remoteProviderAvailable, accountID != nil else {
            return flag.safeDefault
        }

        return PostHogSDK.shared.isFeatureEnabled(flag.rawValue)
    }

#if DEBUG
    func setLocalOverride(_ value: Bool?, for flag: FeatureFlag) {
        var overrides = debugOverrides()
        overrides[flag.rawValue] = value
        UserDefaults.standard.set(overrides, forKey: Keys.debugOverrides)

        OperationalLogger.debug(
            "feature_flag_override_changed",
            category: .featureFlags,
            metadata: [
                "flag": flag.rawValue,
                "value": value.map(String.init) ?? "remote_or_default"
            ]
        )
    }

    private func debugOverrides() -> [String: Bool] {
        UserDefaults.standard.dictionary(forKey: Keys.debugOverrides) as? [String: Bool] ?? [:]
    }
#endif
}
