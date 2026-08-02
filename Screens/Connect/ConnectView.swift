import SwiftUI
import SwiftData
import UIKit

fileprivate func uniqueProfilesByImageName<S: Sequence>(in profiles: S) -> [DeckProfile] where S.Element == DeckProfile {
    var seen = Set<String>()
    var unique: [DeckProfile] = []

    for profile in profiles {
        guard seen.insert(profile.imageName).inserted else { continue }
        unique.append(profile)
    }

    return unique
}

private struct ConnectSelectedProfile: Identifiable, Equatable {
    let profile: DeckProfile
    let lens: ConnectFilter
    let framing: ConnectEmotionalFraming
    let variant: Int

    var id: UUID { profile.id }
}

/// Legacy discovery prototype retained temporarily while Read Someone owns the Connect tab.
struct LegacyConnectConceptView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @StateObject private var vm = ConnectViewModel()
    @Query(sort: \ConnectUserProfile.updatedAt, order: .reverse) private var connectProfiles: [ConnectUserProfile]
    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]

    @State private var stage: ConnectFlowStage = .intro
    @State private var selectedProfile: ConnectSelectedProfile?
    @State private var ambientMotion = false
    @State private var introProfileIndex = 0
    @State private var introGlowPulse = false
    @State private var showLensSelector = false
    @State private var showConnectSetupEditor = false
    @State private var shouldShowLensPickerAfterSetup = false
    @State private var forceIntroAfterReset = false
    @State private var scrollResetToken = 0

    private let lensOrder: [ConnectFilter] = [.compatible, .newEnergy, .similar]

    private var discoveryProfiles: [DeckProfile] {
        ConnectLensEditorialOrder.profiles(vm.profiles, for: vm.selectedFilter)
    }

    private var arrivalProfiles: [DeckProfile] {
        uniqueProfilesByImageName(in: discoveryProfiles.prefix(20))
            .prefix(6)
            .map { $0 }
    }

    private var previewProfiles: [DeckProfile] {
        Array(discoveryProfiles.prefix(20))
    }

    private var arrivalFeaturedProfile: DeckProfile? {
        guard !arrivalProfiles.isEmpty else { return nil }
        return arrivalProfiles[introProfileIndex % arrivalProfiles.count]
    }

    private var arrivalBackgroundProfiles: [DeckProfile] {
        let featuredImageName = arrivalFeaturedProfile?.imageName
        let currentIndex = introProfileIndex % max(arrivalProfiles.count, 1)

        return uniqueProfilesByImageName(
            in: arrivalProfiles.enumerated().compactMap { index, profile in
                guard index != currentIndex else { return nil }
                guard profile.imageName != featuredImageName else { return nil }
                return profile
            }
        )
        .prefix(5)
        .map { $0 }
    }

    private var currentPatternMemoryIdentity: String? {
        store.currentUser.map { "\($0.westernSign.displayName) × \($0.chineseSign.displayName)" }
    }

    private func trackLensSelected(_ lens: ConnectFilter) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent(
                type: .lensSelected,
                identity: currentPatternMemoryIdentity,
                lens: lens.title
            )
        )
    }

    private var arrivalTaskKey: String {
        stage == .intro ? "\(vm.selectedFilter.rawValue)-\(arrivalProfiles.count)" : "inactive"
    }

    private var activeConnectProfile: ConnectUserProfile? {
        connectProfiles.first
    }

    private var connectProfileIsComplete: Bool {
        activeConnectProfile?.isCoreProfileComplete ?? false
    }

    private var connectAccessUnlocked: Bool {
        connectProfileIsComplete && store.hasUnlockedFullConnect
    }

    private var initialConnectStage: ConnectFlowStage {
        if forceIntroAfterReset || store.shouldReplayConnectIntro {
            return .intro
        }

        if shouldShowLensPickerAfterSetup {
            return .lens
        }

        if connectAccessUnlocked {
            return .feed
        }

        if store.hasSeenConnectIntro {
            return .preview
        }

        return .intro
    }

    var body: some View {
        NavigationStack {
            ZStack {
                connectBackground

                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 30) {
                            Color.clear
                                .frame(height: 0)
                                .id("connect-scroll-top")

                            switch stage {
                            case .intro:
                                arrivalScreen
                            case .preview:
                                previewFeed
                            case .lens:
                                lensSelectionScreen
                            case .feed:
                                discoveryFeed
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, stage == .intro ? 44 : 160)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear
                            .frame(height: stage == .intro ? 54 : 120)
                            .allowsHitTesting(false)
                    }
                    .onChange(of: stage) {
                        withAnimation(.easeInOut(duration: 0.38)) {
                            scrollProxy.scrollTo("connect-scroll-top", anchor: .top)
                        }
                    }
                    .onChange(of: scrollResetToken) {
                        withAnimation(.easeInOut(duration: 0.38)) {
                            scrollProxy.scrollTo("connect-scroll-top", anchor: .top)
                        }
                    }
                }
                .scrollDisabled(selectedProfile != nil)
                .blur(radius: selectedProfile == nil ? 0 : 6)
                .scaleEffect(selectedProfile == nil ? 1 : 0.985)

                if let selectedProfile {
                    ConnectPrototypeDetailView(
                        profile: selectedProfile.profile,
                        viewer: store.currentUser,
                        lens: selectedProfile.lens,
                        framing: selectedProfile.framing,
                        variant: selectedProfile.variant,
                        isParticipationLocked: !connectAccessUnlocked,
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.42)) {
                                self.selectedProfile = nil
                            }
                        },
                        onRequestSetup: {
                            showConnectSetupEditor = true
                        }
                    )
                    .zIndex(4)
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                store.syncConnectAccessState(isComplete: connectProfileIsComplete)
                loadDeck()
                syncConnectStage(animated: false)
                withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true)) {
                    ambientMotion = true
                }
            }
            .task(id: arrivalTaskKey) {
                await runArrivalRotation()
            }
            .onChange(of: vm.selectedFilter) {
                loadDeck(forceRefresh: true)
            }
            .onChange(of: connectProfileIsComplete) { _, _ in
                syncConnectStage(animated: false)
            }
            .onChange(of: store.identityRefreshToken) {
                loadDeck(forceRefresh: true)
                syncConnectStage(animated: false)
            }
            .onChange(of: store.connectResetToken) {
                resetConnectExperience()
            }
            .onChange(of: store.selectedTab) { _, newTab in
                guard newTab == .connect else { return }
                syncConnectStage(animated: false)
            }
            .sheet(isPresented: $showConnectSetupEditor) {
                NavigationStack {
                    ConnectProfileEditorView(onSave: {
                        shouldShowLensPickerAfterSetup = true
                        forceIntroAfterReset = false
                        showConnectSetupEditor = false
                        selectedProfile = nil
                        syncConnectStage(animated: true)
                        loadDeck(forceRefresh: true)
                    })
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
                }
                .presentationDetents([.large, .fraction(0.92)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showLensSelector) {
                ConnectLensSelectorSheet(
                    lenses: lensOrder,
                    selectedLens: vm.selectedFilter,
                    lensTitle: lensTitle,
                    lensLine: lensEmotionalLine,
                    lensColor: lensGlowColor,
                    onSelect: { lens in
                        feedbackSoft()
                        if vm.selectedFilter != lens {
                            trackLensSelected(lens)
                        }
                        vm.selectedFilter = lens
                        shouldShowLensPickerAfterSetup = false
                        stage = .feed
                        showLensSelector = false
                        scrollResetToken += 1
                    },
                    onClose: {
                        showLensSelector = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.40), value: selectedProfile)
        .animation(.easeInOut(duration: 0.9), value: vm.selectedFilter)
    }

    private var arrivalScreen: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                arrivalMark

                Text("Understand people through patterns")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(-1)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Use astrology as a lens for what feels familiar, different, or worth another look")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 620, alignment: .leading)

            arrivalDeckVisual

            Button {
                feedbackSoft()
                store.markConnectIntroSeen()
                withAnimation(.easeInOut(duration: 0.38)) {
                    stage = connectAccessUnlocked ? .feed : .preview
                    scrollResetToken += 1
                }
            } label: {
                Text("Start noticing")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(ZD.Gradient.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)

                Text("Your card helps others understand your identity too")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var lensSelectionScreen: some View {
        VStack(alignment: .leading, spacing: 12) {
            connectMark

            VStack(alignment: .leading, spacing: 5) {
                Text("Choose a lens")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(-1)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Choose what kind of person you want to understand first")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.88))
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 7) {
                ForEach(lensOrder) { lens in
                    lensPanel(for: lens)
                }
            }

            Button {
                feedbackSoft()
                withAnimation(.easeInOut(duration: 0.38)) {
                    stage = .feed
                    scrollResetToken += 1
                }
            } label: {
                Text("Explore \(lensTitle(vm.selectedFilter))")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(ZD.Gradient.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var discoveryFeed: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lensFeedLine(vm.selectedFilter))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(1.1)
                        .textCase(.uppercase)
                        .foregroundStyle(ZD.Color.accent.opacity(0.72))

                    Text(lensTitle(vm.selectedFilter))
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(lensEmotionalLine(vm.selectedFilter))
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Button {
                    feedbackSoft()
                    showLensSelector = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(ZD.Color.card.opacity(0.74)))
                        .overlay(Circle().stroke(ZD.Color.border.opacity(0.18), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .zIndex(12)
            }
            .padding(.top, 8)
            .zIndex(12)

            connectEntryPoints

            if discoveryProfiles.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: lensFeedCardSpacing(vm.selectedFilter)) {
                    ForEach(
                        ConnectEditorialRhythm.entries(
                            for: Array(discoveryProfiles.prefix(20)),
                            lens: vm.selectedFilter,
                            repeatCount: 3
                        )
                    ) { entry in
                        switch entry {
                        case .person(let item):
                            ConnectDiscoveryCard(
                                profile: item.profile,
                                viewer: store.currentUser,
                                lens: vm.selectedFilter,
                                layout: item.layout,
                                rhythm: item.rhythm,
                                framing: item.framing,
                                variant: item.variant,
                                onOpen: {
                                    withAnimation(.easeInOut(duration: 0.42)) {
                                        feedbackSoft()
                                        selectedProfile = ConnectSelectedProfile(
                                            profile: item.profile,
                                            lens: vm.selectedFilter,
                                            framing: item.framing,
                                            variant: item.variant
                                        )
                                    }
                                }
                            )
                            .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.72)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.982)
                                    .offset(y: phase.value * -8)
                            }
                        case .breath(let moment):
                            ConnectBreathMoment(text: moment.text, lens: vm.selectedFilter)
                                .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.52)
                                        .offset(y: phase.value * -6)
                                }
                        }
                    }
                }
                .zIndex(0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var previewFeed: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(lensFeedLine(vm.selectedFilter))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(ZD.Color.accent.opacity(0.72))

                Text(lensTitle(vm.selectedFilter))
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(lensEmotionalLine(vm.selectedFilter))
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            connectEntryPoints

            if previewProfiles.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: lensFeedCardSpacing(vm.selectedFilter)) {
                    ForEach(ConnectEditorialRhythm.entries(for: previewProfiles, lens: vm.selectedFilter)) { entry in
                        switch entry {
                        case .person(let item):
                            ConnectDiscoveryCard(
                                profile: item.profile,
                                viewer: store.currentUser,
                                lens: vm.selectedFilter,
                                layout: item.layout,
                                rhythm: item.rhythm,
                                framing: item.framing,
                                variant: item.variant,
                                onOpen: {
                                    withAnimation(.easeInOut(duration: 0.42)) {
                                        feedbackSoft()
                                        selectedProfile = ConnectSelectedProfile(
                                            profile: item.profile,
                                            lens: vm.selectedFilter,
                                            framing: item.framing,
                                            variant: item.variant
                                        )
                                    }
                                }
                            )
                            .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.74)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.984)
                                    .offset(y: phase.value * -8)
                            }
                        case .breath(let moment):
                            ConnectBreathMoment(text: moment.text, lens: vm.selectedFilter)
                                .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.54)
                                        .offset(y: phase.value * -6)
                                }
                        }
                    }

                    previewGateCard
                }
                .zIndex(0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var connectMark: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text("Connect")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .textCase(.uppercase)
                .tracking(1.6)
                .foregroundStyle(ZD.Color.accent)
        }
    }

    private var connectEntryPoints: some View {
        HStack(spacing: 10) {
            NavigationLink {
                ReadSomeoneConnectPlaceholderView()
            } label: {
                connectEntryCard(
                    title: "Read Someone",
                    subtitle: "Enter a birthday",
                    icon: "magnifyingglass"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                MatchesView()
            } label: {
                connectEntryCard(
                    title: "My Circle",
                    subtitle: savedMatches.isEmpty ? "Saved people" : "\(savedMatches.count) saved",
                    icon: "person.2.fill"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func connectEntryCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 30, height: 30)
                .background(Circle().fill(ZD.Color.accent.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.76))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZD.Color.card.opacity(0.62))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private var previewGateCard: some View {
        Button {
            feedbackSoft()
            withAnimation(.easeInOut(duration: 0.38)) {
                showConnectSetupEditor = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "person.crop.square")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)

                    Text("Set up your Connect card")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Finish your card so others can read your identity clearly")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)

                HStack(spacing: 8) {
                    Text("Finish card")
                        .font(ZD.Font.body(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(ZD.Gradient.gold)
                .clipShape(Capsule(style: .continuous))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.72),
                                ZD.Color.cardAlt.opacity(0.40)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var arrivalDeckVisual: some View {
        return ConnectArrivalDeckScene(
            featuredProfile: arrivalFeaturedProfile,
            activeIndex: introProfileIndex,
            backgroundProfiles: arrivalBackgroundProfiles,
            ambientMotion: ambientMotion,
            glowPulse: introGlowPulse,
            glowColor: lensGlowColor(vm.selectedFilter)
        )
        .frame(height: 324)
        .animation(.easeInOut(duration: 0.95), value: arrivalFeaturedProfile?.id)
        .animation(.easeInOut(duration: 1.2), value: introGlowPulse)
    }

    private func lensPanel(for lens: ConnectFilter) -> some View {
        let isSelected = vm.selectedFilter == lens

        return Button {
            guard vm.selectedFilter != lens else { return }
            feedbackSoft()
            trackLensSelected(lens)
            vm.selectedFilter = lens
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [lensGlowColor(lens).opacity(0.38), ZD.Color.cardAlt.opacity(0.68)]
                                : [ZD.Color.card.opacity(0.52), ZD.Color.cardAlt.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .stroke(lensGlowColor(lens).opacity(isSelected ? 0.26 : 0.055), lineWidth: 1)
                    .frame(width: 138, height: 138)
                    .offset(x: 214, y: -34)
                    .blur(radius: isSelected ? 0 : 1.6)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lensTitle(lens))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(isSelected ? ZD.Color.textPrimary : ZD.Color.textPrimary.opacity(0.76))

                    Text(lensEmotionalLine(lens))
                        .font(ZD.Font.caption())
                        .foregroundStyle(isSelected ? ZD.Color.textSecondary.opacity(0.92) : ZD.Color.textSecondary.opacity(0.64))
                        .lineSpacing(0)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .frame(minHeight: isSelected ? 74 : 68)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? lensGlowColor(lens).opacity(0.48) : ZD.Color.border.opacity(0.07), lineWidth: isSelected ? 1.35 : 1)
            )
            .shadow(color: lensGlowColor(lens).opacity(isSelected ? 0.20 : 0), radius: 18, y: 8)
            .scaleEffect(isSelected ? 1.01 : 1)
            .opacity(isSelected ? 1 : 0.76)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("More people are on the way")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)

            Text("Connect refreshes as new profiles appear")
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(ZD.Color.card.opacity(0.70))
        )
    }

    private var connectBackground: some View {
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        lensGlowColor(vm.selectedFilter).opacity(0.15),
                        .clear,
                        ZD.Color.cardAlt.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        lensGlowColor(vm.selectedFilter).opacity(ambientMotion ? 0.16 : 0.10),
                        ZD.Color.card.opacity(ambientMotion ? 0.05 : 0.03),
                        .clear
                    ],
                    center: ambientMotion ? .topTrailing : .topLeading,
                    startRadius: 80,
                    endRadius: 620
                )
            )
            .overlay {
                connectIntersectionAtmosphere
            }
            .ignoresSafeArea()
    }

    private var connectIntersectionAtmosphere: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let glow = lensGlowColor(vm.selectedFilter)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                glow.opacity(ambientMotion ? 0.12 : 0.08),
                                glow.opacity(0.04),
                                .clear
                            ],
                            center: .center,
                            startRadius: 18,
                            endRadius: 240
                        )
                    )
                    .frame(width: width * 1.18, height: width * 1.18)
                    .offset(x: -width * 0.24, y: -height * 0.22)
                    .blur(radius: 0.8)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZD.Color.textPrimary.opacity(ambientMotion ? 0.05 : 0.03),
                                ZD.Color.cardAlt.opacity(0.03),
                                .clear
                            ],
                            center: .center,
                            startRadius: 18,
                            endRadius: 220
                        )
                    )
                    .frame(width: width * 1.06, height: width * 1.06)
                    .offset(x: width * 0.24, y: height * 0.12)
                    .blur(radius: 0.8)

                Circle()
                    .stroke(glow.opacity(ambientMotion ? 0.10 : 0.06), lineWidth: 1)
                    .frame(width: width * 0.88, height: width * 0.88)
                    .offset(x: width * 0.02, y: height * 0.04)
                    .blur(radius: 0.35)

                Circle()
                    .stroke(ZD.Color.border.opacity(0.04), lineWidth: 1)
                    .frame(width: width * 0.74, height: width * 0.74)
                    .offset(x: -width * 0.10, y: height * 0.20)

                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    glow.opacity(0.16),
                                    ZD.Color.textPrimary.opacity(0.14),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 2 + CGFloat(index % 2), height: 2 + CGFloat(index % 2))
                        .offset(
                            x: dustXOffset(index: index, width: width),
                            y: dustYOffset(index: index, height: height)
                        )
                        .opacity(0.50)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func dustXOffset(index: Int, width: CGFloat) -> CGFloat {
        let base: [CGFloat] = [width * 0.12, width * 0.20, width * 0.62, width * 0.76, width * 0.42, width * 0.88]
        return base[index % base.count] - width * 0.5
    }

    private func dustYOffset(index: Int, height: CGFloat) -> CGFloat {
        let base: [CGFloat] = [height * 0.24, height * 0.58, height * 0.18, height * 0.42, height * 0.74, height * 0.52]
        return base[index % base.count] - height * 0.5
    }

    private func lensTitle(_ lens: ConnectFilter) -> String {
        lens.title
    }

    private func lensEmotionalLine(_ lens: ConnectFilter) -> String {
        lens.subtitle
    }

    private func lensFeedLine(_ lens: ConnectFilter) -> String {
        lens.detail
    }

    private func lensFeedCardSpacing(_ lens: ConnectFilter) -> CGFloat {
        switch lens {
        case .compatible:
            return 46
        case .newEnergy:
            return 24
        case .similar:
            return 38
        }
    }

    private var arrivalMark: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text("CONNECT")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(ZD.Color.accent)
        }
    }

    private func lensGlowColor(_ lens: ConnectFilter) -> Color {
        switch lens {
        case .similar:
            return Color(red: 0.56, green: 0.38, blue: 0.46)
        case .compatible:
            return Color(red: 0.58, green: 0.68, blue: 0.78)
        case .newEnergy:
            return Color(red: 0.82, green: 0.68, blue: 0.46)
        }
    }

    private func loadDeck(forceRefresh: Bool = false) {
        store.loadUserIfNeeded(context: context)
        vm.loadDeck(
            user: store.currentUser,
            isPremium: store.effectivePremiumAccess,
            context: context,
            forceRefresh: forceRefresh
        )
        introProfileIndex = 0
        introGlowPulse = false
    }

    private func resetConnectExperience() {
        selectedProfile = nil
        showLensSelector = false
        showConnectSetupEditor = false
        shouldShowLensPickerAfterSetup = false
        forceIntroAfterReset = true
        introProfileIndex = 0
        introGlowPulse = false
        vm.resetForConnectRestart()
        withAnimation(.easeInOut(duration: 0.38)) {
            stage = .intro
        }
        scrollResetToken += 1
        loadDeck(forceRefresh: true)
        syncConnectStage(animated: false)
    }

    private func runArrivalRotation() async {
        while !Task.isCancelled {
            guard stage == .intro, arrivalProfiles.count > 1 else {
                try? await Task.sleep(for: .milliseconds(350))
                continue
            }

            let currentCount = arrivalProfiles.count
            try? await Task.sleep(for: .seconds(Double.random(in: 3.5...5.0)))

            guard !Task.isCancelled, stage == .intro, currentCount == arrivalProfiles.count, currentCount > 1 else {
                continue
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 1.05)) {
                    introProfileIndex = (introProfileIndex + 1) % currentCount
                    introGlowPulse = true
                }
            }

            try? await Task.sleep(for: .milliseconds(650))

            await MainActor.run {
                introGlowPulse = false
            }
        }
    }

    private func syncConnectStage(animated: Bool) {
        store.loadUserIfNeeded(context: context)
        store.syncConnectAccessState(isComplete: connectProfileIsComplete)

        let nextStage = initialConnectStage

        if animated {
            withAnimation(.easeInOut(duration: 0.38)) {
                stage = nextStage
            }
        } else {
            stage = nextStage
        }

        if nextStage == .feed {
            showLensSelector = false
        }
    }

    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.68)
    }
}

