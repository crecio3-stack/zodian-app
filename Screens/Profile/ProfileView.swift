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
    @State private var showDisablePremiumAlert = false
    @State private var showConnectProfileEditor = false
    @State private var animatedProgress: Double = 0
    @State private var heroTitleShimmer = false
    @State private var resolvedIdentityContent: ZodiacIdentityContent?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    heroSection
                    progressHubSection
                    settingsHubSection
#if DEBUG
                    developerSection
#endif
                }
                .padding(.top, 12)
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
                Text("This clears your profile, readings, points, streak, and saved matches")
            }
            .alert("Reset Connect history?", isPresented: $showResetConnectAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    showPremiumSheet = false
                    store.resetConnectHistory(context: context)
                }
            } message: {
                Text("This clears saved and passed profiles. Everything else stays put.")
            }
            .alert("Reset daily reveal?", isPresented: $showResetTodayRevealAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    store.resetTodayRevealForDebug(context: context)
                }
            } message: {
                Text("This resets Home back to its unopened state")
            }
            .alert("Disable premium access?", isPresented: $showDisablePremiumAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Disable", role: .destructive) {
                    store.disablePremiumAccessForDebug()
                }
            } message: {
                Text("This switches the app back to Free on this device")
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
        ZStack {
            ZD.Color.bg

            LinearGradient(
                colors: [
                    ZD.Color.card.opacity(0.24),
                    .clear,
                    ZD.Color.cardAlt.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(0.10),
                    .clear
                ],
                center: .top,
                startRadius: 18,
                endRadius: 460
            )

            profileStarField
        }
        .ignoresSafeArea()
    }

    private var profileStarField: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let stars: [(CGFloat, CGFloat, CGFloat, Double)] = [
                (0.14, 0.08, 1.3, 0.20),
                (0.76, 0.12, 1.5, 0.18),
                (0.90, 0.26, 1.1, 0.14),
                (0.18, 0.39, 1.4, 0.13),
                (0.66, 0.50, 1.2, 0.13),
                (0.24, 0.72, 1.0, 0.12),
                (0.84, 0.84, 1.3, 0.12)
            ]

            ZStack {
                ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                    Circle()
                        .fill(ZD.Color.accent.opacity(star.3))
                        .frame(width: star.2, height: star.2)
                        .position(x: width * star.0, y: height * star.1)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hero

    private var heroSection: some View {
        Button {
            showConnectProfileEditor = true
        } label: {
            profileHeroCard
        }
        .buttonStyle(.plain)
    }

    private var profileHeroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            profilePanel {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 14) {
                        profileAvatarTile

                        VStack(alignment: .leading, spacing: 6) {
                            Text(profileGreetingTitle)
                                .font(.system(size: 34, weight: .regular, design: .serif))
                                .foregroundStyle(ZD.Color.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.82)

                            Text(currentCombinedSigns)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textSecondary.opacity(0.92))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    connectCardHeroCTA
                }
            }

            profileSnapshotRow
        }
    }

    private var connectCardHeroCTA: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.system(size: 13, weight: .semibold))

            Text("Edit your Connect card")
                .font(ZD.Font.caption(.semibold))
                .lineLimit(1)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            Capsule()
                .fill(ZD.Gradient.gold)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accentSoft.opacity(0.42), lineWidth: ZD.Stroke.thin)
                )
        )
        .shadow(color: ZD.Color.glow.opacity(0.46), radius: 10, x: 0, y: 5)
    }

    private var profileSnapshotRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                profileSnapshotTile(icon: "sparkles", value: "\(store.points)", label: "Points")
                profileSnapshotTile(icon: "flame.fill", value: "\(store.streak)", label: store.streak == 1 ? "Day" : "Days")
                membershipSnapshotTile
            }
            .frame(maxWidth: .infinity)

            Text("Points spend on one-day Premium Preview access from Rewards")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 2)
        }
    }

    private func profileSnapshotTile(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.24), lineWidth: ZD.Stroke.thin)
                )
        )
    }

    private var membershipSnapshotTile: some View {
        HStack(spacing: 7) {
            Image(systemName: store.effectivePremiumAccess ? "crown.fill" : "moon.stars.fill")
                .font(.system(size: 12, weight: .semibold))

            VStack(alignment: .leading, spacing: 1) {
                Text(store.effectivePremiumAccess ? "Premium" : "Preview")
                    .font(ZD.Font.caption(.semibold))
                    .lineLimit(1)

                Text("Status")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(store.effectivePremiumAccess ? Color.black : ZD.Color.textPrimary)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    store.effectivePremiumAccess
                    ? AnyShapeStyle(ZD.Gradient.gold)
                    : AnyShapeStyle(ZD.Color.cardAlt.opacity(0.72))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            store.effectivePremiumAccess ? Color.clear : ZD.Color.border.opacity(0.24),
                            lineWidth: ZD.Stroke.thin
                        )
                )
        )
    }


    private var profileAvatarTile: some View {
        Group {
            if let image = connectProfileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(ZD.Color.cardAlt)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(ZD.Color.accent.opacity(0.75))
                }
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(ZD.Color.accent.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: ZD.Color.glow.opacity(0.20), radius: 10, x: 0, y: 6)
    }


    private var profileGreetingTitle: String {
        guard let name = store.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return "Welcome back"
        }

        return "Welcome back, \(name)"
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

    private var progressHubSection: some View {
        sectionBlock(
            title: "Momentum",
            subtitle: "Points, streak, and what unlocks next"
        ) {
            profilePanel {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Next unlock")
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

    private var settingsHubSection: some View {
        sectionBlock(
            title: "Preferences",
            subtitle: "Account, reminders, and access"
        ) {
            settingsContainer {
                NavigationLink {
                    PlaceholderDetailView(title: "Account", bodyText: "Coming soon")
                } label: {
                    settingsRow(
                        title: "Account",
                        subtitle: "Name, birthday, and sign-in",
                        icon: "person.crop.circle"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    NotificationSettingsView()
                        .environmentObject(store)
                } label: {
                    settingsRow(
                        title: "Notifications",
                        subtitle: "Daily reminders and nudges",
                        icon: "bell.badge.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    PlaceholderDetailView(title: "Privacy", bodyText: "Coming soon")
                } label: {
                    settingsRow(
                        title: "Privacy",
                        subtitle: "Visibility and controls",
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
                    PlaceholderDetailView(title: "Support", bodyText: "Coming soon")
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
            subtitle: "Testing controls"
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
                    title: "Disable Premium Access",
                    icon: "crown.fill",
                    tint: ZD.Color.warning
                ) {
                    showDisablePremiumAlert = true
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

    private func profilePanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.92),
                                ZD.Color.cardAlt.opacity(0.84)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.22), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.26), radius: 12, x: 0, y: 8)
            )
    }

    private func settingsContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        profilePanel {
            VStack(spacing: 0) {
                content()
            }
        }
    }

    // MARK: - Shared UI

    private func hubCard(title: String, subtitle: String, icon: String, accent: Color) -> some View {
        profilePanel {
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
            .frame(minHeight: 64)
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

    private func compactDeveloperToggleRow(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.12))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(subtitle)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 2)
        }
        .toggleStyle(SwitchToggleStyle(tint: ZD.Color.accent))
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

        if let content = ZodiacIdentityContentService.shared.content(forArchetypeId: user.archetypeId) {
            resolvedIdentityContent = content
        } else if let archetype = store.currentArchetype {
            resolvedIdentityContent = .fromArchetype(
                archetype,
                western: user.westernSign,
                chinese: user.chineseSign
            )
            print("[ProfileView] Missing profile identity content for archetype id \(user.archetypeId)")
        } else {
            resolvedIdentityContent = nil
            print("[ProfileView] Missing current archetype for user archetype id \(user.archetypeId)")
        }

#if DEBUG
        let usedFallback = ZodiacIdentityContentService.shared.content(forArchetypeId: user.archetypeId) == nil
        print("[ProfileView] westernSignRaw='\(user.westernSignRaw)' chineseSignRaw='\(user.chineseSignRaw)' resolved='\(resolvedIdentityContent?.id ?? "nil")' fallback=\(usedFallback)")
#endif
    }

    private var progressCaption: String {
        if store.daysUntilNextReward == 0 {
            return "Track complete"
        } else if store.daysUntilNextReward == 1 {
            return "1 day left"
        } else {
            return "\(store.daysUntilNextReward) days left"
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

@ViewBuilder
fileprivate func destructiveEditorCTA(title: String, icon: String) -> some View {
    HStack(spacing: 8) {
        Text(title)
            .font(ZD.Font.body(.semibold))

        Image(systemName: icon)
            .font(.system(size: 13, weight: .semibold))
    }
    .foregroundStyle(ZD.Color.error)
    .frame(maxWidth: .infinity, alignment: .leading)
}

// MARK: - Premium Sheet

struct PremiumRewardsSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let source: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                    SectionHeader(
                        title: "Premium & Rewards",
                        subtitle: "Connect access, preview windows, and streak rewards"
                    )

                    profileSheetPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(sheetHeadline)
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.accent)

                            Text(sheetBody)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                                benefitRow("Keep Connect open past the free limit")
                                benefitRow("See more of the Connect deck in one session")
                                benefitRow("Earn preview and access through streak rewards")
                                benefitRow("Spend 50 points for a one-day preview")
                            }

                            if store.hasActivePremiumPreview {
                                Text(store.premiumPreviewStatusLine)
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.muted)
                                    .padding(.top, 2)
                            } else if !store.hasPremiumTrialUnlocked {
                                Text("Unlock premium preview until tonight")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.muted)
                                    .padding(.top, 2)
                            }
                        }
                    }

                    PrimaryButton(
                        title: primaryButtonTitle,
                        action: {
                            if !store.effectivePremiumAccess {
                                store.activatePremiumPreview()
                                AnalyticsService.shared.track(
                                    .premiumPreviewActivated(source: source)
                                )
                            }
                            dismiss()
                        },
                        isDisabled: false,
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

    private func profileSheetPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.92),
                                ZD.Color.cardAlt.opacity(0.84)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.22), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.26), radius: 12, x: 0, y: 8)
            )
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

    private var sheetHeadline: String {
        if store.hasPremiumTrialUnlocked {
            return "Premium access is active"
        }

        if store.hasActivePremiumPreview {
            return "Premium preview is active"
        }

        return "Try premium preview"
    }

    private var sheetBody: String {
        if store.hasPremiumTrialUnlocked {
            return "This account currently has premium access through rewards"
        }

        if store.hasActivePremiumPreview {
            return "You have temporary premium preview access right now, so Connect should feel noticeably more open"
        }

        return "Premium purchase is not live in this build. Daily Reveal earns points, and 50 points unlocks a one-day preview here."
    }

    private var primaryButtonTitle: String {
        if store.hasPremiumTrialUnlocked {
            return "Done"
        }

        if store.hasActivePremiumPreview {
            return "Preview Active"
        }

        return "Unlock Premium Preview"
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
    @State private var showsAge = true
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
    @State private var showDeleteAlert = false

    private let openToOptions = [
        "Friendship",
        "Dating",
        "Creative connection",
        "Like-minded people",
        "Different perspective",
        "Open to whatever fits"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                SectionHeader(
                    title: "Edit Connect Profile",
                    subtitle: "Set the card people see in Connect"
                )

                ConnectProfileForm(
                    displayName: $displayName,
                    derivedAge: derivedAge,
                    showsAge: $showsAge,
                    bio: $bio,
                    prompt1: $prompt1,
                    prompt2: $prompt2,
                    prompt3: $prompt3,
                    intent: $intent,
                    isVisible: $isVisible,
                    profileImage: $profileImage,
                    photoItem: $photoItem,
                    openToOptions: openToOptions
                )

                Text("Card preview")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.leading, 2)

                profileEditorPanel {
                    ConnectCardPreview(
                        displayName: displayName,
                        age: derivedAge,
                        showsAge: showsAge,
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
                    Text("Saved")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .transition(.opacity)
                }

                Button(action: saveProfile) {
                    hubCTA(title: isSaving ? "Saving..." : "Save Connect Profile", icon: "checkmark")
                }
                .buttonStyle(.plain)
                .disabled(isSaving)

                if profile != nil {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        destructiveEditorCTA(title: "Delete Connect Profile", icon: "trash")
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                }
            }
            .padding(ZD.Spacing.l)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Connect Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Connect Profile?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: deleteProfile)
        } message: {
            Text("This removes the saved Connect profile and its local photo from this device")
        }
        .onAppear(perform: loadProfile)
        .onChange(of: photoItem) { _, newItem in
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

    private func profileEditorPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.92),
                                ZD.Color.cardAlt.opacity(0.84)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.22), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.26), radius: 12, x: 0, y: 8)
            )
    }

    private func loadProfile() {
        let loaded = profiles.first
        profile = loaded
        displayName = loaded?.displayName.isEmpty == false ? (loaded?.displayName ?? "") : inferredDefaultDisplayName
        showsAge = loaded?.showsAge ?? true
        bio = loaded?.bio ?? ""
        prompt1 = loaded?.prompt1 ?? ""
        prompt2 = loaded?.prompt2 ?? ""
        prompt3 = loaded?.prompt3 ?? ""
        intent = loaded?.intent ?? openToOptions.first ?? ""
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
            validationError = "Display name must be 1–24 characters"
            return
        }

        guard trimmedBio.count <= 120 else {
            validationError = "Your read can be up to 120 characters"
            return
        }

        guard trimmedPrompt1.count <= 90, trimmedPrompt2.count <= 90, trimmedPrompt3.count <= 90 else {
            validationError = "Each signal can be up to 90 characters"
            return
        }

        guard !trimmedIntent.isEmpty else {
            validationError = "Choose what you’re open to"
            return
        }

        isSaving = true
        let now = Date()
        let ageInt = derivedAge
        let shouldShowAge = ageInt != nil && showsAge
        let previousPhotoFileName = profile?.photoFileName

        if let profile {
            profile.displayName = trimmedName
            profile.age = ageInt
            profile.showsAge = shouldShowAge
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
                showsAge: shouldShowAge,
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
            validationError = "Couldn't save right now. Try again."
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

    private func deleteProfile() {
        validationError = nil
        saveSuccess = false

        let fileNamesToDelete = Set(
            [
                profile?.photoFileName,
                stagedPhotoFileName
            ].compactMap { $0 }
        )

        if let profile {
            context.delete(profile)
        }

        do {
            try context.save()
        } catch {
            validationError = "Couldn't delete right now. Try again."
            return
        }

        fileNamesToDelete.forEach(deleteImageFromDisk)
        resetEditorStateAfterDelete()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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

    private func resetEditorStateAfterDelete() {
        profile = nil
        displayName = inferredDefaultDisplayName
        showsAge = derivedAge != nil
        bio = ""
        prompt1 = ""
        prompt2 = ""
        prompt3 = ""
        intent = openToOptions.first ?? ""
        isVisible = true
        photoItem = nil
        profileImage = nil
        photoFileName = nil
        originalPhotoFileName = nil
        stagedPhotoFileName = nil
    }

    private var inferredDefaultDisplayName: String {
        guard let rawName = store.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawName.isEmpty else { return "" }
        return rawName.split(separator: " ").first.map(String.init) ?? rawName
    }

    private var derivedAge: Int? {
        if let birthday = store.currentUser?.birthday {
            let years = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year
            if let years, years > 0 {
                return years
            }
        }

        return profile?.age
    }
}

private struct ConnectProfileForm: View {
    @Binding var displayName: String
    let derivedAge: Int?
    @Binding var showsAge: Bool
    @Binding var bio: String
    @Binding var prompt1: String
    @Binding var prompt2: String
    @Binding var prompt3: String
    @Binding var intent: String
    @Binding var isVisible: Bool
    @Binding var profileImage: UIImage?
    @Binding var photoItem: PhotosPickerItem?

    let openToOptions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.l) {
            profileBasicsSection
            yourReadSection
            signalsSection
            openToSection
            visibilitySection
        }
    }

    private var profileBasicsSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Text("Your card")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                HStack(spacing: 16) {
                    PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 78, height: 78)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            } else {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(ZD.Color.cardAlt)
                                    .frame(width: 78, height: 78)
                                    .overlay(
                                        VStack(spacing: 5) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 22, weight: .medium))
                                            Text("Photo")
                                                .font(.system(size: 10, weight: .semibold))
                                        }
                                        .foregroundStyle(ZD.Color.accent.opacity(0.75))
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Name", text: $displayName)
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)
                            .textInputAutocapitalization(.words)

                        if let derivedAge {
                            HStack(spacing: 8) {
                                Text("Age")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.muted)

                                Text(showsAge ? "\(derivedAge)" : "Hidden")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.textPrimary)

                                Spacer()
                            }

                            Toggle(isOn: $showsAge) {
                                Text(showsAge ? "Show age" : "Age hidden")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.textSecondary)
                            }
                            .toggleStyle(.switch)
                        }
                    }
                }
            }
        }
    }

    private var yourReadSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your read")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("A quick line that gives the card its vibe without overexplaining")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                TextField("A quick read on your vibe", text: $bio, axis: .vertical)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2...3)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ZD.Color.cardAlt.opacity(0.55))
                    )
            }
        }
    }

    private var signalsSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Signals")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("Three small tells that make your card feel more like you")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                signalField(
                    title: "How I show up",
                    text: $prompt1
                )

                signalField(
                    title: "What people notice first",
                    text: $prompt2
                )

                signalField(
                    title: "What I’m looking for",
                    text: $prompt3
                )
            }
        }
    }

    private func signalField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textSecondary)

            TextField(title, text: text, axis: .vertical)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(1...2)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(ZD.Color.cardAlt.opacity(0.55))
                )
        }
    }

    private var openToSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Open to")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("This tells people what kind of connection you want")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(openToOptions, id: \.self) { option in
                        openToPill(option)
                    }
                }
            }
        }
    }

    private func openToPill(_ option: String) -> some View {
        let isSelected = intent == option

        return Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            intent = option
        } label: {
            Text(option)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(isSelected ? Color.black : ZD.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.cardAlt.opacity(0.78)))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : ZD.Color.border.opacity(0.28),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var visibilitySection: some View {
        TarotCardContainer {
            Toggle(isOn: $isVisible) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Use in preview")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(isVisible ? "This card is active in your local setup" : "This card is hidden in your local setup")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }
            }
            .toggleStyle(.switch)
        }
    }
}

