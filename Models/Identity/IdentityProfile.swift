import Foundation

struct IdentityProfile: Codable, Equatable {
    let title: String
    let thesis: String
    let westernContribution: String
    let chineseContribution: String
    let combinedSummary: String
    let strengths: [String]
    let shadows: [String]
    let relationshipStyle: String
    let stressPattern: String
    let growthEdge: String
}

struct IdentityProfileEntry: Codable, Equatable, Identifiable {
    let westernSignRaw: String
    let chineseSignRaw: String
    let profile: IdentityProfile

    var id: String { "\(westernSignRaw)-\(chineseSignRaw)" }

    var westernSign: WesternZodiac {
        WesternZodiac.from(rawValue: westernSignRaw) ?? .aries
    }

    var chineseSign: ChineseZodiac {
        ChineseZodiac.from(rawValue: chineseSignRaw) ?? .rat
    }
}

struct IdentityRevealProfileContent: Equatable {
    let signCombo: String
    let title: String
    let thesis: String
    let supportingLine: String?
}

struct IdentityPatternSection: Equatable, Identifiable {
    let id: String
    let title: String
    let body: [String]
}

struct IdentityPatternContent: Equatable {
    let signCombo: String
    let title: String
    let thesis: String
    let summary: String
    let sections: [IdentityPatternSection]
}
