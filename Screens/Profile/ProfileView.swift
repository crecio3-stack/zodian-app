import SwiftUI
import SwiftData
import UIKit
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @Query(sort: \SavedDailyReading.createdAt, order: .reverse) private var savedReadings: [SavedDailyReading]
    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]
    @Query(sort: \ConnectUserProfile.updatedAt, order: .reverse) private var connectProfiles: [ConnectUserProfile]

    @State private var showPremiumSheet = false
    @State private var showResetAlert = false
    @State private var showResetConnectAlert = false
    @State private var showResetTodayRevealAlert = false
    @State private var showConnectProfileEditor = false
    @State private var animatedProgress: Double = 0
    @State private var heroTitleShimmer = false
    @State private var resolvedIdentityContent: ZodiacIdentityContent?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    connectHubSection
                    blueprintHubSection
                    progressHubSection
                    archiveHubSection
                    settingsHubSection
                    developerSection
                }
                .padding(.top, 14)
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.bottom, 128)
            }
            .background(profileBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPremiumSheet) {
                PremiumRewardsSheet(source: "profile")
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showConnectProfileEditor) {
                NavigationStack {
                    ConnectProfileEditorView()
                        .environmentObject(store)
                        .preferredColorScheme(.dark)
                }
                .presentationDetents([.large, .fraction(0.92)])
                .presentationDragIndicator(.visible)
            }
            .alert("Reset onboarding?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    showPremiumSheet = false
                    showConnectProfileEditor = false
                    store.resetOnboardingExperience(context: context)
                }
            } message: {
                Text("This will clear your saved profile, readings, points, streak, matches, and return you to onboarding.")
            }
            .alert("Reset Connect history?", isPresented: $showResetConnectAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    showPremiumSheet = false
                    store.resetConnectHistory(context: context)
                }
            } message: {
                Text("This will remove saved matches and passed profiles, but keep the rest of your app data.")
            }
            .alert("Reset daily reveal?", isPresented: $showResetTodayRevealAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    store.resetTodayRevealForDebug(context: context)
                }
            } message: {
                Text("This will reset the Home tab’s Daily Reveal card back to its unrevealed state for testing.")
            }
            .onAppear {
                refreshIdentityContent()
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedProgress = store.nextRewardProgress
                }

                heroTitleShimmer = false
                withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                    heroTitleShimmer = true
                }
            }
            .onChange(of: identityLookupKey) { _, _ in
                refreshIdentityContent()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var profileBackground: some View {
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(0.14),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.06),
                        .clear
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: 420
                )
            )
            .ignoresSafeArea()
    }

    // MARK: - Hero

    private var heroSection: some View {
        profileHeroCard
    }

    private var profileHeroCard: some View {
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

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    shimmeringGoldTitle(
                        profileGreetingTitle,
                        font: ZD.Font.title(),
                        shimmerActive: heroTitleShimmer,
                        baseOpacity: 0.10
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ZD.Color.accent.opacity(0.9))

                        Text(currentCombinedSigns)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.92))
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

                    membershipPillInline
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                profileStatsCluster
                    .fixedSize()
            }
            .padding(ZD.Spacing.l)
        }
        .shadow(color: ZD.Color.shadow, radius: 18, x: 0, y: 10)
    }

    private var profileStatsCluster: some View {
        VStack(spacing: 10) {
            profileAvatarTile

            HStack(spacing: 10) {
                statOrb(value: "\(store.points)", label: "PTS")
                statOrb(value: "\(store.streak)", label: "DAY")
            }
        }
    }

    private var profileAvatarTile: some View {
        Group {
            if let image = connectProfileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(ZD.Color.cardAlt)

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(ZD.Color.accent.opacity(0.75))
                }
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ZD.Color.accent.opacity(0.14), lineWidth: 1)
        )
    }

    private var membershipPillInline: some View {
        HStack(spacing: 6) {
            Image(systemName: store.effectivePremiumAccess ? "crown.fill" : "moon.stars.fill")
                .font(.system(size: 12, weight: .semibold))

            Text(store.effectivePremiumAccess ? "Premium" : "Free")
                .font(ZD.Font.badge())
        }
        .foregroundStyle(store.effectivePremiumAccess ? Color.black : Color.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    store.effectivePremiumAccess
                    ? AnyShapeStyle(ZD.Gradient.gold)
                    : AnyShapeStyle(ZD.Color.cardAlt.opacity(0.95))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            store.effectivePremiumAccess
                            ? Color.clear
                            : ZD.Color.accent.opacity(0.18),
                            lineWidth: 1
                        )
                )
        )
        .fixedSize()
    }

    private var profileGreetingTitle: String {
        let name = store.currentUser?.name ?? "Friend"
        return "Welcome,\n\(name)"
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

    // MARK: - Sections

    private var connectHubSection: some View {
        sectionBlock(
            title: "Connect Profile",
            subtitle: "How you appear to potential connections"
        ) {
            Button {
                showConnectProfileEditor = true
            } label: {
                hubCard(
                    title: "Your Connect Profile",
                    subtitle: connectProfileSummary,
                    icon: "person.crop.square.fill",
                    accent: ZD.Color.accent
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var blueprintHubSection: some View {
        sectionBlock(
            title: "Identity Blueprint",
            subtitle: "Your deeper pattern and hidden layers"
        ) {
            NavigationLink {
                BlueprintHubStubView(
                    archetypeTitle: zodiacIdentityContent?.title ?? "The Hidden Pattern",
                    tagline: zodiacIdentityContent?.tagline ?? "A pattern still unfolding.",
                    identitySummary: zodiacIdentityContent?.identitySummary ?? "Your deeper blueprint is still unfolding.",
                    mantra: zodiacIdentityContent?.mantra ?? "I trust the deeper pattern unfolding within me.",
                    hiddenInsightUnlocked: store.hasHiddenInsightUnlocked,
                    combinedSigns: currentCombinedSigns,
                    birthdayText: birthdayText
                )
            } label: {
                hubCard(
                    title: zodiacIdentityContent?.title ?? "The Hidden Pattern",
                    subtitle: zodiacIdentityContent?.tagline ?? "A pattern still unfolding.",
                    icon: "sparkles.rectangle.stack.fill",
                    accent: ZD.Color.accent
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var progressHubSection: some View {
        sectionBlock(
            title: "Progress",
            subtitle: "Streaks, points, and what unlocks next"
        ) {
            TarotCardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Next Unlock")
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.muted)

                            Text(store.nextRewardTitle)
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.accent)
                                .lineLimit(2)
                                .minimumScaleFactor(0.84)

                            Text(store.nextRewardSubtitle)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.86)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 8)

                        Text(store.daysUntilNextReward == 0 ? "Ready" : "\(store.daysUntilNextReward)d left")
                            .font(ZD.Font.badge())
                            .foregroundStyle(ZD.Color.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(ZD.Color.cardAlt)
                                    .overlay(
                                        Capsule()
                                            .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                                    )
                            )
                            .fixedSize()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(ZD.Color.cardAlt)

                                Capsule()
                                    .fill(ZD.Gradient.gold)
                                    .frame(width: max(proxy.size.width * animatedProgress, 12))
                            }
                        }
                        .frame(height: 10)

                        HStack {
                            Text(progressCaption)
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)

                            Spacer()

                            Text("\(Int(animatedProgress * 100))%")
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.accent)
                        }
                    }

                    NavigationLink {
                        RewardsView()
                    } label: {
                        hubCTA(title: "View Rewards", icon: "arrow.right")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var archiveHubSection: some View {
        sectionBlock(
            title: "Archive",
            subtitle: "Your saved readings and connections"
        ) {
            VStack(spacing: 8) {
                NavigationLink {
                    PlaceholderDetailView(title: "Reading Archive", bodyText: "Archive coming soon")
                } label: {
                    hubCard(
                        title: "Reading Archive",
                        subtitle: savedReadings.isEmpty
                            ? "No saved readings yet."
                            : "\(savedReadings.count) saved reading\(savedReadings.count == 1 ? "" : "s")",
                        icon: "book.closed.fill",
                        accent: ZD.Color.accent
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    MatchesView()
                } label: {
                    hubCard(
                        title: "Matches",
                        subtitle: savedMatches.isEmpty
                            ? "No saved matches yet."
                            : "\(savedMatches.count) saved match\(savedMatches.count == 1 ? "" : "es")",
                        icon: "heart.fill",
                        accent: ZD.Color.error.opacity(0.9)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var settingsHubSection: some View {
        sectionBlock(
            title: "Settings",
            subtitle: "Account, privacy, app preferences, and support"
        ) {
            settingsContainer {
                NavigationLink {
                    PlaceholderDetailView(title: "Account", bodyText: "Account settings coming soon")
                } label: {
                    settingsRow(
                        title: "Account",
                        subtitle: "Name, birthday, login, and credentials",
                        icon: "person.crop.circle"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    PlaceholderDetailView(title: "Notifications", bodyText: "Notification settings coming soon")
                } label: {
                    settingsRow(
                        title: "Notifications",
                        subtitle: "Daily reminders and alerts",
                        icon: "bell.badge.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    PlaceholderDetailView(title: "Privacy", bodyText: "Privacy settings coming soon")
                } label: {
                    settingsRow(
                        title: "Privacy",
                        subtitle: "Profile visibility and controls",
                        icon: "lock.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                Button {
                    showPremiumSheet = true
                } label: {
                    settingsRow(
                        title: "Membership",
                        subtitle: "Premium and rewards",
                        icon: "crown.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    PlaceholderDetailView(title: "Support", bodyText: "Support coming soon")
                } label: {
                    settingsRow(
                        title: "Support",
                        subtitle: "Help, feedback, and legal",
                        icon: "questionmark.circle.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var developerSection: some View {
        sectionBlock(
            title: "Developer Tools",
            subtitle: "Testing-only controls"
        ) {
            settingsContainer {
                compactDeveloperRow(
                    title: "Reset Daily Reveal",
                    icon: "rectangle.on.rectangle",
                    tint: ZD.Color.accent
                ) {
                    showResetTodayRevealAlert = true
                }

                dividerLine

                compactDeveloperRow(
                    title: "Reset Connect",
                    icon: "heart.slash",
                    tint: ZD.Color.warning
                ) {
                    showResetConnectAlert = true
                }

                dividerLine

                compactDeveloperRow(
                    title: "Reset Onboarding",
                    icon: "arrow.counterclockwise",
                    tint: ZD.Color.error
                ) {
                    showResetAlert = true
                }
            }
        }
    }

    // MARK: - Shared Layout

    private func sectionBlock<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(
                title: title,
                subtitle: subtitle
            )

            content()
        }
    }

    private func settingsContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        TarotCardContainer {
            VStack(spacing: 0) {
                content()
            }
        }
    }

    // MARK: - Shared UI

    private func hubCard(title: String, subtitle: String, icon: String, accent: Color) -> some View {
        TarotCardContainer {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)

                    Text(subtitle)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZD.Color.muted)
            }
            .frame(minHeight: 68)
        }
    }

    private func settingsRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.10))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted.opacity(0.85))
                    .padding(.top, -1)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 2)
    }

    private func compactDeveloperRow(
        title: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.12))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                }

                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ZD.Color.muted)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 2)
        }
        .buttonStyle(.plain)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(ZD.Color.border.opacity(0.24))
            .frame(height: 1)
    }

    // MARK: - Helpers

    private var currentArchetype: Archetype? {
        store.currentArchetype
    }

    private var zodiacIdentityContent: ZodiacIdentityContent? {
        resolvedIdentityContent
    }

    private var identityLookupKey: String {
        guard let user = store.currentUser else { return "no-user" }
        return "\(user.westernSignRaw)|\(user.chineseSignRaw)"
    }

    private var currentCombinedSigns: String {
        guard let user = store.currentUser else { return "—" }
        return "\(user.westernSign.displayName) • \(user.chineseSign.displayName)"
    }

    private var birthdayText: String {
        guard let birthday = store.currentUser?.birthday else { return "—" }
        return birthday.formatted(date: .long, time: .omitted)
    }

    private var activeConnectProfile: ConnectUserProfile? {
        connectProfiles.first
    }

    private var connectProfileImage: UIImage? {
        guard let fileName = activeConnectProfile?.photoFileName else { return nil }
        return loadConnectProfileImage(named: fileName)
    }

    private var connectProfileSummary: String {
        let hasProfile = activeConnectProfile != nil
        let photoCount = activeConnectProfile?.photoFileName == nil ? 0 : 1

        if hasProfile && photoCount > 0 {
            return "Manage your photo, prompts, intent, and preview"
        } else if hasProfile {
            return "Add a photo, refine your prompts, and preview your card."
        } else {
            return "Complete your public profile."
        }
    }

    private func loadConnectProfileImage(named fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func refreshIdentityContent() {
        guard let user = store.currentUser else {
            resolvedIdentityContent = nil
            return
        }

        let content = ZodiacIdentityContentService.shared.safeContent(
            forWestern: user.westernSignRaw,
            chinese: user.chineseSignRaw
        )
        resolvedIdentityContent = content

#if DEBUG
        let usedFallback = content.id == "mystic-blend"
        print("[ProfileView] westernSignRaw='\(user.westernSignRaw)' chineseSignRaw='\(user.chineseSignRaw)' resolved='\(content.id)' fallback=\(usedFallback)")
#endif
    }

    private var progressCaption: String {
        if store.daysUntilNextReward == 0 {
            return "Current roadmap complete"
        } else if store.daysUntilNextReward == 1 {
            return "1 more day to go"
        } else {
            return "\(store.daysUntilNextReward) more days to go"
        }
    }
}

