import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    
    @State private var isRevealing = false
    @State private var showMilestoneBanner = false
    @State private var milestoneMessage = ""
    
    @State private var todayReading: DailyReading?
    @State private var showFullReflection = false
    
    @State private var heroTitleShimmer = false
    @State private var revealedTitleShimmer = false
    
    @State private var concealedGlowBreathing = false
    
    @State private var dailyCardFlip: Double = 0
    
    private let dailyCardHeight: CGFloat = 540
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: ZD.Spacing.l) {
                    heroHeader
                    dailyRevealSection
                    quickActionsSection
                }
                .padding(.top, 28)
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.bottom, 24)
            }
            .background(
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
            )
            .overlay(alignment: .top) {
                if showMilestoneBanner {
                    milestoneBanner
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                hydrateTodayReadingIfNeeded()
                
                heroTitleShimmer = false
                revealedTitleShimmer = false
                concealedGlowBreathing = false
                
                withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                    heroTitleShimmer = true
                    revealedTitleShimmer = true
                }
                
                DispatchQueue.main.async {
                    concealedGlowBreathing = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header
    
    private var heroHeader: some View {
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
            
            homeCardOrnaments(showBottomMedallion: false)
                .opacity(0.16)
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    shimmeringGoldTitle(
                        greetingTitle,
                        font: ZD.Font.title(),
                        shimmerActive: heroTitleShimmer,
                        baseOpacity: 0.10
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.80)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ZD.Color.accent.opacity(0.9))
                        
                        Text(subtitleText)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
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
                }
                .layoutPriority(1)
                
                headerStatsCluster
                    .fixedSize()
            }
            .padding(ZD.Spacing.l)
        }
        .shadow(color: ZD.Color.shadow, radius: 18, x: 0, y: 10)
    }
    
    private var headerStatsCluster: some View {
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
    
    // MARK: - Daily Reveal
    
    private var dailyRevealSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(
                title: "Daily Reveal",
                subtitle: store.todayRevealed
                ? "Your guidance has been revealed for today."
                : "Reveal today’s guidance and earn points."
            )
            
            ZStack {
                concealedCard
                    .opacity(dailyCardFlip < 90 ? 1 : 0)
                
                revealedCard
                    .opacity(dailyCardFlip >= 90 ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(height: dailyCardHeight)
            .rotation3DEffect(.degrees(dailyCardFlip), axis: (x: 0, y: 1, z: 0), perspective: 0.85)
            .animation(.easeInOut(duration: 0.65), value: dailyCardFlip)
        }
    }
    
    private var concealedCard: some View {
        concealedRevealShell {
            ZStack {
                framedCardOrnaments(
                    cornerSize: 96,
                    cornerInsetX: 54,
                    cornerInsetY: 64,
                    medallionSize: 96,
                    medallionBottomInset: 24,
                    ornamentOpacity: 0.72
                )
                
                VStack(spacing: 22) {
                    Spacer(minLength: 12)
                    
                    Text("TODAY’S CARD")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(2.2)
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.68))
                    
                    ZStack {
                        Circle()
                            .fill(ZD.Color.accent.opacity(concealedGlowBreathing ? 0.10 : 0.04))
                            .frame(width: 108, height: 108)
                            .scaleEffect(concealedGlowBreathing ? 1.0 : 0.78)
                            .blur(radius: concealedGlowBreathing ? 8 : 2)
                            .opacity(concealedGlowBreathing ? 1.0 : 0.65)
                            .animation(
                                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                                value: concealedGlowBreathing
                            )
                        
                        Image("zodianMark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .blur(radius: 12)
                            .opacity(0.14)
                        
                        Image("zodianMark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .scaleEffect(concealedGlowBreathing ? 1.0 : 0.985)
                    .opacity(concealedGlowBreathing ? 1.0 : 0.94)
                    .animation(
                        .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                        value: concealedGlowBreathing
                    )
                    
                    VStack(spacing: 8) {
                        Text("Your card is waiting")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Reveal today’s message to earn points and protect your streak.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.muted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 320)
                    }
                    
                    PrimaryButton(
                        title: isRevealing ? "Revealing..." : "Reveal Today",
                        action: revealToday,
                        isDisabled: isRevealing,
                        icon: "sparkles",
                        fullWidth: true
                    )
                    .padding(.horizontal, 28)
                    .rotation3DEffect(.degrees(isRevealing ? 6 : 0), axis: (x: 1, y: 0, z: 0))
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.vertical, ZD.Spacing.l)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
    
    private var revealedCard: some View {
        concealedRevealShell {
            ZStack {
                framedCardOrnaments(
                    cornerSize: 82,
                    cornerInsetX: 48,
                    cornerInsetY: 52,
                    medallionSize: 64,
                    medallionBottomInset: 14,
                    ornamentOpacity: 0.30
                )

                VStack(alignment: .leading, spacing: 10) {
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 10) {
                            Text("Today’s Guidance")
                                .font(ZD.Font.heading())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            if let archetype = store.currentArchetype {
                                shimmeringGoldTitle(
                                    archetype.title,
                                    font: ZD.Font.title(),
                                    shimmerActive: revealedTitleShimmer,
                                    baseOpacity: 0.18
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            }

                            HStack {
                                Spacer()
                                moodPill
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(ZD.Color.success)
                            .padding(.top, 4)
                            .padding(.trailing, 8)
                    }

                    if let reading = todayReading {
                        VStack(alignment: .leading, spacing: 8) {
                            infoLabel("Theme")

                            Text(reading.theme)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)
                                .lineLimit(1)

                            infoLabel("Guidance")

                            Text(shortGuidanceText(from: reading.summary))
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .lineLimit(showFullReflection ? nil : 3)
                                .fixedSize(horizontal: false, vertical: true)

                            Button {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    showFullReflection.toggle()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(showFullReflection ? "Show Less" : "Show Reflection")
                                    Image(systemName: showFullReflection ? "chevron.up" : "chevron.down")
                                }
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.accent)
                            }
                            .buttonStyle(.plain)

                            if showFullReflection {
                                VStack(alignment: .leading, spacing: 8) {
                                    infoLabel("Reflection")

                                    Text(reflectionText(for: reading))
                                        .font(ZD.Font.body())
                                        .foregroundStyle(ZD.Color.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)

                                    if let archetype = store.currentArchetype {
                                        Text(archetype.tagline)
                                            .font(ZD.Font.caption())
                                            .foregroundStyle(ZD.Color.muted)
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }

                        Spacer(minLength: 0)
                            .frame(height: showFullReflection ? 12 : 0)

                        VStack(spacing: 8) {
                            NavigationLink(destination: ritualDestinationView) {
                                HStack(spacing: 8) {
                                    Image(systemName: store.ritualCompletedToday ? "checkmark.circle.fill" : "moon.stars.fill")
                                        .font(.system(size: 16, weight: .semibold))

                                    Text(ritualButtonTitle)
                                        .font(ZD.Font.body(.semibold))
                                        .lineLimit(1)
                                }
                                .foregroundStyle(store.ritualCompletedToday ? ZD.Color.muted : ZD.Color.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                        .fill(ZD.Color.cardAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                                .stroke(ZD.Color.border.opacity(0.45), lineWidth: ZD.Stroke.thin)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(todayReading == nil || store.currentArchetype == nil || store.ritualCompletedToday)

                            NavigationLink(destination: extendedReadingDestinationView) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16, weight: .semibold))

                                    Text(extendedReadingButtonTitle)
                                        .font(ZD.Font.body(.semibold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                }
                                .foregroundStyle(store.points >= store.extendedReadingCost ? ZD.Color.textPrimary : ZD.Color.muted)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                        .fill(ZD.Color.cardAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                                .stroke(ZD.Color.border.opacity(0.45), lineWidth: ZD.Stroke.thin)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(store.points < store.extendedReadingCost || todayReading == nil || store.currentArchetype == nil)

                            Text(bottomSupportText)
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                        }
                    } else {
                        Spacer()

                        Text("Your guidance is settling into place. Return in a moment.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)

                        Spacer()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 26)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
    private var moodPill: some View {
        HStack(spacing: 8) {
            Image(systemName: currentMood.symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(currentMood.tint)

            Text("Mood: \(currentMood.title)")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, ZD.Spacing.s)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                        .stroke(currentMood.tint.opacity(0.35), lineWidth: ZD.Stroke.thin)
                )
        )
        .fixedSize()
    }
    
    
    private var milestoneBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundStyle(ZD.Color.accent)
            
            Text(milestoneMessage)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, ZD.Spacing.m)
        .padding(.vertical, ZD.Spacing.s)
        .background(
            Capsule()
                .fill(ZD.Color.card)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(0.35), lineWidth: ZD.Stroke.thin)
                )
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            SectionHeader(title: "Quick Actions", subtitle: "Explore more of your identity")
            
            Button {
                store.selectedTab = .blueprint
            } label: {
                PremiumTileRow(
                    title: "Identity Blueprint",
                    subtitle: "Strengths, shadows, love style, growth.",
                    icon: "book.closed.fill"
                )
            }
            .buttonStyle(.plain)
            
            Button {
                store.selectedTab = .connect
            } label: {
                PremiumTileRow(
                    title: "Connect",
                    subtitle: "Compatibility and resonant energies.",
                    icon: "sparkles"
                )
            }
            .buttonStyle(.plain)
            
            Button {
                store.selectedTab = .profile
            } label: {
                PremiumTileRow(
                    title: store.premiumStatus == .free ? "Go Premium" : "Premium Active",
                    subtitle: store.premiumStatus == .free
                    ? "Unlock deeper readings and more insight."
                    : "Thanks for backing Zodian.",
                    icon: "crown.fill",
                    isPremium: store.premiumStatus != .free,
                    showPremiumBadge: false
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Destinations
    
    @ViewBuilder
    private var extendedReadingDestinationView: some View {
        if let reading = todayReading,
           let archetype = store.currentArchetype {
            ExtendedReadingView(reading: reading, archetype: archetype)
        } else {
            Text("Extended reading is not available yet.")
                .foregroundStyle(ZD.Color.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ZD.Color.bg.ignoresSafeArea())
        }
    }
    
    @ViewBuilder
    private var ritualDestinationView: some View {
        if let reading = todayReading,
           let archetype = store.currentArchetype {
            DailyRitualView(reading: reading, archetype: archetype)
        } else {
            Text("Daily ritual is not available yet.")
                .foregroundStyle(ZD.Color.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ZD.Color.bg.ignoresSafeArea())
        }
    }
    
    // MARK: - Helpers
    
    private var greetingTitle: String {
        let name = store.currentUser?.name ?? "Friend"
        return name.count > 10 ? name : "Welcome, \(name)"
    }
    
    private var subtitleText: String {
        guard let user = store.currentUser else { return "Your ritual begins here" }
        return "\(user.westernSign.displayName) • \(user.chineseSign.displayName)"
    }
    
    private var currentMood: DailyMood {
        if let reading = todayReading,
           let mappedMood = DailyMood(rawValue: reading.mood.lowercased()) {
            return mappedMood
        }
        return moodForToday()
    }
    
    private var ritualButtonTitle: String {
        store.ritualCompletedToday ? "Ritual Completed" : "Open Daily Ritual"
    }
    
    private var extendedReadingButtonTitle: String {
        "Extended Reading (\(store.extendedReadingCost) pts)"
    }
    
    private var bottomSupportText: String {
        if store.ritualCompletedToday {
            return "Today’s ritual is complete."
        } else if store.points < store.extendedReadingCost {
            return "Earn more points to unlock the extended reading."
        } else {
            return "You have enough points for the extended reading."
        }
    }
    
    private func revealToday() {
        guard !store.todayRevealed, !isRevealing else { return }
        guard let archetype = store.currentArchetype else { return }
        
        isRevealing = true
        showFullReflection = false
        
        feedbackSoft()
        
        withAnimation(.easeInOut(duration: 0.65)) {
            dailyCardFlip = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.325) {
            todayReading = DailyReadingGenerator.generate(for: archetype)
            
            let previousStreak = store.streak
            store.awardDailyRevealPoints(context: context, amount: 10)
            AnalyticsService.shared.track(
                .dailyRevealCompleted(
                    identityID: archetype.id,
                    streak: store.streak,
                    points: store.points
                )
            )
            showMilestoneIfNeeded(previousStreak: previousStreak, newStreak: store.streak)
            
            feedbackReveal()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            isRevealing = false
        }
    }
    
    private func hydrateTodayReadingIfNeeded() {
        dailyCardFlip = store.todayRevealed ? 180 : 0
        
        guard store.todayRevealed else { return }
        guard todayReading == nil else { return }
        guard let archetype = store.currentArchetype else { return }
        
        todayReading = DailyReadingGenerator.generate(for: archetype)
        showFullReflection = false
    }
    
    private func shortGuidanceText(from text: String) -> String {
        if text.count <= 95 { return text }
        let index = text.index(text.startIndex, offsetBy: 95)
        return String(text[..<index]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
    
    private func reflectionText(for reading: DailyReading) -> String {
        "Today favors a more intentional expression of \(reading.theme.lowercased()). Move slowly enough to notice what is aligning."
    }
    
    
    
    private func showMilestoneIfNeeded(previousStreak: Int, newStreak: Int) {
        let milestones = [3, 7, 14, 30]
        guard milestones.contains(newStreak), newStreak != previousStreak else { return }
        
        milestoneMessage = "\(newStreak)-day streak reached"
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            showMilestoneBanner = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showMilestoneBanner = false
            }
        }
    }
    
    private func moodForToday() -> DailyMood {
        let moods = DailyMood.allCases
        let seed = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return moods[seed % moods.count]
    }
    
    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func feedbackReveal() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func infoLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.accent)
    }
    
    // MARK: - Shared Styling
    
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
    
    
    private func concealedRevealShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.985),
                            ZD.Color.cardAlt.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.60, green: 0.45, blue: 0.13).opacity(0.70),
                            Color(red: 0.90, green: 0.79, blue: 0.44).opacity(0.70),
                            Color(red: 0.74, green: 0.58, blue: 0.20).opacity(0.70),
                            Color(red: 0.96, green: 0.88, blue: 0.60).opacity(0.70),
                            Color(red: 0.58, green: 0.42, blue: 0.11).opacity(0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
            
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.07),
                            ZD.Color.accent.opacity(0.08),
                            Color.clear,
                            ZD.Color.accent.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .padding(8)
            
            content()
        }
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: ZD.Color.shadow.opacity(0.55), radius: 22, x: 0, y: 12)
    }
    
    private func homeCardOrnaments(showBottomMedallion: Bool = true) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .opacity(0.82)
                    .position(x: 18, y: 18)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .scaleEffect(x: -1, y: 1)
                    .opacity(0.82)
                    .position(x: w - 18, y: 18)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .scaleEffect(x: 1, y: -1)
                    .opacity(0.82)
                    .position(x: 18, y: h - 18)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .scaleEffect(x: -1, y: -1)
                    .opacity(0.82)
                    .position(x: w - 18, y: h - 18)
                
                if showBottomMedallion {
                    Image("bottomMedallion")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .opacity(0.92)
                        .position(x: w / 2, y: h - 8)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func framedCardOrnaments(
        cornerSize: CGFloat = 96,
        cornerInsetX: CGFloat = 54,
        cornerInsetY: CGFloat = 64,
        medallionSize: CGFloat = 96,
        medallionBottomInset: CGFloat = 24,
        ornamentOpacity: Double = 0.72
    ) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: cornerSize, height: cornerSize)
                    .opacity(ornamentOpacity)
                    .position(x: cornerInsetX, y: cornerInsetY)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: cornerSize, height: cornerSize)
                    .scaleEffect(x: -1, y: 1)
                    .opacity(ornamentOpacity)
                    .position(x: w - cornerInsetX, y: cornerInsetY)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: cornerSize, height: cornerSize)
                    .scaleEffect(x: 1, y: -1)
                    .opacity(ornamentOpacity)
                    .position(x: cornerInsetX, y: h - cornerInsetY)
                
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: cornerSize, height: cornerSize)
                    .scaleEffect(x: -1, y: -1)
                    .opacity(ornamentOpacity)
                    .position(x: w - cornerInsetX, y: h - cornerInsetY)
                
                Image("bottomMedallion")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: medallionSize, height: medallionSize)
                    .opacity(ornamentOpacity)
                    .position(x: w / 2, y: h - medallionBottomInset)
            }
        }
        .allowsHitTesting(false)
    }
}
// MARK: - Supporting Types

