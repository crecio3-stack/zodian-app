//
//  CompatibilityScoringService.swift
//  Zodian
//
//  Created by Ian Recio on 4/11/26.
//


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
        let total = max(58, min(rawTotal, 98))

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
            candidateWestern: candidateWestern
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
        if a == b { return 28 }

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
        if a == b { return 24 }

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
        if a == b { return 28 }

        let aParts = a.split(separator: "-").map(String.init)
        let bParts = b.split(separator: "-").map(String.init)

        guard aParts.count == 2, bParts.count == 2 else { return 18 }

        var score = 18
        if aParts[0] == bParts[0] { score += 5 }
        if aParts[1] == bParts[1] { score += 5 }

        return min(score, 28)
    }

    private func deriveStyle(
        total: Int,
        userWestern: WesternZodiac,
        candidateWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateChinese: ChineseZodiac
    ) -> MatchStyle {
        if total >= 90 { return .harmonious }

        if userWestern == candidateWestern || userChinese == candidateChinese {
            return .mirrored
        }

        if isHighTensionWesternPair(userWestern, candidateWestern) {
            return .intense
        }

        if isSupportiveWesternPair(userWestern, candidateWestern) {
            return .magnetic
        }

        return .growth
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
                    title: "Shared rhythm",
                    detail: "You naturally move through life with similar emotional pacing."
                )
            )
        } else if westernElement(of: userWestern) == westernElement(of: candidateWestern) {
            reasons.append(
                MatchReason(
                    title: "Elemental harmony",
                    detail: "Your core zodiac energy tends to flow in a naturally compatible way."
                )
            )
        } else if isSupportiveWesternPair(userWestern, candidateWestern) {
            reasons.append(
                MatchReason(
                    title: "Balanced polarity",
                    detail: "There is enough contrast here to create chemistry without losing alignment."
                )
            )
        }

        if userChinese == candidateChinese {
            reasons.append(
                MatchReason(
                    title: "Instinctive familiarity",
                    detail: "Your deeper instinctual nature may feel immediately recognizable to each other."
                )
            )
        } else if isChineseTrine(userChinese, candidateChinese) {
            reasons.append(
                MatchReason(
                    title: "Natural support",
                    detail: "Your Chinese zodiac pairing suggests ease, encouragement, and mutual lift."
                )
            )
        }

        let aParts = userArchetypeId.split(separator: "-").map(String.init)
        let bParts = candidateArchetypeId.split(separator: "-").map(String.init)

        if aParts == bParts {
            reasons.append(
                MatchReason(
                    title: "Archetypal mirror",
                    detail: "You carry almost the same energetic pattern, which can feel deeply validating."
                )
            )
        } else if aParts.first == bParts.first || aParts.last == bParts.last {
            reasons.append(
                MatchReason(
                    title: "Pattern overlap",
                    detail: "There is a familiar thread in how your deeper identity expresses itself."
                )
            )
        }

        if reasons.isEmpty {
            reasons.append(
                MatchReason(
                    title: style.label,
                    detail: "This match has enough tension and harmony to feel meaningful rather than flat."
                )
            )
        }

        return Array(reasons.prefix(3))
    }

    private func buildFrictionNote(
        style: MatchStyle,
        userWestern: WesternZodiac,
        candidateWestern: WesternZodiac
    ) -> String {
        if isHighTensionWesternPair(userWestern, candidateWestern) {
            return "Strong attraction may come with power struggles or mismatched pacing."
        }

        switch style {
        case .harmonious:
            return "The challenge here may be comfort without enough challenge."
        case .mirrored:
            return "You may reflect each other so closely that neither person initiates growth."
        case .magnetic:
            return "Chemistry is strong here, but consistency will matter more than intensity."
        case .growth:
            return "The lesson here is learning how to stay open across differences."
        case .intense:
            return "This connection can be transformative, but only if both people communicate clearly."
        }
    }

    private func westernElement(of sign: WesternZodiac) -> String {
        switch sign {
        case .aries, .leo, .sagittarius:
            return "fire"
        case .taurus, .virgo, .capricorn:
            return "earth"
        case .gemini, .libra, .aquarius:
            return "air"
        case .cancer, .scorpio, .pisces:
            return "water"
        }
    }

    private func isSupportiveWesternPair(_ a: WesternZodiac, _ b: WesternZodiac) -> Bool {
        let pair = Set([a.rawValue, b.rawValue])

        let supportivePairs: [Set<String>] = [
            Set([WesternZodiac.aries.rawValue, WesternZodiac.gemini.rawValue]),
            Set([WesternZodiac.aries.rawValue, WesternZodiac.aquarius.rawValue]),
            Set([WesternZodiac.taurus.rawValue, WesternZodiac.cancer.rawValue]),
            Set([WesternZodiac.taurus.rawValue, WesternZodiac.pisces.rawValue]),
            Set([WesternZodiac.gemini.rawValue, WesternZodiac.libra.rawValue]),
            Set([WesternZodiac.cancer.rawValue, WesternZodiac.virgo.rawValue]),
            Set([WesternZodiac.leo.rawValue, WesternZodiac.libra.rawValue]),
            Set([WesternZodiac.virgo.rawValue, WesternZodiac.capricorn.rawValue]),
            Set([WesternZodiac.scorpio.rawValue, WesternZodiac.capricorn.rawValue]),
            Set([WesternZodiac.sagittarius.rawValue, WesternZodiac.aquarius.rawValue]),
            Set([WesternZodiac.pisces.rawValue, WesternZodiac.scorpio.rawValue])
        ]

        return supportivePairs.contains(pair)
    }

    private func isHighTensionWesternPair(_ a: WesternZodiac, _ b: WesternZodiac) -> Bool {
        let pair = Set([a.rawValue, b.rawValue])

        let tensionPairs: [Set<String>] = [
            Set([WesternZodiac.aries.rawValue, WesternZodiac.cancer.rawValue]),
            Set([WesternZodiac.aries.rawValue, WesternZodiac.capricorn.rawValue]),
            Set([WesternZodiac.taurus.rawValue, WesternZodiac.aquarius.rawValue]),
            Set([WesternZodiac.gemini.rawValue, WesternZodiac.scorpio.rawValue]),
            Set([WesternZodiac.cancer.rawValue, WesternZodiac.libra.rawValue]),
            Set([WesternZodiac.leo.rawValue, WesternZodiac.scorpio.rawValue]),
            Set([WesternZodiac.virgo.rawValue, WesternZodiac.sagittarius.rawValue]),
            Set([WesternZodiac.pisces.rawValue, WesternZodiac.gemini.rawValue])
        ]

        return tensionPairs.contains(pair)
    }

    private func isChineseTrine(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let groups: [[ChineseZodiac]] = [
            [.rat, .dragon, .monkey],
            [.ox, .snake, .rooster],
            [.tiger, .horse, .dog],
            [.rabbit, .goat, .pig]
        ]

        return groups.contains { $0.contains(a) && $0.contains(b) }
    }

    private func isChineseComplement(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let complements: [Set<String>] = [
            Set([ChineseZodiac.rat.rawValue, ChineseZodiac.ox.rawValue]),
            Set([ChineseZodiac.tiger.rawValue, ChineseZodiac.rabbit.rawValue]),
            Set([ChineseZodiac.dragon.rawValue, ChineseZodiac.snake.rawValue]),
            Set([ChineseZodiac.horse.rawValue, ChineseZodiac.goat.rawValue]),
            Set([ChineseZodiac.monkey.rawValue, ChineseZodiac.rooster.rawValue]),
            Set([ChineseZodiac.dog.rawValue, ChineseZodiac.pig.rawValue])
        ]

        return complements.contains(Set([a.rawValue, b.rawValue]))
    }

    private func isChineseConflict(_ a: ChineseZodiac, _ b: ChineseZodiac) -> Bool {
        let conflicts: [Set<String>] = [
            Set([ChineseZodiac.rat.rawValue, ChineseZodiac.horse.rawValue]),
            Set([ChineseZodiac.ox.rawValue, ChineseZodiac.goat.rawValue]),
            Set([ChineseZodiac.tiger.rawValue, ChineseZodiac.monkey.rawValue]),
            Set([ChineseZodiac.rabbit.rawValue, ChineseZodiac.rooster.rawValue]),
            Set([ChineseZodiac.dragon.rawValue, ChineseZodiac.dog.rawValue]),
            Set([ChineseZodiac.snake.rawValue, ChineseZodiac.pig.rawValue])
        ]

        return conflicts.contains(Set([a.rawValue, b.rawValue]))
    }
}