// MARK: - Shared CTA

@ViewBuilder
fileprivate func hubCTA(title: String, icon: String) -> some View {
    HStack(spacing: 8) {
        Text(title)
            .font(ZD.Font.body(.semibold))

        Image(systemName: icon)
            .font(.system(size: 13, weight: .semibold))
    }
    .foregroundStyle(ZD.Color.accent)
    .frame(maxWidth: .infinity, alignment: .leading)
}

// MARK: - Premium Sheet

struct PremiumRewardsSheet: View {
    @EnvironmentObject private var store: AppStore
    let source: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                    SectionHeader(
                        title: "Premium & Rewards",
                        subtitle: "Support Zodian and unlock deeper layers"
                    )

                    TarotCardContainer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.effectivePremiumAccess ? "Premium access is active" : "Go deeper with Premium")
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.accent)

                            Text(
                                store.effectivePremiumAccess
                                ? "Premium access is currently active on your account, including any unlocked trial access."
                                : "Unlock full blueprint sections, richer daily guidance, and deeper compatibility experiences."
                            )
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                                benefitRow("Full blueprint access")
                                benefitRow("Deeper daily insights")
                                benefitRow("Expanded compatibility features")
                                benefitRow("Future premium rituals and rewards")
                            }
                        }
                    }

                    PrimaryButton(
                        title: store.effectivePremiumAccess ? "Premium Active" : "Go Premium",
                        action: {
                            if !store.effectivePremiumAccess {
                                store.updatePremiumStatus(.premium)
                                AnalyticsService.shared.track(
                                    .premiumActivated(source: source)
                                )
                            }
                        },
                        isDisabled: store.effectivePremiumAccess,
                        icon: "crown.fill",
                        fullWidth: true
                    )
                }
                .padding(ZD.Spacing.l)
            }
            .background(ZD.Color.bg.ignoresSafeArea())
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                AnalyticsService.shared.track(
                    .paywallViewed(
                        source: source,
                        premiumActive: store.effectivePremiumAccess
                    )
                )
            }
        }
    }

    private func benefitRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)
                .padding(.top, 4)

            Text(text)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
        }
    }
}

