import SwiftUI
import SwiftData
import UIKit

private enum LensFocusState: Equatable {
    case concealed
    case pressing
    case exploring
}

private struct TodayLensPreviewBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var accountOwnership: AccountOwnershipController
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \SavedDailyReading.createdAt, order: .reverse) private var savedDailyReadings: [SavedDailyReading]
    @Query(sort: \StreakDay.date, order: .reverse) private var completedDailyReadDays: [StreakDay]

    @State private var appeared = false
    @State private var isOpeningDailyRitual = false
    @State private var isDailyReadExpanded = false
    @State private var isDailyReadReplayConcealed = false
    @State private var showMilestoneBanner = false
    @State private var milestoneMessage = ""
    @State private var hasSyncedPersistedRevealState = false
    @State private var isDailyReadDeeperExpanded = false
    @State private var showBirthdayLookup = false
    @State private var selectedSavedPerson: SavedLookupPerson? = nil
    @State private var savedPeople: [SavedLookupPerson] = []
    @State private var selectedDetailPerson: SavedLookupPerson? = nil
    @State private var dailyReadSaveMessage: String? = nil
    @State private var dailyReadSaveDetailMessage: String? = nil
    @State private var dailyReadSaveMessageToken = UUID()
    @State private var showDailyReadUnsaveConfirmation = false
    @State private var showDailyLensFeedbackReason = false
    @State private var dailyLensFeedbackReasonContext: DailyLensFeedbackContext?
    @State private var dailyReadShareItems: [Any] = []
    @State private var showDailyReadShareSheet = false
    @State private var trackedDailyReadOpenKeys: Set<String> = []
    @State private var patternMemorySummary = PatternMemoryService.shared.monthlySummary()
    @State private var patternMemoryReflection = PatternMemoryService.shared.monthlyReflection()
    @State private var showPatternMemoryDestination = false
    @State private var showPatternIntelligenceDestination = false
    @State private var patternEvolutionMoment: PatternEvolutionMoment? = nil
    @State private var yourPatternFocusToken = 0
    @State private var cachedPatternIntelligencePreview: PatternIntelligencePreview? = nil
    @State private var cachedPatternIntelligenceSourceKey = ""
    @State private var patternIntelligenceCardIsVisible = false
    @State private var didOpenPatternIntelligenceVisualQASheet = false
    @State private var todayLensFocusState: LensFocusState = .concealed
    @State private var todayLensCenterY: CGFloat = 137
    @State private var todayLensPreviewBounds: CGRect = .zero
    @State private var todayLensPressStartTime: Date?
    @StateObject private var dailyRitualViewModel = DailyRitualViewModel()
    @StateObject private var dailyLensFeedback = DailyLensFeedbackController()
    @ScaledMetric(relativeTo: .body) private var todayLensScaledActiveControlHeight: CGFloat = 124

    private var profile: HomePatternProfile {
        guard let archetype = store.currentArchetype else { return .fallback }
        return HomePatternProfile(archetype: archetype)
    }

    private var headerContext: HomeHeaderContext {
        HomeHeaderContext(
            profileID: profile.id,
            completedDailyReadCount: completedDailyReadCount,
            hasMeaningfulPatternMemoryReflection: hasMeaningfulPatternMemoryReflection
        )
    }

    private var isDailyReadComplete: Bool {
        store.ritualCompletedToday
    }

    private var patternIntelligencePreview: PatternIntelligencePreview {
        let sourceKey = patternIntelligenceSourceKey
        if cachedPatternIntelligenceSourceKey == sourceKey,
           let cachedPatternIntelligencePreview {
            return cachedPatternIntelligencePreview
        }

        return makePatternIntelligencePreview()
    }

    private var patternIntelligenceSourceKey: String {
        #if DEBUG
        if let savedCount = patternIntelligenceVisualQASavedCount {
            return "debug-fixtures:\(savedCount)"
        }
        #endif

        return savedDailyReadings.map { read in
            [
                read.id.uuidString,
                read.dateKey,
                read.themeKey ?? "",
                read.patternPrimarySignal ?? "",
                read.patternSecondarySignal ?? "",
                String(read.createdAt.timeIntervalSince1970)
            ].joined(separator: ":")
        }
        .joined(separator: "|")
    }

    private func makePatternIntelligencePreview() -> PatternIntelligencePreview {
        #if DEBUG
        if let savedCount = patternIntelligenceVisualQASavedCount {
            return PatternIntelligencePreviewBuilder.makePreview(
                from: patternIntelligenceVisualQASavedReadFixtures(count: savedCount)
            )
        }
        #endif

        return PatternIntelligencePreviewBuilder.makePreview(from: savedDailyReadings)
    }

    private var patternIntelligenceGenerationSavedReads: [SavedDailyReading] {
        #if DEBUG
        if let savedCount = patternIntelligenceVisualQASavedCount {
            return patternIntelligenceVisualQASavedReadFixtures(count: savedCount)
        }
        #endif

        return savedDailyReadings
    }

    private func refreshPatternIntelligencePreviewCache() {
        let sourceKey = patternIntelligenceSourceKey
        cachedPatternIntelligenceSourceKey = sourceKey
        cachedPatternIntelligencePreview = makePatternIntelligencePreview()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HomeAtmosphere(tint: homeAccent)

                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 26) {
                            headerBlock
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)

#if DEBUG
                            if let metadata = dailyRitualViewModel.debugFreshnessMetadata {
                                DailyLensFreshnessDiagnosticsView(metadata: metadata)
                            }
                            if DailyLensCandidateRuntimeFixture.isEditorialVoiceV2RecognitionEnabled {
                                TodaysLensEditorialVoiceV2RecognitionPreviewControls(
                                    reload: {
                                        Task { await dailyRitualViewModel.reload(for: store.currentUser) }
                                    },
                                    diagnostics: dailyRitualViewModel
                                        .debugEditorialVoiceV2RecognitionDiagnostics
                                )
                            } else if DailyLensCandidateRuntimeFixture.isEditorialVoiceV21Amendment1Enabled {
                                TodaysLensEditorialVoiceV21Amendment1PreviewControls(
                                    reload: {
                                        Task { await dailyRitualViewModel.reload(for: store.currentUser) }
                                    },
                                    diagnostics: dailyRitualViewModel.debugEditorialVoiceV21Diagnostics
                                )
                            } else if DailyLensCandidateRuntimeFixture.isSpokenVoiceV1Enabled {
                                TodayLensSpokenVoiceV1FixtureControls(
                                    reload: {
                                        Task { await dailyRitualViewModel.reload(for: store.currentUser) }
                                    },
                                    diagnostics: dailyRitualViewModel.debugLensRoutingDiagnostics
                                )
                            } else if DailyLensCandidateRuntimeFixture.isFrozenV5Enabled {
                                DailyLensFrozenV5FixtureControls {
                                    Task { await dailyRitualViewModel.reload(for: store.currentUser) }
                                }
                            }
