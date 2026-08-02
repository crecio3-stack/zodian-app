import Foundation
import SwiftUI

struct ConnectProfileGenerator {
    static let shared = ConnectProfileGenerator()

    private init() {}

    private struct SignPair {
        let western: WesternZodiac
        let chinese: ChineseZodiac
    }

    private struct StagedProfileCopy {
        let bio: String
        let signals: [ConnectProfileSignal]
        let openTo: String
    }

    private struct AnchorProfile {
        let western: WesternZodiac
        let chinese: ChineseZodiac
        let copy: StagedProfileCopy
    }

    private let names = [
        "Selene", "Orion", "Mira", "Rowan", "Luna", "Cassian",
        "Nova", "Iris", "Kai", "Lyra", "Atlas", "Aria",
        "Noah", "Cleo", "Zane", "Thea", "Ezra", "Nico",
        "Rhea", "Ari"
    ]

    private let openToOptions = [
        "Friendship",
        "Real conversation",
        "Creative connection",
        "Something steady",
        "Something real",
        "Open to what feels real"
    ]

    private let casualBios = [
        "I warm up slowly, but I’m easy to read once I do",
        "I like being genuine more than polished",
        "I care a lot, sometimes more than I mean to",
        "I like trying new things and seeing where they go",
        "I can talk about almost anything when the conversation feels alive",
        "I start quiet and open up once I feel safe",
        "I can be a little unusual, but I handle myself",
        "I let plans breathe a little",
        "I’m drawn to people who feel warm and steady",
        "I seem reserved at first, then I get honest fast",
        "I’m usually open to plans if they feel natural",
        "I like people who are simple to be around and still interesting",
        "I’m playful, but I notice details",
        "If we click, I’m easy to talk to",
        "I like a little surprise, not the stressful kind",
        "I’m better in person than by text",
        "I take time with people, but I’m not closed off",
        "When something feels right, I’m all in"
    ]

    private let casualSignals = [
        ConnectProfileSignal("How I move", "I warm up slowly"),
        ConnectProfileSignal("What stands out", "I notice the small things"),
        ConnectProfileSignal("What I want", "I need a minute before I open up"),
        ConnectProfileSignal("How I move", "I think a lot about small details"),
        ConnectProfileSignal("What stands out", "I listen closely"),
        ConnectProfileSignal("What I want", "I like things simple"),
        ConnectProfileSignal("How I move", "I remember what people say"),
        ConnectProfileSignal("What stands out", "I don’t fake it well"),
        ConnectProfileSignal("What I want", "I’m trying to say things sooner"),
        ConnectProfileSignal("How I move", "I respond well to humor"),
        ConnectProfileSignal("What stands out", "I like direct communication"),
        ConnectProfileSignal("What I want", "I notice mood shifts fast"),
        ConnectProfileSignal("How I move", "I’m different once I relax"),
        ConnectProfileSignal("What stands out", "I can disappear when I’m overloaded"),
        ConnectProfileSignal("What I want", "Quiet confidence stands out to me"),
        ConnectProfileSignal("How I move", "I do not like being pushed to perform"),
        ConnectProfileSignal("What stands out", "I ask a lot of questions"),
        ConnectProfileSignal("What I want", "I’m softer than I look"),
        ConnectProfileSignal("How I move", "I can be stubborn when it matters"),
        ConnectProfileSignal("What stands out", "I like people with their own style"),
        ConnectProfileSignal("What I want", "I’m open to changing plans"),
        ConnectProfileSignal("How I move", "I joke before I get serious"),
        ConnectProfileSignal("What stands out", "I’d rather hear the truth"),
        ConnectProfileSignal("What I want", "I try not to rush my feelings"),
        ConnectProfileSignal("How I move", "I like honesty that stays easy")
    ]

