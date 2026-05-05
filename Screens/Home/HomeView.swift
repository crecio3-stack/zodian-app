import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @State private var appeared = false
    @State private var isOpeningDailyRitual = false
    @State private var navigateToDailyRitual = false
    @State private var showMilestoneBanner = false
    @State private var milestoneMessage = ""
    @State private var hasSyncedPersistedRevealState = false
    @State private var showBirthdayLookup = false
    @State private var showSharedIdentitySheet = false
    @State private var selectedSavedPerson: SavedLookupPerson? = nil
    @State private var savedPeople: [SavedLookupPerson] = []
    @State private var selectedDetailPerson: SavedLookupPerson? = nil
    @State private var revealedDeletePersonID: String? = nil
    @State private var ritualCTAShimmer = false

    private var profile: HomePatternProfile {
        guard let archetype = store.currentArchetype else { return .fallback }
        return HomePatternProfile(archetype: archetype)
    }

    private var output: HomePatternOutput {
        HomePatternEngine.output(for: profile, date: Date())
    }

    private var isDailyReadComplete: Bool {
        store.ritualCompletedToday
    }

    private var dailyReadAccent: Color {
        isDailyReadComplete ? ZD.Color.success : homeAccent
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HomeAtmosphere(tint: homeAccent)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 10)

                        ritualPreviewCard
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)

                        todayPullSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)

                        sharedIdentitySection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)

                        savedReadsSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 22)

                        premiumDepthSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 24)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.bottom, 180)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToDailyRitual) {
                ritualDestinationView
            }
            .navigationDestination(item: $selectedDetailPerson) { person in
                PeopleDetailView(person: person)
            }
            .sheet(isPresented: $showBirthdayLookup) {
                BirthdayLookupSheet(
                    selectedPerson: selectedSavedPerson,
                    onSave: loadSavedPeople
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    selectedSavedPerson = nil
                }
            }
            .sheet(isPresented: $showSharedIdentitySheet) {
                sharedIdentitySheet
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
                    .presentationBackground(ZD.Color.bg)
            }
            .overlay(alignment: .top) {
                if showMilestoneBanner {
                    milestoneBanner
                        .padding(.top, 14)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(5)
                }
            }
            .onAppear {
                syncPersistedDailyRevealStateIfNeeded()

                withAnimation(.easeOut(duration: 0.7)) {
                    appeared = true
                }

                ritualCTAShimmer = false
                if !isDailyReadComplete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        withAnimation(.linear(duration: 1.9)) {
                            ritualCTAShimmer = true
                        }
                    }
                }

                loadSavedPeople()
            }
            .onChange(of: store.todayRevealed) { _, isRevealed in
                syncDailyRevealState(isRevealed: isRevealed)
            }
            .onChange(of: store.dailyRevealResetToken) { _, _ in
                isOpeningDailyRitual = false
                navigateToDailyRitual = false
                hasSyncedPersistedRevealState = false
                syncPersistedDailyRevealStateIfNeeded()
            }
        }
    }

    // MARK: - Saved Reads Section

    private var savedReadsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Saved Reads")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(ZD.Color.muted)

                Spacer()

                if !savedPeople.isEmpty {
                    Text("\(savedPeople.count)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(ZD.Color.accent)
                }
            }

            lookupSavedReadCard

            if savedPeople.isEmpty {
                emptySavedReadsNote
            } else {
                VStack(spacing: 10) {
                    ForEach(savedPeople.prefix(4)) { person in
                        savedPersonRow(person)
                    }
                }
            }
        }
    }

    private var lookupSavedReadCard: some View {
        Button {
            feedbackSoft()
            selectedSavedPerson = nil
            showBirthdayLookup = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(ZD.Color.accent.opacity(0.14))
                        .frame(width: 42, height: 42)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ZD.Color.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Create a Saved Read")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Enter a birthday and save their pattern here")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZD.Color.muted)
            }
            .padding(14)
            .background(savedReadBackground)
        }
        .buttonStyle(.plain)
    }

    private var emptySavedReadsNote: some View {
        Text("Saved Reads fills in after you save someone")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
            .padding(.horizontal, 4)
            .padding(.top, 2)
    }

    private func savedPersonRow(_ person: SavedLookupPerson) -> some View {
        ZStack(alignment: .trailing) {
            Button {
                feedbackSoft()
                deleteSavedPerson(person)
            } label: {
                ZStack {
                    Circle()
                        .fill(ZD.Color.error.opacity(0.92))
                        .frame(width: 44, height: 44)

                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 72, height: 72, alignment: .trailing)
                .padding(.trailing, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .opacity(revealedDeletePersonID == person.id ? 1 : 0)
            .allowsHitTesting(revealedDeletePersonID == person.id)
            .zIndex(2)

            savedPersonRowContent(person)
                .offset(x: revealedDeletePersonID == person.id ? -66 : 0)
                .contentShape(Rectangle())
                .allowsHitTesting(revealedDeletePersonID != person.id)
                .zIndex(1)
                .onTapGesture {
                    if revealedDeletePersonID == person.id {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            revealedDeletePersonID = nil
                        }
                    } else {
                        feedbackSoft()
                        selectedDetailPerson = person
                    }
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = abs(value.translation.height)

                            guard abs(horizontal) > vertical else { return }

                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                if horizontal < -24 {
                                    revealedDeletePersonID = person.id
                                } else if horizontal > 18 {
                                    revealedDeletePersonID = nil
                                }
                            }
                        }
                )
        }
    }

    private func savedPersonRowContent(_ person: SavedLookupPerson) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.cardAlt.opacity(0.88))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                    )

                Text(person.initials)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Text(person.patternTitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(14)
        .background(savedReadBackground)
    }

    private var savedReadBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(ZD.Color.card.opacity(0.74))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.15), lineWidth: 1)
            )
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Today")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(2)
                .foregroundStyle(ZD.Color.muted)

            Text(headerLine)
                .font(.system(size: 31, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var ritualPreviewCard: some View {
        Button {
            triggerReveal()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.98),
                                ZD.Color.cardAlt.opacity(0.90),
                                ZD.Color.card.opacity(0.86)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                DailyRitualBackdrop()

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        statePill

                        Spacer()

                        HStack(spacing: 8) {
                            statOrb(value: "\(store.points)", label: "POINTS")
                            statOrb(value: "\(store.streak)", label: "STREAK")
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(ritualHeadline)
                            .font(.system(size: 25, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineSpacing(0)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(ritualInsight)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    dailyRevealCTA

                    Text(ritualFooterLine)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(ZD.Color.muted.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 0)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(dailyReadAccent.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: dailyReadAccent.opacity(0.10), radius: 22, y: 12)
        }
        .buttonStyle(.plain)
        .scaleEffect(isOpeningDailyRitual ? 0.985 : 1)
        .opacity(isOpeningDailyRitual ? 0.82 : 1)
        .animation(.easeInOut(duration: 0.18), value: isOpeningDailyRitual)
    }

    private var premiumDepthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium depth")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.muted)

            Button {
                feedbackSoft()
                if !store.effectivePremiumAccess {
                    store.activatePremiumPreview()
                }
                store.selectedTab = .blueprint
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(ZD.Color.premium.opacity(0.16))
                            .frame(width: 42, height: 42)

                        Image(systemName: store.effectivePremiumAccess ? "crown.fill" : "lock.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(ZD.Color.premium)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(premiumDepthTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(premiumDepthSubtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(ZD.Color.muted)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(ZD.Color.card.opacity(0.78))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(ZD.Color.premium.opacity(0.16), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            Text(premiumDepthStatusLine)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ZD.Color.muted.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var premiumDepthTitle: String {
        store.effectivePremiumAccess ? "Premium is active" : "Unlock deeper Pattern"
    }

    private var premiumDepthSubtitle: String {
        store.effectivePremiumAccess ? "Open the Pattern tab to go deeper" : "Preview the premium layers before they unlock"
    }

    private var premiumDepthStatusLine: String {
        if store.hasActivePremiumPreview {
            return store.premiumPreviewStatusLine
        }

        if store.hasPremiumTrialUnlocked {
            return "Reward-based premium is active right now"
        }

        if store.effectivePremiumAccess {
            return "Premium access is active"
        }

        return "Use 50 points in Rewards for a one-day Connect preview"
    }

    private var famousPattern: FamousPattern {
        FamousPatternCatalog.pattern(for: store.currentUser?.archetypeId ?? "")
    }

    private var exactFamousPattern: FamousPattern? {
        FamousPatternCatalog.exactPattern(for: store.currentUser?.archetypeId ?? "")
    }

    private var sharedIdentitySectionTitle: String {
        "Shared identity"
    }

    private var sharedIdentityRowTitle: String {
        famousPattern.name
    }

    private var sharedIdentityRowSubtitle: String {
        famousPattern.patternTitle
    }

    private var sharedIdentitySheetTitle: String {
        famousPattern.name
    }

    private var sharedIdentitySheetSubtitle: String {
        famousPattern.patternTitle
    }

    private var sharedIdentitySheetBody: String {
        famousPattern.line
    }

    private var sharedIdentitySheetNote: String {
        exactFamousPattern == nil
            ? "A famous person with the closest matching pattern"
            : "A real person with the same exact signs"
    }

    private var todayPullSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keep going")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.muted)

            VStack(spacing: 10) {
                // Pattern
                Button {
                    feedbackSoft()
                    store.selectedTab = .blueprint
                } label: {
                    pullRow(
                        icon: "book.fill",
                        title: "Pattern",
                        subtitle: "The deeper read behind today"
                    )
                }

                // Connect
                Button {
                    feedbackSoft()
                    store.selectedTab = .connect
                } label: {
                    pullRow(
                        icon: "person.2.fill",
                        title: "Connect",
                        subtitle: "Find people who fit this rhythm"
                    )
                }

            }
        }
    }

    private var sharedIdentitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sharedIdentitySectionTitle)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.muted)

            Button {
                feedbackSoft()
                showSharedIdentitySheet = true
            } label: {
                sharedIdentityRow
            }
            .buttonStyle(.plain)
        }
    }

    private func pullRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.premium.opacity(0.16))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZD.Color.premium)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.card.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var sharedIdentityRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.premium.opacity(0.16))
                    .frame(width: 42, height: 42)

                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZD.Color.premium)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(sharedIdentityRowTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(sharedIdentityRowSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.8))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.card.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var sharedIdentitySheet: some View {
        ZStack {
            ZD.Color.bg
                .overlay(
                    RadialGradient(
                        colors: [
                            homeAccent.opacity(0.14),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 24,
                        endRadius: 420
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.12),
                            .clear,
                            ZD.Color.premium.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Capsule()
                        .fill(ZD.Color.border.opacity(0.45))
                        .frame(width: 42, height: 5)
                        .frame(maxWidth: .infinity)

                    Text(sharedIdentitySectionTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(ZD.Color.muted)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(sharedIdentitySheetTitle)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(sharedIdentitySheetSubtitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(ZD.Color.textSecondary)

                        Text(sharedIdentitySheetBody)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineSpacing(4)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ZD.Color.card.opacity(0.94),
                                        ZD.Color.cardAlt.opacity(0.84)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                            )
                    )

                    Text(sharedIdentitySheetNote)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        feedbackSoft()
                        showSharedIdentitySheet = false
                        store.selectedTab = .blueprint
                    } label: {
                        Text("Open Pattern")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(.black)
                            .background(Capsule().fill(ZD.Color.accent))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .presentationBackground(ZD.Color.bg)
    }

    // MARK: - Daily Home CTA/Copy helpers
    private var primaryCTA: String {
        isDailyReadComplete ? "Read saved for today" : "Open today’s reveal"
    }

    private var ritualFooterLine: String {
        isDailyReadComplete
            ? "Saved for today. Unlocks tomorrow."
            : "One read today. Then it locks in."
    }

    private var statePill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(dailyReadAccent)
                .frame(width: 7, height: 7)

            Text("Daily reveal")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(dailyReadAccent.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(dailyReadAccent.opacity(0.26), lineWidth: 1)
                )
        )
    }

    private var dailyRevealCTA: some View {
        Button {
            triggerReveal()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(
                        isDailyReadComplete
                        ? AnyShapeStyle(Color(red: 0.76, green: 0.77, blue: 0.79))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.78, blue: 0.47),
                                    Color(red: 0.84, green: 0.68, blue: 0.28),
                                    Color(red: 0.97, green: 0.89, blue: 0.63),
                                    Color(red: 0.76, green: 0.58, blue: 0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )

                if !isDailyReadComplete {
                    shimmerReflection
                }

                HStack(spacing: 10) {
                    if isDailyReadComplete {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .bold))
                    }

                    Text(isOpeningDailyRitual ? "Opening..." : primaryCTA)
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(isDailyReadComplete ? Color.black.opacity(0.92) : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isOpeningDailyRitual)
        .scaleEffect(isOpeningDailyRitual ? 0.985 : 1)
        .animation(.easeInOut(duration: 0.18), value: isOpeningDailyRitual)
    }

    private var shimmerReflection: some View {
        Text(primaryCTA)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.clear)
            .overlay(
                GeometryReader { proxy in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.06),
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.95),
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.06),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 140, height: proxy.size.height + 12)
                        .rotationEffect(.degrees(12))
                        .offset(x: ritualCTAShimmer ? proxy.size.width + 160 : -160)
                }
            )
            .mask(
                Text(primaryCTA)
                    .font(.system(size: 14, weight: .bold))
            )
            .allowsHitTesting(false)
    }

    private func statOrb(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(label)
                .font(.system(size: 7, weight: .bold))
                .tracking(0.9)
                .foregroundStyle(ZD.Color.muted.opacity(0.86))
        }
        .frame(width: 46, height: 46)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.12), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var ritualDestinationView: some View {
        if store.currentUser != nil {
            DailyRitualView()
        } else {
            Text("Ritual not ready yet")
                .foregroundStyle(ZD.Color.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ZD.Color.bg.ignoresSafeArea())
        }
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

    private var headerLine: String {
        switch output.state {
        case .aligned:
            return userLead("your rhythm looks steady")
        case .drifting:
            return userLead("something deserves a second look")
        case .reactive:
            return userLead("slow the first move")
        }
    }

    private func userLead(_ line: String) -> String {
        guard let name = store.currentUser?.name.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return line.prefix(1).uppercased() + line.dropFirst()
        }

        return "\(name), \(line)"
    }

    private var homeAccent: Color {
        ZD.Color.accent
    }

    private var ritualHeadline: String {
        isDailyReadComplete ? "Your daily read is complete" : output.hero
    }

    private var ritualInsight: String {
        isDailyReadComplete ? "Today is locked in" : output.insight
    }

    private func triggerReveal() {
        guard !isOpeningDailyRitual else { return }
        guard store.currentArchetype != nil else { return }

        feedbackSoft()
        isOpeningDailyRitual = true

        if !store.todayRevealed {
            let previousStreak = store.streak
            store.awardDailyRevealPoints(context: context)
            showMilestoneIfNeeded(previousStreak: previousStreak, newStreak: store.streak)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            navigateToDailyRitual = true
            feedbackReveal()
            isOpeningDailyRitual = false
        }
    }

    private func syncPersistedDailyRevealStateIfNeeded() {
        guard !hasSyncedPersistedRevealState else { return }
        hasSyncedPersistedRevealState = true
        syncDailyRevealState(isRevealed: store.todayRevealed)
    }

    private func syncDailyRevealState(isRevealed: Bool) {
        if !isRevealed {
            isOpeningDailyRitual = false
            navigateToDailyRitual = false
        }
    }

    private func showMilestoneIfNeeded(previousStreak: Int, newStreak: Int) {
        let milestones = [7, 14, 30]
        guard newStreak > previousStreak,
              milestones.contains(newStreak) else { return }

        milestoneMessage = milestoneMessage(for: newStreak)

        withAnimation(.spring(response: 0.48, dampingFraction: 0.82)) {
            showMilestoneBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.28)) {
                showMilestoneBanner = false
            }
        }
    }

    private func milestoneMessage(for streak: Int) -> String {
        switch streak {
        case 7: return "7-day pattern line started"
        case 14: return "14 days of signal"
        case 30: return "30 days of pattern recognition"
        default: return "\(streak)-day streak"
        }
    }

    private func feedbackSoft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    private func feedbackReveal() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // Remove duplicate savedPeople and SavedLookupPerson definitions
    // Removed: private var savedPeople: [SavedLookupPerson]
    // Removed: private struct SavedLookupPerson

    private func deleteSavedPerson(_ person: SavedLookupPerson) {
        var existing = UserDefaults.standard.stringArray(forKey: "saved_people") ?? []
        existing.removeAll { $0 == person.id }
        UserDefaults.standard.set(existing, forKey: "saved_people")
        loadSavedPeople()
        revealedDeletePersonID = nil
    }

    private func loadSavedPeople() {
        savedPeople = SavedLookupPerson.loadAll()
    }
}

