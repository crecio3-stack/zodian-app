import SwiftUI
import SwiftData
import UIKit
import PhotosUI
import ImageIO
import Vision

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var avatarCropSession: SavedPersonPhotoCropSession?
    @State private var avatarCropScale: CGFloat = 1
    @State private var avatarCropOffset: CGSize = .zero
    @State private var avatarCropBaselineOffset: CGSize = .zero
    @State private var avatarCropBaselineScale: CGFloat = 1
    @State private var showResetAlert = false
    @State private var showResetConnectAlert = false
    @State private var showResetDailyReadAlert = false
    @State private var showDisablePremiumAlert = false
    @State private var showDeveloperTools = false
    @State private var resolvedIdentityCardContent: IdentityCardContent?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    identityHeroSection
                    settingsHubSection
#if DEBUG
                    developerSection
#endif
                }
                .padding(.top, 12)
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.bottom, 210)
            }
            .background(profileBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset onboarding?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    store.resetOnboardingExperience(context: context)
                }
            } message: {
                Text("This clears your profile, readings, points, streak, and saved matches")
            }
            .alert("Reset Connect and My Circle?", isPresented: $showResetConnectAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Connect", role: .destructive) {
                    store.resetConnectHistory(context: context)
                }
            } message: {
                Text("This clears Connect discovery history, saved people, and notes, then returns Connect to the beginning")
            }
            .alert("Reset Daily Lens?", isPresented: $showResetDailyReadAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Lens", role: .destructive) {
                    store.resetTodayDailyReadForDebug(context: context)
                }
            } message: {
                Text("This returns Daily Lens to its unrevealed state")
            }
            .alert("Disable archive access?", isPresented: $showDisablePremiumAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Disable", role: .destructive) {
                    store.disablePremiumAccessForDebug()
                }
            } message: {
                Text("This switches Pattern Archive access back to Free on this device")
            }
            .onAppear {
                refreshIdentityContent()
            }
            .onChange(of: identityLookupKey) { _, _ in
                refreshIdentityContent()
            }
            .fullScreenCover(item: $avatarCropSession) { session in
                SavedPersonPhotoCropView(
                    image: session.image,
                    scale: $avatarCropScale,
                    offset: $avatarCropOffset,
                    baselineOffset: $avatarCropBaselineOffset,
                    baselineScale: $avatarCropBaselineScale,
                    onCancel: { avatarCropSession = nil },
                    onConfirm: { saveAvatar(session.image) }
                )
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

            profileOrbAtmosphere
            profileStarField
        }
        .ignoresSafeArea()
    }

    private var profileOrbAtmosphere: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.07), lineWidth: 1.2)
                    .frame(width: width * 1.24, height: width * 1.24)
                    .blur(radius: 0.4)
                    .position(x: width * 0.10, y: height * 0.16)

                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.05), lineWidth: 1)
                    .frame(width: width * 0.64, height: width * 0.64)
                    .position(x: width * 0.76, y: height * 0.42)

                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.045), lineWidth: 1)
                    .frame(width: width * 0.42, height: width * 0.42)
                    .position(x: width * 0.66, y: height * 0.74)
            }
        }
        .allowsHitTesting(false)
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
                        .fill(
                            LinearGradient(
                                colors: [
                                    ZD.Color.accent.opacity(star.3),
                                    ZD.Color.accent.opacity(star.3 * 0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: star.2, height: star.2)
                        .position(x: width * star.0, y: height * star.1)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hero

    private var identityHeroSection: some View {
        profilePanel(padding: 15) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        profileAvatarTile
                        identityNavigationButton
                    }
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        profileAvatarTile
                        identityNavigationButton
                    }
                }
        }
    }

    private var identityNavigationButton: some View {
        Button { store.selectedTab = .blueprint } label: {
            HStack(alignment: .top, spacing: 12) {
                profileIdentitySummary
                profileIdentityChevron
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "View your Identity. \(profileDisplayName). \(profileSignPair). \(profileArchetypeTitle). \(profileIdentityLine)"
        )
        .accessibilityHint("Opens the Identity tab")
    }

    private var profileIdentityChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(ZD.Color.accent)
            .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
    }

    private var profileIdentitySummary: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(profileSignPair)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.accent)
                .tracking(0.9)
                .textCase(.uppercase)
                .fixedSize(horizontal: false, vertical: true)

            Text(profileDisplayName)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(profileArchetypeTitle)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .fixedSize(horizontal: false, vertical: true)

            Text(profileIdentityLine)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 7) {
                Text("\(store.streak) \(store.streak == 1 ? "day" : "days") streak")
                Text(store.effectivePremiumAccess ? "Premium" : "Free")
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(ZD.Color.accent.opacity(0.12)))
            }
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var profileAvatarTile: some View {
        ZodianPhotoPicker(
            hasPhoto: store.currentUser?.photoFileName != nil,
            onImageSelected: beginAvatarCrop,
            onRemove: removeAvatar
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(ZD.Color.cardAlt)
                if let name = store.currentUser?.photoFileName,
                   let image = SavedPersonImageStore.load(fileName: name) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Text(String(profileDisplayName.prefix(1)).uppercased())
                        .font(.system(size: 30, weight: .medium, design: .serif))
                        .foregroundStyle(ZD.Color.accent.opacity(0.82))
                }
                Image(systemName: "camera.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ZD.Color.bg)
                    .padding(7)
                    .background(Circle().fill(ZD.Color.accent))
                    .offset(x: 22, y: 22)
            }
        }
        .frame(width: 68, height: 68)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ZD.Color.accent.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: ZD.Color.glow.opacity(0.20), radius: 10, x: 0, y: 6)
        .accessibilityLabel("Edit profile photo")
        .accessibilityHint("Choose a photo source")
    }

    private func beginAvatarCrop(_ image: UIImage) {
        avatarCropScale = 1; avatarCropBaselineScale = 1
        avatarCropOffset = .zero; avatarCropBaselineOffset = .zero
        avatarCropSession = SavedPersonPhotoCropSession(image: image.normalizedForSavedPersonCrop())
    }

    private func saveAvatar(_ image: UIImage) {
        guard let user = store.currentUser else { avatarCropSession = nil; return }
        let cropped = image.savedPersonCircularCrop(scale: avatarCropScale, offset: avatarCropOffset)
        user.photoFileName = SavedPersonImageStore.save(cropped, replacing: user.photoFileName)
        try? context.save()
        avatarCropSession = nil
    }

    private func removeAvatar() {
        guard let user = store.currentUser else { return }
        if let fileName = user.photoFileName { SavedPersonImageStore.delete(fileName: fileName) }
        user.photoFileName = nil
        try? context.save()
    }

    // MARK: - Sections

    private var settingsHubSection: some View {
        sectionBlock(title: "Settings") {
            settingsContainer {
                NavigationLink {
                    AccountSettingsView()
                        .environmentObject(store)
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
                    SavedDailyReadsView()
                } label: {
                    settingsRow(
                        title: "Saved Reads",
                        subtitle: "Daily Lens entries you saved",
                        icon: "bookmark.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    PrivacySettingsView()
                        .environmentObject(store)
                } label: {
                    settingsRow(
                        title: "Privacy",
                        subtitle: "Visibility and controls",
                        icon: "lock.fill"
                    )
                }
                .buttonStyle(.plain)

                dividerLine

                NavigationLink {
                    SupportSettingsView()
                        .environmentObject(store)
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

#if DEBUG
    private var developerSection: some View {
        profilePanel {
            DisclosureGroup(isExpanded: $showDeveloperTools) {
                VStack(spacing: 0) {
                    NavigationLink {
                        EditorialReviewModeView()
                    } label: {
                        compactDeveloperLinkRow(
                            title: "Editorial Review",
                            icon: "text.book.closed",
                            tint: ZD.Color.accent
                        )
                    }
                    .buttonStyle(.plain)

                    dividerLine

                    NavigationLink {
                        TodaysLensTwoStageDebugReviewView()
                    } label: {
                        compactDeveloperLinkRow(
                            title: "Two-Stage Editorial Review",
                            icon: "rectangle.split.2x1",
                            tint: ZD.Color.accent
                        )
                    }
                    .buttonStyle(.plain)

                    dividerLine

                    NavigationLink {
                        PatternMemoryPreviewView()
                    } label: {
                        compactDeveloperLinkRow(
                            title: "Pattern Memory Preview",
                            icon: "brain.head.profile",
                            tint: ZD.Color.accent
                        )
                    }
                    .buttonStyle(.plain)

                    dividerLine

                    compactDeveloperRow(
                        title: "Reset Daily Lens",
                        icon: "rectangle.on.rectangle",
                        tint: ZD.Color.accent
                    ) {
                        showResetDailyReadAlert = true
                    }

                    dividerLine

                    compactDeveloperRow(
                        title: "Reset Connect + My Circle",
                        icon: "arrow.counterclockwise.circle",
                        tint: ZD.Color.warning
                    ) {
                        showResetConnectAlert = true
                    }

                    dividerLine

                    compactDeveloperRow(
                        title: "Disable Archive Access",
                        icon: "archivebox.fill",
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
                .padding(.top, 12)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ZD.Color.muted)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Testing controls")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("Debug only")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
        }
    }
#endif

    // MARK: - Shared Layout

    private func sectionBlock<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: title,
                subtitle: subtitle
            )

            content()
        }
    }

    private func profilePanel<Content: View>(
        padding: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(padding)
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
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 2)
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
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 18, alignment: .center)

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
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 18, alignment: .center)

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

    private func compactDeveloperLinkRow(
        title: String,
        icon: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 18, alignment: .center)

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

    private var profileDisplayName: String {
        guard let name = store.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return "Your identity"
        }

        return name
    }

    private var profileSignPair: String {
        guard let user = store.currentUser else { return "Western × Eastern" }
        return "\(user.westernSign.displayName) × \(user.chineseSign.displayName)"
    }

    private var profileArchetypeTitle: String {
        resolvedIdentityCardContent?.identityName ?? currentArchetype?.title ?? "The Hidden Pattern"
    }

    private var profileIdentityLine: String {
        resolvedIdentityCardContent?.descriptor ?? "This is where you return to yourself"
    }

    private var identityLookupKey: String {
        guard let user = store.currentUser else { return "no-user" }
        return "\(user.westernSignRaw)|\(user.chineseSignRaw)"
    }

    private var birthdayText: String {
        guard let birthday = store.currentUser?.birthday else { return "—" }
        return birthday.formatted(date: .long, time: .omitted)
    }

    private func refreshIdentityContent() {
        guard let user = store.currentUser else {
            resolvedIdentityCardContent = nil
            return
        }

        if let archetype = ArchetypeService.shared.archetypeIfLoaded(forId: user.archetypeId) {
            resolvedIdentityCardContent = archetype.identityCardContent
        } else if let archetype = store.currentArchetype {
            resolvedIdentityCardContent = archetype.identityCardContent
            print("[ProfileView] Missing loaded identity card content")
        } else {
            resolvedIdentityCardContent = nil
            print("[ProfileView] Missing current archetype")
        }

#if DEBUG
        print("[ProfileView] identity card resolution completed")
#endif
    }

    private func orbitalAccentRing(size: CGFloat, opacity: Double, lineWidth: CGFloat) -> some View {
        Circle()
            .stroke(ZD.Color.accent.opacity(opacity), lineWidth: lineWidth)
            .frame(width: size, height: size)
            .blur(radius: 0.35)
            .allowsHitTesting(false)
    }

    private func presenceInfoRow(label: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.accent)
                .tracking(0.8)

            Text(value)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(detail)
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func saveShelfRow(title: String, value: String, detail: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
                    .tracking(0.8)

                Text(detail)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .padding(.leading, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    let onAccessActivated: () -> Void

    init(
        source: String,
        onAccessActivated: @escaping () -> Void = {}
    ) {
        self.source = source
        self.onAccessActivated = onAccessActivated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                    SectionHeader(
                        title: "Pattern Archive",
                        subtitle: "Your private library of saved Daily Lens entries"
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
                                benefitRow("Access can be opened with an existing reward or 50 points")
                            }

                            if store.hasActivePremiumPreview {
                                Text(
                                    store.premiumPreviewStatusLine.replacingOccurrences(
                                        of: "Preview active",
                                        with: "Available"
                                    )
                                )
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.muted)
                                    .padding(.top, 2)
                            } else if !store.hasPremiumTrialUnlocked && store.points < 50 {
                                Text("You need 50 points to open the archive for today")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.muted)
                                    .padding(.top, 2)
                            } else if !store.hasPremiumTrialUnlocked {
                                Text("Use 50 points to open the archive for today")
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
                                guard store.redeemPremiumPreviewWithPoints(cost: 50) else {
                                    return
                                }
                                AnalyticsService.shared.track(
                                    .premiumPreviewActivated(source: source)
                                )
                            }

                            guard store.effectivePremiumAccess else { return }
                            onAccessActivated()
                            dismiss()
                        },
                        isDisabled: !store.effectivePremiumAccess && store.points < 50,
                        icon: "archivebox.fill",
                        fullWidth: true
                    )
                }
                .padding(ZD.Spacing.l)
            }
            .background(ZD.Color.bg.ignoresSafeArea())
            .navigationTitle("Pattern Archive")
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
        if store.effectivePremiumAccess {
            return "Your archive is available"
        }

        return "Open your Pattern Archive"
    }

    private var sheetBody: String {
        "A private library of the Daily Lens entries you chose to keep."
    }

    private var primaryButtonTitle: String {
        if store.effectivePremiumAccess {
            return "View saved reads"
        }

        return store.points >= 50 ? "Open archive for today" : "50 points needed"
    }
}

