import Foundation

// Legacy prototype catalog retained for migration reference. ArchetypeService
// is the runtime source of truth for identity content.
final class IdentityProfileCatalog {
    static let shared = IdentityProfileCatalog()

    private var entriesByID: [String: IdentityProfileEntry]

    init(entries: [IdentityProfileEntry] = IdentityProfileCatalog.seedEntries) {
        #if DEBUG
        entries.forEach { entry in
            let errors = IdentityProfileRuleChecker.validationErrors(for: entry.profile)
            if !errors.isEmpty {
                print("[IdentityProfileCatalog] Validation warnings for \(entry.id): \(errors.joined(separator: " | "))")
            }
        }
        #endif
        self.entriesByID = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }

    func entry(for western: WesternZodiac, chinese: ChineseZodiac) -> IdentityProfileEntry? {
        entriesByID["\(western.rawValue)-\(chinese.rawValue)"]
    }

    func profile(for western: WesternZodiac, chinese: ChineseZodiac) -> LegacyIdentityProfile? {
        entry(for: western, chinese: chinese)?.profile
    }

    func replaceEntries(_ entries: [IdentityProfileEntry]) {
        entriesByID = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }

    static func decodeEntries(from data: Data) throws -> [IdentityProfileEntry] {
        let entries = try JSONDecoder().decode([IdentityProfileEntry].self, from: data)
        #if DEBUG
        entries.forEach { entry in
            let errors = IdentityProfileRuleChecker.validationErrors(for: entry.profile)
            if !errors.isEmpty {
                print("[IdentityProfileCatalog] Validation warnings for \(entry.id): \(errors.joined(separator: " | "))")
            }
        }
        #endif
        return entries
    }
}

extension IdentityProfileCatalog {
    static let ariesHorse = IdentityProfileEntry(
        westernSignRaw: WesternZodiac.aries.rawValue,
        chineseSignRaw: ChineseZodiac.horse.rawValue,
        profile: LegacyIdentityProfile(
            title: "The Untamed Spark",
            thesis: "You move first, feel later, and resist anything that tries to pin you down",
            westernContribution: "Aries brings ignition. You act fast, trust instinct, and would rather create motion than wait for permission.",
            chineseContribution: "Horse brings freedom hunger. You stay alive through movement, momentum, and choice.",
            combinedSummary: "Together, this identity is bold, fast, and difficult to contain. You look fearless, but much of your intensity is a way to stay ahead of doubt.",
            strengths: [
                "You create momentum the second a room starts to stall",
                "You tell the truth faster than most people are ready for",
                "You trust your instincts when hesitation would cost time"
            ],
            shadows: [
                "You rush past your own feelings and call it clarity",
                "You pull away the moment care starts to feel like control",
                "You burn energy proving your freedom instead of using it well"
            ],
            relationshipStyle: "You need honesty, momentum, and space. You come alive with people who are direct and self-possessed, but you test the bond when closeness starts to feel limiting.",
            stressPattern: "Under stress, you get sharper, faster, and harder to reach. Irritation shows up before vulnerability does, and movement becomes a way to avoid sitting with what actually hurt.",
            growthEdge: "Your growth is learning that freedom is not the same as escape. When you slow down long enough to name what you feel, your courage becomes steadier and more trustworthy."
        )
    )

    static let seedEntries: [IdentityProfileEntry] = [
        ariesHorse
    ]
}