enum DailyMood: String, CaseIterable, Codable {
    case clarity
    case magnetism
    case restraint
    case devotion
    case momentum
    case softness

    var title: String {
        switch self {
        case .clarity: return "Clarity"
        case .magnetism: return "Magnetism"
        case .restraint: return "Restraint"
        case .devotion: return "Devotion"
        case .momentum: return "Momentum"
        case .softness: return "Softness"
        }
    }

    var symbol: String {
        switch self {
        case .clarity: return "eye.fill"
        case .magnetism: return "sparkles"
        case .restraint: return "moon.fill"
        case .devotion: return "heart.fill"
        case .momentum: return "flame.fill"
        case .softness: return "cloud.fill"
        }
    }

    var tint: Color {
        switch self {
        case .clarity: return ZD.Color.accent
        case .magnetism: return ZD.Color.premium
        case .restraint: return ZD.Color.olive
        case .devotion: return ZD.Color.error.opacity(0.9)
        case .momentum: return ZD.Color.warning
        case .softness: return ZD.Color.textSecondary
        }
    }
}

#Preview("Home - Free") {
    let store = AppStore()
    store.onboardingComplete = true
    store.points = 20
    store.streak = 2
    store.updatePremiumStatus(.free)
    store.currentUser = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 631152000),
        westernSignRaw: "leo",
        chineseSignRaw: "dragon",
        archetypeId: "leo-dragon"
    )

    return HomeView()
        .environmentObject(store)
        .modelContainer(for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self, SavedDailyReading.self], inMemory: true)
        .preferredColorScheme(.dark)
}