#endif

                            inlineDailyReadSection
                                .id("home-daily-read")
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)

                            identityPathSection
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 18)

                            connectEntrySection
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 22)

                        }
                        .padding(.top, 30)
                        .padding(.horizontal, ZD.Spacing.l)
                        .padding(.bottom, ZD.Spacing.m)
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        Color.clear
                            .frame(height: ZD.Spacing.m)
                            .accessibilityHidden(true)
                    }
                    .scrollDisabled(todayLensFocusState == .exploring)
                    .onChange(of: store.homeDailyReadFocusToken) { _, _ in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                scrollProxy.scrollTo("home-daily-read", anchor: .top)
                            }
                        }
                    }
                    .onChange(of: yourPatternFocusToken) { _, _ in
                        guard !patternIntelligenceCardIsVisible else { return }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                            withAnimation(.easeInOut(duration: reduceMotion ? 0.18 : 0.48)) {
                                scrollProxy.scrollTo("home-your-pattern", anchor: .center)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedDetailPerson) { person in
                PeopleDetailView(person: person)
            }
            .sheet(isPresented: $showBirthdayLookup) {
                BirthdayLookupSheet(
                    selectedPerson: selectedSavedPerson,
                    onSave: loadSavedPeople
                )
                .onDisappear {
                    selectedSavedPerson = nil
                }
            }
            .sheet(isPresented: $showDailyReadShareSheet) {
                ActivityShareSheet(activityItems: dailyReadShareItems)
            }
            .sheet(isPresented: $showPatternIntelligenceDestination) {
                PatternIntelligencePlaceholderView(
                    savedLensCount: patternIntelligencePreview.savedCount,
                    preview: patternIntelligencePreview,
                    savedReads: patternIntelligenceGenerationSavedReads,
                    savedLensSourceKey: patternIntelligenceSourceKey,
                    profileID: store.currentUser?.archetypeId ?? profile.id
                )
                    .presentationDetents([.height(620)])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showPatternMemoryDestination) {
                let patternMemorySheetHeight: CGFloat = store.hasAccess(to: .patternArchive) ? 700 : 620

                PatternMemoryHomeDestinationView(
                    summary: patternMemorySummary,
                    reflection: patternMemoryReflection,
                    hasAccess: store.hasAccess(to: .patternArchive)
                )
                .environmentObject(store)
                .presentationDetents([.height(patternMemorySheetHeight)])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
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

                loadSavedPeople()
                refreshPatternMemory()
                refreshPatternIntelligencePreviewCache()

                #if DEBUG
                openPatternIntelligenceVisualQASheetIfNeeded()
                #endif
            }
            .onChange(of: patternIntelligenceSourceKey) { _, _ in
                refreshPatternIntelligencePreviewCache()
            }
            .onChange(of: store.todayRevealed) { _, isRevealed in
                syncDailyRevealState(isRevealed: isRevealed)
            }
            .onChange(of: store.dailyReadResetToken) { _, _ in
                isOpeningDailyRitual = false
                isDailyReadExpanded = false
                isDailyReadReplayConcealed = false
                isDailyReadDeeperExpanded = false
                hasSyncedPersistedRevealState = false
                syncPersistedDailyRevealStateIfNeeded()
            }
            .task(id: dailyRitualViewModel.requestKey(for: store.currentUser)) {
                isDailyReadDeeperExpanded = false
                await dailyRitualViewModel.load(for: store.currentUser)
            }
            .onChange(of: dailyRitualViewModel.phase) { _, phase in
                if case .loaded = phase {
                    isDailyReadDeeperExpanded = false
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
                    Text("Read Someone")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Enter a birthday and see their perspective more clearly")
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
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(ZD.Color.card.opacity(0.62))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.13), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func savedPersonRow(_ person: SavedLookupPerson) -> some View {
        Button {
            feedbackSoft()
            selectedDetailPerson = person
        } label: {
            savedPersonRowContent(person)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                feedbackSoft()
                deleteSavedPerson(person)
            } label: {
                Label("Delete", systemImage: "trash")
            }
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

    private var inlineDailyReadSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Lens")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .tracking(2.1)
                        .foregroundStyle(ZD.Color.accent.opacity(0.86))

                    Group {
#if DEBUG || BETA
                        Text(betaLensStatusMessage)
#else
                        Text(
                            dailyRitualViewModel.resolvedLensContent?.isReadyForDisplay == true
                                ? "Today’s horoscope is ready."
                                : "Your personal Lens will appear here."
                        )
#endif
                    }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            if isDailyReadRevealed {
                dailyReadRevealedBody
            } else {
                todayLensRevealRitual
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.72),
                            ZD.Color.cardAlt.opacity(0.48),
                            ZD.Color.card.opacity(0.60)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(dailyReadCardAtmosphere)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ZD.Color.accent.opacity(0.30),
                                    ZD.Color.border.opacity(0.14),
                                    ZD.Color.accent.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: ZD.Color.shadow.opacity(0.28), radius: 18, x: 0, y: 12)
        .shadow(color: ZD.Color.accent.opacity(0.05), radius: 20, x: 0, y: 6)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: isDailyReadExpanded)
    }

    private var dailyReadHeroTitle: some View {
        Text(dailyReadTitle)
            .font(.system(size: 32, weight: .bold, design: .serif))
            .foregroundStyle(ZD.Color.textPrimary)
            .lineSpacing(1)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var patternIntelligencePreviewCard: some View {
        let preview = patternIntelligencePreview

        return Button {
            // TODO: Add subscription entitlement check before opening the full Pattern Intelligence experience.
            // TODO: Add paywall gating here when Pattern Intelligence becomes a premium destination.
            showPatternIntelligenceDestination = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PATTERN INTELLIGENCE")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.8)
                            .foregroundStyle(ZD.Color.accent.opacity(0.86))

                        Text(preview.sentence)
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let supportingLine = preview.supportingLine {
                            Text(supportingLine)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(ZD.Color.textSecondary.opacity(0.78))
                                .lineLimit(3)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .layoutPriority(1)

                    Spacer(minLength: 10)

                    patternIntelligenceCountBadge(savedCount: preview.savedCount)
                }

                YourPatternIrisView(
                    preview: preview,
                    evolutionID: patternEvolutionMoment?.id,
                    evolutionStatusLabel: patternEvolutionMoment?.statusLabel,
                    isIdleActive: patternIntelligenceCardIsVisible
                )
                    .frame(maxWidth: .infinity)
                    .frame(height: 154)

                if let nextUnlockHint = patternIntelligenceNextUnlockHint(savedCount: preview.savedCount) {
                    Text(nextUnlockHint)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.62))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                        .transition(.opacity)
                }

                if !preview.discoveries.isEmpty {
                    patternIntelligenceSignalChips(preview.discoveries)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.70),
                                ZD.Color.forest.opacity(0.78),
                                ZD.Color.card.opacity(0.56)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(patternIntelligenceCardAtmosphere)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ZD.Color.premium.opacity(0.24),
                                        ZD.Color.success.opacity(0.13),
                                        ZD.Color.border.opacity(0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: ZD.Color.shadow.opacity(0.22), radius: 16, x: 0, y: 10)
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .background(PatternIntelligenceVisibilityReader())
        .onPreferenceChange(PatternIntelligenceCardVisibilityKey.self) { isVisible in
            guard patternIntelligenceCardIsVisible != isVisible else { return }
            patternIntelligenceCardIsVisible = isVisible
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pattern Intelligence. \(preview.sentence). Opens Pattern Intelligence.")
    }
    private var patternIntelligenceCardAtmosphere: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .stroke(ZD.Color.success.opacity(0.055), lineWidth: 1)
                    .frame(width: width * 0.86, height: width * 0.34)
                    .rotationEffect(.degrees(-10))
                    .position(x: width * 0.76, y: height * 0.22)

                Ellipse()
                    .stroke(ZD.Color.premium.opacity(0.065), lineWidth: 1)
                    .frame(width: width * 0.64, height: width * 0.25)
                    .rotationEffect(.degrees(18))
                    .position(x: width * 0.24, y: height * 0.90)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .allowsHitTesting(false)
    }

    private func patternIntelligenceCountBadge(savedCount: Int) -> some View {
        let title = patternIntelligenceBadgeTitle(savedCount: savedCount)
        let caption = "\(savedCount) \(savedCount == 1 ? "Lens" : "Lenses")"

        return VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11.5, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .foregroundStyle(ZD.Color.textPrimary)

            Text(caption)
                .font(.system(size: 8.5, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .foregroundStyle(ZD.Color.muted)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(width: 96)
        .background(
            Capsule(style: .continuous)
                .fill(ZD.Color.card.opacity(0.54))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(ZD.Color.premium.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func patternIntelligenceBadgeTitle(savedCount: Int) -> String {
        switch savedCount {
        case 90...:
            return "Cosmic Weather"
        case 30...:
            return "Monthly Reflection"
        case 7...:
            return "Unlocked"
        case 5...:
            return "Dots Aligning"
        case 3...:
            return "Pattern Emerging"
        case 1...:
            return "First Observation"
        default:
            return "Start Saving"
        }
    }

    private func patternIntelligenceNextUnlockHint(savedCount: Int) -> String? {
        guard savedCount > 0,
              let nextMilestone = PatternIntelligenceMilestone.next(after: savedCount),
              nextMilestone.count - savedCount == 1 else {
            return nil
        }

        if nextMilestone.count == 3 {
            return "1 more saved Lens unlocks Pattern Intelligence Preview."
        }

        if nextMilestone.count == 7 {
            return "1 more saved Lens unlocks Pattern Intelligence."
        }

        return "1 more saved Lens unlocks \(nextMilestone.title)."
    }

    private func patternIntelligenceSignalChips(_ discoveries: [PatternIntelligenceSignalDiscovery]) -> some View {
        // TODO: Let tapping the featured signal reveal the supporting signal set and why it surfaced.
        HStack {
            Spacer(minLength: 0)

            if let discovery = discoveries.first {
                HStack(spacing: 6) {
                    Circle()
                        .fill(patternIntelligenceSignalTint(0).opacity(0.82))
                        .frame(width: 5, height: 5)
                        .shadow(color: patternIntelligenceSignalTint(0).opacity(0.30), radius: 5)

                    Text(discovery.label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                        .allowsTightening(true)
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.90))
                }
                .frame(minHeight: 32)
                .padding(.horizontal, 13)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.045))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(patternIntelligenceSignalTint(0).opacity(0.18), lineWidth: 1)
                        )
                )
            }

            Spacer(minLength: 0)
        }
    }

    private func patternIntelligenceSignalTint(_ index: Int) -> Color {
        switch index {
        case 0:
            return ZD.Color.premium
        case 1:
            return ZD.Color.success
        default:
            return ZD.Color.accent
        }
    }

    private var todayLensRevealRitual: some View {
        GeometryReader { proxy in
            let activeWidth = todayLensActiveControlWidth(availableWidth: proxy.size.width)
            let controlWidth = todayLensIsExploring ? activeWidth : todayLensRestingControlWidth
            let controlHeight = todayLensIsExploring ? todayLensActiveControlHeight : todayLensRestingControlHeight

            ZStack {
                todayLensOrbitField(progress: todayLensFocusState == .exploring ? 1 : 0)

                todayLensPreviewCanvas(width: proxy.size.width)
                    // Give the blur room to spread beyond its source bounds so
                    // the concealed copy does not expose a hard raster edge.
                    .padding(18)
                    .blur(radius: reduceMotion ? 0 : 7.5, opaque: false)
                    .padding(-18)
                    .opacity(reduceMotion ? 0.88 : 0.40)
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 0.10),
                                .init(color: .white, location: 0.97),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 0.08),
                                .init(color: .white, location: 0.97),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .allowsHitTesting(false)

                todayLensFocusedPreview(width: controlWidth, height: controlHeight)

                if reduceMotion {
                    todayLensGlassControl(width: todayLensRestingControlWidth, height: todayLensRestingControlHeight)
                        .position(x: proxy.size.width * 0.50, y: todayLensRestingCenterY)
                        .onTapGesture {
                            revealDailyReadInline()
                        }
                } else {
                    todayLensGlassControl(width: controlWidth, height: controlHeight)
                        .position(x: proxy.size.width * 0.50, y: todayLensCenterY)

                    if todayLensFocusState != .exploring {
                        Text("Hold, explore, release to unveil")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                            .position(x: proxy.size.width * 0.50, y: todayLensRestingCenterY + 52)
                            .allowsHitTesting(false)
                    }

                    TodayLensFocusTouchSurface(
                        restingControlSize: CGSize(
                            width: todayLensRestingControlWidth,
                            height: todayLensRestingControlHeight
                        ),
                        restingCenterY: todayLensRestingCenterY,
                        onTouchDown: todayLensTouchDown,
                        onHoldActivated: todayLensHoldActivated,
                        onChanged: todayLensMoveMagnifier,
                        onEnded: todayLensTouchEnded,
                        onCancelled: todayLensTouchCancelled
                    )
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .coordinateSpace(name: "today-lens-reveal")
            .onPreferenceChange(TodayLensPreviewBoundsPreferenceKey.self) { bounds in
                guard bounds != .zero, bounds != todayLensPreviewBounds else { return }
                todayLensPreviewBounds = bounds
            }
        }
        .frame(height: reduceMotion ? 220 : todayLensRevealCanvasHeight)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            reduceMotion
                ? "Daily Lens. Tap to reveal today’s lens."
                : "Daily Lens. Tap and hold to explore, then release to unveil today’s lens."
        )
        .accessibilityAction(named: "Reveal Daily Lens") {
            revealDailyReadInline()
        }
    }

    private var todayLensRestingCenterY: CGFloat { 137 }
    private var todayLensIsExploring: Bool { todayLensFocusState == .exploring }
    private var todayLensRestingControlHeight: CGFloat { 66 }
    private var todayLensRestingControlWidth: CGFloat { 188 }
    private var todayLensActiveControlHeight: CGFloat {
        min(max(124, todayLensScaledActiveControlHeight), 210)
    }
    private var todayLensRevealCanvasHeight: CGFloat {
        max(274, todayLensPreviewBounds.maxY + 24)
    }
    private var todayLensRevealVerticalInset: CGFloat { 0 }
    private var todayLensGlassShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: todayLensIsExploring
                ? 18
                : todayLensRestingControlHeight / 2,
            style: .continuous
        )
    }

    private func todayLensActiveControlWidth(availableWidth: CGFloat) -> CGFloat {
        max(todayLensRestingControlWidth, availableWidth)
    }

    private var todayLensPreviewContent: some View {
        Group {
            if case .loaded(let ritual) = dailyRitualViewModel.state {
                let content = dailyRitualViewModel.lensContent(for: ritual)
                if content.isReadyForDisplay {
                    DailyLensTitleReadView(
                        content: content,
                        titleBaseSize: DailyLensRevealGeometry.titleFontSize,
                        readBaseSize: DailyLensRevealGeometry.readFontSize
                    )
                    .background {
                        GeometryReader { contentProxy in
                            Color.clear.preference(
                                key: TodayLensPreviewBoundsPreferenceKey.self,
                                value: contentProxy.frame(in: .named("today-lens-reveal"))
                            )
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(content.accessibilityLabel)
                } else {
                    todayLensUnavailablePreview
                }
            } else {
                todayLensUnavailablePreview
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Both the concealed copy and the in-lens copy render through this exact
    /// canvas. The lens changes clarity only; it never changes text scale,
    /// wrapping width, alignment, or line geometry.
    private func todayLensPreviewCanvas(width: CGFloat) -> some View {
        todayLensPreviewContent
            .frame(width: width, alignment: .topLeading)
            .offset(x: 1.5)
            .padding(.top, 14)
            .frame(minHeight: 246, alignment: .topLeading)
    }

    private var todayLensUnavailablePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Lens is ready")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
            Text("Hold to bring it into focus.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
        }
        .background {
            GeometryReader { contentProxy in
                Color.clear.preference(
                    key: TodayLensPreviewBoundsPreferenceKey.self,
                    value: contentProxy.frame(in: .named("today-lens-reveal"))
                )
            }
        }
    }

    private func todayLensFocusedPreview(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { proxy in
            todayLensPreviewCanvas(width: proxy.size.width)
                .opacity(reduceMotion ? 0 : (todayLensIsExploring ? 1 : 0))
                .mask {
                    todayLensGlassShape
                        .frame(width: width, height: height)
                        .position(x: proxy.size.width * 0.50, y: todayLensCenterY)
                }
        }
        .allowsHitTesting(false)
    }

    private func todayLensOrbitField(progress: CGFloat) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.045 + (progress * 0.045)), lineWidth: 1)
                    .frame(width: width * 1.12, height: width * 0.74)
                    .rotationEffect(.degrees(-14 + (progress * 4)))
                    .position(x: width * 0.58, y: height * 0.44)

                Ellipse()
                    .stroke(Color.white.opacity(0.028 + (progress * 0.022)), lineWidth: 1)
                    .frame(width: width * 0.86, height: width * 0.44)
                    .rotationEffect(.degrees(18 - (progress * 5)))
                    .position(x: width * 0.42, y: height * 0.44)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .allowsHitTesting(false)
    }

    private var todayLensIsPressing: Bool {
        todayLensFocusState != .concealed
    }

    private func todayLensGlassControl(width: CGFloat, height: CGFloat) -> some View {
        let progress: CGFloat = todayLensIsExploring ? 1 : 0

        return ZStack {
            if todayLensFocusState != .exploring {
                Text("Tap and hold")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(ZD.Color.textPrimary.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(width: width, height: height)
        .background {
            todayLensGlassBackground(progress: progress)
        }
        .overlay {
            todayLensPrismaticEdge(progress: progress)
        }
        .shadow(color: ZD.Color.accent.opacity(todayLensIsExploring ? 0.02 : 0.05), radius: 10, x: 0, y: 6)
        .contentShape(todayLensGlassShape)
    }

    @ViewBuilder
    private func todayLensGlassBackground(progress: CGFloat) -> some View {
        let shape = todayLensGlassShape

        if todayLensIsExploring {
            // The active lens must stay optically clear. Applying the system
            // glass backdrop here re-blurs the unblurred content layer that
            // the lens is meant to reveal. The prismatic edge above retains
            // the liquid-glass character without obscuring the words.
            shape
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.018),
                            Color.clear,
                            ZD.Color.accent.opacity(0.014)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else if #available(iOS 26.0, *) {
            shape
                .fill(Color.clear)
                .glassEffect(
                    .clear
                        .tint(Color.white.opacity(todayLensIsPressing ? 0.022 : 0.008))
                        .interactive(),
                    in: shape
                )
        } else {
            shape
                .fill(Color.white.opacity(todayLensIsPressing ? 0.012 : 0.018))
                .background(
                    shape
                        .fill(.ultraThinMaterial.opacity(todayLensIsPressing ? 0.10 : 0.22))
                )
        }
    }

    private func todayLensPrismaticEdge(progress: CGFloat) -> some View {
        ZStack {
            todayLensGlassShape
                .stroke(Color.white.opacity(todayLensIsPressing ? 0.64 : 0.38), lineWidth: todayLensIsPressing ? 1.35 : 1.05)
                .blendMode(.screen)
                .shadow(color: Color.white.opacity(todayLensIsPressing ? 0.26 : 0.04), radius: todayLensIsPressing ? 3 : 1.2, x: 0, y: 0)

            todayLensEdgeReflections(progress: progress)

            todayLensGlassShape
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(todayLensIsPressing ? 0.92 : 0.40),
                            ZD.Color.accent.opacity(todayLensIsPressing ? 0.64 + (progress * 0.10) : 0.22),
                            Color.cyan.opacity(todayLensIsPressing ? 0.54 : 0.08),
                            Color.blue.opacity(todayLensIsPressing ? 0.42 : 0.055),
                            Color.pink.opacity(todayLensIsPressing ? 0.46 : 0.07),
                            Color.white.opacity(todayLensIsPressing ? 0.72 : 0.20),
                            ZD.Color.accent.opacity(todayLensIsPressing ? 0.50 : 0.14)
                        ],
                        center: .center
                    ),
                    lineWidth: todayLensIsPressing ? 2.7 : 1
                )
                .blendMode(.screen)
                .opacity(todayLensIsPressing ? 0.96 : 0.64)
                .shadow(color: Color.cyan.opacity(todayLensIsPressing ? 0.18 : 0), radius: todayLensIsPressing ? 4.5 : 0, x: -1, y: 0)
                .shadow(color: ZD.Color.accent.opacity(todayLensIsPressing ? 0.18 : 0), radius: todayLensIsPressing ? 4.5 : 0, x: 1, y: 0)

            todayLensGlassShape
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(todayLensIsPressing ? 0.62 : 0.14),
                            Color.clear,
                            ZD.Color.accent.opacity(todayLensIsPressing ? 0.34 : 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: todayLensIsPressing ? 3.2 : 1.2
                )
                .blur(radius: todayLensIsPressing ? 0.55 : 0.35)
                .blendMode(.screen)
                .opacity(todayLensIsPressing ? 0.58 : 0.24)

            todayLensGlassShape
                .stroke(Color.white.opacity(todayLensIsPressing ? 0.18 : 0.05), lineWidth: todayLensIsPressing ? 5 : 2)
                .blur(radius: todayLensIsPressing ? 2 : 1)
                .blendMode(.screen)

            todayLensGlassShape
                .stroke(Color.black.opacity(todayLensIsPressing ? 0.30 : 0.08), lineWidth: todayLensIsPressing ? 1.1 : 0.6)
                .blur(radius: todayLensIsPressing ? 0.45 : 0.2)
                .offset(y: todayLensIsPressing ? 1.1 : 0.5)
                .blendMode(.multiply)
        }
    }

    private func todayLensEdgeReflections(progress: CGFloat) -> some View {
        GeometryReader { _ in
            let activeOpacity = todayLensIsPressing ? 1.0 : 0.24

            ZStack {
                todayLensGlassShape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.92 * activeOpacity),
                                Color.cyan.opacity(0.34 * activeOpacity),
                                Color.clear,
                                Color.clear,
                                ZD.Color.accent.opacity(0.30 * activeOpacity),
                                Color.white.opacity(0.72 * activeOpacity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: todayLensIsPressing ? 2.2 : 1.1
                    )
                    .blur(radius: todayLensIsPressing ? 0.18 : 0.12)
                    .blendMode(.screen)

                todayLensGlassShape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.16 * activeOpacity),
                                Color.clear,
                                Color.cyan.opacity(0.18 * activeOpacity)
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ),
                        lineWidth: todayLensIsPressing ? 1.4 : 0.75
                    )
                    .blur(radius: todayLensIsPressing ? 0.24 : 0.14)
                    .blendMode(.screen)
            }
            .clipShape(todayLensGlassShape)
        }
        .allowsHitTesting(false)
    }

    private func todayLensTouchDown() {
        guard !reduceMotion, !isOpeningDailyRitual else { return }
        todayLensPressStartTime = Date()
        todayLensFocusState = .pressing
        todayLensCenterY = todayLensRestingCenterY
    }

    private func todayLensHoldActivated() {
        guard todayLensFocusState == .pressing, !isOpeningDailyRitual else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            todayLensFocusState = .exploring
        }
        feedbackSoft()
    }

    private func todayLensMoveMagnifier(_ locationY: CGFloat) {
        guard todayLensFocusState == .exploring, !isOpeningDailyRitual else { return }
        let renderedBounds = todayLensPreviewBounds == .zero
            ? CGRect(x: 0, y: todayLensRevealVerticalInset, width: 0, height: todayLensRevealCanvasHeight - (todayLensRevealVerticalInset * 2))
            : todayLensPreviewBounds
        let range = DailyLensRevealGeometry.centerRange(
            cardHeight: todayLensRevealCanvasHeight,
            contentBounds: renderedBounds,
            viewfinderHeight: todayLensActiveControlHeight,
            cardInset: todayLensRevealVerticalInset
        )
#if DEBUG
        DailyLensRevealGeometry.assertReachability(
            range: range,
            contentBounds: renderedBounds,
            viewfinderHeight: todayLensActiveControlHeight
        )
#endif
        var transaction = Transaction()
        transaction.animation = nil
        withTransaction(transaction) {
            todayLensCenterY = min(max(locationY, range.lowerBound), range.upperBound)
        }
    }

    private func todayLensTouchEnded() {
        let shouldUnveil = todayLensFocusState == .exploring
        todayLensResetFocus()

        if shouldUnveil {
            revealDailyReadInline()
        }
    }

    private func todayLensTouchCancelled() {
        todayLensResetFocus()
    }

    private func todayLensResetFocus() {
        withAnimation(.easeOut(duration: 0.18)) {
            todayLensFocusState = .concealed
            todayLensCenterY = todayLensRestingCenterY
            todayLensPressStartTime = nil
        }
    }

    private var dailyReadCardAtmosphere: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.075))
                    .frame(width: width * 0.58, height: width * 0.58)
                    .blur(radius: 34)
                    .position(x: width * 0.88, y: height * 0.04)

                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.08), lineWidth: 1)
                    .frame(width: width * 1.05, height: width * 0.72)
                    .rotationEffect(.degrees(-13))
                    .position(x: width * 0.70, y: height * 0.12)

                Ellipse()
                    .stroke(Color.white.opacity(0.045), lineWidth: 1)
                    .frame(width: width * 0.78, height: width * 0.46)
                    .rotationEffect(.degrees(18))
                    .position(x: width * 0.42, y: height * 0.20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var dailyReadRevealedBody: some View {
        switch dailyRitualViewModel.state {
        case .loaded(let ritual):
            dailyReadEditorialContent(ritual)
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .tint(ZD.Color.accent)

                Text("Preparing today’s Lens…")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
            }
            .padding(.vertical, 10)

        case .empty:
            Text("Daily Lens is still being prepared")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

        case .failed(let message):
            VStack(alignment: .leading, spacing: 12) {
#if DEBUG || BETA
                Text(message)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
#else
                Text("Daily Lens is still being prepared")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
#endif

                Button {
                    feedbackSoft()
                    Task {
                        await dailyRitualViewModel.reload(for: store.currentUser)
                    }
                } label: {
                    Text("Try again")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ZD.Color.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }

#if DEBUG || BETA
    private var betaLensStatusMessage: String {
        if dailyRitualViewModel.resolvedLensContent?.isReadyForDisplay == true {
            return "Today’s horoscope is ready."
        }
        if case .failed(let message) = dailyRitualViewModel.state {
            return message
        }
        return "Your personal Lens will appear here."
    }
#endif

    private var completedDailyReadCount: Int {
        Set(completedDailyReadDays.filter(\.didReveal).map { $0.day }).count
    }

    private var hasMeaningfulPatternMemoryReflection: Bool {
        patternMemorySummary.topSavedReadThemes.contains { $0.count > 1 }
            || patternMemorySummary.repeatedSavedIdentities.contains { $0.count > 1 }
            || !patternMemorySummary.revisitedSavedReadThemes.isEmpty
            || !patternMemorySummary.threadStartedIdentities.isEmpty
            || patternMemorySummary.lensCounts.values.contains { $0 >= 3 }
    }

    @ViewBuilder
    private func dailyReadEditorialContent(_ ritual: DailyRitualResponse) -> some View {
        if ritual.isUnavailableDailyRead {
            Text(ritual.unavailableMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                let content = dailyLensContent(for: ritual)
                if content.isReadyForDisplay {
                    DailyLensTitleReadView(
                        content: content,
                        titleBaseSize: DailyLensRevealGeometry.titleFontSize,
                        readBaseSize: DailyLensRevealGeometry.readFontSize
                    )
                } else {
                    Text("Daily Lens is still being prepared")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if ritual.hasRealDailyReadContent {
                    dailyReadActionRow(ritual)
                        .padding(.top, isDailyReadComplete ? 14 : 0)
                }
            }
            .onAppear {
                trackDailyReadOpened(ritual)
            }
        }
    }

    private func dailyLensFeedbackControl(context: DailyLensFeedbackContext) -> some View {
        VStack(alignment: .trailing, spacing: 9) {
            Text("Did this resonate?")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))

            HStack(spacing: 8) {
                dailyLensFeedbackButton(.up, context: context)
                dailyLensFeedbackButton(.down, context: context)

                if dailyLensFeedback.hasRetryableSubmissionError {
                    Button("Retry") {
                        dailyLensFeedback.retry(
                            context: context,
                            ownership: accountOwnership
                        )
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                    .buttonStyle(.plain)
                    .accessibilityLabel("Retry")
                    .accessibilityHint("Retries saving your response.")
                }
            }

            if let confirmation = dailyLensFeedback.confirmationMessage {
                Text(confirmation)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
                    .fixedSize(horizontal: false, vertical: true)
                    .task(id: confirmation) {
                        try? await Task.sleep(for: .seconds(2.4))
                        dailyLensFeedback.dismissConfirmation(confirmation)
                    }
                    .accessibilityLabel(confirmation)
            }
        }
        .padding(.top, 3)
    }

    private func dailyLensFeedbackButton(
        _ response: DailyLensFeedbackResponse,
        context: DailyLensFeedbackContext
    ) -> some View {
        let isSelected = dailyLensFeedback.selected == response
        let label = response == .up ? "Thumbs up" : "Thumbs down"
        let symbol = response == .up ? "hand.thumbsup.fill" : "hand.thumbsdown.fill"

        return Button {
            feedbackSoft()
            if response == .down {
                dailyLensFeedbackReasonContext = context
                showDailyLensFeedbackReason = true
            }
            dailyLensFeedback.submit(
                response,
                confirmation: response == .up ? "Glad it resonated." : nil,
                context: context,
                ownership: accountOwnership
            )
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? ZD.Color.bg : ZD.Color.textSecondary)
                .frame(width: 44, height: 44)
                .background(
                    Capsule()
                        .fill(isSelected ? ZD.Color.accent : ZD.Color.card.opacity(0.72))
                )
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.border.opacity(isSelected ? 0 : 0.26), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(
            response == .down
                ? "Records that this Lens missed the mark and lets you share what felt off."
                : "Records that this Lens resonated."
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func dailyReadSixFieldFallback(_ ritual: DailyRitualResponse) -> some View {
        Text(ritual.title)
            .font(.system(size: 32, weight: .bold, design: .serif))
            .foregroundStyle(ZD.Color.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
        if let intro = distinctDailyReadValue(ritual.intro, comparedTo: [ritual.validPullQuote, ritual.validDeeperRead, ritual.validWatchFor, ritual.validMove]) {
            Text(intro)
                .foregroundStyle(ZD.Color.textSecondary)
        }
        if let pullQuote = distinctDailyReadValue(ritual.validPullQuote, comparedTo: [ritual.intro]) {
            Text(pullQuote)
        }
        if let deeperRead = distinctDailyReadValue(ritual.validDeeperRead, comparedTo: [ritual.intro, ritual.validPullQuote]) {
            dailyReadDeeperDisclosure(deeperRead, ritual: ritual)
        }
        if let watchFor = distinctDailyReadValue(ritual.validWatchFor, comparedTo: [ritual.intro, ritual.validPullQuote, ritual.validDeeperRead, ritual.validMove]) {
            compactDailyReadField(title: "Watch", text: watchFor, titleSize: 11, bodySize: 15)
        }
        if let move = distinctDailyReadValue(ritual.validMove, comparedTo: [ritual.intro, ritual.validPullQuote, ritual.validDeeperRead, ritual.validWatchFor]) {
            compactDailyReadField(title: "Move", text: move, titleSize: 11, bodySize: 16)
        }
    }

    private func dailyLensContent(for ritual: DailyRitualResponse) -> DailyLensContent {
        dailyRitualViewModel.lensContent(for: ritual)
    }

    private func compactDailyReadField(title: String, text: String, titleSize: CGFloat, bodySize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.muted)

            Text(text)
                .font(.system(size: bodySize, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func dailyReadDeeperDisclosure(_ text: String, ritual: DailyRitualResponse) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Button {
                feedbackSoft()
                let willExpand = !isDailyReadDeeperExpanded
                withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                    isDailyReadDeeperExpanded.toggle()
                }
                if willExpand {
                    trackDailyReadEvent(.dailyReadExpanded, ritual: ritual, isSaved: dailyReadIsSaved(ritual))
                }
            } label: {
                HStack(spacing: 7) {
                    Text(isDailyReadDeeperExpanded ? "Hide horoscope detail" : "Behind the Lens")
                        .font(.system(size: 13, weight: .bold, design: .rounded))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .rotationEffect(.degrees(isDailyReadDeeperExpanded ? 180 : 0))
                }
                .foregroundStyle(ZD.Color.accent)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isDailyReadDeeperExpanded ? "Hide horoscope detail" : "Behind the Lens")

            if isDailyReadDeeperExpanded {
                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private var inlineDailyReadCompletionButton: some View {
        if isDailyReadComplete {
            HStack(spacing: 9) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(ZD.Color.accent)

                Text("Saved for today")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
            }
            .padding(.vertical, 4)
        } else {
            Button {
                feedbackSoft()
                store.completeDailyRitual(context: context, reward: 5)
                feedbackReveal()
            } label: {
                Text("Mark as read")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ZD.Color.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private func dailyReadActionRow(_ ritual: DailyRitualResponse) -> some View {
        let isSaved = dailyReadIsSaved(ritual)

        return VStack(alignment: .leading, spacing: 12) {
            if let momentumMoment = store.dailyReadMomentumMoment,
               momentumMoment.dateKey == DailyReadingStore.dateKey() {
                Text(momentumMoment.message)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                dailyReadActionButton(
                    title: isSaved ? "Saved" : "Save",
                    icon: isSaved ? "checkmark.circle.fill" : "bookmark.fill",
                    isPrimary: !isSaved
                ) {
                    if isSaved {
                        showDailyReadUnsaveConfirmation = true
                    } else {
                        saveDailyRead(ritual)
                    }
                }

                dailyReadActionButton(
                    title: "Share",
                    icon: "square.and.arrow.up",
                    isPrimary: isSaved
                ) {
                    shareDailyRead(ritual)
                }
            }

            if isDailyReadRevealed {
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        replayDailyReadReveal()
                    } label: {
                        Label("Replay reveal", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Replays the hold-to-focus reveal without changing points, streak, or saved status.")

                    Spacer(minLength: 12)

                    let content = dailyLensContent(for: ritual)
                    if let feedbackContext = DailyLensFeedbackContext(content: content) {
                        dailyLensFeedbackControl(context: feedbackContext)
                            .task(id: feedbackContext.key) {
                                await dailyLensFeedback.restore(
                                    context: feedbackContext,
                                    ownership: accountOwnership
                                )
                            }
                    }
                }
            }

            if let dailyReadSaveMessage {
                dailyReadSaveConfirmation(dailyReadSaveMessage)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            if isDailyReadRevealed {
                trackHomeCompletedStateSeen()
            }
        }
        .confirmationDialog(
            "Remove this Lens from Profile?",
            isPresented: $showDailyReadUnsaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove from Profile", role: .destructive) {
                unsaveDailyRead(ritual)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The Lens will remain completed and can still be replayed today.")
        }
        .sheet(isPresented: $showDailyLensFeedbackReason, onDismiss: {
            dailyLensFeedback.negativeReasonSheetDismissedWithoutSelection()
            dailyLensFeedbackReasonContext = nil
        }) {
            dailyLensFeedbackReasonSheet
        }
    }

    @ViewBuilder
    private var dailyLensFeedbackReasonSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("What felt off?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text("Pick one if you want to help shape future readings.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(DailyLensFeedbackReason.allCases, id: \.self) { reason in
                    Button {
                        guard let feedbackContext = dailyLensFeedbackReasonContext else { return }
                        feedbackSoft()
                        dailyLensFeedback.submit(
                            .down,
                            negativeReason: reason,
                            confirmation: "Thanks — this helps improve future readings.",
                            context: feedbackContext,
                            ownership: accountOwnership
                        )
                        showDailyLensFeedbackReason = false
                    } label: {
                        HStack {
                            Text(reason.title)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(ZD.Color.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(ZD.Color.cardAlt.opacity(0.7))
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(reason.title)
                    .accessibilityHint("Saves this as the reason the Lens did not resonate.")
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Lens feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") {
                        showDailyLensFeedbackReason = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func dailyReadSaveConfirmation(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.accent.opacity(0.92))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.textPrimary.opacity(0.86))

                if let dailyReadSaveDetailMessage {
                    Text(dailyReadSaveDetailMessage)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.46))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func dailyReadActionButton(
        title: String,
        icon: String,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))

                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(isPrimary ? Color.black : ZD.Color.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(isPrimary ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.cardAlt.opacity(0.62)))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(isPrimary ? Color.clear : ZD.Color.border.opacity(0.22), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func dailyReadIsSaved(_ ritual: DailyRitualResponse) -> Bool {
        savedDailyReading(for: ritual) != nil
    }

    private func saveDailyRead(_ ritual: DailyRitualResponse) {
        feedbackSoft()

        if savedDailyReading(for: ritual) != nil {
            dailyReadSaveMessage = "Already saved in Profile."
            dailyReadSaveDetailMessage = nil
            clearDailyReadSaveMessageSoon()
            return
        }

        guard let user = store.currentUser,
              let archetype = store.currentArchetype else {
            dailyReadSaveMessage = "Finish onboarding before saving reads."
            dailyReadSaveDetailMessage = nil
            clearDailyReadSaveMessageSoon()
            return
        }

        let content = dailyLensContent(for: ritual)
        guard content.isReadyForDisplay else {
            dailyReadSaveMessage = "Daily Lens is still being prepared."
            dailyReadSaveDetailMessage = nil
            clearDailyReadSaveMessageSoon()
            return
        }

        let saved = SavedDailyReading(
            content: content,
            dateKey: dailyReadDateKey(for: ritual),
            archetypeId: archetype.id,
            westernSignRaw: user.westernSign.rawValue,
            chineseSignRaw: user.chineseSign.rawValue,
            streakContext: store.streak,
            patternIntelligence: ritual.patternIntelligence,
            createdAt: Date()
        )

        context.insert(saved)

        do {
            try context.save()
            store.completeDailyRitual(context: context, reward: 5)
            let savedCountAfterSave = savedDailyReadCountAfterSaving(ritual, archetypeId: archetype.id)
            dailyReadSaveMessage = nil
            dailyReadSaveDetailMessage = nil
            triggerPatternEvolutionMoment(savedCount: savedCountAfterSave)
            trackDailyReadEvent(.dailyReadSaved, ritual: ritual, entityID: saved.id.uuidString, isSaved: true)
            refreshPatternMemory()
            feedbackReveal()
        } catch {
            dailyReadSaveMessage = "Could not save right now."
            dailyReadSaveDetailMessage = nil
        }

        clearDailyReadSaveMessageSoon()
    }

    private func savedDailyReadCountAfterSaving(_ ritual: DailyRitualResponse, archetypeId: String) -> Int {
        let dateKey = dailyReadDateKey(for: ritual)
        let otherSavedReads = savedDailyReadings.filter { read in
            !(read.dateKey == dateKey && read.archetypeId == archetypeId)
        }

        return otherSavedReads.count + 1
    }

    private func triggerPatternEvolutionMoment(savedCount: Int) {
        let moment = PatternEvolutionMoment(
            savedCount: savedCount,
            statusLabel: patternEvolutionStatusLabel(savedCount: savedCount)
        )

        withAnimation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.46, dampingFraction: 0.86)) {
            patternEvolutionMoment = moment
        }

        // TODO: At 7 saved Lenses, show "Pattern Intelligence unlocked."
        // TODO: Let the artifact bloom subtly and evolve the ring/contour structure at milestone saves.
        // TODO: Keep milestone moments quiet: no confetti, coins, XP, or loud badge mechanics.
        yourPatternFocusToken += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            guard patternEvolutionMoment?.id == moment.id else { return }

            withAnimation(.easeInOut(duration: reduceMotion ? 0.12 : 0.28)) {
                patternEvolutionMoment = nil
            }
        }
    }

    private func patternEvolutionStatusLabel(savedCount: Int) -> String {
        switch savedCount {
        case 0:
            return "New observation"
        case 1:
            return "New observation"
        case 2:
            return "Saved Lens"
        case 3...6:
            return "Growing"
        default:
            return "Recurring"
        }
    }

    private func unsaveDailyRead(_ ritual: DailyRitualResponse) {
        feedbackSoft()

        guard let savedReading = savedDailyReading(for: ritual) else {
            dailyReadSaveMessage = "Nothing saved to remove."
            dailyReadSaveDetailMessage = nil
            clearDailyReadSaveMessageSoon()
            return
        }

        context.delete(savedReading)

        do {
            try context.save()
            dailyReadSaveMessage = nil
            dailyReadSaveDetailMessage = nil
            trackDailyReadEvent(.dailyReadUnsaved, ritual: ritual, entityID: savedReading.id.uuidString, isSaved: false)
            refreshPatternMemory()
        } catch {
            dailyReadSaveMessage = "Could not remove right now."
            dailyReadSaveDetailMessage = nil
        }

        clearDailyReadSaveMessageSoon()
    }

    private func savedDailyReading(for ritual: DailyRitualResponse) -> SavedDailyReading? {
        guard let archetype = store.currentArchetype else { return nil }
        let key = dailyReadDateKey(for: ritual)
        let archetypeId = archetype.id
        let descriptor = FetchDescriptor<SavedDailyReading>(
            predicate: #Predicate { item in
                item.dateKey == key && item.archetypeId == archetypeId
            },
            sortBy: [SortDescriptor(\SavedDailyReading.createdAt, order: .forward)]
        )

        return try? context.fetch(descriptor).first
    }

    private func dailyReadDateKey(for ritual: DailyRitualResponse) -> String {
        ritual.ritualDate?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? (ritual.ritualDate ?? DailyReadingStore.dateKey())
            : DailyReadingStore.dateKey()
    }

    private func trackDailyReadOpened(_ ritual: DailyRitualResponse) {
        guard ritual.hasRealDailyReadContent else { return }
        let trackingKey = dailyReadDateKey(for: ritual)
        guard trackedDailyReadOpenKeys.insert(trackingKey).inserted else { return }
        trackDailyReadEvent(.dailyReadOpened, ritual: ritual, isSaved: dailyReadIsSaved(ritual))
    }

    private func trackHomeCompletedStateSeen() {
        let dateKey = DailyReadingStore.dateKey()
        let trackingKey = "zodian.homeCompletedStateSeen.\(dateKey)"
        guard !UserDefaults.standard.bool(forKey: trackingKey) else { return }

        UserDefaults.standard.set(true, forKey: trackingKey)
        AnalyticsService.shared.track(
            .homeCompletedStateSeen(
                dateKey: dateKey,
                identityID: store.currentUser?.archetypeId ?? "unknown"
            )
        )
    }

    private func trackDailyReadEvent(
        _ type: PatternMemoryEventType,
        ritual: DailyRitualResponse,
        entityID: String? = nil,
        isSaved: Bool?
    ) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent(
                type: type,
                entityID: entityID,
                dateKey: dailyReadDateKey(for: ritual),
                identity: currentPatternMemoryIdentity,
                title: ritual.title,
                theme: ritual.title,
                focus: ritual.validDeeperRead ?? ritual.intro,
                isSaved: isSaved
            )
        )
    }

    private var currentPatternMemoryIdentity: String? {
        store.currentUser.map { "\($0.westernSign.displayName) × \($0.chineseSign.displayName)" }
    }

    @MainActor
    private func dailyReadShareItems(for ritual: DailyRitualResponse) -> [Any] {
        let resolvedContent = dailyLensContent(for: ritual)
        if resolvedContent.isReadyForDisplay {
            let content = DailyLensSharePayload(
                content: resolvedContent,
                signLine: currentPatternMemoryIdentity ?? "Daily Lens"
            )
            let caption = formattedDailyReadShareCaption(ritual, content: resolvedContent)
            guard let image = DailyLensShareRenderer.renderImage(for: content) else {
                return [content.text]
            }
            return [image, caption]
        }

        let content = DailyReadShareContent(
            signLine: currentPatternMemoryIdentity ?? "Daily Lens",
            title: ritual.title,
            intro: ritual.intro.nilIfBlankForHome,
            pullQuote: ritual.validPullQuote,
            deeperRead: ritual.validDeeperRead,
            watchFor: ritual.validWatchFor,
            move: ritual.validMove
        )
        guard let image = DailyReadShareRenderer.renderImage(for: content) else {
            return [formattedProductionControlShareText(ritual)]
        }
        return [image, formattedProductionControlShareText(ritual)]
    }

    private func refreshPatternMemory() {
        patternMemorySummary = PatternMemoryService.shared.monthlySummary()
        patternMemoryReflection = PatternMemoryService.shared.monthlyReflection()
    }

    private func formattedDailyReadShareText(_ ritual: DailyRitualResponse) -> String {
        let content = dailyLensContent(for: ritual)
        guard content.isReadyForDisplay else {
            return formattedProductionControlShareText(ritual)
        }

        return DailyLensSharePayload(
            content: content,
            signLine: currentPatternMemoryIdentity ?? "Daily Lens"
        ).text
    }

    private func formattedDailyReadShareCaption(
        _ ritual: DailyRitualResponse,
        content: DailyLensContent? = nil
    ) -> String {
        if let title = content?.title?.trimmingCharacters(in: .whitespacesAndNewlines),
           !title.isEmpty {
            return "My Zodian Daily Lens: \(title)"
        }
        return "My Zodian Daily Lens"
    }

    private func formattedProductionControlShareText(_ ritual: DailyRitualResponse) -> String {
        let fields = [
            ritual.intro.nilIfBlankForHome,
            ritual.validPullQuote,
            ritual.validDeeperRead.map { "Behind the Lens: \($0)" },
            ritual.validWatchFor.map { "Watch: \($0)" },
            ritual.validMove.map { "Move: \($0)" }
        ]
        .compactMap { $0 }
        .joined(separator: "\n\n")

        return """
        Zodian Daily Lens
        \(currentPatternMemoryIdentity ?? "Daily Lens")

        \(ritual.title)

        \(fields)
        """
    }

    private func shareDailyRead(_ ritual: DailyRitualResponse) {
        feedbackSoft()
        dailyReadShareItems = dailyReadShareItems(for: ritual)
        trackDailyReadEvent(.dailyReadShared, ritual: ritual, isSaved: dailyReadIsSaved(ritual))
        showDailyReadShareSheet = true
    }

    private func clearDailyReadSaveMessageSoon() {
        let token = UUID()
        dailyReadSaveMessageToken = token

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            guard dailyReadSaveMessageToken == token else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                dailyReadSaveMessage = nil
                dailyReadSaveDetailMessage = nil
            }
        }
    }

    private func editorialBreathLine(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .medium, design: .serif))
            .foregroundStyle(ZD.Color.muted.opacity(0.78))
            .lineSpacing(4)
            .padding(.vertical, 8)
            .padding(.horizontal, 2)
    }

    private var identityPathSection: some View {
        Button {
            feedbackSoft()
            store.selectedTab = .blueprint
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "book.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(ZD.Color.accent.opacity(0.10))
                    )

                VStack(alignment: .leading, spacing: 6) {
                Text("Identity")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Understand the patterns that shape you")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 5) {
                        Text("Go deeper")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(0.8)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.top, 1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 21)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ZD.Color.card.opacity(0.58),
                                    ZD.Color.cardAlt.opacity(0.34)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Identity uses complete, nested gold halos rather than
                    // Connect's intersecting orbit lines. Keeping both rings
                    // fully inside the card makes the treatment feel settled
                    // and intentional instead of like a cropped decoration.
                    Ellipse()
                        .stroke(ZD.Color.premium.opacity(0.13), lineWidth: 1)
                        .frame(width: 154, height: 64)
                        .rotationEffect(.degrees(-18))
                        .offset(x: 74, y: -6)

                    Ellipse()
                        .stroke(ZD.Color.premium.opacity(0.065), lineWidth: 1)
                        .frame(width: 122, height: 50)
                        .rotationEffect(.degrees(-18))
                        .offset(x: 74, y: -6)

                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.14), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            )
        }
        .buttonStyle(.plain)
    }

    private var connectEntrySection: some View {
        Button {
            feedbackSoft()
            store.selectedTab = .connect
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(ZD.Color.accent.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Connect")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("See today’s Lens or Identity for someone you know.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 5) {
                        Text("Read someone")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(0.8)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(ZD.Color.accent)
                    .padding(.top, 1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ZD.Color.cardAlt.opacity(0.76),
                                    ZD.Color.card.opacity(0.64)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Ellipse()
                        .stroke(ZD.Color.accent.opacity(0.12), lineWidth: 1)
                        .frame(width: 260, height: 116)
                        .rotationEffect(.degrees(-14))
                        .offset(x: 88, y: -30)

                    Ellipse()
                        .stroke(ZD.Color.border.opacity(0.15), lineWidth: 1)
                        .frame(width: 210, height: 92)
                        .rotationEffect(.degrees(24))
                        .offset(x: 112, y: 48)

                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Connect. See today’s Lens or Identity for someone you know. Read someone.")
        .accessibilityHint("Opens the Connect tab.")
    }

    // MARK: - Daily Home Copy helpers
    private var dailyReadTitle: String {
        if isDailyReadRevealed, case .loaded(let ritual) = dailyRitualViewModel.state {
            return ritual.title
        }

        return "Ready when you are"
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
        userLead(HomeHeaderEngine.line(for: headerContext, date: Date()))
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

    private var isDailyReadRevealed: Bool {
        !isDailyReadReplayConcealed && (store.todayRevealed || isDailyReadExpanded)
    }

    private func revealDailyReadInline() {
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
            withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
                isDailyReadReplayConcealed = false
                isDailyReadExpanded = true
            }
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
            isDailyReadExpanded = false
            isDailyReadReplayConcealed = false
        }
    }

    private func replayDailyReadReveal() {
        guard isDailyReadRevealed, !isOpeningDailyRitual else { return }

        feedbackSoft()
        todayLensResetFocus()
        withAnimation(.easeInOut(duration: reduceMotion ? 0.12 : 0.24)) {
            isDailyReadReplayConcealed = true
            isDailyReadExpanded = false
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

    private func distinctDailyReadValue(_ value: String?, comparedTo others: [String?]) -> String? {
        guard let normalizedValue = normalizedDailyReadText(value) else { return nil }

        let otherValues = others.compactMap(normalizedDailyReadText)
        guard !otherValues.contains(normalizedValue) else { return nil }
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedDailyReadText(_ value: String?) -> String? {
        let normalized = value?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()

        guard let normalized, !normalized.isEmpty else { return nil }
        return normalized
    }

    // Remove duplicate savedPeople and SavedLookupPerson definitions
    // Removed: private var savedPeople: [SavedLookupPerson]
    // Removed: private struct SavedLookupPerson

    private func deleteSavedPerson(_ person: SavedLookupPerson) {
        var existing = UserDefaults.standard.stringArray(forKey: "saved_people") ?? []
        existing.removeAll { $0 == person.id }
        UserDefaults.standard.set(existing, forKey: "saved_people")
        if selectedDetailPerson?.id == person.id {
            selectedDetailPerson = nil
        }
        loadSavedPeople()
    }

    private func loadSavedPeople() {
        savedPeople = SavedLookupPerson.loadAll()
    }

    #if DEBUG
    private enum PatternIntelligenceVisualQA {
        static let savedCountFlag = "-ZodianPatternQASavedCount"
        static let openSheetFlag = "-ZodianPatternQAOpenSheet"
    }

    private var patternIntelligenceVisualQASavedCount: Int? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: PatternIntelligenceVisualQA.savedCountFlag) else {
            return nil
        }

        let valueIndex = arguments.index(after: flagIndex)
        guard arguments.indices.contains(valueIndex),
              let savedCount = Int(arguments[valueIndex]) else {
            return nil
        }

        return max(0, min(savedCount, 120))
    }

    private var shouldOpenPatternIntelligenceVisualQASheet: Bool {
        ProcessInfo.processInfo.arguments.contains(PatternIntelligenceVisualQA.openSheetFlag)
            && patternIntelligenceVisualQASavedCount != nil
    }

    private func openPatternIntelligenceVisualQASheetIfNeeded() {
        guard shouldOpenPatternIntelligenceVisualQASheet,
              !didOpenPatternIntelligenceVisualQASheet else { return }

        didOpenPatternIntelligenceVisualQASheet = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            guard shouldOpenPatternIntelligenceVisualQASheet else { return }
            showPatternIntelligenceDestination = true
        }
    }

    private func patternIntelligenceVisualQASavedReadFixtures(count: Int) -> [SavedDailyReading] {
        guard count > 0 else { return [] }

        // DEBUG-only visual QA fixtures. They are never inserted into SwiftData.
        let calendar = Calendar.current
        let signalPlan: [(primary: String, secondary: String, tags: [String], tone: String)] = [
            ("Trust Instincts", "Ask Questions", ["instinct", "choice", "trust"], "steady"),
            ("Ask Questions", "Notice Details", ["curiosity", "questions", "observation"], "curious"),
            ("Trust Instincts", "Being Seen", ["instinct", "visibility", "trust"], "open"),
            ("Being Seen", "Quiet Confidence", ["visibility", "confidence", "recognition"], "clear"),
            ("Ask Questions", "Choose Growth", ["curiosity", "growth", "choice"], "reflective"),
            ("Trust Instincts", "Build Momentum", ["instinct", "momentum", "trust"], "grounded"),
            ("Quiet Confidence", "Ask Questions", ["confidence", "curiosity", "clarity"], "calm")
        ]

        return (0..<count).map { index in
            let plan = signalPlan[index % signalPlan.count]
            let createdAt = calendar.date(byAdding: .day, value: -(count - index), to: Date()) ?? Date()

            return SavedDailyReading(
                dateKey: "pattern-visual-qa-\(index)",
                archetypeId: "pattern-visual-qa",
                theme: plan.primary,
                summary: "A saved Lens for visual QA.",
                mood: plan.tone,
                themeKey: plan.primary,
                toneKey: plan.tone,
                identity: plan.primary,
                insight: index == 0
                    ? "This first Lens points toward \(plan.primary.lowercased())."
                    : "Your saved Lenses are starting to point toward \(plan.primary.lowercased()).",
                focus: plan.secondary,
                affirmation: "Keep noticing what returns.",
                energy: plan.tone,
                energyKey: plan.tone,
                patternConfidence: 0.42 + Double(index % 4) * 0.08,
                patternReflection: 0.48 + Double(index % 3) * 0.07,
                patternConnection: 0.38 + Double(index % 5) * 0.06,
                patternGrowth: 0.45 + Double(index % 4) * 0.09,
                patternMomentum: 0.36 + Double(index % 6) * 0.05,
                patternPrimarySignal: plan.primary,
                patternSecondarySignal: plan.secondary,
                patternEmotionalTone: plan.tone,
                patternThemeTags: plan.tags,
                love: "Trust what keeps returning.",
                work: "Notice the pattern before moving.",
                growth: "Let one clear signal guide the day.",
                caution: "Do not rush the meaning.",
                opportunity: "A recurring theme is becoming easier to see.",
                createdAt: createdAt
            )
        }
    }
    #endif

}

private struct TodayLensFocusTouchSurface: UIViewRepresentable {
    let restingControlSize: CGSize
    let restingCenterY: CGFloat
    let onTouchDown: () -> Void
    let onHoldActivated: () -> Void
    let onChanged: (CGFloat) -> Void
    let onEnded: () -> Void
    let onCancelled: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> TodayLensFocusHitView {
        let view = TodayLensFocusHitView(frame: .zero)
        view.backgroundColor = .clear
        view.isAccessibilityElement = false
        view.restingControlSize = restingControlSize
        view.restingCenterY = restingCenterY

        let recognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handle(_:))
        )
        // Begin immediately so this one surface owns the touch before the
        // enclosing Home ScrollView can turn the same drag into scrolling.
        // The coordinator promotes pressing -> exploring after the intended
        // sustained-hold interval.
        recognizer.minimumPressDuration = 0
        recognizer.allowableMovement = 1_000
        recognizer.cancelsTouchesInView = true
        recognizer.delaysTouchesBegan = false
        view.addGestureRecognizer(recognizer)
        return view
    }

    func updateUIView(_ uiView: TodayLensFocusHitView, context: Context) {
        context.coordinator.parent = self
        uiView.restingControlSize = restingControlSize
        uiView.restingCenterY = restingCenterY
    }

    final class Coordinator: NSObject {
        var parent: TodayLensFocusTouchSurface
        private var holdWorkItem: DispatchWorkItem?
        private var holdIsActive = false

        init(parent: TodayLensFocusTouchSurface) {
            self.parent = parent
        }

        @objc func handle(_ recognizer: UILongPressGestureRecognizer) {
            guard let view = recognizer.view else { return }
            let locationY = recognizer.location(in: view).y

            switch recognizer.state {
            case .began:
                holdIsActive = false
                parent.onTouchDown()

                let workItem = DispatchWorkItem { [weak self] in
                    guard let self else { return }
                    self.holdIsActive = true
                    self.parent.onHoldActivated()
                }
                holdWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24, execute: workItem)
            case .changed:
                guard holdIsActive else { return }
                parent.onChanged(locationY)
            case .ended:
                cancelPendingHold()
                parent.onEnded()
            case .cancelled, .failed:
                cancelPendingHold()
                parent.onCancelled()
            default:
                break
            }
        }

        private func cancelPendingHold() {
            holdWorkItem?.cancel()
            holdWorkItem = nil
            holdIsActive = false
        }
    }
}

