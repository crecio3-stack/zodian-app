import Foundation

struct Archetype: Codable, Identifiable, Equatable {
    let id: String

    let combinedName: String
    let title: String

    let overview: String

    let strengths: [String]
    let shadows: [String]

    let emotionalPattern: String
    let loveStyle: String
    let friendshipStyle: String
    let workStyle: String
    let growthPath: String

    let compatibilityNotes: String

    let tagline: String
    let hiddenInsight: String?

    var shareTitle: String {
        "\(combinedName) — \(title)"
    }

    var shortDescription: String {
        tagline
    }

    static func fallback(western: WesternZodiac, chinese: ChineseZodiac) -> Archetype {
        Archetype(
            id: "\(western.rawValue)-\(chinese.rawValue)",
            combinedName: "\(western.displayName) × \(chinese.displayName)",
            title: "The Hidden Pattern",
            overview: "Your identity blends two systems into something uniquely yours. As Zodian evolves, deeper insights will reveal your full archetype.",
            strengths: [
                "Adaptable nature",
                "Layered personality",
                "Intuitive awareness"
            ],
            shadows: [
                "Unclear direction",
                "Internal conflict",
                "Overthinking identity"
            ],
            emotionalPattern: "You process experiences through multiple lenses, often seeking deeper meaning beneath the surface.",
            loveStyle: "You are exploratory in love, seeking connection that feels both grounding and expansive.",
            friendshipStyle: "You show up thoughtfully, observing before fully opening.",
            workStyle: "You adapt quickly and thrive when given space to explore.",
            growthPath: "Clarity comes from trusting your instincts and embracing your dual nature.",
            compatibilityNotes: "You resonate with individuals who bring balance and clarity to your layered perspective.",
            tagline: "A pattern still unfolding.",
            hiddenInsight: "Your deeper gift is learning how to trust the tension between your softness and your power without trying to erase either."
        )
    }
}