#Preview("Home - Revealed") {
    let store = AppStore()
    store.onboardingComplete = true
    store.points = 140
    store.streak = 7
    store.updatePremiumStatus(.premium)
    store.lastRevealDate = Date()
    store.currentUser = UserProfile(
        name: "Ari",
        birthday: Date(timeIntervalSince1970: 915177600),
        westernSignRaw: "aries",
        chineseSignRaw: "rabbit",
        archetypeId: "aries-rabbit"
    )

    return HomeView()
        .environmentObject(store)
        .modelContainer(for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self, SavedDailyReading.self], inMemory: true)
        .preferredColorScheme(.dark)
}

#Preview("Home - Ritual Complete") {
    let store = AppStore()
    store.onboardingComplete = true
    store.points = 145
    store.streak = 7
    store.updatePremiumStatus(.premium)
    store.lastRevealDate = Date()
    store.lastRitualCompletionDate = Date()
    store.currentUser = UserProfile(
        name: "Ari",
        birthday: Date(timeIntervalSince1970: 915177600),
        westernSignRaw: "aries",
        chineseSignRaw: "rabbit",
        archetypeId: "aries-rabbit"
    )

    return HomeView()
        .environmentObject(store)
        .modelContainer(
            for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self, SavedDailyReading.self],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}
