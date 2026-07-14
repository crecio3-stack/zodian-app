import SwiftUI
import Foundation
import SwiftData
import UIKit

private struct PatternArchiveSignal {
    enum Source {
        case savedRead
        case connect
        case thread
        case profile

        var label: String {
            switch self {
            case .savedRead:
                return "SAVED READ"
            case .connect:
                return "CONNECT"
            case .thread:
                return "THREAD"
            case .profile:
                return "SAVED PROFILE"
            }
        }
    }

    let title: String
    let date: Date
    let themes: [String]
    let excerpt: String
    let source: Source

    var primaryTheme: String? {
        themes.first
    }

    var secondaryTheme: String? {
        themes.dropFirst().first
    }
}

struct PatternView: View {
    @EnvironmentObject private var store: AppStore
    @Query(sort: \SavedDailyReading.createdAt, order: .reverse) private var savedDailyReadings: [SavedDailyReading]
    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]

    @StateObject private var viewModel = BlueprintViewModel()
    @State private var sharePayload: SharePayload?
    @State private var showPremiumSheet = false
    @State private var showPatternArchive = false
    @State private var openArchiveAfterPremiumDismiss = false
    @State private var appeared = false
    @State private var revealedSectionCount = 0
    @State private var patternMemorySummary = PatternMemoryService.shared.monthlySummary()
    @State private var patternMemoryReflection = PatternMemoryService.shared.monthlyReflection()
    @State private var archiveFocusQuery: String?
    @State private var archiveHighlightedReadingID: UUID?
    @State private var savedProfileFocus: PatternMemorySavedProfileFocus?
    @AppStorage("zodian.patternRevealLocked") private var patternRevealLocked = false

    private var presentation: BlueprintPresentation {
        viewModel.presentation
    }

    private var identityContent: ZodiacIdentityContent {
        presentation.identityContent
    }

    private var identityCardContent: IdentityCardContent {
        presentation.identityCardContent
    }

    private var pattern: PatternPageContent {
        PatternPageContent.make(
            archetype: presentation.currentArchetype,
            identity: identityContent,
            user: store.currentUser
        )
    }

    private var presentationRefreshKey: String {
        let user = store.currentUser
        return [
            store.identityRefreshToken.uuidString,
            store.onboardingResetToken.uuidString,
            user?.id.uuidString ?? "no-user",
            user?.name ?? "",
            user.map { String($0.birthday.timeIntervalSince1970) } ?? "no-birthday",
            user?.westernSignRaw ?? "",
            user?.chineseSignRaw ?? "",
            user?.archetypeId ?? ""
        ].joined(separator: "|")
    }

    private func trackPatternMemory(_ type: PatternMemoryEventType) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent(
                type: type,
                identity: pattern.combinedName
            )
        )
    }

    private func refreshPatternMemory() {
        patternMemorySummary = PatternMemoryService.shared.monthlySummary()
        patternMemoryReflection = PatternMemoryService.shared.monthlyReflection()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PatternAtmosphere()

                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            Color.clear
                                .frame(height: 0)
                                .id("pattern-top")

                            heroStage()
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 14
                                )

                            editorialPause(
                                eyebrow: "THE TELL",
                                statement: pattern.oneLineRead
                            )
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 12
                                )

                            traitSystemSection
                                .opacity(0.86)
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 10
                                )

                            if revealedSectionCount > 0 {
                                VStack(alignment: .leading, spacing: 18) {
                                    ForEach(Array(revealSections.enumerated()), id: \.offset) { index, section in
                                        if index < revealedSectionCount {
                                            revealSection(
                                                section,
                                                scrollProxy: scrollProxy
                                            )
                                                .id(section.scrollTargetID)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                                .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                                    content
                                                        .opacity(phase.isIdentity ? 1 : 0.94)
                                                        .offset(y: phase.value * -10)
                                                }
                                        }
                                    }
                                }
                                .animation(.spring(response: 0.42, dampingFraction: 0.9), value: revealedSectionCount)
                            }

                            revealCTA(scrollProxy: scrollProxy)
                                .id("pattern-reveal-cta")
                                .patternCinematicMotion(
                                    appeared: appeared,
                                    entranceOffset: 10
                                )

                            patternResetControl(scrollProxy: scrollProxy)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 18)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 128)
                        .animation(.spring(response: 0.42, dampingFraction: 0.9), value: revealedSectionCount)
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $sharePayload) { payload in
                ActivityShareSheet(activityItems: payload.activityItems)
            }
            .sheet(isPresented: $showPremiumSheet, onDismiss: {
                guard openArchiveAfterPremiumDismiss,
                      store.hasAccess(to: .patternArchive) else {
                    openArchiveAfterPremiumDismiss = false
                    return
                }

                openArchiveAfterPremiumDismiss = false
                DispatchQueue.main.async {
                    showPatternArchive = true
                }
            }) {
                PremiumRewardsSheet(
                    source: "pattern",
                    onAccessActivated: {
                        openArchiveAfterPremiumDismiss = true
                    }
                )
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showPatternArchive) {
                NavigationStack {
                    SavedDailyReadsView(navigationTitle: "Pattern Archive")
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
            }
            .sheet(item: $savedProfileFocus) { focus in
                PatternMemorySavedProfilesView(
                    title: focus.title,
                    matches: focus.matches
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .preferredColorScheme(.dark)
            }
            .onAppear {
                refreshPresentation()
                trackPatternMemory(.patternScreenOpened)
                refreshPatternMemory()
                revealedSectionCount = patternRevealLocked ? revealSections.count : 0
                withAnimation(.easeOut(duration: 0.78)) {
                    appeared = true
                }
            }
            .onChange(of: presentationRefreshKey) { _, _ in
                refreshPresentation()
                revealedSectionCount = patternRevealLocked ? revealSections.count : 0
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Sections

private extension PatternView {
    func heroStage() -> some View {
        VStack(spacing: 10) {
            IdentityRevealCardView(content: identityCardContent)
                .frame(maxWidth: 380)
                .shadow(color: ZD.Color.accent.opacity(0.14), radius: 22, y: 10)
                .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .onLongPressGesture(minimumDuration: 0.45) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    shareCurrentIdentity()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(identityCardContent.signCombination), \(identityCardContent.identityName), \(identityCardContent.descriptor), \(identityCardContent.patternSummary)"
                )
                .accessibilityAction(named: "Share your identity") {
                    shareCurrentIdentity()
                }

            Text("Long press to share what came into focus")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ZD.Color.muted.opacity(0.78))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    var traitSystemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 0) {
                traitColumn(
                    label: "STRENGTH",
                    title: pattern.primaryStrength,
                    items: pattern.strengths,
                    accent: ZD.Color.accent
                )
                .frame(maxWidth: .infinity, alignment: .topLeading)

                Rectangle()
                    .fill(ZD.Color.border.opacity(0.18))
                    .frame(width: 1)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 14)

                traitColumn(
                    label: "SHADOW",
                    title: pattern.primaryShadow,
                    items: pattern.shadows,
                    accent: ZD.Color.premium
                )
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    var corePatternEditorial: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(title: "HOW IT SHOWS UP", accent: ZD.Color.accent)
            pacedBody(pattern.howYouMove, leadSize: 19, bodySize: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 4)
    }

    func editorialPause(eyebrow: String, statement: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(title: eyebrow, accent: ZD.Color.premium.opacity(0.92))

            Text(statement)
                .font(.system(size: 29, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .padding(.horizontal, 4)
    }

    func revealCTA(scrollProxy: ScrollViewProxy) -> some View {
        Group {
            if let nextSection = nextRevealSection {
                Button {
                    revealNextSection(scrollProxy: scrollProxy)
                } label: {
                    VStack(spacing: 7) {
                        Text(nextSection.ctaLabel)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .multilineTextAlignment(.center)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(ZD.Color.premium.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            } else {
                Text("Identity revealed")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func patternResetControl(scrollProxy: ScrollViewProxy) -> some View {
        if revealedSectionCount > 0 {
            Button {
                resetPatternReveal(scrollProxy: scrollProxy)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .bold))

                    Text("Reset identity")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(ZD.Color.muted)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(ZD.Color.card.opacity(0.5))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(ZD.Color.border.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(0.68)
            .transition(.opacity)
        }
    }

    @ViewBuilder
    func revealSection(
        _ section: PatternRevealSection,
        scrollProxy: ScrollViewProxy
    ) -> some View {
        switch section {
        case .howItShowsUp:
            corePatternEditorial
        case .whatGetsInTheWay:
            revealTextSection(
                title: "WHAT GETS IN THE WAY",
                body: pattern.shadowRead,
                accent: ZD.Color.premium,
                base: ZD.Color.cardAlt.opacity(0.84),
                glow: ZD.Color.premium.opacity(0.05)
            )
        case .loveAndFriendship:
            revealTextSection(
                title: "LOVE AND FRIENDSHIP",
                body: pattern.connectionRead,
                accent: ZD.Color.accent,
                base: ZD.Color.card.opacity(0.86),
                glow: ZD.Color.accent.opacity(0.05)
            )
        case .workAndPurpose:
            revealTextSection(
                title: "WORK AND PURPOSE",
                body: pattern.workRead,
                accent: ZD.Color.muted,
                base: ZD.Color.card.opacity(0.84),
                glow: ZD.Color.muted.opacity(0.04)
            )
        case .howYouStayTrue:
            revealTextSection(
                title: "HOW YOU STAY TRUE",
                body: pattern.growthRead,
                accent: ZD.Color.accent,
                base: ZD.Color.cardAlt.opacity(0.78),
                glow: ZD.Color.accent.opacity(0.05)
            )
        case .closeCompany:
            patternSection(
                eyebrow: "CLOSE COMPANY",
                title: "Who can stay close",
                body: pattern.compatibilityRead
            )
        case .finalPath:
            finalPathSection
        }
    }

    func revealTextSection(
        title: String,
        body: String,
        accent: Color,
        base: Color,
        glow: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(title: title, accent: accent)

            pacedBody(body, leadSize: 18, bodySize: 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .background(
            patternPanelBackground(
                cornerRadius: 24,
                accent: accent,
                base: base,
                glow: glow
            )
        )
    }

    var patternArchiveSection: some View {
        let hasAccess = store.hasAccess(to: .patternArchive)

        return Group {
            if hasAccess {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    trackPatternMemory(.patternArchiveOpened)
                    showPatternArchive = true
                } label: {
                    patternArchiveGateway
                }
                .id("pattern-archive")
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
                    trackPatternMemory(.patternArchiveViewed)
                }
            } else {
                Button {
                    trackPatternMemory(.patternArchiveOpened)
                    openArchiveAfterPremiumDismiss = false
                    showPremiumSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel(title: "PATTERN ARCHIVE", accent: ZD.Color.premium)

                        Text("Your saved reads")
                            .font(.system(size: 23, weight: .bold, design: .serif))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("A private library of Today’s Lens entries you chose to keep.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .bold))

                            Text("View archive access")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Capsule(style: .continuous).fill(ZD.Gradient.gold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 17)
                    .background(
                        patternPanelBackground(
                            cornerRadius: 24,
                            accent: ZD.Color.premium,
                            base: ZD.Color.cardAlt.opacity(0.68),
                            glow: ZD.Color.premium.opacity(0.05)
                        )
                    )
                }
                .id("pattern-archive")
                .buttonStyle(.plain)
                .onAppear {
                    trackPatternMemory(.archivePreviewViewed)
                }
            }
        }
    }

    var patternArchiveGateway: some View {
        let readings = archiveFocusedReadings
        let themes = archiveThemeLabels(from: readings)
        let count = savedDailyReadings.count

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel(title: "PATTERN ARCHIVE", accent: ZD.Color.premium)

            Text("Your saved reads")
                .font(.system(size: 23, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if readings.isEmpty {
                Text("Your archive starts with the first Today’s Lens you save.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text("A theme is starting to repeat:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)

                    Text(themes.isEmpty ? "A recurring theme" : themes.joined(separator: " • "))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(2)
                }
            }

            HStack(spacing: 10) {
                Text("\(count) saved \(count == 1 ? "read" : "reads")")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)

                Spacer()

                Text("View saved reads")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.premium.opacity(0.94))
                    .lineLimit(1)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ZD.Color.premium.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .background(
            patternPanelBackground(
                cornerRadius: 24,
                accent: ZD.Color.premium,
                base: ZD.Color.cardAlt.opacity(0.68),
                glow: ZD.Color.premium.opacity(0.05)
            )
        )
    }

    @ViewBuilder
    var patternArchiveContent: some View {
        let readings = archiveFocusedReadings

        if readings.isEmpty {
            patternArchiveEmptyState
        } else if archiveHasFocusedMatches {
            VStack(alignment: .leading, spacing: 16) {
                patternArchiveSupportingSignal(for: readings)

                VStack(alignment: .leading, spacing: 14) {
                    patternArchiveSummary(for: recentArchiveReadings)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recentArchiveReadings.prefix(3), id: \.id) { reading in
                            patternArchiveReadingRow(reading)
                        }
                    }
                }
                .padding(.top, 2)
            }
        } else {
            VStack(alignment: .leading, spacing: 14) {
                patternArchiveSummary(for: readings)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(readings.prefix(3), id: \.id) { reading in
                        patternArchiveReadingRow(reading)
                    }
                }
            }
        }
    }

    var archiveFocusedReadings: [SavedDailyReading] {
        guard let query = archiveFocusQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty
        else {
            return recentArchiveReadings
        }

        return focusedArchiveReadings(for: query)
    }

    var recentArchiveReadings: [SavedDailyReading] {
        Array(savedDailyReadings.prefix(8))
    }

    func focusedArchiveReadings(for query: String?) -> [SavedDailyReading] {
        guard let query = query?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty
        else {
            return recentArchiveReadings
        }

        let matches = recentArchiveReadings.filter { archiveReading($0, matches: query) }
        return matches.isEmpty ? recentArchiveReadings : matches
    }

    var patternArchivePreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                patternArchivePreviewPill("Saved reads")
                patternArchivePreviewPill("Kept for later")
            }

            Text("Pattern Archive keeps the Today’s Lens entries you want to return to.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                showPremiumSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))

                    Text("View archive access")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule(style: .continuous).fill(ZD.Gradient.gold))
            }
            .buttonStyle(.plain)
        }
    }

    var patternArchiveEmptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your archive starts with the first Today’s Lens you save.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Save a Lens when you want to come back to it later.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func patternArchiveSummary(for readings: [SavedDailyReading]) -> some View {
        let title = readings.count == 1 ? "FIRST SAVED READ" : "SAVED READS"
        let summary = readings.count == 1
            ? archiveFirstSignal(from: readings[0])
            : archiveRecurringSignal(from: readings)

        return VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.3)
                .foregroundStyle(ZD.Color.premium.opacity(0.9))

            Text(summary)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func patternArchiveSupportingSignal(for readings: [SavedDailyReading]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SAVED READS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(ZD.Color.premium.opacity(0.9))

                Text("The reads behind this archive view.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(readings.prefix(2), id: \.id) { reading in
                    patternArchiveSupportingRow(reading)
                }
            }
        }
    }

    func patternArchiveSupportingRow(_ reading: SavedDailyReading) -> some View {
        let isHighlighted = archiveHighlightedReadingID == reading.id
        let signal = archiveSignal(from: reading)

        return VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(signal.title)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text("Saved \(archiveShortDateText(for: reading))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)
                    .lineLimit(1)
            }

            Text(signal.excerpt)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(3)
                .lineLimit(2)

            archiveSignalMetadata(signal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isHighlighted ? ZD.Color.premium.opacity(0.13) : ZD.Color.card.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isHighlighted ? ZD.Color.premium.opacity(0.36) : ZD.Color.border.opacity(0.14),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            trackPatternMemorySavedReadOpened(reading)
        }
    }

    func patternArchiveReadingRow(_ reading: SavedDailyReading) -> some View {
        let signal = archiveSignal(from: reading)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(signal.title)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text(archiveDateText(for: reading))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)
                    .lineLimit(1)
            }

            Text(signal.excerpt)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(3)
                .lineLimit(2)

            archiveSignalMetadata(signal)
        }
        .padding(.top, 10)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(ZD.Color.border.opacity(0.18))
                .frame(height: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            trackPatternMemorySavedReadOpened(reading)
        }
    }

    func trackPatternMemorySavedReadOpened(_ reading: SavedDailyReading) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent.savedReadArchiveEvent(
                type: .archiveItemOpened,
                reading: reading
            )
        )
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent.savedReadArchiveEvent(
                type: .savedReadOpenedFromArchive,
                reading: reading
            )
        )
    }

    func patternArchivePreviewPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(ZD.Color.premium.opacity(0.92))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(ZD.Color.card.opacity(0.66))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(ZD.Color.premium.opacity(0.16), lineWidth: 1)
                    )
            )
    }

    func archiveFirstSignal(from reading: SavedDailyReading) -> String {
        let theme = archiveSignal(from: reading).primaryTheme
            .map(lowercasedThemeLabel)
            ?? "the read you wanted to keep"

        return "Your first saved read begins with \(theme)."
    }

    func archiveRecurringSignal(from readings: [SavedDailyReading]) -> String {
        let themes = archiveThemeLabels(from: readings)
            .map(lowercasedThemeLabel)

        switch themes.count {
        case 3:
            return "Your saved reads keep circling back to \(themes[0]), \(themes[1]), and \(themes[2])."
        case 2:
            return "Your saved reads keep circling back to \(themes[0]) and \(themes[1])."
        case 1:
            return "A theme is starting to repeat: \(themes[0])."
        default:
            return "A theme is starting to repeat across what you have saved."
        }
    }

    func archiveThemeLabels(from readings: [SavedDailyReading]) -> [String] {
        let labels = readings.flatMap { archiveSignal(from: $0).themes }
        let counts = Dictionary(grouping: labels, by: { $0.lowercased() })
            .mapValues(\.count)

        return counts
            .sorted { lhs, rhs in
                lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value
            }
            .prefix(3)
            .compactMap { entry in
                labels.first { $0.lowercased() == entry.key }
            }
    }

    func archiveDisplayTitle(for reading: SavedDailyReading) -> String {
        let title = firstNonEmpty([
            reading.versionedLensContent?.title,
            reading.theme,
            reading.identity,
            reading.focus
        ])

        return isSafeArchiveTitle(title) ? title : "Saved read"
    }

    func archiveDisplayBody(for reading: SavedDailyReading) -> String {
        let body = firstNonEmpty([
            reading.versionedLensContent?.read,
            reading.insight,
            reading.summary,
            reading.affirmation,
            reading.caution
        ])

        return body.isEmpty || containsSuspiciousInternalString(body)
            ? "A saved signal from this day."
            : body
    }

    func archiveDateText(for reading: SavedDailyReading) -> String {
        if !reading.dateKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let parser = DateFormatter()
            parser.locale = Locale(identifier: "en_US_POSIX")
            parser.dateFormat = "yyyy-MM-dd"

            if let date = parser.date(from: reading.dateKey) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: reading.createdAt)
    }

    func archiveShortDateText(for reading: SavedDailyReading) -> String {
        if !reading.dateKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"

            let parser = DateFormatter()
            parser.dateFormat = "yyyy-MM-dd"

            if let date = parser.date(from: reading.dateKey) {
                return formatter.string(from: date)
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: reading.createdAt)
    }

    func setArchiveHighlight(from readings: [SavedDailyReading]) {
        archiveHighlightedReadingID = readings.first?.id

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            archiveHighlightedReadingID = nil
        }
    }

    func archiveReading(_ reading: SavedDailyReading, matches query: String) -> Bool {
        [
            reading.theme,
            reading.themeKey ?? "",
            reading.focus ?? "",
            reading.insight ?? "",
            reading.identity ?? "",
            reading.summary,
            reading.mood
        ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(query)
    }

    var archiveHasFocusedMatches: Bool {
        guard let query = archiveFocusQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty
        else {
            return false
        }

        return savedDailyReadings.prefix(8).contains { archiveReading($0, matches: query) }
    }

    func firstNonEmpty(_ values: [String?]) -> String {
        values
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? ""
    }

    func isSafeArchiveTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !containsSuspiciousInternalString(trimmed) else { return false }

        let words = trimmed.split(whereSeparator: \.isWhitespace)
        guard (2...8).contains(words.count) else { return false }
        return words.allSatisfy { word in
            word.allSatisfy { $0.isLetter || $0 == "'" || $0 == "’" || $0 == "-" }
        }
    }

    func containsSuspiciousInternalString(_ value: String) -> Bool {
        let compact = value.lowercased().filter(\.isLetter)
        let blockedFragments = [
            "supabase",
            "structuredrow",
            "legacyrow",
            "rawvalue",
            "dailyritual",
            "localfallback",
            "notreadyfallback",
            "database",
            "transport",
            "entity",
            "object",
            "model",
            "table",
            "uuid"
        ]

        if blockedFragments.contains(where: compact.contains) {
            return true
        }

        if value.range(of: #"\b[a-z]+_[a-z0-9_]+\b"#, options: .regularExpression) != nil {
            return true
        }

        if value.range(of: #"\b[a-z]+[A-Z][A-Za-z0-9]*\b"#, options: .regularExpression) != nil {
            return true
        }

        return value.contains(where: { "/\\|".contains($0) })
    }

    func lowercasedThemeLabel(_ label: String) -> String {
        label.prefix(1).lowercased() + String(label.dropFirst())
    }

    func archiveSignal(from reading: SavedDailyReading) -> PatternArchiveSignal {
        let themes = PatternMemoryLabelFormatter.themeLabels(
            from: [
                reading.versionedLensContent?.title,
                reading.themeKey,
                reading.theme,
                reading.focus,
                reading.insight,
                reading.summary,
                reading.caution
            ],
            limit: 2
        )

        return PatternArchiveSignal(
            title: archiveDisplayTitle(for: reading),
            date: reading.createdAt,
            themes: themes,
            excerpt: archiveDisplayBody(for: reading),
            source: .savedRead
        )
    }

    @ViewBuilder
    func archiveSignalMetadata(_ signal: PatternArchiveSignal) -> some View {
        HStack(spacing: 7) {
            Text(signal.source.label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.muted)

            if let theme = signal.primaryTheme {
                Text(theme)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.premium.opacity(0.92))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ZD.Color.premium.opacity(0.10))
                    )
            }
        }
    }

    func handlePatternMemoryObservation(
        _ target: PatternMemoryObservationTarget,
        scrollProxy: ScrollViewProxy
    ) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        switch target {
        case .savedReads(let query):
            archiveFocusQuery = query
            let focusedReadings = focusedArchiveReadings(for: query)
            if focusedReadings.contains(where: { reading in
                guard let query else { return false }
                return archiveReading(reading, matches: query)
            }) {
                setArchiveHighlight(from: focusedReadings)
            }

            withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) {
                scrollProxy.scrollTo("pattern-archive", anchor: .top)
            }

            if !store.hasAccess(to: .patternArchive) {
                trackPatternMemory(.patternArchiveOpened)
            }
        case .savedProfiles(let query):
            let matches = matchingSavedProfiles(for: query)
            guard !matches.isEmpty else { return }

            savedProfileFocus = PatternMemorySavedProfileFocus(
                title: savedProfileFocusTitle(for: query),
                matches: matches
            )
        case .none:
            break
        }
    }

    func matchingSavedProfiles(for query: String?) -> [SavedMatch] {
        let trimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else {
            return Array(savedMatches.prefix(8))
        }

        let matches = savedMatches.filter { match in
            savedProfileSearchText(for: match)
                .localizedCaseInsensitiveContains(trimmed)
        }

        return Array(matches.prefix(8))
    }

    func savedProfileFocusTitle(for query: String?) -> String {
        let trimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Saved profiles" : "Profiles with \(trimmed)"
    }

    func savedProfileSearchText(for match: SavedMatch) -> String {
        [
            savedProfileIdentity(for: match),
            match.name,
            match.archetypeTitle,
            match.essence,
            match.connectionPrompt,
            match.primaryReasonTitle,
            match.primaryReasonDetail,
            match.secondaryReasonTitle,
            match.secondaryReasonDetail,
            match.intent,
            match.signals.map { [$0.prompt, $0.response].joined(separator: " ") }.joined(separator: " ")
        ]
            .joined(separator: " ")
    }

    func savedProfileIdentity(for match: SavedMatch) -> String {
        guard let western = WesternZodiac(rawValue: match.westernSignRaw)?.displayName,
              let eastern = ChineseZodiac(rawValue: match.chineseSignRaw)?.displayName
        else {
            return "Saved profile"
        }

        return "\(western) × \(eastern)"
    }

    func sectionLabel(title: String, accent: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(accent.opacity(0.9))
    }

    func pacedBody(
        _ text: String,
        leadSize: CGFloat,
        bodySize: CGFloat,
        alignment: TextAlignment = .leading
    ) -> some View {
        let pieces = PatternPageContent.rhythmSentences(from: text)
        let lead = pieces.first ?? text
        let rest = pieces.dropFirst().prefix(1).joined(separator: " ")
        let stackAlignment: HorizontalAlignment = {
            switch alignment {
            case .center:
                return .center
            case .trailing:
                return .trailing
            default:
                return .leading
            }
        }()

        return VStack(alignment: stackAlignment, spacing: rest.isEmpty ? 0 : 9) {
            Text(lead)
                .font(.system(size: leadSize, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(alignment)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if !rest.isEmpty {
                Text(rest)
                    .font(.system(size: bodySize, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .multilineTextAlignment(alignment)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    func traitColumn(label: String, title: String, items: [String], accent: Color) -> some View {
        let visibleItems = items
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .prefix(2)

        return VStack(alignment: .leading, spacing: 11) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(accent.opacity(0.9))

            Text(title)
                .font(.system(size: 21, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(visibleItems), id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle()
                            .fill(accent.opacity(0.7))
                            .frame(width: 5, height: 5)

                        Text(item)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 138, alignment: .topLeading)
    }

    func splitLayerRow(
        title: String,
        body: String,
        alignment: PatternSplitAlignment
    ) -> some View {
        VStack(alignment: alignment.horizontal, spacing: 10) {
            Text(title)
                .font(.system(size: 21, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            pacedBody(body, leadSize: 16, bodySize: 14, alignment: alignment.text)
        }
        .frame(maxWidth: .infinity, alignment: alignment.frame)
        .padding(.vertical, 20)
    }

    func patternSection(
        eyebrow: String,
        title: String,
        body: String,
        tone: PatternTone = .standard
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(2)
                .foregroundStyle(tone.accent)

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            pacedBody(body, leadSize: 17, bodySize: 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 17)
        .background(
            patternPanelBackground(
                cornerRadius: 24,
                accent: tone.accent,
                base: tone.fill.opacity(0.86),
                glow: tone.accent.opacity(0.05)
            )
        )
    }

    var finalPathSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            patternArchiveSection
            connectCTA
        }
    }

    var connectCTA: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.easeInOut(duration: 0.28)) {
                store.selectedTab = .connect
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Who meets you there")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("See where fit, friction, and closeness appear")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ZD.Color.premium.opacity(0.82))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 4)
            .background(
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(ZD.Color.border.opacity(0.18))
                        .frame(height: 1)
                    Spacer()
                    Rectangle()
                        .fill(ZD.Color.border.opacity(0.10))
                        .frame(height: 1)
                }
            )
        }
        .buttonStyle(.plain)
    }

    func patternPanelBackground(
        cornerRadius: CGFloat,
        accent: Color,
        base: Color,
        glow: Color
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        base,
                        base.opacity(0.95),
                        ZD.Color.bg.opacity(0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.14),
                                glow,
                                ZD.Color.border.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(glow)
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)
                .offset(x: 30, y: -36)
                .allowsHitTesting(false)
            }
    }

    var revealSections: [PatternRevealSection] {
        PatternRevealSection.allCases.filter { section in
            if section == .closeCompany {
                return !pattern.compatibilityRead.isEmpty
            }

            return true
        }
    }

    var nextRevealSection: PatternRevealSection? {
        guard revealedSectionCount < revealSections.count else { return nil }
        return revealSections[revealedSectionCount]
    }

    func revealNextSection(scrollProxy: ScrollViewProxy) {
        guard let sectionToReveal = nextRevealSection else { return }

        withAnimation(.spring(response: 0.44, dampingFraction: 0.88)) {
            revealedSectionCount += 1
        }

        if revealedSectionCount >= revealSections.count {
            patternRevealLocked = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.62, dampingFraction: 0.92)) {
                scrollProxy.scrollTo(sectionToReveal.scrollTargetID, anchor: .center)
            }
        }
    }

    func resetPatternReveal(scrollProxy: ScrollViewProxy) {
        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            revealedSectionCount = 0
        }

        patternRevealLocked = false

        withAnimation(.spring(response: 0.44, dampingFraction: 0.9)) {
            scrollProxy.scrollTo("pattern-top", anchor: .top)
        }
    }
}