struct CompatibilityTeaserSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let person: SavedPerson
    let user: UserProfile?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("ZODIAN PREMIUM")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(1.5)
                        .foregroundStyle(ZD.Color.accent)

                    Text(store.effectivePremiumAccess ? "Compatibility is coming" : "See how you connect")
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    connectionPreview

                    if store.effectivePremiumAccess {
                        Text("You’ll soon be able to explore how you communicate, build trust, handle conflict, and connect with every person you save.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        PrimaryButton(title: "Got It", action: { dismiss() }, fullWidth: true)
                            .accessibilityLabel("Got It")
                    } else {
                        Text("See where you naturally click—and where things can get complicated.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        benefits

                        VStack(alignment: .leading, spacing: 5) {
                            Text("COMING SOON")
                                .font(ZD.Font.caption(.semibold))
                                .tracking(1.3)
                                .foregroundStyle(ZD.Color.accent)
                            Text("Compatibility is one of the next major experiences coming to Zodian.")
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        PremiumGoldShimmerButton(
                            title: "I’m Interested",
                            action: {
                                AnalyticsService.shared.track(.compatibilityNotifyInterest(identityID: person.archetype.id))
                                dismiss()
                            }
                        )
                        .accessibilityLabel("I’m interested in Compatibility")
                        .accessibilityHint("Records your interest and closes this preview")
                    }
                }
                .padding(ZD.Spacing.l)
            }
            .background(ZD.Color.bg.ignoresSafeArea())
            .navigationTitle("Compatibility")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Close Compatibility")
                }
            }
        }
    }

    private var connectionPreview: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("YOUR CONNECTION")
                .font(ZD.Font.caption(.semibold))
                .tracking(1.3)
                .foregroundStyle(ZD.Color.accent)

            HStack(alignment: .top, spacing: 12) {
                dynamicPerson(
                    name: user?.name ?? "You",
                    signs: user.map { "\($0.westernSign.displayName) × \($0.chineseSign.displayName)" } ?? "Your signs",
                    photoFileName: user?.photoFileName
                )
                .frame(maxWidth: .infinity)

                Text("×")
                    .font(.system(size: 19, weight: .medium, design: .serif))
                    .foregroundStyle(ZD.Color.accent.opacity(0.78))
                    .frame(width: 24, height: 64)
                    .accessibilityHidden(true)

                dynamicPerson(
                    name: person.name,
                    signs: person.signLine,
                    photoFileName: person.photoFileName
                )
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    lockedPreview("Connection")
                    lockedPreview("Friction")
                    lockedPreview("Chemistry")
                }
                VStack(alignment: .leading, spacing: 8) {
                    lockedPreview("Connection")
                    lockedPreview("Friction")
                    lockedPreview("Chemistry")
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.58))
                .overlay(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous).stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
    }

    private func dynamicPerson(name: String, signs: String, photoFileName: String?) -> some View {
        VStack(spacing: 7) {
            SavedPersonAvatar(name: name, photoFileName: photoFileName, size: 64)
            Text(name)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .frame(height: 22)
            Text(signs)
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(height: 18)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func lockedPreview(_ label: String) -> some View {
        Label(label, systemImage: "lock.fill")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(ZD.Color.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(Capsule().fill(ZD.Color.card.opacity(0.72)))
            .frame(maxWidth: .infinity)
            .accessibilityLabel("\(label), locked")
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 10) {
            benefit("Full compatibility with every person you save")
            benefit("Communication, trust, and conflict insights")
            benefit("Perspectives across love, friendship, family, and work")
        }
    }

    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(ZD.Color.accent)
                .padding(.top, 2)
            Text(text)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Connect Profile Editor

private let connectProfilePhotoEditorPreviewSize: CGFloat = 188
private let connectProfilePhotoCropModalSize: CGFloat = min(UIScreen.main.bounds.width - 48, 360)

private func connectPhotoOffsetLimits(imageSize: CGSize, cropSize: CGFloat, scale: CGFloat) -> CGSize {
    guard imageSize.width > 0, imageSize.height > 0 else {
        return .zero
    }

    let aspectRatio = imageSize.width / imageSize.height
    let baseWidth: CGFloat
    let baseHeight: CGFloat

    if aspectRatio >= 1 {
        baseWidth = cropSize * aspectRatio
        baseHeight = cropSize
    } else {
        baseWidth = cropSize
        baseHeight = cropSize / aspectRatio
    }

    return CGSize(
        width: max(((baseWidth * scale) - cropSize) / 2, 0),
        height: max(((baseHeight * scale) - cropSize) / 2, 0)
    )
}

@MainActor
struct ConnectProfileEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [ConnectUserProfile]
    @Query(sort: \UserProfile.createdAt, order: .forward) private var users: [UserProfile]

    private let onSave: (() -> Void)?

    @State private var profile: ConnectUserProfile?
    @State private var displayName: String = ""
    @State private var showsAge = true
    @State private var bio: String = ""
    @State private var prompt1: String = ""
    @State private var prompt2: String = ""
    @State private var prompt3: String = ""
    @State private var openToSelections: [String] = []
    @State private var isVisible: Bool = true
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var photoFileName: String? = nil
    @State private var photoRemoved = false
    @State private var originalPhotoFileName: String? = nil
    @State private var photoCropOffset: CGSize = .zero
    @State private var photoCropBaselineOffset: CGSize = .zero
    @State private var photoCropScale: CGFloat = 1.04
    @State private var photoCropBaselineScale: CGFloat = 1.04
    @State private var pendingCropImage: UIImage? = nil
    @State private var pendingCropOffset: CGSize = .zero
    @State private var pendingCropBaselineOffset: CGSize = .zero
    @State private var pendingCropScale: CGFloat = 1.04
    @State private var pendingCropBaselineScale: CGFloat = 1.04
    @State private var showPhotoCropModal = false
    @State private var suppressNextEditorAppearReload = false
    @State private var isLoadingPhoto = false
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var validationError: String? = nil
    @State private var showDeleteAlert = false

    private let openToOptions = [
        "Friendship",
        "Attraction",
        "Creative",
        "Conversation",
        "Open"
    ]

    init(onSave: (() -> Void)? = nil) {
        self.onSave = onSave
    }

    private var signPairText: String {
        guard let user = sourceUser else { return "—" }
        return "\(user.westernSign.displayName) × \(user.chineseSign.displayName)"
    }

    private var signDotText: String {
        guard let user = sourceUser else { return "—" }
        return "\(user.westernSign.displayName) • \(user.chineseSign.displayName)"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                SectionHeader(
                    title: "Set your Connect card",
	                    subtitle: "This is what people see when your perspective appears"
                )

                ConnectProfileForm(
                    displayName: $displayName,
                    derivedAge: derivedAge,
                    showsAge: $showsAge,
                    signal: $prompt1,
                    isVisible: $isVisible,
                    profileImage: $profileImage,
                    photoCropOffset: photoCropOffset,
                    photoCropScale: photoCropScale,
                    onPhotoSelected: beginConnectPhotoCrop,
                    onPhotoRemoved: removeConnectPhoto,
                    openToSelections: $openToSelections,
                    combinedSigns: signPairText,
                    archetypeTitle: store.currentArchetype?.title ?? "The Hidden Pattern",
                    connectVisibilityAllowed: store.connectVisibilityAllowsDiscovery,
                    openToOptions: openToOptions
                )

                Text("Card preview")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.leading, 2)

                profileEditorPanel {
                    ConnectCardPreview(
                        displayName: displayName,
                        signal: prompt1,
                        openToSelections: openToSelections,
                        isVisible: isVisible && store.connectVisibilityAllowsDiscovery,
                        profileImage: profileImage,
                        photoCropOffset: photoCropOffset,
                        photoCropScale: photoCropScale,
                        combinedSigns: signDotText,
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
                    hubCTA(title: isSaving ? "Saving..." : "Save Connect Card", icon: "checkmark")
                }
                .buttonStyle(.plain)
                .disabled(isSaving || isLoadingPhoto)

                if profile != nil {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        destructiveEditorCTA(title: "Delete Connect Card", icon: "trash")
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                }
            }
            .padding(ZD.Spacing.l)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Connect Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(ZD.Color.accent)
            }
        }
        .alert("Delete Connect Profile?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: deleteProfile)
        } message: {
            Text("This removes the saved Connect profile and its local photo from this device")
        }
        .fullScreenCover(isPresented: $showPhotoCropModal) {
            if let pendingCropImage {
                ConnectProfilePhotoCropModal(
                    image: pendingCropImage,
                    photoCropOffset: $pendingCropOffset,
                    photoCropBaselineOffset: $pendingCropBaselineOffset,
                    photoCropScale: $pendingCropScale,
                    photoCropBaselineScale: $pendingCropBaselineScale,
                    onCancel: cancelPendingPhotoCrop,
                    onUsePhoto: commitPendingPhotoCrop
                )
                .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            if suppressNextEditorAppearReload {
                suppressNextEditorAppearReload = false
                return
            }

            store.loadUserIfNeeded(context: context)
            loadProfile()
            store.syncConnectAccessState(isComplete: profile?.isCoreProfileComplete ?? false)
        }
        .onDisappear {
            guard !showPhotoCropModal else { return }
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
        openToSelections = parsedOpenToSelections(from: loaded?.intent)
        isVisible = (loaded?.isVisible ?? true) && store.connectVisibilityAllowsDiscovery
        photoFileName = loaded?.photoFileName
        originalPhotoFileName = loaded?.photoFileName
        resetPhotoCropTransform()

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
        let trimmedPrompt1 = prompt1.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOpenTo = normalizedOpenToSelections(openToSelections)

        guard !trimmedName.isEmpty, trimmedName.count <= 24 else {
            validationError = "Display name must be 1–24 characters"
            return
        }

        guard profileImage != nil || photoFileName != nil else {
            validationError = "Add a photo for your Connect card"
            return
        }

        guard trimmedPrompt1.count <= 90 else {
            validationError = "First signal can be up to 90 characters"
            return
        }

        guard !trimmedOpenTo.isEmpty else {
            validationError = "Choose what you’re open to"
            return
        }

        isSaving = true
        let now = Date()
        let shouldShowAge = showsAge
        let ageInt = derivedAge ?? profile?.age
        let previousPhotoFileName = profile?.photoFileName
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedPhoto = profileImage != nil
            ? saveCanonicalPhoto(from: profileImage)
            : nil
        let savedPhotoFileName = photoRemoved ? nil : (savedPhoto?.fileName ?? profile?.photoFileName)

        if let profile {
            profile.displayName = trimmedName
            profile.age = ageInt
            profile.showsAge = shouldShowAge
            profile.bio = trimmedBio
            profile.prompt1 = trimmedPrompt1
            profile.prompt2 = ""
            profile.prompt3 = ""
            profile.intent = openToStorageValue(from: trimmedOpenTo)
            profile.isVisible = isVisible && store.connectVisibilityAllowsDiscovery
            profile.photoFileName = savedPhotoFileName
            profile.updatedAt = now
        } else {
            let newProfile = ConnectUserProfile(
                displayName: trimmedName,
                age: ageInt,
                showsAge: shouldShowAge,
                bio: trimmedBio,
                prompt1: trimmedPrompt1,
                prompt2: "",
                prompt3: "",
                intent: openToStorageValue(from: trimmedOpenTo),
                isVisible: isVisible && store.connectVisibilityAllowsDiscovery,
                photoFileName: savedPhotoFileName,
                createdAt: now,
                updatedAt: now
            )
            context.insert(newProfile)
            profile = newProfile
        }

        do {
            try context.save()
        } catch {
            validationError = "Couldn't save right now. Try again"
            if let previousPhotoFileName,
               let image = loadImageFromDisk(previousPhotoFileName) {
                profileImage = image
            } else {
                profileImage = nil
            }
            photoFileName = previousPhotoFileName
            isSaving = false
            return
        }

        if let previousPhotoFileName,
           previousPhotoFileName != savedPhotoFileName {
            deleteImageFromDisk(previousPhotoFileName)
        }

        store.markIdentityStateChanged()
        store.markConnectCardCompleted()

        photoFileName = savedPhotoFileName
        photoRemoved = false
        originalPhotoFileName = savedPhotoFileName
        if let savedPhoto {
            profileImage = savedPhoto.image
        } else if let savedPhotoFileName,
                  let image = loadImageFromDisk(savedPhotoFileName) {
            profileImage = image
        }
        resetPhotoCropTransform()
        photoItem = nil
        isSaving = false
        saveSuccess = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if onSave != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                onSave?()
            }
        }

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
            ].compactMap { $0 }
        )

        if let profile {
            context.delete(profile)
        }

        do {
            try context.save()
        } catch {
            validationError = "Couldn't delete right now. Try again"
            return
        }

        fileNamesToDelete.forEach(deleteImageFromDisk)
        store.syncConnectAccessState(isComplete: false)
        resetEditorStateAfterDelete()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func saveCanonicalPhoto(from image: UIImage?) -> (fileName: String, image: UIImage)? {
        guard let image else { return nil }
        guard let cropped = canonicalSquarePhoto(from: image) else { return nil }
        guard let data = cropped.pngData() else { return nil }
        let fileName = "connect_profile_\(UUID().uuidString).png"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        do {
            try data.write(to: url)
            return (fileName, cropped)
        } catch {
            return nil
        }
    }

    private func decodedConnectPhoto(from data: Data) -> UIImage? {
        let maxPixelSize: CGFloat = 1800
        let sourceOptions = [
            kCGImageSourceShouldCache: false
        ] as CFDictionary

        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return UIImage(data: data)
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return UIImage(data: data)
        }

        return UIImage(cgImage: cgImage)
    }

    private func applySuggestedPendingPhotoCrop(for image: UIImage) {
        resetPendingPhotoCropTransform()

        guard let faceCenter = primaryFaceCenter(in: image) else { return }

        let suggestedScale: CGFloat = 1.04
        let suggestedOffset = faceCenteredOffset(
            for: image,
            faceCenter: faceCenter,
            scale: suggestedScale
        )

        pendingCropOffset = suggestedOffset
        pendingCropBaselineOffset = suggestedOffset
        pendingCropScale = suggestedScale
        pendingCropBaselineScale = suggestedScale
    }

    private func primaryFaceCenter(in image: UIImage) -> CGPoint? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)

        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        guard let face = request.results?.max(by: { lhs, rhs in
            let lhsArea = lhs.boundingBox.width * lhs.boundingBox.height
            let rhsArea = rhs.boundingBox.width * rhs.boundingBox.height
            return lhsArea < rhsArea
        }) else {
            return nil
        }

        return CGPoint(
            x: face.boundingBox.midX,
            y: 1 - face.boundingBox.midY
        )
    }

    private func faceCenteredOffset(for image: UIImage, faceCenter: CGPoint, scale: CGFloat) -> CGSize {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let cropSize = connectProfilePhotoCropModalSize
        let aspectRatio = imageSize.width / imageSize.height
        let baseWidth: CGFloat
        let baseHeight: CGFloat

        if aspectRatio >= 1 {
            baseWidth = cropSize * aspectRatio
            baseHeight = cropSize
        } else {
            baseWidth = cropSize
            baseHeight = cropSize / aspectRatio
        }

        let relativeFacePosition = CGSize(
            width: (faceCenter.x - 0.5) * baseWidth * scale,
            height: (faceCenter.y - 0.5) * baseHeight * scale
        )
        let targetFacePosition = CGSize(width: 0, height: -cropSize * 0.07)
        let rawOffset = CGSize(
            width: targetFacePosition.width - relativeFacePosition.width,
            height: targetFacePosition.height - relativeFacePosition.height
        )
        let limits = connectPhotoOffsetLimits(imageSize: imageSize, cropSize: cropSize, scale: scale)

        return CGSize(
            width: min(max(rawOffset.width, -limits.width), limits.width),
            height: min(max(rawOffset.height, -limits.height), limits.height)
        )
    }

    private func canonicalSquarePhoto(from image: UIImage) -> UIImage? {
        let outputSize = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: outputSize)

        let rendered = renderer.image { _ in
            let imageSize = image.size
            guard imageSize.width > 0, imageSize.height > 0 else { return }

            let baseScale = max(outputSize.width / imageSize.width, outputSize.height / imageSize.height)
            let scale = baseScale * photoCropScale
            let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            let outputScale = outputSize.width / connectProfilePhotoEditorPreviewSize
            let offsetX = photoCropOffset.width * outputScale
            let offsetY = photoCropOffset.height * outputScale

            let drawRect = CGRect(
                x: (outputSize.width - drawSize.width) / 2 + offsetX,
                y: (outputSize.height - drawSize.height) / 2 + offsetY,
                width: drawSize.width,
                height: drawSize.height
            )

            image.draw(in: drawRect)
        }

        return rendered
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
        return
    }

    private func discardUnsavedPhotoSelection() {
        photoItem = nil
        if let originalPhotoFileName,
           let image = loadImageFromDisk(originalPhotoFileName) {
            profileImage = image
        } else {
            profileImage = nil
        }
        resetPhotoCropTransform()
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
        openToSelections = []
        isVisible = store.connectVisibilityAllowsDiscovery
        photoItem = nil
        profileImage = nil
        photoFileName = nil
        originalPhotoFileName = nil
        resetPhotoCropTransform()
    }

    private var inferredDefaultDisplayName: String {
        guard let rawName = sourceUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawName.isEmpty else { return "" }
        return rawName.split(separator: " ").first.map(String.init) ?? rawName
    }

    private var derivedAge: Int? {
        if let birthday = sourceUser?.birthday {
            let years = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year
            if let years, years > 0 {
                return years
            }
        }

        return profile?.age
    }

    private var sourceUser: UserProfile? {
        store.currentUser ?? users.first
    }

    private func resetPhotoCropTransform() {
        photoCropOffset = .zero
        photoCropBaselineOffset = .zero
        photoCropScale = 1.04
        photoCropBaselineScale = 1.04
    }

    private func resetPendingPhotoCropTransform() {
        pendingCropOffset = .zero
        pendingCropBaselineOffset = .zero
        pendingCropScale = 1.04
        pendingCropBaselineScale = 1.04
    }

    private func cancelPendingPhotoCrop() {
        suppressNextEditorAppearReload = true
        showPhotoCropModal = false
        pendingCropImage = nil
        resetPendingPhotoCropTransform()
    }

    private func beginConnectPhotoCrop(_ image: UIImage) {
        photoRemoved = false
        pendingCropImage = image
        applySuggestedPendingPhotoCrop(for: image)
        validationError = nil
        showPhotoCropModal = true
    }

    private func removeConnectPhoto() {
        profileImage = nil
        photoFileName = nil
        photoRemoved = true
        validationError = nil
    }

    private func commitPendingPhotoCrop() {
        guard let pendingCropImage else { return }

        let cropOffsetScale = connectProfilePhotoEditorPreviewSize / connectProfilePhotoCropModalSize
        let committedOffset = CGSize(
            width: pendingCropOffset.width * cropOffsetScale,
            height: pendingCropOffset.height * cropOffsetScale
        )

        profileImage = pendingCropImage
        photoFileName = nil
        photoCropOffset = committedOffset
        photoCropBaselineOffset = committedOffset
        photoCropScale = pendingCropScale
        photoCropBaselineScale = pendingCropScale
        validationError = nil
        suppressNextEditorAppearReload = true
        showPhotoCropModal = false
        self.pendingCropImage = nil
        resetPendingPhotoCropTransform()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

private struct ConnectProfileForm: View {
    private enum FocusedField {
        case displayName
        case signal
    }

    @Binding var displayName: String
    let derivedAge: Int?
    @Binding var showsAge: Bool
    @Binding var signal: String
    @Binding var isVisible: Bool
    @Binding var profileImage: UIImage?
    var photoCropOffset: CGSize
    var photoCropScale: CGFloat
    let onPhotoSelected: (UIImage) -> Void
    let onPhotoRemoved: () -> Void
    @Binding var openToSelections: [String]
    let combinedSigns: String
    let archetypeTitle: String
    let connectVisibilityAllowed: Bool

    let openToOptions: [String]

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.l) {
            profileBasicsSection
            signalSection
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("Photo")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("This is how people will see you in Connect")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }

                ZodianPhotoPicker(
                    hasPhoto: profileImage != nil,
                    onImageSelected: onPhotoSelected,
                    onRemove: onPhotoRemoved
                ) {
                    ConnectProfilePhotoPreview(
                        image: profileImage,
                        photoCropOffset: photoCropOffset,
                        photoCropScale: photoCropScale
                    )
                }
                .accessibilityLabel(profileImage == nil ? "Choose photo" : "Change photo")
                .accessibilityHint("Choose a photo source")

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Display name", text: $displayName)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .displayName)
                        .onSubmit {
                            focusedField = .signal
                        }

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

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Western × Eastern")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.muted)

                        Text(combinedSigns)
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineLimit(1)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Archetype title")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.muted)

                        Text(archetypeTitle)
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                            .lineLimit(2)
                    }
                }
            }
        }
    }

    private var signalSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("First detail")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("A detail is the small truth people notice first. Keep it short and real.")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                TextField("I notice the shift before people name it", text: $signal)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .signal)
                    .onChange(of: signal) { _, newValue in
                        let singleLine = newValue
                            .replacingOccurrences(of: "\n", with: " ")
                            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

                        if singleLine != newValue {
                            signal = singleLine
                        }
                    }
                    .onSubmit {
                        focusedField = nil
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ZD.Color.cardAlt.opacity(0.55))
                    )

                Text("Max 90 characters")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
            }
        }
    }

    private var openToSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Open to")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("What are you open to here?")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 96), spacing: 8)],
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
        let isSelected = openToSelections.contains(option)

        return Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            toggleOpenToSelection(option)
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

    private func toggleOpenToSelection(_ option: String) {
        var selections = openToSelections

        if let index = selections.firstIndex(of: option) {
            selections.remove(at: index)
        } else {
            if selections.count == 2 {
                selections.removeFirst()
            }
            selections.append(option)
        }

        openToSelections = selections
    }

    private var visibilitySection: some View {
        TarotCardContainer {
            Toggle(isOn: $isVisible) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview only")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(visibilitySubtitle)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }
            }
            .toggleStyle(.switch)
            .disabled(!connectVisibilityAllowed)
            .onChange(of: connectVisibilityAllowed) { _, allowed in
                if !allowed {
                    isVisible = false
                }
            }
        }
    }

    private var visibilitySubtitle: String {
        if !connectVisibilityAllowed {
            return "Hidden by Privacy settings"
        }

        return isVisible ? "Shown in local testing" : "Hidden in local testing"
    }
}