    private let anchorProfiles: [AnchorProfile] = [
        AnchorProfile(
            western: .libra,
            chinese: .snake,
            copy: StagedProfileCopy(
                bio: "I like calm, but not dull",
                signals: [
                    ConnectProfileSignal("How I move", "I take my time with responses"),
                    ConnectProfileSignal("What stands out", "I notice small shifts fast"),
                    ConnectProfileSignal("What I want", "I let very few people close")
                ],
                openTo: "Real conversation"
            )
        ),
        AnchorProfile(
            western: .taurus,
            chinese: .horse,
            copy: StagedProfileCopy(
                bio: "I stay steady until something matters",
                signals: [
                    ConnectProfileSignal("How I move", "I’m dependable, not boring"),
                    ConnectProfileSignal("What stands out", "I know what I like"),
                    ConnectProfileSignal("What I want", "Effort matters to me")
                ],
                openTo: "Something steady"
            )
        ),
        AnchorProfile(
            western: .pisces,
            chinese: .dog,
            copy: StagedProfileCopy(
                bio: "I feel things deeply, even when I keep them in",
                signals: [
                    ConnectProfileSignal("How I move", "I’m softer than I seem"),
                    ConnectProfileSignal("What stands out", "I notice subtle changes"),
                    ConnectProfileSignal("What I want", "I care more than I admit")
                ],
                openTo: "Something real"
            )
        ),
        AnchorProfile(
            western: .sagittarius,
            chinese: .monkey,
            copy: StagedProfileCopy(
                bio: "Curiosity usually shows up before plans do",
                signals: [
                    ConnectProfileSignal("How I move", "I like to keep things interesting"),
                    ConnectProfileSignal("What stands out", "Humor gets my attention fast"),
                    ConnectProfileSignal("What I want", "I’m willing to try almost anything once")
                ],
                openTo: "Open to what feels real"
            )
        ),
        AnchorProfile(
            western: .gemini,
            chinese: .dragon,
            copy: StagedProfileCopy(
                bio: "I can talk about almost anything when the conversation feels alive",
                signals: [
                    ConnectProfileSignal("How I move", "My thoughts move quickly"),
                    ConnectProfileSignal("What stands out", "I ask the questions people avoid"),
                    ConnectProfileSignal("What I want", "I need someone who can keep up")
                ],
                openTo: "Creative connection"
            )
        ),
        AnchorProfile(
            western: .scorpio,
            chinese: .dragon,
            copy: StagedProfileCopy(
                bio: "I do not give my full attention easily",
                signals: [
                    ConnectProfileSignal("How I move", "I don’t miss much"),
                    ConnectProfileSignal("What stands out", "I notice what people hide"),
                    ConnectProfileSignal("What I want", "I trust slowly")
                ],
                openTo: "Something real"
            )
        ),
        AnchorProfile(
            western: .aquarius,
            chinese: .snake,
            copy: StagedProfileCopy(
                bio: "My perspective is a little unusual, and I trust my instincts",
                signals: [
                    ConnectProfileSignal("How I move", "I need space to think"),
                    ConnectProfileSignal("What stands out", "I do not fit easy categories"),
                    ConnectProfileSignal("What I want", "I’m trying to say things sooner")
                ],
                openTo: "Real conversation"
            )
        ),
        AnchorProfile(
            western: .aries,
            chinese: .rat,
            copy: StagedProfileCopy(
                bio: "I move fast when something feels right",
                signals: [
                    ConnectProfileSignal("How I move", "I keep things simple"),
                    ConnectProfileSignal("What stands out", "I read the room fast"),
                    ConnectProfileSignal("What I want", "I say exactly what I mean")
                ],
                openTo: "Friendship"
            )
        ),
        AnchorProfile(
            western: .leo,
            chinese: .horse,
            copy: StagedProfileCopy(
                bio: "I like people who make life feel brighter",
                signals: [
                    ConnectProfileSignal("How I move", "I bring a lot of presence"),
                    ConnectProfileSignal("What stands out", "I show up fully"),
                    ConnectProfileSignal("What I want", "I do not do halfway")
                ],
                openTo: "Something steady"
            )
        )
    ]

    private let feminineNames: Set<String> = [
        "Selene", "Mira", "Luna", "Nova", "Iris",
        "Lyra", "Aria", "Cleo", "Thea", "Rhea"
    ]

    private let masculineNames: Set<String> = [
        "Orion", "Rowan", "Cassian", "Kai", "Atlas",
        "Noah", "Ezra", "Zane", "Nico", "Ari"
    ]

