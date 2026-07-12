import Foundation

enum DailyReadingGenerator {
    struct Context {
        let archetype: Archetype
        let user: UserProfile?
        let streak: Int?
        let date: Date
        let previousIdentities: [String]
        let recentThemes: [String]
        let recentTones: [String]
        let lastReflectionTag: String?
        let skyContext: DailySkyContext?

        init(
            archetype: Archetype,
            user: UserProfile?,
            streak: Int?,
            date: Date = Date(),
            previousIdentities: [String] = [],
            recentThemes: [String] = [],
            recentTones: [String] = [],
            lastReflectionTag: String? = nil,
            skyContext: DailySkyContext? = nil
        ) {
            self.archetype = archetype
            self.user = user
            self.streak = streak
            self.date = date
            self.previousIdentities = previousIdentities
            self.recentThemes = recentThemes
            self.recentTones = recentTones
            self.lastReflectionTag = lastReflectionTag
            self.skyContext = skyContext
        }
    }

    struct PromptPackage {
        let system: String
        let user: String
    }

    private struct Payload: Codable {
        let identity: String
        let insight: String
        let focus: String
        let caution: String
        let affirmation: String
        let energy: String?
        let energyKey: String
    }

    static func generate(context: Context) -> DailyReading {
        if let payload = validatedPayload(from: makeStructuredPayload(context: context)) {
            return buildReading(from: payload, context: context)
        }

        return fallbackReading(context: context)
    }

    static func promptPackage(for context: Context) -> PromptPackage {
        let westernName = context.user?.westernSign.displayName ?? westernSign(from: context.archetype).displayName
        let chineseName = context.user?.chineseSign.displayName ?? chineseSign(from: context.archetype).displayName
        let streak = context.streak ?? 0
        let dayPart = timeOfDay(for: context.date)
        let recentIdentities = context.previousIdentities.suffix(5).joined(separator: ", ")
        let recentThemes = context.recentThemes.suffix(4).joined(separator: ", ")
        let recentTones = context.recentTones.suffix(4).joined(separator: ", ")
        let skyContext = context.skyContext
        let userName = context.user?.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let birthdayContext = userName?.isEmpty == false ? "User first name: \(userName!)" : "User first name unavailable"

        let system = """
        You are Zodian. Write for a younger astrology audience.

        Voice rules:
        - clear on the first read
        - calm, modern, and emotionally sharp
        - slightly mystical, never dramatic
        - short, direct, and easy to feel
        - premium without sounding formal
        - treat this as Zodian's Today’s Lens: an AI-generated read built from both Western and Eastern signs
        - keep the merged-sign idea visible without overexplaining it
        - each result should feel specific to the user's identity, not generic astrology copy

        Avoid:
        - vague horoscope language
        - filler
        - therapy-style wording
        - abstract phrasing
        - repeated ideas in new words
        - long reflective sentences
        - anything that reads like an essay

        Return strict JSON with exactly these keys:
        identity, insight, focus, caution, affirmation, energy, energyKey

        Field rules:
        - identity: 2 to 4 words, memorable, easy to get
        - insight: max 2 short sentences, prefer 1
        - focus: max 2 short sentences, prefer 1
        - caution: max 2 short sentences, prefer 1
        - affirmation: max 2 short sentences, prefer 1
        - energy: optional short label for the day
        - energyKey: one of clarity, magnetism, restraint, devotion, momentum, softness

        Writing rules:
        - 5 to 12 words per sentence when possible
        - one idea per sentence
        - no filler setup
        - land fast

        Continuity rules:
        - avoid recent identity repetition
        - avoid repeating the same theme on back-to-back days
        - vary tone if recent days felt too similar
        - let streak subtly influence confidence
        - if reflection context exists, use it lightly
        """

        let user = """
        Build Today’s Lens for this user context.
        This is Zodian's Today’s Lens, and it should feel more specific than generic horoscope copy because it merges the user's Western and Eastern signs each day.
        Aim for a reading that feels accurate to the current identity, not just the sign pair.

        Archetype title: \(context.archetype.title)
        Archetype combined name: \(context.archetype.combinedName)
        Western sign: \(westernName)
        Chinese sign: \(chineseName)
        Emotional pattern: \(context.archetype.emotionalPattern)
        Love style: \(context.archetype.loveStyle)
        Work style: \(context.archetype.workStyle)
        Growth path: \(context.archetype.growthPath)
        Hidden insight: \(context.archetype.hiddenInsight ?? "Unavailable")
        Strengths: \(context.archetype.strengths.joined(separator: ", "))
        Shadows: \(context.archetype.shadows.joined(separator: ", "))
        Time of day: \(dayPart.promptLabel)
        Current streak: \(streak)
        Recently used identities: \(recentIdentities.isEmpty ? "None" : recentIdentities)
        Recent themes: \(recentThemes.isEmpty ? "None" : recentThemes)
        Recent tones: \(recentTones.isEmpty ? "None" : recentTones)
        Last reflection tag: \(context.lastReflectionTag ?? "None")
        Sun sign today: \(skyContext?.sunSign.displayName ?? "Unknown")
        Moon sign today: \(skyContext?.moonSign.displayName ?? "Unknown")
        Moon phase today: \(skyContext?.moonPhase ?? "Unknown")
        Sky theme today: \(skyContext?.majorTheme ?? "Unknown")
        Sky tone today: \(skyContext?.tone ?? "Unknown")
        \(birthdayContext)

        Write this for one real person today. Keep it short, clear, and easy to scan.
        """

        return PromptPackage(system: system, user: user)
    }