private final class TodayLensFocusHitView: UIView {
    var restingControlSize: CGSize = .zero
    var restingCenterY: CGFloat = 0

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitTarget = CGRect(
            x: (bounds.width - restingControlSize.width) / 2,
            y: restingCenterY - (restingControlSize.height / 2),
            width: restingControlSize.width,
            height: restingControlSize.height
        )
        .insetBy(dx: -6, dy: -6)

        return hitTarget.contains(point)
    }
}

// MARK: - Birthday Lookup

private struct BirthdayLookupSheet: View {
    let selectedPerson: SavedLookupPerson?
    let onSave: () -> Void

    private enum Field {
        case name
    }

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()
    @State private var draftBirthday = Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()
    @State private var showBirthdayPicker = false
    @State private var hasRevealed = false
    @State private var savedMessage: String? = nil
    @State private var showCompareRead = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var lookupRevealScrollToken = 0
    @State private var presentationDetent: PresentationDetent = .medium
    @FocusState private var focusedField: Field?

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

    private var viewerWesternSign: LookupWesternSign? {
        store.currentUser.flatMap { LookupWesternSign(rawValue: $0.westernSign.rawValue) }
    }

    private var viewerChineseSign: LookupChineseSign? {
        store.currentUser.flatMap { LookupChineseSign(rawValue: $0.chineseSign.rawValue) }
    }

