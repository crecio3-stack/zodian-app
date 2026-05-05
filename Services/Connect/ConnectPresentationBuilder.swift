import Foundation
import SwiftUI

struct ConnectDeckStatusPresentation {
    let deckStatusText: String
    let emptyStateTitle: String
    let emptyStateSubtitle: String
}

struct ConnectCelebrationPresentation {
    let title: String
    let message: String
    let compatibilityText: String
}

struct ConnectProfilePresentation {
    let compatibilityBadgeLabel: String
    let compatibilityPillText: String
    let compatibilitySummaryShort: String
    let compatibilitySummarySavedMatch: String
    let compatibilitySummaryPremium: String
    let matchEnergySummary: String
    let chatStarterPrompts: [String]
}

enum ConnectPresentation {
    static let compatibilityLabel = "Fit"

    static func imageAlignment(for anchor: UnitPoint) -> Alignment {
        switch anchor {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        default: return .center
        }
    }

    static func imageAlignment(for rawAnchor: String) -> Alignment {
        switch rawAnchor {
        case "top": return .top
        case "bottom": return .bottom
        case "leading": return .leading
        case "trailing": return .trailing
        case "topLeading": return .topLeading
        case "topTrailing": return .topTrailing
        case "bottomLeading": return .bottomLeading
        case "bottomTrailing": return .bottomTrailing
        default: return .center
        }
    }
}

enum ConnectPresentationBuilder {
    static func buildDeckStatus(
        isPremium: Bool,
        profileCount: Int,
        remainingCount: Int,
        hasReachedFreeLimit: Bool
    ) -> ConnectDeckStatusPresentation {
        let deckStatusText: String

        if isPremium {
            deckStatusText = profileCount == 0 ? "Room is quiet" : "\(profileCount) people ready"
        } else {
            deckStatusText = "\(remainingCount) left today"
        }

        let emptyStateTitle: String
        let emptyStateSubtitle: String

        if hasReachedFreeLimit {
            emptyStateTitle = "You’ve seen today’s room"
            emptyStateSubtitle = "Come back tomorrow, or unlock more people to keep comparing today."
        } else if isPremium {
            emptyStateTitle = "The room is quiet now"
            emptyStateSubtitle = "You’ve seen everyone in today’s rhythm. Come back when the pattern shifts."
        } else {
            emptyStateTitle = "No one else is showing up yet"
            emptyStateSubtitle = "The room changes daily. Come back when the next set lands."
        }

        return ConnectDeckStatusPresentation(
            deckStatusText: deckStatusText,
            emptyStateTitle: emptyStateTitle,
            emptyStateSubtitle: emptyStateSubtitle
        )
    }

    static func buildPresentation(
        profile: DeckProfile,
        compatibility: CompatibilityBreakdown? = nil
    ) -> ConnectProfilePresentation {
        buildPresentation(
            score: profile.compatibilityScore,
            style: compatibility?.style ?? profile.matchStyle,
            name: profile.name,
            reasons: compatibility?.reasons ?? profile.matchReasons,
            frictionNote: compatibility?.frictionNote ?? profile.frictionNote
        )
    }

    static func buildPresentation(
        match: SavedMatch,
        compatibility: CompatibilityBreakdown? = nil
    ) -> ConnectProfilePresentation {
        buildPresentation(
            score: match.compatibilityScore,
            style: compatibility?.style ?? MatchStyle(rawValue: match.matchStyleRaw) ?? .growth,
            name: match.name,
            reasons: compatibility?.reasons ?? [],
            frictionNote: compatibility?.frictionNote ?? match.frictionNote
        )
    }

    static func buildCelebration(
        name: String,
        compatibilityScore: Int
    ) -> ConnectCelebrationPresentation {
        ConnectCelebrationPresentation(
            title: "Saved to your room",
            message: "\(name) is in Matches now.",
            compatibilityText: "\(compatibilityScore)% fit"
        )
    }