// MARK: - Birthday Lookup

private struct BirthdayLookupSheet: View {
    let selectedPerson: SavedLookupPerson?
    let onSave: () -> Void

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()
    @State private var hasRevealed = false
    @State private var savedMessage: String? = nil
    @State private var showCompareRead = false
    @State private var showShareSheet = false
    @State private var shareText = ""

    private var westernSign: LookupWesternSign {
        LookupWesternSign.sign(for: birthday)
    }

    private var chineseSign: LookupChineseSign {
        LookupChineseSign.sign(for: birthday)
    }

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "This person" : trimmed
    }

    private var patternTitle: String {
        "\(westernSign.displayName) × \(chineseSign.displayName)"
    }

    private var displayedPatternTitle: String {
        selectedPerson?.patternTitle ?? patternTitle
    }

    private var readLine: String {
        LookupPatternCopy.readLine(western: westernSign, chinese: chineseSign, name: displayName)
    }

    private var userPatternTitle: String {
        store.currentArchetype?.title ?? "your pattern"
    }

    private var compareClicksLine: String {
        switch westernSign {
        case .aries, .leo, .sagittarius:
            return "Their fire can pull you into motion. If your pattern has been stuck, they may wake something up fast."
        case .taurus, .virgo, .capricorn:
            return "Their earth can make the connection feel more grounded. This works best when neither of you rush the read."
        case .gemini, .libra, .aquarius:
            return "Their air keeps the exchange moving. Conversation may be the first place this starts to click."
        case .cancer, .scorpio, .pisces:
            return "Their water reads beneath the surface. This can feel familiar fast if both of you stay honest."
        }
    }

    private var compareCatchLine: String {
        switch chineseSign {
        case .rat, .monkey, .dragon:
            return "They may move quicker than they explain. The catch is trying to read their next move before they have made it."
        case .ox, .rooster, .snake:
            return "They may hold more back than they show. The catch is mistaking control for distance."
        case .tiger, .horse, .dog:
            return "They need room to choose. The catch is pressing for certainty before the rhythm has settled."
        case .rabbit, .goat, .pig:
            return "They are more affected by tone than they may admit. The catch is thinking softness means simplicity."
        }
    }

    private var compareKnowLine: String {
        "Your \(userPatternTitle) does not need to solve \(displayName) immediately. Watch what repeats before deciding what it means."
    }

    private var generatedShareText: String {
        """
        Zodian read \(displayName) as \(displayedPatternTitle).

        \(readLine)

        Quick signal:
        \(LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign))
        """
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZD.Color.bg.ignoresSafeArea()

                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(0.26),
                        .clear,
                        ZD.Color.cardAlt.opacity(0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Read someone")
                                .font(.system(size: 34, weight: .regular, design: .serif))
                                .foregroundStyle(ZD.Color.textPrimary)

                            Text("Enter a birthday and get the quick pattern behind them")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        lookupInputCard

                        if hasRevealed {
                            lookupResultCard
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 22)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(ZD.Color.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            guard let selectedPerson else { return }
            name = selectedPerson.name

            if let savedDate = selectedPerson.birthday {
                birthday = savedDate
            }

            hasRevealed = true
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
        }
    }

    private var lookupInputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)
                    .textCase(.uppercase)
                    .tracking(1.2)

                TextField("Someone you’re curious about", text: $name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .padding(14)
                    .background {
                        sheetPanelFieldBackground
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Birthday")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)
                    .textCase(.uppercase)
                    .tracking(1.2)

                DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(ZD.Color.accent)
            }

            Button {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                    hasRevealed = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))

                    Text(hasRevealed ? "Refresh the read" : "Reveal their pattern")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(ZD.Color.accent))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background {
            sheetPanelBackground
        }
    }

    private var lookupResultCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(displayedPatternTitle)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                }

                Spacer()

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)
            }

            Text(readLine)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Quick signal")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign))
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                lookupMiniAction(title: "Compare", icon: "arrow.left.arrow.right")
                lookupMiniAction(title: "Save", icon: "bookmark.fill")
                lookupMiniAction(title: "Share", icon: "square.and.arrow.up")
            }

            if let savedMessage {
                Text(savedMessage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .transition(.opacity)
            }

            if showCompareRead {
                compareReadCard
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(18)
        .background {
            sheetPanelBackground
        }
    }

    private var compareReadCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("You × Them")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(1.2)

            compareLine(title: "Where it clicks", text: compareClicksLine)
            compareLine(title: "Where it catches", text: compareCatchLine)
            compareLine(title: "What to know", text: compareKnowLine)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func compareLine(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func lookupMiniAction(title: String, icon: String) -> some View {
        Button {
            handleLookupAction(title: title)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))

                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(ZD.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ZD.Color.cardAlt.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func handleLookupAction(title: String) {
        switch title {
        case "Compare":
            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                showCompareRead.toggle()
            }
        case "Save":
            savePerson()
        case "Share":
            shareText = generatedShareText
            showShareSheet = true
        default:
            break
        }
    }

    private func savePerson() {
        let timestamp = Int(birthday.timeIntervalSince1970)
        let person = "\(displayName)|\(displayedPatternTitle)|\(timestamp)"

        var existing = UserDefaults.standard.stringArray(forKey: "saved_people") ?? []

        if !existing.contains(person) {
            existing.append(person)
            UserDefaults.standard.set(existing, forKey: "saved_people")
            onSave()
            savedMessage = "Saved"
        } else {
            savedMessage = "Already saved"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            savedMessage = nil
        }
    }

    private var sheetPanelBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
            )
    }

    private var sheetPanelFieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(ZD.Color.cardAlt.opacity(0.72))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
            )
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum LookupWesternSign: String {
    case aries, taurus, gemini, cancer, leo, virgo, libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var displayName: String { rawValue.capitalized }

    static func sign(for date: Date) -> LookupWesternSign {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        switch (month, day) {
        case (3, 21...31), (4, 1...20): return .aries
        case (4, 21...30), (5, 1...21): return .taurus
        case (5, 22...31), (6, 1...21): return .gemini
        case (6, 22...30), (7, 1...23): return .cancer
        case (7, 24...31), (8, 1...23): return .leo
        case (8, 24...31), (9, 1...23): return .virgo
        case (9, 24...30), (10, 1...23): return .libra
        case (10, 24...31), (11, 1...22): return .scorpio
        case (11, 23...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...20): return .capricorn
        case (1, 21...31), (2, 1...19): return .aquarius
        default: return .pisces
        }
    }
}

