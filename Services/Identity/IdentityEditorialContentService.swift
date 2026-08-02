import Foundation

struct IdentityEditorialRecord: Decodable, Equatable {
    struct Provenance: Decodable, Equatable {
        let source: String
        let reviewedAt: String
        let reviewer: String
    }

    struct Hero: Decodable, Equatable {
        let archetypeTitle: String
        let tell: String
        let centralSynthesis: String
        let strength: String
        let shadow: String
    }

    struct Section: Decodable, Equatable {
        let lead: String
        let detail: String
    }

    struct Sections: Decodable, Equatable {
        let howItShowsUp: Section
        let whatGetsInTheWay: Section
        let decisionMaking: Section
        let loveAndFriendship: Section
        let trustAndCloseness: Section
        let workAndPurpose: Section
        let underPressure: Section
        let restoration: Section
        let growth: Section
        let closeCompany: Section
        let closingSynthesis: Section
    }

    let westernSign: String
    let chineseSign: String
    let version: String
    let status: String
    let provenance: Provenance
    let hero: Hero
    let sections: Sections

    var id: String {
        "\(westernSign.lowercased())-\(chineseSign.lowercased())"
    }
}

struct IdentityEditorialResolvedProfile: Equatable {
    let presentation: IdentityPresentation
    let cardContent: IdentityCardContent
    let closeCompany: String
}

/// Review-pending canonical Identity content. The loader is intentionally active
/// only in Debug so unreviewed editorial copy cannot replace Release content.
final class IdentityEditorialContentService {
    static let shared = IdentityEditorialContentService()

    #if DEBUG
    private let records: [String: IdentityEditorialRecord]
    #endif

    private init() {
        #if DEBUG
        records = Self.loadReviewPendingRecords()
        #endif
    }

    func profile(forWestern western: String, chinese: String) -> IdentityEditorialResolvedProfile? {
        #if DEBUG
        let requestedKey = ProcessInfo.processInfo.environment[
            "ZODIAN_IDENTITY_EDITORIAL_FIXTURE_ID"
        ]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let key = requestedKey?.isEmpty == false
            ? requestedKey!
            : Self.key(western: western, chinese: chinese)
        guard let record = records[key],
              record.version == "identity-editorial-v1",
              record.status == "review_pending" else {
            return nil
        }

        let presentation = IdentityPresentation.make(from: record)
        return IdentityEditorialResolvedProfile(
            presentation: presentation,
            cardContent: Self.compactCardContent(
                for: record,
                presentation: presentation
            ),
            closeCompany: IdentityPresentation.editorialSectionText(record.sections.closeCompany)
        )
        #else
        return nil
        #endif
    }

    #if DEBUG
    private static func loadReviewPendingRecords() -> [String: IdentityEditorialRecord] {
        guard let url = Bundle.main.url(
            forResource: "identity_editorial_v1_review_pending",
            withExtension: "json"
        ) else {
            assertionFailure("identity_editorial_v1_review_pending.json is missing from the Debug bundle")
            return [:]
        }

        do {
            let decoded = try JSONDecoder().decode(
                [IdentityEditorialRecord].self,
                from: Data(contentsOf: url)
            )
            guard decoded.count == 144,
                  Set(decoded.map(\.id)).count == 144,
                  decoded.allSatisfy({
                      $0.version == "identity-editorial-v1" && $0.status == "review_pending"
                  }) else {
                assertionFailure("Identity editorial review corpus failed Debug integrity checks")
                return [:]
            }
            return Dictionary(uniqueKeysWithValues: decoded.map { ($0.id, $0) })
        } catch {
            assertionFailure("Identity editorial review corpus failed to decode: \(error)")
            return [:]
        }
    }
    #endif

    private static func key(western: String, chinese: String) -> String {
        "\(normalize(western))-\(normalize(chinese))"
    }

    /// The full editorial corpus owns the expanded Identity sections, but the
    /// reveal card keeps its earlier scan-first role. Its tagline and teaser
    /// come from the compact canonical archetype instead of repeating the
    /// editorial Tell and synthesis that appear immediately below the card.
    private static func compactCardContent(
        for record: IdentityEditorialRecord,
        presentation: IdentityPresentation
    ) -> IdentityCardContent {
        guard let western = WesternZodiac.from(rawValue: record.westernSign),
              let chinese = ChineseZodiac.from(rawValue: record.chineseSign) else {
            return IdentityCardContent(
                id: record.id,
                signCombination: presentation.signCombination,
                identityName: record.hero.archetypeTitle,
                descriptor: "",
                patternSummary: ""
            )
        }

        let compact = ArchetypeService.shared
            .archetype(for: western, chinese: chinese)
            .identityCardContent

        return IdentityCardContent(
            id: record.id,
            signCombination: presentation.signCombination,
            identityName: record.hero.archetypeTitle,
            descriptor: compact.descriptor,
            patternSummary: compact.patternSummary
        )
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
