//
//  MatchDetailView.swift
//  Zodian
//

import SwiftUI
import SwiftData

struct MatchDetailView: View {
    let match: SavedMatch

    @Environment(\.dismiss) private var dismiss
    @Query private var savedMatches: [SavedMatch]
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(match: match)
    }

    private var westernSign: WesternZodiac? {
        WesternZodiac(rawValue: match.westernSignRaw)
    }

    private var chineseSign: ChineseZodiac? {
        ChineseZodiac(rawValue: match.chineseSignRaw)
    }

    private var matchStyle: MatchStyle? {
        MatchStyle(rawValue: match.matchStyleRaw)
    }

    private var hasUserSentFirstMessage: Bool {
        match.hasSentFirstMessage || allMessages.contains {
            $0.matchID == match.id && $0.sender == .me
        }
    }

    private var isAwaitingFirstMessage: Bool {
        !hasUserSentFirstMessage
    }

    private var compatibilityExplanation: String {
        if !match.secondaryReasonDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return match.secondaryReasonDetail
        }

        if !match.primaryReasonDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return match.primaryReasonDetail
        }

        if !match.connectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return match.connectionPrompt
        }

        return presentation.compatibilitySummarySavedMatch
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                savedContextSection
                compatibilitySection

                detailSection(
                    title: "In their words",
                    content: match.essence
                )

                if !match.signals.isEmpty {
                    signalsSection(match.signals)
                }

                detailSection(
                    title: "Why it works",
                    content: compatibilityExplanation
                )

                detailSection(
                    title: "Where it gets tricky",
                    content: match.frictionNote
                )

                detailSection(
                    title: "What they want",
                    content: match.intent
                )

                conversationSection
                closingSection
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 28)
        }
        .background(backgroundView)
        .navigationTitle(match.name)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            dismissIfMatchWasRemoved()
        }
        .onChange(of: savedMatches.count) { _ in
            dismissIfMatchWasRemoved()
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

    // MARK: - Sections

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { proxy in
                    Image(match.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height,
                            alignment: ConnectPresentation.imageAlignment(for: match.imageAnchorRaw)
                        )
                        .clipped()
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
                    compatibilityBadge
                }
                .padding(ZD.Spacing.m)
                .frame(maxHeight: .infinity, alignment: .top)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(match.name)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        if let matchStyle {
                            styleChip(matchStyle.label)
                        }
                    }

                    Text(combinedSignsText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .tracking(1.2)

                    Text(match.archetypeTitle)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(red: 0.93, green: 0.83, blue: 0.63))
                        .lineLimit(2)
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

            Text(heroSummary)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 2)
        }
    }

    private var savedContextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("Saved read")
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
        if let matchStyle {
            return "You kept this because something about the \(matchStyle.label.lowercased()) felt worth another look."
        }

        return "You kept this because something here felt worth another look"
    }

    private var compatibilitySection: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 12) {
                Text("The Read")
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                compatibilityMeter

                Text(presentation.compatibilitySummarySavedMatch)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailSection(title: String, content: String) -> some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(content)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func signalsSection(_ signals: [ConnectProfileSignal]) -> some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("THEIR SIGNALS")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(signals.prefix(3).enumerated()), id: \.offset) { index, signal in
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var conversationSection: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 12) {
                Text(isAwaitingFirstMessage ? "MESSAGE FIRST" : "FOLLOW THE THREAD")
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

                        Text(isAwaitingFirstMessage ? "Start the thread" : "Follow this thread")
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
            return "Still thinking about this? Follow it"
        }

        if match.isFirstMessageAtRisk {
            return "This pull is waiting on you. Send the first message to keep it active."
        }

        return "You made the pull. Send the first message within 24 hours to keep it active."
    }

    private var closingSection: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 6) {
                Text("WHAT THIS HOLDS")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(presentation.matchEnergySummary)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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

    // MARK: - Components

    private var compatibilityBadge: some View {
        VStack(spacing: 4) {
            Text("\(match.compatibilityScore)%")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(Color(red: 0.98, green: 0.91, blue: 0.72))

            Text(presentation.compatibilityBadgeLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.54))
                .tracking(1.0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            ZD.Color.cardAlt.opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.89, green: 0.77, blue: 0.52).opacity(0.28), lineWidth: ZD.Stroke.thin)
                )
        )
        .shadow(color: ZD.Color.accent.opacity(0.12), radius: 10, y: 4)
    }

    private func styleChip(_ text: String) -> some View {
        Text(text)
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
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

    private var compatibilityMeter: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ZD.Color.cardAlt)

                    Capsule()
                        .fill(ZD.Gradient.gold)
                        .frame(width: proxy.size.width * CGFloat(match.compatibilityScore) / 100)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Low")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)

                Spacer()

                Text("High")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
            }
        }
    }

    // MARK: - Helpers

    private var combinedSignsText: String {
        let western = westernSign?.displayName ?? "—"
        let chinese = chineseSign?.displayName ?? "—"
        return "\(western) • \(chinese)"
    }

    private func vibePrompt(for index: Int) -> String {
        let prompts = [
            "How they show up",
            "What you notice first",
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

    private var heroSummary: String {
        "This is the saved read — the part of the pull worth coming back to"
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
                frictionNote: "Both of you may hold back at first, which can slow momentum",
                intent: "Something real",
                imageName: "selene",
                imageAnchorRaw: "top",
                primaryReasonTitle: "Magnetic Contrast",
                primaryReasonDetail: "Differences create intrigue, tension, and chemistry"
            )
        )
    }
    .preferredColorScheme(.dark)
}