    private static func buildPresentation(
        score: Int,
        style: MatchStyle,
        name: String,
        reasons: [MatchReason],
        frictionNote: String
    ) -> ConnectProfilePresentation {
        ConnectProfilePresentation(
            compatibilityBadgeLabel: ConnectPresentation.compatibilityLabel,
            compatibilityPillText: "\(score)% \(ConnectPresentation.compatibilityLabel)",
            compatibilitySummaryShort: deckCompatibilitySummary(for: score, style: style),
            compatibilitySummarySavedMatch: savedMatchCompatibilitySummary(for: score, style: style, name: name),
            compatibilitySummaryPremium: premiumCompatibilityInsight(for: score, style: style, reasons: reasons, frictionNote: frictionNote),
            matchEnergySummary: matchEnergySummary(for: score, style: style),
            chatStarterPrompts: chatStarterPrompts(for: style)
        )
    }

    private static func deckCompatibilitySummary(for score: Int, style: MatchStyle) -> String {
        switch style {
        case .harmonious:
            return "Easy to be around. No friction."
        case .mirrored:
            return "Familiar fast. It clicks quickly."
        case .growth:
            return "Different enough to expand you."
        case .magnetic:
            return "Strong chemistry. Not automatically simple."
        case .intense:
            return "There is charge here. Read slowly."
        }
    }

    private static func savedMatchCompatibilitySummary(for score: Int, style: MatchStyle, name: String) -> String {
        switch style {
        case .harmonious:
            return "\(name) feels easy to be around. That’s not something to overthink."
        case .mirrored:
            return "\(name) might feel familiar fast. Stay curious instead of assuming."
        case .growth:
            return "\(name) moves differently than you. That’s where this works."
        case .magnetic:
            return "There’s strong chemistry with \(name). Don’t rush what it is."
        case .intense:
            return "\(name) might hit stronger than expected. Take your time with it."
        }
    }

    private static func premiumCompatibilityInsight(
        for score: Int,
        style: MatchStyle,
        reasons: [MatchReason],
        frictionNote: String
    ) -> String {

        let cleanFriction = frictionNote.trimmingCharacters(in: .whitespacesAndNewlines)

        switch style {
        case .harmonious:
            return "It works because nothing feels forced. Don’t complicate it."

        case .mirrored:
            return "It feels familiar for a reason. Just don’t assume you already know it."

        case .growth:
            return cleanFriction.isEmpty
                ? "This works through difference. That’s where the shift happens."
                : cleanFriction

        case .magnetic:
            return cleanFriction.isEmpty
                ? "The chemistry is real. It still needs pacing."
                : cleanFriction

        case .intense:
            return cleanFriction.isEmpty
                ? "This is strong energy. Move slow enough to understand it."
                : cleanFriction
        }
    }

    private static func matchEnergySummary(for score: Int, style: MatchStyle) -> String {
        switch style {
        case .harmonious:
            return "This one feels easy."

        case .mirrored:
            return "There’s recognition here."

        case .growth:
            return "This shifts you a little."

        case .magnetic:
            return "It starts as curiosity."

        case .intense:
            return "There’s something strong here."
        }
    }

    private static func chatStarterPrompts(for style: MatchStyle) -> [String] {
        switch style {
        case .harmonious:
            return [
                "What usually makes someone easy for you to be around?",
                "What kind of people make you feel calm fast?",
                "What does trust look like before words?"
            ]
        case .mirrored:
            return [
                "What do people usually recognize in you first?",
                "Do you like familiar energy or does it make you cautious?",
                "What part of you gets misunderstood the most?"
            ]
        case .growth:
            return [
                "What kind of person makes you think differently?",
                "Where do you like being challenged?",
                "What pace works best when someone is new?"
            ]
        case .magnetic:
            return [
                "What kind of energy gets your attention fast?",
                "Do you trust instant chemistry?",
                "What makes someone hard to ignore?"
            ]
        case .intense:
            return [
                "What makes a connection too much too soon?",
                "Do you read people quickly or let them unfold?",
                "What kind of tension keeps you curious?"
            ]
        }
    }
}
