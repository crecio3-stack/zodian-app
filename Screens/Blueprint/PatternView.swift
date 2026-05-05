import SwiftUI
import Foundation
import UIKit

struct PatternView: View {
    @EnvironmentObject private var store: AppStore

    @StateObject private var viewModel = BlueprintViewModel()
    @State private var sharePayload: SharePayload?
    @State private var showPremiumSheet = false
    @State private var appeared = false

    private var presentation: BlueprintPresentation {
        viewModel.presentation
    }

    private var identityContent: ZodiacIdentityContent {
        presentation.identityContent
    }

    private var pattern: PatternPageContent {
        PatternPageContent.make(
            archetype: presentation.currentArchetype,
            identity: identityContent,
            user: store.currentUser
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    PatternAtmosphere()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            heroStage
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 14
                                )

                            twoColumnTraitGrid
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 18
                                )

                            patternSection(
                                eyebrow: "CORE PATTERN",
                                title: "How you move",
                                body: pattern.howYouMove
                            )
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 16
                            )

                            patternSection(
                                eyebrow: "SHADOWS",
                                title: "What gets in the way",
                                body: pattern.shadowRead,
                                tone: .warning
                            )
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 16
                            )

                            patternSection(
                                eyebrow: "DEEPER LAYERS",
                                title: "Love and friendship",
                                body: pattern.connectionRead
                            )
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 14
                            )

                            patternSection(
                                eyebrow: "DEEPER LAYERS",
                                title: "Work and purpose",
                                body: pattern.workRead
                            )
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 14
                            )

                            patternSection(
                                eyebrow: "EVOLUTION PATH",
                                title: "How you stay clear",
                                body: pattern.growthRead,
                                tone: .accent
                            )
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 14
                            )

                            if !pattern.compatibilityRead.isEmpty {
                                patternSection(
                                    eyebrow: "CLOSE COMPANY",
                                    title: "How it lands with others",
                                    body: pattern.compatibilityRead
                                )
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 12
                                )
                            }

                            deeperLayersSection
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 20
                                )

                            connectCTA
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 14
                            )

                            identitySealCard(maxWidth: max(proxy.size.width - 40, 0))
                            .patternCinematicMotion(
                                appeared: appeared,
                                entranceOffset: 12
                            )
                        }
                        .frame(width: max(proxy.size.width - 40, 0), alignment: .leading)
                        .padding(.top, 18)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                    .frame(width: proxy.size.width)
                    .clipped()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $sharePayload) { payload in
                ActivityShareSheet(activityItems: payload.activityItems)
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumRewardsSheet(source: "pattern")
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .onAppear {
                refreshPresentation()
                withAnimation(.easeOut(duration: 0.78)) {
                    appeared = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Sections

private extension PatternView {
    var heroStage: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .topLeading) {
                PatternHeroBackdrop()

                VStack(alignment: .leading, spacing: 18) {
                    compactHeader
                    identitySummaryCard
                }
                .padding(18)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var compactHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR PATTERN")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(3)
                .foregroundStyle(ZD.Color.muted)

            Text(pattern.combinedName)
                .font(.system(size: 31, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("A sharper read of how you move")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var identitySummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CORE PATTERN")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(ZD.Color.accent)

                    Text(pattern.oneLineRead)
                        .font(.system(size: 23, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Button {
                    shareCurrentIdentity()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(ZD.Color.cardAlt.opacity(0.9))
                                .overlay(
                                    Circle()
                                        .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share identity")
            }

            Text(PatternPageContent.summaryLead(pattern.summary))
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(ZD.Color.card.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: ZD.Color.accent.opacity(0.08), radius: 18, y: 10)
    }

    var twoColumnTraitGrid: some View {
        HStack(alignment: .top, spacing: 12) {
            traitStack(
                label: "STRENGTHS",
                title: pattern.primaryStrength,
                items: pattern.strengths,
                accent: ZD.Color.accent,
                glow: ZD.Color.accent.opacity(0.12)
            )

            traitStack(
                label: "SHADOWS",
                title: pattern.primaryShadow,
                items: pattern.shadows,
                accent: ZD.Color.premium,
                glow: ZD.Color.premium.opacity(0.10)
            )
        }
        .frame(maxWidth: .infinity)
    }

    var deeperLayersSection: some View {
        Group {
            if store.effectivePremiumAccess {
                VStack(alignment: .leading, spacing: 14) {
                    sectionLabel(title: "DEEPER LAYERS", accent: ZD.Color.premium)

                    Text("What the pattern reveals")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 12) {
                        deeperLayerRow(
                            label: "Love",
                            body: PatternPageContent.compactParagraph(
                                pattern.connectionRead,
                                fallback: PatternPageContent.compactParagraph(
                                    identityContent.loveStyle,
                                    fallback: "How closeness works when the pattern is honest"
                                )
                            )
                        )

                        deeperLayerRow(
                            label: "Work",
                            body: PatternPageContent.compactParagraph(
                                pattern.workRead,
                                fallback: PatternPageContent.compactParagraph(
                                    identityContent.workStyle,
                                    fallback: "Where your pattern becomes useful in motion"
                                )
                            )
                        )

                        deeperLayerRow(
                            label: "Pressure",
                            body: PatternPageContent.compactParagraph(
                                pattern.shadowRead,
                                fallback: PatternPageContent.compactParagraph(
                                    identityContent.shadowLoop,
                                    fallback: "What tightens first when the pattern gets tested"
                                )
                            )
                        )

                        deeperLayerRow(
                            label: "Evolution",
                            body: PatternPageContent.compactParagraph(
                                identityContent.matureExpression,
                                fallback: "How this pattern settles as it grows up"
                            )
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(
                    patternPanelBackground(
                        cornerRadius: 24,
                        accent: ZD.Color.premium,
                        base: ZD.Color.cardAlt.opacity(0.86),
                        glow: ZD.Color.premium.opacity(0.10)
                    )
                )
            } else {
                Button {
                    showPremiumSheet = true
                } label: {
                    PremiumTileRow(
                        title: "Unlock deeper layers",
                        subtitle: "See the love, work, pressure, and evolution reads",
                        icon: "crown.fill",
                        isPremium: false
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    func deeperLayerRow(label: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(ZD.Color.premium.opacity(0.92))

            Text(body)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func sectionLabel(title: String, accent: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(accent.opacity(0.9))
    }

    func traitStack(label: String, title: String, items: [String], accent: Color) -> some View {
        traitStack(label: label, title: title, items: items, accent: accent, glow: accent.opacity(0.12))
    }

    func traitStack(label: String, title: String, items: [String], accent: Color, glow: Color) -> some View {
        let visibleItems = items
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .prefix(2)

        return VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(accent.opacity(0.9))

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(visibleItems), id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle()
                            .fill(accent.opacity(0.7))
                            .frame(width: 5, height: 5)

                        Text(item)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 172, alignment: .topLeading)
        .padding(16)
        .background(
            patternPanelBackground(
                cornerRadius: 22,
                accent: accent,
                base: ZD.Color.card.opacity(0.82),
                glow: glow
            )
        )
    }

    func patternSection(
        eyebrow: String,
        title: String,
        body: String,
        tone: PatternTone = .standard
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(2)
                .foregroundStyle(tone.accent)

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(body)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            patternPanelBackground(
                cornerRadius: 24,
                accent: tone.accent,
                base: tone.fill,
                glow: tone.accent.opacity(0.08)
            )
        )
    }

    func identitySealCard(maxWidth: CGFloat) -> some View {
        VStack(spacing: 14) {
            Text("THE SEAL")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(2.4)
                .foregroundStyle(ZD.Color.muted)

            IdentityRevealCardView(content: identityContent, includeBrandFooter: false)
                .frame(width: maxWidth)
                .frame(minHeight: 560)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .onLongPressGesture(minimumDuration: 0.45) {
                    shareCurrentIdentity()
                }

            Text("Long press the card to share it")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ZD.Color.muted.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    var connectCTA: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.easeInOut(duration: 0.28)) {
                store.selectedTab = .connect
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(ZD.Color.premium.opacity(0.16))
                        .frame(width: 46, height: 46)

                    Image(systemName: "person.2.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(ZD.Color.premium)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("See who fits your pattern")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Compare fit, friction, and timing")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ZD.Color.muted)
            }
            .padding(16)
            .background(
                patternPanelBackground(
                    cornerRadius: 24,
                    accent: ZD.Color.premium,
                    base: ZD.Color.card.opacity(0.82),
                    glow: ZD.Color.premium.opacity(0.12)
                )
            )
        }
        .buttonStyle(.plain)
    }

    func patternPanelBackground(
        cornerRadius: CGFloat,
        accent: Color,
        base: Color,
        glow: Color
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        base,
                        base.opacity(0.95),
                        ZD.Color.bg.opacity(0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.20),
                                glow,
                                ZD.Color.border.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(glow)
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)
                    .offset(x: 30, y: -36)
                    .allowsHitTesting(false)
            }
    }
}

// MARK: - Actions

private extension PatternView {
    func refreshPresentation() {
        viewModel.refresh(user: store.currentUser, archetype: store.currentArchetype)
    }

    func shareCurrentIdentity() {
        let content = identityContent
        guard let shareText = presentation.shareText else { return }
        guard let image = IdentityRevealShareRenderer.renderImage(for: content) else { return }

        sharePayload = SharePayload(activityItems: [shareText, image])

        AnalyticsService.shared.track(
            .identitySharePresented(
                identityID: content.id,
                title: content.title,
                source: "pattern"
            )
        )
    }

    struct SharePayload: Identifiable {
        let id = UUID()
        let activityItems: [Any]
    }
}

private struct PatternCinematicMotionModifier: ViewModifier {
    let appeared: Bool
    let entranceOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : entranceOffset)
            .scaleEffect(appeared ? 1 : 0.99)
            .animation(.easeOut(duration: 0.34), value: appeared)
    }
}

private extension View {
    func patternCinematicMotion(
        appeared: Bool,
        entranceOffset: CGFloat
    ) -> some View {
        modifier(
            PatternCinematicMotionModifier(
                appeared: appeared,
                entranceOffset: entranceOffset
            )
        )
    }
}

private struct PatternHeroBackdrop: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.94),
                            ZD.Color.cardAlt.opacity(0.82),
                            ZD.Color.card.opacity(0.64)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.24),
                            ZD.Color.premium.opacity(0.10),
                            ZD.Color.border.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Circle()
                .fill(ZD.Color.accent.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 2)
                .offset(x: 104, y: -96)

            Circle()
                .stroke(ZD.Color.premium.opacity(0.18), lineWidth: 1)
                .frame(width: 172, height: 172)
                .offset(x: 146, y: -38)

            Circle()
                .fill(ZD.Color.card.opacity(0.88))
                .frame(width: 118, height: 118)
                .overlay(
                    Circle()
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )
                .offset(x: -38, y: 138)

        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .shadow(color: ZD.Color.shadow.opacity(0.18), radius: 30, y: 18)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }
}

// MARK: - Atmosphere

private struct PatternAtmosphere: View {
    @State private var breathe = false

    var body: some View {
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(breathe ? 0.20 : 0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(breathe ? 0.12 : 0.07),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 560
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.premium.opacity(breathe ? 0.08 : 0.04),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 30,
                    endRadius: 520
                )
            )
            .overlay(
                Circle()
                    .fill(ZD.Color.accent.opacity(0.10))
                    .frame(width: 240, height: 240)
                    .blur(radius: 18)
                    .offset(x: breathe ? 130 : 110, y: breathe ? -120 : -98)
                    .allowsHitTesting(false)
            )
            .overlay(
                Circle()
                    .stroke(ZD.Color.premium.opacity(0.12), lineWidth: 1)
                    .frame(width: 176, height: 176)
                    .offset(x: breathe ? 122 : 138, y: breathe ? 18 : 8)
                    .allowsHitTesting(false)
            )
            .overlay(
                Circle()
                    .fill(ZD.Color.cardAlt.opacity(0.18))
                    .frame(width: 122, height: 122)
                    .blur(radius: 12)
                    .offset(x: breathe ? -26 : -40, y: breathe ? 148 : 130)
                    .allowsHitTesting(false)
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 6.4).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
    }
}

// MARK: - Presentation
private enum PatternTone {
    case standard
    case accent
    case warning

    var accent: Color {
        switch self {
        case .standard:
            return ZD.Color.muted
        case .accent:
            return ZD.Color.accent
        case .warning:
            return ZD.Color.premium
        }
    }

    var fill: Color {
        switch self {
        case .standard:
            return ZD.Color.card.opacity(0.82)
        case .accent:
            return ZD.Color.card.opacity(0.90)
        case .warning:
            return ZD.Color.cardAlt.opacity(0.82)
        }
    }

    var stroke: Color {
        switch self {
        case .standard:
            return ZD.Color.border.opacity(0.15)
        case .accent:
            return ZD.Color.accent.opacity(0.18)
        case .warning:
            return ZD.Color.premium.opacity(0.16)
        }
    }
}
private struct PatternPageContent {
    let id: String
    let combinedName: String
    let title: String
    let tagline: String
    let oneLineRead: String
    let summary: String
    let howYouMove: String
    let shadowRead: String
    let connectionRead: String
    let workRead: String
    let growthRead: String
    let compatibilityRead: String
    let strengths: [String]
    let shadows: [String]

    var primaryStrength: String {
        strengths.first ?? "Clear read"
    }

    var primaryShadow: String {
        shadows.first ?? "Old reaction"
    }

    static func make(
        archetype: Archetype?,
        identity: ZodiacIdentityContent,
        user: UserProfile?
    ) -> PatternPageContent {
        guard let archetype else {
            return fallback(identity: identity, user: user)
        }

        let id = archetype.id.lowercased()
        let western = signPart(id: id, index: 0, fallback: user?.westernSign.displayName ?? "Western")
        let eastern = signPart(id: id, index: 1, fallback: user?.chineseSign.displayName ?? "Eastern")

        let strength = clean(archetype.dominantStrengthTrait, fallback: archetype.strengths.first ?? "Instinct")
        let shadow = clean(archetype.dominantShadowTrait, fallback: archetype.shadows.first ?? "Old reaction")

        let strengths = prioritizedList(primary: strength, values: archetype.strengths)
        let shadows = prioritizedList(primary: shadow, values: archetype.shadows)

        return PatternPageContent(
            id: id,
            combinedName: clean(archetype.combinedName, fallback: "\(western) × \(eastern)"),
            title: clean(archetype.title, fallback: identity.title),
            tagline: clean(archetype.tagline, fallback: identity.tagline),
            oneLineRead: oneLineRead(strength: strength, shadow: shadow),
            summary: clean(archetype.overview, fallback: identity.identitySummary),
            howYouMove: clean(archetype.howYouMove, fallback: identity.workStyle),
            shadowRead: shadowRead(emotionalPattern: archetype.emotionalPattern, shadow: shadow),
            connectionRead: connectionRead(love: archetype.loveStyle, friendship: archetype.friendshipStyle),
            workRead: workRead(archetype.workStyle),
            growthRead: growthRead(archetype.growthPath),
            compatibilityRead: clean(archetype.compatibilityNotes, fallback: ""),
            strengths: strengths,
            shadows: shadows
        )
    }

    static func fallback(identity: ZodiacIdentityContent, user: UserProfile?) -> PatternPageContent {
        let western = user?.westernSign.displayName ?? "Western"
        let eastern = user?.chineseSign.displayName ?? "Eastern"

        let strengths = cleanedList(identity.strengths, fallback: ["Perceptive", "Adaptive", "Magnetic"])
        let shadows = cleanedList(identity.growthEdges, fallback: ["Overthinking", "Withholding", "Reacting fast"])

        let strength = strengths.first ?? "Instinct"
        let shadow = shadows.first ?? "Old reaction"

        return PatternPageContent(
            id: identity.id,
            combinedName: "\(western) × \(eastern)",
            title: identity.title,
            tagline: clean(identity.tagline, fallback: "Pattern in motion"),
            oneLineRead: oneLineRead(strength: strength, shadow: shadow),
            summary: clean(identity.identitySummary, fallback: "A pattern with gifts, defenses, timing, and tells"),
            howYouMove: clean(identity.workStyle, fallback: "The pattern shows up most clearly in motion"),
            shadowRead: clean(identity.emotionalPattern, fallback: "Pressure reveals the reaction before the reason"),
            connectionRead: [identity.loveStyle, identity.friendshipStyle]
                .map { clean($0, fallback: "") }
                .filter { !$0.isEmpty }
                .joined(separator: " "),
            workRead: clean(identity.workStyle, fallback: "Work reveals where the pattern becomes useful"),
            growthRead: clean(identity.ritualPrompt, fallback: "Notice the pattern before obeying it"),
            compatibilityRead: "",
            strengths: strengths,
            shadows: shadows
        )
    }
}

// MARK: - Copy Builder

private extension PatternPageContent {
    static func oneLineRead(strength: String, shadow: String) -> String {
        "\(sentenceStartWithoutPeriod(strength)) is the gift. \(sentenceStartWithoutPeriod(shadow)) is the tell."
    }

    static func shadowRead(emotionalPattern: String, shadow: String) -> String {
        let source = clean(emotionalPattern, fallback: "")
        if !source.isEmpty {
            return "\(sentence(source)) Under pressure, \(shadow.lowercased()) can take over before the full picture lands."
        }

        return "\(sentenceStartWithoutPeriod(shadow)) is not the whole pattern. It is the part that gets loud under pressure."
    }

    static func connectionRead(love: String, friendship: String) -> String {
        let parts = [love, friendship]
            .map { clean($0, fallback: "") }
            .filter { !$0.isEmpty }
            .map(sentence)

        if parts.isEmpty {
            return "Connection works best with people who meet the real rhythm, not just the polished version"
        }

        return parts.joined(separator: " ")
    }

    static func workRead(_ value: String) -> String {
        let work = clean(value, fallback: "")
        if work.isEmpty {
            return "Work rewards timing, perception, and quiet authority"
        }

        return sentence(work)
    }

    static func growthRead(_ value: String) -> String {
        let growth = clean(value, fallback: "")
        if growth.isEmpty {
            return "Stay clear by noticing the pattern before you obey it"
        }

        return sentence(growth)
    }
}

// MARK: - Text Helpers

private extension PatternPageContent {
    static func signPart(id: String, index: Int, fallback: String) -> String {
        let parts = id.split(separator: "-").map(String.init)
        guard parts.indices.contains(index) else { return fallback }
        return parts[index].capitalized
    }

    static func clean(_ value: String?, fallback: String) -> String {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    static func cleanedList(_ values: [String], fallback: [String]) -> [String] {
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return cleaned.isEmpty ? fallback : cleaned
    }

    static func prioritizedList(primary: String, values: [String]) -> [String] {
        let cleanedPrimary = primary.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedValues = cleanedList(values, fallback: [])

        var result: [String] = []

        if !cleanedPrimary.isEmpty {
            result.append(cleanedPrimary)
        }

        for value in cleanedValues {
            if !result.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) {
                result.append(value)
            }
        }

        return result
    }

    static func sentence(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        if trimmed.hasSuffix("") || trimmed.hasSuffix("!") || trimmed.hasSuffix("?") {
            return trimmed
        }

        return "\(trimmed)"
    }

    static func sentenceStartWithoutPeriod(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        return trimmed.prefix(1).uppercased() + trimmed.dropFirst()
    }

    static func compactParagraph(_ value: String, fallback: String) -> String {
        let text = Self.clean(value, fallback: fallback)
        let firstSentence = text
            .split(whereSeparator: { ".!?".contains($0) })
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? text

        let words = firstSentence.split(separator: " ").prefix(14).map(String.init)
        guard !words.isEmpty else { return fallback }

        let line = words.joined(separator: " ")
        return line.hasSuffix("") ? line : line + ""
    }

    static func summaryLead(_ value: String) -> String {
        let sentence = value
            .split(whereSeparator: { ".!?".contains($0) })
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? value

        let words = sentence.split(separator: " ").prefix(10).map(String.init)
        let lead = words.joined(separator: " ")
        guard !lead.isEmpty else { return value }
        return lead.hasSuffix("") ? lead : lead + ""
    }
}