// MARK: - Connect Profile Editor

@MainActor
private struct ConnectProfileEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    @Query private var profiles: [ConnectUserProfile]

    @State private var profile: ConnectUserProfile?
    @State private var displayName: String = ""
    @State private var age: String = ""
    @State private var bio: String = ""
    @State private var prompt1: String = ""
    @State private var prompt2: String = ""
    @State private var prompt3: String = ""
    @State private var intent: String = ""
    @State private var isVisible: Bool = true
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var photoFileName: String? = nil
    @State private var originalPhotoFileName: String? = nil
    @State private var stagedPhotoFileName: String? = nil
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var validationError: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                SectionHeader(
                    title: "Edit Connect Profile",
                    subtitle: "Curate your public presence"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 14) {
                        ConnectProfileForm(
                            displayName: $displayName,
                            age: $age,
                            bio: $bio,
                            prompt1: $prompt1,
                            prompt2: $prompt2,
                            prompt3: $prompt3,
                            intent: $intent,
                            isVisible: $isVisible,
                            profileImage: $profileImage,
                            photoItem: $photoItem
                        )
                    }
                }

                Text("Preview")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.leading, 2)

                TarotCardContainer {
                    ConnectCardPreview(
                        displayName: displayName,
                        age: Int(age),
                        bio: bio,
                        prompt1: prompt1,
                        prompt2: prompt2,
                        prompt3: prompt3,
                        intent: intent,
                        isVisible: isVisible,
                        profileImage: profileImage,
                        combinedSigns: store.currentUser.map { "\($0.westernSign.displayName) • \($0.chineseSign.displayName)" } ?? "—",
                        archetypeTitle: store.currentArchetype?.title ?? "The Hidden Pattern"
                    )
                }

                if let error = validationError {
                    Text(error)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.error)
                }

                if saveSuccess {
                    Text("Saved!")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .transition(.opacity)
                }

                Button(action: saveProfile) {
                    hubCTA(title: isSaving ? "Saving..." : "Save Changes", icon: "checkmark")
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
            .padding(ZD.Spacing.l)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Connect Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadProfile)
        .onChange(of: photoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let savedFileName = saveImageToDisk(uiImage) {
                    cleanupStagedPhotoIfNeeded()
                    profileImage = uiImage
                    photoFileName = savedFileName
                    stagedPhotoFileName = savedFileName
                }
            }
        }
        .onDisappear {
            discardUnsavedPhotoSelection()
        }
    }

    private func loadProfile() {
        let loaded = profiles.first
        profile = loaded
        displayName = loaded?.displayName ?? ""
        age = loaded?.age.map { String($0) } ?? ""
        bio = loaded?.bio ?? ""
        prompt1 = loaded?.prompt1 ?? ""
        prompt2 = loaded?.prompt2 ?? ""
        prompt3 = loaded?.prompt3 ?? ""
        intent = loaded?.intent ?? ""
        isVisible = loaded?.isVisible ?? true
        photoFileName = loaded?.photoFileName
        originalPhotoFileName = loaded?.photoFileName
        stagedPhotoFileName = nil

        if let fileName = photoFileName, let image = loadImageFromDisk(fileName) {
            profileImage = image
        } else {
            profileImage = nil
        }
    }

    private func saveProfile() {
        validationError = nil
        saveSuccess = false

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt1 = prompt1.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt2 = prompt2.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt3 = prompt3.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIntent = intent.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, trimmedName.count <= 24 else {
            validationError = "Display name must be 1–24 characters."
            return
        }

        if let ageInt = Int(age), !(18...99).contains(ageInt) {
            validationError = "Age must be 18–99."
            return
        }

        guard trimmedBio.count <= 120 else {
            validationError = "Bio max 120 characters."
            return
        }

        guard trimmedPrompt1.count <= 90, trimmedPrompt2.count <= 90, trimmedPrompt3.count <= 90 else {
            validationError = "Prompts max 90 characters each."
            return
        }

        isSaving = true
        let now = Date()
        let ageInt = Int(age)
        let previousPhotoFileName = profile?.photoFileName

        if let profile = profile {
            profile.displayName = trimmedName
            profile.age = ageInt
            profile.bio = trimmedBio
            profile.prompt1 = trimmedPrompt1
            profile.prompt2 = trimmedPrompt2
            profile.prompt3 = trimmedPrompt3
            profile.intent = trimmedIntent
            profile.isVisible = isVisible
            profile.photoFileName = photoFileName
            profile.updatedAt = now
        } else {
            let newProfile = ConnectUserProfile(
                displayName: trimmedName,
                age: ageInt,
                bio: trimmedBio,
                prompt1: trimmedPrompt1,
                prompt2: trimmedPrompt2,
                prompt3: trimmedPrompt3,
                intent: trimmedIntent,
                isVisible: isVisible,
                photoFileName: photoFileName,
                createdAt: now,
                updatedAt: now
            )
            context.insert(newProfile)
            profile = newProfile
        }

        do {
            try context.save()
        } catch {
            validationError = "Failed to save changes. Please try again."
            if let stagedPhotoFileName {
                deleteImageFromDisk(stagedPhotoFileName)
                if photoFileName == stagedPhotoFileName {
                    photoFileName = previousPhotoFileName
                }
                self.stagedPhotoFileName = nil
                if let previousPhotoFileName,
                   let image = loadImageFromDisk(previousPhotoFileName) {
                    profileImage = image
                } else {
                    profileImage = nil
                }
            }
            isSaving = false
            return
        }

        if let previousPhotoFileName,
           previousPhotoFileName != photoFileName {
            deleteImageFromDisk(previousPhotoFileName)
        }
        originalPhotoFileName = photoFileName
        stagedPhotoFileName = nil
        photoItem = nil
        isSaving = false
        saveSuccess = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            saveSuccess = false
        }
    }

    private func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.92) else { return nil }
        let fileName = "connect_profile_\(UUID().uuidString).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    private func deleteImageFromDisk(_ fileName: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func loadImageFromDisk(_ fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func cleanupStagedPhotoIfNeeded() {
        guard let stagedPhotoFileName,
              stagedPhotoFileName != originalPhotoFileName else { return }
        deleteImageFromDisk(stagedPhotoFileName)
    }

    private func discardUnsavedPhotoSelection() {
        guard let stagedPhotoFileName,
              stagedPhotoFileName != originalPhotoFileName else { return }
        deleteImageFromDisk(stagedPhotoFileName)
        self.stagedPhotoFileName = nil
        photoFileName = originalPhotoFileName
    }
}