// MARK: - Actions

private extension PatternView {
    func refreshPresentation() {
        viewModel.refresh(user: store.currentUser, archetype: store.currentArchetype)
    }

    func shareCurrentIdentity() {
        let content = identityCardContent
        guard let shareText = presentation.shareText else { return }
        guard let image = IdentityRevealShareRenderer.renderImage(for: content) else { return }

        sharePayload = SharePayload(activityItems: [shareText, image])

        AnalyticsService.shared.track(
            .identitySharePresented(
                identityID: content.id,
                title: content.identityName,
                source: "pattern"
            )
        )
    }

    struct SharePayload: Identifiable {
        let id = UUID()
        let activityItems: [Any]
    }
}

private struct PatternCinematicMotionModifier: ViewModifier {
    let appeared: Bool
    let entranceOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : entranceOffset)
            .scaleEffect(appeared ? 1 : 0.99)
            .animation(.easeOut(duration: 0.34), value: appeared)
    }
}

private extension View {
    func patternCinematicMotion(
        appeared: Bool,
        entranceOffset: CGFloat
    ) -> some View {
        modifier(
            PatternCinematicMotionModifier(
                appeared: appeared,
                entranceOffset: entranceOffset
            )
        )
    }
}

// MARK: - Atmosphere

private struct PatternAtmosphere: View {
    @State private var breathe = false