private enum ConnectFlowStage {
    case intro
    case preview
    case lens
    case feed
}

private enum ConnectCardLayoutStyle {
    case poster
    case portrait
    case split
    case silent
    case edgeBleed
    case quote
}

private enum ConnectCardRhythm {
    case hero
    case support
    case quiet
}

private enum ConnectEmotionalFraming: CaseIterable, Equatable {
    case observation
    case tension
    case recognition
    case curiosity
    case comfort
    case disruption
    case magnetism
    case reflection
    case expansion

    var label: String {
        label(for: nil)
    }

    func label(for lens: ConnectFilter?) -> String {
        guard let lens else {
            switch self {
            case .observation: return "Observation"
            case .tension: return "Tension"
            case .recognition: return "Recognition"
            case .curiosity: return "Curiosity"
            case .comfort: return "Comfort"
            case .disruption: return "Disruption"
            case .magnetism: return "Magnetism"
            case .reflection: return "Reflection"
            case .expansion: return "Expansion"
            }
        }

        switch self {
        case .observation:
            switch lens {
            case .compatible: return "WARMTH"
            case .similar: return "BELOW THE SURFACE"
            case .newEnergy: return "CONTRAST"
            }
        case .tension:
            switch lens {
            case .compatible: return "COMFORT"
            case .similar: return "UNDERSTANDING"
            case .newEnergy: return "FRICTION"
            }
        case .recognition:
            switch lens {
            case .compatible: return "FAMILIARITY"
            case .similar: return "RECOGNITION"
            case .newEnergy: return "DISRUPTION"
            }
        case .curiosity:
            switch lens {
            case .compatible: return "NATURAL FIT"
            case .similar: return "BELOW THE SURFACE"
            case .newEnergy: return "CONTRAST"
            }
        case .comfort:
            switch lens {
            case .compatible: return "COMFORT"
            case .similar: return "UNDERSTANDING"
            case .newEnergy: return "EXPANSION"
            }
        case .disruption:
            switch lens {
            case .compatible: return "WARMTH"
            case .similar: return "BELOW THE SURFACE"
            case .newEnergy: return "DISRUPTION"
            }
        case .magnetism:
            switch lens {
            case .compatible: return "NATURAL FIT"
            case .similar: return "RECOGNITION"
            case .newEnergy: return "CONTRAST"
            }
        case .reflection:
            switch lens {
            case .compatible: return "FAMILIARITY"
            case .similar: return "REFLECTION"
            case .newEnergy: return "FRICTION"
            }
        case .expansion:
            switch lens {
            case .compatible: return "NATURAL FIT"
            case .similar: return "UNDERSTANDING"
            case .newEnergy: return "EXPANSION"
            }
        }
    }

    static func priority(for profile: DeckProfile, lens: ConnectFilter) -> [ConnectEmotionalFraming] {
        switch profile.matchStyle {
        case .harmonious:
            return lens == .similar
                ? [.comfort, .recognition, .observation, .reflection, .curiosity, .expansion, .tension, .magnetism, .disruption]
                : [.comfort, .observation, .recognition, .expansion, .reflection, .curiosity, .tension, .magnetism, .disruption]
        case .mirrored:
            return [.reflection, .recognition, .observation, .curiosity, .tension, .comfort, .magnetism, .expansion, .disruption]
        case .growth:
            return [.expansion, .curiosity, .tension, .observation, .recognition, .disruption, .comfort, .reflection, .magnetism]
        case .magnetic:
            return [.magnetism, .curiosity, .tension, .disruption, .observation, .recognition, .reflection, .expansion, .comfort]
        case .intense:
            return [.disruption, .tension, .magnetism, .observation, .curiosity, .reflection, .recognition, .expansion, .comfort]
        }
    }
}

private struct ConnectEditorialFeedItem: Identifiable {
    let id: String
    let profile: DeckProfile
    let layout: ConnectCardLayoutStyle
    let rhythm: ConnectCardRhythm
    let framing: ConnectEmotionalFraming
    let variant: Int
}

private struct ConnectEditorialBreathMoment: Identifiable {
    let id: String
    let text: String
}

private enum ConnectEditorialFeedEntry: Identifiable {
    case person(ConnectEditorialFeedItem)
    case breath(ConnectEditorialBreathMoment)

    var id: String {
        switch self {
        case .person(let item):
            return "person-\(item.id)"
        case .breath(let moment):
            return moment.id
        }
    }
}

private enum ConnectEditorialRhythm {
    private static func layoutCycle(for lens: ConnectFilter) -> [ConnectCardLayoutStyle] {
        switch lens {
        case .similar:
            return [.quote, .split, .portrait, .quote, .silent, .split, .poster, .quote]
        case .compatible:
            return [.poster, .portrait, .silent, .poster, .edgeBleed, .portrait, .silent, .quote]
        case .newEnergy:
            return [.edgeBleed, .split, .poster, .silent, .edgeBleed, .quote, .split, .poster]
        }
    }

    private static func breathLines(for lens: ConnectFilter) -> [String] {
        switch lens {
        case .compatible:
            return [
                "Nothing has to rush to be real",
                "You do not have to prove your place",
                "Ordinary moments can feel complete",
                "Trust can arrive without a performance",
                "Some people make belonging feel simple",
                "The easy part can be the important part",
                "A familiar feeling is still information",
                "Comfort has its own kind of clarity",
                "Some conversations keep themselves alive"
            ]
        case .newEnergy:
            return [
                "Some people interrupt the script",
                "Notice what changes your next move",
                "A little charge changes the room",
                "Curiosity usually knows before certainty does",
                "Some questions move the whole moment",
                "Possibility has a different temperature",
                "The shift is what keeps your attention",
                "Attraction can start as interruption",
                "A new direction can be quiet at first"
            ]
        case .similar:
            return [
                "The quiet part is often the clue",
                "Some details ask you to stay",
                "Recognition takes more than one glance",
                "What goes unsaid can carry the meaning",
                "Some truths arrive in the return",
                "The smallest detail can change the story",
                "A pause can hold more than an answer",
                "Some people hear what stays protected",
                "The deeper clue is rarely the loudest one"
            ]
        }
    }

    static func entries(
        for profiles: [DeckProfile],
        lens: ConnectFilter,
        repeatCount: Int = 1
    ) -> [ConnectEditorialFeedEntry] {
        var entries: [ConnectEditorialFeedEntry] = []

        let cycles = max(repeatCount, 1)
        let repeatedProfiles = Array(repeating: profiles, count: cycles).flatMap { $0 }

        for (index, item) in items(for: repeatedProfiles, lens: lens).enumerated() {
            entries.append(.person(item))

            if shouldInsertBreath(after: index, total: repeatedProfiles.count, lens: lens) {
                let lines = breathLines(for: lens)
                let line = lines[(index + item.variant) % lines.count]
                entries.append(.breath(.init(id: "breath-\(index)-\(item.id)", text: line)))
            }
        }

        return entries
    }

