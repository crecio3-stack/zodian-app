import Foundation

final class ZodiacIdentityContentService {
    static let shared = ZodiacIdentityContentService()

    private init() {}

    func content(forArchetypeId id: String) -> ZodiacIdentityContent? {
        guard let archetype = ArchetypeService.shared.archetypeIfLoaded(forId: normalizedLookupKey(from: id)),
              let (western, chinese) = signs(from: archetype.id) else {
            return nil
        }

        return .fromArchetype(archetype, western: western, chinese: chinese)
    }

    func content(forWestern western: String, chinese: String) -> ZodiacIdentityContent? {
        guard let westernSign = WesternZodiac.from(rawValue: normalizedLookupKeyPart(western)),
              let chineseSign = ChineseZodiac.from(rawValue: normalizedLookupKeyPart(chinese)),
              let archetype = ArchetypeService.shared.archetypeIfLoaded(for: westernSign, chinese: chineseSign) else {
            return nil
        }

        return .fromArchetype(archetype, western: westernSign, chinese: chineseSign)
    }

    private func signs(from id: String) -> (WesternZodiac, ChineseZodiac)? {
        let parts = normalizedLookupKey(from: id)
            .split(separator: "-", maxSplits: 1)
            .map(String.init)

        guard parts.count == 2,
              let western = WesternZodiac.from(rawValue: parts[0]),
              let chinese = ChineseZodiac.from(rawValue: parts[1]) else {
            return nil
        }

        return (western, chinese)
    }

    private func normalizedLookupKey(from id: String) -> String {
        id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func normalizedLookupKeyPart(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