private struct ConnectProfileForm: View {
    @Binding var displayName: String
    @Binding var age: String
    @Binding var bio: String
    @Binding var prompt1: String
    @Binding var prompt2: String
    @Binding var prompt3: String
    @Binding var intent: String
    @Binding var isVisible: Bool
    @Binding var profileImage: UIImage?
    @Binding var photoItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    ZStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 68, height: 68)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(ZD.Color.cardAlt)
                                .frame(width: 68, height: 68)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundStyle(ZD.Color.accent.opacity(0.7))
                                )
                        }
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    TextField("Display Name", text: $displayName)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .textInputAutocapitalization(.words)

                    HStack(spacing: 8) {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .font(ZD.Font.body())
                            .frame(width: 54)
                            .foregroundStyle(ZD.Color.textSecondary)

                        Text("years")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Short Bio")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                TextField("Write a short intro...", text: $bio, axis: .vertical)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(2...3)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Profile Prompts")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                TarotCardContainer {
                    VStack(spacing: 8) {
                        TextField("Prompt 1", text: $prompt1)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Divider().background(ZD.Color.border.opacity(0.18))

                        TextField("Prompt 2", text: $prompt2)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Divider().background(ZD.Color.border.opacity(0.18))

                        TextField("Prompt 3", text: $prompt3)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textPrimary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Looking For / Intent")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                TextField("e.g. Friendship, Dating, Mentorship", text: $intent)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
            }

            Toggle(isOn: $isVisible) {
                Text("Visible to matches")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
            }
            .toggleStyle(.switch)
        }
    }
}

