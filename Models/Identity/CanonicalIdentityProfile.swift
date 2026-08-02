import Foundation

struct IdentityRevealCard: Codable, Equatable {
    let tagline: String
    let overview: String
}

/// The sole schema for the readable Identity canonical resource. This is
/// intentionally distinct from the retired `LegacyIdentityProfile` prototype.
struct IdentityProfile: Codable, Equatable, Identifiable {
    struct Provenance: Codable, Equatable {
        let semanticSource: String
        let semanticSourceVersion: String
        let semanticSourceStatus: String
        let presentationMigrationSource: String
        let migration: String
    }

    struct Hero: Codable, Equatable {
        let archetypeTitle: String
        let tell: String
        let centralSynthesis: String
    }

    struct LifeArea: Codable, Equatable, Identifiable {
        let area: String
        let hook: String
        let expandedRead: String

        var id: String { area }
    }

    struct EditorialSection: Codable, Equatable, Identifiable {
        let id: String
        let lead: String
        let detail: String
    }

    let id: String
    let westernSign: String
    let chineseSign: String
    let version: String
    let editorialStatus: String
    let provenance: Provenance
    let hero: Hero
    let revealCard: IdentityRevealCard
    let signature: String
    let strengths: [String]
    let shadows: [String]
    let lifeAreas: [LifeArea]
    let editorialSections: [EditorialSection]

    var signCombination: String { "\(westernSign) × \(chineseSign)" }

    var identityCardContent: IdentityCardContent {
        IdentityCardContent(
            id: id,
            signCombination: signCombination,
            identityName: hero.archetypeTitle,
            descriptor: revealCard.tagline,
            patternSummary: revealCard.overview
        )
    }
}