enum LookupChineseSign: String {
    case rat, ox, tiger, rabbit, dragon, snake, horse, goat, monkey, rooster, dog, pig

    var displayName: String { rawValue.capitalized }

    static func sign(for date: Date) -> LookupChineseSign {
        let year = Calendar.current.component(.year, from: date)
        let signs: [LookupChineseSign] = [.rat, .ox, .tiger, .rabbit, .dragon, .snake, .horse, .goat, .monkey, .rooster, .dog, .pig]
        let index = ((year - 1900) % 12 + 12) % 12
        return signs[index]
    }
}

private enum LookupPatternCopy {
    static func readLine(western: LookupWesternSign, chinese: LookupChineseSign, name: String) -> String {
        switch chinese {
        case .rat:
            return "\(name) probably notices openings fast. Clever read, quick timing, not always easy to pin down."
        case .ox:
            return "\(name) may move slower than expected, but there’s real force once they decide"
        case .tiger:
            return "\(name) carries restless heat. They need movement, honesty, and room to choose."
        case .rabbit:
            return "\(name) looks softer than they are. Calm outside, selective underneath."
        case .dragon:
            return "\(name) has presence. Even when they’re quiet, the room tends to notice."
        case .snake:
            return "\(name) reads more than they say. Charm outside, strategy underneath."
        case .horse:
            return "\(name) needs freedom in the room. Too much pressure and they start looking for the exit."
        case .goat:
            return "\(name) is more sensitive than they may admit. Comfort matters more than it looks."
        case .monkey:
            return "\(name) thinks fast and adapts faster. If it gets boring, they feel it immediately."
        case .rooster:
            return "\(name) notices details and likes things clear. Messy energy will not go unseen."
        case .dog:
            return "\(name) watches for trust. Once something feels off, they may not forget it quickly."
        case .pig:
            return "\(name) wants things to feel real and generous. If they care, they usually mean it."
        }
    }

