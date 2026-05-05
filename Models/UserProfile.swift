import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID

    var name: String
    var birthday: Date
    var birthTime: Date?
    var birthPlaceRaw: String?
    var birthPlaceNormalized: String?
    var birthTimezoneIdentifier: String?

    var westernSignRaw: String
    var chineseSignRaw: String

    var archetypeId: String

    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthday: Date,
        birthTime: Date? = nil,
        birthPlaceRaw: String? = nil,
        birthPlaceNormalized: String? = nil,
        birthTimezoneIdentifier: String? = nil,
        westernSignRaw: String,
        chineseSignRaw: String,
        archetypeId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.birthday = birthday
        self.birthTime = birthTime
        self.birthPlaceRaw = birthPlaceRaw
        self.birthPlaceNormalized = birthPlaceNormalized
        self.birthTimezoneIdentifier = birthTimezoneIdentifier
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
