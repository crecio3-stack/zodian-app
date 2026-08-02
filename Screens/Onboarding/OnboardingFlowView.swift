import SwiftUI
import SwiftData
import UIKit

private enum OnboardingRevealTiming {
    static let compressionDuration: Double = 2.25
    static let suspensionDuration: Double = 1.7
    static let preRevealBloomDuration: Double = 0.82

    static let headerDelay: Double = 0.95
    static let comboDelay: Double = 0.68
    static let titleDelay: Double = 0.82
    static let taglineDelay: Double = 0.72
    static let overviewDelay: Double = 0.82
    static let actionDelay: Double = 1.05
    static let shareDelay: Double = 0.55
}

struct OnboardingFooterSentinelKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

struct OnboardingScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct OnboardingFlowView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var accountOwnership: AccountOwnershipController
    @Environment(\.modelContext) private var context
    @State private var mergingUIFadeOut = false
    @StateObject private var vm = OnboardingFlowViewModel()
    @StateObject private var birthplaceSearch = BirthplaceSearchService()
    @AppStorage("zodian.onboardingComplete") private var onboardingCompleteStorage = false

    private enum FlowStep: Int, CaseIterable {
        case welcome
        case western
        case refineBirthdate
        case eastern
        case merging
        case reveal
    }

    private enum MergingPhase {
        case form
        case loading
    }

    private enum BirthdateRevealPhase {
        case idle
        case selecting
        case revealed
    }
    @State private var flowStep: FlowStep = .welcome
    @State private var mergingPhase: MergingPhase = .form
    @State private var revealState = RevealAnimationState()
    @State private var westernRevealState = WesternRevealAnimationState()
    @State private var easternRevealState = EasternRevealAnimationState()
    @State private var mergingRevealState = MergingRevealAnimationState()
    @State private var birthdateRevealState: BirthdateRevealPhase = .idle
    @State private var birthdateRevealWorkItem: DispatchWorkItem?
    @State private var didMeaningfullySelectBirthdate = false
    @State private var westernRevealTask: Task<Void, Never>?
    @State private var easternRevealTask: Task<Void, Never>?
    @State private var mergeRevealTask: Task<Void, Never>?
    @State private var optionalRefinementExpanded = false
    @State private var westernRevealActive = false
    @State private var easternRevealActive = false
    @State private var westernSelectedSign: WesternZodiac?
    @State private var hasInteractedWithWesternSelector = false
    @State private var westernWheelCTAFlash = false
    @State private var westernWheelMessageVisible = false
    @State private var westernFooterRevealProgress: CGFloat = 0
    @State private var easternFooterRevealProgress: CGFloat = 0
    @State private var mergingFooterRevealProgress: CGFloat = 0
    @State private var westernScrollOffset: CGFloat = 0
    @State private var easternScrollOffset: CGFloat = 0
    @State private var mergingScrollOffset: CGFloat = 0
    @State private var revealPhase: RevealPhase = .idle
    @State private var revealPhaseTask: Task<Void, Never>?
    @State private var revealSequenceTask: Task<Void, Never>?

    @State private var ritualGlow = false
    @State private var ritualBandPulse = false
    @State private var lastBirthdaySelection = Date.distantPast

    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardWillShowObserver: NSObjectProtocol?
    @State private var keyboardWillHideObserver: NSObjectProtocol?
    @State private var pageDragOffset: CGFloat = 0
    @State private var isCompletingBackSwipe = false

    @State private var sharePayload: SharePayload?
    @FocusState private var focusedField: OnboardingField?

    enum OnboardingField {
        case name
        case birthplace
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer

                if let previousStep = previousFlowStep,
                   backSwipeIsEnabled,
                   pageDragOffset > 0 || isCompletingBackSwipe {
                    stepView(for: previousStep)
                        .offset(x: previousStepOffset(for: geometry.size.width))
                        .opacity(previousStepOpacity)
                        .allowsHitTesting(false)
                }

                ZStack(alignment: .leading) {
                    stepView(for: flowStep)
                        .offset(x: pageDragOffset)
                        .shadow(
                            color: Color.black.opacity(pageDragOffset > 0 ? 0.18 : 0.0),
                            radius: pageDragOffset > 0 ? 18 : 0,
                            y: 8
                        )
                        .contentShape(Rectangle())

                    Color.clear
                        .frame(width: 20)
                        .contentShape(Rectangle())
                        .gesture(backSwipeGesture(screenWidth: geometry.size.width))
                }

                if flowStep == .reveal, let errorMessage = vm.errorMessage {
                    ownershipErrorCard(message: errorMessage)
                        .padding(.horizontal, ZD.Spacing.m)
                        .padding(.bottom, ZD.Spacing.l)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: flowStep)
        .preferredColorScheme(.dark)
        .onAppear {
            lastBirthdaySelection = vm.birthday
            startRitualAmbientAnimation()
            birthplaceSearch.query = vm.birthPlaceNormalized ?? vm.birthPlaceRaw
            registerForKeyboardNotifications()
        }
        .onDisappear {
            unregisterForKeyboardNotifications()
        }
        .onChange(of: vm.birthday) { _, newValue in

            focusedField = nil

            guard !Calendar.current.isDate(newValue, inSameDayAs: lastBirthdaySelection) else { return }

            lastBirthdaySelection = newValue
            didMeaningfullySelectBirthdate = true

            feedbackRitualTick()

            pulseRitualBand()
            handleBirthdateSelectionChange()

        }
        .onChange(of: flowStep) { _, _ in
            focusedField = nil
            pageDragOffset = 0
            isCompletingBackSwipe = false

            if flowStep != .western {
                resetWesternRevealState()
            }
            if flowStep != .eastern {
                resetEasternRevealState()
            }
            if flowStep != .merging || mergingPhase != .form {
                resetMergingRevealState()
            }
            birthdateRevealWorkItem?.cancel()
        }

        .onChange(of: birthplaceSearch.query) { _, newValue in
            guard flowStep == .merging, mergingPhase == .form else { return }
            vm.updateBirthplaceRaw(newValue)
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(activityItems: payload.activityItems)
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        Group {
            if flowStep == .welcome {
                ZD.Color.bg
                    .ignoresSafeArea()
            } else {
                OnboardingAmbientBackground(style: .subtle)
                    .offset(y: backgroundParallaxOffset)
                    .scaleEffect(1.015)
                    .animation(.easeOut(duration: 0.22), value: backgroundParallaxOffset)
            }
        }
    }

    private var activeScrollOffset: CGFloat {
        switch flowStep {
        case .western:
            return westernScrollOffset
        case .refineBirthdate:
            return 0
        case .eastern:
            return easternScrollOffset
        case .merging:
            return mergingScrollOffset
        case .welcome, .reveal:
            return 0
        }
    }

    private var backgroundParallaxOffset: CGFloat {
        let limited = max(min(activeScrollOffset, 180), -220)
        return limited * 0.05
    }

    private var currentWesternSign: WesternZodiac {
        AstrologyCalculator.westernZodiac(from: vm.birthday)
    }

    private var currentWesternSignName: String {
        currentWesternSign.displayName
    }

    private var currentEasternSign: ChineseZodiac {
        AstrologyCalculator.chineseZodiac(from: vm.birthday)
    }

    private var currentEasternSignName: String {
        currentEasternSign.displayName
    }

    private var currentBirthYear: Int {
        Calendar.current.component(.year, from: vm.birthday)
    }

    private var currentBirthYearText: String {
        String(currentBirthYear)
    }



    private var previousFlowStep: FlowStep? {
        guard mergingPhase != .loading else { return nil }

        switch flowStep {
        case .welcome:
            return nil
        case .western:
            return .welcome
        case .refineBirthdate:
            return .western
        case .eastern:
            return .refineBirthdate
        case .merging:
            return .eastern
        case .reveal:
            return .merging
        }
    }

    private var backSwipeIsEnabled: Bool {
        previousFlowStep != nil && focusedField == nil && !isCompletingBackSwipe
    }

    private var previousStepOpacity: Double {
        let progress = min(max(pageDragOffset / 220, 0), 1)
        return 0.82 + (0.18 * progress)
    }

    private func footerRevealProgress(sentinelMinY: CGFloat, viewportHeight: CGFloat) -> CGFloat {
        guard sentinelMinY.isFinite, viewportHeight > 0 else { return 0 }

        let dockRevealLine = viewportHeight - OnboardingHeroMetrics.footerReservedHeight + 8
        let distanceFromRevealLine = sentinelMinY - dockRevealLine
        let fullRevealDistance: CGFloat = -12
        let hiddenDistance: CGFloat = 64
        let progress = 1 - ((distanceFromRevealLine - fullRevealDistance) / (hiddenDistance - fullRevealDistance))
        return min(max(progress, 0), 1)
    }

    private func parallaxShift(from scrollOffset: CGFloat) -> CGFloat {
        let limited = max(min(scrollOffset, 180), -220)
        return limited * 0.16
    }


    private var westernStepSupportingText: String {
        "Western astrology uses the month and day you were born"
    }

    private var westernAdjacentContextText: String {
        let sign = currentWesternSign
        let allSigns = WesternZodiac.allCases

        guard let index = allSigns.firstIndex(of: sign) else {
            return sign.dateRangeText
        }

        let previousSign = allSigns[(index - 1 + allSigns.count) % allSigns.count]
        let nextSign = allSigns[(index + 1) % allSigns.count]

        return "\(sign.displayName) carries the energy between \(previousSign.displayName) and \(nextSign.displayName)"
    }

    private var easternStepSupportingText: String {
        "Eastern astrology follows the year you were born"
    }

    private var easternCycleContextText: String {
        let allSigns = ChineseZodiac.allCases

        guard let index = allSigns.firstIndex(of: currentEasternSign) else {
            return "The eastern cycle repeats every 12 years"
        }

        let previousSign = allSigns[(index - 1 + allSigns.count) % allSigns.count]
        let nextSign = allSigns[(index + 1) % allSigns.count]

        return "In the cycle, it sits between \(previousSign.displayName) and \(nextSign.displayName), shaping how you take things in and what you give back"
    }

    private var birthYearBinding: Binding<Int> {
        Binding(
            get: { currentBirthYear },
            set: { setBirthdayYear($0) }
        )
    }

    private var birthMonthBinding: Binding<Int> {
        Binding(
            get: { Calendar.current.component(.month, from: vm.birthday) },
            set: { setBirthdayMonth($0) }
        )
    }

    private var birthDayBinding: Binding<Int> {
        Binding(
            get: { Calendar.current.component(.day, from: vm.birthday) },
            set: { setBirthdayDay($0) }
        )
    }

    private var availableBirthYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1900...currentYear).reversed())
    }

    private var availableBirthMonths: [Int] {
        Array(1...12)
    }

    private var availableBirthDays: [Int] {
        let calendar = Calendar(identifier: .gregorian)
        let year = currentBirthYear
        let month = birthMonthBinding.wrappedValue
        let range = dateFor(year: year, month: month, day: 1, calendar: calendar)
            .flatMap { calendar.range(of: .day, in: .month, for: $0) }
        return Array(range ?? (1..<32))
    }

    // MARK: - Flow Steps

    @ViewBuilder
    private func stepView(for step: FlowStep) -> some View {
        switch step {
        case .welcome:
            welcomeStepView
                .transition(.opacity)

        case .western:
            westernStepView
                .transition(.opacity)
        case .refineBirthdate:
            refineBirthdateStepView
                .transition(.opacity)
        case .eastern:
            easternStepView
                .transition(.opacity)

        case .merging:
            Group {
                switch mergingPhase {
                case .form:
                    mergingStepView
                case .loading:
                    calculatingView
                        .onDisappear {
                            vm.isLoading = false
                        }
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98)))

        case .reveal:
            revealView
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
        }
    }


    private var welcomeStepView: some View {
        WelcomeStepView(isActive: flowStep == .welcome) {
            feedbackSoft()
            withAnimation(.easeInOut(duration: 0.35)) {
                flowStep = .western
            }
        }
    }




    private var westernStepView: some View {
        WesternStepView(
            selectedSign: Binding(
                get: { westernSelectedSign ?? currentWesternSign },
                set: { westernSelectedSign = $0 }
            ),
            currentSignName: currentWesternSignName,
            supportText: westernStepSupportingText,
            dateRange: currentWesternSign.dateRangeText,
            isSelecting: birthdateRevealState == .selecting,
            isRevealed: birthdateRevealState == .revealed,
            glyphVisible: westernRevealState.glyphVisible,
            identityVisible: westernRevealState.identityVisible,
            supportingVisible: westernRevealState.supportingVisible,
            ctaVisible: westernRevealState.ctaVisible,
            footerRevealProgress: westernFooterRevealProgress,
            centerBoosted: westernWheelCTAFlash,
            transitionLineVisible: westernWheelMessageVisible,
            revealActive: westernRevealActive,
            ctaTitle: westernRevealActive ? "Continue" : "Reveal the deeper layer",
            isCTAEnabled: hasInteractedWithWesternSelector,
            onSignChange: handleWesternSignSelection,
            onPrimaryAction: handleWesternPrimaryAction,
            onAppear: prepareWesternStep
        )
    }
    private func prepareRefineBirthdateStep() {
        birthdateRevealWorkItem?.cancel()
    }
    private var refineBirthdateStepView: some View {
        RefineBirthdateStepView(
            birthMonth: birthMonthBinding,
            birthDay: birthDayBinding,
            availableBirthMonths: availableBirthMonths,
            availableBirthDays: availableBirthDays,
            monthName: monthName,
            onContinue: {
                feedbackSoft()
                withAnimation(.easeInOut(duration: 0.35)) {
                    flowStep = .eastern
                }
            },
            onAppear: prepareRefineBirthdateStep
        )
    }
    private var easternStepView: some View {
        EasternStepView(
            currentSign: currentEasternSign,
            currentYearText: currentBirthYearText,
            signName: currentEasternSignName,
            supportText: easternStepSupportingText,
            revealState: easternRevealState,
            revealActive: easternRevealActive,
            selectedYear: birthYearBinding,
            availableBirthYears: availableBirthYears,
            onSelectSign: handleEasternSignSelection,
            onPrimaryAction: handleEasternPrimaryAction,
            onClearFocus: { focusedField = nil },
            onAppear: prepareEasternStep
        )
    }

    private var mergingStepView: some View {
        MergingStepView(
            scrollOffset: mergingScrollOffset,
            keyboardHeight: keyboardHeight,
            uiFadeOut: mergingUIFadeOut,
            revealState: mergingRevealState,
            optionalRefinementExpanded: optionalRefinementExpanded,
            footerRevealProgress: mergingFooterRevealProgress,
            isBeginRevealDisabled: vm.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onBeginReveal: beginReveal,
            onToggleOptionalRefinement: toggleOptionalRefinement,
            onAppear: prepareMergingStep,
            onScrollOffsetChange: { mergingScrollOffset = $0 },
            onFooterSentinelChange: updateMergingFooterRevealProgress,
            nameSection: { mergingNameSection },
            timeSection: { refinementTimeSection },
            placeSection: { refinementPlaceSection }
        )
    }
    private var mergingNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What should we call you?")
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)

            TextField("Enter your name", text: $vm.name)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .name)
                .padding()
                .background(OnboardingRefinementFieldBackground())
                .foregroundStyle(ZD.Color.textPrimary)
        }
    }


    private var refinementTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingRefinementSectionLabel(
                icon: "clock.fill",
                title: "Birth Time",
                subtitle: "Optional — even a rough time can sharpen the result"
            )

            if vm.birthTime == nil {
                Button {
                    focusedField = nil
                    feedbackSoft()
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                        vm.birthTime = defaultBirthTime
                    }
                } label: {
                    HStack {
                        Text("Add your birth time")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Spacer()

                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(ZD.Color.accent)
                    }
                    .padding()
                    .background(OnboardingRefinementFieldBackground())
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(formattedBirthTime)
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Spacer()

                        Button("Clear") {
                            focusedField = nil
                            feedbackSoft()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                                vm.birthTime = nil
                            }
                        }
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                    OnboardingRitualWheelContainer(
                        onInteraction: { focusedField = nil }
                    ) {
                        DatePicker(
                            "",
                            selection: birthTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .clipped()
                        .padding(.horizontal, 4)
                        .tint(ZD.Color.accent)
                        .colorScheme(.dark)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .background(OnboardingRefinementFieldBackground())
                .onTapGesture {
                    focusedField = nil
                }
            }
        }
        .id("timeSection")
    }

    private var refinementPlaceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingRefinementSectionLabel(
                icon: "mappin.and.ellipse",
                title: "Birthplace",
                subtitle: "Optional — where you were born can refine the reading"
            )

            VStack(alignment: .leading, spacing: 10) {
                TextField("City, State or City, Country", text: $birthplaceSearch.query)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .foregroundStyle(ZD.Color.textPrimary)
                    .focused($focusedField, equals: .birthplace)

                if !birthplaceSearch.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if birthplaceSearch.isResolving {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.85)
                                .tint(ZD.Color.accent)

                            Text("Resolving birthplace")
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)
                        }
                    } else if !birthplaceSearch.suggestions.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(birthplaceSearch.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                                Button {
                                    selectBirthplaceSuggestion(suggestion)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestion.title)
                                            .font(ZD.Font.body(.semibold))
                                            .foregroundStyle(ZD.Color.textPrimary)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .font(ZD.Font.caption())
                                                .foregroundStyle(ZD.Color.muted)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if index < birthplaceSearch.suggestions.count - 1 {
                                    Divider()
                                        .overlay(ZD.Color.border.opacity(0.28))
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                                .fill(ZD.Color.card.opacity(0.92))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                                        .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                                )
                        )
                    }
                }
            }
            .padding()
            .background(OnboardingRefinementFieldBackground())
            .padding(.bottom, birthplaceSearch.suggestions.isEmpty ? 0 : 16)
        }
        .id("birthplaceSection")
    }


    // MARK: - Calculating

    private var calculatingView: some View {
        MergingCalculatingView(
            background: AnyView(backgroundLayer),
            phase: revealPhase,
            revealFlashActive: revealState.revealFlash,
            onAppear: { vm.isLoading = true }
        )
    }

    // MARK: - Reveal

    private var revealView: some View {
        RevealStepView(
            background: AnyView(backgroundLayer),
            revealState: revealState,
            content: vm.identityCardContent,
            onComplete: completeOnboardingReveal,
            onShare: handleRevealShare,
            onAppear: runRevealSequence
        )
    }

    private func ownershipErrorCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.s) {
            Text("Account ownership needed")
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)

            Text(message)
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: completeOnboardingReveal) {
                HStack(spacing: 8) {
                    if vm.isCompletingOnboarding {
                        ProgressView()
                            .tint(Color.black)
                    }

                    Text(vm.isCompletingOnboarding ? "Securing account…" : "Try again")
                        .font(ZD.Font.body(.semibold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(ZD.Gradient.gold)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(vm.isCompletingOnboarding)
        }
        .padding(ZD.Spacing.m)
        .zCardStyle()
    }

    private func shareIdentityCard(_ content: IdentityCardContent, source: String) {
        guard let image = IdentityRevealShareRenderer.renderImage(for: content) else { return }

        let shareText = "My Zodian identity"

        sharePayload = SharePayload(activityItems: [shareText, image])
        AnalyticsService.shared.track(
            .identitySharePresented(
                identityID: content.id,
                title: content.identityName,
                source: source
            )
        )
    }

    private struct SharePayload: Identifiable {
        let id = UUID()
        let activityItems: [Any]
    }

    // MARK: - Actions

    private var defaultBirthTime: Date {
        Calendar.current.date(
            bySettingHour: 12,
            minute: 0,
            second: 0,
            of: vm.birthday
        ) ?? vm.birthday
    }

    private var birthTimeBinding: Binding<Date> {
        Binding(
            get: { vm.birthTime ?? defaultBirthTime },
            set: { vm.birthTime = $0 }
        )
    }

    private var formattedBirthTime: String {
        guard let birthTime = vm.birthTime else { return "Birth time" }
        return birthTime.formatted(date: .omitted, time: .shortened)
    }
    private func setBirthdayYearForEasternSign(_ sign: ChineseZodiac) {
        let currentYear = currentBirthYear

        let matchingYears = availableBirthYears.filter { year in
            let date = dateFor(year: year, month: 7, day: 1) ?? Date()
            return AstrologyCalculator.chineseZodiac(from: date) == sign
        }

        guard let bestYear = matchingYears.min(by: { abs($0 - currentYear) < abs($1 - currentYear) }) else {
            return
        }

        setBirthdayYear(bestYear)
    }
    private func setBirthdayYear(_ year: Int) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let components = calendar.dateComponents([.month, .day], from: vm.birthday)
        let month = components.month ?? 1
        let originalDay = components.day ?? 1

        var clampedDay = originalDay
        while clampedDay > 0 {
            var updated = DateComponents()
            updated.year = year
            updated.month = month
            updated.day = clampedDay

            if let resolvedDate = calendar.date(from: updated) {
                vm.birthday = resolvedDate
                return
            }

            clampedDay -= 1
        }
    }

    private func setBirthdayMonth(_ month: Int) {
        let day = Calendar.current.component(.day, from: vm.birthday)
        updateBirthdayKeepingYear(month: month, day: day)
    }

    private func setBirthdayDay(_ day: Int) {
        let month = Calendar.current.component(.month, from: vm.birthday)
        updateBirthdayKeepingYear(month: month, day: day)
    }

    private func updateBirthdayKeepingYear(month: Int, day: Int) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let year = currentBirthYear
        var clampedDay = day

        while clampedDay > 0 {
            if let resolvedDate = dateFor(year: year, month: month, day: clampedDay, calendar: calendar) {
                vm.birthday = resolvedDate
                return
            }

            clampedDay -= 1
        }
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.monthSymbols[max(0, min(month - 1, formatter.monthSymbols.count - 1))]
    }

    private func dateFor(year: Int, month: Int, day: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }

    private func selectBirthplaceSuggestion(_ suggestion: BirthplaceSuggestion) {
        feedbackSoft()

        Task {
            let resolution = await birthplaceSearch.resolve(suggestion)
            birthplaceSearch.query = resolution.normalized ?? resolution.raw
            birthplaceSearch.clearSuggestions()
            vm.applyBirthplace(
                raw: resolution.raw,
                normalized: resolution.normalized,
                timezoneIdentifier: resolution.timezoneIdentifier
            )
        }
    }

    private func resolvedFinalBirthDateForReveal() -> Date {
        let timezone = resolvedBirthTimezone()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: vm.birthday)
        let timeComponents = vm.birthTime.map { calendar.dateComponents([.hour, .minute], from: $0) }

        var resolvedComponents = DateComponents()
        resolvedComponents.calendar = calendar
        resolvedComponents.timeZone = timezone
        resolvedComponents.year = dateComponents.year
        resolvedComponents.month = dateComponents.month
        resolvedComponents.day = dateComponents.day
        resolvedComponents.hour = timeComponents?.hour ?? 12
        resolvedComponents.minute = timeComponents?.minute ?? 0
        resolvedComponents.second = 0

        let resolvedDate = calendar.date(from: resolvedComponents) ?? vm.birthday
        return westernCuspAdjustedDateIfNeeded(resolvedDate, calendar: calendar)
    }

    private func resolvedBirthTimezone() -> TimeZone {
        if let identifier = vm.birthTimezoneIdentifier,
           let timezone = TimeZone(identifier: identifier) {
            return timezone
        }

        return .current
    }

    private func westernCuspAdjustedDateIfNeeded(_ date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        guard let month = components.month,
              let day = components.day,
              let hour = components.hour,
              isWesternCuspEndDate(month: month, day: day),
              hour >= 20 else {
            return date
        }

        return calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    private func isWesternCuspEndDate(month: Int, day: Int) -> Bool {
        switch (month, day) {
        case (1, 20),
             (2, 19),
             (3, 20),
             (4, 20),
             (5, 21),
             (6, 21),
             (7, 23),
             (8, 23),
             (9, 23),
             (10, 23),
             (11, 22),
             (12, 21):
            return true
        default:
            return false
        }
    }

    private func previousStepOffset(for screenWidth: CGFloat) -> CGFloat {
        let progress = min(max(pageDragOffset / max(screenWidth, 1), 0), 1)
        return (-screenWidth * 0.22) + (screenWidth * 0.22 * progress)
    }

    private func backSwipeGesture(screenWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 22, coordinateSpace: .local)
            .onChanged { value in
                guard backSwipeIsEnabled else { return }
                guard value.startLocation.x <= 20 else { return }
                guard value.translation.width > 0 else { return }
                guard value.translation.width > 24 else { return }
                guard abs(value.translation.width) > abs(value.translation.height) * 1.4 else { return }
                pageDragOffset = value.translation.width
            }
            .onEnded { value in
                guard focusedField == nil else {
                    focusedField = nil
                    resetPageDragOffset()
                    return
                }

                guard backSwipeIsEnabled else {
                    resetPageDragOffset()
                    return
                }

                let translation = value.translation.width
                let predicted = value.predictedEndTranslation.width
                let shouldNavigateBack = translation > max(132, screenWidth * 0.30) || predicted > screenWidth * 0.55

                if shouldNavigateBack {
                    completeBackSwipe(screenWidth: screenWidth)
                } else {
                    resetPageDragOffset()
                }
            }
    }

    private func completeBackSwipe(screenWidth: CGFloat) {
        guard let previousStep = previousFlowStep else {
            resetPageDragOffset()
            return
        }

        feedbackSoft()
        isCompletingBackSwipe = true

        withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
            pageDragOffset = screenWidth + 32
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                if previousStep == .merging {
                    mergingPhase = .form
                }
                flowStep = previousStep
                pageDragOffset = 0
                isCompletingBackSwipe = false
            }
        }
    }

    private func resetPageDragOffset() {
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.88)) {
            pageDragOffset = 0
        }
    }

    private func registerForKeyboardNotifications() {
        guard keyboardWillShowObserver == nil, keyboardWillHideObserver == nil else { return }

        keyboardWillShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = max(frame.height - 24, 0)
            }
        }

        keyboardWillHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }

    private func unregisterForKeyboardNotifications() {
        if let keyboardWillShowObserver {
            NotificationCenter.default.removeObserver(keyboardWillShowObserver)
            self.keyboardWillShowObserver = nil
        }
        if let keyboardWillHideObserver {
            NotificationCenter.default.removeObserver(keyboardWillHideObserver)
            self.keyboardWillHideObserver = nil
        }
    }



    private func beginReveal() {
        feedbackSoft()
        focusedField = nil
        vm.finalizeOptionalInputs()
        vm.birthday = resolvedFinalBirthDateForReveal()
        vm.prepareReveal()

        guard vm.identityContent != nil else { return }

        withAnimation(.easeInOut(duration: 0.45)) {
            mergingUIFadeOut = true
        }

        revealPhaseTask?.cancel()
        revealSequenceTask?.cancel()

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.42))

            vm.isLoading = true
            resetRevealState()
            revealPhase = .compressing

            withAnimation(.easeInOut(duration: 0.32)) {
                flowStep = .merging
                mergingPhase = .loading
            }

            revealPhaseTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(OnboardingRevealTiming.compressionDuration))
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: 0.42)) {
                    revealPhase = .suspended
                }

                try? await Task.sleep(for: .seconds(OnboardingRevealTiming.suspensionDuration))
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: 0.3)) {
                    revealPhase = .revealing
                }

                revealState.revealFlash = true

                try? await Task.sleep(for: .seconds(0.35))
                guard !Task.isCancelled else { return }

                revealState.revealFlash = false

                try? await Task.sleep(for: .seconds(0.08))
                guard !Task.isCancelled else { return }

                vm.isLoading = false

                withAnimation(.easeInOut(duration: 0.60)) {
                    mergingPhase = .form
                    flowStep = .reveal
                }
            }
        }
    }

    private func resetRevealState() {
        revealPhaseTask?.cancel()
        revealSequenceTask?.cancel()
        revealPhase = .idle
        revealState.revealScale = 0.92
        revealState.revealOpacity = 0.0
        revealState.revealGlow = false
        revealState.revealBackdropVisible = false
        revealState.revealHeaderVisible = false
        revealState.revealComboVisible = false
        revealState.revealTitleVisible = false
        revealState.revealTaglineVisible = false
        revealState.revealOverviewVisible = false
        revealState.revealOverviewLineCount = 0
        revealState.revealButtonVisible = false
        revealState.revealShareVisible = false
        revealState.revealFlash = false
        revealState.revealCardLift = 38
    }

    private func runRevealSequence() {
        resetRevealState()

        // Arrival phase: the card lifts in, the glow peaks, then the identity details resolve.
        revealSequenceTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 1.1)) {
                revealState.revealBackdropVisible = true
            }

            try? await Task.sleep(for: .seconds(0.46))
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.42)) {
                revealState.revealFlash = true
                revealState.revealGlow = true
            }

            try? await Task.sleep(for: .seconds(0.22))
            guard !Task.isCancelled else { return }

            revealState.revealScale = 0.94
            revealState.revealCardLift = 40
            revealState.revealOpacity = 0

            withAnimation(.spring(response: 1.45, dampingFraction: 0.92)) {
                revealState.revealScale = 1.0
                revealState.revealOpacity = 1.0
                revealState.revealCardLift = 0
            }

            withAnimation(.easeOut(duration: 0.58)) {
                revealState.revealFlash = false
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.headerDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.82)) {
                revealState.revealHeaderVisible = true
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.comboDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.84)) {
                revealState.revealComboVisible = true
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.titleDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 1.14, dampingFraction: 0.9)) {
                revealState.revealTitleVisible = true
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.taglineDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.86)) {
                revealState.revealTaglineVisible = true
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.overviewDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.80)) {
                revealState.revealOverviewVisible = true
                revealState.revealOverviewLineCount = 1
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.actionDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.84, dampingFraction: 0.92)) {
                revealState.revealButtonVisible = true
            }

            try? await Task.sleep(for: .seconds(OnboardingRevealTiming.shareDelay))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.68)) {
                revealState.revealShareVisible = true
            }
        }
    }

    private func resetWesternRevealState() {
        westernRevealState = WesternRevealAnimationState()
        westernFooterRevealProgress = 0
        westernScrollOffset = 0
    }

    private func resetEasternRevealState() {
        easternRevealState = EasternRevealAnimationState()
        easternFooterRevealProgress = 0
        easternScrollOffset = 0
    }

    private func resetMergingRevealState() {
        mergingRevealState = MergingRevealAnimationState()
        optionalRefinementExpanded = false
        mergingScrollOffset = 0
    }

    private func runWesternRevealSequence() {
        resetWesternRevealState()
        westernFooterRevealProgress = 1
        westernRevealTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.18)) {
                westernRevealState.heroVisible = true
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                westernRevealState.glyphVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .western else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                westernRevealState.identityVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .western else { return }
            withAnimation(.easeOut(duration: 0.24)) {
                westernRevealState.supportingVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .western else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                westernRevealState.ctaVisible = true
            }
        }
    }

    private func runEasternRevealSequence() {
        resetEasternRevealState()
        easternRevealTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.18)) {
                easternRevealState.heroVisible = true
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                easternRevealState.symbolVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .eastern else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                easternRevealState.identityVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .eastern else { return }
            withAnimation(.easeOut(duration: 0.24)) {
                easternRevealState.supportingVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .eastern else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                easternRevealState.ctaVisible = true
            }
        }
    }

    private func runMergingRevealSequence() {
        resetMergingRevealState()
        mergeRevealTask = Task { @MainActor in
            withAnimation(.easeOut(duration: 0.18)) {
                mergingRevealState.heroVisible = true
            }

            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                mergingRevealState.westernVisible = true
            }

            try? await Task.sleep(for: .seconds(0.08))
            guard !Task.isCancelled, flowStep == .merging, mergingPhase == .form else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                mergingRevealState.easternVisible = true
            }

            try? await Task.sleep(for: .seconds(0.10))
            guard !Task.isCancelled, flowStep == .merging, mergingPhase == .form else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                mergingRevealState.combinedVisible = true
            }

            try? await Task.sleep(for: .seconds(0.12))
            guard !Task.isCancelled, flowStep == .merging, mergingPhase == .form else { return }
            withAnimation(.easeOut(duration: 0.24)) {
                mergingRevealState.contentVisible = true
            }

            try? await Task.sleep(for: .seconds(0.12))
            guard !Task.isCancelled, flowStep == .merging, mergingPhase == .form else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                mergingRevealState.ctaVisible = true
            }
        }
    }

    private func handleBirthdateSelectionChange() {
        if flowStep == .western, hasInteractedWithWesternSelector {
            birthdateRevealWorkItem?.cancel()

            westernSelectedSign = currentWesternSign

            let wasAlreadyRevealed = birthdateRevealState == .revealed
            birthdateRevealState = .revealed

            if !wasAlreadyRevealed {
                runWesternRevealSequence()
            } else {
                westernRevealState.identityVisible = true
                westernRevealState.supportingVisible = true
                westernRevealState.ctaVisible = true
            }

            return
        }

        birthdateRevealState = .selecting
        scheduleBirthdateReveal(after: 0.46)
    }

    private func handleWesternSignSelection(_ sign: WesternZodiac) {
        let didChangeResolvedWesternSign = currentWesternSign != sign
        westernSelectedSign = sign
        hasInteractedWithWesternSelector = true
        if didChangeResolvedWesternSign {
            setBirthdayForWesternSign(sign)
        }
    }

    private func handleWesternPrimaryAction() {
        feedbackSoft()

        if !westernRevealActive {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                westernRevealActive = true
                westernWheelCTAFlash = true
                westernWheelMessageVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                westernWheelCTAFlash = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.35)) {
                flowStep = .refineBirthdate
                westernRevealActive = false
                westernWheelMessageVisible = false
            }
        }
    }

    private func handleEasternSignSelection(_ sign: ChineseZodiac) {
        guard !easternRevealActive else { return }
        feedbackRitualTick()
        setBirthdayYearForEasternSign(sign)
    }

    private func handleEasternPrimaryAction() {
        feedbackSoft()

        if !easternRevealActive {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                easternRevealActive = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.35)) {
                mergingPhase = .form
                flowStep = .merging
                easternRevealActive = false
            }
        }
    }

    private func toggleOptionalRefinement() {
        focusedField = nil
        feedbackSoft()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.9)) {
            optionalRefinementExpanded.toggle()
        }
    }

    private func updateMergingFooterRevealProgress(minY: CGFloat, viewportHeight: CGFloat) {
        let progress = footerRevealProgress(
            sentinelMinY: minY,
            viewportHeight: viewportHeight
        )
        withAnimation(.easeOut(duration: 0.22)) {
            mergingFooterRevealProgress = progress
        }
    }

    private func handleRevealShare() {
        guard let content = vm.identityCardContent else { return }
        shareIdentityCard(content, source: "onboarding_reveal")
    }

    private func prepareWesternStep() {
        westernRevealTask?.cancel()
        resetWesternRevealState()
        westernScrollOffset = 0
        westernFooterRevealProgress = 1
        westernSelectedSign = currentWesternSign
        hasInteractedWithWesternSelector = false
        westernWheelCTAFlash = false
        westernWheelMessageVisible = false
        westernRevealActive = false
        if didMeaningfullySelectBirthdate {
            birthdateRevealState = .selecting
            scheduleBirthdateReveal(after: 0.16)
        } else {
            birthdateRevealState = .idle
        }
    }

    private func prepareEasternStep() {
        easternRevealTask?.cancel()
        easternRevealActive = false
        resetEasternRevealState()
        if didMeaningfullySelectBirthdate {
            birthdateRevealState = .selecting
            scheduleBirthdateReveal(after: 0.16)
        } else {
            birthdateRevealState = .idle
        }
    }

    private func prepareMergingStep() {
        mergeRevealTask?.cancel()
        resetMergingRevealState()
        mergingUIFadeOut = false
        if didMeaningfullySelectBirthdate {
            birthdateRevealState = .selecting
            scheduleBirthdateReveal(after: 0.16)
        } else {
            birthdateRevealState = .idle
        }
    }

    private func scheduleBirthdateReveal(after delay: Double) {
        birthdateRevealWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                birthdateRevealState = .revealed
            }

            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            switch flowStep {
            case .western:
                runWesternRevealSequence()
            case .refineBirthdate:
                break
            case .eastern:
                runEasternRevealSequence()
            case .merging:
                guard mergingPhase == .form else { return }
                runMergingRevealSequence()
            case .welcome, .reveal:
                break
            }
        }

        birthdateRevealWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func setBirthdayForWesternSign(_ sign: WesternZodiac) {
        let (month, day) = representativeMonthDay(for: sign)
        updateBirthdayKeepingYear(month: month, day: day)
    }

    private func representativeMonthDay(for sign: WesternZodiac) -> (Int, Int) {
        switch sign {
        case .aries: return (4, 5)
        case .taurus: return (5, 5)
        case .gemini: return (6, 5)
        case .cancer: return (7, 6)
        case .leo: return (8, 7)
        case .virgo: return (9, 7)
        case .libra: return (10, 7)
        case .scorpio: return (11, 6)
        case .sagittarius: return (12, 6)
        case .capricorn: return (1, 5)
        case .aquarius: return (2, 4)
        case .pisces: return (3, 5)
        }
    }


    private func startRitualAmbientAnimation() {
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            ritualGlow = true
        }
    }

    private func pulseRitualBand() {
        ritualBandPulse = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.28)) {
                ritualBandPulse = false
            }
        }
    }

    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    private func feedbackSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func feedbackRitualTick() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    private func completeOnboardingReveal() {
        guard !vm.isCompletingOnboarding else { return }

        Task {
            let completed = await vm.completeOnboarding(
                accountOwnership: accountOwnership,
                store: store,
                context: context
            )

            if completed {
                feedbackSuccess()
                onboardingCompleteStorage = true
            }
        }
    }

}