    static func signalLine(western: LookupWesternSign, chinese: LookupChineseSign) -> String {
        "\(western.displayName) gives the first impulse. \(chinese.displayName) shows how it plays out over time."
    }
}


// MARK: - People Detail View

private struct PeopleDetailView: View {
    let person: SavedLookupPerson

    @EnvironmentObject private var store: AppStore
    @State private var showShareSheet = false

    private var birthday: Date {
        person.birthday ?? Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()
    }

    private var westernSign: LookupWesternSign {
        LookupWesternSign.sign(for: birthday)
    }

    private var chineseSign: LookupChineseSign {
        LookupChineseSign.sign(for: birthday)
    }

    private var readLine: String {
        LookupPatternCopy.readLine(western: westernSign, chinese: chineseSign, name: person.name)
    }

    private var signalLine: String {
        LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign)
    }

    private var userPatternTitle: String {
        store.currentArchetype?.title ?? "your pattern"
    }

    private var compareClicksLine: String {
        switch westernSign {
        case .aries, .leo, .sagittarius:
            return "Their fire can pull you into motion. If your pattern has been stuck, they may wake something up fast."
        case .taurus, .virgo, .capricorn:
            return "Their earth can make the connection feel more grounded. This works best when neither of you rush the read."
        case .gemini, .libra, .aquarius:
            return "Their air keeps the exchange moving. Conversation may be the first place this starts to click."
        case .cancer, .scorpio, .pisces:
            return "Their water reads beneath the surface. This can feel familiar fast if both of you stay honest."
        }
    }

    private var compareCatchLine: String {
        switch chineseSign {
        case .rat, .monkey, .dragon:
            return "They may move quicker than they explain. The catch is trying to read their next move before they have made it."
        case .ox, .rooster, .snake:
            return "They may hold more back than they show. The catch is mistaking control for distance."
        case .tiger, .horse, .dog:
            return "They need room to choose. The catch is pressing for certainty before the rhythm has settled."
        case .rabbit, .goat, .pig:
            return "They are more affected by tone than they may admit. The catch is thinking softness means simplicity."
        }
    }

    private var compareKnowLine: String {
        "Your \(userPatternTitle) does not need to solve \(person.name) immediately. Watch what repeats before deciding what it means."
    }

    private var shareText: String {
        """
        Zodian read \(person.name) as \(person.patternTitle).

        \(readLine)

        Quick signal:
        \(signalLine)
        """
    }

    var body: some View {
        ZStack {
            detailBackground

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    heroSection
                    patternReadSection
                    quickSignalSection
                    compareSection
                    actionSection
                }
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.top, 24)
                .padding(.bottom, 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
        }
    }

    private var detailBackground: some View {
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
        }
        .ignoresSafeArea()
    }

    private var heroSection: some View {
        VStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.cardAlt.opacity(0.82))
                    .frame(width: 94, height: 94)
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.24), lineWidth: 1)
                    )
                    .shadow(color: ZD.Color.glow.opacity(0.20), radius: 16, x: 0, y: 10)

                Text(person.initials)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
            }

            VStack(spacing: 6) {
                Text(person.name)
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(person.patternTitle)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var patternReadSection: some View {
        detailPanel {
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Pattern read", color: ZD.Color.muted)

                Text(readLine)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var quickSignalSection: some View {
        detailPanel {
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Quick signal", color: ZD.Color.muted)

                Text(signalLine)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var compareSection: some View {
        detailPanel {
            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("You × Them", color: ZD.Color.accent)

                compareLine(title: "Where it clicks", text: compareClicksLine)
                compareLine(title: "Where it catches", text: compareCatchLine)
                compareLine(title: "What to know", text: compareKnowLine)
            }
        }
    }

    private var actionSection: some View {
        HStack(spacing: 10) {
            Button {
                showShareSheet = true
            } label: {
                actionPill(title: "Share", icon: "square.and.arrow.up")
            }
            .buttonStyle(.plain)

            Button {
                // Placeholder for future compare history / notes.
            } label: {
                actionPill(title: "Save note", icon: "text.badge.plus")
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }

    private func compareLine(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func actionPill(title: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(ZD.Color.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func detailPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.22), radius: 10, x: 0, y: 7)
            )
    }
}

// MARK: - Saved Reads Model

private struct SavedLookupPerson: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let patternTitle: String
    let birthday: Date?

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let initialString = String(letters).uppercased()
        return initialString.isEmpty ? "?" : initialString
    }

    static func loadAll() -> [SavedLookupPerson] {
        let rawValues = UserDefaults.standard.stringArray(forKey: "saved_people") ?? []

        return rawValues.reversed().compactMap { value in
            let parts = value.split(separator: "|").map(String.init)
            guard parts.count >= 2 else { return nil }

            let savedBirthday: Date?
            if parts.count >= 3, let timestamp = Double(parts[2]) {
                savedBirthday = Date(timeIntervalSince1970: timestamp)
            } else {
                savedBirthday = nil
            }

            return SavedLookupPerson(
                id: value,
                name: parts[0],
                patternTitle: parts[1],
                birthday: savedBirthday
            )
        }
    }
}

// MARK: - Atmosphere

private struct HomeAtmosphere: View {
    let tint: Color

    @State private var breathe = false

    var body: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        tint.opacity(breathe ? 0.20 : 0.10),
                        ZD.Color.card.opacity(0.12),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 18,
                    endRadius: 620
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(breathe ? 0.10 : 0.05),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 40,
                    endRadius: 520
                )
            )
            .overlay(StarField().opacity(0.34))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
    }
}

