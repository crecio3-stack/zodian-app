//
//  MatchesView.swift
//  Zodian
//

import SwiftUI
import SwiftData

struct MatchesView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]

    @State private var matchToDelete: SavedMatch?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                headerSection

                if savedMatches.isEmpty {
                    dormantState
                    emergingCirclePreview
                } else {
                    savedPullsSection
                    emergingCircleSection
                }
            }
            .padding(.horizontal, ZD.Spacing.l)
            .padding(.top, 20)
            .padding(.bottom, 172)
        }
        .background(backgroundView)
        .navigationTitle("My Circle")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onChange(of: store.connectResetToken) {
            matchToDelete = nil
        }
        .onChange(of: store.onboardingResetToken) {
            matchToDelete = nil
        }
        .alert("Let this go?", isPresented: Binding(
            get: { matchToDelete != nil },
            set: { if !$0 { matchToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                matchToDelete = nil
            }

            Button("Let Go", role: .destructive) {
                if let match = matchToDelete {
                    delete(match)
                }
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
                endRadius: 520
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
                (0.16, 0.10, 1.3, 0.20),
                (0.78, 0.14, 1.5, 0.18),
                (0.88, 0.28, 1.1, 0.14),
                (0.14, 0.40, 1.4, 0.13),
                (0.64, 0.53, 1.2, 0.13),
                (0.24, 0.72, 1.0, 0.12),
                (0.84, 0.82, 1.3, 0.12)
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

    // MARK: - Derived Data

    private var emergingThreadLines: [String] {
        let hasSignals = savedMatches.contains { !$0.signals.isEmpty }
        let hasOpenTo = savedMatches.contains { !$0.intent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let hasFriction = savedMatches.contains { !$0.frictionNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let hasPrompt = savedMatches.contains { !$0.connectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        var lines: [String] = []

        if hasSignals {
            lines.append("You keep returning to people who move differently")
        }

        if hasOpenTo {
            lines.append("You pause when curiosity feels mutual")
        }

        if hasFriction {
            lines.append("Distance seems to increase your attention")
        }

        if hasPrompt {
            lines.append("You save people who do not fully resolve")
        }

        if lines.isEmpty {
            lines.append("You keep returning to people who move differently")
            lines.append("You pause when curiosity feels mutual")
            lines.append("You save people who do not fully resolve")
        }

        return Array(lines.prefix(3))
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("People you save collect here for another look")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var dormantState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Rectangle()
                .fill(ZD.Color.accent.opacity(0.36))
                .frame(width: 48, height: 1)

            VStack(alignment: .leading, spacing: 10) {
                Text("Nothing has stayed with you yet")
                    .font(.system(size: 31, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)

                Text("The people you keep returning to will collect here")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                store.selectedTab = .connect
            } label: {
                Text("Open Connect")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ZD.Gradient.gold)
                            .shadow(color: ZD.Color.glow.opacity(0.32), radius: 16, y: 8)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var savedPullsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                eyebrow: "SAVED PEOPLE",
                title: "People you wanted to come back to"
            )

            savedPullsList
        }
    }

    private var savedPullsList: some View {
        VStack(spacing: 14) {
            ForEach(savedMatches) { match in
                swipeableMatchRow(for: match)
            }
        }
    }

    private var emergingCirclePreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                eyebrow: "MY CIRCLE",
                title: "What keeps returning"
            )

            Text("You start seeing which people keep coming back into focus")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            quietThreadLine("Saved profiles become people worth revisiting")
            quietThreadLine("Repeated returns become part of your pattern")
        }
        .padding(.vertical, 10)
    }

    private var emergingCircleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                eyebrow: "MY CIRCLE",
                title: "What keeps returning"
            )

            VStack(spacing: 10) {
                ForEach(emergingThreadLines, id: \.self) { line in
                    interpretedThreadCard(line)
                }
            }
        }
    }

    private func swipeableMatchRow(for match: SavedMatch) -> some View {
        NavigationLink {
            MatchDetailView(match: match)
        } label: {
            listMatchCard(for: match)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                matchToDelete = match
            } label: {
                Label("Let Go", systemImage: "trash")
            }
        }
    }

    private func listMatchCard(for match: SavedMatch) -> some View {
        matchPanel {
            HStack(alignment: .top, spacing: 12) {
                ConnectProfileImage(
                    assetName: match.imageName,
                    size: CGSize(width: 58, height: 58),
                    focalPoint: ConnectPresentation.focalPoint(for: match.imageAnchorRaw),
                    clipShape: .circle
                )
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.28), lineWidth: ZD.Stroke.thin)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(1)

                    Text(threadTitle(for: match))
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .lineLimit(1)

                    Text(signsText(for: match))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .lineLimit(1)

                    threadFieldLabel("Detail")
                    Text(signalLine(for: match))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    threadFieldLabel("Open to")
                    Text(openToLine(for: match))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(ZD.Color.muted.opacity(0.72))
                    .padding(.top, 4)
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                matchToDelete = match
            } label: {
                Label("Let Go", systemImage: "trash")
            }
        }
    }

    // MARK: - Components

    private func sectionHeader(eyebrow: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(2.1)
                .foregroundStyle(ZD.Color.accent)

            Text(title)
                .font(.system(size: 25, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func quietThreadLine(_ line: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ZD.Color.accent.opacity(0.78))
                .frame(width: 5, height: 5)

            Text(line)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 6)
    }

    private func interpretedThreadCard(_ line: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(ZD.Color.accent.opacity(0.12))
                )

            Text(line)
                .font(.system(size: 19, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .background(alignment: .bottom) {
            Rectangle()
                .fill(ZD.Color.border.opacity(0.12))
                .frame(height: 1)
        }
    }

    private func matchPanel<Content: View>(isHighlighted: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isHighlighted
                            ? [
                                ZD.Color.card.opacity(0.94),
                                ZD.Color.accent.opacity(0.12),
                                ZD.Color.cardAlt.opacity(0.88)
                            ]
                            : [
                                ZD.Color.card.opacity(0.92),
                                ZD.Color.cardAlt.opacity(0.84)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(
                                isHighlighted ? ZD.Color.accent.opacity(0.34) : ZD.Color.border.opacity(0.22),
                                lineWidth: ZD.Stroke.thin
                            )
                    )
                    .shadow(
                        color: isHighlighted ? ZD.Color.glow.opacity(0.28) : ZD.Color.shadow.opacity(0.26),
                        radius: isHighlighted ? 16 : 12,
                        x: 0,
                        y: isHighlighted ? 10 : 8
                    )
            )
    }

    // MARK: - Helpers

    private func signsText(for match: SavedMatch) -> String {
        let western = WesternZodiac(rawValue: match.westernSignRaw)?.displayName ?? "—"
        let chinese = ChineseZodiac(rawValue: match.chineseSignRaw)?.displayName ?? "—"
        return "\(western) • \(chinese)"
    }

    private func threadTitle(for match: SavedMatch) -> String {
        let title = match.archetypeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? "Saved person" : title
    }

    private func signalLine(for match: SavedMatch) -> String {
        if let firstSignal = match.signals.first {
            let response = firstSignal.response.trimmingCharacters(in: .whitespacesAndNewlines)
            if !response.isEmpty {
                return response
            }

            return firstSignal.prompt
        }

        let prompt = match.connectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if !prompt.isEmpty {
            return prompt
        }

        return match.essence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Something that stays with you" : match.essence
    }

    private func openToLine(for match: SavedMatch) -> String {
        let intent = match.intent.trimmingCharacters(in: .whitespacesAndNewlines)
        return intent.isEmpty ? "Open" : intent
    }

    private func threadFieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(ZD.Color.accent.opacity(0.72))
            .tracking(1.1)
            .padding(.top, 4)
    }

    private func delete(_ match: SavedMatch) {
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
            print("❌ Failed to delete match: \(error)")
        }

        matchToDelete = nil
    }

}

#Preview {
    NavigationStack {
        MatchesView()
    }
    .modelContainer(
        for: [SavedMatch.self, ChatMessage.self],
        inMemory: true
    )
    .preferredColorScheme(.dark)
}