    var body: some View {
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(breathe ? 0.20 : 0.12),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(breathe ? 0.12 : 0.07),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 560
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.premium.opacity(breathe ? 0.08 : 0.04),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 30,
                    endRadius: 520
                )
            )
            .overlay(
                Circle()
                    .fill(ZD.Color.accent.opacity(0.10))
                    .frame(width: 240, height: 240)
                    .blur(radius: 18)
                    .offset(x: breathe ? 130 : 110, y: breathe ? -120 : -98)
                    .allowsHitTesting(false)
            )
            .overlay(
                Circle()
                    .stroke(ZD.Color.premium.opacity(0.12), lineWidth: 1)
                    .frame(width: 176, height: 176)
                    .offset(x: breathe ? 122 : 138, y: breathe ? 18 : 8)
                    .allowsHitTesting(false)
            )
            .overlay(
                Circle()
                    .fill(ZD.Color.cardAlt.opacity(0.18))
                    .frame(width: 122, height: 122)
                    .blur(radius: 12)
                    .offset(x: breathe ? -26 : -40, y: breathe ? 148 : 130)
                    .allowsHitTesting(false)
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 6.4).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
    }
}

// MARK: - Presentation
private enum PatternTone {
    case standard
    case accent
    case warning

    var accent: Color {
        switch self {
        case .standard:
            return ZD.Color.muted
        case .accent:
            return ZD.Color.accent
        case .warning:
            return ZD.Color.premium
        }
    }

