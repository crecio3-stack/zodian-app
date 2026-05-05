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
    @State private var selectedFilter: MatchesFilter = .all
    @State private var revealedDeleteMatchID: UUID? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                if let dailyResurfaceMatch {
                    dailyResurfaceCard(for: dailyResurfaceMatch)
                }

                if !savedMatches.isEmpty {
                    filterBar
                }

                if filteredMatches.isEmpty {
                    emptyFilteredState
                } else {
                    matchesList
                }
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 32)
        }
        .background(backgroundView)
        .navigationTitle("Matches")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onChange(of: store.connectResetToken) {
            matchToDelete = nil
            selectedFilter = .all
            revealedDeleteMatchID = nil
        }
        .onChange(of: store.onboardingResetToken) {
            matchToDelete = nil
            selectedFilter = .all
            revealedDeleteMatchID = nil
        }
        .alert("Let this go?", isPresented: Binding(
            get: { matchToDelete != nil },
            set: { if !$0 { matchToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                matchToDelete = nil
                revealedDeleteMatchID = nil
            }

            Button("Let Go", role: .destructive) {
                if let match = matchToDelete {
                    delete(match)
                }
            }
        } message: {
            Text("This slips them out of your orbit")
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

    private var filteredMatches: [SavedMatch] {
        switch selectedFilter {
        case .all:
            return savedMatches

        case .highMatch:
            return savedMatches.filter { $0.compatibilityScore >= 85 }

        case .recent:
            return savedMatches.filter {
                Calendar.current.dateComponents([.day], from: $0.createdAt, to: Date()).day ?? 999 <= 7
            }

        case .intentional:
            return savedMatches.filter {
                let value = $0.intent.lowercased()
                return value.contains("something real")
                    || value.contains("real conversation")
                    || value.contains("shared rhythm")
                    || value.contains("creative connection")
                    || value.contains("intentional")
                    || value.contains("meaningful")
                    || value.contains("relationship")
                    || value.contains("slow-burn")
            }
        }
    }

    private var dailyResurfaceMatch: SavedMatch? {
        guard !savedMatches.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return savedMatches[day % savedMatches.count]
    }

    private var highMatchCount: Int {
        savedMatches.filter { $0.compatibilityScore >= 85 }.count
    }

    private var recentMatchCount: Int {
        savedMatches.filter {
            Calendar.current.dateComponents([.day], from: $0.createdAt, to: Date()).day ?? 999 <= 7
        }.count
    }

    private var intentionalMatchCount: Int {
        savedMatches.filter {
            let value = $0.intent.lowercased()
            return value.contains("something real")
                || value.contains("real conversation")
                || value.contains("shared rhythm")
                || value.contains("creative connection")
                || value.contains("intentional")
                || value.contains("meaningful")
                || value.contains("relationship")
                || value.contains("slow-burn")
        }.count
    }

    // MARK: - Sections

    private var headerSection: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 14) {
                Text("Saved Pulls")
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.accent)

                Text("The ones you wanted to come back to")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    statPill(title: "\(savedMatches.count)", subtitle: "Saved")
                    statPill(title: "\(highMatchCount)", subtitle: "Strong")
                    statPill(title: "\(recentMatchCount)", subtitle: "Fresh")
                    statPill(title: "\(intentionalMatchCount)", subtitle: "For keeps")
                }
            }
        }
    }

    private func dailyResurfaceCard(for match: SavedMatch) -> some View {
        NavigationLink {
            MatchDetailView(match: match)
        } label: {
            matchPanel {
                HStack(alignment: .top, spacing: 12) {
                    Image(match.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 68, height: 68)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(ZD.Color.accent.opacity(0.24), lineWidth: ZD.Stroke.thin)
                        )

                    VStack(alignment: .leading, spacing: 5) {
                        Text("TODAY'S SAVED READ")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)
                            .lineLimit(1)

                        Text(match.name)
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineLimit(1)

                        Text("A saved pull worth another look")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(returnLine(for: match))
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    compatibilityBadge(score: match.compatibilityScore, compact: true)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lane")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MatchesFilter.allCases) { filter in
                        filterChip(for: filter)
                    }
                }
                .padding(.trailing, 6)
                .padding(.vertical, 2)
            }
        }
    }

    private var emptyFilteredState: some View {
        matchPanel {
            VStack(alignment: .leading, spacing: 6) {
                Text(emptyStateTitle)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(emptyStateSubtitle)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var matchesList: some View {
        VStack(spacing: 10) {
            ForEach(filteredMatches) { match in
                swipeableMatchRow(for: match)
            }
        }
    }

    private func swipeableMatchRow(for match: SavedMatch) -> some View {
        ZStack(alignment: .trailing) {
            Button {
                matchToDelete = match
            } label: {
                ZStack {
                    Circle()
                        .fill(ZD.Color.error.opacity(0.92))
                        .frame(width: 44, height: 44)

                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 72, height: 72, alignment: .trailing)
                .padding(.trailing, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .opacity(revealedDeleteMatchID == match.id ? 1 : 0)
            .allowsHitTesting(revealedDeleteMatchID == match.id)
            .zIndex(2)

            NavigationLink {
                MatchDetailView(match: match)
            } label: {
                listMatchCard(for: match)
                    .offset(x: revealedDeleteMatchID == match.id ? -66 : 0)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .allowsHitTesting(revealedDeleteMatchID != match.id)
            .zIndex(1)
            .highPriorityGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = abs(value.translation.height)

                        guard abs(horizontal) > vertical else { return }

                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            if horizontal < -24 {
                                revealedDeleteMatchID = match.id
                            } else if horizontal > 18 {
                                revealedDeleteMatchID = nil
                            }
                        }
                    }
            )
        }
    }

    private func listMatchCard(for match: SavedMatch) -> some View {
        let preview = threadPreview(for: match)
        let needsFirstMessage = isAwaitingFirstMessage(match, messages: threadMessages(for: match))

        return matchPanel(isHighlighted: preview.hasUnread || needsFirstMessage) {
            HStack(alignment: .top, spacing: 12) {
                Image(match.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.28), lineWidth: ZD.Stroke.thin)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(1)

                    Text(match.displayArchetypeTitle)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .lineLimit(1)

                    Text(signsText(for: match))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .lineLimit(1)

                    Text(returnLine(for: match))
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 8) {
                    if preview.hasUnread {
                        unreadBadge(count: preview.unreadCount)
                    }

                    if needsFirstMessage {
                        firstMessageBadge(for: match)
                    }

                    compatibilityBadge(score: match.compatibilityScore, compact: true)
                }
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

    private func filterChip(for filter: MatchesFilter) -> some View {
        let isSelected = selectedFilter == filter

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(isSelected ? Color.black : ZD.Color.textPrimary)
                .padding(.horizontal, 15)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(
                            isSelected
                            ? AnyShapeStyle(ZD.Gradient.gold)
                            : AnyShapeStyle(ZD.Color.card)
                        )
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

    private func statPill(title: String, subtitle: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(ZD.Color.textPrimary)
                .minimumScaleFactor(0.8)

            Text(subtitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(ZD.Color.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.26), lineWidth: ZD.Stroke.thin)
                )
        )
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

    private func compatibilityBadge(score: Int, compact: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text("\(score)%")
                .font(compact ? ZD.Font.body(.semibold) : ZD.Font.heading())
                .foregroundStyle(ZD.Color.textPrimary)

            Text("Pull")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(.horizontal, compact ? 10 : 13)
        .padding(.vertical, compact ? 7 : 9)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt.opacity(0.84))
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(0.28), lineWidth: ZD.Stroke.thin)
                )
        )
        .fixedSize()
    }

    private func unreadBadge(count: Int) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.black.opacity(0.82))
                .frame(width: 5, height: 5)

            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(ZD.Gradient.gold)
        )
        .overlay(
            Capsule()
                .stroke(ZD.Color.accentSoft.opacity(0.42), lineWidth: ZD.Stroke.thin)
        )
        .shadow(color: ZD.Color.glow.opacity(0.75), radius: 10, x: 0, y: 6)
        .fixedSize()
        .accessibilityLabel("\(count) unread message\(count == 1 ? "" : "s")")
    }

    private func firstMessageBadge(for match: SavedMatch) -> some View {
        HStack(spacing: 5) {
            Image(systemName: match.isFirstMessageAtRisk ? "exclamationmark.circle.fill" : "hourglass")
                .font(.system(size: 10, weight: .bold))

            Text(match.firstMessageWindowText)
                .font(.system(size: 10, weight: .bold, design: .rounded))
        }
        .foregroundStyle(match.isFirstMessageAtRisk ? ZD.Color.accent : ZD.Color.textPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt.opacity(0.86))
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(match.isFirstMessageAtRisk ? 0.42 : 0.24), lineWidth: ZD.Stroke.thin)
                )
        )
        .fixedSize()
        .accessibilityLabel(match.isFirstMessageAtRisk ? "First message at risk" : "First message window")
    }

    // MARK: - Helpers

    private func threadMessages(for match: SavedMatch) -> [ChatMessage] {
        allMessages
            .filter { $0.matchID == match.id }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private func threadPreview(for match: SavedMatch) -> MatchThreadPreview {
        let messages = threadMessages(for: match)
        let latestMessage = messages.last

        let latestText: String
        if let latestMessage {
            latestText = latestMessage.sender == .me
                ? "You: \(latestMessage.text)"
                : latestMessage.text
        } else if match.isFirstMessageAtRisk {
            latestText = "Send the first message or this pull may fade"
        } else if match.isAwaitingFirstMessage {
            latestText = "Start the thread to keep this pull active"
        } else {
            latestText = "No thread yet"
        }

        let unreadCount = messages.filter { $0.isFromMatch && !$0.isRead }.count
        return MatchThreadPreview(latestText: latestText, unreadCount: unreadCount)
    }

    private func signsText(for match: SavedMatch) -> String {
        let western = WesternZodiac(rawValue: match.westernSignRaw)?.displayName ?? "—"
        let chinese = ChineseZodiac(rawValue: match.chineseSignRaw)?.displayName ?? "—"
        return "\(western) • \(chinese)"
    }

    private func returnLine(for match: SavedMatch) -> String {
        if isAwaitingFirstMessage(match, messages: threadMessages(for: match)) {
            return match.isFirstMessageAtRisk
                ? "This pull is waiting on your first message"
                : "Message first within 24 hours to keep the pull warm"
        }

        let lines = [
            "Still worth another look",
            "There may be more here now",
            "You saved this for a reason",
            "This might read differently today"
        ]

        let index = abs(match.id.uuidString.hashValue % lines.count)
        return lines[index]
    }

    private func isAwaitingFirstMessage(_ match: SavedMatch, messages: [ChatMessage]) -> Bool {
        guard !messages.contains(where: { $0.sender == .me }) else { return false }
        return match.isAwaitingFirstMessage
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
        } catch {
            print("❌ Failed to delete match: \(error)")
        }

        matchToDelete = nil
        revealedDeleteMatchID = nil
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return "No saved pulls yet"
        case .highMatch:
            return "Nothing strong enough yet"
        case .recent:
            return "Nothing fresh here"
        case .intentional:
            return "No one in this lane"
        }
    }

    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all:
            return "Keep the ones you want to read again"
        case .highMatch:
            return "Your strongest saved pulls will show here"
        case .recent:
            return "Saved pulls from the last week will show here"
        case .intentional:
            return "Saved pulls with a more intentional read will show here"
        }
    }
}

private enum MatchesFilter: String, CaseIterable, Identifiable {
    case all
    case highMatch
    case recent
    case intentional

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .highMatch: return "Strong"
        case .recent: return "Fresh"
        case .intentional: return "For Keeps"
        }
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