private struct ConnectProfilePhotoPreview: View {
    let image: UIImage?
    var photoCropOffset: CGSize
    var photoCropScale: CGFloat

    private let previewSize: CGFloat = connectProfilePhotoEditorPreviewSize

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.80))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                )

            if let image {
                GeometryReader { proxy in
                    let previewScale = min(proxy.size.width, proxy.size.height) / connectProfilePhotoEditorPreviewSize

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .scaleEffect(photoCropScale)
                        .offset(
                            CGSize(
                                width: photoCropOffset.width * previewScale,
                                height: photoCropOffset.height * previewScale
                            )
                        )
                        .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.02),
                            Color.black.opacity(0.16),
                            Color.black.opacity(0.46)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                )

                VStack {
                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 11, weight: .semibold))

                        Text("Change photo")
                            .font(ZD.Font.caption(.semibold))
                    }
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.black.opacity(0.58))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 12)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.square")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(ZD.Color.accent.opacity(0.78))

                    Text("Choose a photo")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.textSecondary)
                }
            }

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                .padding(1)
        }
        .frame(width: previewSize, height: previewSize)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityLabel(image == nil ? "Choose photo" : "Change photo")
    }
}

private struct ConnectProfilePhotoCropModal: View {
    let image: UIImage
    @Binding var photoCropOffset: CGSize
    @Binding var photoCropBaselineOffset: CGSize
    @Binding var photoCropScale: CGFloat
    @Binding var photoCropBaselineScale: CGFloat
    let onCancel: () -> Void
    let onUsePhoto: () -> Void