    private var maxDeckSize: Int {
        maxAvailablePortraitCount
    }

    private var feminineAssets: [String] {
        Array(Set(ConnectPortraitCatalog.feminineAssetNames)).sorted()
    }

    private var masculineAssets: [String] {
        Array(Set(ConnectPortraitCatalog.masculineAssetNames)).sorted()
    }

    private var maxAvailablePortraitCount: Int {
        Set(feminineAssets + masculineAssets).count
    }

    func generateProfiles(
        for user: UserProfile,
        count requestedCount: Int = 20,
        excluding keysToAvoid: Set<String> = []
    ) -> [DeckProfile] {
        print("🟡 Generating profiles...")

        let targetCount = min(requestedCount, maxDeckSize)
        guard targetCount > 0 else {
            print("🟢 Generated 0 profiles")
            return []
        }

        let userWestern = user.westernSign
        let userChinese = user.chineseSign
        let userArchetype = ArchetypeService.shared.archetype(for: userWestern, chinese: userChinese)

        let imageSlots = makeImageSlots(
            limit: targetCount,
            seed: stableHash("\(userWestern.rawValue)|\(userChinese.rawValue)|\(userArchetype.id)|\(keysToAvoid.count)")
        )
        guard !imageSlots.isEmpty else {
            print("🟢 Generated 0 profiles")
            return []
        }

        let candidatePairs = makeCandidatePairs(
            userWestern: userWestern,
            userChinese: userChinese
        )

        var generated: [DeckProfile] = []
        var usedKeys = keysToAvoid
        var usedNames = Set<String>()

        var slotIndex = 0
        var attempt = 0
        let hardLimit = 200

        while generated.count < targetCount && attempt < hardLimit && attempt < candidatePairs.count {
            let pairIndex = attempt
            attempt += 1

            guard generated.count < imageSlots.count else { break }

            let pair = candidatePairs[pairIndex]

            let western = pair.western
            let chinese = pair.chinese
            let archetype = ArchetypeService.shared.archetype(for: western, chinese: chinese)
            let slot = imageSlots[slotIndex]

            guard let candidateName = nextAvailableName(
                preferredPresentation: slot.presentation,
                usedNames: usedNames,
                usedKeys: usedKeys,
                archetypeId: archetype.id,
                seed: mixedSeed(pairIndex + 1, generated.count + slotIndex)
            ) else {
                continue
            }

            let key = "\(archetype.id)|\(candidateName)"
            guard !usedKeys.contains(key) else { continue }

            let compatibility = CompatibilityScoringService.shared.score(
                userWestern: userWestern,
                userChinese: userChinese,
                userArchetypeId: userArchetype.id,
                candidateWestern: western,
                candidateChinese: chinese,
                candidateArchetypeId: archetype.id
            )

            usedKeys.insert(key)
            usedNames.insert(candidateName)

            let age = 24 + positiveMod(
                mixedSeed(pairIndex + 1, western.rawValue.count + chinese.rawValue.count),
                11
            )

            let style = compatibility.style
            let stagedCopy = makeStagedProfileCopy(
                western: western,
                chinese: chinese,
                style: style,
                seed: mixedSeed(pairIndex + 7, candidateName.count)
            )
            let reasons = makeCompatibilityReasons(
                userWestern: userWestern,
                userChinese: userChinese,
                candidateWestern: western,
                candidateChinese: chinese,
                compatibility: compatibility
            )

            let profile = DeckProfile(
                name: candidateName,
                age: age,
                archetypeId: archetype.id,
                archetypeTitle: archetype.title,
                combinedSigns: "\(western.displayName) × \(chinese.displayName)",
                westernSign: western,
                chineseSign: chinese,
                essence: stagedCopy.bio,
                connectionPrompt: makeConnectionPrompt(
                    userWestern: userWestern,
                    userChinese: userChinese,
                    candidateWestern: western,
                    candidateChinese: chinese,
                    compatibility: compatibility
                ),
                compatibilityScore: compatibility.totalScore,
                matchStyle: style,
                matchReasons: reasons,
                frictionNote: makeFrictionNote(
                    userWestern: userWestern,
                    userChinese: userChinese,
                    candidateWestern: western,
                    candidateChinese: chinese,
                    style: style
                ),
                imageName: slot.imageName,
                imageAnchor: ConnectPortraitCatalog.focalPoint(for: slot.imageName) ?? ConnectPortraitCatalog.anchor(seed: mixedSeed(stableHash(slot.imageName), slotIndex + generated.count)),
                intent: stagedCopy.openTo,
                signals: stagedCopy.signals
            )

            generated.append(profile)
            slotIndex += 1
        }

        print("🟢 Generated \(generated.count) profiles")
        return generated
    }

