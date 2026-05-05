import Foundation

struct DailyRitualPresentation {
    let currentMood: DailyMood
    let skyCueText: String?
    let skyCueIcon: String
    let dailyEntryLines: [String]
    let identityRecognitionLine: String
    let progressHeadline: String
    let progressSubtitle: String
    let progressMessage: String
    let streakTierLabel: String
    let streakMeaning: String
    let tomorrowPullMessage: String
    let layerContent: [RitualLayer: String]

    func content(for layer: RitualLayer) -> String {
        layerContent[layer, default: ""]
    }
}
enum RitualLayer: String, CaseIterable, Identifiable {
    case identity
    case insight
    case focus
    case caution
    case affirmation

    var id: String { rawValue }
}
enum DailyRitualPresentationBuilder {
    
    static func build(
        reading: DailyReading,
        archetype: Archetype,
        streak: Int,
        revealedLayerCount: Int,
        hasCompletedRitualToday: Bool
    ) -> DailyRitualPresentation {
        
        let core = buildCoreMessage(reading: reading)
        let support = buildSupportLine(reading: reading)
        let closing = buildClosingLine(reading: reading, streak: streak)
        
        return DailyRitualPresentation(
            currentMood: currentMood(for: reading),
            skyCueText: skyCueText(for: reading),
            skyCueIcon: skyCueIcon(for: reading),
            dailyEntryLines: [core, support].compactMap { $0 },
            identityRecognitionLine: identityRecognitionLine(for: reading),
            progressHeadline: "",
            progressSubtitle: "",
            progressMessage: "",
            streakTierLabel: streakTierLabel(for: streak),
            streakMeaning: streakMeaning(for: streak),
            tomorrowPullMessage: closing,
            layerContent: [
                .identity: reading.identity,
                .insight: reading.insight,
                .focus: reading.focus,
                .caution: reading.caution,
                .affirmation: reading.affirmation
            ]
        )
    }
    
    // MARK: - Core Daily Message
    
    private static func buildCoreMessage(reading: DailyReading) -> String {
        let insight = trimmed(reading.insight)?.lowercased() ?? ""
        let focus = trimmed(reading.focus)?.lowercased() ?? ""
        let caution = trimmed(reading.caution)?.lowercased() ?? ""

        let combined = insight + " " + focus + " " + caution

        if combined.contains("distance") || combined.contains("pull away") || combined.contains("withdraw") {
            return "You’re creating distance where something needs honesty."
        }

        if combined.contains("wait") || combined.contains("slow") || combined.contains("timing") {
            return "You’re waiting when you should be moving."
        }

        if combined.contains("act") || combined.contains("move") || combined.contains("start") {
            return "You already know enough. Stop stalling and move."
        }

        if combined.contains("confusion") || combined.contains("unclear") || combined.contains("fog") {
            return "This is not confusion. It’s reluctance."
        }

        if combined.contains("return") || combined.contains("again") || combined.contains("repeat") {
            return "Something is back in front of you because you still haven’t dealt with it."
        }

        if combined.contains("control") || combined.contains("grip") || combined.contains("tight") {
            return "You’re trying to control something you haven’t understood yet."
        }

        return "Something important isn’t going away until you face it."
    }

    private static func buildSupportLine(reading: DailyReading) -> String? {
        let focus = trimmed(reading.focus)
        let caution = trimmed(reading.caution)

        guard let focus else { return nil }

        if let caution, !caution.isEmpty {
            return "\(cleanLine(from: focus)) \(softCaution(from: caution))"
        }

        return cleanLine(from: focus)
    }
    private static func cleanLine(from text: String) -> String {
        firstSentence(from: text)
    }

    private static func softCaution(from text: String) -> String {
        let caution = firstSentence(from: text)

        return lowercasedFirstLetter(caution)
    }

    private static func lowercasedFirstLetter(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.lowercased() + text.dropFirst()
    }
    private static func buildClosingLine(reading: DailyReading, streak: Int) -> String {
        let text = (
            (trimmed(reading.insight) ?? "") + " " +
            (trimmed(reading.focus) ?? "") + " " +
            (trimmed(reading.caution) ?? "")
        ).lowercased()

        if streak >= 7 {
            return "By now, you know exactly what this feels like."
        }

        if text.contains("act") || text.contains("move") || text.contains("start") {
            return "Do it before doubt starts rewriting the story."
        }

        if text.contains("wait") || text.contains("slow") || text.contains("space") {
            return "If you rush this, you’ll miss what matters."
        }

        if text.contains("distance") || text.contains("withdraw") {
            return "Pulling away will not protect you from what is already true."
        }

        if text.contains("control") || text.contains("tight") {
            return "Relax your grip. You’ll see more."
        }

        return "You already know what this is."
    }
    
    
    
    // MARK: - Existing Presentation Helpers
    
    private static func currentMood(for reading: DailyReading) -> DailyMood {
        if let key = reading.energyKey,
           let mapped = DailyMood(rawValue: key.lowercased()) {
            return mapped
        }
        return .clarity
    }
    
    private static func skyCueText(for reading: DailyReading) -> String? {
        let moonPart = reading.moonSign.map { "\($0.displayName) Moon" }
        let phasePart = reading.moonPhase?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch (phasePart, moonPart) {
        case let (phase?, moon?):
            return "\(phase) • \(moon)"
        case let (phase?, nil):
            return phase
        case let (nil, moon?):
            return moon
        default:
            return nil
        }
    }
    
    private static func skyCueIcon(for reading: DailyReading) -> String {
        guard let phase = reading.moonPhase?.lowercased() else { return "moon.stars.fill" }
        
        if phase.contains("full") {
            return "moon.full.fill"
        }
        if phase.contains("new") {
            return "moonphase.new.moon"
        }
        return "moon.stars.fill"
    }
    
    private static func identityRecognitionLine(for reading: DailyReading) -> String {
        let title = reading.identity.lowercased()
        
        if title.contains("hidden") {
            return "The obvious story usually is not the whole one."
        }
        if title.contains("returning") {
            return "This has been circling long before today."
        }
        if title.contains("quiet") {
            return "It lands quietly, then starts running everything."
        }
        if title.contains("shifting") {
            return "Something underneath has already started turning."
        }
        if title.contains("unseen") {
            return "This layer gets felt before it gets named."
        }
        
        return "Something familiar is showing its real shape."
    }
    
    private static func streakTierLabel(for streak: Int) -> String {
        switch streak {
        case 0...2: return "Starting"
        case 3...5: return "Building"
        case 6...10: return "Consistent"
        default: return "Identity Forming"
        }
    }
    
    private static func streakMeaning(for streak: Int) -> String {
        switch streak {
        case 0...2:
            return "You’re building something real. Each return makes it stronger."
        case 3...5:
            return "Your rhythm is getting stronger. It’s starting to stick."
        case 6...10:
            return "This is starting to feel natural. It’s part of your rhythm now."
        default:
            return "This is becoming part of you. It feels natural now."
        }
    }
    
    // MARK: - Text Helpers
    
    private static func combine(_ a: String, _ b: String) -> String {
        let first = firstSentence(from: a)
        
        // only show second sentence if it's short
        let second = firstSentence(from: b)
        
        if first.count > 80 {
            return first
        }
        
        if first.count + second.count > 110 {
            return first
        }
        
        return "\(first) \(second)"
    }
    
    private static func trimmed(_ text: String?) -> String? {
        let value = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
    
    private static func firstSentence(from text: String) -> String {
        let parts = text.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
        return parts.first.map { String($0) + "." } ?? text
    }
}
       