    private static func makeStructuredPayload(context: Context) -> Payload? {
        let mood = moodForToday(archetypeId: context.archetype.id, date: context.date, recentTones: context.recentTones)
        let promptPackage = promptPackage(for: context)
        let identity = chooseIdentity(context: context, mood: mood)
        let dayPart = timeOfDay(for: context.date)
        let themeKey = chooseThemeKey(context: context, mood: mood)
        let blueprint = readingBlueprint(context: context, mood: mood, dayPart: dayPart, themeKey: themeKey)

        let payload = Payload(
            identity: identity,
            insight: insightLine(context: context, blueprint: blueprint),
            focus: focusLine(context: context, blueprint: blueprint),
            caution: cautionLine(context: context, blueprint: blueprint),
            affirmation: affirmationLine(context: context, blueprint: blueprint),
            energy: energyLine(for: mood, dayPart: dayPart, voice: promptPackage.system),
            energyKey: mood.rawValue
        )

        guard let data = try? JSONEncoder().encode(payload),
              let decoded = try? JSONDecoder().decode(Payload.self, from: data) else {
            return nil
        }

        return decoded
    }

    private static func validatedPayload(from payload: Payload?) -> Payload? {
        guard let payload else { return nil }

        let fields = [
            payload.identity,
            payload.insight,
            payload.focus,
            payload.caution,
            payload.affirmation
        ]

        let allValid = fields.allSatisfy {
            let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
                && trimmed.count >= 5
                && trimmed.count <= 180
                && sentenceCount(in: trimmed) <= 2
        }

        guard allValid, DailyMood(rawValue: payload.energyKey) != nil else {
            return nil
        }

        return payload
    }

    private static func buildReading(from payload: Payload, context: Context) -> DailyReading {
        let western = context.user?.westernSign ?? westernSign(from: context.archetype)
        let chinese = context.user?.chineseSign ?? chineseSign(from: context.archetype)

        return DailyReading(
            date: context.date,
            identity: payload.identity,
            insight: payload.insight,
            focus: payload.focus,
            caution: payload.caution,
            affirmation: payload.affirmation,
            energy: payload.energy,
            energyKey: payload.energyKey,
            themeKey: chooseThemeKey(context: context, mood: DailyMood(rawValue: payload.energyKey) ?? .clarity),
            toneKey: toneKey(for: context, mood: DailyMood(rawValue: payload.energyKey) ?? .clarity),
            reflectionTag: context.lastReflectionTag,
            moonPhase: context.skyContext?.moonPhase,
            moonSign: context.skyContext?.moonSign,
            sunSign: context.skyContext?.sunSign,
            skyTheme: context.skyContext?.majorTheme,
            skyTone: context.skyContext?.tone,
            westernSign: western,
            chineseSign: chinese,
            streakContext: context.streak
        )
    }

