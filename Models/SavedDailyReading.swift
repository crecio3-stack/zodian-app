import Foundation
import SwiftData

@Model
final class SavedDailyReading {
    @Attribute(.unique) var id: UUID

    var dateKey: String
    var archetypeId: String

    /// Versioned consumer payload. These optional fields allow title/read
    /// candidates to be archived without manufacturing legacy section values.
    var contentVersionRaw: String?
    var canonicalTitle: String?
    var canonicalRead: String?

    var theme: String
    var summary: String
    var mood: String
    var themeKey: String?
    var toneKey: String?
    var identity: String?
    var insight: String?
    var focus: String?
    var affirmation: String?
    var energy: String?
    var energyKey: String?
    var reflectionTag: String?
    var reflectionNote: String?
    var moonPhase: String?
    var moonSignRaw: String?
    var sunSignRaw: String?
    var skyTheme: String?
    var skyTone: String?
    var westernSignRaw: String?
    var chineseSignRaw: String?
    var streakContext: Int?
    var patternConfidence: Double?
    var patternReflection: Double?
    var patternConnection: Double?
    var patternGrowth: Double?
    var patternMomentum: Double?
    var patternPrimarySignal: String?
    var patternSecondarySignal: String?
    var patternEmotionalTone: String?
    var patternThemeTags: [String]?

    var love: String
    var work: String
    var growth: String
    var caution: String
    var opportunity: String

    var createdAt: Date

    init(
        id: UUID = UUID(),
        dateKey: String,
        archetypeId: String,
        contentVersionRaw: String? = nil,
        canonicalTitle: String? = nil,
        canonicalRead: String? = nil,
        theme: String,
        summary: String,
        mood: String,
        themeKey: String? = nil,
        toneKey: String? = nil,
        identity: String? = nil,
        insight: String? = nil,
        focus: String? = nil,
        affirmation: String? = nil,
        energy: String? = nil,
        energyKey: String? = nil,
        reflectionTag: String? = nil,
        reflectionNote: String? = nil,
        moonPhase: String? = nil,
        moonSignRaw: String? = nil,
        sunSignRaw: String? = nil,
        skyTheme: String? = nil,
        skyTone: String? = nil,
        westernSignRaw: String? = nil,
        chineseSignRaw: String? = nil,
        streakContext: Int? = nil,
        patternConfidence: Double? = nil,
        patternReflection: Double? = nil,
        patternConnection: Double? = nil,
        patternGrowth: Double? = nil,
        patternMomentum: Double? = nil,
        patternPrimarySignal: String? = nil,
        patternSecondarySignal: String? = nil,
        patternEmotionalTone: String? = nil,
        patternThemeTags: [String]? = nil,
        love: String,
        work: String,
        growth: String,
        caution: String,
        opportunity: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dateKey = dateKey
        self.archetypeId = archetypeId
        self.contentVersionRaw = contentVersionRaw
        self.canonicalTitle = canonicalTitle
        self.canonicalRead = canonicalRead
        self.theme = theme
        self.summary = summary
        self.mood = mood
        self.themeKey = themeKey
        self.toneKey = toneKey
        self.identity = identity
        self.insight = insight
        self.focus = focus
        self.affirmation = affirmation
        self.energy = energy
        self.energyKey = energyKey
        self.reflectionTag = reflectionTag
        self.reflectionNote = reflectionNote
        self.moonPhase = moonPhase
        self.moonSignRaw = moonSignRaw
        self.sunSignRaw = sunSignRaw
        self.skyTheme = skyTheme
        self.skyTone = skyTone
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.streakContext = streakContext
        self.patternConfidence = patternConfidence
        self.patternReflection = patternReflection
        self.patternConnection = patternConnection
        self.patternGrowth = patternGrowth
        self.patternMomentum = patternMomentum
        self.patternPrimarySignal = patternPrimarySignal
        self.patternSecondarySignal = patternSecondarySignal
        self.patternEmotionalTone = patternEmotionalTone
        self.patternThemeTags = patternThemeTags
        self.love = love
        self.work = work
        self.growth = growth
        self.caution = caution
        self.opportunity = opportunity
        self.createdAt = createdAt
    }
}

