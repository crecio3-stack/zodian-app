import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var presentation = HomePatternSurfacePresentation.placeholder

    func refresh(
        user: UserProfile?,
        archetype: Archetype?,
        streak: Int,
        todayRevealed: Bool,
        ritualCompletedToday: Bool
    ) {
        guard let user else {
            presentation = .placeholder
            return
        }

        let identityContent = ZodiacIdentityContentService.shared.content(forArchetypeId: user.archetypeId)
            ?? archetype.map {
                ZodiacIdentityContent.fromArchetype(
                    $0,
                    western: user.westernSign,
                    chinese: user.chineseSign
                )
            }

        presentation = HomePatternSurfacePresentation.make(
            user: user,
            archetype: archetype,
            identityContent: identityContent,
            streak: streak,
            todayRevealed: todayRevealed,
            ritualCompletedToday: ritualCompletedToday
        )
    }
}

struct HomePatternSurfacePresentation: Equatable {
    let greeting: String
    let signLine: String
    let identityTitle: String
    let identityTagline: String
    let patternToday: PatternTodayContent
    let continuity: PatternContinuityContent
    let ritualAction: PatternActionContent
    let connectAction: PatternActionContent

    static let placeholder = HomePatternSurfacePresentation(
        greeting: "Your pattern",
        signLine: "Still loading",
        identityTitle: "The Hidden Pattern",
        identityTagline: "Still coming into focus",
        patternToday: PatternTodayContent(
            headline: "You notice it before you name it",
            body: "Start with what already stands out. The rest usually follows."
        ),
        continuity: PatternContinuityContent(
            badge: "NEW",
            title: "Nothing to track yet",
            body: "Reveal your identity to start seeing what keeps repeating"
        ),
        ritualAction: PatternActionContent(
            eyebrow: "Today",
            title: "Get your read",
            subtitle: "Open the ritual and see what today is really pushing on"
        ),
        connectAction: PatternActionContent(
            eyebrow: "Connect",
            title: "See who fits today",
            subtitle: "People are sorted by rhythm, friction, and timing — not just attraction"
        )
    )

    static func make(
        user: UserProfile,
        archetype: Archetype?,
        identityContent: ZodiacIdentityContent?,
        streak: Int,
        todayRevealed: Bool,
        ritualCompletedToday: Bool
    ) -> HomePatternSurfacePresentation {
        let identityTitle = identityContent?.title ?? archetype?.title ?? "The Hidden Pattern"
        let identityTagline = identityContent?.tagline ?? archetype?.tagline ?? "Still coming into focus"
        let source = PatternTodaySource(
            archetypeID: user.archetypeId,
            title: identityTitle,
            tagline: identityTagline,
            overview: identityContent?.identitySummary ?? archetype?.overview ?? "",
            howYouMove: archetype?.howYouMove ?? identityContent?.coreEnergy ?? "",
            emotionalPattern: identityContent?.emotionalPattern ?? archetype?.emotionalPattern ?? "",
            growthEdge: identityContent?.mantra ?? archetype?.growthPath ?? "",
            relationshipStyle: identityContent?.loveStyle ?? archetype?.loveStyle ?? "",
            strengths: identityContent?.strengths ?? archetype?.strengths ?? [],
            shadows: identityContent?.growthEdges ?? archetype?.shadows ?? []
        )

        return HomePatternSurfacePresentation(
            greeting: greeting(for: user.name),
            signLine: "\(user.westernSign.displayName) × \(user.chineseSign.displayName)",
            identityTitle: identityTitle,
            identityTagline: identityTagline,
            patternToday: patternToday(from: source),
            continuity: continuity(
                from: source,
                streak: streak,
                todayRevealed: todayRevealed,
                ritualCompletedToday: ritualCompletedToday
            ),
            ritualAction: ritualAction(todayRevealed: todayRevealed, ritualCompletedToday: ritualCompletedToday),
            connectAction: connectAction(from: source, streak: streak)
        )
    }