    private static func fallbackReading(context: Context) -> DailyReading {
        let mood = moodForToday(archetypeId: context.archetype.id, date: context.date, recentTones: context.recentTones)
        let themeKey = chooseThemeKey(context: context, mood: mood)
        let blueprint = readingBlueprint(context: context, mood: mood, dayPart: timeOfDay(for: context.date), themeKey: themeKey)
        let fallback = Payload(
            identity: fallbackIdentity(context: context),
            insight: fallbackInsight(context: context, blueprint: blueprint),
            focus: fallbackFocus(context: context, blueprint: blueprint),
            caution: fallbackCaution(context: context, blueprint: blueprint),
            affirmation: fallbackAffirmation(context: context, blueprint: blueprint),
            energy: energyLine(for: mood, dayPart: timeOfDay(for: context.date), voice: promptPackage(for: context).system),
            energyKey: mood.rawValue
        )
        return buildReading(from: fallback, context: context)
    }

    private static func moodForToday(archetypeId: String, date: Date, recentTones: [String]) -> DailyMood {
        let moods = DailyMood.allCases
        let daySeed = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        let combined = abs(archetypeId.hashValue ^ daySeed)
        let base = moods[combined % moods.count]
        let recent = recentTones.prefix(2).map { $0.lowercased() }

        guard recent.filter({ $0 == base.rawValue }).count >= 2 else {
            return base
        }

        return moods.first(where: { !recent.contains($0.rawValue) }) ?? base
    }

    private static func chooseIdentity(context: Context, mood: DailyMood) -> String {
        let candidates = identityPool(for: context, mood: mood)
        let trimmedHistory = Set(context.previousIdentities.suffix(5).map { $0.lowercased() })
        let filtered = candidates.filter { !trimmedHistory.contains($0.lowercased()) }
        let pool = filtered.isEmpty ? candidates : filtered
        let seed = dailySeed(for: context)
        return pool[seed % pool.count]
    }

    private static func identityPool(for context: Context, mood: DailyMood) -> [String] {
        let title = context.archetype.title
        let descriptorPairs = identityDescriptorPairs(for: mood)
        let seededTitle = title.hasPrefix("The ") ? title : "The \(title)"
        let generated = descriptorPairs.map { "The \($0.0) \($0.1)" }

        return Array(NSOrderedSet(array: generated + [seededTitle])) as? [String] ?? generated + [seededTitle]
    }

    private static func identityDescriptorPairs(for mood: DailyMood) -> [(String, String)] {
        switch mood {
        case .clarity:
            return [("Quiet", "Signal"), ("Hidden", "Pattern"), ("Clear", "Thread"), ("Unseen", "Edge")]
        case .magnetism:
            return [("Quiet", "Current"), ("Returning", "Signal"), ("Hidden", "Pulse"), ("Shifting", "Thread")]
        case .restraint:
            return [("Held", "Line"), ("Quiet", "Edge"), ("Hidden", "Current"), ("Unseen", "Signal")]
        case .devotion:
            return [("Returning", "Thread"), ("Steady", "Current"), ("Quiet", "Pattern"), ("Hidden", "Pulse")]
        case .momentum:
            return [("Shifting", "Current"), ("Returning", "Edge"), ("Quiet", "Pulse"), ("Hidden", "Motion")]
        case .softness:
            return [("Quiet", "Thread"), ("Hidden", "Signal"), ("Unseen", "Current"), ("Soft", "Edge")]
        }
    }

