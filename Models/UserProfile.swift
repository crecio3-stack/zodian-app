import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID

    var name: String
    var birthday: Date

    var westernSignRaw: String
    var chineseSignRaw: String

    var archetypeId: String

    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthday: Date,
        westernSignRaw: String,
        chineseSignRaw: String,
        archetypeId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.birthday = birthday
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.archetypeId = archetypeId
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties

extension UserProfile {
    var westernSign: WesternZodiac {
        WesternZodiac.from(rawValue: westernSignRaw) ?? .aries
    }

    var chineseSign: ChineseZodiac {
        ChineseZodiac.from(rawValue: chineseSignRaw) ?? .rat
    }
}
