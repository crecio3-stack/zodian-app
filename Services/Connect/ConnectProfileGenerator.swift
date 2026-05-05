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
        "Nova", "Sage", "Iris", "Kai", "Lyra", "Atlas",
        "Aria", "Jules", "Noah", "Skye", "Eden", "Ezra",
        "Cleo", "Zane", "Thea", "Nico", "Rhea", "Ari"
    ]

    private let openToOptions = [
        "Friendship",
        "Real conversation",
        "Creative connection",
        "Shared rhythm",
        "Something real",
        "Open to whatever fits"
    ]

    private let casualBios = [
        "Not difficult to get along with, but it takes a minute for me to relax and warm up.",
        "I prefer to be natural and authentic rather than artificial.",
        "I'm a caring person; perhaps, overly so.",
        "I love experimenting and experiencing fresh adventures.",
        "I can talk about anything with anyone when we vibe.",
        "Initially, I tend to remain reserved and guarded, only becoming more relaxed after gaining comfort.",
        "I am a bit unconventional, although I always manage to pull through.",
        "I prefer going with the flow and improvising.",
        "I like people who radiate positive energy.",
        "Quiet initially, but probably too honest later.",
        "I am down for plans if they come naturally.",
        "I like people who can be ordinary yet fascinating at the same time.",
        "A humorous individual, yet attentive to detail.",
        "Conversationally, I am not a challenge if we vibe correctly.",
        "I enjoy a bit of chaos in my life, but not the stress-inducing variety.",
        "Better in person than over text; truthfully.",
        "I take time with individuals, but I'm not close-minded.",
        "When everything clicks with ease, I'm happy."
    ]

    private let casualSignals = [
        ConnectProfileSignal("How they come across", "I'm quiet initially"),
        ConnectProfileSignal("What you notice first", "I observe the small things"),
        ConnectProfileSignal("One thing about them", "I require a minute to loosen up"),
        ConnectProfileSignal("How they come across", "I think excessively about minor things"),
        ConnectProfileSignal("What you notice first", "I listen actively"),
        ConnectProfileSignal("One thing about them", "I like simplicity, nothing complex"),
        ConnectProfileSignal("How they come across", "I recall insignificant details"),
        ConnectProfileSignal("What you notice first", "I don't excel at acting"),
        ConnectProfileSignal("One thing about them", "I'm learning to express myself sooner"),
        ConnectProfileSignal("How they come across", "I respond to humor when comfortable"),
        ConnectProfileSignal("What you notice first", "I appreciate straightforward communication"),
        ConnectProfileSignal("One thing about them", "I detect any mood swings"),
        ConnectProfileSignal("How they come across", "I am a completely distinct person when at ease"),
        ConnectProfileSignal("What you notice first", "I may vanish when overloaded"),
        ConnectProfileSignal("One thing about them", "Quiet self-assurance makes an impression on me"),
        ConnectProfileSignal("How they come across", "I hate being under pressure to perform"),
        ConnectProfileSignal("What you notice first", "I question extensively"),
        ConnectProfileSignal("One thing about them", "I'm softer than I appear"),
        ConnectProfileSignal("How they come across", "I may be obstinate when necessary"),
        ConnectProfileSignal("What you notice first", "I like those who have their own style"),
        ConnectProfileSignal("One thing about them", "I'm okay with changing arrangements"),
        ConnectProfileSignal("How they come across", "Jokes are generally how I make contact"),
        ConnectProfileSignal("What you notice first", "I'd rather hear the truth"),
        ConnectProfileSignal("One thing about them", "I attempt not to rush every emotion"),
        ConnectProfileSignal("How they come across", "I value sincerity without making it awkward")
    ]

    private let anchorProfiles: [AnchorProfile] = [
        AnchorProfile(
            western: .libra,
            chinese: .snake,
            copy: StagedProfileCopy(
                bio: "I enjoy serenity, though nothing dull.",
                signals: [
                    ConnectProfileSignal("How they come across", "I take my time with responses"),
                    ConnectProfileSignal("What you notice first", "I detect subtle alterations"),
                    ConnectProfileSignal("One thing about them", "I select carefully those who can come near")
                ],
                openTo: "Real conversation"
            )
        ),
        AnchorProfile(
            western: .taurus,
            chinese: .horse,
            copy: StagedProfileCopy(
                bio: "I am level-headed until something worth pursuing appears.",
                signals: [
                    ConnectProfileSignal("How they come across", "I am dependable, but not predictable"),
                    ConnectProfileSignal("What you notice first", "I know my preferences"),
                    ConnectProfileSignal("One thing about them", "Effort is essential to me")
                ],
                openTo: "Shared rhythm"
            )
        ),
        AnchorProfile(
            western: .pisces,
            chinese: .dog,
            copy: StagedProfileCopy(
                bio: "I experience emotions strongly, even if I strive to suppress them.",
                signals: [
                    ConnectProfileSignal("How they come across", "I am softer than I seem"),
                    ConnectProfileSignal("What you notice first", "I detect subtle changes"),
                    ConnectProfileSignal("One thing about them", "I care more than I admit")
                ],
                openTo: "Something real"
            )
        ),
        AnchorProfile(
            western: .sagittarius,
            chinese: .monkey,
            copy: StagedProfileCopy(
                bio: "Curiosity precedes planning in my case.",
                signals: [
                    ConnectProfileSignal("How they come across", "I keep things interesting"),
                    ConnectProfileSignal("What you notice first", "Humor is my entry point"),
                    ConnectProfileSignal("One thing about them", "I will test virtually anything once")
                ],
                openTo: "Open possibility"
            )
        ),
        AnchorProfile(
            western: .gemini,
            chinese: .dragon,
            copy: StagedProfileCopy(
                bio: "I may discuss anything, yet stay for the excitement.",
                signals: [
                    ConnectProfileSignal("How they come across", "My thoughts are quick-moving"),
                    ConnectProfileSignal("What you notice first", "I pose inquiries that people avoid"),
                    ConnectProfileSignal("One thing about them", "I must find someone to keep up with")
                ],
                openTo: "Creative connection"
            )
        ),
        AnchorProfile(
            western: .scorpio,
            chinese: .dragon,
            copy: StagedProfileCopy(
                bio: "I don't give others my full attention easily.",
                signals: [
                    ConnectProfileSignal("How they come across", "I don't overlook much"),
                    ConnectProfileSignal("What you notice first", "I perceive what people conceal"),
                    ConnectProfileSignal("One thing about them", "I trust slowly")
                ],
                openTo: "Something real"
            )
        ),
        AnchorProfile(
            western: .aquarius,
            chinese: .snake,
            copy: StagedProfileCopy(
                bio: "My perspective is unusual, and I frequently trust my instincts.",
                signals: [
                    ConnectProfileSignal("How they come across", "I require space to think"),
                    ConnectProfileSignal("What you notice first", "I don't fit in the apparent categories"),
                    ConnectProfileSignal("One thing about them", "I am attempting to clarify myself sooner")
                ],
                openTo: "Real conversation"
            )
        ),
        AnchorProfile(
            western: .aries,
            chinese: .rat,
            copy: StagedProfileCopy(
                bio: "I act swiftly when things seem appropriate.",
                signals: [
                    ConnectProfileSignal("How they come across", "I do not over-complicate anything"),
                    ConnectProfileSignal("What you notice first", "I quickly gauge the environment"),
                    ConnectProfileSignal("One thing about them", "I say precisely what I imply")
                ],
                openTo: "Friendship"
            )
        ),
        AnchorProfile(
            western: .leo,
            chinese: .horse,
            copy: StagedProfileCopy(
                bio: "I admire individuals who enhance life.",
                signals: [
                    ConnectProfileSignal("How they come across", "I provide lots of vitality"),
                    ConnectProfileSignal("What you notice first", "I fully participate"),
                    ConnectProfileSignal("One thing about them", "I don't reduce well")
                ],
                openTo: "Shared rhythm"
            )
        )
    ]

    private let feminineNames: Set<String> = [
        "Selene", "Mira", "Luna", "Nova", "Iris", "Lyra",
        "Aria", "Cleo", "Thea", "Rhea", "Skye", "Ari"
    ]

    private let masculineNames: Set<String> = [
        "Orion", "Rowan", "Cassian", "Kai", "Atlas", "Noah",
        "Ezra", "Zane", "Nico"
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

    private var neutralAssets: [String] {
        Array(Set(ConnectPortraitCatalog.neutralAssetNames)).sorted()
    }

    private var maxAvailablePortraitCount: Int {
        Set(feminineAssets + masculineAssets + neutralAssets).count
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
                imageAnchor: ConnectPortraitCatalog.anchor(seed: mixedSeed(stableHash(slot.imageName), slotIndex + generated.count)),
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

        let neutral = rotatedSlots(
            neutralAssets.map { ImageSlot(imageName: $0, presentation: .neutral) },
            seed: seed + 11
        )

        var slots: [ImageSlot] = []
        let maxCount = max(feminine.count, masculine.count, neutral.count)

        for index in 0..<maxCount {
            let order = positiveMod(seed + index, 3)

            switch order {
            case 0:
                if feminine.indices.contains(index) { slots.append(feminine[index]) }
                if masculine.indices.contains(index) { slots.append(masculine[index]) }
                if neutral.indices.contains(index) { slots.append(neutral[index]) }
            case 1:
                if masculine.indices.contains(index) { slots.append(masculine[index]) }
                if neutral.indices.contains(index) { slots.append(neutral[index]) }
                if feminine.indices.contains(index) { slots.append(feminine[index]) }
            default:
                if neutral.indices.contains(index) { slots.append(neutral[index]) }
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
        let fallbackPool = names.filter { !preferredPool.contains($0) }

        if let preferred = pickUnusedName(
            from: preferredPool,
            usedNames: usedNames,
            usedKeys: usedKeys,
            archetypeId: archetypeId,
            seed: seed
        ) {
            return preferred
        }

        if let fallback = pickUnusedName(
            from: fallbackPool,
            usedNames: usedNames,
            usedKeys: usedKeys,
            archetypeId: archetypeId,
            seed: seed + 11
        ) {
            return fallback
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
            return names.filter { !feminineNames.contains($0) && !masculineNames.contains($0) }
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
        let userElement = westernElement(of: userWestern)
        let candidateElement = westernElement(of: candidateWestern)

        switch compatibility.style {
        case .harmonious:
            return "Your \(userWestern.displayName) \(userElement) and their \(candidateWestern.displayName) \(candidateElement) can settle into an easy pace."

        case .mirrored:
            return "The familiar part is real: \(sharedLanguage(userWestern, userChinese, candidateWestern, candidateChinese))."

        case .growth:
            return "They move at a different speed, which can help your \(userWestern.displayName) side adjust without losing itself."

        case .magnetic:
            return "The pull comes from contrast: your \(userElement) read meets their \(candidateElement) read in a way that keeps attention."

        case .intense:
            return "This has charge because \(userWestern.displayName) and \(candidateWestern.displayName) do not handle pressure the same way."
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
                title: "Deeper compatibility",
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
        let userElement = westernElement(of: userWestern)
        let candidateElement = westernElement(of: candidateWestern)

        switch style {
        case .harmonious:
            return "\(candidateWestern.displayName) \(candidateElement) and \(candidateChinese.displayName) instinct match your pace without asking either side to perform."
        case .mirrored:
            return "There is overlap in how you both move: \(sharedLanguage(userWestern, userChinese, candidateWestern, candidateChinese))."
        case .growth:
            return "They bring a rhythm your \(userWestern.displayName) side may not lead with, which is why the match has room to teach you something."
        case .magnetic:
            return "Your \(userElement) style and their \(candidateElement) style create enough difference to keep the room interesting."
        case .intense:
            return "The signal is strong because your signs push on different needs around speed, control, or emotional timing."
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
        let userPace = westernPace(for: userWestern)
        let candidatePace = westernPace(for: candidateWestern)
        let userInstinct = chineseInstinct(for: userChinese)
        let candidateInstinct = chineseInstinct(for: candidateChinese)

        switch style {
        case .harmonious:
            return "This works because your \(userPace) pace has room for their \(candidatePace) pace, while \(userChinese.displayName) and \(candidateChinese.displayName) do not fight for the same role."
        case .mirrored:
            return "The score is high because there is recognition in the pattern. The only thing to watch is assuming the familiar parts mean the rest is already understood."
        case .growth:
            return "Your \(userInstinct) instinct meets their \(candidateInstinct) instinct. That can feel different at first, but the difference gives the connection somewhere useful to go."
        case .magnetic:
            return "The compatibility is not about sameness. It comes from timing, curiosity, and the way your signs pull different reactions out of each other."
        case .intense:
            return "The \(score)% pull is real, but it needs pacing. Their signs may press on places where your signs usually want clarity sooner."
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
            return "The only catch is getting too comfortable and missing what is actually different."
        case .mirrored:
            return "A familiar feeling can make people fill in blanks too quickly. Let them show you the details."
        case .growth:
            return "Your \(userWestern.displayName) timing and their \(candidateWestern.displayName) timing may need a minute to line up."
        case .magnetic:
            return "Chemistry will not do the work by itself. Watch whether the pace feels mutual."
        case .intense:
            return "\(userChinese.displayName) instinct and \(candidateChinese.displayName) instinct can both hold their ground. Go slower than the charge wants."
        }
    }

    private func openTo(for style: MatchStyle, seed: Int) -> String {
        let pool: [String]

        switch style {
        case .harmonious:
            pool = ["Friendship", "Shared rhythm", "Real conversation"]
        case .mirrored:
            pool = ["Friendship", "Real conversation", "Shared rhythm"]
        case .growth:
            pool = ["Creative connection", "Shared rhythm", "Open to whatever fits"]
        case .magnetic:
            pool = ["Creative connection", "Something real", "Open to whatever fits"]
        case .intense:
            pool = ["Real conversation", "Something real", "Open to whatever fits"]
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
            return "the same \(userWestern.displayName) surface rhythm"
        }

        if userChinese == candidateChinese {
            return "the same \(userChinese.displayName) inner reflex"
        }

        if westernElement(of: userWestern) == westernElement(of: candidateWestern) {
            return "both Western signs speak in \(westernElement(of: userWestern))"
        }

        return "\(userWestern.displayName) reads the room one way, while \(candidateWestern.displayName) gives it another angle"
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
