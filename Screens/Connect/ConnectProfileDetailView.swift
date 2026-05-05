import SwiftUI

struct ConnectProfileDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let profile: DeckProfile
    let isPremium: Bool
    let onPass: () -> Void
    let onLike: () -> Void

    @State private var showPremiumSheet = false

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(profile: profile)
    }

    private var compatibilityExplanation: String {
        if let deeperReason = profile.matchReasons.dropFirst().first?.detail,
           !deeperReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return deeperReason
        }

        if let primaryReason = profile.matchReasons.first?.detail,
           !primaryReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return primaryReason
        }

        if !profile.connectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return profile.connectionPrompt
        }

        return presentation.compatibilitySummaryShort
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                compatibilitySection
                detailSection(
                    title: "How they describe themselves",
                    content: profile.essence
                )
                if !profile.signals.isEmpty {
                    signalsSection(profile.signals)
                }
                detailSection(
                    title: "Why this connection fits",
                    content: compatibilityExplanation
                )
                detailSection(
                    title: "Where this may stretch",
                    content: profile.frictionNote
                )
                detailSection(
                    title: "What they are looking for",
                    content: profile.intent
                )

                if isPremium {
                    detailSection(
                        title: "Deeper connection",
                        content: presentation.compatibilitySummaryPremium
                    )
                } else {
                    lockedPremiumSection
                }

                actionRow
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 28)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumRewardsSheet(source: "connect_detail")
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
        }
        .preferredColorScheme(.dark)
    }

    private var heroSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 14) {
                ZStack(alignment: .bottomLeading) {
                    GeometryReader { proxy in
                        Image(profile.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: proxy.size.width,
                                height: proxy.size.height,
                                alignment: ConnectPresentation.imageAlignment(for: profile.imageAnchor)
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
                            .font(.system(size: 33, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text(profile.combinedSigns)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(1.2)

                        Text(profile.archetypeTitle)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(Color(red: 0.93, green: 0.83, blue: 0.63))
                    }
                    .padding(ZD.Spacing.m)
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.25), lineWidth: ZD.Stroke.thin)
                )

                Text("This is worth a closer look")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var compatibilitySection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Connection read")
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                compatibilityMeter

                Text(presentation.compatibilitySummaryShort)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailSection(title: String, content: String) -> some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 6) {
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

    private func signalsSection(_ signals: [ConnectProfileSignal]) -> some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Text("Signals")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(signals.indices, id: \.self) { index in
                        let signal = signals[index]
                        VStack(alignment: .leading, spacing: 4) {
                            Text(signal.prompt)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)

                            Text(refinedSignalResponse(signal.response))
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func refinedSignalResponse(_ response: String) -> String {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)

        switch trimmed.lowercased() {
        case "i change my mind":
            return "i change my mind a lot"
        default:
            return trimmed
        }
    }

    private var lockedPremiumSection: some View {
        Button {
            showPremiumSheet = true
        } label: {
            ZStack {
                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DEEPER CONNECTION")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)

                        Text(presentation.compatibilitySummaryPremium)
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

                            Text("Unlock deeper connection")
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.premium)
                        }
                    )
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
        .accessibilityLabel("Unlock deeper connection")
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            detailDockOrb(
                systemName: "arrow.uturn.backward",
                accessibilityLabel: "Close profile",
                action: { dismiss() }
            )

            detailDockOrb(
                systemName: "xmark",
                accessibilityLabel: "Pass on profile",
                role: .pass,
                action: onPass
            )

            detailDockOrb(
                systemName: "sparkles",
                accessibilityLabel: "Like profile",
                role: .like,
                action: onLike
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.88),
                            ZD.Color.cardAlt.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: ZD.Stroke.thin)
                )
                .shadow(color: ZD.Color.glow.opacity(0.08), radius: 18, y: 10)
        )
        .frame(maxWidth: .infinity)
    }

    private enum DetailDockRole {
        case neutral
        case pass
        case like
    }

    private func detailDockOrb(
        systemName: String,
        accessibilityLabel: String,
        role: DetailDockRole = .neutral,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(role == .like ? Color.black : ZD.Color.textPrimary.opacity(role == .pass ? 0.95 : 0.72))
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(detailDockFill(for: role))
                        .overlay(
                            Circle()
                                .stroke(detailDockStroke(for: role), lineWidth: ZD.Stroke.thin)
                        )
                )
                .shadow(
                    color: detailDockShadow(for: role),
                    radius: role == .neutral ? 4 : 10,
                    y: role == .neutral ? 2 : 5
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func detailDockFill(for role: DetailDockRole) -> AnyShapeStyle {
        switch role {
        case .neutral:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        ZD.Color.cardAlt.opacity(0.44),
                        ZD.Color.card.opacity(0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .pass:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.86, green: 0.20, blue: 0.18),
                        Color(red: 0.48, green: 0.07, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .like:
            return AnyShapeStyle(ZD.Gradient.gold)
        }
    }

    private func detailDockStroke(for role: DetailDockRole) -> Color {
        switch role {
        case .neutral:
            return Color.white.opacity(0.18)
        case .pass:
            return Color.white.opacity(0.20)
        case .like:
            return ZD.Color.accent.opacity(0.24)
        }
    }

    private func detailDockShadow(for role: DetailDockRole) -> Color {
        switch role {
        case .neutral:
            return Color.clear
        case .pass:
            return Color(red: 0.86, green: 0.20, blue: 0.18).opacity(0.18)
        case .like:
            return ZD.Color.glow
        }
    }

    private var compatibilityBadge: some View {
        VStack(spacing: 4) {
            Text("\(profile.compatibilityScore)%")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(Color(red: 0.98, green: 0.91, blue: 0.72))

            Text(presentation.compatibilityBadgeLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.54))
                .tracking(1.0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            ZD.Color.cardAlt.opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.89, green: 0.77, blue: 0.52).opacity(0.28), lineWidth: ZD.Stroke.thin)
                )
        )
        .shadow(color: ZD.Color.accent.opacity(0.12), radius: 10, y: 4)
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
}