    private static func greeting(for name: String) -> String {
        name.count > 12 ? "Your pattern" : "\(name)'s pattern"
    }

    private static func patternToday(from source: PatternTodaySource) -> PatternTodayContent {
        if let seeded = PatternTodaySeed.examples[source.archetypeID] {
            return seeded.patternToday
        }

        let headline = behaviorLine(from: [
            source.howYouMove,
            source.emotionalPattern,
            source.overview
        ]) ?? "You catch the shift before anyone says it"
        let body = growthLine(
            from: source.growthEdge,
            fallbackShadow: source.shadows.first,
            fallbackStrength: source.strengths.first
        ) ?? "Call the move a little earlier. That usually changes the whole day."

        return PatternTodayContent(
            headline: trimmedSentence(headline),
            body: trimmedSentence(body)
        )
    }

    private static func continuity(
        from source: PatternTodaySource,
        streak: Int,
        todayRevealed: Bool,
        ritualCompletedToday: Bool
    ) -> PatternContinuityContent {
        if let seeded = PatternTodaySeed.examples[source.archetypeID] {
            return seeded.continuity(streak: streak, todayRevealed: todayRevealed, ritualCompletedToday: ritualCompletedToday)
        }

        let badge = streak == 1 ? "1 day" : "\(streak) days"
        let title: String

        if ritualCompletedToday {
            title = "You stayed with it today"
        } else if todayRevealed {
            title = "The line is already moving"
        } else if streak >= 3 {
            title = "This keeps showing up"
        } else {
            title = "The pattern is starting to show"
        }

        let bodyBase = continuityLine(
            relationshipStyle: source.relationshipStyle,
            shadow: source.shadows.first,
            strength: source.strengths.first
        ) ?? "The same move keeps repeating until you finally catch yourself doing it"

        return PatternContinuityContent(
            badge: badge,
            title: title,
            body: trimmedSentence(bodyBase)
        )
    }

    private static func ritualAction(
        todayRevealed: Bool,
        ritualCompletedToday: Bool
    ) -> PatternActionContent {
        if ritualCompletedToday {
            return PatternActionContent(
                eyebrow: "Settled",
                title: "Revisit what landed",
                subtitle: "Go back to the ritual and catch the part that is still bothering you"
            )
        }

        if todayRevealed {
            return PatternActionContent(
                eyebrow: "Open",
                title: "Keep following it",
                subtitle: "Today’s Lens is already open. Go back to the line you cannot quite shake."
            )
        }

        return PatternActionContent(
            eyebrow: "Today",
            title: "Get your read",
            subtitle: "Open the ritual and see what today is really asking of you"
        )
    }

    private static func connectAction(
        from source: PatternTodaySource,
        streak: Int
    ) -> PatternActionContent {
        if let seeded = PatternTodaySeed.examples[source.archetypeID] {
            return seeded.connectAction(streak: streak)
        }

        let subtitleBase = connectLine(
            relationshipStyle: source.relationshipStyle,
            shadow: source.shadows.first,
            strength: source.strengths.first
        ) ?? "Take this version of yourself into Connect and see who can actually meet it"

        return PatternActionContent(
            eyebrow: streak >= 5 ? "In motion" : "After that",
            title: "See who fits today",
            subtitle: trimmedSentence(subtitleBase)
        )
    }

    private static func behaviorLine(from texts: [String]) -> String? {
        for text in texts {
            guard let clause = compactClause(from: text) else { continue }
            if let reframed = reframeBehaviorClause(clause) {
                return reframed
            }
        }

        return nil
    }

    private static func growthLine(
        from growthText: String,
        fallbackShadow: String?,
        fallbackStrength: String?
    ) -> String? {
        if let clause = compactClause(from: growthText),
           let reframed = reframeGrowthClause(clause) {
            return reframed
        }

        if let shadow = fallbackShadow?.lowercased(), !shadow.isEmpty {
            return "When \(shadow), slow down long enough to catch yourself in it"
        }

        if let strength = fallbackStrength?.lowercased(), !strength.isEmpty {
            return "Use your \(strength) on purpose instead of letting the day choose for you"
        }

        return nil
    }