    // MARK: - Image Slots

    private struct ImageSlot {
        let imageName: String
        let presentation: ConnectPortraitCatalog.Presentation
    }

    private func makeImageSlots(limit: Int, seed: Int) -> [ImageSlot] {
        let feminine = rotatedSlots(
            feminineAssets.map { ImageSlot(imageName: $0, presentation: .feminine) },
            seed: seed + 3
        )

        let masculine = rotatedSlots(
            masculineAssets.map { ImageSlot(imageName: $0, presentation: .masculine) },
            seed: seed + 7
        )

        var slots: [ImageSlot] = []
        let maxCount = max(feminine.count, masculine.count)

        for index in 0..<maxCount {
            let masculineFirst = positiveMod(seed + index, 2) == 1

            if masculineFirst {
                if masculine.indices.contains(index) { slots.append(masculine[index]) }
                if feminine.indices.contains(index) { slots.append(feminine[index]) }
            } else {
                if feminine.indices.contains(index) { slots.append(feminine[index]) }
                if masculine.indices.contains(index) { slots.append(masculine[index]) }
            }
        }

        return Array(slots.prefix(limit))
    }

    private func rotatedSlots(_ slots: [ImageSlot], seed: Int) -> [ImageSlot] {
        guard !slots.isEmpty else { return [] }

        let offset = positiveMod(seed, slots.count)
        guard offset > 0 else { return slots }

        return Array(slots[offset...]) + Array(slots[..<offset])
    }

    // MARK: - Name Selection

    private func nextAvailableName(
        preferredPresentation: ConnectPortraitCatalog.Presentation,
        usedNames: Set<String>,
        usedKeys: Set<String>,
        archetypeId: String,
        seed: Int
    ) -> String? {
        let preferredPool = namesForPresentation(preferredPresentation)
        if let preferred = pickUnusedName(
            from: preferredPool,
            usedNames: usedNames,
            usedKeys: usedKeys,
            archetypeId: archetypeId,
            seed: seed
        ) {
            return preferred
        }

        return nil
    }

    private func namesForPresentation(_ presentation: ConnectPortraitCatalog.Presentation) -> [String] {
        switch presentation {
        case .feminine:
            return names.filter { feminineNames.contains($0) }
        case .masculine:
            return names.filter { masculineNames.contains($0) }
        case .neutral:
            return []
        }
    }

    private func pickUnusedName(
        from pool: [String],
        usedNames: Set<String>,
        usedKeys: Set<String>,
        archetypeId: String,
        seed: Int
    ) -> String? {
        let available = pool.filter {
            !usedNames.contains($0) && !usedKeys.contains("\(archetypeId)|\($0)")
        }
        guard !available.isEmpty else { return nil }
        return available[positiveMod(seed, available.count)]
    }

    // MARK: - Sign Pair Selection

    private func makeCandidatePairs(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac
    ) -> [SignPair] {
        var pairs: [SignPair] = []
        var usedPairKeys = Set<String>()

        func append(_ western: WesternZodiac, _ chinese: ChineseZodiac) {
            guard western != userWestern || chinese != userChinese else { return }

            let key = pairKey(western: western, chinese: chinese)
            guard !usedPairKeys.contains(key) else { return }

            usedPairKeys.insert(key)
            pairs.append(SignPair(western: western, chinese: chinese))
        }

        anchorProfiles.forEach { append($0.western, $0.chinese) }

        for western in WesternZodiac.allCases {
            for chinese in ChineseZodiac.allCases {
                append(western, chinese)
            }
        }

        return pairs
    }