    private var compareClicksLine: String {
        LookupPatternCopy.compareClicksLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: displayName
        )
    }

    private var compareCatchLine: String {
        LookupPatternCopy.compareCatchLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: displayName
        )
    }

    private var compareKnowLine: String {
        LookupPatternCopy.compareKnowLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: displayName
        )
    }

    private var generatedShareText: String {
        """
        Zodian read \(displayName) as \(displayedPatternTitle).

        \(readLine)

        Quick signal:
        \(LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign))
        """
    }

    private var lookupShareContent: LookupShareContent {
        LookupShareContent(
            name: displayName,
            patternTitle: displayedPatternTitle,
            readLine: readLine,
            signalLine: LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign),
            compareClicksLine: compareClicksLine,
            compareCatchLine: compareCatchLine,
            compareKnowLine: compareKnowLine
        )
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

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Read Someone")
                                    .font(.system(size: 34, weight: .regular, design: .serif))
                                    .foregroundStyle(ZD.Color.textPrimary)

                                Text("Enter a birthday and see their perspective more clearly")
                                    .font(ZD.Font.body())
                                    .foregroundStyle(ZD.Color.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            lookupInputCard

                            if hasRevealed {
                                lookupResultCard
                                    .id("lookupResult")
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, ZD.Spacing.l)
                        .padding(.top, 22)
                        .padding(.bottom, 40)
                    }
                    .onChange(of: lookupRevealScrollToken) { _, _ in
                        guard hasRevealed else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                                proxy.scrollTo("lookupResult", anchor: .top)
                            }
                        }
                    }
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
                draftBirthday = savedDate
            }

            hasRevealed = true
            presentationDetent = .large
        }
        .sheet(isPresented: $showBirthdayPicker) {
            BirthdayPickerSheet(
                birthday: $draftBirthday,
                onConfirm: {
                    birthday = draftBirthday
                    showBirthdayPicker = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
        .presentationDetents([.medium, .large], selection: $presentationDetent)
        .presentationDragIndicator(.visible)
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
                    .focused($focusedField, equals: .name)
                    .onSubmit {
                        focusedField = nil
                    }
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

                Button {
                    draftBirthday = birthday
                    showBirthdayPicker = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ZD.Color.accent)

                        Text(birthday.formatted(date: .long, time: .omitted))
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Spacer(minLength: 8)

                        Text("Change")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(ZD.Color.accent)
                    }
                    .padding(14)
                    .background {
                        sheetPanelFieldBackground
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Birthday, \(birthday.formatted(date: .long, time: .omitted))")
                .accessibilityHint("Opens a birthday selector")
            }

            Button {
                focusedField = nil

                withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                    hasRevealed = true
                    presentationDetent = .large
                }
                lookupRevealScrollToken += 1
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
                Text("Quick detail")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(LookupPatternCopy.signalLine(western: westernSign, chinese: chineseSign))
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            saveToHomeCallout

            Button {
                savePerson()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 13, weight: .bold))

                    Text("Save to My Circle")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(ZD.Color.accent))
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                lookupMiniAction(title: "Compare", icon: "arrow.left.arrow.right")
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

    private var saveToHomeCallout: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 26, height: 26)
                .background(Circle().fill(ZD.Color.accent.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text("Keep them in My Circle")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text("Save this person so their read is easy to return to.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                )
        )
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
                presentationDetent = .large
            }
        case "Share":
            shareItems = lookupShareItems()
            showShareSheet = true
        default:
            break
        }
    }

    @MainActor
    private func lookupShareItems() -> [Any] {
        guard let image = LookupShareRenderer.renderImage(for: lookupShareContent) else {
            return [generatedShareText]
        }

        return [image, generatedShareText]
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

private struct DailyReadShareContent {
    let signLine: String
    let title: String
    let intro: String?
    let pullQuote: String?
    let deeperRead: String?
    let watchFor: String?
    let move: String?
}

private struct DailyReadShareCardView: View {
    let content: DailyReadShareContent

    var body: some View {
        ZStack {
            ZD.Color.bg

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.98),
                            ZD.Color.cardAlt.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("ZODIAN DAILY LENS")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(2.4)
                            .foregroundStyle(ZD.Color.accent)

                        Text(content.signLine)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(ZD.Color.muted)
                    }

                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)
                }

                Text(content.title)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let intro = content.intro {
                    Text(intro)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.9))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let pullQuote = content.pullQuote {
                    HStack(alignment: .top, spacing: 14) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(ZD.Color.accent.opacity(0.82))
                            .frame(width: 4)

                        Text(pullQuote)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let deeperRead = content.deeperRead {
                    shareField(title: "BEHIND THE LENS", text: deeperRead)
                }

                if let watchFor = content.watchFor {
                    shareField(title: "WATCH", text: watchFor)
                }

                if let move = content.move {
                    shareField(title: "MOVE", text: move)
                }

                HStack(spacing: 8) {
                    Text("Astrology is the lens.")
                    Text("Zodian brings you into focus.")
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.muted.opacity(0.8))
                .padding(.top, 4)
            }
            .padding(30)
        }
        .frame(width: 390)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func shareField(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(ZD.Color.muted)

            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum DailyReadShareRenderer {
    @MainActor
    static func renderImage(for content: DailyReadShareContent) -> UIImage? {
        let shareView = DailyReadShareCardView(content: content)
            .padding(24)
            .background(ZD.Color.bg)
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

private enum DailyLensShareRenderer {
    @MainActor
    static func renderImage(for content: DailyLensSharePayload) -> UIImage? {
        let shareView = ZStack {
            ZD.Color.bg

            VStack(alignment: .leading, spacing: 20) {
                Text("ZODIAN DAILY LENS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(2.4)
                    .foregroundStyle(ZD.Color.accent)

                Text(content.signLine)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)

                if let title = content.title?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !title.isEmpty {
                    Text(title)
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(content.read)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(30)
        }
        .frame(width: 390)
        .fixedSize(horizontal: false, vertical: true)
        .padding(24)
        .background(ZD.Color.bg)
        .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

private struct LookupShareContent {
    let name: String
    let patternTitle: String
    let readLine: String
    let signalLine: String
    let compareClicksLine: String
    let compareCatchLine: String
    let compareKnowLine: String
}

private struct LookupShareCardView: View {
    let content: LookupShareContent

    var body: some View {
        ZStack {
            ZD.Color.bg

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.98),
                            ZD.Color.cardAlt.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("ZODIAN READ SOMEONE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(2.2)
                            .foregroundStyle(ZD.Color.accent)

                        Text(content.patternTitle)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .tracking(1.1)
                            .foregroundStyle(ZD.Color.muted)
                    }

                    Spacer()

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)
                }

                Text(content.name)
                    .font(.system(size: 42, weight: .regular, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                shareField(title: "THIS PERSON", text: content.readLine, isPrimary: true)
                shareField(title: "QUICK SIGNAL", text: content.signalLine)

                VStack(alignment: .leading, spacing: 12) {
                    Text("YOU × THEM")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(ZD.Color.accent)

                    shareField(title: "WHERE IT CLICKS", text: content.compareClicksLine)
                    shareField(title: "WHERE IT CATCHES", text: content.compareCatchLine)
                    shareField(title: "WHAT TO KNOW", text: content.compareKnowLine)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(ZD.Color.cardAlt.opacity(0.62))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                        )
                )
            }
            .padding(30)
        }
        .frame(width: 390)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func shareField(title: String, text: String, isPrimary: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(ZD.Color.muted)

            Text(text)
                .font(.system(size: isPrimary ? 18 : 15, weight: isPrimary ? .semibold : .medium))
                .foregroundStyle(isPrimary ? ZD.Color.textPrimary : ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum LookupShareRenderer {
    @MainActor
    static func renderImage(for content: LookupShareContent) -> UIImage? {
        let shareView = LookupShareCardView(content: content)
            .padding(24)
            .background(ZD.Color.bg)
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private extension String {
    var nilIfBlankForHome: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
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
        validated(personRead(western: western, chinese: chinese, name: name), fallback: "\(name) is easiest to read through what they do twice. Watch what they return to when nobody is pushing.")
    }

    static func signalLine(western: LookupWesternSign, chinese: LookupChineseSign) -> String {
        validated(quickSignal(western: western, chinese: chinese), fallback: "The first thing to notice is how they respond when a small choice starts to feel important.")
    }

    static func compareClicksLine(
        viewerWestern: LookupWesternSign?,
        viewerChinese: LookupChineseSign?,
        targetWestern: LookupWesternSign,
        targetChinese: LookupChineseSign,
        name: String
    ) -> String {
        let subject = subject(for: name)
        let possessive = possessive(for: name)
        let copy: String

        switch (viewerWestern, targetWestern) {
        case (.some(.libra), .cancer):
            copy = "You may catch the mood behind \(possessive) words before they explain it, which can make the connection feel familiar fast."
        case (.some(.libra), .taurus):
            copy = "\(possessive) slower pace can make your attention settle instead of scanning for what everyone else needs."
        case (.some(.taurus), .libra):
            copy = "\(subject) can soften the edges of a conversation you would rather keep simple, and that may make hard topics easier to enter."
        case (.some(.taurus), .taurus):
            copy = "You may both trust what is steady. Plans feel easier when nobody has to perform excitement."
        case (.some(.aries), _):
            copy = "\(possessive) directness gives you something clear to meet. You are less likely to feel stuck guessing where the room stands."
        case (.some(.scorpio), _):
            copy = "\(subject) may notice the unsaid parts too, which can make a quiet exchange feel more honest than a polished one."
        case (.some(.virgo), _):
            copy = "\(subject) gives you details to work with. Small habits and repeated choices are easier to read than big declarations."
        case (.some(.pisces), _):
            copy = "\(possessive) shifts in tone may make sense to you before they make sense out loud."
        default:
            copy = clickLine(for: targetWestern, name: name)
        }

        return validated(copy, fallback: clickLine(for: targetWestern, name: name))
    }

    static func compareCatchLine(
        viewerWestern: LookupWesternSign?,
        viewerChinese: LookupChineseSign?,
        targetWestern: LookupWesternSign,
        targetChinese: LookupChineseSign,
        name: String
    ) -> String {
        let subject = subject(for: name)
        let object = object(for: name)
        let beVerb = name == "This person" ? "are" : "is"
        let copy: String

        switch (viewerChinese, targetChinese) {
        case (.some(.snake), .tiger):
            copy = "Friction can start if you wait for \(object) to explain a feeling they are still inside of."
        case (.some(.snake), .horse):
            copy = "Friction can start when you read between the lines and \(subject) thinks a simple choice has become a quiet test."
        case (.some(.horse), .snake):
            copy = "Friction can start when you want a clean answer and \(subject) \(beVerb) still deciding what they are willing to say."
        default:
            copy = catchLine(for: targetChinese, name: name)
        }

        return validated(copy, fallback: catchLine(for: targetChinese, name: name))
    }

    static func compareKnowLine(
        viewerWestern: LookupWesternSign?,
        viewerChinese: LookupChineseSign?,
        targetWestern: LookupWesternSign,
        targetChinese: LookupChineseSign,
        name: String
    ) -> String {
        let object = object(for: name)
        let possessive = possessive(for: name)
        let copy: String

        switch (viewerWestern, targetChinese) {
        case (.some(.libra), .tiger):
            copy = "You do not need to make \(possessive) first answer fair or tidy. Let it pass, then listen for what remains."
        case (.some(.libra), .horse):
            copy = "Offer \(object) a real option, then watch which one they return to when the moment is no longer pressured."
        case (.some(.taurus), .snake):
            copy = "Do not rush \(object) into certainty. Ask clearly once, then let the quiet show you what they trust."
        default:
            copy = knowLine(for: targetChinese, name: name)
        }

        return validated(copy, fallback: knowLine(for: targetChinese, name: name))
    }

    static func validationIssues(read: String, signal: String, click: String, catchText: String, know: String) -> [String] {
        let labeled = [
            ("Identity Read", read),
            ("Quick Detail", signal),
            ("Where it clicks", click),
            ("Where it catches", catchText),
            ("What to know", know)
        ]

        var issues = labeled.flatMap { label, text in
            validationIssues(in: text).map { "\(label): \($0)" }
        }

        let ideaKeys = labeled.map { ($0.0, dominantIdeaKey(for: $0.1)) }
        for index in ideaKeys.indices {
            for otherIndex in ideaKeys.indices where otherIndex > index {
                let first = ideaKeys[index]
                let second = ideaKeys[otherIndex]
                if first.1 == second.1 {
                    issues.append("\(first.0) duplicates \(second.0) idea: \(first.1)")
                }
            }
        }

        return issues
    }

    private static func personRead(western: LookupWesternSign, chinese: LookupChineseSign, name: String) -> String {
        switch (western, chinese) {
        case (.cancer, .tiger):
            return "\(name) moves from feeling before the feeling has fully settled. If they feel boxed in, they get harder to read."
        case (.taurus, .horse):
            return "\(name) seems steady until something starts to feel forced. Then they look for the quickest way back to their own pace."
        case (.libra, .snake):
            return "\(name) notices small shifts in tone and decides carefully what to reveal. They can seem easy until a question gets too direct."
        case (.aries, .rabbit):
            return "\(name) moves fast on the outside, but they are more selective than they seem. A hard push can make them go quiet."
        case (.scorpio, .dog):
            return "\(name) watches what people do after the room gets uncomfortable. Once trust cracks, they remember the small details."
        case (.virgo, .rooster):
            return "\(name) catches the detail everyone else skipped. If the plan gets sloppy, their face may say it before they do."
        case (.pisces, .goat):
            return "\(name) takes in the room before they speak. A harsh tone can stay with them longer than the conversation."
        default:
            return animalRead(chinese, name: name)
        }
    }

    private static func animalRead(_ chinese: LookupChineseSign, name: String) -> String {
        switch chinese {
        case .rat:
            return "\(name) notices openings quickly. They may answer fast, change course faster, and leave you catching up after the fact."
        case .ox:
            return "\(name) moves carefully at first. Once they decide, they can become much harder to redirect."
        case .tiger:
            return "\(name) moves quickly when something feels wrong. They may need a minute before they can explain what set them off."
        case .rabbit:
            return "\(name) seems gentle until the tone turns sharp. Then they may step back before saying what bothered them."
        case .dragon:
            return "\(name) has a way of filling the room without asking for permission. Even quiet choices can draw attention."
        case .snake:
            return "\(name) reads more than they say. If a question gets too direct, they may answer only the part they trust."
        case .horse:
            return "\(name) is easy to be around until a choice starts to feel forced. Then the whole room can feel smaller."
        case .goat:
            return "\(name) notices tone before most people notice content. Warmth gets you further than pressure."
        case .monkey:
            return "\(name) thinks quickly and watches for the interesting door. If the room goes flat, they may already be halfway elsewhere."
        case .rooster:
            return "\(name) catches the loose thread early. A messy plan may bother them before anyone else sees the problem."
        case .dog:
            return "\(name) watches for consistency. If words and actions stop matching, they may not say much, but they notice."
        case .pig:
            return "\(name) responds to what feels real and generous. If they care, they tend to show it in practical ways."
        }
    }

    private static func quickSignal(western: LookupWesternSign, chinese: LookupChineseSign) -> String {
        switch (western, chinese) {
        case (.cancer, .tiger):
            return "Their face may change before they are ready to explain why."
        case (.taurus, .horse):
            return "They often pause at the exact moment others expect an easy yes."
        case (.libra, .snake):
            return "They may smile through a moment while privately deciding what feels safe to say."
        case (.aries, .rabbit):
            return "Their yes can arrive quickly, but their comfort takes longer to earn."
        case (.scorpio, .dog):
            return "They remember whether you followed through."
        case (.virgo, .rooster):
            return "They ask the practical question everyone else skipped."
        case (.pisces, .goat):
            return "They may stay soft in the moment and process the sting later."
        default:
            return westernSignal(western)
        }
    }

    private static func westernSignal(_ western: LookupWesternSign) -> String {
        switch western {
        case .aries:
            return "They tend to answer with action before offering a long explanation."
        case .taurus:
            return "They are easiest to read when a decision is being rushed."
        case .gemini:
            return "They usually reveal interest by asking one more question."
        case .cancer:
            return "Their mood can enter the room before they name what changed."
        case .leo:
            return "They often show care by making the moment feel bigger than expected."
        case .virgo:
            return "They notice the loose detail before anyone calls it a problem."
        case .libra:
            return "They catch unfairness quickly, especially when nobody wants to name it."
        case .scorpio:
            return "They listen for what is being avoided."
        case .sagittarius:
            return "They look for the honest answer, even when it makes the room less tidy."
        case .capricorn:
            return "They show seriousness by becoming more practical, not more dramatic."
        case .aquarius:
            return "They often step back just enough to see the whole room differently."
        case .pisces:
            return "They pick up the tone underneath the conversation."
        }
    }

    private static func clickLine(for targetWestern: LookupWesternSign, name: String) -> String {
        let subject = subject(for: name)
        let possessive = possessive(for: name)
        let sentencePossessive = sentencePossessive(for: name)

        switch targetWestern {
        case .aries:
            return "\(possessive) directness can make the room easier to read. You usually know what they mean first."
        case .taurus:
            return "\(possessive) steady pace can make time together feel less performative."
        case .gemini:
            return "\(subject) keeps the exchange moving. A small question can become a real conversation quickly."
        case .cancer:
            return "\(sentencePossessive) visible cues give you something honest to work with; the connection rarely stays purely polite."
        case .leo:
            return "\(subject) can make ordinary moments feel noticed, which may help warmth arrive faster."
        case .virgo:
            return "\(subject) gives you details to work with. Small habits are easier to read than big declarations."
        case .libra:
            return "\(subject) can meet you in nuance, especially when a conversation needs tact."
        case .scorpio:
            return "\(subject) may notice the unsaid parts too, which can make quiet exchanges feel more honest."
        case .sagittarius:
            return "\(subject) can make honesty feel less heavy by saying the thing plainly."
        case .capricorn:
            return "\(possessive) practical side can make trust feel built instead of performed."
        case .aquarius:
            return "\(subject) can help you see the situation from an angle you had not tried yet."
        case .pisces:
            return "\(possessive) shifts in tone may make sense before they make sense out loud."
        }
    }

    private static func catchLine(for targetChinese: LookupChineseSign, name: String) -> String {
        let subject = subject(for: name)
        let possessive = possessive(for: name)
        let object = object(for: name)
        let beVerb = name == "This person" ? "are" : "is"

        switch targetChinese {
        case .rat:
            return "Friction can start when \(subject) moves on from a moment before you have caught up."
        case .ox:
            return "Friction can start when \(possessive) slow yes gets mistaken for a no."
        case .tiger:
            return "Friction can start if you ask for certainty while \(subject) \(beVerb) still sorting out what they mean."
        case .rabbit:
            return "Friction can start if a small correction lands sharper than you meant it."
        case .dragon:
            return "Friction can start when \(possessive) presence takes over a room they did not mean to dominate."
        case .snake:
            return "Friction can start when \(subject) holds back and you start filling in the blanks."
        case .horse:
            return "Friction can start when a simple suggestion starts to feel like a decision being made for \(object)."
        case .goat:
            return "Friction can start if the tone gets too blunt before trust has warmed up."
        case .monkey:
            return "Friction can start when \(subject) treats a serious moment like something to outsmart."
        case .rooster:
            return "Friction can start when \(subject) points out a detail you thought was harmless."
        case .dog:
            return "Friction can start when \(subject) tests whether your words match what you actually do."
        case .pig:
            return "Friction can start when \(possessive) generosity is treated like it costs them nothing."
        }
    }

    private static func knowLine(for targetChinese: LookupChineseSign, name: String) -> String {
        let subject = subject(for: name)
        let object = object(for: name)
        let possessive = possessive(for: name)

        switch targetChinese {
        case .rat:
            return "Do not chase every quick turn. Notice which idea \(subject) comes back to after the room settles."
        case .ox:
            return "Give \(object) time to decide, then take the decision seriously when it arrives."
        case .tiger:
            return "Let the first thing they say pass before treating it as the final answer."
        case .rabbit:
            return "Keep the tone gentle if you want the real answer."
        case .dragon:
            return "Do not confuse \(possessive) confidence with certainty; ask what they actually want."
        case .snake:
            return "Ask clearly once, then give the quiet enough space to become honest."
        case .horse:
            return "Offer \(object) a real option, then watch which one they return to."
        case .goat:
            return "Lead with warmth before asking \(object) for precision."
        case .monkey:
            return "If \(subject) jokes around the point, listen for the truth sitting inside the joke."
        case .rooster:
            return "Be clear about details before the details become the whole conversation."
        case .dog:
            return "Be consistent in the small things; that is where \(subject) decides what to trust."
        case .pig:
            return "Notice what \(subject) keeps offering without making a speech about it."
        }
    }

    private static func validated(_ text: String, fallback: String) -> String {
        validationIssues(in: text).isEmpty ? text : fallback
    }

    private static func subject(for name: String) -> String {
        name == "This person" ? "they" : name
    }

    private static func possessive(for name: String) -> String {
        name == "This person" ? "their" : "\(name)'s"
    }

    private static func sentencePossessive(for name: String) -> String {
        name == "This person" ? "Their" : "\(name)'s"
    }

    private static func object(for name: String) -> String {
        name == "This person" ? "them" : name
    }

    private static func validationIssues(in text: String) -> [String] {
        let normalized = text.lowercased()
        var issues: [String] = []

        for phrase in forbiddenPhrases where normalized.contains(phrase) {
            issues.append("forbidden phrase '\(phrase)'")
        }

        for sign in LookupWesternSign.allCases.map(\.displayName) + LookupChineseSign.allCases.map(\.displayName) {
            let signMechanics = [
                "\(sign.lowercased()) gives",
                "\(sign.lowercased()) shows",
                "\(sign.lowercased()) creates",
                "\(sign.lowercased()) brings"
            ]
            if signMechanics.contains(where: normalized.contains) {
                issues.append("sign-mechanics phrase for \(sign)")
            }
        }

        if normalized.contains("your the ") || normalized.contains("your archetype") {
            issues.append("user archetype phrasing")
        }

        if text.split(separator: " ").count < 7 {
            issues.append("too short to be behavioral")
        }

        return issues
    }

    private static func dominantIdeaKey(for text: String) -> String {
        let normalized = text.lowercased()

        if normalized.contains("tone") || normalized.contains("sharp") || normalized.contains("warm") {
            return "tone"
        }
        if normalized.contains("quiet") || normalized.contains("holds back") || normalized.contains("silence") {
            return "withholding"
        }
        if normalized.contains("forced") || normalized.contains("option") || normalized.contains("decision") {
            return "choice-pressure"
        }
        if normalized.contains("trust") || normalized.contains("consistent") || normalized.contains("match") {
            return "trust"
        }
        if normalized.contains("detail") || normalized.contains("loose") || normalized.contains("sloppy") {
            return "details"
        }
        if normalized.contains("reaction") || normalized.contains("reacting") || normalized.contains("first") {
            return "first-response"
        }

        return normalized
            .split { !$0.isLetter }
            .filter { $0.count > 4 }
            .prefix(3)
            .joined(separator: "-")
    }

    private static let forbiddenPhrases = [
        "needs freedom",
        "room to choose",
        "plays out over time",
        "first impulse",
        "energy",
        "alignment",
        "balance",
        "growth",
        "their pattern",
        "your archetype",
        "your the ",
        "values autonomy",
        "seeks emotional security",
        "relational contrast",
        "activates growth"
    ]
}

extension LookupWesternSign: CaseIterable {}

extension LookupChineseSign: CaseIterable {}


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

    private var viewerWesternSign: LookupWesternSign? {
        store.currentUser.flatMap { LookupWesternSign(rawValue: $0.westernSign.rawValue) }
    }

    private var viewerChineseSign: LookupChineseSign? {
        store.currentUser.flatMap { LookupChineseSign(rawValue: $0.chineseSign.rawValue) }
    }

    private var compareClicksLine: String {
        LookupPatternCopy.compareClicksLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: person.name
        )
    }

    private var compareCatchLine: String {
        LookupPatternCopy.compareCatchLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: person.name
        )
    }

    private var compareKnowLine: String {
        LookupPatternCopy.compareKnowLine(
            viewerWestern: viewerWesternSign,
            viewerChinese: viewerChineseSign,
            targetWestern: westernSign,
            targetChinese: chineseSign,
            name: person.name
        )
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
                sectionLabel("Identity read", color: ZD.Color.muted)

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
        Button {
            showShareSheet = true
        } label: {
            actionPill(title: "Share", icon: "square.and.arrow.up")
        }
        .buttonStyle(.plain)
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

    var body: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        tint.opacity(0.14),
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
                        ZD.Color.accent.opacity(0.07),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 40,
                    endRadius: 520
                )
            )
            .overlay(StarField().opacity(0.34))
            .ignoresSafeArea()
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

// MARK: - Home Header Engine

private enum HomeHeaderPhase {
    case discovery
    case returning
    case established
}

private struct PatternEvolutionMoment: Identifiable, Equatable {
    let id = UUID()
    let savedCount: Int
    let statusLabel: String
}

private struct PatternIntelligenceCardVisibilityKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

private struct PatternIntelligenceVisibilityReader: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: PatternIntelligenceCardVisibilityKey.self,
                value: proxy.frame(in: .global).intersects(UIScreen.main.bounds.insetBy(dx: 0, dy: -96))
            )
        }
        .allowsHitTesting(false)
    }
}

private struct YourPatternIrisView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var focusAdjustment: CGFloat = 0
    @State private var saveFocusLock: CGFloat = 0
    @State private var evolutionTrace: CGFloat = 0
    @State private var evolutionGlow = 0.0
    @State private var focusTask: Task<Void, Never>? = nil

    let preview: PatternIntelligencePreview
    let evolutionID: UUID?
    let evolutionStatusLabel: String?
    let isIdleActive: Bool

    private var irisOpacity: Double {
        switch preview.state {
        case .empty:
            return 0.34
        case .building:
            return 0.68
        case .ready:
            return 0.96
        }
    }

    private var irisRingCount: Int {
        switch preview.savedCount {
        case 0:
            return 2
        case 1..<3:
            return 4
        case 3..<5:
            return 6
        case 5..<7:
            return 8
        case 7..<30:
            return 9
        case 30..<90:
            // TODO: Add deeper 30-Lens iris complexity when monthly reflection unlocks.
            return 10
        default:
            // TODO: Add denser 90-Lens fingerprint-like structure for Cosmic Weather.
            return 11
        }
    }

    private var irisStrokeBoost: Double {
        switch preview.savedCount {
        case 0..<3:
            return 0
        case 3..<5:
            return 0.16
        case 5..<7:
            return 0.26
        default:
            return 0.34
        }
    }

    private var focusLineCount: Int {
        switch preview.savedCount {
        case 0:
            return 3
        case 1..<3:
            return 4
        case 3..<5:
            return 5
        case 5..<7:
            return 6
        default:
            return 7
        }
    }

    private var apertureLineCount: Int {
        switch preview.savedCount {
        case 0..<3:
            return 0
        case 0..<5:
            return 7
        case 5..<7:
            return 9
        default:
            return 11
        }
    }

    private var apertureBladeCount: Int {
        preview.savedCount >= 7 ? 7 : 0
    }

    private var signalParticleCount: Int {
        switch preview.savedCount {
        case 0..<3:
            return 0
        case 3..<5:
            return 10
        case 5..<7:
            return 16
        case 7..<30:
            return 22
        case 30..<90:
            return 28
        default:
            return 34
        }
    }

    private var irisFiberCount: Int {
        switch preview.savedCount {
        case 0:
            return 0
        case 1..<3:
            return 12
        case 3..<5:
            return 20
        case 5..<7:
            return 28
        case 7..<30:
            return 34
        case 30..<90:
            return 42
        default:
            return 50
        }
    }

    private var signalIntensity: Double {
        let values = [
            preview.scores.confidence,
            preview.scores.reflection,
            preview.scores.connection,
            preview.scores.growth,
            preview.scores.momentum
        ]

        return max(0.16, min(1, values.reduce(0, +) / Double(values.count)))
    }

    private var earnedLayerProgress: Double {
        switch preview.savedCount {
        case 0:
            return 0.16
        case 1..<3:
            return 0.34
        case 3..<5:
            return 0.54
        case 5..<7:
            return 0.72
        case 7..<30:
            return 0.86
        case 30..<90:
            return 0.94
        default:
            return 1.0
        }
    }

    private var signalLabel: String {
        (preview.topSignal ?? preview.discoveries.first?.label ?? "").lowercased()
    }

    private var signalAccent: Color {
        if signalLabel.contains("ask") || signalLabel.contains("curious") || signalLabel.contains("question") || signalLabel.contains("detail") {
            return ZD.Color.success
        }

        if signalLabel.contains("seen") || signalLabel.contains("connect") || signalLabel.contains("recognition") {
            return ZD.Color.accentSoft
        }

        if signalLabel.contains("growth") || signalLabel.contains("momentum") || signalLabel.contains("move") {
            return ZD.Color.warning
        }

        return ZD.Color.premium
    }

    private var signalBias: PatternIrisSignalBias {
        if signalLabel.contains("ask") || signalLabel.contains("curious") || signalLabel.contains("question") || signalLabel.contains("detail") {
            return .upperRight
        }

        if signalLabel.contains("seen") || signalLabel.contains("connect") || signalLabel.contains("recognition") {
            return .lowerLeft
        }

        if signalLabel.contains("growth") || signalLabel.contains("momentum") || signalLabel.contains("move") {
            return .lowerRight
        }

        return .upperLeft
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width * 0.50, y: proxy.size.height * 0.50)
            let irisWidth = min(proxy.size.width * 0.82, size * 1.74)
            let irisHeight = min(proxy.size.height * 0.82, irisWidth * 0.46)
            let focusFieldWidth = proxy.size.width * 1.28
            let idlePulse = 0.0
            let structuralPulse = evolutionGlow
            let displayPulse = idlePulse + structuralPulse
            let focusPull = reduceMotion ? 0 : max(focusAdjustment, saveFocusLock)
            let activeSignalOpacity = irisOpacity * (0.78 + signalIntensity * 0.16)
            let signatureOpacity = activeSignalOpacity * earnedLayerProgress

            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZD.Color.premium.opacity((0.12 + structuralPulse * 0.06) * irisOpacity),
                                signalAccent.opacity((0.055 + structuralPulse * 0.035) * irisOpacity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: irisWidth * (0.42 + structuralPulse * 0.04)
                        )
                    )
                    .frame(width: irisWidth * 1.10, height: irisHeight * 1.90)
                    .position(center)
                    .blur(radius: 1.5)

                signalQuadrantGlow(
                    center: signalBias.center(in: center, irisWidth: irisWidth, irisHeight: irisHeight),
                    size: irisHeight,
                    accent: signalAccent,
                    opacity: signatureOpacity,
                    pulse: structuralPulse
                )

                ForEach(0..<focusLineCount, id: \.self) { index in
                    let spread = CGFloat(index) - CGFloat(max(1, focusLineCount - 1)) / 2
                    let yOffset = spread * irisHeight * (0.126 + CGFloat(index % 2) * 0.010)
                    let lineOpacity = (0.060 + Double(index.isMultiple(of: 2) ? 0.022 : 0.0)) * activeSignalOpacity

                    focusLinePath(
                        center: center,
                        focusFieldWidth: focusFieldWidth,
                        irisWidth: irisWidth,
                        irisHeight: irisHeight,
                        yOffset: yOffset,
                        side: .left,
                        index: index,
                        pulse: structuralPulse,
                        focusPull: focusPull
                    )
                    .stroke(
                        index.isMultiple(of: 3)
                            ? signalAccent.opacity(max(0.035, lineOpacity * 0.76))
                            : ZD.Color.premium.opacity(max(0.040, lineOpacity)),
                        style: StrokeStyle(lineWidth: index.isMultiple(of: 2) ? 0.72 : 0.52, lineCap: .round, lineJoin: .round)
                    )
                    .blur(radius: index.isMultiple(of: 2) ? 0.12 : 0)

                    focusLinePath(
                        center: center,
                        focusFieldWidth: focusFieldWidth,
                        irisWidth: irisWidth,
                        irisHeight: irisHeight,
                        yOffset: yOffset,
                        side: .right,
                        index: index,
                        pulse: structuralPulse,
                        focusPull: focusPull
                    )
                    .stroke(
                        index.isMultiple(of: 3)
                            ? signalAccent.opacity(max(0.035, lineOpacity * 0.76))
                            : ZD.Color.premium.opacity(max(0.040, lineOpacity)),
                        style: StrokeStyle(lineWidth: index.isMultiple(of: 2) ? 0.72 : 0.52, lineCap: .round, lineJoin: .round)
                    )
                    .blur(radius: index.isMultiple(of: 2) ? 0.12 : 0)
                }

                Ellipse()
                    .stroke(ZD.Color.premium.opacity((0.28 + structuralPulse * 0.07) * irisOpacity), lineWidth: 7.0)
                    .frame(width: irisWidth * 1.02, height: irisHeight * 1.07)
                    .position(center)
                    .blur(radius: 8)

                sideCausticGlow(
                    center: CGPoint(x: center.x - irisWidth * 0.48, y: center.y),
                    size: irisHeight,
                    opacity: activeSignalOpacity,
                    pulse: structuralPulse
                )

                sideCausticGlow(
                    center: CGPoint(x: center.x + irisWidth * 0.48, y: center.y),
                    size: irisHeight,
                    opacity: activeSignalOpacity,
                    pulse: structuralPulse
                )

                ForEach(0..<4, id: \.self) { index in
                    let arcOpacity = (0.20 + Double(index.isMultiple(of: 2) ? 0.09 : 0.0) + structuralPulse * 0.05) * irisOpacity
                    let arcWidth = irisWidth * (0.96 - CGFloat(index) * 0.012 - focusPull * 0.010)
                    let arcHeight = irisHeight * (1.02 - CGFloat(index) * 0.018 - focusPull * 0.010)

                    Ellipse()
                        .trim(
                            from: index.isMultiple(of: 2) ? 0.035 : 0.545,
                            to: index.isMultiple(of: 2) ? 0.455 : 0.955
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ZD.Color.premium.opacity(arcOpacity * 0.45),
                                    ZD.Color.premium.opacity(arcOpacity),
                                    signalAccent.opacity(arcOpacity * 0.42),
                                    ZD.Color.premium.opacity(arcOpacity * 0.72)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: (1.0 + irisStrokeBoost * 0.38) - CGFloat(index) * 0.10, lineCap: .round)
                        )
                        .frame(width: arcWidth, height: arcHeight)
                        .rotationEffect(.degrees(Double(index) * 2.0 - 3.0))
                        .position(center)
                        .shadow(color: ZD.Color.premium.opacity((0.07 + structuralPulse * 0.04) * irisOpacity), radius: 10 + structuralPulse * 3)
                }

                ForEach(0..<irisRingCount, id: \.self) { index in
                    let depth = CGFloat(index) / CGFloat(max(1, irisRingCount - 1))
                    let organicShift = CGFloat(sin(Double(index) * 1.37 + preview.signature.nodeDrift)) * 0.015
                    let ringWidth = irisWidth * (0.74 - depth * 0.48 + organicShift - focusPull * 0.007)
                    let ringHeight = irisHeight * (0.92 - depth * 0.56 - organicShift * 0.7 - focusPull * 0.006)
                    let ringOpacity = (0.044 + Double(irisRingCount - index) * 0.009 + irisStrokeBoost * 0.026 + structuralPulse * 0.020) * irisOpacity
                    let ringLineWidth = (index == 0 ? 0.80 : 0.42 + CGFloat(index % 3) * 0.12) + irisStrokeBoost * 0.24

                    Ellipse()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    ZD.Color.premium.opacity(ringOpacity),
                                    signalAccent.opacity(max(0.028, ringOpacity * 0.54)),
                                    Color.white.opacity(max(0.020, ringOpacity * 0.34)),
                                    ZD.Color.premium.opacity(ringOpacity)
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .frame(width: ringWidth, height: ringHeight)
                        .position(
                            x: center.x + CGFloat(cos(Double(index) * 1.1)) * irisWidth * 0.0025,
                            y: center.y + CGFloat(sin(Double(index) * 1.6)) * irisHeight * 0.004
                        )
                        .blur(radius: index == irisRingCount - 1 ? 0.20 : 0)
                }

                ForEach(0..<irisFiberCount, id: \.self) { index in
                    irisFiberPath(
                        center: center,
                        radiusX: irisWidth * 0.36,
                        radiusY: irisHeight * 0.46,
                        index: index,
                        total: irisFiberCount,
                        pulse: structuralPulse,
                        focusPull: focusPull
                    )
                    .stroke(
                        index.isMultiple(of: 5)
                            ? signalAccent.opacity(0.044 * signatureOpacity)
                            : ZD.Color.premium.opacity(0.056 * signatureOpacity),
                        style: StrokeStyle(lineWidth: index.isMultiple(of: 4) ? 0.52 : 0.34, lineCap: .round)
                    )
                    .blur(radius: index.isMultiple(of: 6) ? 0.18 : 0)
                }

                ForEach(0..<signalParticleCount, id: \.self) { index in
                    let particle = signalParticle(
                        center: center,
                        focusFieldWidth: focusFieldWidth,
                        irisWidth: irisWidth,
                        irisHeight: irisHeight,
                        index: index
                    )

                    Circle()
                        .fill(particle.isGreen ? signalAccent.opacity(0.34 * signatureOpacity) : ZD.Color.premium.opacity(0.38 * signatureOpacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.point)
                        .blur(radius: particle.blur)
                        .shadow(color: (particle.isGreen ? signalAccent : ZD.Color.premium).opacity(0.13 * signatureOpacity), radius: 4)
                }

                ForEach(0..<apertureLineCount, id: \.self) { index in
                    apertureLinePath(
                        center: center,
                        radiusX: irisWidth * 0.28,
                        radiusY: irisHeight * 0.35,
                        index: index,
                        total: apertureLineCount,
                        pulse: structuralPulse + Double(focusPull) * 0.18
                    )
                    .stroke(
                        index.isMultiple(of: 4)
                            ? signalAccent.opacity(0.045 * activeSignalOpacity)
                            : ZD.Color.premium.opacity(0.066 * activeSignalOpacity),
                        style: StrokeStyle(lineWidth: 0.48, lineCap: .round)
                    )
                }

                if apertureBladeCount > 0 {
                    ForEach(0..<apertureBladeCount, id: \.self) { index in
                        apertureBladePath(
                            center: center,
                            radiusX: irisWidth * 0.24,
                            radiusY: irisHeight * 0.31,
                            index: index,
                            total: apertureBladeCount,
                            pulse: structuralPulse
                        )
                        .fill(ZD.Color.premium.opacity(0.024 * activeSignalOpacity))
                        .overlay {
                            apertureBladePath(
                                center: center,
                                radiusX: irisWidth * 0.24,
                                radiusY: irisHeight * 0.31,
                                index: index,
                                total: apertureBladeCount,
                                pulse: structuralPulse
                            )
                            .stroke(ZD.Color.premium.opacity(0.052 * activeSignalOpacity), lineWidth: 0.55)
                        }
                    }
                }

                if evolutionTrace > 0.001 {
                    Ellipse()
                        .trim(from: 0, to: evolutionTrace)
                        .stroke(
                            ZD.Color.premium.opacity(0.36 + evolutionGlow * 0.24),
                            style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                        )
                        .frame(width: irisWidth * 0.48, height: irisHeight * 0.58)
                        .position(center)
                        .shadow(color: ZD.Color.premium.opacity(0.13 + evolutionGlow * 0.12), radius: 8)

                    focusLinePath(
                        center: center,
                        focusFieldWidth: focusFieldWidth,
                        irisWidth: irisWidth,
                        irisHeight: irisHeight,
                        yOffset: 0,
                        side: .left,
                        index: 99,
                        pulse: structuralPulse,
                        focusPull: focusPull
                    )
                    .trim(from: 0, to: evolutionTrace)
                    .stroke(
                        ZD.Color.success.opacity(0.18 + evolutionGlow * 0.18),
                        style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round)
                    )
                }

                pupilAssembly(
                    size: size,
                    irisOpacity: irisOpacity,
                    evolutionGlow: evolutionGlow,
                    focusPull: focusPull,
                    accent: signalAccent,
                    centerOpacity: preview.state == .empty ? 0.48 : 1
                )
                .position(center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(reduceMotion ? 1 : 1 + (displayPulse * 0.008) - focusPull * 0.010, anchor: .center)
            .opacity(reduceMotion ? 1 : 0.985 + min(displayPulse, 0.8) * 0.015)
            .overlay(alignment: .top) {
                if let evolutionStatusLabel {
                    Text(evolutionStatusLabel)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(ZD.Color.accent.opacity(0.92))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(ZD.Color.card.opacity(0.64))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                                )
                        )
                        .shadow(color: ZD.Color.accent.opacity(0.10), radius: 8, x: 0, y: 4)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        .accessibilityHidden(true)
                }
            }
        }
        .onAppear {
            startIdleAnimationIfNeeded()
        }
        .onDisappear {
            stopIdleAnimation()
        }
        .onChange(of: reduceMotion) { _, newValue in
            if newValue {
                stopIdleAnimation()
            } else {
                startIdleAnimationIfNeeded()
            }
        }
        .onChange(of: isIdleActive) { _, isActive in
            if isActive {
                startIdleAnimationIfNeeded()
            } else {
                stopIdleAnimation()
            }
        }
        .onChange(of: evolutionID) { _, newValue in
            guard newValue != nil else { return }
            playEvolutionMoment()
        }
        .allowsHitTesting(false)
    }

    private func pupilAssembly(
        size: CGFloat,
        irisOpacity: Double,
        evolutionGlow: Double,
        focusPull: CGFloat,
        accent: Color,
        centerOpacity: Double
    ) -> some View {
        let glow = evolutionGlow + Double(focusPull) * 0.20

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.premium.opacity((0.26 + glow * 0.18) * irisOpacity),
                            accent.opacity((0.10 + glow * 0.06) * irisOpacity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: size * (0.24 + glow * 0.02)
                    )
                )
                .frame(width: 76 + glow * 12, height: 76 + glow * 12)
                .blur(radius: 3)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.92),
                            ZD.Color.forest.opacity(0.78),
                            ZD.Color.premium.opacity(0.18)
                        ],
                        center: .center,
                        startRadius: 2,
                            endRadius: 24 + glow * 3
                        )
                    )
                .frame(width: 43 + glow * 6, height: 43 + glow * 6)
                .shadow(color: Color.black.opacity(0.34), radius: 8, x: 0, y: 2)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            ZD.Color.premium.opacity(0.60 * irisOpacity),
                            Color.white.opacity(0.22 * irisOpacity),
                            accent.opacity(0.22 * irisOpacity),
                            ZD.Color.premium.opacity(0.60 * irisOpacity)
                        ],
                        center: .center
                    ),
                    lineWidth: 1.15
                )
                .frame(width: 39 + glow * 5, height: 39 + glow * 5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            ZD.Color.premium.opacity(0.58 + glow * 0.16),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0.5,
                        endRadius: 10 + glow * 2
                    )
                )
                .frame(width: 19 + glow * 3, height: 19 + glow * 3)
                .offset(x: -2.0, y: -1.4)

            Circle()
                .fill(Color.white.opacity(0.84))
                .frame(width: 5.2 + glow, height: 5.2 + glow)
                .offset(x: -6.0, y: -6.0)
        }
        .opacity(centerOpacity)
    }

    private func signalQuadrantGlow(
        center: CGPoint,
        size: CGFloat,
        accent: Color,
        opacity: Double,
        pulse: Double
    ) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        accent.opacity((0.12 + pulse * 0.04) * opacity),
                        ZD.Color.premium.opacity(0.035 * opacity),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 1,
                    endRadius: size * 0.74
                )
            )
            .frame(width: size * 1.28, height: size * 0.82)
            .position(center)
            .blur(radius: 7)
            .allowsHitTesting(false)
    }

    private func sideCausticGlow(
        center: CGPoint,
        size: CGFloat,
        opacity: Double,
        pulse: Double
    ) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.premium.opacity((0.34 + pulse * 0.10) * opacity),
                            ZD.Color.success.opacity((0.14 + pulse * 0.05) * opacity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size * 1.34, height: size * 1.34)
                .blur(radius: 4)

            Circle()
                .fill(ZD.Color.premium.opacity(0.42 * opacity))
                .frame(width: 4.4, height: 4.4)
                .shadow(color: ZD.Color.premium.opacity(0.34 * opacity), radius: 7)
        }
        .position(center)
    }

    private func signalParticle(
        center: CGPoint,
        focusFieldWidth: CGFloat,
        irisWidth: CGFloat,
        irisHeight: CGFloat,
        index: Int
    ) -> (point: CGPoint, size: CGFloat, blur: CGFloat, isGreen: Bool) {
        let side: CGFloat = index.isMultiple(of: 2) ? -1 : 1
        let localIndex = CGFloat(index / 2)
        let phase = Double(index) * 1.618 + preview.signature.nodeDrift * 3.0
        let t = 0.18 + CGFloat((sin(phase) + 1) * 0.5) * 0.74
        let edgeX = center.x + side * focusFieldWidth * (0.50 - t * 0.22)
        let causticX = center.x + side * irisWidth * 0.46
        let x = causticX + (edgeX - causticX) * t
        let ySpread = irisHeight * (0.18 + CGFloat(index % 5) * 0.055)
        let y = center.y
            + CGFloat(sin(phase * 1.7)) * ySpread
            + (localIndex.truncatingRemainder(dividingBy: 3) - 1) * irisHeight * 0.035
        let size = CGFloat(index % 3 == 0 ? 2.2 : 1.45)
        let blur = CGFloat(index % 4 == 0 ? 0.2 : 0)

        return (
            point: CGPoint(x: x, y: y),
            size: size,
            blur: blur,
            isGreen: index % 3 == 1
        )
    }

    private func irisFiberPath(
        center: CGPoint,
        radiusX: CGFloat,
        radiusY: CGFloat,
        index: Int,
        total: Int,
        pulse: Double,
        focusPull: CGFloat
    ) -> Path {
        var path = Path()
        let progress = Double(index) / Double(max(1, total))
        let angle = progress * Double.pi * 2
        let twist = sin(Double(index) * 1.71 + preview.signature.nodeDrift * 4.0) * 0.10
        let inner = 0.22 + CGFloat(index % 4) * 0.010 + focusPull * 0.010
        let outer = 0.88 - CGFloat(index % 5) * 0.018 - focusPull * 0.012
        let startAngle = angle + twist * 0.32
        let endAngle = angle + twist + pulse * 0.016
        let start = CGPoint(
            x: center.x + CGFloat(cos(startAngle)) * radiusX * inner,
            y: center.y + CGFloat(sin(startAngle)) * radiusY * inner
        )
        let end = CGPoint(
            x: center.x + CGFloat(cos(endAngle)) * radiusX * outer,
            y: center.y + CGFloat(sin(endAngle)) * radiusY * outer
        )
        let control = CGPoint(
            x: center.x + CGFloat(cos((startAngle + endAngle) * 0.5 + twist)) * radiusX * 0.58,
            y: center.y + CGFloat(sin((startAngle + endAngle) * 0.5 + twist)) * radiusY * 0.52
        )

        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }

    private func startIdleAnimationIfNeeded() {
        guard !reduceMotion, isIdleActive else {
            stopIdleAnimation()
            return
        }

        scheduleFocusAdjustment()
    }

    private func stopIdleAnimation() {
        focusTask?.cancel()
        focusTask = nil
        focusAdjustment = 0
    }

    private func scheduleFocusAdjustment() {
        focusTask?.cancel()
        guard !reduceMotion else { return }

        let delay = 12.0 + Double(preview.signature.seed % 8)
        let delayNanoseconds = UInt64(delay * 1_000_000_000)
        focusTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            guard !Task.isCancelled, !reduceMotion else { return }

            withAnimation(.easeInOut(duration: 1.2)) {
                focusAdjustment = 1
            }

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard !Task.isCancelled, !reduceMotion else { return }

            withAnimation(.easeInOut(duration: 1.8)) {
                focusAdjustment = 0
            }

            guard !Task.isCancelled else { return }
            scheduleFocusAdjustment()
        }
    }

    private func playEvolutionMoment() {
        evolutionTrace = 0
        evolutionGlow = 0
        saveFocusLock = 0

        if reduceMotion {
            evolutionTrace = 1
            evolutionGlow = 0.32
            saveFocusLock = 0.42

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                evolutionTrace = 0
                evolutionGlow = 0
                saveFocusLock = 0
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.24)) {
            saveFocusLock = 0.86
            evolutionGlow = 0.22
        }

        withAnimation(.easeInOut(duration: 1.45)) {
            evolutionTrace = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.interpolatingSpring(stiffness: 220, damping: 21)) {
                saveFocusLock = 0.18
                evolutionGlow = 0.52
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) {
            withAnimation(.easeInOut(duration: 0.70)) {
                saveFocusLock = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) {
            withAnimation(.easeInOut(duration: 1.0)) {
                evolutionGlow = 0
                evolutionTrace = 0
                saveFocusLock = 0
            }
        }
    }

    private func focusLinePath(
        center: CGPoint,
        focusFieldWidth: CGFloat,
        irisWidth: CGFloat,
        irisHeight: CGFloat,
        yOffset: CGFloat,
        side: IrisSide,
        index: Int,
        pulse: Double,
        focusPull: CGFloat
    ) -> Path {
        var path = Path()
        let direction = side == .left ? -1.0 : 1.0
        let edgeX = center.x + CGFloat(direction) * focusFieldWidth * 0.50
        let innerX = center.x + CGFloat(direction) * irisWidth * (0.42 - focusPull * 0.010)
        let edgeY = center.y + yOffset * 1.46
        let innerY = center.y + yOffset * (0.05 - focusPull * 0.012)
        let wave = CGFloat(sin(Double(index) * 0.72 + preview.signature.nodeDrift * 2.2)) * irisHeight * 0.030
        let firstControlX = center.x + CGFloat(direction) * focusFieldWidth * 0.34
        let firstControlY = center.y + yOffset * 1.08 + wave
        let secondControlX = center.x + CGFloat(direction) * irisWidth * (0.56 - focusPull * 0.018)
        let secondControlY = center.y + yOffset * 0.26 + wave * 0.40 + CGFloat(pulse) * 1.2

        path.move(to: CGPoint(x: edgeX, y: edgeY))
        path.addCurve(
            to: CGPoint(x: innerX, y: innerY),
            control1: CGPoint(x: firstControlX, y: firstControlY),
            control2: CGPoint(x: secondControlX, y: secondControlY)
        )

        return path
    }

    private func apertureLinePath(
        center: CGPoint,
        radiusX: CGFloat,
        radiusY: CGFloat,
        index: Int,
        total: Int,
        pulse: Double
    ) -> Path {
        var path = Path()
        let angle = (Double(index) / Double(max(1, total))) * Double.pi * 2
        let inner = 0.42 + pulse * 0.015
        let outer = 0.80 + pulse * 0.018
        let start = CGPoint(
            x: center.x + CGFloat(cos(angle)) * radiusX * inner,
            y: center.y + CGFloat(sin(angle)) * radiusY * inner
        )
        let end = CGPoint(
            x: center.x + CGFloat(cos(angle)) * radiusX * outer,
            y: center.y + CGFloat(sin(angle)) * radiusY * outer
        )

        path.move(to: start)
        path.addLine(to: end)
        return path
    }

    private func apertureBladePath(
        center: CGPoint,
        radiusX: CGFloat,
        radiusY: CGFloat,
        index: Int,
        total: Int,
        pulse: Double
    ) -> Path {
        var path = Path()
        let angle = (Double(index) / Double(max(1, total))) * Double.pi * 2
        let nextAngle = angle + Double.pi * 2 / Double(max(1, total)) * 0.52
        let inner = 0.44 + pulse * 0.018
        let outer = 0.92 + pulse * 0.018
        let p1 = CGPoint(
            x: center.x + CGFloat(cos(angle)) * radiusX * inner,
            y: center.y + CGFloat(sin(angle)) * radiusY * inner
        )
        let p2 = CGPoint(
            x: center.x + CGFloat(cos(angle + 0.10)) * radiusX * outer,
            y: center.y + CGFloat(sin(angle + 0.10)) * radiusY * outer
        )
        let p3 = CGPoint(
            x: center.x + CGFloat(cos(nextAngle)) * radiusX * inner,
            y: center.y + CGFloat(sin(nextAngle)) * radiusY * inner
        )

        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.closeSubpath()
        return path
    }
}

