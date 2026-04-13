import SwiftUI
import SwiftData
import UIKit

struct ConnectView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]
    @Query(sort: \PassedProfile.createdAt, order: .reverse) private var passedProfiles: [PassedProfile]
    @Query(sort: \ConnectSwipeEvent.createdAt, order: .reverse) private var swipeEvents: [ConnectSwipeEvent]

    @StateObject private var vm = ConnectViewModel()

    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var isAnimatingSwipe: Bool = false

    @State private var selectedProfile: DeckProfile?
    @State private var showCelebration = false

    private var visibleProfiles: [DeckProfile] {
        vm.visibleProfiles(isPremium: store.effectivePremiumAccess)
    }

    private var hasReachedFreeLimit: Bool {
        vm.hasReachedFreeLimit(isPremium: store.effectivePremiumAccess)
    }
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    heroSection
                    filterSection
                    discoveryDeckSection
                    actionHintSection
                    premiumPromptSection
                }
                .padding(.top, 12)
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.bottom, 120)
            }
            .background(connectBackground)
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
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
                        },
                        onSave: {
                            saveMatch(profile: profile, showConfirmation: true)
                            feedbackSoft()
                        }
                    )
                }
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
                vm.loadDeck(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )
            }
            .onChange(of: swipeEvents.count) { _ in
                guard !isAnimatingSwipe else { return }
                vm.loadDeck(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )
            }
            .onChange(of: store.effectivePremiumAccess) { _ in
                vm.loadDeck(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )
            }
            .onChange(of: store.connectResetToken) { _ in
                resetTransientPresentationState()
                vm.resetTransientState()
                vm.loadDeck(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )
            }
            .onChange(of: store.onboardingResetToken) { _ in
                resetTransientPresentationState()
                vm.resetTransientState()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showCelebration)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: vm.showUndoBanner)
    }
   
    // MARK: - Background

    private var connectBackground: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.forest.opacity(0.16),
                        .clear
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: 520
                )
            )
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
            .ignoresSafeArea()
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Energetic Discovery",
                subtitle: "Connection through resonance, not surface"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("Today’s Alignment")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Spacer(minLength: 10)

                        deckCountPill
                    }

                    Text(heroSubtitle)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Discover aligned personalities based on energetic compatibility.")
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var deckCountPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text(
                vm.deckStatusText(isPremium: store.effectivePremiumAccess)
            )
            .font(ZD.Font.badge())
            .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.border.opacity(0.42), lineWidth: ZD.Stroke.thin)
                )
        )
        .fixedSize()
    }
    // MARK: - Filters

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Filters",
                subtitle: "Choose the energy you want to explore"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ConnectFilter.allCases) { filter in
                        filterChip(for: filter)
                    }
                }
                .padding(.trailing, 6)
            }
        }
    }

    private func filterChip(for filter: ConnectFilter) -> some View {
        let isSelected = vm.selectedFilter == filter

        return Button {
            feedbackSoft()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                vm.selectedFilter = filter
                vm.reloadForFilter(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )
            }
        } label: {
            Text(filter.title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(isSelected ? Color.black : ZD.Color.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.card))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected
                            ? ZD.Color.accentSoft.opacity(0.35)
                            : ZD.Color.border.opacity(0.45),
                            lineWidth: ZD.Stroke.thin
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Deck

    private var discoveryDeckSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Suggested Match",
                subtitle: vm.selectedFilter.subtitle
            )

            ZStack {
                if visibleProfiles.isEmpty {
                    emptyDeckCard
                } else {
                    deckStack
                }
            }
            .frame(height: 620)
        }
    }

    private var deckStack: some View {
        ZStack {
            ForEach(Array(visibleProfiles.enumerated()), id: \.element.id) { index, profile in
                let isTop = index == 0

                ConnectCardView(
                    profile: profile,
                    isTopCard: isTop,
                    dragOffset: isTop ? dragOffset : .zero,
                    cardRotation: isTop ? cardRotation : 0,
                    stackedOffset: CGFloat(index) * 6,
                    stackedScale: 1.0 - (CGFloat(index) * 0.02),
                    likeOpacity: isTop ? min(max(dragOffset.width / 120, 0), 1) : 0,
                    passOpacity: isTop ? min(max(-dragOffset.width / 120, 0), 1) : 0,
                    onDrag: { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height

                        guard abs(horizontal) > abs(vertical) else { return }

                        dragOffset = CGSize(width: horizontal, height: 0)
                        cardRotation = Double(horizontal / 18)
                    },
                    onEnd: { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height

                        guard abs(horizontal) > abs(vertical) else {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                                dragOffset = .zero
                                cardRotation = 0
                            }
                            return
                        }

                        if horizontal > 120 {
                            performSwipe(.like, profile: profile)
                        } else if horizontal < -120 {
                            performSwipe(.pass, profile: profile)
                        } else {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                                dragOffset = .zero
                                cardRotation = 0
                            }
                        }
                    },
                    onTap: {
                        selectedProfile = profile
                    },
                    isAnimatingSwipe: isAnimatingSwipe
                )
                .zIndex(Double(visibleProfiles.count - index))
                .animation(
                    isTop ? .spring(response: 0.45, dampingFraction: 0.86) : .easeInOut(duration: 0.22),
                    value: dragOffset
                )
            }
        }
        .clipped()
    }

    // MARK: - Card

    private struct ConnectCardView: View {
        let profile: DeckProfile
        let isTopCard: Bool
        let dragOffset: CGSize
        let cardRotation: Double
        let stackedOffset: CGFloat
        let stackedScale: CGFloat
        let likeOpacity: Double
        let passOpacity: Double
        let onDrag: (DragGesture.Value) -> Void
        let onEnd: (DragGesture.Value) -> Void
        let onTap: () -> Void
        let isAnimatingSwipe: Bool

        var body: some View {
            TarotCardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    ZStack(alignment: .bottomLeading) {
                        GeometryReader { proxy in
                            Image(profile.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height,
                                    alignment: ConnectView.imageAlignment(for: profile.imageAnchor)
                                )
                                .clipped()
                        }

                        LinearGradient(
                            colors: [
                                .clear,
                                Color.black.opacity(0.18),
                                Color.black.opacity(0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ZD.Color.accent.opacity(0.10),
                                        .clear
                                    ],
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(profile.name)
                                    .font(ZD.Font.title())
                                    .foregroundStyle(Color.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.82)

                                Text(", \(profile.age)")
                                    .font(ZD.Font.heading())
                                    .foregroundStyle(Color.white.opacity(0.92))
                            }

                            Text(profile.combinedSigns)
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(Color.white.opacity(0.86))

                            Text(profile.archetypeTitle)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.accentSoft)
                                .lineLimit(1)
                        }
                        .padding(ZD.Spacing.m)

                        HStack {
                            if passOpacity > 0 {
                                ConnectView.swipeStamp(title: "PASS", isLike: false)
                                    .opacity(passOpacity)
                                    .rotationEffect(.degrees(-12))
                                    .padding(.leading, ZD.Spacing.m)
                                    .padding(.top, ZD.Spacing.m)
                            }

                            Spacer()

                            if likeOpacity > 0 {
                                ConnectView.swipeStamp(title: "LIKE", isLike: true)
                                    .opacity(likeOpacity)
                                    .rotationEffect(.degrees(12))
                                    .padding(.trailing, ZD.Spacing.m)
                                    .padding(.top, ZD.Spacing.m)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.25), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(
                        color: ZD.Color.accent.opacity(0.20),
                        radius: 16,
                        y: 8
                    )

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            ConnectView.infoLabel("Essence")
                            Text(profile.essence)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 8)

                        ConnectView.compatibilityBadge(score: profile.compatibilityScore)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        ConnectView.infoLabel("Connection Energy")
                        Text(profile.connectionPrompt)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .lineLimit(2)
                    }

                    if let firstReason = profile.matchReasons.first {
                        VStack(alignment: .leading, spacing: 6) {
                            ConnectView.infoLabel("Why This Match")

                            Text(firstReason.title)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)

                            Text(firstReason.detail)
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                                .lineLimit(2)
                        }
                    }

                    Button {
                        onTap()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                            Text("Preview Match")
                        }
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(.vertical, ZD.Spacing.s)
                .padding(.horizontal, 2)
            }
            .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
            .offset(isTopCard ? dragOffset : CGSize(width: 0, height: stackedOffset))
            .scaleEffect(isTopCard ? 1.0 : stackedScale)
            .rotationEffect(isTopCard ? .degrees(cardRotation) : .degrees(0))
            .opacity(stackedOffset > 16 ? 0 : 1)
            .simultaneousGesture(
                isTopCard
                ? DragGesture()
                    .onChanged(onDrag)
                    .onEnded(onEnd)
                : nil
            )
            .onTapGesture {
                if isTopCard { onTap() }
            }
        }
    }
    private var emptyDeckCard: some View {
        let showExpandedLayout = hasReachedFreeLimit && !store.effectivePremiumAccess

        return TarotCardContainer {
            VStack(spacing: 14) {
                if showExpandedLayout {
                    Spacer(minLength: 0)
                }

                Image(systemName: hasReachedFreeLimit ? "crown.fill" : "sparkles.rectangle.stack.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(ZD.Color.accent)

                VStack(spacing: 6) {
                    Text(emptyStateTitle)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(emptyStateSubtitle)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.muted)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !store.effectivePremiumAccess && hasReachedFreeLimit {
                    PremiumTileRow(
                        title: "Continue with Premium",
                        subtitle: "Keep exploring beyond today's free limit with richer match detail.",
                        icon: "crown.fill",
                        isPremium: false
                    )
                }

                if showExpandedLayout {
                    Spacer(minLength: 0)
                }
            }
            .padding(.vertical, showExpandedLayout ? 18 : 10)
        }
        .frame(height: showExpandedLayout ? 360 : 280)
    }

    private static func swipeStamp(title: String, isLike: Bool) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(isLike ? ZD.Color.success : ZD.Color.error)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isLike ? ZD.Color.success : ZD.Color.error,
                        lineWidth: 2.5
                    )
            )
    }

    // MARK: - Actions

    private var actionHintSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Actions",
                subtitle: "Swipe left to pass, right to like, or preview a profile first"
            )

            HStack(spacing: 10) {
                actionButton(
                    title: "Undo",
                    systemName: "arrow.uturn.backward",
                    isPrimary: false
                ) {
                    undoLastSwipe()
                }

                actionButton(
                    title: "Preview",
                    systemName: "eye.fill",
                    isPrimary: false
                ) {
                    if let profile = visibleProfiles.first {
                        selectedProfile = profile
                    }
                }

                actionButton(
                    title: "Like",
                    systemName: store.effectivePremiumAccess ? "sparkles" : "heart.fill",
                    isPrimary: true
                ) {
                    if let profile = visibleProfiles.first {
                        performSwipe(.like, profile: profile)
                    }
                }
            }
        }
    }

    private func actionButton(
        title: String,
        systemName: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .foregroundStyle(isPrimary ? Color.black : ZD.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(
                        isPrimary
                        ? AnyShapeStyle(ZD.Gradient.gold)
                        : AnyShapeStyle(ZD.Color.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(
                                isPrimary
                                ? ZD.Color.accentSoft.opacity(0.35)
                                : ZD.Color.border.opacity(0.45),
                                lineWidth: ZD.Stroke.thin
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Premium Prompt

    private var premiumPromptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if store.effectivePremiumAccess {
                PremiumTileRow(
                    title: "Premium Discovery Active",
                    subtitle: "You have expanded discovery access with richer match detail across the current deck.",
                    icon: "crown.fill",
                    isPremium: true,
                    showPremiumBadge: false
                )
            } else {
                PremiumTileRow(
                    title: "Unlock Premium Matching",
                    subtitle: "Extend your daily discovery and unlock richer match detail throughout Connect.",
                    icon: "crown.fill",
                    isPremium: false
                )
            }
        }
    }

    // MARK: - Banners

    private var limitBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(ZD.Color.accent)

            Text("Today's free discovery limit reached")
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
        switch vm.selectedFilter {
        case .compatible:
            return "Profiles selected for energetic harmony and emotional balance."
        case .similar:
            return "Profiles that mirror your natural rhythm and archetypal style."
        case .newEnergy:
            return "Profiles that introduce contrast, tension, and chemistry."
        }
    }

    private var emptyStateTitle: String {
        if hasReachedFreeLimit {
            return "Today's free discovery is complete"
        }
        if store.effectivePremiumAccess {
            return "Your premium deck is clear for now"
        }
        return "No more new profiles right now"
    }

    private var emptyStateSubtitle: String {
        if hasReachedFreeLimit {
            return "You've used today's free discovery passes. Premium keeps the deck open longer and adds richer match detail."
        }
        if store.effectivePremiumAccess {
            return "You've moved through the current premium deck. Check back later for a fresh set of profiles."
        }
        return "You've moved through the current free deck. Check back later for a fresh set of profiles."
    }

    private func resetTransientPresentationState() {
        selectedProfile = nil
        showCelebration = false
        dragOffset = .zero
        cardRotation = 0
        isAnimatingSwipe = false
    }
 
    // MARK: - Logic

  

   private func performSwipe(_ action: SwipeAction, profile: DeckProfile) {
            guard !visibleProfiles.isEmpty, !isAnimatingSwipe else { return }

            if hasReachedFreeLimit {
                vm.triggerLimitBanner()
                return
            }

            isAnimatingSwipe = true

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

            let destinationX: CGFloat = action == .like ? 420 : -420

            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                dragOffset = CGSize(width: destinationX, height: 0)
                cardRotation = action == .like ? 12 : -12
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                dragOffset = .zero
                cardRotation = 0
                isAnimatingSwipe = false

                vm.loadDeck(
                    user: store.currentUser,
                    savedMatches: savedMatches,
                    passedProfiles: passedProfiles,
                    swipeEvents: swipeEvents
                )

                if hasReachedFreeLimit {
                    vm.triggerLimitBanner()
                }
            }
        }

    private func saveMatch(profile: DeckProfile, showConfirmation: Bool) {
        if savedMatches.contains(where: { $0.archetypeId == profile.archetypeId && $0.name == profile.name }) {
            if showConfirmation {
                vm.showCelebration(for: profile)
                showCelebration = true
            }
            return
        }

        let primaryReason = profile.matchReasons.first

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
            imageName: profile.imageName,
            imageAnchorRaw: imageAnchorRaw(for: profile.imageAnchor),
            primaryReasonTitle: primaryReason?.title ?? "Energetic Alignment",
            primaryReasonDetail: primaryReason?.detail ?? "There is something naturally compelling about this connection."
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
                showCelebration = true
            }
        } catch {
            print("❌ Failed to save match: \(error)")
        }
    }

    private func savePassedProfile(profile: DeckProfile) {
        if passedProfiles.contains(where: { $0.archetypeId == profile.archetypeId && $0.name == profile.name }) {
            return
        }

        let passed = PassedProfile(
            name: profile.name,
            archetypeId: profile.archetypeId
        )

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

            context.delete(event)

            do {
                try context.save()

                isAnimatingSwipe = true
                vm.triggerUndoBanner()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    isAnimatingSwipe = false
                    vm.loadDeck(
                        user: store.currentUser,
                        savedMatches: savedMatches,
                        passedProfiles: passedProfiles,
                        swipeEvents: swipeEvents
                    )
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
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    private func combinedSignsText(westernRaw: String, chineseRaw: String) -> String {
        let western = WesternZodiac(rawValue: westernRaw)?.displayName ?? "—"
        let chinese = ChineseZodiac(rawValue: chineseRaw)?.displayName ?? "—"
        return "\(western) × \(chinese)"
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
    private func inferredAge(for event: ConnectSwipeEvent) -> Int {
        29
    }


    private func restoredEssence(for archetypeId: String) -> String {
        let archetype = ArchetypeService.shared.archetype(forId: archetypeId)
        return "Magnetic, layered, and worth exploring. \(archetype.tagline)"
    }

    private func restoredPrompt(for archetypeId: String) -> String {
        let archetype = ArchetypeService.shared.archetype(forId: archetypeId)
        return "A connection with real potential. \(archetype.overview)"
    }

    private func restoredImageName(for event: ConnectSwipeEvent) -> String {
        let options = ["selene", "orion", "mira", "rowan", "luna", "cassian"]
        let seed = abs((event.name + event.archetypeId).hashValue)
        return options[seed % options.count]
    }

    private func restoredImageAnchor(for event: ConnectSwipeEvent) -> UnitPoint {
        let anchors: [UnitPoint] = [.center, .top, .topLeading, .topTrailing, .leading, .trailing]
        let seed = abs((event.name + event.archetypeId).hashValue)
        return anchors[seed % anchors.count]
    }

    private static func imageAlignment(for anchor: UnitPoint) -> Alignment {
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

    private static func infoLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.accent)
    }

    private static func compatibilityBadge(score: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(score)%")
                .font(ZD.Font.heading())
                .foregroundStyle(ZD.Color.textPrimary)

            Text("Match")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(0.4), lineWidth: ZD.Stroke.thin)
                )
        )
        .zGoldGlow(active: true)
        .fixedSize()
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
                ConnectSwipeEvent.self
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
                ConnectSwipeEvent.self
            ],
            inMemory: true
        )
        .preferredColorScheme(.dark)
}