    private func pairKey(western: WesternZodiac, chinese: ChineseZodiac) -> String {
        "\(western.rawValue)|\(chinese.rawValue)"
    }

    // MARK: - Seeds

    private func mixedSeed(_ a: Int, _ b: Int) -> Int {
        var x = UInt64(bitPattern: Int64(a &* 1_103_515_245 &+ b &* 12_345))
        x ^= x >> 33
        x &*= 0xff51afd7ed558ccd
        x ^= x >> 33
        x &*= 0xc4ceb9fe1a85ec53
        x ^= x >> 33
        return Int(truncatingIfNeeded: x)
    }

    private func stableHash(_ value: String) -> Int {
        var hash = 5381

        for scalar in value.unicodeScalars {
            hash = ((hash << 5) &+ hash) &+ Int(scalar.value)
        }

        return hash
    }

    private func positiveMod(_ value: Int, _ count: Int) -> Int {
        guard count > 0 else { return 0 }
        let result = value % count
        return result >= 0 ? result : result + count
    }

    // MARK: - Copy

    private func makeStagedProfileCopy(
        western: WesternZodiac,
        chinese: ChineseZodiac,
        style: MatchStyle,
        seed: Int
    ) -> StagedProfileCopy {
        if let anchor = anchorProfiles.first(where: { $0.western == western && $0.chinese == chinese }) {
            return anchor.copy
        }

        let bio = casualBios[positiveMod(seed, casualBios.count)]
        let signals = pickSignals(seed: seed + western.rawValue.count + chinese.rawValue.count)
        let openTo = openTo(for: style, seed: seed)

        return StagedProfileCopy(
            bio: bio,
            signals: signals,
            openTo: openTo
        )
    }

    private func pickSignals(seed: Int) -> [ConnectProfileSignal] {
        let desiredCount = min(3, casualSignals.count)
        guard desiredCount > 0 else { return [] }

        var selected: [ConnectProfileSignal] = []
        var index = positiveMod(seed, casualSignals.count)
        let step = positiveMod(seed / 7, casualSignals.count - 1) + 1
        var attempt = 0
        let hardLimit = max(casualSignals.count * 2, 10)

        while selected.count < desiredCount && attempt < hardLimit {
            attempt += 1

            let signal = casualSignals[index]
            if !selected.contains(signal) {
                selected.append(signal)
            }

            index = positiveMod(index + step, casualSignals.count)
        }

        if selected.count < desiredCount {
            for signal in casualSignals where !selected.contains(signal) {
                selected.append(signal)
                if selected.count == desiredCount { break }
            }
        }

        return selected
    }

    private func makeConnectionPrompt(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        compatibility: CompatibilityBreakdown
    ) -> String {
        switch compatibility.style {
        case .harmonious:
            return "This feels easier because neither of you has to perform at full volume."

        case .mirrored:
            return "Something in their pace may feel familiar before you know why."

        case .growth:
            return "They move differently enough to make your usual response visible."

        case .magnetic:
            return "The contrast keeps your attention because it does not settle too quickly."

        case .intense:
            return "You may both handle pressure in ways that need a little more patience."
        }
    }

    private func makeCompatibilityReasons(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        compatibility: CompatibilityBreakdown
    ) -> [MatchReason] {
        [
            MatchReason(
                title: "Why they showed up",
                detail: whyTheyShowedUp(
                    userWestern: userWestern,
                    userChinese: userChinese,
                    candidateWestern: candidateWestern,
                    candidateChinese: candidateChinese,
                    style: compatibility.style
                )
            ),
            MatchReason(
                title: "What to notice",
                detail: deeperCompatibility(
                    userWestern: userWestern,
                    userChinese: userChinese,
                    candidateWestern: candidateWestern,
                    candidateChinese: candidateChinese,
                    score: compatibility.totalScore,
                    style: compatibility.style
                )
            )
        ]
    }

