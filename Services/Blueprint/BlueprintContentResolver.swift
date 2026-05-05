import Foundation

struct BlueprintPresentation {
    let identityContent: ZodiacIdentityContent
    let currentArchetype: Archetype?
    let lookupKey: String
    let combinedSigns: String
    let fallbackCompatibility: String
    let fallbackFriction: String
    let fallbackHiddenInsight: String
    let shareText: String?

    static let empty = BlueprintPresentation(
        identityContent: .placeholder,
        currentArchetype: nil,
        lookupKey: "no-user",
        combinedSigns: "—",
        fallbackCompatibility: "You do well with people who bring steadiness and clarity.",
        fallbackFriction: "Chaos throws you off. So do mixed signals.",
        fallbackHiddenInsight: "Your real lesson may be this: stay soft without losing your edge.",
        shareText: nil
    )
}

enum BlueprintContentResolver {
    static func resolve(user: UserProfile?, archetype: Archetype?) -> BlueprintPresentation {
        guard let user else {
            return .empty
        }

        let content: ZodiacIdentityContent
        if let resolved = ZodiacIdentityContentService.shared.content(
            forWestern: user.westernSignRaw,
            chinese: user.chineseSignRaw
        ) {
            content = resolved
        } else if let archetype,
                  let western = WesternZodiac.from(rawValue: user.westernSignRaw),
                  let chinese = ChineseZodiac.from(rawValue: user.chineseSignRaw) {
            print("[BlueprintContentResolver] Missing archetype-backed blueprint content for \(user.westernSignRaw)-\(user.chineseSignRaw)")
            content = .fromArchetype(archetype, western: western, chinese: chinese)
        } else {
            print("[BlueprintContentResolver] Missing blueprint content and archetype for \(user.westernSignRaw)-\(user.chineseSignRaw)")
            return .empty
        }

#if DEBUG
        let usedFallback = ZodiacIdentityContentService.shared.content(
            forWestern: user.westernSignRaw,
            chinese: user.chineseSignRaw
        ) == nil
        print("[PatternView] westernSignRaw='\(user.westernSignRaw)' chineseSignRaw='\(user.chineseSignRaw)' resolved='\(content.id)' fallback=\(usedFallback)")
#endif

        return BlueprintPresentation(
            identityContent: content,
            currentArchetype: archetype,
            lookupKey: "\(user.westernSignRaw)|\(user.chineseSignRaw)",
            combinedSigns: "\(user.westernSign.displayName) • \(user.chineseSign.displayName)",
            fallbackCompatibility: BlueprintPresentation.empty.fallbackCompatibility,
            fallbackFriction: BlueprintPresentation.empty.fallbackFriction,
            fallbackHiddenInsight: BlueprintPresentation.empty.fallbackHiddenInsight,
            shareText: """
            My Zodian blueprint:

            "\(content.title)"

            This one still feels true.
            """
        )
    }
}
