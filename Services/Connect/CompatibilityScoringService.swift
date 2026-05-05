import Foundation

struct CompatibilityScoringService {
    static let shared = CompatibilityScoringService()

    private init() {}

    func score(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        userArchetypeId: String,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        candidateArchetypeId: String
    ) -> CompatibilityBreakdown {
        let western = westernCompatibility(userWestern, candidateWestern)
        let chinese = chineseCompatibility(userChinese, candidateChinese)
        let archetype = archetypeCompatibility(userArchetypeId, candidateArchetypeId)

        let rawTotal = western + chinese + archetype
        let total = max(55, min(rawTotal, 96))

        let style = deriveStyle(
            total: total,
            userWestern: userWestern,
            candidateWestern: candidateWestern,
            userChinese: userChinese,
            candidateChinese: candidateChinese
        )

        let reasons = buildReasons(
            userWestern: userWestern,
            candidateWestern: candidateWestern,
            userChinese: userChinese,
            candidateChinese: candidateChinese,
            userArchetypeId: userArchetypeId,
            candidateArchetypeId: candidateArchetypeId,
            style: style
        )

        let frictionNote = buildFrictionNote(
            style: style,
            userWestern: userWestern,
            candidateWestern: candidateWestern,
            userChinese: userChinese,
            candidateChinese: candidateChinese
        )

        return CompatibilityBreakdown(
            totalScore: total,
            westernScore: western,
            chineseScore: chinese,
            archetypeScore: archetype,
            style: style,
            reasons: reasons,
            frictionNote: frictionNote
        )
    }

    private func westernCompatibility(_ a: WesternZodiac, _ b: WesternZodiac) -> Int {
        if a == b { return 27 }

        if westernElement(of: a) == westernElement(of: b) {
            return 25
        }

        if isSupportiveWesternPair(a, b) {
            return 24
        }

        if isHighTensionWesternPair(a, b) {
            return 16
        }

        return 20
    }