extension SavedDailyReading {
    convenience init(
        content: DailyLensContent,
        dateKey: String,
        archetypeId: String,
        westernSignRaw: String?,
        chineseSignRaw: String?,
        streakContext: Int?,
        patternIntelligence: DailyReadPatternIntelligenceMetadata? = nil,
        createdAt: Date = Date()
    ) {
        precondition(content.isCandidate, "Use the control initializer for six-field production content.")

        self.init(
            dateKey: dateKey,
            archetypeId: archetypeId,
            contentVersionRaw: content.version.rawValue,
            canonicalTitle: content.title,
            canonicalRead: content.read,
            // These required legacy storage columns are intentionally blank for
            // a candidate. A candidate must not manufacture six-field meaning.
            theme: "",
            summary: "",
            mood: DailyMood.clarity.rawValue,
            themeKey: nil,
            identity: nil,
            insight: nil,
            westernSignRaw: westernSignRaw,
            chineseSignRaw: chineseSignRaw,
            streakContext: streakContext,
            patternConfidence: patternIntelligence?.confidence,
            patternReflection: patternIntelligence?.reflection,
            patternConnection: patternIntelligence?.connection,
            patternGrowth: patternIntelligence?.growth,
            patternMomentum: patternIntelligence?.momentum,
            patternPrimarySignal: patternIntelligence?.primarySignal,
            patternSecondarySignal: patternIntelligence?.secondarySignal,
            patternEmotionalTone: patternIntelligence?.emotionalTone,
            patternThemeTags: patternIntelligence?.themeTags.isEmpty == false ? patternIntelligence?.themeTags : nil,
            love: "",
            work: "",
            growth: "",
            caution: "",
            opportunity: "",
            createdAt: createdAt
        )
    }

    convenience init(
        control: DailyRitualResponse,
        dateKey: String,
        archetypeId: String,
        westernSignRaw: String?,
        chineseSignRaw: String?,
        streakContext: Int?,
        patternIntelligence: DailyReadPatternIntelligenceMetadata? = nil,
        createdAt: Date = Date()
    ) {
        self.init(
            dateKey: dateKey,
            archetypeId: archetypeId,
            contentVersionRaw: DailyLensContentVersion.productionControlV1.rawValue,
            theme: control.title,
            summary: control.validPullQuote ?? control.pullQuote,
            mood: DailyMood.clarity.rawValue,
            themeKey: control.title,
            identity: control.title,
            insight: control.intro,
            focus: control.validDeeperRead ?? control.deeperRead,
            westernSignRaw: westernSignRaw,
            chineseSignRaw: chineseSignRaw,
            streakContext: streakContext,
            patternConfidence: patternIntelligence?.confidence,
            patternReflection: patternIntelligence?.reflection,
            patternConnection: patternIntelligence?.connection,
            patternGrowth: patternIntelligence?.growth,
            patternMomentum: patternIntelligence?.momentum,
            patternPrimarySignal: patternIntelligence?.primarySignal,
            patternSecondarySignal: patternIntelligence?.secondarySignal,
            patternEmotionalTone: patternIntelligence?.emotionalTone,
            patternThemeTags: patternIntelligence?.themeTags.isEmpty == false ? patternIntelligence?.themeTags : nil,
            love: control.intro,
            work: control.validDeeperRead ?? control.deeperRead,
            growth: control.validMove ?? control.move,
            caution: control.validWatchFor ?? control.watchFor,
            opportunity: control.validMove ?? control.move,
            createdAt: createdAt
        )
    }

    var contentVersion: DailyLensContentVersion {
        contentVersionRaw.flatMap(DailyLensContentVersion.init(rawValue:))
            ?? .productionControlV1
    }

    var versionedLensContent: DailyLensContent? {
        guard contentVersion != .productionControlV1 else { return nil }
        guard let title = canonicalTitle?.nilIfBlankForSavedLens,
              let read = canonicalRead?.nilIfBlankForSavedLens else {
            return nil
        }

        return DailyLensContent(
            version: contentVersion,
            title: title,
            read: read,
            provenance: .candidate
        )
    }
}

private extension String {
    var nilIfBlankForSavedLens: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