private struct LoadingConstellationCompressionView: View {
    let phase: RevealPhase

    private let points: [CGPoint] = [
        CGPoint(x: -84, y: 10),
        CGPoint(x: -52, y: -8),
        CGPoint(x: -18, y: -18),
        CGPoint(x: 18, y: -14),
        CGPoint(x: 52, y: -2),
        CGPoint(x: 84, y: 14)
    ]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let progress = collapseProgress

            ZStack {
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: interpolatedPoint(for: first, center: center, progress: progress))

                    for point in points.dropFirst() {
                        path.addLine(to: interpolatedPoint(for: point, center: center, progress: progress))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.28 * (1 - progress)),
                            Color.white.opacity(0.16 * (1 - progress)),
                            ZD.Color.accent.opacity(0.10 * (1 - progress))
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round)
                )

                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(ZD.Color.accent.opacity(nodeOpacity(for: index)))
                        .frame(width: index == 2 || index == 3 ? 4.5 : 3.5, height: index == 2 || index == 3 ? 4.5 : 3.5)
                        .shadow(color: ZD.Color.accent.opacity(0.24), radius: 4, y: 0)
                        .position(interpolatedPoint(for: point, center: center, progress: progress))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var collapseProgress: CGFloat {
        switch phase {
        case .idle:
            return 0
        case .compressing:
            return 0.10
        case .suspended:
            return 0.58
        case .revealing:
            return 0.92
        }
    }

    private func interpolatedPoint(for point: CGPoint, center: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + (point.x * (1 - progress)),
            y: center.y + (point.y * (1 - progress))
        )
    }

    private func nodeOpacity(for index: Int) -> Double {
        switch phase {
        case .idle, .compressing:
            return index.isMultiple(of: 2) ? 0.82 : 0.62
        case .suspended:
            return 0.54
        case .revealing:
            return index == 2 || index == 3 ? 0.26 : 0.12
        }
    }
}