    static func items(for profiles: [DeckProfile], lens: ConnectFilter) -> [ConnectEditorialFeedItem] {
        var recentFramings: [ConnectEmotionalFraming] = []
        var previousLayout: ConnectCardLayoutStyle?

        return profiles.enumerated().map { index, profile in
            let cycle = profiles.isEmpty ? 0 : index / max(1, profiles.count)
            let layout = layout(for: index, lens: lens, previous: previousLayout)
            let framing = framing(for: profile, lens: lens, index: index, recent: recentFramings)
            let item = ConnectEditorialFeedItem(
                id: "\(cycle)-\(profile.id.uuidString)",
                profile: profile,
                layout: layout,
                rhythm: rhythm(for: index, lens: lens),
                framing: framing,
                variant: (index + profile.name.count) % 3
            )

            previousLayout = layout
            recentFramings.append(framing)
            if recentFramings.count > 3 {
                recentFramings.removeFirst()
            }

            return item
        }
    }

    private static func layout(
        for index: Int,
        lens: ConnectFilter,
        previous: ConnectCardLayoutStyle?
    ) -> ConnectCardLayoutStyle {
        let cycle = layoutCycle(for: lens)
        let proposed = cycle[index % cycle.count]

        if proposed == previous {
            switch proposed {
            case .poster: return .split
            case .portrait: return .poster
            case .split: return .portrait
            case .silent: return .poster
            case .edgeBleed: return .split
            case .quote: return .portrait
            }
        }

        return proposed
    }

    private static func rhythm(for index: Int, lens: ConnectFilter) -> ConnectCardRhythm {
        switch lens {
        case .compatible:
            switch index % 6 {
            case 0:
                return .hero
            case 2, 5:
                return .quiet
            default:
                return .support
            }
        case .newEnergy:
            switch index % 5 {
            case 0, 3:
                return .hero
            case 4:
                return .quiet
            default:
                return .support
            }
        case .similar:
            switch index % 6 {
            case 0:
                return .hero
            case 1, 4:
                return .quiet
            default:
                return .support
            }
        }
    }

    private static func shouldInsertBreath(after index: Int, total: Int, lens: ConnectFilter) -> Bool {
        guard index < total - 1 else { return false }

        switch lens {
        case .compatible:
            return index % 6 == 1 || index % 6 == 4
        case .newEnergy:
            return index % 5 == 1 || index % 5 == 3
        case .similar:
            return index % 6 == 1 || index % 6 == 3 || index % 6 == 5
        }
    }

    private static func framing(
        for profile: DeckProfile,
        lens: ConnectFilter,
        index: Int,
        recent: [ConnectEmotionalFraming]
    ) -> ConnectEmotionalFraming {
        let priority = ConnectEmotionalFraming.priority(for: profile, lens: lens)
        let rotated = rotate(priority, by: index * 2)
        return rotated.first { !recent.contains($0) } ?? rotated.first ?? .observation
    }

    private static func rotate<T>(_ values: [T], by offset: Int) -> [T] {
        guard !values.isEmpty else { return values }
        let pivot = offset % values.count
        return Array(values[pivot...]) + Array(values[..<pivot])
    }
}

private enum ConnectLensEditorialOrder {
    static func profiles(_ profiles: [DeckProfile], for lens: ConnectFilter) -> [DeckProfile] {
        profiles.sorted { lhs, rhs in
            let lhsScore = score(lhs, for: lens)
            let rhsScore = score(rhs, for: lens)

            if lhsScore == rhsScore {
                return tieBreak(lhs, rhs, for: lens)
            }

            return lhsScore > rhsScore
        }
    }

    private static func score(_ profile: DeckProfile, for lens: ConnectFilter) -> Int {
        switch lens {
        case .similar:
            return styleScore(profile.matchStyle, order: [.mirrored, .harmonious, .magnetic, .growth, .intense])
                + textScore(profile, markers: ["shared", "steady", "familiar", "calm", "quiet", "recognize"])
                + profile.compatibilityScore
        case .compatible:
            return styleScore(profile.matchStyle, order: [.harmonious, .growth, .mirrored, .magnetic, .intense])
                + textScore(profile, markers: ["balance", "easy", "flow", "steady", "direct", "ground"])
                + profile.compatibilityScore
        case .newEnergy:
            return styleScore(profile.matchStyle, order: [.intense, .growth, .magnetic, .mirrored, .harmonious])
                + textScore(profile, markers: ["different", "contrast", "charge", "interrupt", "bold", "edge"])
                + max(0, 100 - profile.compatibilityScore)
        }
    }

    private static func styleScore(_ style: MatchStyle, order: [MatchStyle]) -> Int {
        guard let index = order.firstIndex(of: style) else { return 0 }
        return (order.count - index) * 80
    }

    private static func textScore(_ profile: DeckProfile, markers: [String]) -> Int {
        let searchable = [
            profile.name,
            profile.archetypeTitle,
            profile.essence,
            profile.connectionPrompt,
            profile.frictionNote,
            profile.intent,
            profile.matchReasons.map(\.detail).joined(separator: " "),
            profile.signals.map(\.response).joined(separator: " ")
        ]
            .joined(separator: " ")
            .lowercased()

        return markers.reduce(0) { total, marker in
            total + (searchable.contains(marker) ? 14 : 0)
        }
    }

    private static func tieBreak(
        _ lhs: DeckProfile,
        _ rhs: DeckProfile,
        for lens: ConnectFilter
    ) -> Bool {
        switch lens {
        case .similar:
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        case .compatible:
            return lhs.archetypeTitle.localizedCaseInsensitiveCompare(rhs.archetypeTitle) == .orderedAscending
        case .newEnergy:
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
        }
    }
}

private struct ConnectArrivalDeckScene: View {
    let featuredProfile: DeckProfile?
    let activeIndex: Int
    let backgroundProfiles: [DeckProfile]
    let ambientMotion: Bool
    let glowPulse: Bool
    let glowColor: Color

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(max(proxy.size.width * 0.70, 226), 292)
            let cardHeight = cardWidth
            let backgroundSize = CGSize(width: cardWidth * 0.90, height: cardHeight * 0.90)

            ZStack {
                intersectionLayer

                deckOrbit

                backgroundCards(cardSize: backgroundSize)

                if let featuredProfile {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ZD.Color.accent.opacity(0.12),
                                    ZD.Color.accent.opacity(0.04),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 12,
                                endRadius: 168
                            )
                        )
                        .frame(width: cardWidth * 0.82, height: cardHeight * 0.82)
                        .offset(y: cardHeight * 0.08)
                        .blur(radius: 22)
                        .blendMode(.screen)
                        .zIndex(2)

                    ConnectArrivalFeaturedCard(
                        profile: featuredProfile,
                        compositionVariant: ConnectArrivalCompositionVariant.variant(for: featuredProfile),
                        glowColor: glowColor,
                        glowPulse: glowPulse
                    )
                    .frame(width: cardWidth, height: cardHeight)
                    .transition(.opacity.combined(with: .scale(scale: 0.968)))
                    .shadow(color: Color.black.opacity(0.34), radius: 26, y: 16)
                    .zIndex(3)
                    .offset(y: ambientMotion ? -2 : 2)
                    .rotationEffect(.degrees(ambientMotion ? 0.25 : -0.15))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .padding(.vertical, 16)
    }

    private var intersectionLayer: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                glowColor.opacity(glowPulse ? 0.14 : 0.08),
                                glowColor.opacity(0.03),
                                .clear
                            ],
                            center: .center,
                            startRadius: 22,
                            endRadius: 260
                        )
                    )
                    .frame(width: min(width * 0.96, 336), height: min(width * 0.96, 336))
                    .offset(x: -width * 0.20, y: -height * 0.02)
                    .blur(radius: 1.6)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZD.Color.cardAlt.opacity(0.08),
                                ZD.Color.card.opacity(0.018),
                                .clear
                            ],
                            center: .center,
                            startRadius: 22,
                            endRadius: 240
                        )
                    )
                    .frame(width: min(width * 0.92, 326), height: min(width * 0.92, 326))
                    .offset(x: width * 0.14, y: height * 0.14)
                    .blur(radius: 1.6)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                glowColor.opacity(0.06),
                                .clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 140
                        )
                    )
                    .frame(width: min(width * 0.48, 176), height: min(width * 0.48, 176))
                    .offset(x: width * 0.04, y: height * 0.10)
                    .blur(radius: 18)

                Circle()
                    .stroke(glowColor.opacity(0.05), lineWidth: 1)
                    .frame(width: min(width * 1.08, 370), height: min(width * 1.08, 370))
                    .offset(x: width * 0.02, y: height * 0.08)
                    .blur(radius: 1.1)

                Circle()
                    .stroke(ZD.Color.border.opacity(0.025), lineWidth: 1)
                    .frame(width: min(width * 0.74, 260), height: min(width * 0.74, 260))
                    .offset(x: -width * 0.02, y: height * 0.20)
                    .blur(radius: 1.4)
            }
            .allowsHitTesting(false)
        }
    }

    private func backgroundCards(cardSize: CGSize) -> some View {
        ZStack {
            ForEach(Array(backgroundProfiles.enumerated()), id: \.element.id) { index, profile in
                ConnectArrivalBackdropCard(
                    profile: profile,
                    activeIndex: activeIndex,
                    index: index
                )
                    .frame(width: cardSize.width, height: cardSize.height)
                    .rotationEffect(.degrees(rotation(for: index)))
                    .offset(
                        x: xOffset(for: index),
                        y: yOffset(for: index)
                    )
                    .opacity(0.11 + Double(max(0, 4 - index)) * 0.03)
                    .blur(radius: 9 + CGFloat(index) * 0.6)
                    .scaleEffect(1 - CGFloat(index) * 0.02)
                    .zIndex(Double(index))
            }
        }
        .offset(y: ambientMotion ? 4 : 8)
    }

    private var deckOrbit: some View {
        ZStack {
            Circle()
                .stroke(glowColor.opacity(glowPulse ? 0.14 : 0.08), lineWidth: 1)
                .frame(width: 264, height: 264)
                .offset(
                    x: ambientMotion ? 88 : 68,
                    y: ambientMotion ? -34 : -18
                )
                .rotationEffect(.degrees(ambientMotion ? 10 : -8))
                .blur(radius: glowPulse ? 0.8 : 1.4)

            Circle()
                .stroke(ZD.Color.border.opacity(0.08), lineWidth: 1)
                .frame(width: 210, height: 210)
                .offset(
                    x: ambientMotion ? -100 : -84,
                    y: ambientMotion ? 102 : 84
                )
                .rotationEffect(.degrees(ambientMotion ? -8 : 7))
                .blur(radius: 1.1)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(glowPulse ? 0.14 : 0.08),
                            ZD.Color.accent.opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 168, height: 168)
                .blur(radius: glowPulse ? 30 : 38)
                .offset(
                    x: ambientMotion ? 56 : 88,
                    y: ambientMotion ? 2 : 18
                )
        }
    }

    private func rotation(for index: Int) -> Double {
        let base = [-17.0, -8.0, 9.0, 14.0, -4.0]
        let value = base[index % base.count]
        let activeDrift = Double((activeIndex % 4) - 1) * 0.8
        return value + activeDrift + (ambientMotion ? Double(index.isMultiple(of: 2) ? 2 : -2) : 0)
    }

    private func xOffset(for index: Int) -> CGFloat {
        let base: [CGFloat] = [-78, 88, -28, 56, -44]
        let motion: [CGFloat] = [-6, 4, -2, 3, -4]
        let activeDrift: [CGFloat] = [-5, 4, -2, 3]
        return base[index % base.count]
            + activeDrift[activeIndex % activeDrift.count]
            + (ambientMotion ? motion[index % motion.count] : -motion[index % motion.count] * 0.5)
    }

    private func yOffset(for index: Int) -> CGFloat {
        let base: [CGFloat] = [10, -14, 32, -6, 24]
        let motion: [CGFloat] = [-3, 2, -2, 3, -1]
        let activeDrift: [CGFloat] = [3, -4, 1, -2]
        return base[index % base.count]
            + activeDrift[activeIndex % activeDrift.count]
            + (ambientMotion ? motion[index % motion.count] : -motion[index % motion.count] * 0.5)
    }
}

private struct ConnectArrivalFeaturedCard: View {
    let profile: DeckProfile
    let compositionVariant: ConnectArrivalCompositionVariant
    let glowColor: Color
    let glowPulse: Bool

    var body: some View {
        ZStack {
            imageLayer
            overlayLayer
            variantBody
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 20, y: 12)
        .accessibilityElement(children: .combine)
    }

    private var imageLayer: some View {
        GeometryReader { proxy in
            ConnectProfileImage(
                assetName: profile.imageName,
                size: proxy.size,
                focalPoint: profile.imageAnchor,
                clipShape: .roundedRectangle(32)
            )
        }
    }

