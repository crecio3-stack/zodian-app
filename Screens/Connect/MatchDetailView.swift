//
//  MatchDetailView.swift
//  Zodian
//

import SwiftUI
import SwiftData

struct MatchDetailView: View {
    let match: SavedMatch

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var savedMatches: [SavedMatch]
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]

    @State private var showLetGoAlert = false

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(match: match)
    }

    private var hasUserSentFirstMessage: Bool {
        match.hasSentFirstMessage || allMessages.contains {
            $0.matchID == match.id && $0.sender == .me
        }
    }

    private var isAwaitingFirstMessage: Bool {
        !hasUserSentFirstMessage
    }

    private var matchStyle: MatchStyle {
        MatchStyle(rawValue: match.matchStyleRaw) ?? .growth
    }

    private var rememberedFeelingCopy: String {
        presentation.compatibilitySummarySavedMatch
    }

    private var openToText: String {
        let trimmed = match.intent.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Open" : trimmed
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                heroSection
                feelingSection

                if !match.signals.isEmpty {
                    signalsSection(match.signals)
                }

                keptSection

                tensionSection

                openToSection

                conversationSection
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 12)
        }
        .background(backgroundView)
        .navigationTitle(match.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLetGoAlert = true
                } label: {
                    Text("Let Go")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(ZD.Color.accent)
                .accessibilityLabel("Let go")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            dismissIfMatchWasRemoved()
        }
        .onChange(of: savedMatches.count) { _ in
            dismissIfMatchWasRemoved()
        }
        .alert("Let this go?", isPresented: $showLetGoAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Let Go", role: .destructive) {
                deleteMatch()
            }
        } message: {
            Text("This removes them from My Circle.")
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            ZD.Color.bg

            LinearGradient(
                colors: [
                    ZD.Color.card.opacity(0.24),
                    .clear,
                    ZD.Color.cardAlt.opacity(0.22)
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

            matchStarField
        }
        .ignoresSafeArea()
    }

    private var matchStarField: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let stars: [(CGFloat, CGFloat, CGFloat, Double)] = [
                (0.18, 0.09, 1.3, 0.22),
                (0.78, 0.12, 1.5, 0.20),
                (0.90, 0.26, 1.1, 0.16),
                (0.12, 0.36, 1.4, 0.14),
                (0.66, 0.44, 1.2, 0.15),
                (0.28, 0.62, 1.0, 0.12),
                (0.84, 0.70, 1.3, 0.13)
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

    private func dismissIfMatchWasRemoved() {
        guard !savedMatches.contains(where: { $0.id == match.id }) else { return }
        dismiss()
    }

    private func deleteMatch() {
        let relatedMessages = allMessages.filter { $0.matchID == match.id }
        let hadChatHistory = !relatedMessages.isEmpty

        relatedMessages.forEach { context.delete($0) }
        context.delete(match)

        do {
            try context.save()
            AnalyticsService.shared.track(
                .matchDeleted(
                    matchID: match.id.uuidString,
                    archetypeID: match.archetypeId,
                    hadChatHistory: hadChatHistory
                )
            )
            PatternMemoryService.shared.track(
                event: PatternMemoryEvent.savedProfileEvent(type: .profileUnsaved, match: match)
            )
        } catch {
            print("❌ Failed to delete match from detail view: \(error)")
        }

        dismiss()
    }

    // MARK: - Sections

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { proxy in
                    ConnectProfileImage(
                        assetName: match.imageName,
                        size: proxy.size,
                        focalPoint: ConnectPresentation.focalPoint(for: match.imageAnchorRaw),
                        clipShape: .roundedRectangle(28)
                    )
                }

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.02),
                        Color.black.opacity(0.10),
                        Color.black.opacity(0.34),
                        Color.black.opacity(0.84)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.10),
                        .clear,
                        ZD.Color.card.opacity(0.18)
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )

                HStack(alignment: .top) {
                    Spacer()
                    memoryBadge
                }
                .padding(ZD.Spacing.m)
                .frame(maxHeight: .infinity, alignment: .top)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 6) {
                        Text(match.name)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .layoutPriority(1)

                        styleChip("Saved")
                    }

                    heroOpenToPill
                }
                .padding(ZD.Spacing.m)
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(ZD.Color.accent.opacity(0.18), lineWidth: ZD.Stroke.thin)
            )
            .shadow(color: ZD.Color.shadow.opacity(0.42), radius: 18, x: 0, y: 12)

        }
    }

    private var feelingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What it feels like")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.9)

            Text(rememberedFeelingCopy)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    ZD.Color.card.opacity(0.18),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var savedContextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("What stayed with you")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            Text(savedContextCopy)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }

    private var savedContextCopy: String {
        if let secondary = rememberedLine(match.secondaryReasonDetail) {
            return secondary
        }

        if let primary = rememberedLine(match.primaryReasonDetail) {
            return primary
        }

        if let prompt = rememberedLine(match.connectionPrompt) {
            return prompt
        }

        return rememberedFallbackDetail
    }

    private var keptSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What stayed with you")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(1.4)

            Text(savedReasonCopy)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary.opacity(0.92))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if let contextCopy = savedContextDetailCopy {
                Text(contextCopy)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 14)
    }

    private var tensionSection: some View {
        subtlePanel {
            VStack(alignment: .leading, spacing: 6) {
                Text("One tension")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.94))
                    .textCase(.uppercase)
                    .tracking(0.82)

                Text(tensionCopy)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var openToSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Open to")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.8)

            HStack(spacing: 10) {
                Text(openToText)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(
                Capsule(style: .continuous)
                    .fill(ZD.Color.cardAlt.opacity(0.72))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.18), lineWidth: ZD.Stroke.thin)
                    )
            )
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    private func detailSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .tracking(0.8)

            Text(content)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
    }

    private func signalsSection(_ signals: [ConnectProfileSignal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detail")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.9)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(signals.prefix(2).enumerated()), id: \.offset) { index, signal in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vibePrompt(for: index))
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(refinedSignalResponse(signal.response))
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.92),
                                ZD.Color.cardAlt.opacity(0.82)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.18), lineWidth: ZD.Stroke.thin)
                    )
            )
        }
    }

    private var conversationSection: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 12) {
	                Text(isAwaitingFirstMessage ? "START WITH WHAT YOU NOTICED" : "KEEP NOTICING")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(conversationPromptCopy)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    ChatView(match: match)
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .semibold))

	                        Text(isAwaitingFirstMessage ? "Start a note" : "Return to notes")
                            .font(ZD.Font.button())
                            .tracking(0.3)

                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                            .fill(ZD.Gradient.gold)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                            .stroke(ZD.Color.accentSoft.opacity(0.45), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.glow.opacity(0.78), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var conversationPromptCopy: String {
        guard isAwaitingFirstMessage else {
            return "Return to what you started noticing"
        }

        if match.isFirstMessageAtRisk {
	            return "This profile is still open"
        }

	        return "Something about this person made you pause. Start there"
    }

    private func matchPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
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

    private func subtlePanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(ZD.Color.card.opacity(0.58))
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.12), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.shadow.opacity(0.12), radius: 8, x: 0, y: 4)
            )
    }

    // MARK: - Components

    private var memoryBadge: some View {
        Text(memoryBadgeText)
            .font(.system(size: 9, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.68))
            .tracking(0.9)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            ZD.Color.cardAlt.opacity(0.20)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.89, green: 0.77, blue: 0.52).opacity(0.18), lineWidth: ZD.Stroke.thin)
                )
        )
        .shadow(color: ZD.Color.accent.opacity(0.08), radius: 8, y: 3)
    }

    private var heroOpenToPill: some View {
        Text(openToText)
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(Color.white.opacity(0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.26))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(ZD.Color.accent.opacity(0.18), lineWidth: ZD.Stroke.thin)
                    )
            )
            .fixedSize(horizontal: false, vertical: true)
    }

    private func styleChip(_ text: String) -> some View {
        Text(text)
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ZD.Gradient.gold)
            )
            .fixedSize()
    }

    private func quickStatPill(title: String, systemName: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt.opacity(0.84))
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.border.opacity(0.32), lineWidth: ZD.Stroke.thin)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var savedReasonCopy: String {
        switch matchStyle {
        case .harmonious:
            return "You came back to how little effort it asked from you"
        case .mirrored:
            return "You came back to the part that felt quietly familiar"
        case .growth:
            return "You came back because something still felt unfinished"
        case .magnetic:
            return "You came back because the curiosity did not close"
        case .intense:
            return "You came back because the moment kept replaying"
        }
    }

    private var memoryBadgeText: String {
        switch matchStyle {
        case .harmonious:
            return "STAYED"
        case .mirrored:
            return "RETURNED"
        case .growth:
            return "UNFINISHED"
        case .magnetic:
            return "STAYED"
        case .intense:
            return "REPLAYED"
        }
    }

    private func vibePrompt(for index: Int) -> String {
        let prompts = [
            "How they move",
            "What stands out",
            "What stays with you"
        ]

        return prompts.indices.contains(index) ? prompts[index] : "Worth noticing"
    }

    private func refinedSignalResponse(_ response: String) -> String {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)

        switch trimmed.lowercased() {
        case "i change my mind":
            return "i change my mind a lot"
        default:
            return trimmed
        }
    }

    private var rememberedFallbackDetail: String {
        switch matchStyle {
        case .harmonious:
            return "You stopped managing the conversation and started having it"
        case .mirrored:
            return "You felt understood without explaining everything"
        case .growth:
            return "You answered differently around them"
        case .magnetic:
            return "The curiosity kept returning after the first impression"
        case .intense:
            return "The moment kept unfolding after it was over"
        }
    }

    private var savedContextDetailCopy: String? {
        guard !matchesExistingMemoryCopy(savedContextCopy) else { return nil }
        return savedContextCopy
    }

    private func matchesExistingMemoryCopy(_ value: String) -> Bool {
        let normalized = normalizedCopy(value)
        return normalized == normalizedCopy(savedReasonCopy)
            || normalized == normalizedCopy(rememberedFeelingCopy)
    }

    private func normalizedCopy(_ value: String) -> String {
        value
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
            .split(separator: " ")
            .joined(separator: " ")
    }

    private var tensionCopy: String {
        let trimmed = match.frictionNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return fallbackTensionCopy
        }

        let lower = trimmed.lowercased()
        if containsAny(lower, [
            "zodiac",
            "western",
            "eastern",
            "sign",
            "archetype",
            "compatibility",
            "percentage",
            "percent",
            "score",
            "pull score",
            "instinct",
            "rhythm",
            "energy",
            "chemistry",
            "line up",
            "element",
            "leo",
            "gemini",
            "aries",
            "taurus",
            "cancer",
            "virgo",
            "libra",
            "scorpio",
            "sagittarius",
            "capricorn",
            "aquarius",
            "pisces",
            "rat",
            "ox",
            "tiger",
            "rabbit",
            "dragon",
            "snake",
            "horse",
            "goat",
            "monkey",
            "rooster",
            "dog",
            "pig"
        ]) {
            return fallbackTensionCopy
        }

        return trimmed
    }

    private var fallbackTensionCopy: String {
        switch matchStyle {
        case .harmonious:
            return "One of you may name comfort sooner than the other"
        case .mirrored:
            return "You may recognize the same feeling for different reasons"
        case .growth:
            return "They move faster than your certainty"
        case .magnetic:
            return "You keep returning to different moments"
        case .intense:
            return "What feels obvious to one of you may take longer for the other"
        }
    }

    private var memorySourceText: String {
        [
            match.essence,
            match.connectionPrompt,
            match.primaryReasonDetail,
            match.secondaryReasonDetail,
            match.intent,
            match.signals.map(\.response).joined(separator: " ")
        ]
            .joined(separator: " ")
            .lowercased()
    }

    private func rememberedLine(_ rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let lower = trimmed.lowercased()
        guard !containsAny(lower, [
            "zodiac",
            "western",
            "eastern",
            "sign",
            "archetype",
            "compatibility",
            "score",
            "percent",
            "%",
            "pull score",
            "instinct",
            "rhythm",
            "energy",
            "chemistry",
            "element",
            "side meets",
            "pace and",
            "line up",
            "your leo",
            "their gemini",
            "gemini pace",
            "dragon pace"
        ]) else { return nil }

        return trimmed
    }

    private func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }

}

#Preview {
    NavigationStack {
        MatchDetailView(
            match: SavedMatch(
                name: "Selene",
                archetypeId: "libra-snake",
                archetypeTitle: "The Velvet Dagger",
                westernSignRaw: "libra",
                chineseSignRaw: "snake",
                compatibilityScore: 92,
                matchStyleRaw: "magnetic",
                essence: "Pretty easy to get along with, I just take a minute to open up",
                connectionPrompt: "Feels easy at first — then something shifts",
                frictionNote: "Both of you hold back at first, which can slow things down",
                intent: "Something real",
                imageName: "selene",
                imageAnchorRaw: "top",
                primaryReasonTitle: "Magnetic Contrast",
                primaryReasonDetail: "Differences create enough tension to keep the read open."
            )
        )
    }
    .preferredColorScheme(.dark)
}