    private static func chooseThemeKey(context: Context, mood: DailyMood) -> String {
        let seed = dailySeed(for: context)
        let options: [String]

        switch mood {
        case .clarity:
            options = ["clarity", "decision", "signal"]
        case .magnetism:
            options = ["connection", "pull", "chemistry"]
        case .restraint:
            options = ["boundary", "pause", "discipline"]
        case .devotion:
            options = ["care", "consistency", "trust"]
        case .momentum:
            options = ["movement", "action", "progress"]
        case .softness:
            options = ["softness", "rest", "self-trust"]
        }

        let skyOptions = skyThemeOptions(from: context.skyContext)
        let recent = Set(context.recentThemes.prefix(2).map { $0.lowercased() })
        let merged = Array(NSOrderedSet(array: skyOptions + options)) as? [String] ?? (skyOptions + options)
        let filtered = merged.filter { !recent.contains($0) }
        let pool = filtered.isEmpty ? merged : filtered
        return pool[seed % pool.count]
    }

    private static func toneKey(for context: Context, mood: DailyMood) -> String {
        let streak = context.streak ?? 0
        let skyTone = context.skyContext?.tone ?? "neutral"

        switch streak {
        case 0...2:
            return "welcoming-\(skyTone)-\(mood.rawValue)"
        case 3...6:
            return "building-\(skyTone)-\(mood.rawValue)"
        default:
            return "grounded-\(skyTone)-\(mood.rawValue)"
        }
    }

    private static func readingBlueprint(context: Context, mood: DailyMood, dayPart: DayPart, themeKey: String) -> ReadingBlueprint {
        let seed = dailySeed(for: context)
        let streakVoice = streakVoice(for: context.streak ?? 0)
        let userName = preferredFirstName(from: context.user)
        let signSignature = "\(context.user?.westernSign.displayName ?? westernSign(from: context.archetype).displayName) × \(context.user?.chineseSign.displayName ?? chineseSign(from: context.archetype).displayName)"
        let emotionalLens = shortClause(from: context.archetype.emotionalPattern)
        let hiddenInsight = shortClause(from: context.archetype.hiddenInsight ?? context.archetype.growthPath)
        let strongestTrait = context.archetype.strengths[seed % max(context.archetype.strengths.count, 1)]
        let shadow = context.archetype.shadows[seed % max(context.archetype.shadows.count, 1)]
        let reflectionBias = reflectionBias(for: context.lastReflectionTag)
        let skyLead = skyLead(for: context.skyContext, seed: seed)
        let skyFocusCue = skyFocusCue(for: context.skyContext, themeKey: themeKey, seed: seed)
        let skyCautionCue = skyCautionCue(for: context.skyContext, shadow: shadow, seed: seed)
        let dayIntro = [
            "\(dayPart.opening), your pace matters",
            "\(dayPart.opening), keep it steady",
            "\(dayPart.opening), the small choices matter most"
        ][seed % 3]
        let personalizationLead = userName.map { "\($0), " } ?? ""
        let continuityCue = continuityCue(for: context, themeKey: themeKey, seed: seed)

        return ReadingBlueprint(
            mood: mood,
            dayPart: dayPart,
            signSignature: signSignature,
            dayIntro: dayIntro,
            personalizationLead: personalizationLead,
            skyLead: skyLead,
            emotionalLens: emotionalLens,
            hiddenInsight: hiddenInsight,
            strongestTrait: strongestTrait,
            shadow: shadow,
            streakVoice: streakVoice,
            emphasis: emphasisPhrase(for: mood, seed: seed),
            focusAction: focusAction(for: mood, seed: seed, reflectionBias: reflectionBias),
            skyFocusCue: skyFocusCue,
            cautionRisk: cautionRisk(for: mood, shadow: shadow, seed: seed),
            skyCautionCue: skyCautionCue,
            affirmationStem: affirmationStem(for: mood, streakVoice: streakVoice),
            continuityCue: continuityCue,
            themeKey: themeKey
        )
    }

    private static func insightLine(context: Context, blueprint: ReadingBlueprint) -> String {
        let seed = dailySeed(for: context)
        let patterns = [
            "\(blueprint.skyLead)",
            "\(blueprint.emphasis) \(blueprint.continuityCue)",
            "\(blueprint.skyLead) \(blueprint.continuityCue)"
        ]

        return clipped(cleanedSentenceBlock(patterns[seed % patterns.count]))
    }