    private var overlayLayer: some View {
        ZStack {
            LinearGradient(
                colors: compositionVariant.baseScrim,
                startPoint: compositionVariant.baseStartPoint,
                endPoint: compositionVariant.baseEndPoint
            )

            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    glowColor.opacity(glowPulse ? 0.22 : 0.11),
                    .clear
                ],
                startPoint: compositionVariant.glowStartPoint,
                endPoint: compositionVariant.glowEndPoint
            )
            .blendMode(.screen)
        }
    }

    @ViewBuilder
    private var variantBody: some View {
        switch compositionVariant {
        case .bottomLeft:
            bottomLeftVariant
        case .centeredLow:
            centeredLowVariant
        case .leftCompact:
            leftCompactVariant
        case .minimal:
            minimalVariant
        }
    }

    private var bottomLeftVariant: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 0)

                identityStack(alignment: .leading, lineAlignment: .leading, titleAlignment: .leading, nameSize: 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)

            adaptiveBadge(.topLeading)
        }
    }

    private var centeredLowVariant: some View {
        ZStack {
            VStack(spacing: 10) {
                adaptiveBadge(.topTrailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer(minLength: 0)

                VStack(alignment: .center, spacing: 5) {
                    identityStack(alignment: .center, lineAlignment: .center, titleAlignment: .center, nameSize: 27)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
    }

    private var leftCompactVariant: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 8) {
                Spacer(minLength: 0)

                identityStack(alignment: .trailing, lineAlignment: .trailing, titleAlignment: .trailing, nameSize: 26)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(18)

            adaptiveBadge(.topLeading)
        }
    }

    private var minimalVariant: some View {
        ZStack {
            VStack(alignment: .trailing, spacing: 8) {
                Spacer(minLength: 0)

                identityStack(alignment: .trailing, lineAlignment: .trailing, titleAlignment: .trailing, nameSize: 29)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(18)

            adaptiveBadge(.topTrailing)
        }
    }

    private func identityStack(
        alignment: HorizontalAlignment,
        lineAlignment: TextAlignment,
        titleAlignment: TextAlignment,
        nameSize: CGFloat
    ) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(profile.archetypeTitle)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(ZD.Color.accent.opacity(0.96))
                .multilineTextAlignment(titleAlignment)
                .lineLimit(2)
                .minimumScaleFactor(0.88)
                .fixedSize(horizontal: false, vertical: true)

            Text(profile.name)
                .font(.system(size: nameSize, weight: .bold, design: .serif))
                .foregroundStyle(Color.white)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
                .multilineTextAlignment(lineAlignment)
                .fixedSize(horizontal: false, vertical: true)

            Text(profile.combinedSigns)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1)
                .foregroundStyle(Color.white.opacity(0.82))
                .lineLimit(1)
                .multilineTextAlignment(lineAlignment)
        }
    }

    private func adaptiveBadge(_ placement: ConnectArrivalBadgePlacement) -> some View {
        Text(profile.matchStyle.introLabel.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .tracking(1.4)
            .foregroundStyle(ZD.Color.accent.opacity(0.98))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(glowPulse ? 0.28 : 0.36))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(ZD.Color.accent.opacity(0.42), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.20), radius: 8, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: placement.alignment)
            .padding(placement.insets)
    }
}

private struct ConnectArrivalBackdropCard: View {
    let profile: DeckProfile
    let activeIndex: Int
    let index: Int

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ConnectProfileImage(
                    assetName: profile.imageName,
                    size: proxy.size,
                    focalPoint: profile.imageAnchor,
                clipShape: .roundedRectangle(32)
                )
                    .saturation(0.10)
                    .brightness(-0.46)
                    .contrast(1.10)
                    .scaleEffect(1.01)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.76),
                        Color.black.opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.03),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .center
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .rotationEffect(.degrees(Double((activeIndex % 4) - 1) * 0.6))
        .offset(
            x: CGFloat((activeIndex % 3) - 1) * 4,
            y: CGFloat((index % 2 == 0 ? 1 : -1) * 2)
        )
    }
}

private enum ConnectArrivalCompositionVariant: Int {
    case bottomLeft
    case centeredLow
    case leftCompact
    case minimal

    static func variant(for profile: DeckProfile) -> ConnectArrivalCompositionVariant {
        let seed = stableSeed(
            profile.name,
            profile.archetypeTitle,
            profile.combinedSigns,
            profile.matchStyle.rawValue
        )

        return ConnectArrivalCompositionVariant(rawValue: seed % 4) ?? .bottomLeft
    }

    var baseScrim: [Color] {
        switch self {
        case .bottomLeft:
            return [
                Color.black.opacity(0.16),
                Color.black.opacity(0.28),
                Color.black.opacity(0.72)
            ]
        case .centeredLow:
            return [
                Color.black.opacity(0.06),
                Color.black.opacity(0.18),
                Color.black.opacity(0.58)
            ]
        case .leftCompact:
            return [
                Color.black.opacity(0.78),
                Color.black.opacity(0.44),
                .clear
            ]
        case .minimal:
            return [
                Color.black.opacity(0.00),
                Color.black.opacity(0.12),
                Color.black.opacity(0.46)
            ]
        }
    }

    var baseStartPoint: UnitPoint {
        switch self {
        case .bottomLeft:
            return .leading
        case .centeredLow:
            return .top
        case .leftCompact:
            return .leading
        case .minimal:
            return .top
        }
    }

    var baseEndPoint: UnitPoint {
        switch self {
        case .bottomLeft:
            return .bottomTrailing
        case .centeredLow:
            return .bottom
        case .leftCompact:
            return .trailing
        case .minimal:
            return .bottom
        }
    }

    var glowStartPoint: UnitPoint {
        switch self {
        case .bottomLeft:
            return .topTrailing
        case .centeredLow:
            return .topTrailing
        case .leftCompact:
            return .topTrailing
        case .minimal:
            return .topLeading
        }
    }

    var glowEndPoint: UnitPoint {
        switch self {
        case .bottomLeft, .centeredLow, .leftCompact:
            return .center
        case .minimal:
            return .bottomTrailing
        }
    }

    private static func stableSeed(_ values: String...) -> Int {
        values.joined(separator: "|").unicodeScalars.reduce(0) { total, scalar in
            total + Int(scalar.value)
        }
    }
}

private enum ConnectArrivalBadgePlacement {
    case topLeading
    case topTrailing

    var alignment: Alignment {
        switch self {
        case .topLeading:
            return .topLeading
        case .topTrailing:
            return .topTrailing
        }
    }

    var insets: EdgeInsets {
        switch self {
        case .topLeading:
            return EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 0)
        case .topTrailing:
            return EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 14)
        }
    }
}

private struct ConnectBreathMoment: View {
    let text: String
    let lens: ConnectFilter

    var body: some View {
        Text(text)
            .font(.system(size: breathFontSize, weight: breathWeight, design: .serif))
            .foregroundStyle(ZD.Color.textPrimary.opacity(textOpacity))
            .multilineTextAlignment(textAlignment)
            .lineSpacing(lineSpacing)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                ZStack {
                    Circle()
                        .stroke(accentColor.opacity(strokeOpacity), lineWidth: 1)
                        .frame(width: circleSize, height: circleSize)
                        .offset(x: circleOffsetX, y: 10)

                    Circle()
                        .fill(accentColor.opacity(fillOpacity))
                        .frame(width: circleSize * 0.72, height: circleSize * 0.72)
                        .blur(radius: lens == .newEnergy ? 10 : 18)
                        .offset(x: -circleOffsetX, y: -18)
                }
            )
            .accessibilityLabel(text)
    }

    private var accentColor: Color {
        switch lens {
        case .compatible:
            return Color(red: 0.58, green: 0.68, blue: 0.78)
        case .newEnergy:
            return Color(red: 0.82, green: 0.68, blue: 0.46)
        case .similar:
            return Color(red: 0.56, green: 0.38, blue: 0.46)
        }
    }

    private var breathFontSize: CGFloat {
        switch lens {
        case .compatible: return 21
        case .newEnergy: return 25
        case .similar: return 23
        }
    }

    private var breathWeight: Font.Weight {
        lens == .newEnergy ? .bold : .semibold
    }

    private var textOpacity: Double {
        switch lens {
        case .compatible: return 0.64
        case .newEnergy: return 0.86
        case .similar: return 0.78
        }
    }

    private var textAlignment: TextAlignment {
        lens == .newEnergy ? .leading : .center
    }

    private var frameAlignment: Alignment {
        lens == .newEnergy ? .leading : .center
    }

    private var horizontalPadding: CGFloat {
        lens == .compatible ? 34 : 22
    }

    private var verticalPadding: CGFloat {
        switch lens {
        case .compatible: return 48
        case .newEnergy: return 24
        case .similar: return 42
        }
    }

    private var lineSpacing: CGFloat {
        lens == .similar ? 5 : 2
    }

    private var circleSize: CGFloat {
        lens == .newEnergy ? 152 : 210
    }

    private var circleOffsetX: CGFloat {
        lens == .newEnergy ? -128 : -118
    }

    private var strokeOpacity: Double {
        lens == .compatible ? 0.08 : 0.14
    }

    private var fillOpacity: Double {
        lens == .newEnergy ? 0.06 : 0.035
    }
}

private struct ConnectLensSelectorSheet: View {
    let lenses: [ConnectFilter]
    let selectedLens: ConnectFilter
    let lensTitle: (ConnectFilter) -> String
    let lensLine: (ConnectFilter) -> String
    let lensColor: (ConnectFilter) -> Color
    let onSelect: (ConnectFilter) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            ZD.Color.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a lens")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("Choose what kind of person you want to understand first")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                    }

                    Spacer(minLength: 12)

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(ZD.Color.textPrimary.opacity(0.82))
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(ZD.Color.card.opacity(0.78)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close lens selector")
                }

