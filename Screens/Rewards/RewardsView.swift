import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var heroTitleShimmer = false
    @State private var showPremiumSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                headerSection
                progressSection
                pointsSection
                rewardsSection
                premiumSection
            }
            .padding(.top, 28)
            .padding(.horizontal, ZD.Spacing.l)
            .padding(.bottom, 24)
        }
        .background(rewardsBackground)
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumRewardsSheet(source: "rewards")
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
        }
        .onAppear {
            heroTitleShimmer = false
            withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                heroTitleShimmer = true
            }
        }
    }

    private var headerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.96),
                            ZD.Color.cardAlt.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10),
                                    ZD.Color.accent.opacity(0.12),
                                    .clear,
                                    ZD.Color.accent.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                        .padding(1)
                )

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(0.10),
                    .clear
                ],
                center: .leading,
                startRadius: 10,
                endRadius: 180
            )
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    shimmeringGoldTitle(
                        "Rewards\nProgress",
                        font: ZD.Font.title(),
                        shimmerActive: heroTitleShimmer,
                        baseOpacity: 0.10
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ZD.Color.accent.opacity(0.9))

                        Text(nextRewardSubtitle)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.9))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(ZD.Color.cardAlt.opacity(0.9))
                            .overlay(
                                Capsule()
                                    .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(progressMessage)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)

                rewardsStatsCluster
                    .fixedSize()
            }
            .padding(ZD.Spacing.l)
        }
        .shadow(color: ZD.Color.shadow, radius: 18, x: 0, y: 10)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "Milestones",
                subtitle: "Consistency unlocks real access"
            )

            milestoneRow(
                title: "7-Day Streak",
                reward: "One-time +25 point bonus",
                achieved: store.unlockedRewards.contains("bonus_7_day_claimed")
            )

            milestoneRow(
                title: "14-Day Streak",
                reward: "Premium Preview unlocked for today",
                achieved: store.hasRewardPreviewUnlocked
            )

            milestoneRow(
                title: "30-Day Streak",
                reward: "Reward-based premium access unlocked",
                achieved: store.hasPremiumTrialUnlocked
            )
        }
    }

    private var pointsSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "Spend Points",
                subtitle: "Turn earned points into one-day access"
            )

            premiumSpendCard {
                VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Premium Preview for Today")
                                .font(ZD.Font.heading())
                                .foregroundStyle(ZD.Color.textPrimary)

                            Text("Open Connect without the free limit for the rest of today")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Text("50 points")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(ZD.Color.cardAlt.opacity(0.90))
                                    .overlay(
                                        Capsule()
                                            .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                                    )
                            )
                    }

                    HStack(spacing: ZD.Spacing.s) {
                        benefit("Earned from Daily Reveal")
                        benefit("Use only when you want it")
                    }

                    Button {
                        let redeemed = store.redeemPremiumPreviewWithPoints(cost: 50)
                        guard redeemed else { return }
                        store.selectedTab = .connect
                    } label: {
                        PrimaryButtonLabel(
                            title: store.effectivePremiumAccess ? "Preview already active" : "Use 50 points"
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(store.effectivePremiumAccess || store.points < 50)

                    Text(store.effectivePremiumAccess
                         ? "Premium access is already active"
                         : (store.points < 50
                            ? "Earn 50 points to unlock this preview"
                            : "This spends 50 points and opens Connect for the rest of today"))
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.muted)

                    Text("Points are the spendable currency for a one-day Premium Preview")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.8))
                }
            }
        }
    }

    private func premiumSpendCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(ZD.Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.96),
                                ZD.Color.cardAlt.opacity(0.90),
                                ZD.Color.card.opacity(0.94)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RadialGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.10),
                                .clear
                            ],
                            center: .topLeading,
                            startRadius: 20,
                            endRadius: 240
                        )
                        .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ZD.Color.accent.opacity(0.34),
                                        ZD.Color.border.opacity(0.22),
                                        ZD.Color.accent.opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: ZD.Stroke.thin
                            )
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.34), radius: 16, x: 0, y: 10)
                    .shadow(color: ZD.Color.glow.opacity(0.10), radius: 18, x: 0, y: 8)
            )
    }

    private func milestoneRow(title: String, reward: String, achieved: Bool) -> some View {
        TarotCardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(reward)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                }

                Spacer()

                Image(systemName: achieved ? "checkmark.seal.fill" : "circle")
                    .foregroundStyle(achieved ? ZD.Color.success : ZD.Color.muted)
            }
        }
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "What Rewards Open",
                subtitle: "Only live access and real bonuses"
            )

            rewardRow(
                title: "7-Day Bonus",
                badge: "+25 pts",
                description: "A one-time point bonus that lands automatically when your streak hits 7 days"
            )

            rewardRow(
                title: "14-Day Preview",
                badge: "Preview",
                description: "A streak-earned Premium Preview that opens the fuller Connect experience for the rest of the day"
            )

            rewardRow(
                title: "30-Day Reward Access",
                badge: "Access",
                description: "Reward-based premium access that keeps Connect open without the daily free limit"
            )
        }
    }

    private func rewardRow(title: String, badge: String, description: String) -> some View {
        return TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                HStack {
                    Text(title)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Spacer()

                    Text(badge)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                }

                Text(description)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
            }
        }
    }

    private struct PrimaryButtonLabel: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(ZD.Color.accent))
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "Premium",
                subtitle: "Connect-first access and streak unlocks"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                    Text(store.effectivePremiumAccess ? "Premium Access Active" : "Premium Preview")
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.accent)

                    if store.hasActivePremiumPreview {
                        Text(store.premiumPreviewStatusLine)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.muted)
                    }

                    VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                        benefit("More Connect profiles in a session")
                        benefit("The full Connect experience past the free limit")
                        benefit("Reward-based access through streak milestones")
                        benefit("Temporary Premium Preview when you want to test it")
                    }

                    PrimaryButton(
                        title: store.hasActivePremiumPreview ? "Preview Active" : (store.effectivePremiumAccess ? "Premium Active" : "View Access"),
                        action: {
                            if !store.effectivePremiumAccess {
                                showPremiumSheet = true
                            }
                        },
                        isDisabled: store.effectivePremiumAccess,
                        icon: "crown.fill",
                        fullWidth: true
                    )
                }
            }
        }
    }

    private func benefit(_ text: String) -> some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(ZD.Color.accent)
            Text(text)
                .foregroundStyle(ZD.Color.textSecondary)
        }
        .font(ZD.Font.body())
    }

    private var rewardsBackground: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.card.opacity(0.22),
                        .clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 500
                )
            )
            .ignoresSafeArea()
    }

    private var rewardsStatsCluster: some View {
        HStack(spacing: 10) {
            statOrb(value: "\(store.points)", label: "POINTS")
            statOrb(value: "\(store.streak)", label: "DAY")
        }
    }

    private func statOrb(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(ZD.Color.muted.opacity(0.85))
        }
        .frame(width: 48, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private func shimmeringGoldTitle(
        _ text: String,
        font: Font,
        shimmerActive: Bool,
        baseOpacity: Double = 0.18
    ) -> some View {
        ZStack {
            Text(text)
                .font(font)
                .foregroundStyle(ZD.Color.accent.opacity(baseOpacity))
                .blur(radius: 10)

            Text(text)
                .font(font)
                .foregroundStyle(cardGoldStroke)

            Text(text)
                .font(font)
                .foregroundStyle(.clear)
                .overlay(
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white.opacity(0.04),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.95),
                                        ZD.Color.accent.opacity(0.72),
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.04),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 140, height: proxy.size.height + 12)
                            .rotationEffect(.degrees(12))
                            .offset(x: shimmerActive ? proxy.size.width + 160 : -160)
                    }
                )
                .mask(
                    Text(text)
                        .font(font)
                )
                .allowsHitTesting(false)
        }
        .compositingGroup()
    }

    private var cardGoldStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.60, green: 0.45, blue: 0.13),
                Color(red: 0.90, green: 0.79, blue: 0.44),
                Color(red: 0.74, green: 0.58, blue: 0.20),
                Color(red: 0.96, green: 0.88, blue: 0.60),
                Color(red: 0.58, green: 0.42, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var nextRewardSubtitle: String {
        if store.daysUntilNextReward == 0 {
            return "A new unlock is ready now"
        } else if store.daysUntilNextReward == 1 {
            return "1 more day to the next unlock"
        } else {
            return "\(store.daysUntilNextReward) more days to the next unlock"
        }
    }

    private var progressMessage: String {
        if store.streak == 0 {
            return "Your journey begins with your first reveal"
        } else if store.streak < 7 {
            return "Keep going. Your first real bonus lands at 7 days."
        } else if store.streak < 14 {
            return "Momentum is building. You’ve already earned bonus points."
        } else if store.streak < 30 {
            return "Your preview reward is unlocked. Keep pushing toward lasting access."
        } else {
            return "Your ritual is powerful. Reward-based premium access is unlocked."
        }
    }
}