private struct DailyRitualBackdrop: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    ZD.Color.accent.opacity(0.06),
                    .clear,
                    ZD.Color.premium.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.12),
                            ZD.Color.accent.opacity(0.04),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220, height: 220)
                .blur(radius: 16)
                .offset(x: 160 + (drift ? 6 : -6), y: -96 + (drift ? 4 : -4))

            Circle()
                .stroke(ZD.Color.premium.opacity(0.12), lineWidth: 1)
                .frame(width: 160, height: 160)
                .offset(x: 156 + (drift ? 4 : -4), y: 6 + (drift ? 2 : -2))

            Circle()
                .fill(ZD.Color.cardAlt.opacity(0.26))
                .frame(width: 118, height: 118)
                .blur(radius: 10)
                .offset(x: -34 + (drift ? 3 : -3), y: 132 + (drift ? 2 : -2))

        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 6.8).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}

private struct StarField: View {
    private let points: [CGPoint] = [
        CGPoint(x: 0.12, y: 0.18), CGPoint(x: 0.82, y: 0.14),
        CGPoint(x: 0.68, y: 0.28), CGPoint(x: 0.22, y: 0.42),
        CGPoint(x: 0.91, y: 0.44), CGPoint(x: 0.36, y: 0.62),
        CGPoint(x: 0.74, y: 0.72), CGPoint(x: 0.14, y: 0.82)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(points.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.22 : 0.14))
                        .frame(width: index.isMultiple(of: 3) ? 2.2 : 1.4)
                        .position(
                            x: geo.size.width * points[index].x,
                            y: geo.size.height * points[index].y
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Home Pattern Engine

private enum HomePatternState {
    case aligned
    case drifting
    case reactive
}

private struct HomePatternOutput {
    let state: HomePatternState
    let pill: String
    let hero: String
    let insight: String
    let underneath: String
    let tension: String
    let cta: String
}

private struct HomePatternProfile {
    let id: String
    let emotionalPattern: String
    let growthPath: String
    let strengths: [String]
    let shadows: [String]

    var idDisplayName: String {
        id
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " × ")
    }

    static let fallback = HomePatternProfile(
        id: "fallback",
        emotionalPattern: "The same reaction keeps asking for attention",
        growthPath: "Clarity starts when the first reaction is not the final answer",
        strengths: ["Aware", "Adaptive", "Perceptive"],
        shadows: ["Overthinking", "Reacting too quickly"]
    )

    init(archetype: Archetype) {
        self.id = archetype.id
        self.emotionalPattern = archetype.emotionalPattern
        self.growthPath = archetype.growthPath
        self.strengths = archetype.strengths
        self.shadows = archetype.shadows
    }

    private init(
        id: String,
        emotionalPattern: String,
        growthPath: String,
        strengths: [String],
        shadows: [String]
    ) {
        self.id = id
        self.emotionalPattern = emotionalPattern
        self.growthPath = growthPath
        self.strengths = strengths
        self.shadows = shadows
    }
}

private enum HomePatternEngine {
    static func output(for profile: HomePatternProfile, date: Date) -> HomePatternOutput {
        let state = state(for: profile, date: date)
        return seededCopy(for: profile.id, state: state)
    }