private enum IrisSide: Equatable {
    case left
    case right
}

private enum PatternIrisSignalBias {
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight

    func center(in origin: CGPoint, irisWidth: CGFloat, irisHeight: CGFloat) -> CGPoint {
        switch self {
        case .upperLeft:
            return CGPoint(x: origin.x - irisWidth * 0.16, y: origin.y - irisHeight * 0.18)
        case .upperRight:
            return CGPoint(x: origin.x + irisWidth * 0.16, y: origin.y - irisHeight * 0.18)
        case .lowerLeft:
            return CGPoint(x: origin.x - irisWidth * 0.16, y: origin.y + irisHeight * 0.18)
        case .lowerRight:
            return CGPoint(x: origin.x + irisWidth * 0.16, y: origin.y + irisHeight * 0.18)
        }
    }
}

private struct PatternIntelligenceMilestone: Equatable {
    let count: Int
    let title: String

    static let all: [PatternIntelligenceMilestone] = [
        PatternIntelligenceMilestone(count: 1, title: "First Observation"),
        PatternIntelligenceMilestone(count: 3, title: "Pattern Intelligence Preview"),
        PatternIntelligenceMilestone(count: 5, title: "Pattern Shifts"),
        PatternIntelligenceMilestone(count: 7, title: "Ask Pattern Intelligence"),
        PatternIntelligenceMilestone(count: 30, title: "Monthly Reflection"),
        PatternIntelligenceMilestone(count: 90, title: "Cosmic Weather")
    ]