    private let cropSize: CGFloat = connectProfilePhotoCropModalSize
    private let cropCornerRadius: CGFloat = 28
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.2

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.94)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    ZD.Color.card.opacity(0.82),
                    Color.black.opacity(0.92),
                    ZD.Color.bg.opacity(0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                modalTopBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                Spacer(minLength: 18)

                cropStage

                Spacer(minLength: 24)

                modalBottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 22)
            }
        }
    }

    private var modalTopBar: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textSecondary)

            Spacer()

            Text("Position photo")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(1.0)

            Spacer()

            Text("Cancel")
                .font(ZD.Font.body(.semibold))
                .hidden()
        }
    }

    private var cropStage: some View {
        ZStack {
            GeometryReader { proxy in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(photoCropScale)
                    .offset(photoCropOffset)
                    .clipped()
            }
            .frame(width: cropSize, height: cropSize)
            .clipShape(RoundedRectangle(cornerRadius: cropCornerRadius, style: .continuous))

            cropDimOverlay
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: cropCornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.82), lineWidth: 1.5)
                .frame(width: cropSize, height: cropSize)
                .shadow(color: ZD.Color.accent.opacity(0.20), radius: 18, y: 8)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: min(UIScreen.main.bounds.height * 0.66, 560))
        .contentShape(Rectangle())
        .highPriorityGesture(photoDragGesture)
        .simultaneousGesture(photoMagnificationGesture)
    }

    private var cropDimOverlay: some View {
        ZStack {
            Color.black.opacity(0.52)

            RoundedRectangle(cornerRadius: cropCornerRadius, style: .continuous)
                .frame(width: cropSize, height: cropSize)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }

    private var modalBottomBar: some View {
        HStack(spacing: 12) {
            Button {
                resetCrop()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "scope")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Reset")
                        .font(ZD.Font.body(.semibold))
                }
                .foregroundStyle(ZD.Color.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(ZD.Color.card.opacity(0.72))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(ZD.Color.border.opacity(0.24), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            Button(action: onUsePhoto) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text("Use photo")
                        .font(ZD.Font.body(.semibold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ZD.Gradient.gold)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var photoDragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                photoCropOffset = clampedOffset(
                    CGSize(
                        width: photoCropBaselineOffset.width + value.translation.width,
                        height: photoCropBaselineOffset.height + value.translation.height
                    ),
                    scale: photoCropScale
                )
            }
            .onEnded { _ in
                photoCropBaselineOffset = photoCropOffset
            }
    }

    private var photoMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let nextScale = clampedScale(photoCropBaselineScale * value)
                photoCropScale = nextScale
                photoCropOffset = clampedOffset(photoCropOffset, scale: nextScale)
            }
            .onEnded { _ in
                photoCropBaselineScale = photoCropScale
                photoCropBaselineOffset = photoCropOffset
            }
    }

    private func resetCrop() {
        photoCropOffset = .zero
        photoCropBaselineOffset = .zero
        photoCropScale = 1.04
        photoCropBaselineScale = 1.04
    }

    private func clampedOffset(_ offset: CGSize, scale: CGFloat) -> CGSize {
        let limits = offsetLimits(for: scale)
        return CGSize(
            width: min(max(offset.width, -limits.width), limits.width),
            height: min(max(offset.height, -limits.height), limits.height)
        )
    }

    private func clampedScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, minScale), maxScale)
    }

    private func offsetLimits(for scale: CGFloat) -> CGSize {
        connectPhotoOffsetLimits(imageSize: image.size, cropSize: cropSize, scale: scale)
    }
}

