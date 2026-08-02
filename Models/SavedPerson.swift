import Foundation
import SwiftData

/// A local-only person the user has chosen to read. This deliberately stores no account,
/// location, or birth-time data because Western × Chinese identity needs only a date.
@Model
final class SavedPerson {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date
    var westernSignRaw: String
    var chineseSignRaw: String
    var photoFileName: String?
    var createdAt: Date
    var updatedAt: Date
    var lastOpenedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        westernSignRaw: String,
        chineseSignRaw: String,
        photoFileName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastOpenedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.photoFileName = photoFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastOpenedAt = lastOpenedAt
    }
}

extension SavedPerson {
    var westernSign: WesternZodiac { WesternZodiac.from(rawValue: westernSignRaw) ?? .aries }
    var chineseSign: ChineseZodiac { ChineseZodiac.from(rawValue: chineseSignRaw) ?? .rat }
    var signLine: String { "\(westernSign.displayName) × \(chineseSign.displayName)" }

    var archetype: Archetype {
        ArchetypeService.shared.archetype(for: westernSign, chinese: chineseSign)
    }

    var identityEditorialProfile: IdentityEditorialResolvedProfile? {
        IdentityEditorialContentService.shared.profile(
            forWestern: westernSignRaw,
            chinese: chineseSignRaw
        )
    }

    var canonicalIdentityProfile: IdentityProfile? {
        IdentityProfileRepository.shared.profile(
            forWestern: westernSignRaw,
            chinese: chineseSignRaw
        )
    }

    var identityCardContent: IdentityCardContent {
        canonicalIdentityProfile?.identityCardContent
            ?? identityEditorialProfile?.cardContent
            ?? archetype.identityCardContent
    }

    /// Canonical Identity presentation used by saved-person summaries and detail routing.
    var identityPresentation: IdentityPresentation? {
        if let editorial = identityEditorialProfile {
            return editorial.presentation
        }
        guard let content = ZodiacIdentityContentService.shared.content(
            forWestern: westernSignRaw,
            chinese: chineseSignRaw
        ) else { return nil }
        return IdentityPresentation.make(from: content)
    }

    /// Identity-specific key for a person Lens. It is intentionally not the signed-in user's key.
    func lensCacheKey(on date: Date = Date(), calendar: Calendar = .current) -> String {
        let day = calendar.startOfDay(for: date).timeIntervalSince1970
        return "saved-person-lens|\(id.uuidString)|\(westernSignRaw)|\(chineseSignRaw)|\(Int(day))"
    }
}