    private func chineseCompatibility(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Int {
        if a == b { return 23 }

        if isChineseTrine(a, b) {
            return 24
        }

        if isChineseComplement(a, b) {
            return 22
        }

        if isChineseConflict(a, b) {
            return 14
        }

        return 18
    }

    private func archetypeCompatibility(_ a: String, _ b: String) -> Int {
        if a == b { return 27 }

        let aParts = a.split(separator: "-").map(String.init)
        let bParts = b.split(separator: "-").map(String.init)

        guard aParts.count == 2, bParts.count == 2 else { return 18 }

        var score = 18

        if aParts[0] == bParts[0] { score += 5 }
        if aParts[1] == bParts[1] { score += 5 }

        return min(score, 27)
    }

    private func deriveStyle(
        total: Int,
        userWestern: WesternZodiac,
        candidateWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateChinese: ChineseZodiac
    ) -> MatchStyle {
        if total >= 88 { return .harmonious }
        if userWestern == candidateWestern || userChinese == candidateChinese { return .mirrored }
        if isHighTensionWesternPair(userWestern, candidateWestern) || isChineseConflict(userChinese, candidateChinese) { return .intense }
        if isSupportiveWesternPair(userWestern, candidateWestern) || isChineseComplement(userChinese, candidateChinese) { return .growth }
        return .magnetic
    }

    private func buildReasons(
        userWestern: WesternZodiac,
        candidateWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateChinese: ChineseZodiac,
        userArchetypeId: String,
        candidateArchetypeId: String,
        style: MatchStyle
    ) -> [MatchReason] {
        var reasons: [MatchReason] = []

        if userWestern == candidateWestern {
            reasons.append(
                MatchReason(
                    title: "Same solar rhythm",
                    detail: "The outer rhythm is easy to read because both of you move from the same Western current."
                )
            )
        } else if westernElement(of: userWestern) == westernElement(of: candidateWestern) {
            reasons.append(
                MatchReason(
                    title: "Same element",
                    detail: "The pace may differ, but the basic language is familiar."
                )
            )
        } else if isSupportiveWesternPair(userWestern, candidateWestern) {
            reasons.append(
                MatchReason(
                    title: "Useful contrast",
                    detail: "This pairing can help both people adjust without losing their own shape."
                )
            )
        }

        if userChinese == candidateChinese {
            reasons.append(
                MatchReason(
                    title: "Same instinct",
                    detail: "The deeper reflex is similar, which can make the connection feel recognizable fast."
                )
            )
        } else if isChineseTrine(userChinese, candidateChinese) {
            reasons.append(
                MatchReason(
                    title: "Natural alliance",
                    detail: "The Eastern signs support each other without needing constant translation."
                )
            )
        } else if isChineseComplement(userChinese, candidateChinese) {
            reasons.append(
                MatchReason(
                    title: "Balancing pull",
                    detail: "One person brings what the other may not naturally lead with."
                )
            )
        }

        if userArchetypeId.split(separator: "-").first == candidateArchetypeId.split(separator: "-").first {
            reasons.append(
                MatchReason(
                    title: "Shared surface style",
                    detail: "The way you enter the room may feel familiar."
                )
            )
        }

        if userArchetypeId.split(separator: "-").last == candidateArchetypeId.split(separator: "-").last {
            reasons.append(
                MatchReason(
                    title: "Shared inner animal",
                    detail: "The deeper instinct may recognize itself before either person explains it."
                )
            )
        }

        if reasons.isEmpty {
            reasons.append(reasonForStyle(style))
        }

        return Array(reasons.prefix(3))
    }

    private func reasonForStyle(_ style: MatchStyle) -> MatchReason {
        switch style {
        case .harmonious:
            return MatchReason(
                title: "Low friction",
                detail: "This connection has enough ease to let both people stay natural."
            )
        case .mirrored:
            return MatchReason(
                title: "Recognition",
                detail: "There is something familiar here. Useful, but still worth reading slowly."
            )
        case .growth:
            return MatchReason(
                title: "Adjustment",
                detail: "This person may not match your rhythm exactly, but that is why the read matters."
            )
        case .magnetic:
            return MatchReason(
                title: "Curiosity",
                detail: "The pull comes from difference, timing, and what each person brings out of the other."
            )
        case .intense:
            return MatchReason(
                title: "Charge",
                detail: "This one has signal, but it may need more patience than certainty."
            )
        }
    }

    private func buildFrictionNote(
        style: MatchStyle,
        userWestern: WesternZodiac,
        candidateWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateChinese: ChineseZodiac
    ) -> String {
        switch style {
        case .harmonious:
            return "The risk is assuming ease means there is nothing to learn."
        case .mirrored:
            return "The risk is moving too fast because something feels familiar."
        case .growth:
            return "The rhythm works best when neither person tries to convert the other."
        case .magnetic:
            return "The pull is real, but timing will matter more than intensity."
        case .intense:
            if isChineseConflict(userChinese, candidateChinese) {
                return "The deeper instincts may push against each other. Go slower than the charge wants."
            }

            if isHighTensionWesternPair(userWestern, candidateWestern) {
                return "The surface styles can spark. That is useful only if both people stay honest."
            }

            return "The connection may feel loud before it becomes clear."
        }
    }

    private func westernElement(of sign: WesternZodiac) -> String {
        switch sign.displayName.lowercased() {
        case "aries", "leo", "sagittarius":
            return "fire"
        case "taurus", "virgo", "capricorn":
            return "earth"
        case "gemini", "libra", "aquarius":
            return "air"
        case "cancer", "scorpio", "pisces":
            return "water"
        default:
            return "unknown"
        }
    }

    private func isSupportiveWesternPair(_ a: WesternZodiac, _ b: WesternZodiac) -> Bool {
        let pair = normalizedPair(a.displayName, b.displayName)

        let supportive: Set<String> = [
            normalizedPair("Aries", "Gemini"),
            normalizedPair("Aries", "Aquarius"),
            normalizedPair("Taurus", "Cancer"),
            normalizedPair("Taurus", "Pisces"),
            normalizedPair("Gemini", "Leo"),
            normalizedPair("Cancer", "Virgo"),
            normalizedPair("Leo", "Libra"),
            normalizedPair("Virgo", "Scorpio"),
            normalizedPair("Libra", "Sagittarius"),
            normalizedPair("Scorpio", "Capricorn"),
            normalizedPair("Sagittarius", "Aquarius"),
            normalizedPair("Capricorn", "Pisces")
        ]

        return supportive.contains(pair)
    }

    private func isHighTensionWesternPair(_ a: WesternZodiac, _ b: WesternZodiac) -> Bool {
        let pair = normalizedPair(a.displayName, b.displayName)

        let tense: Set<String> = [
            normalizedPair("Aries", "Cancer"),
            normalizedPair("Aries", "Capricorn"),
            normalizedPair("Taurus", "Leo"),
            normalizedPair("Taurus", "Aquarius"),
            normalizedPair("Gemini", "Virgo"),
            normalizedPair("Gemini", "Pisces"),
            normalizedPair("Cancer", "Libra"),
            normalizedPair("Leo", "Scorpio"),
            normalizedPair("Virgo", "Sagittarius"),
            normalizedPair("Libra", "Capricorn"),
            normalizedPair("Scorpio", "Aquarius"),
            normalizedPair("Sagittarius", "Pisces")
        ]

        return tense.contains(pair)
    }

    private func isChineseTrine(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let pair = normalizedPair(a.displayName, b.displayName)

        let trines: Set<String> = [
            normalizedPair("Rat", "Dragon"),
            normalizedPair("Rat", "Monkey"),
            normalizedPair("Dragon", "Monkey"),

            normalizedPair("Ox", "Snake"),
            normalizedPair("Ox", "Rooster"),
            normalizedPair("Snake", "Rooster"),

            normalizedPair("Tiger", "Horse"),
            normalizedPair("Tiger", "Dog"),
            normalizedPair("Horse", "Dog"),

            normalizedPair("Rabbit", "Goat"),
            normalizedPair("Rabbit", "Pig"),
            normalizedPair("Goat", "Pig")
        ]

        return trines.contains(pair)
    }

    private func isChineseComplement(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let pair = normalizedPair(a.displayName, b.displayName)

        let complements: Set<String> = [
            normalizedPair("Rat", "Ox"),
            normalizedPair("Tiger", "Pig"),
            normalizedPair("Rabbit", "Dog"),
            normalizedPair("Dragon", "Rooster"),
            normalizedPair("Snake", "Monkey"),
            normalizedPair("Horse", "Goat")
        ]

        return complements.contains(pair)
    }

    private func isChineseConflict(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let pair = normalizedPair(a.displayName, b.displayName)

        let conflicts: Set<String> = [
            normalizedPair("Rat", "Horse"),
            normalizedPair("Ox", "Goat"),
            normalizedPair("Tiger", "Monkey"),
            normalizedPair("Rabbit", "Rooster"),
            normalizedPair("Dragon", "Dog"),
            normalizedPair("Snake", "Pig")
        ]

        return conflicts.contains(pair)
    }

    private func normalizedPair(_ a: String, _ b: String) -> String {
        [normalize(a), normalize(b)].sorted().joined(separator: "|")
    }

    private func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "cat", with: "rabbit")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
