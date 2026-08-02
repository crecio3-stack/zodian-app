import Foundation
import SwiftUI
import UIKit

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
    static let compatibilityLabel = "Saved"

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

    static func focalPoint(for rawAnchor: String) -> UnitPoint {
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

    static func imageAlignment(for rawAnchor: String) -> Alignment {
        imageAlignment(for: focalPoint(for: rawAnchor))
    }
}

enum ConnectProfileImageClipShape {
    case roundedRectangle(CGFloat)
    case circle
}

struct ConnectProfileImageOverlay {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    let blendMode: BlendMode

    static func gradient(
        _ colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom,
        blendMode: BlendMode = .normal
    ) -> Self {
        Self(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint,
            blendMode: blendMode
        )
    }
}

enum ConnectProfileImageSource {
    case asset(String)
    case url(URL)
}

struct ConnectProfileImage: View {
    private let source: ConnectProfileImageSource
    private let size: CGSize
    private let focalPoint: UnitPoint
    private let clipShape: ConnectProfileImageClipShape
    private let overlay: ConnectProfileImageOverlay?

    init(
        assetName: String,
        size: CGSize,
        focalPoint: UnitPoint = .center,
        clipShape: ConnectProfileImageClipShape = .roundedRectangle(28),
        overlay: ConnectProfileImageOverlay? = nil
    ) {
        self.source = .asset(assetName)
        self.size = size
        self.focalPoint = ConnectPortraitCatalog.focalPoint(for: assetName) ?? focalPoint
        self.clipShape = clipShape
        self.overlay = overlay
    }

    init(
        url: URL,
        size: CGSize,
        focalPoint: UnitPoint = .center,
        clipShape: ConnectProfileImageClipShape = .roundedRectangle(28),
        overlay: ConnectProfileImageOverlay? = nil
    ) {
        self.source = .url(url)
        self.size = size
        self.focalPoint = focalPoint
        self.clipShape = clipShape
        self.overlay = overlay
    }

