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

    func archetypeIfLoaded(for western: WesternZodiac, chinese: ChineseZodiac) -> Archetype? {
        archetypes[keyFor(western: western, chinese: chinese)]
    }

    func archetypeIfLoaded(forId id: String) -> Archetype? {
        archetypes[id]
    }

    // MARK: - Loading

    private func loadArchetypes() {
        guard let url = Bundle.main.url(forResource: "archetypes", withExtension: "json") else {
            print("⚠️ archetypes.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try decodeArchetypes(from: data)

            var map: [String: Archetype] = [:]
            for archetype in decoded {
                map[archetype.id] = archetype
            }

            self.archetypes = map

        } catch {
            print("❌ Failed to load archetypes: \(error)")
        }
    }

    private func decodeArchetypes(from data: Data) throws -> [Archetype] {
        do {
            return try JSONDecoder().decode([Archetype].self, from: data)
        } catch {
            guard let rawText = String(data: data, encoding: .utf8) else {
                throw error
            }

            let repaired = repairedArchetypeJSON(from: rawText)
            guard let repairedData = repaired.data(using: .utf8) else {
                throw error
            }

            return try JSONDecoder().decode([Archetype].self, from: repairedData)
        }
    }

    private func repairedArchetypeJSON(from text: String) -> String {
        var repaired = text
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "’", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        while repaired.hasSuffix(",") {
            repaired.removeLast()
            repaired = repaired.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if !repaired.hasSuffix("]") {
            repaired.append("\n]")
        }

        return repaired
    }

    // MARK: - Helpers

    private func keyFor(western: WesternZodiac, chinese: ChineseZodiac) -> String {
        "\(western.rawValue)-\(chinese.rawValue)"
    }
}