private struct ConnectCardPreview: View {
    var displayName: String
    var signal: String
    var openToSelections: [String]
    var isVisible: Bool
    var profileImage: UIImage?
    var photoCropOffset: CGSize
    var photoCropScale: CGFloat
    var combinedSigns: String
    var archetypeTitle: String

    private var displayTitle: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Your Name" : displayName
    }

    private var signalText: String? {
        let trimmed = signal.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var openToDisplayText: String {
        let cleaned = normalizedOpenToSelections(openToSelections)
        return cleaned.isEmpty ? "Open" : cleaned.joined(separator: " • ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                previewImage

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTitle)
                        .font(.system(size: 25, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(combinedSigns)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(1)

                    Text(archetypeTitle)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.accentSoft)
                        .lineLimit(2)

                    if !isVisible {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Preview only")
                                .font(ZD.Font.caption(.semibold))
                        }
                        .foregroundStyle(ZD.Color.muted)
                        .padding(.top, 4)
                    }
                }

                Spacer(minLength: 0)
            }

            if let signalText {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Signal")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.muted)

                    Text(signalText)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)
                }
            }

            if !openToDisplayText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(spacing: 6) {
                    Text("Open to")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.muted)

                    Text(openToDisplayText)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
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
                GeometryReader { proxy in
                    let previewScale = min(proxy.size.width, proxy.size.height) / connectProfilePhotoEditorPreviewSize

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .scaleEffect(photoCropScale)
                        .offset(
                            CGSize(
                                width: photoCropOffset.width * previewScale,
                                height: photoCropOffset.height * previewScale
                            )
                        )
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(ZD.Color.cardAlt)

                    Image(systemName: "person.crop.square")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(ZD.Color.accent.opacity(0.7))
                }
            }
        }
        .frame(width: 82, height: 82)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private let openToSelectionSeparator = " • "

