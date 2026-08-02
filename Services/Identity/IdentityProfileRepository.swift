import Foundation

/// The only intended runtime entry point for canonical Identity prose.
/// The approved canonical corpus is shared by Development, Beta, and
/// Production so every app configuration presents the same Identity profile.
final class IdentityProfileRepository {
    static let shared = IdentityProfileRepository()

    private let profilesByID: [String: IdentityProfile]

    private init() {
        profilesByID = Self.loadProfiles()
    }

    func profile(forID id: String) -> IdentityProfile? {
        return profilesByID[Self.normalizedID(id)]
    }

    func profile(forWestern western: String, chinese: String) -> IdentityProfile? {
        profile(forID: "\(western)-\(chinese)")
    }

    func allProfiles() -> [IdentityProfile] {
        return profilesByID.values.sorted { $0.id < $1.id }
    }

    private static func loadProfiles() -> [String: IdentityProfile] {
        guard let url = Bundle.main.url(
            forResource: "identity_profiles_v1",
            withExtension: "json"
        ) else {
            assertionFailure("identity_profiles_v1.json is missing from the app bundle")
            return [:]
        }

        do {
            let profiles = try JSONDecoder().decode(
                [IdentityProfile].self,
                from: Data(contentsOf: url)
            )
            guard profiles.count == 144,
                  Set(profiles.map(\.id)).count == 144,
                  profiles.allSatisfy({ !$0.signature.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
                  profiles.allSatisfy({ $0.lifeAreas.count == 7 }),
                  profiles.allSatisfy({ $0.editorialSections.count == 11 }) else {
                assertionFailure("Identity canonical corpus failed integrity checks")
                return [:]
            }
            return Dictionary(uniqueKeysWithValues: profiles.map { (normalizedID($0.id), $0) })
        } catch {
            assertionFailure("Identity canonical corpus failed to decode: \(error)")
            return [:]
        }
    }

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