    var fill: Color {
        switch self {
        case .standard:
            return ZD.Color.card.opacity(0.82)
        case .accent:
            return ZD.Color.card.opacity(0.90)
        case .warning:
            return ZD.Color.cardAlt.opacity(0.82)
        }
    }

    var stroke: Color {
        switch self {
        case .standard:
            return ZD.Color.border.opacity(0.15)
        case .accent:
            return ZD.Color.accent.opacity(0.18)
        case .warning:
            return ZD.Color.premium.opacity(0.16)
        }
    }
}

private enum PatternRevealSection: Int, CaseIterable {
    case howItShowsUp
    case whatGetsInTheWay
    case loveAndFriendship
    case workAndPurpose
    case howYouStayTrue
    case closeCompany
    case finalPath

    var scrollTargetID: String {
        "pattern-reveal-section-\(rawValue)"
    }

    var ctaLabel: String {
        switch self {
        case .howItShowsUp:
            return "See how it shows up"
        case .whatGetsInTheWay:
            return "Reveal what gets in the way"
        case .loveAndFriendship:
            return "Reveal love and friendship"
        case .workAndPurpose:
            return "Reveal work and purpose"
        case .howYouStayTrue:
            return "Reveal how you stay true"
        case .closeCompany:
            return "Reveal close company"
        case .finalPath:
            return "Reveal the final layer"
        }
    }
}