    private static func continuityLine(
        relationshipStyle: String,
        shadow: String?,
        strength: String?
    ) -> String? {
        if let clause = compactClause(from: relationshipStyle),
           let reframed = reframeContinuityClause(clause) {
            return reframed
        }

        if let shadow = shadow?.lowercased(), !shadow.isEmpty {
            return "You keep coming back to the same spot: \(shadow)"
        }

        if let strength = strength?.lowercased(), !strength.isEmpty {
            return "The repeat is clear now: you keep leaning on \(strength) when things get real"
        }

        return nil
    }

    private static func connectLine(
        relationshipStyle: String,
        shadow: String?,
        strength: String?
    ) -> String? {
        if let clause = compactClause(from: relationshipStyle),
           let reframed = reframeConnectClause(clause) {
            return reframed
        }

        if let strength = strength?.lowercased(), !strength.isEmpty {
            return "Go into Connect with your \(strength), then notice who can actually handle it"
        }

        if let shadow = shadow?.lowercased(), !shadow.isEmpty {
            return "Take this side of yourself into Connect and watch who does not flinch when \(shadow)"
        }

        return nil
    }

    private static func compactClause(from text: String) -> String? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        let sentence = cleaned.split(whereSeparator: { ".!?".contains($0) }).first.map(String.init) ?? cleaned
        let compact = sentence
            .replacingOccurrences(of: "Together, this identity is", with: "")
            .replacingOccurrences(of: "Under stress,", with: "")
            .replacingOccurrences(of: "Your growth is", with: "")
            .replacingOccurrences(of: "This identity", with: "You")
            .replacingOccurrences(of: "identity", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return compact.isEmpty ? nil : compact
    }

    private static func reframeBehaviorClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.contains("notice") || lowered.contains("reads") || lowered.contains("subtext") {
            return "You notice the shift before anyone says it"
        }

        if lowered.contains("move") || lowered.contains("fast") || lowered.contains("quick") {
            return "You move fast when something clicks"
        }

        if lowered.contains("soft") || lowered.contains("gentle") || lowered.contains("tender") {
            return "You come in soft, then get harder to reach"
        }

        if lowered.contains("guard") || lowered.contains("hold") || lowered.contains("withhold") {
            return "You keep more to yourself than people think"
        }

        if lowered.contains("control") || lowered.contains("order") || lowered.contains("precise") {
            return "You tighten up the second things get messy"
        }

        return "You keep doing more than you let on"
    }

    private static func reframeGrowthClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.contains("honest") || lowered.contains("truth") {
            return "Say the blunt version sooner"
        }

        if lowered.contains("slow") || lowered.contains("still") {
            return "Slow down before you outrun the point"
        }

        if lowered.contains("boundary") || lowered.contains("door") {
            return "Leave one door closed today"
        }

        if lowered.contains("trust") {
            return "Trust your read without trying to prove it"
        }

        if lowered.contains("soft") {
            return "Stay soft without giving everything away"
        }

        return nil
    }

    private static func reframeContinuityClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.contains("space") {
            return "You keep needing room right when things start getting close"
        }

        if lowered.contains("honesty") || lowered.contains("truth") {
            return "You keep circling back to whether people are being real with you"
        }

        if lowered.contains("care") || lowered.contains("protect") {
            return "You keep taking care of the room before you deal with yourself"
        }

        if lowered.contains("direct") {
            return "You keep wanting the straight answer, even when no one wants to give it"
        }

        return nil
    }

    private static func reframeConnectClause(_ clause: String) -> String? {
        let lowered = clause.lowercased()

        if lowered.contains("space") {
            return "Look for someone who can stay close without crowding you"
        }

        if lowered.contains("honesty") || lowered.contains("truth") {
            return "Look for someone who says the real thing without making you drag it out"
        }

        if lowered.contains("care") || lowered.contains("soft") {
            return "Look for someone who can handle warmth without taking too much from it"
        }

        if lowered.contains("direct") {
            return "Look for someone who can meet you without playing games first"
        }

        return nil
    }

    private static func trimmedSentence(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed.hasSuffix("") ? trimmed : trimmed + ""
    }
}

