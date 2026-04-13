import Foundation

final class ArchetypeService {

    static let shared = ArchetypeService()

    private var archetypes: [String: Archetype] = [:]

    private init() {
        loadArchetypes()
    }

    // MARK: - Public API

    func archetype(for western: WesternZodiac, chinese: ChineseZodiac) -> Archetype {
        let key = keyFor(western: western, chinese: chinese)

        if let archetype = archetypes[key] {
            return archetype
        } else {
            return Archetype.fallback(western: western, chinese: chinese)
        }
    }

    func archetype(forId id: String) -> Archetype {
        if let archetype = archetypes[id] {
            return archetype
        } else {
            let parts = id.split(separator: "-")
            if parts.count == 2,
               let western = WesternZodiac.from(rawValue: String(parts[0])),
               let chinese = ChineseZodiac.from(rawValue: String(parts[1])) {
                return Archetype.fallback(western: western, chinese: chinese)
            }

            return Archetype.fallback(western: .aries, chinese: .rat)
        }
    }

    // MARK: - Loading

    private func loadArchetypes() {
        guard let url = Bundle.main.url(forResource: "archetypes", withExtension: "json") else {
            print("⚠️ archetypes.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Archetype].self, from: data)

            var map: [String: Archetype] = [:]
            for archetype in decoded {
                map[archetype.id] = archetype
            }

            self.archetypes = map

        } catch {
            print("❌ Failed to load archetypes: \(error)")
        }
    }

    // MARK: - Helpers

    private func keyFor(western: WesternZodiac, chinese: ChineseZodiac) -> String {
        "\(western.rawValue)-\(chinese.rawValue)"
    }
}
