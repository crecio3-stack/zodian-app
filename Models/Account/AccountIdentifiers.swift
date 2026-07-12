import Foundation

nonisolated protocol ZodianIdentifier: Codable, Hashable, RawRepresentable, Sendable
where RawValue == String {}

nonisolated struct AccountID: ZodianIdentifier {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

nonisolated struct InstallationID: ZodianIdentifier {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

nonisolated struct DeviceRegistrationID: ZodianIdentifier {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

nonisolated struct SessionID: ZodianIdentifier {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

nonisolated struct MigrationID: ZodianIdentifier {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static func new() -> MigrationID {
        MigrationID(rawValue: UUID().uuidString.lowercased())
    }
}

nonisolated struct InstallationIdentity: Equatable, Sendable {
    let installationID: InstallationID
    let deviceRegistrationID: DeviceRegistrationID
}

nonisolated struct InstallationIdentityStore {
    private enum Keys {
        static let installationID = "zodian.ownership.installationID"
        static let deviceRegistrationID = "zodian.ownership.deviceRegistrationID"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func current() -> InstallationIdentity {
        let installationID = storedIdentifier(
            forKey: Keys.installationID,
            make: InstallationID.init(rawValue:)
        )
        let deviceRegistrationID = storedIdentifier(
            forKey: Keys.deviceRegistrationID,
            make: DeviceRegistrationID.init(rawValue:)
        )

        return InstallationIdentity(
            installationID: installationID,
            deviceRegistrationID: deviceRegistrationID
        )
    }

    private func storedIdentifier<Identifier: ZodianIdentifier>(
        forKey key: String,
        make: (String) -> Identifier
    ) -> Identifier {
        if let existing = defaults.string(forKey: key), !existing.isEmpty {
            return make(existing)
        }

        let generated = UUID().uuidString.lowercased()
        defaults.set(generated, forKey: key)
        return make(generated)
    }
}
