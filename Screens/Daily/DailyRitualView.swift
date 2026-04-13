import SwiftUI
import SwiftData
import UIKit

struct DailyRitualView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    let reading: DailyReading
    let archetype: Archetype

    @State private var showCompletionBanner = false
    @State private var completedSteps: Set<RitualStep> = []
    @State private var selectedReflection: ReflectionChoice?
    @State private var reflectionNote: String = ""

    @State private var pulsingStep: RitualStep?
    @State private var pulseScale: CGFloat = 1.0

    private let ritualCompletionReward = 5

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                heroSection
                stepsSection
                progressSection
                focusSection
                reflectionSection
                completionSection
            }
            .padding(.top, 12)
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.bottom, 24)
        }
        .background(
            ZD.Color.bg
                .overlay(
                    RadialGradient(
                        colors: [
                            ZD.Color.card.opacity(heroAuraOpacity),
                            .clear
                        ],
                        center: .top,
                        startRadius: 10,
                        endRadius: 500
                    )
                )
                .ignoresSafeArea()
        )
        .navigationTitle("Daily Ritual")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            if showCompletionBanner {
                completionBanner
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .onAppear {
            if hasCompletedRitualToday {
                completedSteps = Set(RitualStep.allCases)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Text("Daily Ritual")
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Spacer(minLength: 12)

                    moodPill
                }

                Text("Today asks for \(reading.theme.lowercased()).")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(archetype.combinedName)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)

                Text(shortHeroMessage)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .stroke(heroBorderGradient, lineWidth: heroBorderWidth)
        )
        .shadow(
            color: ZD.Color.accent.opacity(heroShadowOpacity),
            radius: 14,
            y: 7
        )
    }

    // MARK: - Steps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Today’s Steps",
                subtitle: "Move through the day with intention"
            )

            VStack(spacing: 10) {
                ritualStepCard(
                    step: .love,
                    title: "Love",
                    body: reading.love,
                    icon: "heart.fill"
                )

                ritualStepCard(
                    step: .work,
                    title: "Work",
                    body: reading.work,
                    icon: "briefcase.fill"
                )

                ritualStepCard(
                    step: .growth,
                    title: "Growth",
                    body: reading.growth,
                    icon: "sparkles"
                )
            }
        }
    }

    private func ritualStepCard(
        step: RitualStep,
        title: String,
        body: String,
        icon: String
    ) -> some View {
        let isComplete = completedSteps.contains(step)
        let isPulsing = pulsingStep == step

        return Button {
            toggleStep(step)
        } label: {
            TarotCardContainer {
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(ZD.Color.cardAlt)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isComplete
                                            ? ZD.Color.accent
                                            : ZD.Color.accent.opacity(0.42),
                                        lineWidth: isComplete ? 2.2 : 1.25
                                    )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: isComplete
                                    ? ZD.Color.accent.opacity(0.34)
                                    : ZD.Color.accent.opacity(0.12),
                                radius: isComplete ? 8 : 3
                            )
                            .scaleEffect(isPulsing ? pulseScale : 1)

                        Image(systemName: isComplete ? "checkmark" : icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(
                                isComplete
                                    ? ZD.Color.accent
                                    : ZD.Color.accent.opacity(0.84)
                            )
                            .scaleEffect(isPulsing ? pulseScale : 1)
                    }
                    .frame(width: 46, alignment: .leading)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)

                            if isComplete {
                                Text("Complete")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.accent)
                            } else {
                                Text("Tap to mark")
                                    .font(ZD.Font.caption())
                                    .foregroundStyle(ZD.Color.muted)
                            }
                        }

                        Text(body)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isComplete ? 0.94 : 1.0)
                    .scaleEffect(isComplete ? 0.995 : 1.0)

                    Spacer(minLength: 0)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .stroke(
                        isComplete
                            ? ZD.Color.accent.opacity(0.24)
                            : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Ritual Progress",
                subtitle: "Build momentum as you move through each step"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("\(completedSteps.count) of 3 completed")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Spacer()

                        Text("\(Int(progressValue * 100))%")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.accent)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(ZD.Color.cardAlt)

                            Capsule()
                                .fill(ZD.Gradient.gold)
                                .frame(width: max(proxy.size.width * progressValue, 12))
                        }
                    }
                    .frame(height: 12)

                    Text(progressMessage)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.muted)
                }
            }
        }
    }

    // MARK: - Focus

    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Keep in Mind",
                subtitle: "Where today may challenge or reward you"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 14) {
                    insightRow(
                        title: "Caution",
                        body: reading.caution,
                        icon: "exclamationmark.triangle.fill",
                        tint: ZD.Color.warning
                    )

                    divider

                    insightRow(
                        title: "Opportunity",
                        body: reading.opportunity,
                        icon: "sparkles",
                        tint: ZD.Color.accent
                    )
                }
            }
        }
    }

    private func insightRow(
        title: String,
        body: String,
        icon: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(tint)

                Text(body)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Reflection

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Reflection",
                subtitle: "Anchor the lesson before the day moves on"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    Text(reflectionPrompt)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Where is this showing up most?")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.accent)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        reflectionChoiceButton(.love, title: "In love")
                        reflectionChoiceButton(.work, title: "At work")
                        reflectionChoiceButton(.selfFocus, title: "With myself")
                        reflectionChoiceButton(.unsure, title: "Not sure yet")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Optional Note")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.accent)

                        TextField("Write a sentence for yourself...", text: $reflectionNote, axis: .vertical)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .lineLimit(2...3)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                    .fill(ZD.Color.cardAlt)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                            .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                                    )
                            )
                    }

                    divider

                    Text(streakMessage)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func reflectionChoiceButton(_ choice: ReflectionChoice, title: String) -> some View {
        let isSelected = selectedReflection == choice

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                selectedReflection = choice
            }
            feedbackSoft()
        } label: {
            Text(title)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(isSelected ? Color.black : ZD.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(ZD.Gradient.gold)
                                : AnyShapeStyle(ZD.Color.cardAlt)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                .stroke(
                                    isSelected
                                        ? ZD.Color.accent.opacity(0.18)
                                        : ZD.Color.border.opacity(0.35),
                                    lineWidth: ZD.Stroke.thin
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Completion

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Seal the Day",
                subtitle: hasCompletedRitualToday
                    ? "Your ritual is complete."
                    : "Complete all steps to close the loop."
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    if hasCompletedRitualToday {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(ZD.Color.success)

                            Text("Ritual Complete")
                                .font(ZD.Font.heading())
                                .foregroundStyle(ZD.Color.textPrimary)
                        }

                        Text("Today’s ritual has been sealed. Return tomorrow for a new cycle and another layer of guidance.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Reward claimed: +\(ritualCompletionReward) points")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                    } else {
                        Text("Mark Ritual Complete")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("Once all three steps feel complete, seal the ritual and claim your reward.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        PrimaryButton(
                            title: "Complete Ritual (+\(ritualCompletionReward) pts)",
                            action: completeRitual,
                            isDisabled: completedSteps.count < 3,
                            icon: "checkmark",
                            fullWidth: true
                        )
                    }
                }
            }
        }
    }

    // MARK: - Components

    private var moodPill: some View {
        let mood = currentMood

        return HStack(spacing: 8) {
            Image(systemName: mood.symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(mood.tint)

            Text("Mood: \(mood.title)")
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
                        .stroke(mood.tint.opacity(0.35), lineWidth: ZD.Stroke.thin)
                )
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(ZD.Color.border.opacity(0.28))
            .frame(height: 1)
    }

    private var completionBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(ZD.Color.accent)

            Text("Ritual completed • +\(ritualCompletionReward) points")
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

    // MARK: - Derived Content

    private var currentMood: DailyMood {
        if let mapped = DailyMood(rawValue: reading.mood.lowercased()) {
            return mapped
        }
        return .clarity
    }

    private var shortHeroMessage: String {
        reading.summary
    }

    private var progressValue: Double {
        Double(completedSteps.count) / 3.0
    }

    private var progressMessage: String {
        switch completedSteps.count {
        case 0:
            return "Begin with one intentional step."
        case 1:
            return "Momentum has started."
        case 2:
            return "You’re nearly ready to seal the ritual."
        default:
            return "Your ritual is complete for today."
        }
    }

    private var reflectionPrompt: String {
        "Where are you being asked to embody \(reading.theme.lowercased()) more intentionally today?"
    }

    private var streakMessage: String {
        switch store.streak {
        case 0:
            return "Your ritual begins with one return."
        case 1...3:
            return "Consistency is beginning to shape your identity."
        case 4...7:
            return "Your rhythm is strengthening. Small returns are becoming real momentum."
        case 8...13:
            return "You are building a deeper ritual now. Repetition is turning into meaning."
        default:
            return "Your ritual is becoming part of your pattern. Keep going."
        }
    }

    private var hasCompletedRitualToday: Bool {
        store.ritualCompletedToday
    }

    private var heroBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                ZD.Color.accent.opacity(0.78),
                ZD.Color.accent.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroBorderWidth: CGFloat {
        switch store.streak {
        case 0...3: return 1.0
        case 4...7: return 1.2
        case 8...13: return 1.35
        default: return 1.5
        }
    }

    private var heroShadowOpacity: Double {
        switch store.streak {
        case 0...3: return 0.14
        case 4...7: return 0.18
        case 8...13: return 0.22
        default: return 0.28
        }
    }

    private var heroAuraOpacity: Double {
        switch store.streak {
        case 0...3: return 0.16
        case 4...7: return 0.20
        case 8...13: return 0.24
        default: return 0.30
        }
    }

    // MARK: - Actions

    private func toggleStep(_ step: RitualStep) {
        let isCompleting = !completedSteps.contains(step)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            if completedSteps.contains(step) {
                completedSteps.remove(step)
            } else {
                completedSteps.insert(step)
            }
        }

        if isCompleting {
            pulseStep(step)
            feedbackStepComplete()
        } else {
            feedbackSoft()
        }
    }

    private func pulseStep(_ step: RitualStep) {
        pulsingStep = step
        pulseScale = 1.0

        withAnimation(.easeOut(duration: 0.14)) {
            pulseScale = 1.18
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                pulseScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            if pulsingStep == step {
                pulsingStep = nil
            }
        }
    }

    private func completeRitual() {
        guard !hasCompletedRitualToday else { return }
        guard completedSteps.count == 3 else { return }

        feedbackSoft()
        store.completeDailyRitual(context: context, reward: ritualCompletionReward)
        AnalyticsService.shared.track(
            .dailyRitualCompleted(
                identityID: archetype.id,
                streak: store.streak,
                points: store.points
            )
        )

        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            showCompletionBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showCompletionBanner = false
            }
        }

        feedbackSuccess()
    }

    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    private func feedbackStepComplete() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 0.9)
    }

    private func feedbackSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Supporting Types

