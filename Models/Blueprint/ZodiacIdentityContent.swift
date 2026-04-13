import Foundation

struct ZodiacIdentityContent: Codable, Identifiable {
    let id: String
    let westernSign: String
    let chineseSign: String
    let title: String
    let tagline: String
    let identitySummary: String
    let coreEnergy: String
    let strengths: [String]
    let growthEdges: [String]
    let loveStyle: String
    let friendshipStyle: String
    let workStyle: String
    let communicationStyle: String
    let emotionalPattern: String
    let shadowPattern: String
    let bestPractices: [String]
    let ritualPrompt: String
    let mantra: String
}