    private func whyTheyShowedUp(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        style: MatchStyle
    ) -> String {
        switch style {
        case .harmonious:
            return "They bring an ease that lets both people stay natural."
        case .mirrored:
            return "They may feel familiar because you both return to similar cues."
        case .growth:
            return "They bring a pace you may not choose first, which makes the difference useful."
        case .magnetic:
            return "The difference is clear enough to keep you curious."
        case .intense:
            return "The signal is strong because neither person can coast on assumption."
        }
    }

    private func deeperCompatibility(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        score: Int,
        style: MatchStyle
    ) -> String {
        switch style {
        case .harmonious:
            return "The connection works best when ease stays awake, not automatic."
        case .mirrored:
            return "The recognition may arrive quickly. Do not let familiar mean fully known."
        case .growth:
            return "Their way of responding gives the connection somewhere useful to go."
        case .magnetic:
            return "The interest comes from timing, curiosity, and the way each person responds differently."
        case .intense:
            return "The interest may feel obvious at first. Move slowly enough to read what is actually there."
        }
    }

    private func makeFrictionNote(
        userWestern: WesternZodiac,
        userChinese: ChineseZodiac,
        candidateWestern: WesternZodiac,
        candidateChinese: ChineseZodiac,
        style: MatchStyle
    ) -> String {
        switch style {
        case .harmonious:
            return "The only catch is getting too comfortable and missing what is actually different"
        case .mirrored:
            return "Familiar can make people fill in blanks too quickly. Let them show you the details."
        case .growth:
            return "Your timing may need a minute to find the same beat."
        case .magnetic:
            return "Interest will not do the work by itself. Watch whether the pace feels mutual."
        case .intense:
            return "You may both hold your ground. Go slower than the charge wants."
        }
    }

    private func openTo(for style: MatchStyle, seed: Int) -> String {
        let pool: [String]

        switch style {
        case .harmonious:
            pool = ["Friendship", "Something steady", "Real conversation"]
        case .mirrored:
            pool = ["Friendship", "Real conversation", "Something steady"]
        case .growth:
            pool = ["Creative connection", "Something steady", "Open to what feels real"]
        case .magnetic:
            pool = ["Creative connection", "Something real", "Open to what feels real"]
        case .intense:
            pool = ["Real conversation", "Something real", "Open to what feels real"]
        }

        let choice = pool[positiveMod(seed, pool.count)]
        return openToOptions.contains(choice) ? choice : openToOptions[positiveMod(seed, openToOptions.count)]
    }

    private func sharedLanguage(
        _ userWestern: WesternZodiac,
        _ userChinese: ChineseZodiac,
        _ candidateWestern: WesternZodiac,
        _ candidateChinese: ChineseZodiac
    ) -> String {
        if userWestern == candidateWestern {
            return "a similar first impression"
        }

        if userChinese == candidateChinese {
            return "a similar deeper reflex"
        }

        if westernElement(of: userWestern) == westernElement(of: candidateWestern) {
            return "you both recognize the same kind of pace"
        }

        return "you read the room from different angles"
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

    private func westernPace(for sign: WesternZodiac) -> String {
        switch sign {
        case .aries:
            return "direct"
        case .taurus:
            return "steady"
        case .gemini:
            return "quick"
        case .cancer:
            return "careful"
        case .leo:
            return "expressive"
        case .virgo:
            return "measured"
        case .libra:
            return "social"
        case .scorpio:
            return "private"
        case .sagittarius:
            return "restless"
        case .capricorn:
            return "reserved"
        case .aquarius:
            return "unusual"
        case .pisces:
            return "soft"
        }
    }

    private func chineseInstinct(for sign: ChineseZodiac) -> String {
        switch sign {
        case .rat:
            return "resourceful"
        case .ox:
            return "patient"
        case .tiger:
            return "bold"
        case .rabbit:
            return "sensitive"
        case .dragon:
            return "confident"
        case .snake:
            return "observant"
        case .horse:
            return "independent"
        case .goat:
            return "gentle"
        case .monkey:
            return "curious"
        case .rooster:
            return "precise"
        case .dog:
            return "loyal"
        case .pig:
            return "open"
        }
    }
}