private struct ConnectCardPreview: View {
    var displayName: String
    var age: Int?
    var bio: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var intent: String
    var isVisible: Bool
    var profileImage: UIImage?
    var combinedSigns: String
    var archetypeTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 14) {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(ZD.Color.cardAlt)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundStyle(ZD.Color.accent.opacity(0.7))
                        )
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(displayName.isEmpty ? "Your Name" : displayName)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    HStack(spacing: 8) {
                        if let age = age {
                            Text("\(age)")
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.accent)
                        }

                        Text(combinedSigns)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .lineLimit(1)
                    }

                    Text(archetypeTitle)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.accentSoft)
                        .lineLimit(1)
                }

                Spacer()

                if !isVisible {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ZD.Color.muted)
                }
            }

            if !bio.isEmpty {
                Text(bio)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(2)
            }

            VStack(alignment: .leading, spacing: 6) {
                if !prompt1.isEmpty {
                    Text("\"\(prompt1)\"")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                }
                if !prompt2.isEmpty {
                    Text("\"\(prompt2)\"")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                }
                if !prompt3.isEmpty {
                    Text("\"\(prompt3)\"")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                }
            }

            if !intent.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)

                    Text(intent)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(ZD.Color.cardAlt.opacity(0.32))
                        )
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 2)
    }
}

