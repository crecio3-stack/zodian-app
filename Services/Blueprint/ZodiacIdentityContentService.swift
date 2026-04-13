import Foundation

final class ZodiacIdentityContentService {
    static let shared = ZodiacIdentityContentService()
    private var content: [String: ZodiacIdentityContent] = [:]
    private let resourceName = "zodiac_identities"

    private init() {
        debugLog("Initializing shared content service")
        loadContent()
    }

    private func loadContent() {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            print("[ZodiacIdentityContentService] Failed to find \(resourceName).json in bundle \(Bundle.main.bundleURL.path)")
            return
        }

        debugLog("Found bundled JSON at \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            let entries = try JSONDecoder().decode([ZodiacIdentityContent].self, from: data)
            content = Dictionary(uniqueKeysWithValues: entries.map { (normalizedLookupKey(from: $0.id), $0) })

            debugLog("Decoded \(entries.count) zodiac identity entries")
            debugLog("Loaded ids: \(entries.map { $0.id }.joined(separator: ", "))")
        } catch {
            print("[ZodiacIdentityContentService] Failed to decode \(resourceName).json: \(error)")
        }
    }

    func content(forArchetypeId id: String) -> ZodiacIdentityContent? {
        let normalizedID = normalizedLookupKey(from: id)
        let match = content[normalizedID]
        debugLog("Lookup by archetype id '\(id)' normalized to '\(normalizedID)' -> \(match?.id ?? "nil")")
        return match
    }

    func content(forWestern western: String, chinese: String) -> ZodiacIdentityContent? {
        let lookupID = lookupID(forWestern: western, chinese: chinese)
        let match = content[lookupID]
        debugLog("Lookup western='\(western)' chinese='\(chinese)' -> key '\(lookupID)' -> \(match?.id ?? "nil")")
        return match
    }

    func safeContent(forWestern western: String, chinese: String) -> ZodiacIdentityContent {
        if let resolved = content(forWestern: western, chinese: chinese) {
            return resolved
        }

        print("[ZodiacIdentityContentService] Falling back to default content for key '\(lookupID(forWestern: western, chinese: chinese))'")
        return ZodiacIdentityContent(
            id: "mystic-blend",
            westernSign: western,
            chineseSign: chinese,
            title: "The Mystic Blend",
            tagline: "A rare fusion, uniquely yours.",
            identitySummary: "Your cosmic signature is a tapestry of contrasts and harmonies, woven from the rare meeting of two ancient zodiacs. You embody a path that is truly your own—mysterious, layered, and full of potential.",
            coreEnergy: "A dynamic interplay of archetypes, inviting you to discover new facets of yourself.",
            strengths: ["Originality", "Depth", "Resilience"],
            growthEdges: ["Embracing uncertainty", "Trusting your intuition", "Honoring your unique rhythm"],
            loveStyle: "You love in ways that defy easy labels, blending passion with curiosity.",
            friendshipStyle: "You attract kindred spirits who appreciate your complexity and insight.",
            workStyle: "You thrive in spaces that honor both independence and imagination.",
            communicationStyle: "Your words carry both mystery and meaning, inviting others to look deeper.",
            emotionalPattern: "You feel deeply, often sensing undercurrents others miss.",
            shadowPattern: "At times, you may feel out of step or misunderstood—remember, your path is not meant to be ordinary.",
            bestPractices: [
                "Celebrate your differences.",
                "Trust the wisdom of your own journey.",
                "Let your story unfold at its own pace."
            ],
            ritualPrompt: "Light a candle and reflect on the unique gifts your blend brings to the world.",
            mantra: "I honor the rare alchemy of my being."
        )
    }

    private func lookupID(forWestern western: String, chinese: String) -> String {
        "\(normalizedLookupKeyPart(western))-\(normalizedLookupKeyPart(chinese))"
    }

    private func normalizedLookupKey(from id: String) -> String {
        id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func normalizedLookupKeyPart(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func debugLog(_ message: String) {
#if DEBUG
        print("[ZodiacIdentityContentService] \(message)")
#endif
    }
}