private func normalizedOpenToSelections(_ selections: [String]) -> [String] {
    let allowed = [
        "Friendship",
        "Attraction",
        "Creative",
        "Conversation",
        "Open"
    ]

    var normalized: [String] = []
    var seen = Set<String>()

    for raw in selections {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { continue }

        let mapped = normalizedOpenToLabel(trimmed)
        guard !mapped.isEmpty else { continue }
        guard allowed.contains(mapped) else { continue }
        guard seen.insert(mapped).inserted else { continue }

        normalized.append(mapped)
        if normalized.count == 2 { break }
    }

    return normalized
}

    private func parsedOpenToSelections(from rawIntent: String?) -> [String] {
    guard let rawIntent else { return [] }
    let trimmed = rawIntent.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return [] }

    let pieces = trimmed
        .replacingOccurrences(of: "•", with: "|")
        .replacingOccurrences(of: "·", with: "|")
        .replacingOccurrences(of: "\n", with: "|")
        .replacingOccurrences(of: ",", with: "|")
        .split(separator: "|")
        .map(String.init)

    return normalizedOpenToSelections(pieces.isEmpty ? [trimmed] : pieces)
}

private func openToStorageValue(from selections: [String]) -> String {
    normalizedOpenToSelections(selections).joined(separator: openToSelectionSeparator)
}

private func displayOpenToValue(_ rawIntent: String?) -> String {
    let selections = parsedOpenToSelections(from: rawIntent)
    return selections.isEmpty ? "Open" : selections.joined(separator: openToSelectionSeparator)
}

private func normalizedOpenToLabel(_ value: String) -> String {
    switch value.lowercased() {
    case "dating":
        return "Attraction"
    case "perspective":
        return "Conversation"
    case "undefined":
        return ""
    case "open to what fits":
        return "Open"
    default:
        return value
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
        .environmentObject(AccountOwnershipController())
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
        .environmentObject(AccountOwnershipController())
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