    private static func state(for profile: HomePatternProfile, date: Date) -> HomePatternState {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let value = abs(profile.id.hashValue + day) % 3

        switch value {
        case 0: return .aligned
        case 1: return .drifting
        default: return .reactive
        }
    }

    private static func seededCopy(for id: String, state: HomePatternState) -> HomePatternOutput {
        switch id.lowercased() {
        case "pisces-dog":
            return HomePatternOutput(
                state: state,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue tells you where to steady yourself",
                cta: "Open today’s reveal"
            )

        case "aries-horse":
            return HomePatternOutput(
                state: state,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue is where the day speeds up",
                cta: "Open today’s reveal"
            )

        case "libra-snake":
            return HomePatternOutput(
                state: state,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue is where you hesitate",
                cta: "Open today’s reveal"
            )

        default:
            return fallbackCopy(state: state)
        }
    }

    private static func fallbackCopy(state: HomePatternState) -> HomePatternOutput {
        switch state {
        case .aligned:
            return HomePatternOutput(
                state: .aligned,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue is easy to trust",
                cta: "Open today’s reveal"
            )

        case .drifting:
            return HomePatternOutput(
                state: .drifting,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue is small, but it matters",
                cta: "Open today’s reveal"
            )

        case .reactive:
            return HomePatternOutput(
                state: .reactive,
                pill: "Daily reveal",
                hero: "Your daily read is ready",
                insight: "See what today is asking of you",
                underneath: "Built from both systems and tuned for today",
                tension: "The first clue tells you where to pause",
                cta: "Open today’s reveal"
            )
        }
    }
}