    static func next(after savedLensCount: Int) -> PatternIntelligenceMilestone? {
        all.first { savedLensCount < $0.count }
    }
}

private struct PatternIntelligencePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    let savedLensCount: Int
    let preview: PatternIntelligencePreview
    let savedReads: [SavedDailyReading]
    let savedLensSourceKey: String
    let profileID: String

    @State private var currentAskAnswer: PatternIntelligenceAskAnswer? = nil
    @State private var loadingQuestionID: String? = nil
    @State private var askAnswerCache: [String: PatternIntelligenceAskAnswer] = [:]

    private var nextMilestone: PatternIntelligenceMilestone? {
        PatternIntelligenceMilestone.next(after: savedLensCount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZD.Color.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        memoryValueCard

                        if savedLensCount >= 3 {
                            earlyPatternPreviewCard
                        }

                        if savedLensCount >= 5 {
                            patternShiftCard
                        }

                        if savedLensCount >= 7 {
                            askPatternIntelligenceSection
                        }

                        nextUnlockCard

                        unlocksOverTimeCard

                        footerLine

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 24)
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
                }
            }
        }
        // TODO: Gate this destination with subscription entitlement checks when premium launches.
        // TODO: Add subscription entitlement so free users get one preview answer and premium users get all guided questions.
        // TODO: Move Monthly Reflection and Cosmic Weather behind the premium entitlement when billing exists.
        // TODO: Generate the Early Pattern summary with AI once the scoring corpus is strong enough.
        // TODO: Add trend analysis from saved Lens scores.
        // TODO: Add monthly reflection generation.
        // TODO: Add cosmic weather personalization from the user's saved Lens history.
        // TODO: At 7 saved Lenses, show "Pattern Intelligence unlocked."
        // TODO: Let the iris contract, align, and bloom subtly when the 7-Lens milestone is reached.
        // TODO: Let the artifact bloom subtly when later milestones are reached.
        // TODO: Evolve the ring and contour structure at milestones without confetti, coins, XP, or loud badge mechanics.
        .onChange(of: savedLensSourceKey) { _, _ in
            currentAskAnswer = nil
            loadingQuestionID = nil
            askAnswerCache.removeAll()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR PATTERN GROWS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))

            Text("Pattern Intelligence")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("The more you save, the more Zodian begins to understand what keeps returning.")
                .font(.system(size: 14, weight: .medium))
                .lineSpacing(4)
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var memoryValueCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(ZD.Color.accent.opacity(0.13))
                    )

                Text("Built from memory")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
            }

            Text("Built from \(savedLensCount) saved \(savedLensCount == 1 ? "Lens" : "Lenses").")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)

            if let memoryCallback = preview.memoryCallback {
                Text(memoryCallback)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineSpacing(3)
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.74),
                            ZD.Color.forest.opacity(0.62),
                            ZD.Color.card.opacity(0.52)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ZD.Color.premium.opacity(0.22),
                                    ZD.Color.success.opacity(0.12),
                                    ZD.Color.border.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var nextUnlockCard: some View {
        let remaining = nextMilestone.map { max(0, $0.count - savedLensCount) } ?? 0

        return VStack(alignment: .leading, spacing: 9) {
            Text(savedLensCount >= 7 ? "Current unlock" : "Next unlock")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.3)
                .textCase(.uppercase)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))

            if savedLensCount >= 7 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ask Pattern Intelligence")
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Your memory is ready. Ask guided questions about the patterns your saved Lenses are building.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.76))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else if let nextMilestone {
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text(nextMilestone.title)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Spacer(minLength: 8)

                    Text("\(remaining) \(remaining == 1 ? "Lens" : "Lenses") remaining")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.76))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            } else {
                Text("Your full Pattern ladder is open.")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.textPrimary.opacity(0.88))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.66),
                            ZD.Color.forest.opacity(0.54)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.premium.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var earlyPatternPreviewCard: some View {
        let narrative = preview.earlyPatternNarrative ?? "It isn’t tied to one day. It keeps resurfacing across different situations."
        let insight = preview.earlyInsight ?? "It's still early, but this is beginning to repeat."

        return VStack(alignment: .leading, spacing: 10) {
            Text("Early Pattern")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.3)
                .textCase(.uppercase)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))

            Text(insight)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(narrative)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.forest.opacity(0.62),
                            ZD.Color.card.opacity(0.62)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.success.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var patternShiftCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pattern Shift")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.3)
                .textCase(.uppercase)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))

            Text(preview.patternShift ?? "Your pattern is still forming.")
                .font(.system(size: 17, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(preview.patternShiftNarrative ?? "Looking across your recent saves, there’s a subtle change in direction.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.66),
                            ZD.Color.forest.opacity(0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.premium.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var askPatternIntelligenceSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("Ask Pattern Intelligence")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.3)
                .textCase(.uppercase)
                .foregroundStyle(ZD.Color.accent.opacity(0.86))

            if let currentAskAnswer {
                askAnswerCard(currentAskAnswer)
            } else {
                Text("Ask deeper questions about the patterns your saved Lenses are building.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(PatternIntelligenceAskQuestion.curated) { question in
                        Button {
                            openAskAnswer(for: question)
                        } label: {
                            HStack(spacing: 9) {
                                Circle()
                                    .fill(ZD.Color.success.opacity(0.72))
                                    .frame(width: 5, height: 5)

                                Text(question.title)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(ZD.Color.textPrimary.opacity(0.88))
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 8)

                                if loadingQuestionID == question.id {
                                    ProgressView()
                                        .controlSize(.mini)
                                        .tint(ZD.Color.accent)
                                        .accessibilityHidden(true)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(ZD.Color.accent.opacity(0.72))
                                }
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(Color.white.opacity(0.045))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                                            .stroke(ZD.Color.border.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(loadingQuestionID != nil)
                        .accessibilityLabel(question.title)
                    }

                    if loadingQuestionID != nil {
                        Text("Reading your saved Lenses…")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                            .accessibilityLabel("Reading your saved Lenses")
                    }
                }
                .accessibilityElement(children: .contain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.forest.opacity(0.66),
                            ZD.Color.card.opacity(0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.success.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func askAnswerCard(_ answer: PatternIntelligenceAskAnswer) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Button {
                currentAskAnswer = nil
            } label: {
                Label("Questions", systemImage: "chevron.left")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.accent)
            }
            .buttonStyle(.plain)

            Text(answer.question.title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(answer.text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineSpacing(4)
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)

            Text(answer.sourceLine)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.62))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(ZD.Color.success.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func openAskAnswer(for question: PatternIntelligenceAskQuestion) {
        let cacheKey = askAnswerCacheKey(for: question)

        if let cachedAnswer = askAnswerCache[cacheKey] {
            currentAskAnswer = cachedAnswer
            return
        }

        loadingQuestionID = question.id

        Task {
            if let cachedAnswer = await PatternIntelligenceAskAnswerCacheStore.shared.answer(for: cacheKey) {
                await MainActor.run {
                    askAnswerCache[cacheKey] = cachedAnswer
                    currentAskAnswer = cachedAnswer
                    loadingQuestionID = nil
                }
                return
            }

            let answer = await makeAskAnswer(for: question, cacheKey: cacheKey)
            try? await Task.sleep(nanoseconds: 220_000_000)
            await PatternIntelligenceAskAnswerCacheStore.shared.store(answer, for: cacheKey)

            await MainActor.run {
                askAnswerCache[cacheKey] = answer
                currentAskAnswer = answer
                loadingQuestionID = nil
            }
        }
    }

    private func makeAskAnswer(
        for question: PatternIntelligenceAskQuestion,
        cacheKey: String
    ) async -> PatternIntelligenceAskAnswer {
        guard savedLensCount >= 7, savedReads.count >= 7 else {
            return PatternIntelligenceAskAnswer(
                question: question,
                text: "There isn’t enough history for a strong answer yet. Save a few more Lenses and try again.",
                sourceLine: "Drawn from your saved Lenses.",
                cacheKey: cacheKey
            )
        }

        let answerFacts = PatternIntelligenceAnswerFacts.make(
            questionID: question.id,
            questionText: question.title,
            preview: preview,
            savedReads: savedReads
        )
        let answerReasoning = PatternIntelligenceAnswerReasoning.make(from: answerFacts)
        // TODO: Surface answerReasoning.personalizedQuestionSeeds as guided follow-up chips after static v0 questions stabilize.
        let request = PatternIntelligenceGenerationRequest(
            task: .suggestedQuestionAnswerDraft(question: question.title),
            preview: preview,
            savedReads: savedReads,
            answerFacts: answerFacts,
            answerReasoning: answerReasoning
        )
        // Apple Foundation Models is first here because this is private, lightweight language synthesis over deterministic facts.
        let generated = await PatternIntelligenceGenerationService.shared.generate(
            request,
            preferredProviders: [.appleFoundationModels, .backendAI, .fallback]
        )

        return PatternIntelligenceAskAnswer(
            question: question,
            text: displaySafeAskAnswer(generated.text, for: question),
            sourceLine: "Drawn from your saved Lenses.",
            cacheKey: cacheKey
        )
    }

    private func displaySafeAskAnswer(
        _ text: String,
        for question: PatternIntelligenceAskQuestion
    ) -> String {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        guard !normalized.isEmpty else {
            return deterministicAskFallback(for: question)
        }

        let lowercase = normalized.lowercased()
        let blockedFragments = [
            "you always",
            "diagnos",
            "therapy",
            "raw_",
            "sentinel",
            "question id",
            "question_id",
            "primaryrecurringsignal",
            "primary recurring signal",
            "recurring count",
            "saved lens count",
            "%"
        ]

        if blockedFragments.contains(where: { lowercase.contains($0) }) {
            return deterministicAskFallback(for: question)
        }

        if normalized.count <= 260 {
            return normalized
        }

        let prefix = String(normalized.prefix(260))
        if let sentenceEnd = prefix.lastIndex(where: { ".!?".contains($0) }) {
            return String(prefix[...sentenceEnd])
        }

        return "\(prefix.trimmingCharacters(in: .whitespacesAndNewlines))..."
    }

    private func deterministicAskFallback(for question: PatternIntelligenceAskQuestion) -> String {
        let facts = PatternIntelligenceAnswerFacts.make(
            questionID: question.id,
            questionText: question.title,
            preview: preview,
            savedReads: savedReads
        )
        let reasoning = PatternIntelligenceAnswerReasoning.make(from: facts)
        let signalFragment = facts.primaryRecurringSignal ?? preview.topSignal?.lowercased() ?? "your saved Lenses"
        let signalSubject = displaySubjectPhrase(for: signalFragment)

        switch question.id {
        case "why-repeat":
            return "What keeps returning is this: \(withoutTerminalPunctuation(reasoning.primaryObservation)). \(withoutTerminalPunctuation(reasoning.supportingEvidence)). \(reasoning.possibleInterpretation)"
        case "week-change":
            if let earlier = facts.earlierDominantSignal,
               let recent = facts.recentDominantSignal,
               earlier.caseInsensitiveCompare(recent) != .orderedSame {
                return "Earlier Lenses leaned toward \(displaySubjectPhrase(for: earlier)); recent ones point more toward \(displaySubjectPhrase(for: recent)). That gives your pattern a different shape this week."
            }

            return "This week, \(signalSubject) became easier to see. \(withoutTerminalPunctuation(reasoning.supportingEvidence)). \(reasoning.possibleInterpretation)"
        case "tomorrow-watch":
            return "Watch for \(reasoning.recommendedWatch). That is where this pattern becomes easiest to notice tomorrow."
        case "surprise":
            return "The surprising part is \(withoutTerminalPunctuation(reasoning.surprisingContrast)). That pairing gives the pattern more depth than a single theme would."
        case "overlooking":
            return "You may be focused on the choice itself, but the easier-to-miss part is \(reasoning.blindSpot). \(reasoning.possibleInterpretation)"
        case "today-fit":
            return "Today fits because \(withoutTerminalPunctuation(reasoning.todayConnection)). It looks like another angle on the pattern your saved Lenses have already been building."
        default:
            return "Your saved Lenses suggest \(signalSubject) is one of the clearer threads in the pattern so far."
        }
    }

    private func askAnswerCacheKey(for question: PatternIntelligenceAskQuestion) -> String {
        [PatternIntelligenceAskAnswerCacheStore.cacheVersion, profileID, question.id, savedLensSourceKey].joined(separator: "|")
    }

    private func withoutTerminalPunctuation(_ value: String) -> String {
        value.trimmingCharacters(in: CharacterSet(charactersIn: ".!?").union(.whitespacesAndNewlines))
    }

    private func displaySubjectPhrase(for fragment: String) -> String {
        switch fragment.lowercased() {
        case "questions", "ask questions":
            return "pausing before action"
        case "trust", "trust instincts":
            return "trusting yourself"
        case "confidence", "quiet confidence":
            return "quiet confidence"
        case "being seen":
            return "letting yourself be seen"
        case "growth", "choose growth":
            return "choosing growth"
        case "momentum", "build momentum":
            return "building momentum"
        default:
            return fragment
        }
    }

    private var unlocksOverTimeCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Unlock ladder")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(ZD.Color.accent.opacity(0.88))

            VStack(alignment: .leading, spacing: 11) {
                ForEach(PatternIntelligenceMilestone.all, id: \.title) { stage in
                    patternGrowthStageRow(stage)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.42))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.10), lineWidth: 1)
                )
            )
    }

    private func patternGrowthStageRow(_ stage: PatternIntelligenceMilestone) -> some View {
        let isUnlocked = savedLensCount >= stage.count
        let isNext = nextMilestone == stage

        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? ZD.Color.success.opacity(0.20) : (isNext ? ZD.Color.premium.opacity(0.16) : ZD.Color.card.opacity(0.52)))
                    .frame(width: 18, height: 18)

                Circle()
                    .fill(isUnlocked ? ZD.Color.success.opacity(0.84) : (isNext ? ZD.Color.premium.opacity(0.82) : ZD.Color.muted.opacity(0.58)))
                    .frame(width: 6, height: 6)
            }

            Text("\(stage.count) \(stage.count == 1 ? "Lens" : "Lenses")")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.0)
                .textCase(.uppercase)
                .foregroundStyle(isUnlocked || isNext ? ZD.Color.accent.opacity(0.88) : ZD.Color.muted.opacity(0.72))
                .frame(width: 70, alignment: .leading)

            Text(stage.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isUnlocked ? ZD.Color.textPrimary.opacity(0.88) : (isNext ? ZD.Color.textPrimary.opacity(0.82) : ZD.Color.textSecondary.opacity(0.60)))

            Spacer(minLength: 0)

            if isNext {
                Text("Next")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(ZD.Color.premium.opacity(0.78))
            }
        }
    }

    private var footerLine: some View {
        Text("Keep saving Lenses")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
            .accessibilityLabel("Keep saving Lenses")
    }

}

