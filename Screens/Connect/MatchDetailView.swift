//
//  MatchDetailView.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//

import SwiftUI
import SwiftData

struct MatchDetailView: View {
    let match: SavedMatch
    @Environment(\.dismiss) private var dismiss
    @Query private var savedMatches: [SavedMatch]

    private var westernSign: WesternZodiac? {
        WesternZodiac(rawValue: match.westernSignRaw)
    }

    private var chineseSign: ChineseZodiac? {
        ChineseZodiac(rawValue: match.chineseSignRaw)
    }

    private var matchStyle: MatchStyle? {
        MatchStyle(rawValue: match.matchStyleRaw)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                heroSection
                quickStatsSection
                compatibilitySection

                detailSection(
                    title: "Essence",
                    content: match.essence
                )

                detailSection(
                    title: "Connection Energy",
                    content: match.connectionPrompt
                )

                detailSection(
                    title: "Why You Clicked",
                    titleAccent: match.primaryReasonTitle,
                    content: match.primaryReasonDetail
                )

                detailSection(
                    title: "Potential Friction",
                    content: match.frictionNote
                )

                detailSection(
                    title: "Intent",
                    content: match.intent
                )

                conversationSection

                closingSection
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 32)
        }
        .background(backgroundView)
        .navigationTitle(match.name)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            dismissIfMatchWasRemoved()
        }
        .onChange(of: savedMatches.count) { _ in
            dismissIfMatchWasRemoved()
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.forest.opacity(0.12),
                        .clear
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: 500
                )
            )
            .ignoresSafeArea()
    }

    private func dismissIfMatchWasRemoved() {
        guard !savedMatches.contains(where: { $0.id == match.id }) else { return }
        dismiss()
    }

    // MARK: - Sections

    private var heroSection: some View {
        TarotCardContainer(style: .featured) {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image(match.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: proxy.size.width,
                                height: proxy.size.height,
                                alignment: imageAlignment(for: imageAnchor)
                            )
                            .clipped()
                    }

                    LinearGradient(
                        colors: [
                            .clear,
                            Color.black.opacity(0.14),
                            Color.black.opacity(0.32),
                            Color.black.opacity(0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ZD.Color.accent.opacity(0.08),
                                    .clear
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 8) {
                            Text(match.name)
                                .font(ZD.Font.title())
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            if let matchStyle {
                                styleChip(matchStyle.label)
                            }
                        }

                        Text(combinedSignsText)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(.white.opacity(0.86))

                        Text(match.archetypeTitle)
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.accent)
                            .lineLimit(2)
                    }
                    .padding(ZD.Spacing.m)

                    HStack {
                        Spacer()
                        compatibilityBadge
                    }
                    .padding(ZD.Spacing.m)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.25), lineWidth: ZD.Stroke.thin)
                )
                .shadow(
                    color: ZD.Color.accent.opacity(0.16),
                    radius: 16,
                    y: 8
                )

                Text(heroSummary)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var quickStatsSection: some View {
        ViewThatFits(in: .vertical) {
            HStack(spacing: 10) {
                quickStatPill(
                    title: match.intent,
                    systemName: "sparkles"
                )

                if let matchStyle {
                    quickStatPill(
                        title: matchStyle.label,
                        systemName: "heart.fill"
                    )
                }

                quickStatPill(
                    title: "\(match.compatibilityScore)% Match",
                    systemName: "chart.bar.fill"
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                quickStatPill(
                    title: match.intent,
                    systemName: "sparkles"
                )

                if let matchStyle {
                    quickStatPill(
                        title: matchStyle.label,
                        systemName: "heart.fill"
                    )
                }

                quickStatPill(
                    title: "\(match.compatibilityScore)% Match",
                    systemName: "chart.bar.fill"
                )
            }
        }
    }

    private var compatibilitySection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                Text("Compatibility Snapshot")
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                compatibilityMeter

                Text(compatibilitySummary)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailSection(
        title: String,
        titleAccent: String? = nil,
        content: String
    ) -> some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                Text(title.uppercased())
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                if let titleAccent {
                    Text(titleAccent)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                }

                Text(content)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var closingSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                Text("MATCH ENERGY")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(closingSummary)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var conversationSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                Text("NEXT STEP")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("If the energy still feels right, open a conversation and see how the chemistry lands in real time.")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    ChatView(match: match)
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .semibold))

                        Text("Start Conversation")
                            .font(ZD.Font.button())
                            .tracking(0.3)

                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, ZD.Spacing.m)
                    .padding(.vertical, ZD.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                            .fill(ZD.Gradient.gold)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                            .stroke(ZD.Color.accentSoft.opacity(0.45), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.glow, radius: 14, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Components

    private var compatibilityBadge: some View {
        VStack(spacing: 4) {
            Text("\(match.compatibilityScore)%")
                .font(ZD.Font.heading())
                .foregroundStyle(ZD.Color.textPrimary)

            Text("Match")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(.horizontal, ZD.Spacing.m)
        .padding(.vertical, ZD.Spacing.s)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(0.35), lineWidth: ZD.Stroke.thin)
                )
        )
        .zGoldGlow(active: true)
        .fixedSize()
    }

    private func styleChip(_ text: String) -> some View {
        Text(text)
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ZD.Gradient.gold)
            )
            .fixedSize()
    }

    private func quickStatPill(title: String, systemName: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                    .stroke(ZD.Color.border.opacity(0.4), lineWidth: ZD.Stroke.thin)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var compatibilityMeter: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ZD.Color.cardAlt)

                    Capsule()
                        .fill(ZD.Gradient.gold)
                        .frame(width: proxy.size.width * CGFloat(match.compatibilityScore) / 100)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Low")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                Spacer()

                Text("High")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
            }
        }
    }

    // MARK: - Helpers

    private var combinedSignsText: String {
        let western = westernSign?.displayName ?? "—"
        let chinese = chineseSign?.displayName ?? "—"
        return "\(western) • \(chinese)"
    }

    private var imageAnchor: UnitPoint {
        switch match.imageAnchorRaw {
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

    private func imageAlignment(for anchor: UnitPoint) -> Alignment {
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

    // MARK: - Derived Text

    private var heroSummary: String {
        "This connection stood out for a reason. Revisit the chemistry, emotional rhythm, and deeper dynamic that made this match worth saving."
    }

    private var compatibilitySummary: String {
        switch match.compatibilityScore {
        case 90...100:
            return "This is a high-alignment match with strong emotional and energetic resonance. The connection is likely to feel immediate and memorable."
        case 80..<90:
            return "There is real promise here. The balance of comfort and intrigue gives this connection strong potential."
        case 70..<80:
            return "This match has a steady foundation and may deepen with time, curiosity, and consistent effort."
        default:
            return "This connection may feel more complex than easy, but that tension can still create something meaningful."
        }
    }

    private var closingSummary: String {
        if match.compatibilityScore >= 85 {
            return "This match carries strong momentum. It has the kind of energy that can feel rare when timing, curiosity, and openness all line up."
        } else if match.compatibilityScore >= 70 {
            return "This connection has potential when allowed to unfold naturally. The attraction may build through consistency rather than speed."
        } else {
            return "This match may be less about immediate ease and more about intrigue, contrast, and what each of you brings out in the other."
        }
    }
}

#Preview {
    NavigationStack {
        MatchDetailView(
            match: SavedMatch(
                name: "Selene",
                archetypeId: "libra-snake",
                archetypeTitle: "The Velvet Dagger",
                westernSignRaw: "libra",
                chineseSignRaw: "snake",
                compatibilityScore: 92,
                matchStyleRaw: "magnetic",
                essence: "Elegant, observant, and difficult to forget.",
                connectionPrompt: "A connection with strong chemistry and emotional intelligence.",
                frictionNote: "Both of you may hold back at first, which can slow momentum.",
                intent: "Something intentional",
                imageName: "selene",
                imageAnchorRaw: "top",
                primaryReasonTitle: "Magnetic Contrast",
                primaryReasonDetail: "Differences create intrigue, tension, and chemistry."
            )
        )
    }
    .preferredColorScheme(.dark)
}