                VStack(spacing: 12) {
                    ForEach(lenses) { lens in
                        lensButton(for: lens)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
    }

    private func lensButton(for lens: ConnectFilter) -> some View {
        let isSelected = selectedLens == lens

        return Button {
            onSelect(lens)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(lensColor(lens).opacity(isSelected ? 0.92 : 0.42))
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text(lensTitle(lens))
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(lensLine(lens))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ZD.Color.accent)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                lensColor(lens).opacity(isSelected ? 0.22 : 0.08),
                                ZD.Color.card.opacity(isSelected ? 0.74 : 0.52)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(lensColor(lens).opacity(isSelected ? 0.25 : 0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Choose \(lensTitle(lens)) lens")
    }

    private func uniqueProfilesByImageName<S: Sequence>(in profiles: S) -> [DeckProfile] where S.Element == DeckProfile {
        var seen = Set<String>()
        var unique: [DeckProfile] = []

        for profile in profiles {
            guard seen.insert(profile.imageName).inserted else { continue }
            unique.append(profile)
        }

        return unique
    }
}

private struct ConnectDiscoveryCard: View {
    let profile: DeckProfile
    let viewer: UserProfile?
    let lens: ConnectFilter
    let layout: ConnectCardLayoutStyle
    let rhythm: ConnectCardRhythm
    let framing: ConnectEmotionalFraming
    let variant: Int
    let onOpen: () -> Void

    @State private var appeared = false

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(profile: profile)
    }

    var body: some View {
        Button(action: onOpen) {
            renderedCard
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            withAnimation(.easeOut(duration: 0.58).delay(0.04)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private var renderedCard: some View {
        if isContainerFreeHero || layout == .edgeBleed || layout == .quote {
            cardContent
                .padding(.vertical, containerFreeVerticalPadding)
        } else {
            cardContent
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ZD.Color.card.opacity(cardFillOpacity),
                                    lensCardTint.opacity(cardTintOpacity),
                                    ZD.Color.cardAlt.opacity(cardAltOpacity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .stroke(lensCardTint.opacity(cardStrokeOpacity), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(cardShadowOpacity), radius: cardShadowRadius, y: cardShadowY)
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch layout {
        case .poster:
            posterCard
        case .portrait:
            portraitCard
        case .split:
            splitCard
        case .silent:
            silentCard
        case .edgeBleed:
            edgeBleedCard
        case .quote:
            quoteCard
        }
    }

    private var posterCard: some View {
        VStack(alignment: .leading, spacing: posterSpacing) {
            if isContainerFreeHero {
                integratedHeroPoster
            } else {
                editorialHeader(headlineSize: headlineSize, showsIdentity: false)

                HStack(alignment: .center, spacing: 14) {
                    portraitThumb(size: rhythm == .quiet ? 62 : 76)

                    VStack(alignment: .leading, spacing: 5) {
                        identityLine
                        Text(fitInsight)
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.78))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, horizontalInset)
            }

        }
        .padding(.bottom, posterBottomPadding)
    }

    private var integratedHeroPoster: some View {
        ZStack(alignment: .bottomLeading) {
            atmosphericCrop(height: integratedHeroHeight)
                .scaleEffect(1.055)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.03),
                    Color.black.opacity(0.20),
                    Color.black.opacity(0.66),
                    Color.black.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.72),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.34)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(descriptor)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(1.25)
                        .textCase(.uppercase)
                        .foregroundStyle(ZD.Color.accent.opacity(0.90))

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(alignment: .firstTextBaseline, spacing: 7) {
                            Text(profile.name)
                                .font(.system(size: 21, weight: .semibold, design: .serif))
                                .foregroundStyle(ZD.Color.textPrimary.opacity(0.88))

                            Text(profile.combinedSigns)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .tracking(1.1)
                                .foregroundStyle(ZD.Color.textPrimary.opacity(0.54))
                        }

                        Text(profile.archetypeTitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(ZD.Color.accent.opacity(0.58))
                            .lineLimit(2)
                            .minimumScaleFactor(0.86)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Text(dynamicHeadline)
                    .font(.system(size: integratedHeroHeadlineSize, weight: lensHeadlineWeight, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(integratedHeroLineSpacing)
                    .lineLimit(integratedHeroLineLimit)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                if let supportLine = cinematicSupportLine {
                    Text(supportLine)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.88))
                        .lineSpacing(2)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .frame(height: integratedHeroHeight)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .padding(.horizontal, integratedHeroHorizontalBleed)
        .shadow(color: Color.black.opacity(integratedHeroShadowOpacity), radius: 30, y: 18)
        .accessibilityElement(children: .combine)
    }

    private var portraitCard: some View {
        VStack(alignment: .leading, spacing: portraitStackSpacing) {
            editorialHeader(headlineSize: headlineSize - 2)

            imageStage(height: imageHeight, horizontalPadding: rhythm == .quiet ? 22 : 18)

            structuredBlocks
            .padding(.horizontal, horizontalInset)
            .padding(.bottom, structuredBottomPadding)
        }
    }

    private var silentCard: some View {
        ZStack(alignment: .bottomLeading) {
            atmosphericCrop(height: silentCardHeight)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.00),
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(profile.name)
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary.opacity(0.86))

                    Text(profile.combinedSigns)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(ZD.Color.muted.opacity(0.70))
                }

                Text(silentLine)
                    .font(.system(size: silentHeadlineSize, weight: lensHeadlineWeight, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(-1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
        }
        .frame(height: silentCardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }

    private var splitCard: some View {
        VStack(alignment: .leading, spacing: splitStackSpacing) {
            HStack(alignment: .top, spacing: 16) {
                portraitPanel

                VStack(alignment: .leading, spacing: 12) {
                    Text(descriptor)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(0.9)
                        .foregroundStyle(ZD.Color.accent)
                        .textCase(.uppercase)

                    Text(dynamicHeadline)
                        .font(.system(size: splitHeadlineSize, weight: lensHeadlineWeight, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(-1)
                        .lineLimit(3)
                        .minimumScaleFactor(0.76)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(2)

                    identityLine
                        .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.top, splitTopPadding)

            structuredBlocks
            .padding(.horizontal, 22)
            .padding(.bottom, structuredBottomPadding)
        }
    }

    private var edgeBleedCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack(alignment: .bottomLeading) {
                atmosphericCrop(height: edgeBleedImageHeight)
                    .scaleEffect(1.035)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.04),
                        Color.black.opacity(0.18),
                        Color.black.opacity(0.72),
                        Color.black.opacity(0.90)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.58),
                        Color.black.opacity(0.04)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack(alignment: .leading, spacing: 9) {
                    Text(descriptor)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(ZD.Color.accent.opacity(0.78))

                    Text(dynamicHeadline)
                        .font(.system(size: edgeBleedHeadlineSize, weight: lensHeadlineWeight, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(-1.2)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    identityLine
                        .opacity(0.84)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: edgeBleedImageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .padding(.horizontal, edgeBleedHorizontalBleed)
            .shadow(color: Color.black.opacity(0.24), radius: 24, y: 15)

            if let supportLine = cinematicSupportLine {
                Text(supportLine)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                    .lineLimit(supportLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
            }
        }
        .padding(.vertical, edgeBleedVerticalPadding)
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: quoteStackSpacing) {
            toneRow

            Text(dynamicHeadline)
                .font(.system(size: quoteHeadlineSize, weight: lensHeadlineWeight, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(-1.5)
                .lineLimit(quoteHeadlineLineLimit)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 12) {
                portraitThumb(size: 52)

                VStack(alignment: .leading, spacing: 5) {
                    identityLine

                    Text(fitInsight)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

        }
        .padding(.horizontal, quoteHorizontalPadding)
        .padding(.vertical, quoteVerticalPadding)
    }

    private func editorialHeader(headlineSize: CGFloat = 30, showsIdentity: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: headerSpacing) {
            if !isContainerFreeHero {
                toneRow
            }

            Text(dynamicHeadline)
                .font(.system(size: headlineSize, weight: lensHeadlineWeight, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(headlineLineSpacing)
                .lineLimit(headerHeadlineLineLimit)
                .minimumScaleFactor(isContainerFreeHero ? 0.92 : 1)
                .fixedSize(horizontal: false, vertical: true)

            if !isContainerFreeHero && showsIdentity {
                identityLine
            }
        }
        .padding(.horizontal, horizontalInset)
        .padding(.top, headerTopPadding)
    }

    private var toneRow: some View {
        HStack {
            Text(descriptor)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.9)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))
                .textCase(.uppercase)

            Spacer(minLength: 12)

            Text(profile.combinedSigns)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(ZD.Color.muted.opacity(0.78))
        }
    }

    private var identityLine: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(profile.name)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)

                Text(profile.archetypeTitle)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.70))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .allowsTightening(true)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.name)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)

                Text(profile.archetypeTitle)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.70))
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func imageStage(height: CGFloat, horizontalPadding: CGFloat) -> some View {
        ZStack {
            atmosphericCrop(height: height)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.00),
                    Color.black.opacity(0.16),
                    Color.black.opacity(0.54)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, horizontalPadding)
    }

    private var environmentalImageStage: some View {
        ZStack(alignment: .bottomLeading) {
            atmosphericCrop(height: 260)
                .scaleEffect(1.035)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.00),
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.74)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 7) {
                Text(descriptor)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(ZD.Color.accent.opacity(0.84))

                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(profile.name)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(profile.combinedSigns)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .tracking(0.9)
                        .foregroundStyle(ZD.Color.textPrimary.opacity(0.70))
                }

                Text(profile.archetypeTitle)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.76))
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .padding(.horizontal, -8)
        .shadow(color: Color.black.opacity(0.28), radius: 28, y: 18)
    }

    private func atmosphericCrop(height: CGFloat) -> some View {
        GeometryReader { proxy in
            ConnectProfileImage(
                assetName: profile.imageName,
                size: proxy.size,
                focalPoint: imageFocalPoint,
                clipShape: .roundedRectangle(26)
            )
                .saturation(lensImageSaturation)
                .contrast(lensImageContrast)
                .brightness(lensImageBrightness)
                .overlay(lensImageGrade.blendMode(.softLight))
        }
        .frame(height: height)
    }

    private var lensCardTint: Color {
        switch lens {
        case .compatible:
            return Color(red: 0.58, green: 0.68, blue: 0.78)
        case .newEnergy:
            return Color(red: 0.82, green: 0.68, blue: 0.46)
        case .similar:
            return Color(red: 0.56, green: 0.38, blue: 0.46)
        }
    }

    private var lensHeadlineWeight: Font.Weight {
        switch lens {
        case .compatible:
            return .semibold
        case .newEnergy:
            return .heavy
        case .similar:
            return .bold
        }
    }

    private var containerFreeVerticalPadding: CGFloat {
        switch lens {
        case .compatible: return 24
        case .newEnergy: return 8
        case .similar: return 20
        }
    }

    private var cardCornerRadius: CGFloat {
        switch lens {
        case .compatible: return 34
        case .newEnergy: return 26
        case .similar: return 32
        }
    }

    private var cardFillOpacity: Double {
        if layout == .silent { return lens == .newEnergy ? 0.52 : 0.42 }
        return lens == .compatible ? 0.72 : 0.86
    }

    private var cardTintOpacity: Double {
        switch lens {
        case .compatible: return 0.08
        case .newEnergy: return 0.18
        case .similar: return 0.12
        }
    }

    private var cardAltOpacity: Double {
        if layout == .silent { return 0.22 }
        return lens == .compatible ? 0.34 : 0.46
    }

    private var cardStrokeOpacity: Double {
        switch lens {
        case .compatible: return layout == .silent ? 0.05 : 0.10
        case .newEnergy: return layout == .silent ? 0.10 : 0.20
        case .similar: return layout == .silent ? 0.08 : 0.14
        }
    }

    private var cardShadowOpacity: Double {
        switch lens {
        case .compatible: return layout == .silent ? 0.08 : 0.14
        case .newEnergy: return layout == .silent ? 0.16 : 0.24
        case .similar: return layout == .silent ? 0.12 : 0.19
        }
    }

    private var cardShadowRadius: CGFloat {
        switch lens {
        case .compatible: return layout == .silent ? 12 : 18
        case .newEnergy: return layout == .silent ? 16 : 24
        case .similar: return layout == .silent ? 14 : 22
        }
    }

    private var cardShadowY: CGFloat {
        switch lens {
        case .compatible: return layout == .silent ? 8 : 12
        case .newEnergy: return layout == .silent ? 9 : 15
        case .similar: return layout == .silent ? 8 : 14
        }
    }

    private var posterBottomPadding: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 54 : 34
        case .newEnergy: return rhythm == .hero ? 30 : 18
        case .similar: return rhythm == .hero ? 46 : 30
        }
    }

    private var integratedHeroHeight: CGFloat {
        switch lens {
        case .compatible: return 548
        case .newEnergy: return 494
        case .similar: return 532
        }
    }

    private var integratedHeroHeadlineSize: CGFloat {
        switch lens {
        case .compatible: return 40
        case .newEnergy: return 47
        case .similar: return 42
        }
    }

    private var integratedHeroLineSpacing: CGFloat {
        switch lens {
        case .compatible: return -0.5
        case .newEnergy: return -3
        case .similar: return 1
        }
    }

    private var integratedHeroLineLimit: Int {
        switch lens {
        case .compatible: return 4
        case .newEnergy: return 3
        case .similar: return 5
        }
    }

    private var integratedHeroHorizontalBleed: CGFloat {
        lens == .newEnergy ? -14 : -8
    }

    private var integratedHeroShadowOpacity: Double {
        lens == .compatible ? 0.22 : 0.30
    }

    private var portraitStackSpacing: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 28 : 23
        case .newEnergy: return rhythm == .hero ? 18 : 15
        case .similar: return rhythm == .hero ? 26 : 21
        }
    }

    private var structuredBottomPadding: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 34 : 28
        case .newEnergy: return rhythm == .hero ? 24 : 20
        case .similar: return rhythm == .hero ? 34 : 30
        }
    }

    private var silentHeadlineSize: CGFloat {
        switch lens {
        case .compatible: return 25
        case .newEnergy: return 31
        case .similar: return 29
        }
    }

    private var silentCardHeight: CGFloat {
        switch lens {
        case .compatible: return 304
        case .newEnergy: return 264
        case .similar: return 292
        }
    }

    private var splitStackSpacing: CGFloat {
        switch lens {
        case .compatible: return 24
        case .newEnergy: return 15
        case .similar: return 22
        }
    }

    private var splitTopPadding: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 34 : 26
        case .newEnergy: return rhythm == .hero ? 24 : 18
        case .similar: return rhythm == .hero ? 32 : 24
        }
    }

    private var edgeBleedImageHeight: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 342 : 306
        case .newEnergy: return rhythm == .hero ? 320 : 274
        case .similar: return rhythm == .hero ? 336 : 300
        }
    }

    private var edgeBleedHeadlineSize: CGFloat {
        switch lens {
        case .compatible: return rhythm == .hero ? 32 : 29
        case .newEnergy: return rhythm == .hero ? 37 : 33
        case .similar: return rhythm == .hero ? 34 : 31
        }
    }

    private var edgeBleedHorizontalBleed: CGFloat {
        lens == .newEnergy ? -16 : -12
    }

    private var edgeBleedVerticalPadding: CGFloat {
        lens == .newEnergy ? 4 : 10
    }

    private var supportLineLimit: Int {
        lens == .similar ? 3 : 2
    }

    private var quoteStackSpacing: CGFloat {
        switch lens {
        case .compatible: return 22
        case .newEnergy: return 14
        case .similar: return 24
        }
    }

    private var quoteHeadlineSize: CGFloat {
        switch lens {
        case .compatible: return rhythm == .quiet ? 28 : 32
        case .newEnergy: return rhythm == .quiet ? 32 : 38
        case .similar: return rhythm == .quiet ? 32 : 37
        }
    }

    private var quoteHeadlineLineLimit: Int {
        lens == .newEnergy ? 3 : 4
    }

    private var quoteHorizontalPadding: CGFloat {
        lens == .similar ? 18 : 10
    }

    private var quoteVerticalPadding: CGFloat {
        switch lens {
        case .compatible: return 42
        case .newEnergy: return 26
        case .similar: return 44
        }
    }

    private var headerSpacing: CGFloat {
        if isContainerFreeHero { return 0 }
        switch lens {
        case .compatible: return 18
        case .newEnergy: return 10
        case .similar: return 17
        }
    }

    private var headlineLineSpacing: CGFloat {
        switch lens {
        case .compatible: return 0.5
        case .newEnergy: return -2
        case .similar: return 1
        }
    }

    private var headerHeadlineLineLimit: Int? {
        if isContainerFreeHero { return 4 }
        return lens == .newEnergy ? 3 : nil
    }

    private var headerTopPadding: CGFloat {
        if isContainerFreeHero { return 18 }

        switch lens {
        case .compatible:
            return rhythm == .hero ? 40 : rhythm == .quiet ? 34 : 28
        case .newEnergy:
            return rhythm == .hero ? 26 : rhythm == .quiet ? 22 : 20
        case .similar:
            return rhythm == .hero ? 38 : rhythm == .quiet ? 32 : 26
        }
    }

    private var imageFocalPoint: UnitPoint {
        if isContainerFreeHero || layout == .edgeBleed || layout == .silent {
            return .center
        }

        return variant == 1 ? .top : .center
    }

    private var lensImageSaturation: Double {
        switch lens {
        case .similar:
            return 0.74
        case .compatible:
            return 0.96
        case .newEnergy:
            return 1.08
        }
    }

    private var lensImageContrast: Double {
        switch lens {
        case .similar:
            return 0.90
        case .compatible:
            return 0.96
        case .newEnergy:
            return 1.14
        }
    }

    private var lensImageBrightness: Double {
        switch lens {
        case .similar:
            return -0.075
        case .compatible:
            return 0.018
        case .newEnergy:
            return -0.055
        }
    }

    private var lensImageGrade: some View {
        LinearGradient(
            colors: lensImageGradeColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var lensImageGradeColors: [Color] {
        switch lens {
        case .similar:
            return [
                Color(red: 0.25, green: 0.16, blue: 0.24).opacity(0.22),
                Color(red: 0.48, green: 0.34, blue: 0.24).opacity(0.13)
            ]
        case .compatible:
            return [
                Color(red: 0.58, green: 0.68, blue: 0.78).opacity(0.12),
                Color.black.opacity(0.035)
            ]
        case .newEnergy:
            return [
                Color(red: 0.82, green: 0.68, blue: 0.46).opacity(0.17),
                Color(red: 0.40, green: 0.28, blue: 0.16).opacity(0.08)
            ]
        }
    }

    private var portraitPanel: some View {
        ZStack {
            ConnectProfileImage(
                assetName: profile.imageName,
                size: CGSize(width: 126, height: 174),
                focalPoint: .center,
                clipShape: .roundedRectangle(26)
            )

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.48)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(width: 126, height: 174)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func portraitThumb(size: CGFloat) -> some View {
        ConnectProfileImage(
            assetName: profile.imageName,
            size: CGSize(width: size, height: size),
            focalPoint: .center,
            clipShape: .roundedRectangle(size * 0.28)
        )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
    }

    private var insightBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("What stands out")
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.accent.opacity(0.62))
            .textCase(.uppercase)
            .tracking(0.8)

            Text(fitInsight)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var promptBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Ask this")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent.opacity(0.62))
                .textCase(.uppercase)
                .tracking(0.8)

            Text(conversationDirection)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var structuredBlocks: some View {
        VStack(alignment: .leading, spacing: rhythm == .quiet ? 13 : 16) {
            if shouldShowInsightBlock {
                insightBlock
            }

            if shouldShowPromptBlock {
                promptBlock
            }
        }
    }

    private var shouldShowInsightBlock: Bool {
        if lens == .compatible && rhythm == .quiet {
            return false
        }

        switch layout {
        case .portrait:
            return true
        case .split:
            return lens == .similar || rhythm != .quiet
        case .poster, .silent, .edgeBleed, .quote:
            return false
        }
    }

    private var shouldShowPromptBlock: Bool {
        if lens == .compatible {
            return false
        }

        switch layout {
        case .portrait:
            return rhythm != .quiet
        case .split:
            return lens == .newEnergy ? rhythm != .quiet : rhythm == .support
        case .poster, .silent, .edgeBleed, .quote:
            return false
        }
    }

    private var cinematicSupportLine: String? {
        let headline = dynamicHeadline.lowercased()
        let insight = fitInsight.lowercased()
        let repeatedConcepts = [
            "room",
            "familiar",
            "loud",
            "contrast",
            "slow",
            "rhythm",
            "pattern"
        ]

        if repeatedConcepts.contains(where: { headline.contains($0) && insight.contains($0) }) {
            return nil
        }

        return fitInsight
    }

    private var headlineSize: CGFloat {
        if layout == .silent {
            return 24
        }

        switch rhythm {
        case .hero:
            return isContainerFreeHero ? 38 : 38
        case .support:
            return 31
        case .quiet:
            return 27
        }
    }

    private var splitHeadlineSize: CGFloat {
        let wordCount = dynamicHeadline.split(whereSeparator: { $0.isWhitespace }).count

        switch wordCount {
        case 0...3:
            return 27
        case 4...5:
            return 24
        case 6...7:
            return 21
        default:
            return 19
        }
    }

    private var imageHeight: CGFloat {
        switch rhythm {
        case .hero:
            return 250
        case .support:
            return 198
        case .quiet:
            return 148
        }
    }

    private var horizontalInset: CGFloat {
        if isContainerFreeHero {
            return 10
        }

        return rhythm == .hero ? 26 : 22
    }

    private var posterSpacing: CGFloat {
        switch rhythm {
        case .hero:
            return isContainerFreeHero ? 20 : 30
        case .support:
            return 22
        case .quiet:
            return 24
        }
    }

    private var isContainerFreeHero: Bool {
        rhythm == .hero && layout == .poster
    }

    private var silentLine: String {
        switch lens {
        case .compatible:
            switch framing {
            case .comfort:
                return "You can land here"
            case .tension:
                return "The tension lowers around them"
            default:
                return "This feels easy to stay in"
            }
        case .newEnergy:
            switch framing {
            case .disruption:
                return "The moment changes direction"
            case .tension:
                return "Certainty gets harder here"
            default:
                return "They move something in you"
            }
        case .similar:
            switch framing {
            case .reflection:
                return "They understand the quiet part"
            case .observation:
                return "They notice what remains unsaid"
            default:
                return "They notice the quieter clue"
            }
        }
    }

    private var descriptor: String {
        ConnectEditorialCopy.descriptor(for: profile, lens: lens, framing: framing)
    }

    private var dynamicHeadline: String {
        ConnectEditorialCopy.dynamicHeadline(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        )
    }

    private var fitInsight: String {
        let reason = ConnectEditorialCopy.appearanceReason(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        )

        guard normalizedCopy(reason) == normalizedCopy(dynamicHeadline) else {
            return reason
        }

        let alternate = ConnectEditorialCopy.appearanceReason(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant + 1
        )

        return normalizedCopy(alternate) == normalizedCopy(dynamicHeadline) ? reason : alternate
    }

    private var conversationDirection: String {
        let prompt = ConnectEditorialCopy.conversationDirection(
            for: profile,
            lens: lens,
            framing: framing,
            variant: variant,
            fallback: presentation.chatStarterPrompts.first ?? profile.connectionPrompt
        )
        return trimmed(prompt, fallback: "Ask what feels different here")
    }

    private func trimmed(_ value: String, fallback: String) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return fallback }
        let words = clean.split(separator: " ")
        guard words.count > 16 else { return clean }
        return words.prefix(16).joined(separator: " ")
    }

    private func normalizedCopy(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct ConnectPrototypeDetailView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]

    let profile: DeckProfile
    let viewer: UserProfile?
    let lens: ConnectFilter
    let framing: ConnectEmotionalFraming
    let variant: Int
    let isParticipationLocked: Bool
    let onClose: () -> Void
    let onRequestSetup: () -> Void

    @State private var revealContent = false
    @State private var didSavePull = false

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(profile: profile)
    }

    private var isSavedToThreads: Bool {
        didSavePull || savedMatches.contains {
            $0.archetypeId == profile.archetypeId && $0.name == profile.name
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                backdrop
                    .onTapGesture(perform: onClose)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        identityHeader
                            .opacity(revealContent ? 1 : 0)
                            .offset(y: revealContent ? 0 : 10)

                        detailHero
                            .opacity(revealContent ? 1 : 0)
                            .blur(radius: revealContent ? 0 : 6)
                            .offset(y: revealContent ? 0 : 10)

                        detailSection("Why this matters", text: fitInsight)
                            .opacity(revealContent ? 1 : 0)
                            .offset(y: revealContent ? 0 : 10)

                        detailSection("What they bring out", text: conversationFeel)
                            .opacity(revealContent ? 1 : 0)
                            .offset(y: revealContent ? 0 : 10)

                        detailSection("Ask this", text: starterPrompt)
                            .opacity(revealContent ? 1 : 0)
                            .offset(y: revealContent ? 0 : 12)

                        actionStack
                            .opacity(revealContent ? 1 : 0)
                            .offset(y: revealContent ? 0 : 14)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, proxy.safeAreaInsets.top + 56)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + 68)
                    .frame(
                        width: min(max(proxy.size.width - 48, 0), 470),
                        alignment: .leading
                    )
                    .frame(maxWidth: .infinity)
                }

                closeButton
                    .padding(.leading, 18)
                    .padding(.top, proxy.safeAreaInsets.top + 10)

            }
        }
        .onAppear {
            trackPatternMemoryProfileEvent(.profileViewed)
            withAnimation(.easeOut(duration: 0.52).delay(0.08)) {
                revealContent = true
            }
        }
    }

    private var backdrop: some View {
        ZD.Color.bg
            .opacity(0.96)
            .overlay(.ultraThinMaterial.opacity(0.16))
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.15),
                        ZD.Color.card.opacity(0.14),
                        .clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 560
                )
            )
            .overlay(Color.black.opacity(0.22))
            .ignoresSafeArea()
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(ZD.Color.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.black.opacity(0.42)))
                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close profile")
    }

    private var detailHero: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                ConnectProfileImage(
                    assetName: profile.imageName,
                    size: proxy.size,
                    focalPoint: profile.imageAnchor,
                    clipShape: .roundedRectangle(28)
                )
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.28),
                    Color.black.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 292)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
        )
    }

    private var identityHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lens.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(0.9)
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)

            Text(dynamicHeadline)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(-1)
                .minimumScaleFactor(0.88)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(profile.name)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text("\(profile.combinedSigns) · \(profile.archetypeTitle)")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 4)
    }

    private func detailSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.8)

            Text(text)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionStack: some View {
        VStack(spacing: 10) {
            if isParticipationLocked {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Complete your profile so others can understand your identity")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(ZD.Color.textSecondary)

                    Button {
                        feedbackSoft()
                        onRequestSetup()
                    } label: {
                        HStack(spacing: 9) {
                            Image(systemName: "person.crop.square")
                                .font(.system(size: 15, weight: .bold))

                            Text("Set up profile")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(ZD.Gradient.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: savePullToThreads) {
                    HStack(spacing: 9) {
                        Image(systemName: isSavedToThreads ? "checkmark" : "sparkles")
                            .font(.system(size: 15, weight: .bold))

                        Text(isSavedToThreads ? "Saved to My Circle" : "Save this profile")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(ZD.Gradient.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isSavedToThreads)
            }

            Button(action: onClose) {
                Text("Keep observing")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(ZD.Color.card.opacity(0.62))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(ZD.Color.border.opacity(0.16), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    private var dynamicHeadline: String {
        ConnectEditorialCopy.dynamicHeadline(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        )
    }

    private var fitInsight: String {
        let reason = ConnectEditorialCopy.appearanceReason(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        )

        guard normalizedCopy(reason) == normalizedCopy(dynamicHeadline) else {
            return reason
        }

        let alternate = ConnectEditorialCopy.appearanceReason(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant + 1
        )

        return normalizedCopy(alternate) == normalizedCopy(dynamicHeadline) ? conversationFeel : alternate
    }

    private var conversationFeel: String {
        ConnectEditorialCopy.detailEffect(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        )
    }

    private var starterPrompt: String {
        presentation.chatStarterPrompts.first ?? "What helps people understand you?"
    }

    private func savePullToThreads() {
        guard !isSavedToThreads else { return }

        let primaryReason = profile.matchReasons.first
        let secondaryReason = profile.matchReasons.dropFirst().first

        let saved = SavedMatch(
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
            signalsRaw: ConnectProfileSignal.storageString(from: profile.signals),
            imageName: profile.imageName,
            imageAnchorRaw: imageAnchorRawValue(profile.imageAnchor),
            primaryReasonTitle: primaryReason?.title ?? "",
            primaryReasonDetail: primaryReason?.detail ?? "",
            secondaryReasonTitle: secondaryReason?.title ?? "",
            secondaryReasonDetail: secondaryReason?.detail ?? ""
        )

        context.insert(saved)

        do {
            try context.save()
            didSavePull = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.82)
            AnalyticsService.shared.track(
                .matchSaved(
                    archetypeID: profile.archetypeId,
                    score: profile.compatibilityScore,
                    matchStyle: profile.matchStyle.rawValue,
                    intent: profile.intent,
                    source: "connect_detail"
                )
            )
            trackPatternMemoryProfileEvent(.profileSaved, entityID: saved.id.uuidString)
        } catch {
            print("❌ Failed to save pull to My Circle: \(error)")
        }
    }

    private func trackPatternMemoryProfileEvent(_ type: PatternMemoryEventType, entityID: String? = nil) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent(
                type: type,
                entityID: entityID ?? profile.id.uuidString,
                lens: lens.title,
                profileIdentity: profile.combinedSigns,
                signal: profile.signals.first?.displayText,
                openTo: profile.intent
            )
        )
    }

    private func feedbackSoft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.62)
    }

    private func imageAnchorRawValue(_ point: UnitPoint) -> String {
        switch point {
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

    private func normalizedCopy(_ copy: String) -> String {
        copy
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }
}

private enum ConnectEditorialCopy {
    static func descriptor(
        for profile: DeckProfile,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming? = nil
    ) -> String {
        if let framing {
            return framing.label(for: lens)
        }

        return baseDescriptor(for: profile, lens: lens)
    }

    static func dynamicHeadline(
        for profile: DeckProfile,
        viewer: UserProfile? = nil,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming? = nil,
        variant: Int = 0
    ) -> String {
        guard let framing else {
            return defaultHeadline(for: profile, viewer: viewer, lens: lens)
        }

        if let lensHeadline = lensHeadline(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: framing,
            variant: variant
        ) {
            return lensHeadline
        }

        switch framing {
        case .observation:
            return pick(variant, [
                "They notice the small shifts first",
                "You catch their effect quickly",
                "The small details give something away"
            ])
        case .tension:
            return pick(variant, [
                "They ask for a different kind of honesty",
                "The mismatch makes you pay attention",
                "The quiet clue asks you to stay"
            ])
        case .recognition:
            return pick(variant, [
                "They understand what you rarely explain",
                "This feels familiar fast",
                "They catch what you were about to hide"
            ])
        case .curiosity:
            return pick(variant, [
                "You keep wanting another look",
                "They leave just enough unsaid",
                "The interest comes from what is not obvious"
            ])
        case .comfort:
            return pick(variant, [
                "This conversation feels easy",
                "They make the moment feel relaxed",
                "You do not need to translate as much here"
            ])
        case .disruption:
            return pick(variant, [
                "They interrupt your usual response",
                "The room changes when they enter it",
                "The conversation moves differently now"
            ])
        case .magnetism:
            return pick(variant, [
                "The feeling is quiet, but hard to miss",
                "They keep your attention",
                "Something here stays in your mind"
            ])
        case .reflection:
            return pick(variant, [
                "They reflect what you keep private",
                "They show you a familiar edge from another angle",
                "You notice yourself more clearly around them"
            ])
        case .expansion:
            return pick(variant, [
                "This opens a wider version of you",
                "They bring out a part of you that needs more room",
                "The conversation makes your world feel larger"
            ])
        }
    }

    static func conversationDirection(
        for profile: DeckProfile,
        lens: ConnectFilter,
        framing: ConnectEmotionalFraming,
        variant: Int,
        fallback: String
    ) -> String {
        switch lens {
        case .compatible:
            return pick(variant, [
                "Ask what makes honesty feel easy",
                "Ask what makes a conversation feel easy",
                "Ask what feels natural when trust is new"
            ])
        case .newEnergy:
            return pick(variant, [
                "Ask what has changed their mind recently",
                "Ask what they want to try next",
                "Ask what habit they are ready to question"
            ])
        case .similar:
            return pick(variant, [
                "Ask what they notice after everyone else moves on",
                "Ask what they rarely explain twice",
                "Ask what they remember longer than expected"
            ])
        }
    }

    static func appearanceReason(
        for profile: DeckProfile,
        viewer: UserProfile? = nil,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming?,
        variant: Int
    ) -> String {
        if let framing {
            if let lensReason = lensReason(
                for: profile,
                viewer: viewer,
                lens: lens,
                framing: framing,
                variant: variant
            ) {
                return lensReason
            }

            return reason(for: profile.matchStyle, lens: lens, framing: framing, variant: variant)
        }

        return detailReason(for: profile.matchStyle, variant: variant)
    }

    static func detailEffect(
        for profile: DeckProfile,
        viewer: UserProfile? = nil,
        lens: ConnectFilter,
        framing: ConnectEmotionalFraming,
        variant: Int
    ) -> String {
        let text = profileText(profile)

        switch lens {
        case .compatible:
            if containsAny(text, ["warm up slowly", "take my time", "need a minute", "trust slowly", "not like being pushed"]) {
                return pick(variant, [
                    "They let you decide what to reveal without making the wait awkward",
                    "You settle because they are not measuring how fast you open",
                    "They make guardedness feel allowed, not inconvenient"
                ])
            }

            if containsAny(text, ["notice", "listen", "remember", "read the room", "small shifts", "mood shifts"]) {
                return pick(variant, [
                    "You stop explaining the mood because they already move gently with it",
                    "They notice enough that you can stop managing every small change",
                    "They make being seen feel calm instead of demanding"
                ])
            }

            if viewer?.westernSign == profile.westernSign || viewer?.chineseSign == profile.chineseSign {
                return pick(variant, [
                    "Something familiar in them lets you arrive without overexplaining",
                    "You relax into the overlap before either of you has to name it",
                    "They make belonging feel ordinary in the best way"
                ])
            }

            return pick(variant, [
                "You stop monitoring yourself around them",
                "They make ordinary honesty easier to keep",
                "They give you somewhere to land without asking for a performance"
            ])

        case .newEnergy:
            if containsAny(text, ["question", "questions", "direct", "truth", "honesty", "exactly what i mean", "say things sooner"]) {
                return pick(variant, [
                    "They make the safe answer feel too small to keep",
                    "You say the sharper thing because they can hold it",
                    "They bring out the answer you usually edit away"
                ])
            }

            if containsAny(text, ["humor", "joke", "playful", "chaos", "interesting", "quickly", "fast", "keep up", "try almost anything"]) {
                return pick(variant, [
                    "They catch the part of you that wants to behave less predictably",
                    "You try the strange angle before you can talk yourself out of it",
                    "They make the expected move feel dull"
                ])
            }

            if containsAny(text, ["soft", "gentle", "care", "warm", "steady", "dependable"]) {
                return pick(variant, [
                    "They change the moment by refusing to make softness passive",
                    "You rethink what strength has to sound like",
                    "They make calm feel like a move, not a retreat"
                ])
            }

            return pick(variant, [
                "They make your usual answer feel incomplete",
                "You notice yourself choosing the less rehearsed move",
                "They bring out the bolder thought before caution can organize it"
            ])

        case .similar:
            if containsAny(text, ["notice", "listen", "remember", "read the room", "small shifts", "mood shifts"]) {
                return pick(variant, [
                    "They notice what changes between what you say and what you mean",
                    "They stay with the detail everyone else would pass over",
                    "They remember the small part that explains the larger one"
                ])
            }

            if containsAny(text, ["warm up slowly", "take my time", "need a minute", "trust slowly", "not like being pushed"]) {
                return pick(variant, [
                    "They understand why the guarded part arrives first",
                    "They hear the delay as information, not distance",
                    "They recognize what you protect by moving carefully"
                ])
            }

            if containsAny(text, ["question", "questions", "direct", "truth", "honesty", "exactly what i mean", "say things sooner"]) {
                return pick(variant, [
                    "They hear what directness still leaves unsaid",
                    "They stay with the private part after the honest sentence lands",
                    "They recognize the concern behind the clean answer"
                ])
            }

            return pick(variant, [
                "They notice what you almost hide",
                "They recognize the meaning before the story is finished",
                "They hear the part that arrives after the simple answer"
            ])
        }
    }

    private static func baseDescriptor(for profile: DeckProfile, lens: ConnectFilter?) -> String {
        if let lens {
            return lens.title
        }

        switch profile.matchStyle {
        case .harmonious:
            return "Observe First"
        case .mirrored:
            return "Depth"
        case .growth:
            return "Spark"
        case .magnetic:
            return "Spark"
        case .intense:
            return "Spark"
        }
    }

    private static func reason(
        for style: MatchStyle,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming,
        variant: Int
    ) -> String {
        switch framing {
        case .observation:
            return pick(variant, [
                "They notice small shifts before most people do",
                "They catch what shifts before either of you explains it",
                "They catch the details you usually track"
            ])
        case .tension:
            return pick(variant, [
                "Their certainty presses against your instinct to wait",
                "They move directly where you usually hesitate",
                "They expose what you usually keep flexible"
            ])
        case .recognition:
            return pick(variant, [
                "They name what you usually circle around",
                "They make the familiar parts easy to see",
                "They recognize the truth before you make it louder"
            ])
        case .curiosity:
            return pick(variant, [
                "They leave enough space for your questions to keep forming",
                "They make you look twice",
                "They hold back just enough for your attention to follow"
            ])
        case .comfort:
            return pick(variant, [
                "Their steadiness lets you stop scanning for trouble",
                "They bring a calmer tempo to the parts of you that scan quickly",
                "Their presence makes directness feel less expensive"
            ])
        case .disruption:
            return pick(variant, [
                "They bring out the part of you that wants a cleaner answer",
                "They interrupt the version of you that stays composed",
                "They make your usual timing harder to hide behind"
            ])
        case .magnetism:
            return pick(variant, [
                "They carry the kind of certainty you tend to test",
                "Their presence pulls focus without asking you to chase it",
                "They create a charge you want to follow slowly"
            ])
        case .reflection:
            return pick(variant, [
                "They reflect the part of you that reads more than you reveal",
                "They show your restraint from another angle",
                "They catch what you usually keep understated"
            ])
        case .expansion:
            return pick(variant, [
                "They widen the conversation without making it louder",
                "They make the next move feel less automatic",
                "They bring a different scale to questions you already carry"
            ])
        }
    }

    private struct CopyCue {
        let easeObservation: String
        let easeRecognition: String
        let easeCuriosity: String
        let easeComfort: String
        let easeMagnetism: String
        let easeReflection: String
        let easeReason: String
        let sparkObservation: String
        let sparkTension: String
        let sparkCuriosity: String
        let sparkComfort: String
        let sparkDisruption: String
        let sparkReflection: String
        let sparkReason: String
        let depthObservation: String
        let depthTension: String
        let depthCuriosity: String
        let depthComfort: String
        let depthMagnetism: String
        let depthReflection: String
        let depthReason: String
    }

    private static func personCue(for profile: DeckProfile) -> CopyCue {
        let text = profileText(profile)

        if containsAny(text, ["warm up slowly", "take my time", "need a minute", "trust slowly", "space to think", "not like being pushed"]) {
            return CopyCue(
                easeObservation: "They do not rush what you are still deciding",
                easeRecognition: "You get a little more room to arrive",
                easeCuriosity: "The conversation gets to breathe",
                easeComfort: "They do not ask for the full story too soon",
                easeMagnetism: "Time feels less demanding around them",
                easeReflection: "You stop monitoring how guarded you seem",
                easeReason: "They make trust feel uncomplicated",
                sparkObservation: "Their restraint makes the moment change direction",
                sparkTension: "They make silence feel like a dare",
                sparkCuriosity: "They make you want to test the next possibility",
                sparkComfort: "They turn quiet into movement",
                sparkDisruption: "They make the careful response feel too small",
                sparkReflection: "They draw out the part of you that wants to risk more",
                sparkReason: "They make stillness feel like a starting point",
                depthObservation: "They hear the pause before the fuller thought",
                depthTension: "They know guardedness is information",
                depthCuriosity: "They notice what someone protects before speaking",
                depthComfort: "They understand why honesty arrives in pieces",
                depthMagnetism: "Their guardedness means something specific",
                depthReflection: "They recognize the part of you that waits",
                depthReason: "They understand the silence before the story"
            )
        }

        if containsAny(text, ["notice", "listen", "remember", "read the room", "don’t miss", "small shifts", "subtle changes", "mood shifts"]) {
            return CopyCue(
                easeObservation: "They notice without turning it into pressure",
                easeRecognition: "You explain less because the room feels steady",
                easeCuriosity: "Ordinary moments feel easier to stay inside",
                easeComfort: "They track the mood without making you perform it",
                easeMagnetism: "Their attention makes honesty easier",
                easeReflection: "You stop checking whether you belong",
                easeReason: "They make the space easier to inhabit",
                sparkObservation: "They catch the detail that changes the direction",
                sparkTension: "They make your polished line harder to keep",
                sparkCuriosity: "They introduce the question you were not considering",
                sparkComfort: "They turn being noticed into momentum",
                sparkDisruption: "They interrupt the version you were about to perform",
                sparkReflection: "They move the thought somewhere new",
                sparkReason: "They catch the part of you that wants to be less composed",
                depthObservation: "They notice what you protect by making it casual",
                depthTension: "They stay with the detail everyone else would miss",
                depthCuriosity: "They know which detail carries the meaning",
                depthComfort: "They understand what your wording protects",
                depthMagnetism: "Their attention stays with the smallest detail",
                depthReflection: "They see what you soften before you say it",
                depthReason: "They hear what the easier version protects"
            )
        }

        if containsAny(text, ["question", "questions", "direct", "truth", "honesty", "exactly what i mean", "say things sooner"]) {
            return CopyCue(
                easeObservation: "They make directness feel less expensive",
                easeRecognition: "You do not have to circle the real answer",
                easeCuriosity: "The conversation rarely needs rescuing",
                easeComfort: "They make plain speech feel safe",
                easeMagnetism: "Their clarity keeps you from over-editing",
                easeReflection: "You stop preparing a cleaner version",
                easeReason: "They let the honest answer arrive without effort",
                sparkObservation: "They ask before you know if you wanted it asked",
                sparkTension: "They draw the cleaner lie out of hiding",
                sparkCuriosity: "They make your curiosity louder than your caution",
                sparkComfort: "They make the edited version feel incomplete",
                sparkDisruption: "They make the prepared line less convincing",
                sparkReflection: "They make the sharper sentence possible",
                sparkReason: "They do not let your polished answer be the final one",
                depthObservation: "They hear what directness leaves out",
                depthTension: "They make honesty feel private before it gets loud",
                depthCuriosity: "They make the real question feel unavoidable",
                depthComfort: "They let truth arrive without a performance",
                depthMagnetism: "Their honesty lingers after the moment passes",
                depthReflection: "They reflect the part of you that wants fewer edits",
                depthReason: "They stay with the moment after it gets honest"
            )
        }

        if containsAny(text, ["humor", "joke", "playful", "chaos", "interesting", "quickly", "fast", "keep up", "try almost anything"]) {
            return CopyCue(
                easeObservation: "They make lightness feel easy to trust",
                easeRecognition: "You soften before you realize you are laughing",
                easeCuriosity: "Simple moments keep carrying themselves",
                easeComfort: "They keep things easy without making them shallow",
                easeMagnetism: "Their playfulness keeps you present",
                easeReflection: "You stop trying to manage the mood",
                easeReason: "They make openness feel less serious in the best way",
                sparkObservation: "They make the edited version feel too small",
                sparkTension: "They draw out the version that behaves less",
                sparkCuriosity: "You want to see what they do next",
                sparkComfort: "They make the moment start moving",
                sparkDisruption: "They make the expected move feel boring",
                sparkReflection: "They bring out the part of you that wants more nerve",
                sparkReason: "They bring out the part of you that wants the riskier sentence",
                depthObservation: "They hide sincerity inside the joke",
                depthTension: "They make you wonder what the humor protects",
                depthCuriosity: "You want the serious layer behind the playful one",
                depthComfort: "They reveal meaning from the side",
                depthMagnetism: "Their lightness has something private under it",
                depthReflection: "They reflect the part of you that jokes before truth",
                depthReason: "They make the unserious moment reveal more than expected"
            )
        }

        if containsAny(text, ["soft", "gentle", "care", "care more", "warm", "steady", "dependable", "effort matters"]) {
            return CopyCue(
                easeObservation: "They make steadiness feel personal",
                easeRecognition: "You stop bracing for mixed messages",
                easeCuriosity: "Ordinary care feels complete around them",
                easeComfort: "They make effort feel ordinary in a good way",
                easeMagnetism: "Their steadiness gives you somewhere to land",
                easeReflection: "You do not need to prove your place",
                easeReason: "They make care feel easier to receive",
                sparkObservation: "They make softness change the moment",
                sparkTension: "They unsettle you by staying steady",
                sparkCuriosity: "You want to know what they choose when it matters",
                sparkComfort: "They turn calm into a new possibility",
                sparkDisruption: "They interrupt you by refusing to perform",
                sparkReflection: "They make you question what strength has to look like",
                sparkReason: "They make certainty feel less important than effort",
                depthObservation: "They stay with what matters after the moment passes",
                depthTension: "They make care feel like a private standard",
                depthCuriosity: "You want to know what earns their effort",
                depthComfort: "They make loyalty feel intimate, not automatic",
                depthMagnetism: "Their steadiness has a private weight",
                depthReflection: "They reflect the part of you that wants to trust slowly",
                depthReason: "They make the small proof matter more than the claim"
            )
        }

        return CopyCue(
            easeObservation: "They make the first moment feel less guarded",
            easeRecognition: "You explain less around them",
            easeCuriosity: "The conversation rarely needs rescuing",
            easeComfort: "You stop preparing the cleaner version of yourself",
            easeMagnetism: "Something about them softens the edges",
            easeReflection: "You stop monitoring yourself around them",
            easeReason: "They do not make you prove the mood first",
            sparkObservation: "They catch your attention before you can edit it",
            sparkTension: "They make the prepared version stop working",
            sparkCuriosity: "They make your curiosity louder than your caution",
            sparkComfort: "They make the easy response feel unfinished",
            sparkDisruption: "You say the thing you normally would not say",
            sparkReflection: "They catch the part of you that wants less polish",
            sparkReason: "They bring out the sentence you did not plan to say",
            depthObservation: "They notice what changes when you continue",
            depthTension: "They stay with what you made sound casual",
            depthCuriosity: "They make the unsaid part feel worth following",
            depthComfort: "They make honesty feel private before it feels exposed",
            depthMagnetism: "They stay in your mind afterward",
            depthReflection: "They reflect the private layer",
            depthReason: "They stay with the detail others move past"
        )
    }

    private static func signalSpecificReason(
        for profile: DeckProfile,
        lens: ConnectFilter,
        variant: Int
    ) -> String? {
        let text = profile.signals.map(\.response).joined(separator: " ").lowercased()

        if containsAny(text, ["warm up slowly", "need a minute", "take my time", "trust slowly"]) {
            switch lens {
            case .compatible:
                return pick(variant, [
                    "They do not rush the part where you decide what to reveal",
                    "They let your guarded thought arrive in its own time",
                    "They make waiting feel considerate, not distant"
                ])
            case .newEnergy:
                return pick(variant, [
                    "They make patience feel sharper than a quick answer",
                    "You want to know what finally gets past their guard",
                    "Their restraint makes your curiosity harder to hide"
                ])
            case .similar:
                return pick(variant, [
                    "They make trust feel earned in small pieces",
                    "They hear the pause before the fuller thought",
                    "They do not ask for the full story too soon"
                ])
            }
        }

        if containsAny(text, ["notice", "remember", "listen", "don’t miss", "mood shifts"]) {
            switch lens {
            case .compatible:
                return pick(variant, [
                    "They lower the need to explain",
                    "You explain less because they catch the shift",
                    "They make ordinary timing feel complete"
                ])
            case .newEnergy:
                return pick(variant, [
                    "They catch the detail your polished version tries to skip",
                    "They notice the moment your caution starts to lose",
                    "They make the second thought harder to hide"
                ])
            case .similar:
                return pick(variant, [
                    "They notice what you protect by making it casual",
                    "They stay with the detail everyone else would move past",
                    "They hear what changes when you keep talking"
                ])
            }
        }

        if containsAny(text, ["question", "direct", "truth", "honesty", "exactly what i mean"]) {
            switch lens {
            case .compatible:
                return pick(variant, [
                    "They make directness feel uncomplicated",
                    "They let the honest answer arrive without drama",
                    "You do not have to soften the simple truth"
                ])
            case .newEnergy:
                return pick(variant, [
                    "They ask the question before you know whether you wanted it asked",
                    "They do not let your polished version be the final one",
                    "They make your safer sentence feel too small"
                ])
            case .similar:
                return pick(variant, [
                    "They make honesty feel private before it feels exposed",
                    "They stay with the moment after it gets honest",
                    "They hear what directness leaves out"
                ])
            }
        }

        return nil
    }

    private static func viewerSpecificReason(
        for profile: DeckProfile,
        viewer: UserProfile?,
        lens: ConnectFilter,
        variant: Int
    ) -> String? {
        guard let viewer else { return nil }

        if viewer.westernSign == profile.westernSign {
            switch lens {
            case .compatible:
                return "They make belonging feel simple without naming it"
            case .newEnergy:
                return "They make your own habits easier to notice"
            case .similar:
                return "They notice what you leave unfinished"
            }
        }

        if viewer.chineseSign == profile.chineseSign {
            switch lens {
            case .compatible:
                return "They give you somewhere easy to land"
            case .newEnergy:
                return "They make your usual reflex less automatic"
            case .similar:
                return "They notice where you get quiet"
            }
        }

        if westernElement(of: viewer.westernSign) == westernElement(of: profile.westernSign) {
            switch lens {
            case .compatible:
                return pick(variant, [
                    "They feel familiar faster than expected",
                    "You stop working so hard to be understood",
                    "They make the room easier to trust"
                ])
            case .newEnergy:
                return pick(variant, [
                    "They push the moment in a new direction",
                    "They make your usual move less certain",
                    "They make familiar instincts behave differently"
                ])
            case .similar:
                return pick(variant, [
                    "They understand why you start there",
                    "They recognize what you leave unfinished",
                    "They notice the meaning inside a familiar instinct"
                ])
            }
        }

        return nil
    }

    private static func titleSpecificReason(
        for profile: DeckProfile,
        lens: ConnectFilter,
        variant: Int
    ) -> String? {
        switch lens {
        case .compatible:
            return pick(variant, [
                "They make the moment feel unforced",
                "They make ordinary time feel complete",
                "They soften the need to perform"
            ])
        case .newEnergy:
            return pick(variant, [
                "They draw out your less edited thought",
                "They make caution feel too small",
                "They make the prepared line less interesting"
            ])
        case .similar:
            return pick(variant, [
                "They stay with the private detail",
                "They notice what you almost hide",
                "They make the small proof matter"
            ])
        }
    }

    private static func profileIdentityLine(
        for profile: DeckProfile,
        lens: ConnectFilter,
        variant: Int
    ) -> String {
        titleSpecificReason(for: profile, lens: lens, variant: variant)
            ?? signFallbackLine(for: profile, lens: lens, variant: variant)
    }

    private static func signSpecificLine(
        for profile: DeckProfile,
        viewer: UserProfile?,
        lens: ConnectFilter,
        variant: Int
    ) -> String {
        viewerSpecificReason(for: profile, viewer: viewer, lens: lens, variant: variant)
            ?? signFallbackLine(for: profile, lens: lens, variant: variant)
    }

    private static func signFallbackLine(
        for profile: DeckProfile,
        lens: ConnectFilter,
        variant: Int
    ) -> String {
        switch lens {
        case .compatible:
            return pick(variant, [
                "They make the moment easier to stay in",
                "They soften the room without asking for much",
                "They make belonging feel less complicated"
            ])
        case .newEnergy:
            return pick(variant, [
                "They change the direction of the moment",
                "They make the next move less predictable",
                "They make your usual response feel incomplete"
            ])
        case .similar:
            return pick(variant, [
                "They notice the subtext",
                "They remember the detail others miss",
                "They understand what the simple version leaves out"
            ])
        }
    }

    private static func profileText(_ profile: DeckProfile) -> String {
        [
            profile.essence,
            profile.intent,
            profile.archetypeTitle,
            profile.connectionPrompt,
            profile.frictionNote,
            profile.signals.map(\.response).joined(separator: " ")
        ]
            .joined(separator: " ")
            .lowercased()
    }

    private static func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }

    private static func westernElement(of sign: WesternZodiac) -> String {
        switch sign {
        case .aries, .leo, .sagittarius:
            return "fire"
        case .taurus, .virgo, .capricorn:
            return "earth"
        case .gemini, .libra, .aquarius:
            return "air"
        case .cancer, .scorpio, .pisces:
            return "water"
        }
    }

    private static func lensHeadline(
        for profile: DeckProfile,
        viewer: UserProfile?,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming,
        variant: Int
    ) -> String? {
        guard let lens else { return nil }
        let cue = personCue(for: profile)
        let signLine = signSpecificLine(for: profile, viewer: viewer, lens: lens, variant: variant)
        let profileLine = profileIdentityLine(for: profile, lens: lens, variant: variant)

        switch lens {
        case .compatible:
            switch framing {
            case .observation:
                return pick(variant, [cue.easeObservation, "You stop monitoring yourself around them", signLine])
            case .tension:
                return pick(variant, ["They reduce the tension without naming it", "You do not have to defend the softer answer", profileLine])
            case .recognition:
                return pick(variant, [cue.easeRecognition, "You stop needing to manage the mood", signLine])
            case .curiosity:
                return pick(variant, ["The conversation rarely needs rescuing", cue.easeCuriosity, profileLine])
            case .comfort:
                return pick(variant, ["You stop preparing the cleaner version of yourself", "They make ordinary moments feel complete", cue.easeComfort])
            case .disruption:
                return pick(variant, ["They make the moment feel easier to stay in", "You do not need to prove your place", signLine])
            case .magnetism:
                return pick(variant, ["Trust feels uncomplicated around them", cue.easeMagnetism, profileLine])
            case .reflection:
                return pick(variant, ["You stop checking whether you belong", "The ordinary parts feel accepted", cue.easeReflection])
            case .expansion:
                return pick(variant, ["They give you more space, not more pressure", "You open without noticing the effort", profileLine])
            }

        case .newEnergy:
            switch framing {
            case .observation:
                return pick(variant, [cue.sparkObservation, "They catch the thought you almost skipped", signLine])
            case .tension:
                return pick(variant, ["They make the prepared line stop working", cue.sparkTension, profileLine])
            case .recognition:
                return pick(variant, ["They make the familiar response feel unfinished", "They interrupt the version you rehearsed", signLine])
            case .curiosity:
                return pick(variant, ["They make your curiosity louder than caution", cue.sparkCuriosity, profileLine])
            case .comfort:
                return pick(variant, ["They make the easy response feel unfinished", "You relax, then try the riskier thing", cue.sparkComfort])
            case .disruption:
                return pick(variant, ["You say the thing you normally edit out", cue.sparkDisruption, signLine])
            case .magnetism:
                return pick(variant, ["They make the next thought arrive faster", "They catch the part of you that wants less polish", profileLine])
            case .reflection:
                return pick(variant, ["They reflect the edge you usually soften", "You notice the crack in your practiced answer", cue.sparkReflection])
            case .expansion:
                return pick(variant, ["They bring out the bolder thought", "You sound less edited around them", signLine])
            }

        case .similar:
            switch framing {
            case .observation:
                return pick(variant, [cue.depthObservation, "They hear the pause before you continue", signLine])
            case .tension:
                return pick(variant, ["They hear the concern beneath the confidence", cue.depthTension, profileLine])
            case .recognition:
                return pick(variant, ["They recognize the part you do not announce", "You feel known before you perform being open", signLine])
            case .curiosity:
                return pick(variant, ["They recognize what the story is circling", cue.depthCuriosity, profileLine])
            case .comfort:
                return pick(variant, ["They make honesty feel precise first", "They understand what the simple version leaves out", cue.depthComfort])
            case .disruption:
                return pick(variant, ["They notice what the easy answer protects", "They catch the concern behind the practiced version", signLine])
            case .magnetism:
                return pick(variant, ["They stay in your mind afterward", cue.depthMagnetism, profileLine])
            case .reflection:
                return pick(variant, ["They reflect the private layer", "You recognize yourself more slowly around them", cue.depthReflection])
            case .expansion:
                return pick(variant, ["They open the inward door first", "There is more in what they leave unfinished", signLine])
            }
        }
    }

    private static func lensReason(
        for profile: DeckProfile,
        viewer: UserProfile?,
        lens: ConnectFilter?,
        framing: ConnectEmotionalFraming,
        variant: Int
    ) -> String? {
        guard let lens else { return nil }
        let cue = personCue(for: profile)
        let signalLine = signalSpecificReason(for: profile, lens: lens, variant: variant)
        let viewerLine = viewerSpecificReason(for: profile, viewer: viewer, lens: lens, variant: variant)
        let titleLine = titleSpecificReason(for: profile, lens: lens, variant: variant)

        switch lens {
        case .compatible:
            return pick(variant, [
                signalLine ?? cue.easeReason,
                viewerLine ?? "They do not make you prove the mood first",
                titleLine ?? "They make ordinary moments feel complete"
            ])
        case .newEnergy:
            return pick(variant, [
                signalLine ?? cue.sparkReason,
                viewerLine ?? "They pull you toward a different possibility",
                titleLine ?? "They make the prepared line less interesting"
            ])
        case .similar:
            return pick(variant, [
                signalLine ?? cue.depthReason,
                viewerLine ?? "They hear the part that arrives later",
                titleLine ?? "They recognize the detail others move past"
            ])
        }
    }

    private static func detailReason(for style: MatchStyle, variant: Int) -> String {
        switch style {
        case .harmonious:
            return pick(variant, [
                "Their steadiness slows you without flattening you",
                "They bring a calmer tempo to the parts of you that scan quickly",
                "Their steadiness makes directness feel less expensive"
            ])
        case .mirrored:
            return pick(variant, [
                "They reflect the part of you that reads more than you reveal",
                "They catch what you usually keep understated",
                "They show your restraint from another angle"
            ])
        case .growth:
            return pick(variant, [
                "They make the next move feel less automatic",
                "They bring out the part of you that wants a cleaner sentence",
                "They bring a different scale to questions you already carry"
            ])
        case .magnetic:
            return pick(variant, [
                "They carry the kind of certainty you tend to test",
                "Their presence pulls focus without asking you to chase it",
                "They create a charge you want to understand slowly"
            ])
        case .intense:
            return pick(variant, [
                "They move directly where you usually hesitate",
                "They expose what you usually keep negotiable",
                "They make your usual timing harder to hide behind"
            ])
        }
    }

    private static func defaultHeadline(
        for profile: DeckProfile,
        viewer: UserProfile? = nil,
        lens: ConnectFilter?
    ) -> String {
        if let lensHeadline = lensHeadline(
            for: profile,
            viewer: viewer,
            lens: lens,
            framing: .observation,
            variant: profile.name.count
        ) {
            return lensHeadline
        }

        switch profile.matchStyle {
        case .harmonious:
            return lens == .similar
                ? "They hear what the simple version leaves out"
                : "They make directness feel less expensive"
        case .mirrored:
            return "They notice what you usually keep hidden"
        case .growth:
            return "They bring out the sentence you did not plan"
        case .magnetic:
            return "They stay in your mind afterward"
        case .intense:
            return "They make the prepared version stop working"
        }
    }

    private static func pick(_ variant: Int, _ lines: [String]) -> String {
        guard !lines.isEmpty else { return "" }
        return lines[abs(variant) % lines.count]
    }
}

private struct ReadSomeoneConnectPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Read Someone")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)

            Text("Birthday lookup is moving into Connect. For this PR, saved people and discovery now live here without changing the existing data model.")
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(ZD.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Read Someone")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let store = AppStore()
    store.onboardingComplete = true
    store.currentUser = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 622684800),
        westernSignRaw: WesternZodiac.libra.rawValue,
        chineseSignRaw: ChineseZodiac.snake.rawValue,
        archetypeId: "libra-snake"
    )

    return LegacyConnectConceptView()
        .environmentObject(store)
        .modelContainer(for: [
            UserProfile.self,
            ConnectUserProfile.self,
            SavedMatch.self,
            ConnectDeckEntry.self
        ], inMemory: true)
}