private struct PatternIntelligenceAskQuestion: Identifiable, Hashable {
    let id: String
    let title: String

    static let curated: [PatternIntelligenceAskQuestion] = [
        PatternIntelligenceAskQuestion(id: "why-repeat", title: "Why does this keep showing up?"),
        PatternIntelligenceAskQuestion(id: "week-change", title: "What changed this week?"),
        PatternIntelligenceAskQuestion(id: "tomorrow-watch", title: "What should I watch tomorrow?"),
        PatternIntelligenceAskQuestion(id: "surprise", title: "What surprised you about my pattern?"),
        PatternIntelligenceAskQuestion(id: "overlooking", title: "What am I overlooking?"),
        PatternIntelligenceAskQuestion(id: "today-fit", title: "How does today fit my recent pattern?")
    ]
}

private struct PatternIntelligenceAskAnswer: Equatable {
    let question: PatternIntelligenceAskQuestion
    let text: String
    let sourceLine: String
    let cacheKey: String
}

private actor PatternIntelligenceAskAnswerCacheStore {
    static let shared = PatternIntelligenceAskAnswerCacheStore()
    static let cacheVersion = "ask-pattern-intelligence-v1-copy-2026-07-07"

    private var answers: [String: PatternIntelligenceAskAnswer] = [:]

    func answer(for key: String) -> PatternIntelligenceAskAnswer? {
        answers[key]
    }

    func store(_ answer: PatternIntelligenceAskAnswer, for key: String) {
        answers[key] = answer
    }
}

