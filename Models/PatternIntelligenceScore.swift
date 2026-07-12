import Foundation
import SwiftData

@Model
final class PatternIntelligenceScore {
    @Attribute(.unique) var id: UUID

    var confidenceScore: Double
    var reflectionScore: Double
    var connectionScore: Double
    var growthScore: Double
    var momentumScore: Double
    var generatedAt: Date
    var sourceDailyReadId: UUID

    init(
        id: UUID = UUID(),
        confidenceScore: Double,
        reflectionScore: Double,
        connectionScore: Double,
        growthScore: Double,
        momentumScore: Double,
        generatedAt: Date = Date(),
        sourceDailyReadId: UUID
    ) {
        self.id = id
        self.confidenceScore = confidenceScore
        self.reflectionScore = reflectionScore
        self.connectionScore = connectionScore
        self.growthScore = growthScore
        self.momentumScore = momentumScore
        self.generatedAt = generatedAt
        self.sourceDailyReadId = sourceDailyReadId
    }
}