private enum PatternSplitAlignment {
    case leading
    case trailing

    var horizontal: HorizontalAlignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }

    var text: TextAlignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }

    var frame: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

private struct PatternPageContent {
    let id: String
    let combinedName: String
    let title: String
    let tagline: String
    let oneLineRead: String
    let summary: String
    let howYouMove: String
    let shadowRead: String
    let connectionRead: String
    let workRead: String
    let growthRead: String
    let compatibilityRead: String
    let strengths: [String]
    let shadows: [String]

    var primaryStrength: String {
        strengths.first ?? "Clear read"
    }

    var primaryShadow: String {
        shadows.first ?? "Old reaction"
    }

    static func make(
        archetype: Archetype?,
        identity: ZodiacIdentityContent,
        user: UserProfile?
    ) -> PatternPageContent {
        guard let archetype else {
            return fallback(identity: identity, user: user)
        }

        let id = archetype.id.lowercased()
        let western = signPart(id: id, index: 0, fallback: user?.westernSign.displayName ?? "Western")
        let eastern = signPart(id: id, index: 1, fallback: user?.chineseSign.displayName ?? "Eastern")

        let title = clean(archetype.title, fallback: identity.title)
        let tagline = clean(archetype.tagline, fallback: identity.tagline)
        let summary = clean(archetype.overview, fallback: identity.identitySummary)
        let canonicalCopy = [title, tagline, summary].joined(separator: " ")
        let strength = distinctTrait(
            primary: clean(archetype.dominantStrengthTrait, fallback: archetype.strengths.first ?? "Instinct"),
            candidates: (archetype.strengthProfile ?? []) + archetype.strengths,
            avoiding: canonicalCopy,
            role: .strength,
            id: id
        )
        let shadow = distinctTrait(
            primary: clean(archetype.dominantShadowTrait, fallback: archetype.shadows.first ?? "Old reaction"),
            candidates: (archetype.shadowProfile ?? []) + archetype.shadows,
            avoiding: "\(canonicalCopy) \(strength)",
            role: .shadow,
            id: id
        )

        let strengths = visibleTraitList(
            primary: strength,
            values: archetype.strengths,
            avoiding: canonicalCopy
        )
        let shadows = visibleTraitList(
            primary: shadow,
            values: archetype.shadows,
            avoiding: "\(canonicalCopy) \(strength)"
        )
        let howYouMove = distinctSection(
            primary: archetype.howYouMove ?? "",
            alternates: isTooSimilar(identity.workStyle, to: archetype.workStyle)
                ? []
                : [identity.workStyle],
            avoiding: [canonicalCopy, strength, strength, shadow, shadow]
                + Array(strengths.dropFirst())
                + Array(shadows.dropFirst()),
            fallbacks: visibleWindowFallbacks(for: id)
        )
        let connectionRead = connectionRead(
            love: archetype.loveStyle,
            friendship: archetype.friendshipStyle
        )
        let growthRead = growthRead(archetype.growthPath)

        let base = PatternPageContent(
            id: id,
            combinedName: clean(archetype.combinedName, fallback: "\(western) × \(eastern)"),
            title: title,
            tagline: tagline,
            oneLineRead: behavioralTell(
                id: id,
                overview: summary,
                emotionalPattern: archetype.emotionalPattern,
                howYouMove: archetype.howYouMove ?? "",
                growthPath: archetype.growthPath,
                loveStyle: archetype.loveStyle,
                friendshipStyle: archetype.friendshipStyle,
                avoiding: canonicalCopy
            ),
            summary: summary,
            howYouMove: howYouMove,
            shadowRead: shadowRead(emotionalPattern: archetype.emotionalPattern, shadow: shadow),
            connectionRead: connectionRead,
            workRead: workRead(archetype.workStyle),
            growthRead: growthRead,
            compatibilityRead: closeCompanyRead(
                archetype.compatibilityNotes,
                avoiding: connectionRead,
                identityName: title,
                id: id
            ),
            strengths: strengths,
            shadows: shadows
        )

        let refined = editoriallyRefined(base)
        auditVisibleWindow(refined)
        return refined
    }

    static func fallback(identity: ZodiacIdentityContent, user: UserProfile?) -> PatternPageContent {
        let western = user?.westernSign.displayName ?? "Western"
        let eastern = user?.chineseSign.displayName ?? "Eastern"

        let title = clean(identity.title, fallback: "The Hidden Pattern")
        let tagline = clean(identity.tagline, fallback: "Pattern in motion")
        let summary = clean(identity.identitySummary, fallback: "A pattern with gifts, defenses, and a real edge")
        let canonicalCopy = [title, tagline, summary].joined(separator: " ")
        let strength = distinctTrait(
            primary: identity.strengths.first ?? "Instinct",
            candidates: identity.strengths,
            avoiding: canonicalCopy,
            role: .strength,
            id: identity.id
        )
        let shadow = distinctTrait(
            primary: identity.growthEdges.first ?? "Old reaction",
            candidates: identity.growthEdges,
            avoiding: "\(canonicalCopy) \(strength)",
            role: .shadow,
            id: identity.id
        )
        let strengths = visibleTraitList(
            primary: strength,
            values: identity.strengths,
            avoiding: canonicalCopy
        )
        let shadows = visibleTraitList(
            primary: shadow,
            values: identity.growthEdges,
            avoiding: "\(canonicalCopy) \(strength)"
        )
        let howYouMove = distinctSection(
            primary: identity.workStyle,
            alternates: [],
            avoiding: [canonicalCopy, strength, strength, shadow, shadow]
                + Array(strengths.dropFirst())
                + Array(shadows.dropFirst()),
            fallbacks: visibleWindowFallbacks(for: identity.id)
        )
        let connectionRead = connectionRead(
            love: identity.loveStyle,
            friendship: identity.friendshipStyle
        )
        let growthRead = growthRead(identity.ritualPrompt)

        let content = PatternPageContent(
            id: identity.id,
            combinedName: "\(western) × \(eastern)",
            title: title,
            tagline: tagline,
            oneLineRead: behavioralTell(
                id: identity.id,
                overview: summary,
                emotionalPattern: identity.emotionalPattern,
                howYouMove: identity.workStyle,
                growthPath: identity.ritualPrompt,
                loveStyle: identity.loveStyle,
                friendshipStyle: identity.friendshipStyle,
                avoiding: canonicalCopy
            ),
            summary: summary,
            howYouMove: howYouMove,
            shadowRead: shadowRead(emotionalPattern: identity.emotionalPattern, shadow: shadow),
            connectionRead: connectionRead,
            workRead: clean(identity.workStyle, fallback: "Work rewards clear judgment and a steady hand"),
            growthRead: growthRead,
            compatibilityRead: closeCompanyRead(
                identity.communicationStyle,
                avoiding: connectionRead,
                identityName: identity.title,
                id: identity.id
            ),
            strengths: strengths,
            shadows: shadows
        )

        auditVisibleWindow(content)
        return content
    }
}

// MARK: - Copy Builder

private extension PatternPageContent {
    enum TraitRole {
        case strength
        case shadow
    }