private struct HomeHeaderContext {
    let profileID: String
    let completedDailyReadCount: Int
    let hasMeaningfulPatternMemoryReflection: Bool

    var phase: HomeHeaderPhase {
        if completedDailyReadCount >= 3 && hasMeaningfulPatternMemoryReflection {
            return .established
        }

        if completedDailyReadCount >= 3 {
            return .returning
        }

        return .discovery
    }
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

private enum HomeHeaderEngine {
    private static let discoveryLines = [
        "something is coming into focus",
        "today’s pattern is waiting",
        "today begins with a fresh perspective",
        "let’s see what’s becoming clearer"
    ]

    private static let returningLines = [
        "something deserves a second look",
        "something familiar is revealing more",
        "today’s pattern builds on yesterday",
        "something is asking for your attention again"
    ]

    private static let establishedLines = [
        "a familiar pattern is resurfacing",
        "something you’ve been noticing is becoming clearer"
    ]

    static func line(for context: HomeHeaderContext, date: Date) -> String {
        switch context.phase {
        case .discovery:
            return stableLine(from: discoveryLines, profileID: context.profileID, date: date)
        case .returning:
            return stableLine(from: returningLines, profileID: context.profileID, date: date)
        case .established:
            return stableLine(from: establishedLines, profileID: context.profileID, date: date)
        }
    }

    private static func stableLine(from lines: [String], profileID: String, date: Date) -> String {
        guard !lines.isEmpty else { return "something is coming into focus" }

        let day = Calendar(identifier: .gregorian).ordinality(of: .day, in: .year, for: date) ?? 1
        let seed = stableSeed(for: "\(profileID)-\(day)")
        return lines[seed % lines.count]
    }

    private static func stableSeed(for input: String) -> Int {
        input.unicodeScalars.reduce(0) { partial, scalar in
            ((partial * 31) + Int(scalar.value)) % 1_000_003
        }
    }
}

private struct PatternMemoryHomeDestinationView: View {
    let summary: PatternMemorySummary
    let reflection: PatternMemoryMonthlyReflection
    let hasAccess: Bool

    private var usefulLines: [String] {
        reflection.reflectionLines.filter { line in
            let normalized = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !normalized.isEmpty else { return false }

            return ![
                "nothing has repeated",
                "still gathering signal",
                "no clear",
                "not developed",
                "too varied",
                "no specific",
                "no identity",
                "no saved read",
                "no saved identity",
                "no saved profile",
                "has not become part",
                "not revisited",
                "more observational than conversational"
            ].contains { normalized.contains($0) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZD.Color.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        if hasAccess {
                            PatternMemorySectionView(
                                summary: summary,
                                reflection: reflection,
                                onSelectObservation: { _ in },
                                showsObservationActions: false
                            )
                        } else {
                            previewCard
                        }
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 24)
                    .padding(.bottom, 36)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PATTERN MEMORY")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(ZD.Color.accent.opacity(0.88))

            Text("See what keeps returning")
                .font(.system(size: 29, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("A reflection on what Zodian is beginning to recognize in what stays with you.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Preview memory")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(ZD.Color.muted)

            Text("What Zodian is beginning to notice")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Pattern Memory turns what you keep into a clearer picture of what matters.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if !usefulLines.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(usefulLines.prefix(2).enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(ZD.Color.accent.opacity(0.75))
                                .frame(width: 5, height: 5)
                                .padding(.top, 8)

                            Text(line)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(ZD.Color.textPrimary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.16), lineWidth: 1)
                )
        )
    }

}
