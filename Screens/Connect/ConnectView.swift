import SwiftUI
import SwiftData
import UIKit

struct ConnectView: View {
    private struct MoodStyle {
        let label: String
        let chipAccent: Color
        let glowColors: [Color]
        let washColor: Color
        let washOpacity: Double
    }

    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]
    @Query(sort: \PassedProfile.createdAt, order: .reverse) private var passedProfiles: [PassedProfile]
    @Query(sort: \ConnectSwipeEvent.createdAt, order: .reverse) private var swipeEvents: [ConnectSwipeEvent]

    @StateObject private var vm = ConnectViewModel()

    @State private var isAnimatingSwipe = false
    @State private var pendingSwipeCommand: SwipeDeckView.SwipeCommand?
    @State private var deckRenderToken = UUID()

    @State private var selectedProfile: DeckProfile?
    @State private var showCelebration = false
    @State private var showPremiumSheet = false

    private var visibleProfiles: [DeckProfile] {
        vm.visibleProfiles(isPremium: store.effectivePremiumAccess)
    }

    private var hasReachedFreeLimit: Bool {
        vm.hasReachedFreeLimit(isPremium: store.effectivePremiumAccess)
    }

    private var moodStyle: MoodStyle {
        switch vm.selectedFilter {
        case .compatible:
            return MoodStyle(
                label: "Calm",
                chipAccent: Color(red: 0.74, green: 0.82, blue: 0.90),
                glowColors: [
                    Color(red: 0.34, green: 0.47, blue: 0.61).opacity(0.24),
                    Color(red: 0.74, green: 0.82, blue: 0.90).opacity(0.18),
                    .clear
                ],
                washColor: Color(red: 0.46, green: 0.60, blue: 0.74),
                washOpacity: 0.115
            )
        case .similar:
            return MoodStyle(
                label: "Familiar",
                chipAccent: ZD.Color.accent,
                glowColors: [
                    ZD.Color.forest.opacity(0.18),
                    ZD.Color.accent.opacity(0.08),
                    .clear
                ],
                washColor: ZD.Color.card,
                washOpacity: 0.10
            )
        case .newEnergy:
            return MoodStyle(
                label: "Electric",
                chipAccent: Color(red: 0.93, green: 0.81, blue: 0.49),
                glowColors: [
                    Color(red: 0.82, green: 0.66, blue: 0.22).opacity(0.19),
                    Color(red: 0.93, green: 0.81, blue: 0.49).opacity(0.14),
                    .clear
                ],
                washColor: Color(red: 0.70, green: 0.52, blue: 0.17),
                washOpacity: 0.112
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    heroSection
                    filterFlow
                    discoveryFlow
                    premiumPromptSection
                }
                .padding(.top, 8)
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.bottom, 120)
            }
            .background(connectBackground)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedProfile) { profile in
                NavigationStack {
                    ConnectProfileDetailView(
                        profile: profile,
                        isPremium: store.effectivePremiumAccess,
                        onPass: {
                            selectedProfile = nil
                            performSwipe(.pass, profile: profile)
                        },
                        onLike: {
                            selectedProfile = nil
                            performSwipe(.like, profile: profile)
                        }
                    )
                    .environmentObject(store)
                }
                .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumRewardsSheet(source: "connect")
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .overlay(alignment: .top) {
                VStack(spacing: 10) {
                    if vm.showLimitBanner {
                        limitBanner
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if vm.showUndoBanner, lastSwipeEvent != nil {
                        undoBanner
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.top, 12)
            }
            .overlay {
                if showCelebration, let match = vm.celebrationMatch {
                    MatchCelebrationView(
                        name: match.name,
                        compatibilityScore: match.compatibilityScore,
                        onClose: dismissCelebration
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(10)
                }
            }
            .onAppear {
                loadDeck()
            }
            .onChange(of: savedMatches.count) {
                guard !isAnimatingSwipe else { return }
                loadDeck(forceRefresh: true)
            }
            .onChange(of: passedProfiles.count) {
                guard !isAnimatingSwipe else { return }
                loadDeck(forceRefresh: true)
            }
            .onChange(of: swipeEvents.count) {
                guard !isAnimatingSwipe else { return }
                loadDeck(forceRefresh: true)
            }
            .onChange(of: store.effectivePremiumAccess) {
                loadDeck(forceRefresh: true)
            }
            .onChange(of: store.connectResetToken) {
                resetTransientPresentationState()
                vm.resetTransientState()
                DispatchQueue.main.async {
                    loadDeck(forceRefresh: true)
                }
            }
            .onChange(of: store.onboardingResetToken) {
                resetTransientPresentationState()
                vm.resetTransientState()
            }
            .onChange(of: vm.selectedFilter) {
                pendingSwipeCommand = nil
                isAnimatingSwipe = false
                loadDeck(forceRefresh: true)
                deckRenderToken = UUID()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: showCelebration)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: vm.showUndoBanner)
    }

    private var connectBackground: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: moodStyle.glowColors,
                    center: .topLeading,
                    startRadius: 40,
                    endRadius: 680
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.18),
                        moodStyle.washColor.opacity(moodStyle.washOpacity),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Color.white
                    .opacity(0.015)
                    .blendMode(.overlay)
            )
            .ignoresSafeArea()
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            deckCountPill

            VStack(alignment: .leading, spacing: 8) {
                Text("Find people who fit your rhythm")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(heroSubtitle)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 8)
    }

    private var deckCountPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text(deckStatusText)
                .font(ZD.Font.badge())
                .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.border.opacity(0.28), lineWidth: ZD.Stroke.thin)
                )
        )
        .fixedSize()
    }

    private var filterFlow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Choose a lane")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            Text("This changes who rises to the top of your room")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ConnectFilter.allCases) { filter in
                        filterChip(for: filter)
                    }
                }
                .padding(.trailing, 6)
                .padding(.vertical, 2)
            }
        }
    }

    private func filterChip(for filter: ConnectFilter) -> some View {
        let isSelected = vm.selectedFilter == filter

        return Button {
            guard vm.selectedFilter != filter else { return }
            feedbackSoft()
            pendingSwipeCommand = nil
            isAnimatingSwipe = false
            withAnimation(.spring(response: 0.22, dampingFraction: 0.84)) {
                vm.selectedFilter = filter
                deckRenderToken = UUID()
            }
        } label: {
            VStack(alignment: .center, spacing: 3) {
                Text(moodLabel(for: filter))
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(isSelected ? Color.black : ZD.Color.textPrimary)
                    .lineLimit(1)

                Text(filter.detail)
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? Color.black.opacity(0.62) : ZD.Color.muted.opacity(0.92))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minWidth: 120)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.92))

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(moodStyle.chipAccent.opacity(0.10))
                    } else {
                        Capsule()
                            .fill(ZD.Color.card)
                    }
                }
            )
            .overlay(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    } else {
                        Capsule()
                            .stroke(ZD.Color.border.opacity(0.45), lineWidth: ZD.Stroke.thin)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.25) : .clear,
                radius: isSelected ? 8 : 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(.plain)
    }

    private var discoveryFlow: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(vm.selectedFilter.subtitle)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                if !visibleProfiles.isEmpty {
                    swipeGuideText
                        .padding(.top, 1)
                }
            }
            .padding(.horizontal, 2)

            if visibleProfiles.isEmpty {
                emptyDeckCard
            } else {
                SwipeDeckView(
                    profiles: visibleProfiles,
                    mood: vm.selectedFilter,
                    isSwipeLocked: isAnimatingSwipe || hasReachedFreeLimit,
                    pendingCommand: $pendingSwipeCommand,
                    onSwipe: handleDeckSwipe,
                    onPreview: { profile in
                        selectedProfile = profile
                    },
                    onUndo: undoLastSwipe
                )
                .id(deckRenderToken)
                .frame(height: SwipeDeckView.preferredHeight)
                .frame(maxWidth: .infinity)
                .padding(.top, 2)
            }
        }
    }


    private var swipeGuideText: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.draw.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ZD.Color.accent.opacity(0.78))

            Text("Swipe to compare. Tap to open.")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var emptyDeckCard: some View {
        return TarotCardContainer {
            VStack(spacing: 16) {

                Image(systemName: hasReachedFreeLimit ? "crown.fill" : "sparkles.rectangle.stack.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(ZD.Color.accent)

                VStack(spacing: 6) {
                    Text(deckStatusPresentation.emptyStateTitle)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(deckStatusPresentation.emptyStateSubtitle)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.muted)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                }

                if !store.effectivePremiumAccess && hasReachedFreeLimit {
                    Button {
                        showPremiumSheet = true
                    } label: {
                        PremiumTileRow(
                            title: "Unlock more people",
                            subtitle: "Keep comparing today or come back tomorrow",
                            icon: "crown.fill",
                            isPremium: false
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 18)
        }
        .padding(.top, 4)
        .frame(minHeight: hasReachedFreeLimit && !store.effectivePremiumAccess ? 360 : 280)
    }

    private var premiumPromptSection: some View {
        Group {
            if store.effectivePremiumAccess {
                PremiumTileRow(
                    title: "Full room unlocked",
                    subtitle: "See every profile and keep comparing freely",
                    icon: "crown.fill",
                    isPremium: true,
                    showPremiumBadge: false
                )
                .padding(.top, 12)
            }
        }
    }

    private var limitBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(ZD.Color.accent)

            Text("Today’s free room is full")
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
        .zGoldGlow(active: true)
    }

    private var lastSwipeEvent: ConnectSwipeEvent? {
        swipeEvents.first
    }

    private var undoBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.uturn.backward")
                .foregroundStyle(ZD.Color.accent)

            Text("Last swipe restored")
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
        .zGoldGlow(active: true)
    }

    private var heroSubtitle: String {
        "Compare fit, timing, and chemistry"
    }

    private func moodLabel(for filter: ConnectFilter) -> String {
        filter.title
    }

    private var deckStatusPresentation: ConnectDeckStatusPresentation {
        ConnectPresentationBuilder.buildDeckStatus(
            isPremium: store.effectivePremiumAccess,
            profileCount: vm.profiles.count,
            remainingCount: vm.remainingCount(isPremium: store.effectivePremiumAccess),
            hasReachedFreeLimit: hasReachedFreeLimit
        )
    }

    private var deckStatusText: String {
        deckStatusPresentation.deckStatusText
    }

    private func loadDeck(forceRefresh: Bool = false) {
        store.loadUserIfNeeded(context: context)
        vm.loadDeck(
            user: store.currentUser,
            isPremium: store.effectivePremiumAccess,
            context: context,
            forceRefresh: forceRefresh
        )
    }

    private func resetTransientPresentationState() {
        selectedProfile = nil
        showCelebration = false
        pendingSwipeCommand = nil
        isAnimatingSwipe = false
    }

    private func handleDeckSwipe(_ action: SwipeAction, _ profile: DeckProfile) {
        performSwipe(action, profile: profile)
    }

    private func performSwipe(_ action: SwipeAction, profile: DeckProfile) {
        guard !visibleProfiles.isEmpty, !isAnimatingSwipe else { return }

        if hasReachedFreeLimit {
            vm.triggerLimitBanner()
            return
        }

        isAnimatingSwipe = true

        vm.applySwipe(
            action: action,
            profile: profile,
            context: context
        )

        if action == .like {
            saveMatch(profile: profile, showConfirmation: true)
        } else {
            savePassedProfile(profile: profile)
        }

        saveSwipeEvent(profile: profile, action: action)

        AnalyticsService.shared.track(
            .swipePerformed(
                action: action.rawValue,
                archetypeID: profile.archetypeId,
                score: profile.compatibilityScore,
                filter: vm.selectedFilter.rawValue,
                isPremium: store.effectivePremiumAccess
            )
        )

        feedbackSoft()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            pendingSwipeCommand = nil
            isAnimatingSwipe = false
            loadDeck(forceRefresh: true)

            if hasReachedFreeLimit {
                vm.triggerLimitBanner()
            }
        }
    }

    private func saveMatch(profile: DeckProfile, showConfirmation: Bool) {
        if savedMatches.contains(where: { $0.archetypeId == profile.archetypeId && $0.name == profile.name }) {
            if showConfirmation {
                vm.showCelebration(for: profile)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    showCelebration = true
                }
            }
            return
        }

        let primaryReason = profile.matchReasons.first
        let secondaryReason = profile.matchReasons.dropFirst().first

        let match = SavedMatch(
            name: profile.name,
            archetypeId: profile.archetypeId,
            archetypeTitle: profile.archetypeTitle,
            westernSignRaw: profile.westernSign.rawValue,
            chineseSignRaw: profile.chineseSign.rawValue,
            compatibilityScore: profile.compatibilityScore,
            matchStyleRaw: profile.matchStyle.rawValue,
            essence: profile.essence,
            connectionPrompt: profile.connectionPrompt,
            frictionNote: profile.frictionNote,
            intent: profile.intent,
            signalsRaw: signalsRaw(from: profile.signals),
            imageName: profile.imageName,
            imageAnchorRaw: imageAnchorRaw(for: profile.imageAnchor),
            primaryReasonTitle: primaryReason?.title ?? "Energetic Alignment",
            primaryReasonDetail: primaryReason?.detail ?? "There is something naturally compelling about this connection",
            secondaryReasonTitle: secondaryReason?.title ?? "",
            secondaryReasonDetail: secondaryReason?.detail ?? ""
        )

        context.insert(match)

        do {
            try context.save()
            AnalyticsService.shared.track(
                .matchSaved(
                    archetypeID: profile.archetypeId,
                    score: profile.compatibilityScore,
                    matchStyle: profile.matchStyle.rawValue,
                    intent: profile.intent,
                    source: showConfirmation ? "connect_swipe" : "connect_preview"
                )
            )
            if showConfirmation {
                vm.showCelebration(for: profile)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    showCelebration = true
                }
            }
        } catch {
            print("❌ Failed to save match: \(error)")
        }
    }

    private func savePassedProfile(profile: DeckProfile) {
        if passedProfiles.contains(where: { $0.archetypeId == profile.archetypeId && $0.name == profile.name }) {
            return
        }

        let passed = PassedProfile(name: profile.name, archetypeId: profile.archetypeId)
        context.insert(passed)

        do {
            try context.save()
        } catch {
            print("❌ Failed to save passed profile: \(error)")
        }
    }

    private func saveSwipeEvent(profile: DeckProfile, action: SwipeAction) {
        let event = ConnectSwipeEvent(
            name: profile.name,
            archetypeId: profile.archetypeId,
            westernSignRaw: profile.westernSign.rawValue,
            chineseSignRaw: profile.chineseSign.rawValue,
            compatibilityScore: profile.compatibilityScore,
            actionRaw: action.rawValue
        )

        context.insert(event)

        do {
            try context.save()
        } catch {
            print("❌ Failed to save swipe event: \(error)")
        }
    }

    private func undoLastSwipe() {
        guard let event = lastSwipeEvent, !isAnimatingSwipe else { return }

        if event.actionRaw == SwipeAction.like.rawValue {
            if let match = savedMatches.first(where: { $0.name == event.name && $0.archetypeId == event.archetypeId }) {
                let matchID = match.id
                let relatedMessages = try? context.fetch(
                    FetchDescriptor<ChatMessage>(
                        predicate: #Predicate { $0.matchID == matchID }
                    )
                )
                relatedMessages?.forEach { context.delete($0) }
                context.delete(match)
            }
        } else if event.actionRaw == SwipeAction.pass.rawValue {
            if let passed = passedProfiles.first(where: { $0.name == event.name && $0.archetypeId == event.archetypeId }) {
                context.delete(passed)
            }
        }

        vm.restoreDeckEntry(for: event, context: context)
        context.delete(event)

        do {
            try context.save()
            isAnimatingSwipe = true
            vm.triggerUndoBanner()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    isAnimatingSwipe = false
                    loadDeck(forceRefresh: true)
                }

            vm.dismissUndoBannerSoon()
        } catch {
            print("❌ Failed to undo swipe: \(error)")
        }
    }

    private func dismissCelebration() {
        showCelebration = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            vm.dismissCelebration()
        }
    }

    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.72)
    }

    private func imageAnchorRaw(for anchor: UnitPoint) -> String {
        switch anchor {
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .topLeading: return "topLeading"
        case .topTrailing: return "topTrailing"
        case .bottomLeading: return "bottomLeading"
        case .bottomTrailing: return "bottomTrailing"
        default: return "center"
        }
    }

    private func signalsRaw(from signals: [ConnectProfileSignal]) -> String {
        ConnectProfileSignal.storageString(from: signals)
    }
}