private struct WesternIdentityRevealView: View {
    let glyph: String
    let signName: String
    let dateRange: String
    let supportingText: String
    let contextText: String
    let glyphVisible: Bool
    let identityVisible: Bool
    let supportingVisible: Bool

    @State private var ambientFloat = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.15))
                    .frame(width: 188, height: 188)
                    .blur(radius: 34)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.18),
                                ZD.Color.accent.opacity(0.04),
                                .clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 78
                        )
                    )
                    .frame(width: 208, height: 208)
                    .drawingGroup()

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                ZD.Color.accent.opacity(0.14),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 170, height: 170)

                Text(glyph)
                    .font(.system(size: 108, weight: .regular, design: .default))
                    .foregroundStyle(cardGoldGradient)
                    .shadow(color: ZD.Color.accent.opacity(0.16), radius: 14, y: 0)
                    .frame(width: 136, height: 136, alignment: .center)
                    .offset(x: 1, y: -1)
            }
            .frame(height: 240)
            .scaleEffect(glyphVisible ? 1 : 0.90)
            .opacity(glyphVisible ? 1 : 0)
            .offset(y: ambientFloat ? -3 : 3)
            .animation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true), value: ambientFloat)

            VStack(spacing: 10) {
                Text(signName)
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(supportingText)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(supportingVisible ? 1 : 0)

                Text(dateRange)
                    .font(ZD.Font.caption(.semibold))
                    .tracking(1.0)
                    .foregroundStyle(ZD.Color.accent.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .opacity(supportingVisible ? 1 : 0)
            }
            .frame(maxWidth: 280)
            .opacity(identityVisible ? 1 : 0)
            .offset(y: identityVisible ? 0 : 12)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            ambientFloat = true
        }
    }

    private var cardGoldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.58, green: 0.44, blue: 0.14),
                Color(red: 0.96, green: 0.86, blue: 0.58),
                Color(red: 0.79, green: 0.62, blue: 0.24)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
