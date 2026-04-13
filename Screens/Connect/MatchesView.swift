//
//  MatchesView.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//

import SwiftUI
import SwiftData

struct MatchesView: View {
    @EnvironmentObject private var store: AppStore
    @Query(sort: \SavedMatch.createdAt, order: .reverse) private var savedMatches: [SavedMatch]
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]
    @Environment(\.modelContext) private var context

    @State private var matchToDelete: SavedMatch?
    @State private var selectedFilter: MatchesFilter = .all

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ZD.Spacing.l) {
                headerSection

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
            .padding(.bottom, 28)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Matches")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onChange(of: store.connectResetToken) { _ in
            matchToDelete = nil
            selectedFilter = .all
        }
        .onChange(of: store.onboardingResetToken) { _ in
            matchToDelete = nil
            selectedFilter = .all
        }
        .alert("Remove match?", isPresented: Binding(
            get: { matchToDelete != nil },
            set: { if !$0 { matchToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                matchToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let match = matchToDelete {
                    delete(match)
                }
            }
        } message: {
            Text("This will remove the saved match from your profile.")
        }
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
                return value.contains("intentional")
                    || value.contains("meaningful")
                    || value.contains("relationship")
                    || value.contains("slow-burn")
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                Text("Saved Matches")
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.accent)

                Text("Return to the connections that stood out and revisit their compatibility.")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    statPill(title: "\(savedMatches.count)", subtitle: "Saved")
                    statPill(title: "\(highMatchCount)", subtitle: "High Match")
                }
            }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Browse")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MatchesFilter.allCases) { filter in
                        filterChip(for: filter)
                    }
                }
                .padding(.trailing, 6)
            }
        }
    }

    private var emptyFilteredState: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
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
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            ForEach(filteredMatches) { match in
                NavigationLink {
                    MatchDetailView(match: match)
                } label: {
                    TarotCardContainer {
                        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
                            matchImageSection(for: match)

                            HStack(alignment: .top, spacing: ZD.Spacing.m) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(match.name)
                                        .font(ZD.Font.heading())
                                        .foregroundStyle(ZD.Color.textPrimary)

                                    Text(match.archetypeTitle)
                                        .font(ZD.Font.body(.semibold))
                                        .foregroundStyle(ZD.Color.accent)

                                    Text(signsText(for: match))
                                        .font(ZD.Font.caption(.semibold))
                                        .foregroundStyle(ZD.Color.muted)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 10) {
                                    compatibilityBadge(score: match.compatibilityScore)

                                    Button {
                                        matchToDelete = match
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(ZD.Color.muted)
                                            .padding(10)
                                            .background(
                                                Circle()
                                                    .fill(ZD.Color.cardAlt)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                infoLabel("Essence")
                                Text(match.essence)
                                    .font(ZD.Font.body())
                                    .foregroundStyle(ZD.Color.textSecondary)
                                    .lineLimit(2)
                            }

                            threadPreviewRow(for: match)

                            VStack(alignment: .leading, spacing: 6) {
                                infoLabel("Why You Clicked")
                                Text(match.primaryReasonTitle)
                                    .font(ZD.Font.body(.semibold))
                                    .foregroundStyle(ZD.Color.textPrimary)

                                Text(match.primaryReasonDetail)
                                    .font(ZD.Font.caption())
                                    .foregroundStyle(ZD.Color.muted)
                                    .lineLimit(2)
                            }

                            HStack(spacing: 8) {
                                metaPill(text: match.intent)
                                metaPill(text: match.matchStyleRaw.capitalized)
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundStyle(ZD.Color.accent)

                                Text("View Profile")
                                    .font(ZD.Font.caption(.semibold))
                                    .foregroundStyle(ZD.Color.accent)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(ZD.Color.muted)
                            }
                            .padding(.top, 2)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    private func matchImageSection(for match: SavedMatch) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                Image(match.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: imageAlignment(for: match.imageAnchorRaw)
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
                            ZD.Color.accent.opacity(0.08),
                            .clear
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(match.name)
                    .font(ZD.Font.title())
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(match.archetypeTitle)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.accentSoft)
                    .lineLimit(1)
            }
            .padding(ZD.Spacing.m)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .stroke(ZD.Color.border.opacity(0.25), lineWidth: ZD.Stroke.thin)
                .shadow(
                    color: ZD.Color.accent.opacity(0.16),
                    radius: 14,
                    y: 8
                )
        )
    }

    private func imageAlignment(for raw: String) -> Alignment {
        switch raw {
        case "top": return .top
        case "bottom": return .bottom
        case "leading": return .leading
        case "trailing": return .trailing
        case "topLeading": return .topLeading
        case "topTrailing": return .topTrailing
        case "bottomLeading": return .bottomLeading
        case "bottomTrailing": return .bottomTrailing
        default: return .center
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
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
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
                .font(ZD.Font.heading())
                .foregroundStyle(ZD.Color.textPrimary)

            Text(subtitle)
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
                        .stroke(ZD.Color.border.opacity(0.4), lineWidth: ZD.Stroke.thin)
                )
        )
    }

    private func metaPill(text: String) -> some View {
        Text(text)
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ZD.Color.cardAlt)
                    .overlay(
                        Capsule()
                            .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                    )
            )
            .lineLimit(1)
    }

    // MARK: - Helpers

    private var highMatchCount: Int {
        savedMatches.filter { $0.compatibilityScore >= 85 }.count
    }

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
        } else {
            latestText = "No conversation yet"
        }

        let unreadCount = messages.filter { $0.isFromMatch && !$0.isRead }.count
        return MatchThreadPreview(latestText: latestText, unreadCount: unreadCount)
    }

    private func signsText(for match: SavedMatch) -> String {
        let western = WesternZodiac(rawValue: match.westernSignRaw)?.displayName ?? "—"
        let chinese = ChineseZodiac(rawValue: match.chineseSignRaw)?.displayName ?? "—"
        return "\(western) • \(chinese)"
    }

    private func threadPreviewRow(for match: SavedMatch) -> some View {
        let preview = threadPreview(for: match)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                infoLabel("Conversation")

                if preview.hasUnread {
                    unreadBadge(count: preview.unreadCount)
                }
            }

            Text(preview.latestText)
                .font(ZD.Font.body())
                .foregroundStyle(preview.hasUnread ? ZD.Color.textPrimary : ZD.Color.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
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
    }

    private func infoLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(ZD.Color.accent)
    }

    private func compatibilityBadge(score: Int) -> some View {
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
        .fixedSize()
    }

    private func unreadBadge(count: Int) -> some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ZD.Gradient.gold)
            )
            .overlay(
                Capsule()
                    .stroke(ZD.Color.accentSoft.opacity(0.42), lineWidth: ZD.Stroke.thin)
            )
            .shadow(color: ZD.Color.glow.opacity(0.9), radius: 10, x: 0, y: 6)
            .fixedSize()
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all:
            return "No matches saved yet"
        case .highMatch:
            return "No high matches yet"
        case .recent:
            return "No recent matches"
        case .intentional:
            return "No intentional matches yet"
        }
    }

    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all:
            return "Swipe right in Connect to start building your match list."
        case .highMatch:
            return "Save stronger compatibility profiles to build your top tier match list."
        case .recent:
            return "New saves from the past week will show up here."
        case .intentional:
            return "Matches with more serious or meaningful intent will show up here."
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
        case .highMatch: return "High Match"
        case .recent: return "Recent"
        case .intentional: return "Intentional"
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