    static func behavioralTell(
        id: String,
        overview: String,
        emotionalPattern: String,
        howYouMove: String,
        growthPath: String,
        loveStyle: String,
        friendshipStyle: String,
        avoiding canonicalCopy: String
    ) -> String {
        let source = [
            overview,
            emotionalPattern,
            howYouMove,
            growthPath,
            loveStyle,
            friendshipStyle
        ]
        .joined(separator: " ")
        .lowercased()

        let templates: [String]

        if containsAny(source, ["humor", "joking", "playful", "performance", "entertaining"]) {
            templates = [
                "Humor arrives before honesty.",
                "The joke lands first.",
                "Charm buys time."
            ]
        } else if containsAny(source, ["perfection", "refining", "detail", "exact", "standard", "polish"]) {
            templates = [
                "Improvement never feels finished.",
                "The standard keeps moving.",
                "Completion is the hard part."
            ]
        } else if containsAny(source, ["betrayal", "testing", "test before", "trust takes", "suspicion", "suspicious"]) {
            templates = [
                "Trust is hard won.",
                "Betrayal has a long shadow.",
                "Loyalty remembers."
            ]
        } else if containsAny(source, ["inward", "withdraw", "retreat", "isolation", "disappear", "private internal"]) {
            templates = [
                "You leave before asking.",
                "Feeling others comes first.",
                "Your needs wait."
            ]
        } else if containsAny(source, ["give too much", "giving drains", "overgiving", "provide", "supports others", "supportive"]) {
            templates = [
                "Care becomes responsibility.",
                "Giving becomes expectation.",
                "Duty hides exhaustion."
            ]
        } else if containsAny(source, ["builds, then", "bursts", "accelerating", "stop-start", "waiting too long"]) {
            templates = [
                "Slow decision. Fast action.",
                "The change happens all at once.",
                "Calm until committed.",
                "Stillness breaks suddenly."
            ]
        } else if containsAny(source, ["harmony", "peacekeeping", "smooth", "pleasant", "avoid conflict", "soften"]) {
            templates = [
                "Peace comes before truth.",
                "The room stays easy.",
                "Harmony hides the hard part."
            ]
        } else if containsAny(source, ["freedom", "independence", "space", "leave instead", "hard to pin"]) {
            templates = [
                "Closeness needs an exit.",
                "Freedom keeps one door open.",
                "Commitment needs breathing room."
            ]
        } else if containsAny(source, ["control", "controlled", "structure", "order", "discipline", "plan"]) {
            templates = [
                "Order contains the uncertainty.",
                "Control comes before comfort.",
                "The plan holds everything."
            ]
        } else if containsAny(source, ["adapt", "shifting", "adjust", "changes direction", "many angles"]) {
            templates = [
                "Adaptation hides the first reaction.",
                "The angle changes quickly.",
                "Your position keeps shifting."
            ]
        } else if containsAny(source, ["protect", "protection", "defensive", "shelter", "guard"]) {
            templates = [
                "Protection arrives before permission.",
                "The shield goes up first.",
                "You carry the impact."
            ]
        } else if containsAny(source, ["lead", "leadership", "force", "power", "command", "dominant"]) {
            templates = [
                "Direction arrives before consensus.",
                "The room follows your momentum.",
                "Force settles the question."
            ]
        } else if containsAny(source, ["think", "analysis", "analy", "logic", "mental", "ideas"]) {
            templates = [
                "Understanding arrives before feeling.",
                "The answer keeps unfolding.",
                "Thought outruns experience."
            ]
        } else if containsAny(source, ["emotion", "feeling", "sensitive", "tender", "deeply"]) {
            templates = [
                "The room enters first.",
                "Feeling arrives before clarity.",
                "Composure hides the current."
            ]
        } else if containsAny(source, ["quick", "fast", "impulsive", "act before", "rush"]) {
            templates = [
                "Action arrives before context.",
                "The first surge decides.",
                "Understanding catches up later."
            ]
        } else {
            templates = [
                "The real reaction stays underneath.",
                "The shift gets noticed early.",
                "Composure buys decision time."
            ]
        }

        return selectBehavioralTell(
            templates,
            id: id,
            avoiding: canonicalCopy
        )
    }

    static func containsAny(_ source: String, _ terms: [String]) -> Bool {
        terms.contains { source.contains($0) }
    }

    static func selectBehavioralTell(
        _ templates: [String],
        id: String,
        avoiding canonicalCopy: String
    ) -> String {
        let start = stableVariant(for: "\(id)-behavioral-tell", count: templates.count)

        for offset in 0..<templates.count {
            let candidate = templates[(start + offset) % templates.count]
            if repeatedRoots(introducedBy: candidate, into: canonicalCopy).isEmpty {
                return candidate
            }
        }

        let fallbacks = [
            "The real reaction comes later.",
            "The deeper position stays hidden.",
            "The first response stays measured.",
            "The decision forms underneath."
        ]
        let fallbackStart = stableVariant(for: "\(id)-behavioral-tell-fallback", count: fallbacks.count)

        for offset in 0..<fallbacks.count {
            let candidate = fallbacks[(fallbackStart + offset) % fallbacks.count]
            if repeatedRoots(introducedBy: candidate, into: canonicalCopy).isEmpty {
                return candidate
            }
        }

        return fallbacks[fallbackStart]
    }

    static func editoriallyRefined(_ content: PatternPageContent) -> PatternPageContent {
        guard content.id == "libra-snake" else { return content }

        return PatternPageContent(
            id: content.id,
            combinedName: content.combinedName,
            title: content.title,
            tagline: content.tagline,
            oneLineRead: "Ease first. Truth later.",
            summary: content.summary,
            howYouMove: "You read the room quickly and shape your response with care. You reveal your real position once the tone feels trustworthy.",
            shadowRead: "You start testing the effort instead of naming what feels uneven. Distance grows while everyone else is still guessing.",
            connectionRead: "Mutual effort keeps you engaged. Repeated ambiguity makes you stop explaining and start withdrawing.",
            workRead: content.workRead,
            growthRead: content.growthRead,
            compatibilityRead: "Direct, self-possessed people suit you best. They meet care halfway and do not turn honesty into conflict.",
            strengths: [
                "Diplomatic",
                "Holds more than one perspective at once",
                "Keeps difficult moments socially workable"
            ],
            shadows: [
                "Withholding",
                "Tracks effort without explaining the standard",
                "Lets people guess instead of naming it"
            ]
        )
    }

    static func shadowRead(emotionalPattern: String, shadow: String) -> String {
        let source = clean(emotionalPattern, fallback: "")
        if !source.isEmpty {
            if isTooSimilar(source, to: shadow) {
                if let distinct = distinctSentence(in: source, avoiding: [shadow]) {
                    return sentence(distinct)
                }

                return "Pressure makes the private reaction louder before the full picture lands."
            }

            return sentence(source)
        }

        return "Pressure makes the private reaction louder before the full picture lands."
    }

    static func connectionRead(love: String, friendship: String) -> String {
        let parts = [love, friendship]
            .map { clean($0, fallback: "") }
            .filter { !$0.isEmpty }
            .map { sentence($0) }

        if parts.isEmpty {
            return "You open more when the effort feels mutual"
        }

        return parts.joined(separator: " ")
    }

    static func workRead(_ value: String) -> String {
        let work = clean(value, fallback: "")
        if work.isEmpty { return "Work rewards clear judgment and a steady hand" }

        return sentence(work)
    }

    static func growthRead(_ value: String) -> String {
        let growth = clean(value, fallback: "")
        if growth.isEmpty { return "Name the pattern before you obey it" }

        return sentence(growth)
    }

    static func closeCompanyRead(
        _ value: String?,
        avoiding connectionRead: String,
        identityName: String,
        id: String
    ) -> String {
        let source = clean(value, fallback: "")
        if let distinct = distinctSentence(in: source, avoiding: [connectionRead]) {
            return sentence(distinct)
        }

        return closeCompanyFallback(identityName: identityName, id: id)
    }

}

// MARK: - Text Helpers

private extension PatternPageContent {
    static func signPart(id: String, index: Int, fallback: String) -> String {
        let parts = id.split(separator: "-").map(String.init)
        guard parts.indices.contains(index) else { return fallback }
        return parts[index].capitalized
    }

    static func clean(_ value: String?, fallback: String) -> String {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    static func cleanedList(_ values: [String], fallback: [String]) -> [String] {
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return cleaned.isEmpty ? fallback : cleaned
    }

    static func visibleTraitList(
        primary: String,
        values: [String],
        avoiding source: String
    ) -> [String] {
        let cleanedPrimary = primary.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedValues = cleanedList(values, fallback: [])
        var result = cleanedPrimary.isEmpty ? [] : [cleanedPrimary]
        var visibleCopy = "\(source) \(cleanedPrimary) \(cleanedPrimary)"
        let minimumSupportingItemCount = 2

        for value in cleanedValues {
            guard !result.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) else {
                continue
            }

            if repeatedRoots(introducedBy: value, into: visibleCopy).isEmpty {
                result.append(value)
                visibleCopy += " \(value)"
            }
        }

        for value in cleanedValues where supportingTraitCount(in: result, primary: cleanedPrimary) < minimumSupportingItemCount {
            guard !result.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) else {
                continue
            }

            result.append(value)
        }