private enum RitualStep: CaseIterable, Hashable {
    case love
    case work
    case growth
}

private enum ReflectionChoice: Hashable {
    case love
    case work
    case selfFocus
    case unsure
}

#Preview {
    let store = AppStore()
    store.currentUser = UserProfile(
        name: "Ian",
        birthday: Date(timeIntervalSince1970: 623894400),
        westernSignRaw: "aries",
        chineseSignRaw: "horse",
        archetypeId: "aries-horse"
    )
    store.streak = 6

    let archetype = Archetype.fallback(western: .aries, chinese: .horse)
    let reading = DailyReading(
        theme: "Quiet Attraction",
        summary: "Your energy is more noticeable than usual today. Let attraction come through presence rather than performance.",
        mood: "magnetism",
        love: "Romantic energy is heightened. Let curiosity and reciprocity lead instead of trying to control the outcome.",
        work: "Your presence carries influence today. Let others feel your conviction without overselling it.",
        growth: "Notice where you seek validation and where you genuinely want connection. They are not always the same.",
        caution: "Do not confuse attention with alignment.",
        opportunity: "An unexpected invitation or conversation may hold more potential than first appears."
    )

    return NavigationStack {
        DailyRitualView(reading: reading, archetype: archetype)
            .environmentObject(store)
            .modelContainer(
                for: [
                    UserProfile.self,
                    PointsLedgerItem.self,
                    StreakDay.self
                ],
                inMemory: true
            )
    }
    .preferredColorScheme(.dark)
}