    private static func focusLine(context: Context, blueprint: ReadingBlueprint) -> String {
        let seed = dailySeed(for: context)
        let options = [
            "\(blueprint.focusAction) \(blueprint.skyFocusCue)",
            "\(blueprint.focusAction)",
            "\(blueprint.skyFocusCue)"
        ]

        return clipped(cleanedSentenceBlock(options[seed % options.count]))
    }

    private static func cautionLine(context: Context, blueprint: ReadingBlueprint) -> String {
        let seed = dailySeed(for: context)
        let risk = cautionRiskPhrase(blueprint.cautionRisk)
        let shadow = cautionRiskPhrase(blueprint.shadow)
        let options = [
            "Watch for \(risk). \(blueprint.skyCautionCue)",
            "Notice when \(shadow) starts to feel automatic",
            "Be careful with \(risk). \(blueprint.skyCautionCue)"
        ]

        return clipped(cleanedSentenceBlock(options[seed % options.count]))
    }

    private static func affirmationLine(context: Context, blueprint: ReadingBlueprint) -> String {
        let seed = dailySeed(for: context)
        let endings = [
            "I trust what feels steady",
            "I act in a way that feels honest",
            "I let calm lead",
            "I choose what feels right and real"
        ]

        return clipped(cleanedSentenceBlock("\(blueprint.affirmationStem). \(endings[seed % endings.count])."))
    }

    private static func energyLine(for mood: DailyMood, dayPart: DayPart, voice: String) -> String {
        let premiumBias = voice.contains("premium astrology intelligence")

        switch mood {
        case .clarity:
            return dayPart == .evening ? "Quiet Clarity" : (premiumBias ? "Clear Signal" : "Clarity")
        case .magnetism:
            return dayPart == .morning ? "Soft Magnetism" : "Velvet Pull"
        case .restraint:
            return premiumBias ? "Held Power" : "Sacred Restraint"
        case .devotion:
            return "Steady Heart"
        case .momentum:
            return dayPart == .morning ? "Rising Fire" : "Directed Momentum"
        case .softness:
            return "Gentle Power"
        }
    }

    private static func fallbackInsight(context: Context, blueprint: ReadingBlueprint) -> String {
        clipped(cleanedSentenceBlock("\(blueprint.skyLead) \(blueprint.continuityCue)"))
    }

    private static func fallbackFocus(context: Context, blueprint: ReadingBlueprint) -> String {
        clipped(cleanedSentenceBlock("\(blueprint.focusAction) \(blueprint.skyFocusCue)"))
    }

    private static func fallbackCaution(context: Context, blueprint: ReadingBlueprint) -> String {
        let risk = cautionRiskPhrase(blueprint.cautionRisk)
        return clipped(cleanedSentenceBlock("Watch for \(risk). \(blueprint.skyCautionCue)"))
    }

    private static func fallbackAffirmation(context: Context, blueprint: ReadingBlueprint) -> String {
        clipped(cleanedSentenceBlock("\(blueprint.affirmationStem). I can choose the next honest step."))
    }

    private static func fallbackIdentity(context: Context) -> String {
        let candidates = [
            context.archetype.title,
            "The Hidden Pattern",
            "The Returning Thread",
            "The Quiet Signal"
        ]

        let seed = dailySeed(for: context)
        return candidates[seed % candidates.count]
    }

    private static func westernSign(from archetype: Archetype) -> WesternZodiac {
        let parts = archetype.id.split(separator: "-")
        return WesternZodiac.from(rawValue: parts.first.map(String.init)) ?? .aries
    }

    private static func chineseSign(from archetype: Archetype) -> ChineseZodiac {
        let parts = archetype.id.split(separator: "-")
        guard parts.count > 1 else { return .rat }
        return ChineseZodiac.from(rawValue: String(parts[1])) ?? .rat
    }

    private static func streakVoice(for streak: Int) -> StreakVoice {
        switch streak {
        case 0:
            return .gentle
        case 1...3:
            return .settled
        case 4...7:
            return .assured
        case 8...13:
            return .confident
        default:
            return .commanding
        }
    }

    private static func timeOfDay(for date: Date) -> DayPart {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }

    private static func preferredFirstName(from user: UserProfile?) -> String? {
        guard let raw = user?.name.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }

        return raw.components(separatedBy: .whitespacesAndNewlines).first
    }

    private static func emphasisPhrase(for mood: DailyMood, seed: Int) -> String {
        let phrases: [String]

        switch mood {
        case .clarity:
            phrases = ["Pick the real priority", "Trust what feels clear"]
        case .magnetism:
            phrases = ["Put your attention where it feels mutual", "Stay where the effort comes back"]
        case .restraint:
            phrases = ["Keeping it smaller will help", "Protect your pace today"]
        case .devotion:
            phrases = ["Go back to what has earned your effort", "Care gets stronger with structure"]
        case .momentum:
            phrases = ["A clean start matters more than polish", "Take the first clean step now"]
        case .softness:
            phrases = ["A softer pace will help you think clearly", "Calm will show you more"]
        }

        return phrases[seed % phrases.count]
    }

    private static func skyThemeOptions(from skyContext: DailySkyContext?) -> [String] {
        guard let skyContext else { return [] }

        var options: [String] = []
        options.append(contentsOf: skyContext.majorTheme.split(separator: "-").map { String($0).lowercased() })

        switch skyContext.moonPhase.lowercased() {
        case let phase where phase.contains("new"):
            options.append("reset")
        case let phase where phase.contains("full"):
            options.append("release")
        case let phase where phase.contains("waxing"):
            options.append("build")
        case let phase where phase.contains("waning"):
            options.append("release")
        default:
            break
        }

        return Array(NSOrderedSet(array: options)) as? [String] ?? options
    }

    private static func skyLead(for skyContext: DailySkyContext?, seed: Int) -> String {
        guard let skyContext else {
            let fallbacks = [
                "You are seeing the day more clearly",
                "The tone feels more obvious today",
                "There is a cleaner read on things today"
            ]
            return fallbacks[seed % fallbacks.count]
        }

        let sign = skyContext.moonSign.displayName

        switch skyContext.moonPhase {
        case "New Moon":
            return [
                "The \(sign) moon is asking for a reset",
                "The \(sign) moon is pulling you toward a clean start"
            ][seed % 2]
        case "Waxing Crescent", "Waxing Gibbous":
            return [
                "The \(sign) moon is building momentum",
                "The \(sign) moon is helping small moves stick"
            ][seed % 2]
        case "First Quarter":
            return [
                "The \(sign) moon is pushing for a clear move",
                "The \(sign) moon is asking for action, not circling"
            ][seed % 2]
        case "Full Moon":
            return [
                "The \(sign) moon is turning the volume up",
                "The \(sign) moon is making feelings harder to miss"
            ][seed % 2]
        case "Waning Gibbous", "Last Quarter", "Waning Crescent":
            return [
                "The \(sign) moon is helping you let go of extra noise",
                "The \(sign) moon is making space for a cleaner next step"
            ][seed % 2]
        default:
            return "The \(sign) moon is shifting the tone today"
        }
    }

    private static func skyFocusCue(for skyContext: DailySkyContext?, themeKey: String, seed: Int) -> String {
        guard let skyContext else {
            return [
                "Keep it simple",
                "Do not make it heavier than it is"
            ][seed % 2]
        }

        switch skyContext.tone {
        case "bold":
            return [
                "Trust the direct move",
                "Say the clear thing"
            ][seed % 2]
        case "steady":
            return [
                "Stick with what can hold up",
                "Choose the move you can keep"
            ][seed % 2]
        case "social":
            return themeKey == "connection"
                ? "Notice who meets you halfway"
                : "Talk it through before you overthink it"
        case "deep":
            return [
                "Be honest about what you actually feel",
                "Let the real feeling set the pace"
            ][seed % 2]
        default:
            return "Keep the next step clear"
        }
    }

    private static func skyCautionCue(for skyContext: DailySkyContext?, shadow: String, seed: Int) -> String {
        guard let skyContext else {
            return [
                "Stay close to what feels true",
                "Do not let noise decide for you"
            ][seed % 2]
        }

        switch skyContext.moonPhase {
        case "Full Moon":
            return [
                "Everything can feel louder than it is",
                "Big feelings do not always need big moves"
            ][seed % 2]
        case "New Moon":
            return [
                "You do not need a perfect plan to begin",
                "Keep the reset simple"
            ][seed % 2]
        case "Last Quarter", "Waning Crescent":
            return [
                "Do not drag old weight into what is next",
                "Let some of the pressure go"
            ][seed % 2]
        default:
            return shadow.lowercased().contains("over")
                ? "Keep your pace clean"
                : "Do not let habit run the day"
        }
    }

    private static func focusAction(for mood: DailyMood, seed: Int, reflectionBias: ReflectionBias) -> String {
        let options: [String]

        switch mood {
        case .clarity:
            options = reflectionBias == .work
                ? ["Choose the task that matters most", "Finish the decision you already know"]
                : ["Choose the honest conversation", "Finish the decision you already know"]
        case .magnetism:
            options = reflectionBias == .love
                ? ["Follow what already feels mutual", "Answer what feels mutual, not loud"]
                : ["Follow what already feels mutual", "Stay close to what feels warm"]
        case .restraint:
            options = ["Protect one boundary without apologizing", "Make the field smaller first"]
        case .devotion:
            options = reflectionBias == .love
                ? ["Go back to who deserves your care", "Build through consistency"]
                : ["Go back to what deserves your care", "Build through consistency"]
        case .momentum:
            options = reflectionBias == .work
                ? ["Start one delayed task now", "Begin before overthinking kicks in"]
                : ["Take one clean step now", "Act before overthinking turns into delay"]
        case .softness:
            options = reflectionBias == .selfFocus
                ? ["Give yourself a pace you can trust", "Choose the softer approach"]
                : ["Give yourself a pace you can trust", "Let yourself go gentler today"]
        }

        return options[seed % options.count] + "."
    }

    private static func cautionRisk(for mood: DailyMood, shadow: String, seed: Int) -> String {
        let options: [String]

        switch mood {
        case .clarity:
            options = ["turning thought into avoidance", shadow]
        case .magnetism:
            options = ["mistaking attention for alignment", shadow]
        case .restraint:
            options = ["calling shutdown discernment", shadow]
        case .devotion:
            options = ["giving more than you have", shadow]
        case .momentum:
            options = ["confusing speed with certainty", shadow]
        case .softness:
            options = ["keeping the peace by shrinking", shadow]
        }

        return options[seed % options.count]
    }

    private static func cautionRiskPhrase(_ value: String) -> String {
        let cleaned = cleanedSentenceBlock(value)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".!? "))
            .lowercased()

        let replacements: [(String, String)] = [
            ("lets ", "letting "),
            ("keeps ", "keeping "),
            ("makes ", "making "),
            ("turns ", "turning "),
            ("uses ", "using "),
            ("avoids ", "avoiding "),
            ("waits ", "waiting "),
            ("moves ", "moving "),
            ("holds ", "holding "),
            ("stays ", "staying "),
            ("acts ", "acting "),
            ("reacts ", "reacting ")
        ]

        for (prefix, replacement) in replacements where cleaned.hasPrefix(prefix) {
            return replacement + String(cleaned.dropFirst(prefix.count))
        }

        return cleaned.isEmpty ? "turning a small signal into pressure" : cleaned
    }

    private static func affirmationStem(for mood: DailyMood, streakVoice: StreakVoice) -> String {
        let base: String

        switch mood {
        case .clarity:
            base = "I can trust what feels clear"
        case .magnetism:
            base = "I can recognize what feels mutual"
        case .restraint:
            base = "I can honor timing without shrinking"
        case .devotion:
            base = "I can build with care and still stay myself"
        case .momentum:
            base = "I can take the next step without leaving myself behind"
        case .softness:
            base = "I can stay soft and still stay clear"
        }

        return "\(streakVoice.prefix); \(base)"
    }

    private static func shortClause(from raw: String) -> String {
        let normalized = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")

        let firstSentence = normalized
            .split(separator: ".")
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? normalized

        let withoutLeadIns = firstSentence
            .replacingOccurrences(of: "You ", with: "", options: [.caseInsensitive, .anchored])
            .replacingOccurrences(of: "Your ", with: "", options: [.caseInsensitive, .anchored])

        return clipped(withoutLeadIns.hasSuffix(".") ? withoutLeadIns : withoutLeadIns + ".", maxLength: 90)
    }

    private static func clipped(_ text: String, maxLength: Int = 140) -> String {
        let normalized = text
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalized.count > maxLength else { return normalized }
        let prefix = String(normalized.prefix(maxLength))
        let safe = prefix.split(separator: " ").dropLast().joined(separator: " ")
        return (safe.isEmpty ? prefix : safe).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private static func dailySeed(for context: Context) -> Int {
        let daySeed = Calendar.current.ordinality(of: .day, in: .year, for: context.date) ?? 0
        let streakSeed = context.streak ?? 0
        return abs(context.archetype.id.hashValue ^ daySeed ^ streakSeed)
    }

    private static func sentenceCount(in text: String) -> Int {
        text
            .split(whereSeparator: { ".!?".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .count
    }

    private static func continuityCue(for context: Context, themeKey: String, seed: Int) -> String {
        guard (context.streak ?? 0) >= 2 || !context.recentThemes.isEmpty else { return "" }
        guard seed % 2 == 0 else { return "" }

        let options = [
            "This builds on what is already moving",
            "Something here is still building",
            "You are picking up a thread that already started"
        ]

        let filtered = options.filter { line in
            !context.recentThemes.prefix(2).contains(where: { line.lowercased().contains($0.lowercased()) })
        }

        return (filtered.isEmpty ? options : filtered)[seed % (filtered.isEmpty ? options.count : filtered.count)]
    }

    private static func reflectionBias(for tag: String?) -> ReflectionBias {
        switch tag?.lowercased() {
        case "work": return .work
        case "love": return .love
        case "self": return .selfFocus
        default: return .none
        }
    }

    private static func cleanedSentenceBlock(_ text: String) -> String {
        text
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: "..", with: ".")
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: " . ", with: ". ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension DailyReadingGenerator {
    struct ReadingBlueprint {
        let mood: DailyMood
        let dayPart: DayPart
        let signSignature: String
        let dayIntro: String
        let personalizationLead: String
        let skyLead: String
        let emotionalLens: String
        let hiddenInsight: String
        let strongestTrait: String
        let shadow: String
        let streakVoice: StreakVoice
        let emphasis: String
        let focusAction: String
        let skyFocusCue: String
        let cautionRisk: String
        let skyCautionCue: String
        let affirmationStem: String
        let continuityCue: String
        let themeKey: String
    }

    enum ReflectionBias {
        case none
        case work
        case love
        case selfFocus
    }

    enum StreakVoice {
        case gentle
        case settled
        case assured
        case confident
        case commanding

        var prefix: String {
            switch self {
            case .gentle: return "Today is enough"
            case .settled: return "Your rhythm is starting to stick"
            case .assured: return "Your consistency is making things clearer"
            case .confident: return "You know yourself better than you did a week ago"
            case .commanding: return "Your discipline is turning into self-trust"
            }
        }
    }

    enum DayPart {
        case morning
        case afternoon
        case evening
        case night

        var phrase: String {
            switch self {
            case .morning: return "this morning"
            case .afternoon: return "this afternoon"
            case .evening: return "this evening"
            case .night: return "tonight"
            }
        }

        var opening: String {
            switch self {
            case .morning: return "Early in the day"
            case .afternoon: return "As the day unfolds"
            case .evening: return "Later in the day"
            case .night: return "Tonight"
            }
        }

        var promptLabel: String {
            switch self {
            case .morning: return "Morning"
            case .afternoon: return "Afternoon"
            case .evening: return "Evening"
            case .night: return "Night"
            }
        }

        var focusCue: String {
            switch self {
            case .morning: return "Start smaller than your nerves want"
            case .afternoon: return "Protect the middle of the day from distractions"
            case .evening: return "Let the slower pace show you what matters"
            case .night: return "Do not let tiredness make choices for you"
            }
        }
    }
}