struct PatternTodayContent: Equatable {
    let headline: String
    let body: String
}

struct PatternContinuityContent: Equatable {
    let badge: String
    let title: String
    let body: String
}

struct PatternActionContent: Equatable {
    let eyebrow: String
    let title: String
    let subtitle: String
}

private struct PatternTodaySource {
    let archetypeID: String
    let title: String
    let tagline: String
    let overview: String
    let howYouMove: String
    let emotionalPattern: String
    let growthEdge: String
    let relationshipStyle: String
    let strengths: [String]
    let shadows: [String]
}

private struct PatternTodaySeed {
    let patternToday: PatternTodayContent
    let continuityLine: String
    let connectLine: String

    func continuity(streak: Int, todayRevealed: Bool, ritualCompletedToday: Bool) -> PatternContinuityContent {
        let badge = streak == 1 ? "1 day" : "\(streak) days"
        let title: String

        if ritualCompletedToday {
            title = "You stayed with it today"
        } else if todayRevealed {
            title = "The pattern is already moving"
        } else if streak >= 3 {
            title = "You have been repeating this"
        } else {
            title = "You are starting to catch it"
        }

        return PatternContinuityContent(
            badge: badge,
            title: title,
            body: continuityLine
        )
    }

    func connectAction(streak: Int) -> PatternActionContent {
        PatternActionContent(
            eyebrow: streak >= 5 ? "Carry it out" : "Take it outward",
            title: "See who matches this energy",
            subtitle: connectLine
        )
    }

    static let examples: [String: PatternTodaySeed] = [
        "aries-horse": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You move fast when feeling too much gets close",
                body: "Before you bolt, say what started tightening in you"
            ),
            continuityLine: "The repeat is clear: you push for space, then go looking for the thing you almost left",
            connectLine: "Bring this heat into Connect and look for someone who does not chase or cage it"
        ),
        "libra-snake": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You stay composed while reading more than anyone knows",
                body: "Today works better if you stop smoothing the room and name the sharper truth"
            ),
            continuityLine: "This has been repeating: you keep the tone beautiful while the real judgment stays hidden underneath",
            connectLine: "Take this discernment into Connect and notice who feels clean without needing a performance"
        ),
        "pisces-pig": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You open first, then realize how much you already gave away",
                body: "Let warmth stay warm today without turning it into instant access"
            ),
            continuityLine: "The thread across these days is simple: your heart arrives early, and your boundary arrives late",
            connectLine: "Use this softness in Connect and watch for people who feel easy without taking too much"
        ),
        "capricorn-horse": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You look steady, then disappear the second something feels too boxed in",
                body: "Do the responsible thing without turning it into another way to dodge what you want"
            ),
            continuityLine: "This keeps repeating: you carry a lot, then act like needing room came out of nowhere",
            connectLine: "Take that edge into Connect and look for someone who respects space without acting casual about you"
        ),
        "aries-rabbit": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You come in strong, then pull back the second the room gets too loud",
                body: "Today works better if you stop acting certain and admit what rubbed you wrong"
            ),
            continuityLine: "The repeat is obvious: you go first, then hide the bruise when the moment hits back",
            connectLine: "Bring that mix into Connect and notice who can handle both your spark and your nerves"
        ),
        "leo-dragon": PatternTodaySeed(
            patternToday: PatternTodayContent(
                headline: "You carry the room, even when you act like you are barely trying",
                body: "Let the pressure drop today. You do not need to be the biggest thing in every moment."
            ),
            continuityLine: "You keep ending up in the same role: the one everyone reads first and questions last",
            connectLine: "Take that presence into Connect and look for someone who is impressed, but not intimidated"
        )
    ]
}