#Preview("Connect - Free") {
    let store = AppStore()
    store.updatePremiumStatus(.free)
    store.currentUser = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 631152000),
        westernSignRaw: "leo",
        chineseSignRaw: "dragon",
        archetypeId: "leo-dragon"
    )

    return ConnectView()
        .environmentObject(store)
        .modelContainer(
            for: [
                UserProfile.self,
                PointsLedgerItem.self,
                StreakDay.self,
                SavedDailyReading.self,
                SavedMatch.self,
                PassedProfile.self,
                ConnectSwipeEvent.self,
                ConnectDeckEntry.self
            ],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}

#Preview("Connect - Premium") {
    let store = AppStore()
    store.updatePremiumStatus(.premium)
    store.currentUser = UserProfile(
        name: "Ari",
        birthday: Date(timeIntervalSince1970: 915177600),
        westernSignRaw: "aries",
        chineseSignRaw: "rabbit",
        archetypeId: "aries-rabbit"
    )

    return ConnectView()
        .environmentObject(store)
        .modelContainer(
            for: [
                UserProfile.self,
                PointsLedgerItem.self,
                StreakDay.self,
                SavedDailyReading.self,
                SavedMatch.self,
                PassedProfile.self,
                ConnectSwipeEvent.self,
                ConnectDeckEntry.self
            ],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}