private struct ConnectCardPreview: View {
    var displayName: String
    var age: Int?
    var showsAge: Bool
    var bio: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var intent: String
    var isVisible: Bool
    var profileImage: UIImage?
    var combinedSigns: String
    var archetypeTitle: String

    private var displayTitle: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Your Name" : displayName
    }

    private var ageText: String? {
        guard showsAge, let age else { return nil }
        return "\(age)"
    }

    private var firstSignal: String {
        if !prompt1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return prompt1
        }

        if !prompt2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return prompt2
        }

        if !prompt3.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return prompt3
        }

        return "Add a signal for the card preview"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                previewImage

                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(displayTitle)
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        if let ageText {
                            Text("· \(ageText)")
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.accent)
                        }
                    }

                    Text(combinedSigns)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(1)

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

            if !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(bio)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(2)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Signal")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)

                Text("“\(firstSignal)”")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)
            }

            if !intent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                            Capsule().fill(ZD.Color.cardAlt.opacity(0.42))
                        )
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 2)
    }

    private var previewImage: some View {
        Group {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(ZD.Color.cardAlt)

                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(ZD.Color.accent.opacity(0.7))
                }
            }
        }
        .frame(width: 66, height: 66)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}



private struct BlueprintHubStubView: View {
    let archetypeTitle: String
    let tagline: String
    let identitySummary: String
    let mantra: String
    let premiumAccessActive: Bool
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
                        Text("Summary")
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
                        Text(premiumAccessActive ? "Anchor" : "Anchor Preview")
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