        return result
    }

    static func supportingTraitCount(in values: [String], primary: String) -> Int {
        values.filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(primary.trimmingCharacters(in: .whitespacesAndNewlines)) != .orderedSame
        }.count
    }

    static func distinctTrait(
        primary: String,
        candidates: [String],
        avoiding source: String,
        role: TraitRole,
        id: String
    ) -> String {
        let forbiddenRoots = Set(meaningfulRoots(source))
        let ordered = [primary] + candidates

        if let candidate = ordered.first(where: { candidate in
            let candidateRoots = Set(meaningfulRoots(candidate))
            guard !candidateRoots.isEmpty else { return false }
            return candidateRoots.isDisjoint(with: forbiddenRoots)
        }) {
            return candidate
        }

        let fallbacks: [String]
        switch role {
        case .strength:
            fallbacks = ["Resolve", "Range", "Presence", "Judgment", "Composure", "Instinct"]
        case .shadow:
            fallbacks = ["Friction", "Distance", "Hesitation", "Overreach", "Deflection", "Rigidity"]
        }

        let start = stableVariant(for: "\(id)-\(role)", count: fallbacks.count)
        for offset in 0..<fallbacks.count {
            let value = fallbacks[(start + offset) % fallbacks.count]
            if Set(meaningfulRoots(value)).isDisjoint(with: forbiddenRoots) {
                return value
            }
        }

        return fallbacks[start]
    }

    static func distinctSection(
        primary: String,
        alternates: [String],
        avoiding previousSections: [String],
        fallbacks: [String]
    ) -> String {
        let candidates = [primary] + alternates
        let forbiddenRoots = Set(
            previousSections.prefix(5).flatMap { meaningfulRoots($0) }
        )

        for candidate in candidates {
            let cleaned = clean(candidate, fallback: "")
            guard !cleaned.isEmpty else { continue }
            let candidateRoots = Set(meaningfulRoots(cleaned))

            if candidateRoots.isDisjoint(with: forbiddenRoots),
               previousSections.allSatisfy({ !isTooSimilar(cleaned, to: $0) }),
               repeatedRoots(introducedBy: cleaned, into: previousSections.joined(separator: " ")).isEmpty {
                return sentence(cleaned)
            }

            if let distinct = distinctSentence(in: cleaned, avoiding: previousSections),
               Set(meaningfulRoots(distinct)).isDisjoint(with: forbiddenRoots),
               repeatedRoots(introducedBy: distinct, into: previousSections.joined(separator: " ")).isEmpty {
                return sentence(distinct)
            }
        }

        for fallback in fallbacks {
            if Set(meaningfulRoots(fallback)).isDisjoint(with: forbiddenRoots),
               repeatedRoots(introducedBy: fallback, into: previousSections.joined(separator: " ")).isEmpty {
                return sentence(fallback)
            }
        }

        return sentence(fallbacks.first ?? "The pattern becomes clearest under pressure.")
    }

    static func distinctSentence(in value: String, avoiding previousSections: [String]) -> String? {
        let candidates = rhythmSentences(from: value)

        return candidates.first { candidate in
            let cleaned = clean(candidate, fallback: "")
            guard !cleaned.isEmpty else { return false }
            return previousSections.allSatisfy { !isTooSimilar(cleaned, to: $0) }
        }
    }

    static func isTooSimilar(_ lhs: String, to rhs: String) -> Bool {
        let left = contentWords(lhs)
        let right = contentWords(rhs)
        guard !left.isEmpty, !right.isEmpty else { return false }

        if left == right {
            return true
        }

        let leftSet = Set(left)
        let rightSet = Set(right)
        let sharedCount = leftSet.intersection(rightSet).count
        let shorterCount = min(leftSet.count, rightSet.count)
        let tokenOverlap = Double(sharedCount) / Double(max(shorterCount, 1))

        return tokenOverlap >= 0.58 || hasSharedPhrase(left, right, length: 3)
    }

    static func hasSharedPhrase(_ lhs: [String], _ rhs: [String], length: Int) -> Bool {
        guard lhs.count >= length, rhs.count >= length else { return false }

        let leftPhrases = Set(
            (0...(lhs.count - length)).map { index in
                lhs[index..<(index + length)].joined(separator: " ")
            }
        )

        return (0...(rhs.count - length)).contains { index in
            leftPhrases.contains(rhs[index..<(index + length)].joined(separator: " "))
        }
    }

    static func closeCompanyFallback(identityName: String, id: String) -> String {
        switch stableVariant(for: "\(id)-company", count: 4) {
        case 0:
            return "The closest people make directness feel safe."
        case 1:
            return "Strong company meets the real pace without forcing it."
        case 2:
            return "The right people leave less room for guesswork."
        default:
            let title = clean(identityName, fallback: "This pattern")
            return "\(title) stays closest to people who can be clear without becoming forceful."
        }
    }

    static func stableVariant(for value: String, count: Int) -> Int {
        guard count > 0 else { return 0 }

        let total = value.unicodeScalars.enumerated().reduce(0) { partial, pair in
            partial &+ ((pair.offset + 1) * Int(pair.element.value))
        }

        return abs(total) % count
    }

    static func visibleWindowFallbacks(for id: String) -> [String] {
        let values = [
            "You gather the signal first, then commit cleanly.",
            "You take in the room before choosing a clear position.",
            "You hold your response until the opening feels exact.",
            "Internal pressure builds quietly, then becomes decisive action.",
            "You shape the conditions first, then act without excess.",
            "You gather force quietly, then act all at once.",
            "You hold the line until the choice feels worth the cost.",
            "You let the pattern settle before making the decisive turn.",
            "You create room first, then reveal the firmer edge.",
            "You absorb more than you show, then respond with precision."
        ]
        let start = stableVariant(for: "\(id)-visible-window", count: values.count)

        return (0..<values.count).map { offset in
            values[(start + offset) % values.count]
        }
    }

    static func meaningfulRoots(_ value: String) -> [String] {
        let aliases: [String: String] = [
            "balance": "balance", "balanced": "balance", "balancing": "balance",
            "imbalance": "balance", "imbalanced": "balance",
            "adapt": "adapt", "adaptable": "adapt", "adaptive": "adapt",
            "ambition": "ambition", "ambitious": "ambition",
            "anxiety": "anxious", "anxious": "anxious",
            "avoidance": "avoid", "avoidant": "avoid", "avoiding": "avoid",
            "calm": "calm", "calmer": "calm", "calmness": "calm",
            "care": "care", "caring": "care", "careful": "care", "carefully": "care",
            "clear": "clear", "clearer": "clear", "clearly": "clear", "clarity": "clear",
            "close": "close", "closer": "close", "closeness": "close",
            "confidence": "confident", "confident": "confident",
            "consistency": "consistent", "consistent": "consistent",
            "control": "control", "controlled": "control", "controlling": "control",
            "creative": "create", "creativity": "create",
            "curiosity": "curious", "curious": "curious",
            "decision": "decide", "decisive": "decide",
            "discipline": "discipline", "disciplined": "discipline",
            "direct": "direct", "directly": "direct", "directness": "direct",
            "drive": "drive", "driven": "drive", "drives": "drive", "driving": "drive",
            "focus": "focus", "focused": "focus",
            "free": "free", "freedom": "free",
            "grounded": "ground", "grounding": "ground",
            "hesitant": "hesitate", "hesitation": "hesitate",
            "honest": "honest", "honesty": "honest",
            "impulse": "impulsive", "impulsive": "impulsive",
            "independence": "independent", "independent": "independent",
            "intuition": "intuitive", "intuitive": "intuitive",
            "lead": "lead", "leader": "lead", "leading": "lead", "leadership": "lead",
            "loyal": "loyal", "loyalty": "loyal",
            "move": "move", "moved": "move", "moves": "move", "moving": "move",
            "movement": "move", "momentum": "move", "motion": "move",
            "open": "open", "opened": "open", "opening": "open", "openness": "open",
            "patience": "patient", "patient": "patient",
            "perception": "perceptive", "perceptive": "perceptive",
            "power": "power", "powerful": "power",
            "precise": "precise", "precision": "precise",
            "private": "private", "privacy": "private",
            "protect": "protect", "protected": "protect", "protecting": "protect",
            "protection": "protect", "protective": "protect",
            "quiet": "quiet", "quietly": "quiet",
            "reaction": "reactive", "reactive": "reactive",
            "reliable": "reliable", "reliability": "reliable",
            "resistance": "resist", "resistant": "resist",
            "restless": "restless", "restlessness": "restless",
            "rigid": "rigid", "rigidity": "rigid",
            "safe": "safe", "safety": "safe",
            "sensitive": "sensitive", "sensitivity": "sensitive",
            "soft": "soft", "softness": "soft",
            "stable": "steady", "stability": "steady", "steady": "steady",
            "steadiness": "steady", "steadily": "steady",
            "strong": "strong", "strength": "strong",
            "trust": "trust", "trusted": "trust", "trusting": "trust",
            "warm": "warm", "warmer": "warm", "warmth": "warm"
        ]
        let stopWords = Set([
            "about", "after", "again", "against", "almost", "already", "always",
            "another", "around", "because", "become", "becomes", "before", "being",
            "between", "both", "comes", "could", "does", "doing", "enough",
            "even", "every", "everything", "first", "gets", "going", "hard",
            "inside", "keeps", "longer", "looks", "makes", "often", "once",
            "other", "others", "people", "really", "right", "something", "stays",
            "still", "takes", "things", "through", "together", "under", "until",
            "want", "wants", "without", "situations", "quickly", "emotional",
            "pressure"
        ])

        return value
            .lowercased()
            .split { !$0.isLetter }
            .map(String.init)
            .compactMap { word in
                if let alias = aliases[word] {
                    return alias
                }

                guard word.count > 4,
                      !stopWords.contains(word),
                      !contentStopWords.contains(word) else {
                    return nil
                }

                if word.hasSuffix("ies"), word.count > 6 {
                    return String(word.dropLast(3)) + "y"
                }
                if word.hasSuffix("ing"), word.count > 7 {
                    return String(word.dropLast(3))
                }
                if word.hasSuffix("ed"), word.count > 6 {
                    return String(word.dropLast(2))
                }

                return word
            }
    }

    static func repeatedRoots(introducedBy candidate: String, into existing: String) -> Set<String> {
        let existingCounts = Dictionary(grouping: meaningfulRoots(existing), by: { $0 })
            .mapValues(\.count)
        let candidateCounts = Dictionary(grouping: meaningfulRoots(candidate), by: { $0 })
            .mapValues(\.count)

        return Set(candidateCounts.compactMap { root, count in
            (existingCounts[root, default: 0] + count >= 3) ? root : nil
        })
    }

    static func visibleWindowRepeatReport(_ content: PatternPageContent) -> [String: Int] {
        let visibleCopy = [
            content.title,
            content.tagline,
            content.summary,
            content.oneLineRead,
            content.primaryStrength,
            content.primaryShadow,
            content.strengths.dropFirst().prefix(2).joined(separator: " "),
            content.shadows.dropFirst().prefix(2).joined(separator: " "),
            rhythmSentences(from: content.howYouMove).first ?? content.howYouMove
        ].joined(separator: " ")

        return Dictionary(grouping: meaningfulRoots(visibleCopy), by: { $0 })
            .mapValues(\.count)
            .filter { $0.value >= 3 }
    }

    static func auditVisibleWindow(_ content: PatternPageContent) {
#if DEBUG
        auditTell(content)

        let canonicalCopy = [content.title, content.tagline, content.summary].joined(separator: " ")
        let canonicalCounts = Dictionary(grouping: meaningfulRoots(canonicalCopy), by: { $0 })
            .mapValues(\.count)
        let fullReport = visibleWindowRepeatReport(content)
        let downstreamAmplified = fullReport.filter { root, count in
            count > canonicalCounts[root, default: 0]
        }

        if downstreamAmplified.isEmpty {
            print("[PatternVisibleWindowAudit] \(content.id): pass")
        } else {
            let details = downstreamAmplified
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            print("[PatternVisibleWindowAudit] \(content.id): \(details)")
        }
#endif
    }

    static func auditTell(_ content: PatternPageContent) {
#if DEBUG
        let normalizedTell = content.oneLineRead.lowercased()
        let mechanicalPhrases = [
            "people first read you as",
            "at first, you register as",
            "is the gift",
            "takes longer to understand",
            "visible strength",
            "the first read is",
            "the closer read is"
        ]
        let insertedLabels = [content.primaryStrength, content.primaryShadow]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty && containsTokenPhrase(normalizedTell, phrase: $0) }
        let wordCount = content.oneLineRead.split { !$0.isLetter }.count
        let hasComma = content.oneLineRead.contains(",")

        if mechanicalPhrases.contains(where: normalizedTell.contains)
            || !insertedLabels.isEmpty
            || wordCount > 10
            || hasComma {
            let labels = insertedLabels.joined(separator: ", ")
            print(
                "[PatternTellAudit] \(content.id): mechanical=true "
                    + "labels=\(labels) words=\(wordCount) comma=\(hasComma)"
            )
        } else if content.oneLineRead.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("[PatternTellAudit] \(content.id): blank")
        } else {
            print("[PatternTellAudit] \(content.id): pass")
        }
