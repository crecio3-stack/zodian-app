import SwiftUI

struct ConnectProfileDetailView: View {
    let profile: DeckProfile
    let isPremium: Bool
    let onPass: () -> Void
    let onLike: () -> Void
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                heroSection
                compatibilitySection
                detailSection(
                    title: "Essence",
                    content: profile.essence
                )
                detailSection(
                    title: "Connection Energy",
                    content: profile.connectionPrompt
                )
                detailSection(
                    title: "Why You Might Click",
                    content: profile.matchReasons.first?.detail ?? "\(profile.archetypeTitle) brings a distinct emotional rhythm that could either complement your energy beautifully or challenge you in the right ways."
                )

                detailSection(
                    title: "Potential Friction",
                    content: profile.frictionNote
                )

                detailSection(
                    title: "Intent",
                    content: profile.intent
                )

                if isPremium {
                    detailSection(
                        title: "Premium Compatibility Insight",
                        content: premiumInsight
                    )
                } else {
                    lockedPremiumSection
                }

                actionRow
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 24)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    // MARK: - Hero

    private var heroSection: some View {
        TarotCardContainer(style: .featured) {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image(profile.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: proxy.size.width,
                                height: proxy.size.height,
                                alignment: imageAlignment(for: profile.imageAnchor)
                            )
                            .clipped()
                    }

                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.04),
                            Color.black.opacity(0.12),
                            Color.black.opacity(0.28),
                            Color.black.opacity(0.82)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    LinearGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.08),
                            .clear,
                            ZD.Color.forest.opacity(0.12)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )

                    HStack(alignment: .top) {
                        Spacer()
                        compatibilityBadge
                    }
                    .padding(ZD.Spacing.m)
                    .frame(maxHeight: .infinity, alignment: .top)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(profile.name), \(profile.age)")
                            .font(ZD.Font.title())
                            .foregroundStyle(.white)

                        Text(profile.combinedSigns)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(.white.opacity(0.86))

                        Text(profile.archetypeTitle)
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.accent)
                    }
                    .padding(ZD.Spacing.m)
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.25), lineWidth: ZD.Stroke.thin)
                )

                Text("Explore the energy before deciding whether to save or like this match.")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Sections

    private var compatibilitySection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                Text("Compatibility Snapshot")
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                compatibilityMeter

                Text(snapshotText)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailSection(title: String, content: String) -> some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                Text(title.uppercased())
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(content)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var lockedPremiumSection: some View {
        ZStack {
            TarotCardContainer {
                VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                    Text("PREMIUM COMPATIBILITY INSIGHT")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)

                    Text(premiumInsight)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .blur(radius: 1.2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .fill(Color.black.opacity(0.42))
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ZD.Color.premium)

                        Text("Premium")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.premium)
                    }
                )
        }
    }

    // MARK: - Components

    private var actionRow: some View {
        HStack(spacing: ZD.Spacing.m) {
            IconCircleButton(systemName: "xmark", action: onPass)

            PrimaryButton(
                title: isPremium ? "Like Match" : "Like",
                action: onLike,
                icon: isPremium ? "sparkles" : "heart.fill",
                fullWidth: true
            )

            IconCircleButton(systemName: "bookmark", action: onSave)
        }
    }

    private var compatibilityBadge: some View {
        VStack(spacing: 4) {
            Text("\(profile.compatibilityScore)%")
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
                        .stroke(ZD.Color.accent.opacity(0.4), lineWidth: ZD.Stroke.thin)
                )
        )
        .zGoldGlow(active: true)
    }

    private var compatibilityMeter: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ZD.Color.cardAlt)

                    Capsule()
                        .fill(ZD.Gradient.gold)
                        .frame(width: proxy.size.width * CGFloat(profile.compatibilityScore) / 100)
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

    private var snapshotText: String {
        switch profile.compatibilityScore {
        case 90...100:
            return "Strong resonance. This connection is likely to feel immediate, magnetic, and emotionally legible."
        case 80..<90:
            return "Very promising. There is clear potential here with enough contrast to stay interesting."
        case 70..<80:
            return "Solid compatibility. This may unfold best through patience and curiosity."
        default:
            return "More complex than seamless, but complexity can still create a memorable dynamic."
        }
    }



    private var premiumInsight: String {
        if profile.compatibilityScore >= 90 {
            return "This pairing has unusually strong alignment across attraction, timing, and emotional reciprocity. Lean into directness."
        } else if profile.compatibilityScore >= 80 {
            return "This match benefits from intentional pacing. The chemistry is real, but trust will deepen the connection."
        } else {
            return "The potential here is less about instant ease and more about whether both of you can stay open without over-managing the dynamic."
        }
    }
}
