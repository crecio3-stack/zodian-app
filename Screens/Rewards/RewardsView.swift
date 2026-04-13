import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var heroTitleShimmer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                headerSection
                progressSection
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
                subtitle: "Consistency unlocks deeper access"
            )

            milestoneRow(
                title: "3-Day Streak",
                reward: "Extended reading discount unlocked",
                achieved: store.hasExtendedReadingDiscount
            )

            milestoneRow(
                title: "7-Day Streak",
                reward: "One-time +25 point bonus",
                achieved: store.unlockedRewards.contains("bonus_7_day_claimed")
            )

            milestoneRow(
                title: "14-Day Streak",
                reward: "Hidden archetype insight unlocked",
                achieved: store.hasHiddenInsightUnlocked
            )

            milestoneRow(
                title: "30-Day Streak",
                reward: "Premium trial access unlocked",
                achieved: store.hasPremiumTrialUnlocked
            )
        }
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
                title: "Point Rewards",
                subtitle: "Use points to unlock deeper insight"
            )

            rewardRow(
                title: "Extended Reading",
                cost: store.extendedReadingCost,
                description: store.hasExtendedReadingDiscount
                    ? "Your streak discount is active."
                    : "Unlock deeper love, work, and growth insights."
            )

            rewardRow(
                title: "Hidden Insight",
                cost: 0,
                description: store.hasHiddenInsightUnlocked
                    ? "Unlocked through your 14-day streak."
                    : "Locked until your 14-day streak."
            )

            rewardRow(
                title: "Premium Trial",
                cost: 0,
                description: store.hasPremiumTrialUnlocked
                    ? "Unlocked through your 30-day streak."
                    : "Locked until your 30-day streak."
            )
        }
    }

    private func rewardRow(title: String, cost: Int, description: String) -> some View {
        let canAfford = cost == 0 || store.points >= cost

        return TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                HStack {
                    Text(title)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Spacer()

                    if cost > 0 {
                        Text("\(cost) pts")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                    } else {
                        Text("Milestone")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                    }
                }

                Text(description)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)

                if !canAfford {
                    Text("Not enough points")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }
            }
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "Premium",
                subtitle: "Unlock the full Zodian experience"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                    Text(store.effectivePremiumAccess ? "Premium Access Active" : "Upgrade to Premium")
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.accent)

                    VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                        benefit("Full blueprint access")
                        benefit("Unlimited extended readings")
                        benefit("Future compatibility insights")
                        benefit("Priority new features")
                    }

                    PrimaryButton(
                        title: store.effectivePremiumAccess ? "Premium Active" : "Go Premium",
                        action: {
                            if !store.effectivePremiumAccess {
                                store.updatePremiumStatus(.premium)
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
            statOrb(value: "\(store.points)", label: "PTS")
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
            return "Your journey begins with your first reveal."
        } else if store.streak < 3 {
            return "Keep going. Your first unlock starts at 3 days."
        } else if store.streak < 7 {
            return "Nice. Your discount is active and the next unlock is close."
        } else if store.streak < 14 {
            return "Momentum is building. You’ve already earned bonus points."
        } else if store.streak < 30 {
            return "You’ve unlocked hidden insight. Keep pushing toward premium trial."
        } else {
            return "Your ritual is powerful. You’ve unlocked premium trial access."
        }
    }
}