#endif
    }

    static func containsTokenPhrase(_ source: String, phrase: String) -> Bool {
        let sourceTokens = source.split { !$0.isLetter }.map(String.init)
        let phraseTokens = phrase.split { !$0.isLetter }.map(String.init)
        guard !phraseTokens.isEmpty, sourceTokens.count >= phraseTokens.count else { return false }

        return (0...(sourceTokens.count - phraseTokens.count)).contains { index in
            Array(sourceTokens[index..<(index + phraseTokens.count)]) == phraseTokens
        }
    }

    static let contentStopWords = Set([
        "also", "from", "feel", "feels", "feeling", "feelings", "have", "into",
        "just", "more", "most", "only", "than", "that", "their", "them", "then",
        "there", "they", "this", "very", "what", "when", "where", "which", "while",
        "will", "with", "would", "your"
    ])

    static func contentWords(_ value: String) -> [String] {
        return value
            .lowercased()
            .split { !$0.isLetter }
            .map(String.init)
            .filter { $0.count > 3 && !contentStopWords.contains($0) }
    }

    static func normalizedCopy(_ value: String) -> String {
        contentWords(value).joined(separator: " ")
    }

    static func sentence(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        if trimmed.hasSuffix(".") || trimmed.hasSuffix("!") || trimmed.hasSuffix("?") {
            return trimmed
        }

        return "\(trimmed)."
    }

    static func rhythmSentences(from value: String) -> [String] {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var sentences: [String] = []
        var current = ""

        for character in trimmed {
            current.append(character)
            if ".!?".contains(character) {
                let piece = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !piece.isEmpty {
                    sentences.append(piece)
                }
                current = ""
            }
        }

        let remainder = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !remainder.isEmpty {
            sentences.append(remainder)
        }

        return sentences.isEmpty ? [trimmed] : sentences
    }

    static func sentenceStartWithoutPeriod(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        return trimmed.prefix(1).uppercased() + trimmed.dropFirst()
    }

    static func displayIdentityWord(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        switch trimmed.lowercased() {
        case "warm":
            return "Warmth"
        case "private":
            return "Privacy"
        case "diplomatic":
            return "Diplomacy"
        case "holds back":
            return "Withholding"
        default:
            return sentenceStartWithoutPeriod(trimmed)
        }
    }

    static func compactParagraph(_ value: String, fallback: String) -> String {
        let text = Self.clean(value, fallback: fallback)
        let firstSentence = text
            .split(whereSeparator: { ".!?".contains($0) })
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? text

        let words = firstSentence.split(separator: " ").prefix(14).map(String.init)
        guard !words.isEmpty else { return fallback }

        return Self.ensureTerminalPeriod(words.joined(separator: " "))
    }

    static func summaryLead(_ value: String) -> String {
        let sentence = value
            .split(whereSeparator: { ".!?".contains($0) })
            .first
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? value

        let words = sentence.split(separator: " ").prefix(10).map(String.init)
        let lead = words.joined(separator: " ")
        guard !lead.isEmpty else { return value }
        return Self.ensureTerminalPeriod(lead)
    }

    static func ensureTerminalPeriod(_ value: String) -> String {
        let trimmed = stripTerminalPunctuation(value)
        guard !trimmed.isEmpty else { return trimmed }
        return "\(trimmed)."
    }

    static func stripTerminalPunctuation(_ value: String) -> String {
        var trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = trimmed.last, ".!?".contains(last) {
            trimmed.removeLast()
            trimmed = trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }
}