    var body: some View {
        switch clipShape {
        case .roundedRectangle(let radius):
            imageContent
                .frame(width: size.width, height: size.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .circle:
            imageContent
                .frame(width: size.width, height: size.height)
                .clipped()
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        switch source {
        case .asset(let assetName):
            if let image = UIImage(named: assetName) {
                focalImage(image)
                    .overlay(overlayView)
            } else {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: size.width,
                        height: size.height,
                        alignment: ConnectPresentation.imageAlignment(for: focalPoint)
                    )
                    .clipped()
                    .overlay(overlayView)
            }
        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: size.width,
                            height: size.height,
                            alignment: ConnectPresentation.imageAlignment(for: focalPoint)
                        )
                        .clipped()
                        .overlay(overlayView)
                case .failure:
                    fallbackFill
                case .empty:
                    fallbackFill
                @unknown default:
                    fallbackFill
                }
            }
        }
    }

    private func focalImage(_ image: UIImage) -> some View {
        let imageSize = image.size
        let imageAspectRatio = imageSize.width / max(imageSize.height, 1)
        let frameAspectRatio = size.width / max(size.height, 1)
        let drawSize: CGSize

        if imageAspectRatio > frameAspectRatio {
            drawSize = CGSize(width: size.height * imageAspectRatio, height: size.height)
        } else {
            drawSize = CGSize(width: size.width, height: size.width / max(imageAspectRatio, 0.001))
        }

        let maxOffset = CGSize(
            width: max((drawSize.width - size.width) / 2, 0),
            height: max((drawSize.height - size.height) / 2, 0)
        )
        let rawOffset = CGSize(
            width: (0.5 - focalPoint.x) * drawSize.width,
            height: (0.5 - focalPoint.y) * drawSize.height
        )
        let clampedOffset = CGSize(
            width: min(max(rawOffset.width, -maxOffset.width), maxOffset.width),
            height: min(max(rawOffset.height, -maxOffset.height), maxOffset.height)
        )

        return Image(uiImage: image)
            .resizable()
            .frame(width: drawSize.width, height: drawSize.height)
            .offset(clampedOffset)
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    private var fallbackFill: some View {
        Color.black.opacity(0.08)
            .frame(width: size.width, height: size.height)
            .overlay(overlayView)
    }

    @ViewBuilder
    private var overlayView: some View {
        if let overlay {
            LinearGradient(
                colors: overlay.colors,
                startPoint: overlay.startPoint,
                endPoint: overlay.endPoint
            )
            .blendMode(overlay.blendMode)
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
            deckStatusText = profileCount == 0 ? "No one ready yet" : "\(profileCount) people ready"
        } else {
            deckStatusText = "\(remainingCount) left today"
        }

        let emptyStateTitle: String
        let emptyStateSubtitle: String

        if hasReachedFreeLimit {
            emptyStateTitle = "You’ve seen today’s people"
            emptyStateSubtitle = "Come back tomorrow when the list updates"
        } else if isPremium {
            emptyStateTitle = "No more people for today"
            emptyStateSubtitle = "You’ve seen everyone in today’s set. Check back when the list updates"
        } else {
            emptyStateTitle = "No one else is ready yet"
            emptyStateSubtitle = "The list changes daily. Come back when new people appear"
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
            title: "Saved to Connect",
            message: "\(name) is saved in Connect",
            compatibilityText: "Saved"
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
            compatibilityPillText: ConnectPresentation.compatibilityLabel,
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
            return "Easy to talk to"
        case .mirrored:
            return "Feels familiar fast"
        case .growth:
            return "Hard to stop thinking about"
        case .magnetic:
            return "Keeps returning"
        case .intense:
            return "Hard to forget"
        }
    }

    private static func savedMatchCompatibilitySummary(for score: Int, style: MatchStyle, name: String) -> String {
        switch style {
        case .harmonious:
            return "Nothing about \(name) felt forced"
        case .mirrored:
            return "\(name) kept feeling familiar after you left"
        case .growth:
            return "\(name) changed where your attention went"
        case .magnetic:
            return "\(name) stayed active in your mind"
        case .intense:
            return "\(name) made the moment hard to forget"
        }
    }

    private static func premiumCompatibilityInsight(
        for score: Int,
        style: MatchStyle,
        reasons: [MatchReason],
        frictionNote: String
    ) -> String {

        let cleanFriction = frictionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let rememberedFriction = cleanFriction.isEmpty || containsReportLanguage(cleanFriction)
            ? nil
            : cleanFriction

        switch style {
        case .harmonious:
            return "You stopped managing the conversation and started having it"

        case .mirrored:
            return "You felt understood without explaining everything"

        case .growth:
            return rememberedFriction ?? "Something about their perspective kept returning"

        case .magnetic:
            return rememberedFriction ?? "The curiosity kept coming back after the first impression"

        case .intense:
            return rememberedFriction ?? "The conversation kept unfolding afterward"
        }
    }

    private static func containsReportLanguage(_ value: String) -> Bool {
        let lower = value.lowercased()
        return [
            "zodiac",
            "western",
            "eastern",
            "sign",
            "archetype",
            "compatibility",
            "percentage",
            "percent",
            "score",
            "pull score",
            "instinct",
            "rhythm",
            "energy",
            "chemistry",
            "element",
            "line up"
        ].contains { lower.contains($0) }
    }

    private static func matchEnergySummary(for score: Int, style: MatchStyle) -> String {
        switch style {
        case .harmonious:
            return "Feels easy"

        case .mirrored:
            return "Feels familiar"

        case .growth:
            return "Feels unfinished"

        case .magnetic:
            return "Keeps returning"

        case .intense:
            return "Stays with you"
        }
    }

    private static func chatStarterPrompts(for style: MatchStyle) -> [String] {
        switch style {
        case .harmonious:
            return [
                "What made this feel easy to return to?",
                "What did you stop managing around them?",
                "What part felt simple after you closed the profile?"
            ]
        case .mirrored:
            return [
                "What kept feeling familiar afterward?",
                "What detail did you keep replaying?",
                "What did they seem to notice without forcing it?"
            ]
        case .growth:
            return [
                "What felt unfinished after you closed the profile?",
                "What did you answer differently in your head?",
                "What thought kept opening back up?"
            ]
        case .magnetic:
            return [
                "What kept returning after the first impression?",
                "What part stayed interesting longer than expected?",
                "What did you want another look at?"
            ]
        case .intense:
            return [
                "What kept replaying after the moment passed?",
                "What felt unresolved in a way you wanted to follow?",
                "What did you need more time to understand?"
            ]
        }
    }
}