private struct BlueprintHubStubView: View {
    let archetypeTitle: String
    let tagline: String
    let identitySummary: String
    let mantra: String
    let hiddenInsightUnlocked: Bool
    let combinedSigns: String
    let birthdayText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(archetypeTitle)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(tagline)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Identity Summary")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(identitySummary)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                    }
                    .padding()
                }

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(hiddenInsightUnlocked ? "Mantra" : "Mantra Preview")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(mantra)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                    }
                    .padding()
                }

                Text("Signs: \(combinedSigns)")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                Text("Birthday: \(birthdayText)")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
            }
            .padding()
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(archetypeTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PlaceholderDetailView: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack {
            Text(bodyText)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Profile - Free") {
    let store = AppStore()
    store.updatePremiumStatus(.free)
    store.points = 18
    store.streak = 2
    store.currentUser = UserProfile(
        name: "Mira",
        birthday: Date(timeIntervalSince1970: 694224000),
        westernSignRaw: "libra",
        chineseSignRaw: "horse",
        archetypeId: "libra-horse"
    )

    return ProfileView()
        .environmentObject(store)
        .modelContainer(
            for: [
                UserProfile.self,
                PointsLedgerItem.self,
                StreakDay.self,
                SavedDailyReading.self,
                SavedMatch.self,
                PassedProfile.self,
                ConnectUserProfile.self
            ],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}

#Preview("Profile - Premium") {
    let store = AppStore()
    store.updatePremiumStatus(.premium)
    store.points = 320
    store.streak = 11
    store.currentUser = UserProfile(
        name: "Kai",
        birthday: Date(timeIntervalSince1970: 536457600),
        westernSignRaw: "cancer",
        chineseSignRaw: "ox",
        archetypeId: "cancer-ox"
    )

    return ProfileView()
        .environmentObject(store)
        .modelContainer(
            for: [
                UserProfile.self,
                PointsLedgerItem.self,
                StreakDay.self,
                SavedDailyReading.self,
                SavedMatch.self,
                PassedProfile.self,
                ConnectUserProfile.self
            ],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}
