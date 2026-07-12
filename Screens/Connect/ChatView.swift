//
//  ChatView.swift
//  Zodian
//
//  Created by Ian Recio on 4/21/26.
//


import SwiftUI
import SwiftData

struct ChatView: View {
    let match: SavedMatch

    @Environment(\.modelContext) private var context
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]

    @State private var composerText = ""
    @State private var pendingReplyTask: Task<Void, Never>?
    @State private var hasMarkedThreadReadOnPresentation = false

    private var presentation: ConnectProfilePresentation {
        ConnectPresentationBuilder.buildPresentation(match: match)
    }

    private var threadMessages: [ChatMessage] {
        allMessages.filter { $0.matchID == match.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerCard

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        if threadMessages.isEmpty {
                            emptyState
                        } else {
                            ForEach(threadMessages) { message in
                                bubbleRow(for: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                }
                .onAppear {
                    scrollToLatest(with: proxy, animated: false)
                }
                .onChange(of: threadMessages.count) {
                    scrollToLatest(with: proxy, animated: true)
                }
            }

            composerBar
        }
        .background(backgroundView)
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            trackPatternMemoryThreadEvent(.threadProfileOpened)
            AnalyticsService.shared.track(
                .chatOpened(
                    matchID: match.id.uuidString,
                    archetypeID: match.archetypeId,
                    unreadCount: threadMessages.filter { $0.isFromMatch && !$0.isRead }.count,
                    messageCount: threadMessages.count
                )
            )
            markThreadAsReadIfNeeded()
        }
        .onDisappear {
            pendingReplyTask?.cancel()
            hasMarkedThreadReadOnPresentation = false
        }
    }

    private var backgroundView: some View {
        ZStack {
            ZD.Color.bg

            LinearGradient(
                colors: [
                    ZD.Color.forest.opacity(0.26),
                    .clear,
                    ZD.Color.card.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(0.11),
                    .clear
                ],
                center: .top,
                startRadius: 16,
                endRadius: 430
            )

            starField
        }
        .ignoresSafeArea()
    }

    private var starField: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let stars: [(CGFloat, CGFloat, CGFloat, Double)] = [
                (0.18, 0.10, 1.6, 0.32),
                (0.76, 0.13, 1.2, 0.26),
                (0.88, 0.24, 1.8, 0.22),
                (0.12, 0.31, 1.1, 0.18),
                (0.67, 0.37, 1.4, 0.20),
                (0.30, 0.50, 1.3, 0.16),
                (0.83, 0.56, 1.1, 0.18),
                (0.20, 0.70, 1.5, 0.18),
                (0.72, 0.78, 1.2, 0.14)
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

    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(ZD.Color.cardAlt.opacity(0.72))
                    .frame(width: 74, height: 74)
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.20), lineWidth: ZD.Stroke.thin)
                    )
                    .shadow(color: ZD.Color.glow.opacity(0.22), radius: 12, x: 0, y: 6)

                ConnectProfileImage(
                    assetName: match.chatImageName,
                    size: CGSize(width: 60, height: 60),
                    focalPoint: .center,
                    clipShape: .circle
                )
                    .overlay(
                        Circle()
                            .stroke(ZD.Color.accent.opacity(0.28), lineWidth: ZD.Stroke.thin)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(match.name)
                    .font(.system(size: 31, weight: .regular, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Text(match.displayArchetypeTitle)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .lineLimit(1)

                Text(matchSignLine)
                    .font(ZD.Font.caption(.medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(1)

                Text(openToLine)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(glassPanel(cornerRadius: 30, strokeOpacity: 0.16))
        .padding(.horizontal, ZD.Spacing.l)
        .padding(.top, 14)
    }

    private var matchSignLine: String {
        let western = match.westernSignRaw.capitalized
        let chinese = match.chineseSignRaw.capitalized
        return "\(western) • \(chinese)"
    }

    private var openToLine: String {
        let intent = match.intent.trimmingCharacters(in: .whitespacesAndNewlines)
        return intent.isEmpty ? "Open" : intent
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            introCue

            VStack(alignment: .leading, spacing: 8) {
                ForEach(presentation.chatStarterPrompts, id: \.self) { prompt in
                    Button {
                        sendMessage(prompt)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(ZD.Color.accent)

                            Text(prompt)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            promptPillBackground(cornerRadius: ZD.Radius.l)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var introCue: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)

            Text("Start with what you noticed")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .textCase(.uppercase)
                .tracking(0.8)
            }

            Text(introCueCopy)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 2)
    }

    private var introCueCopy: String {
        if match.isFirstMessageAtRisk {
            return "A small message is enough to keep this profile open."
        }

        if match.isAwaitingFirstMessage {
            return "A small opener is enough to begin understanding them."
        }

        return "Pick one below or write from what you noticed."
    }


    private func glassPanel(cornerRadius: CGFloat, strokeOpacity: Double) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(0.86),
                        ZD.Color.forest.opacity(0.24),
                        ZD.Color.cardAlt.opacity(0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ZD.Color.accent.opacity(strokeOpacity), lineWidth: ZD.Stroke.thin)
            )
            .shadow(color: ZD.Color.shadow.opacity(0.34), radius: 14, x: 0, y: 8)
    }

    private func promptPillBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(ZD.Color.forest.opacity(0.34))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ZD.Color.accent.opacity(0.13), lineWidth: ZD.Stroke.thin)
            )
            .shadow(color: ZD.Color.shadow.opacity(0.18), radius: 8, x: 0, y: 4)
    }

    private func bubbleRow(for message: ChatMessage) -> some View {
        HStack {
            if message.sender == .me {
                Spacer(minLength: 48)
                messageBubble(for: message, isMe: true)
            } else {
                messageBubble(for: message, isMe: false)
                Spacer(minLength: 48)
            }
        }
    }

    private func messageBubble(for message: ChatMessage, isMe: Bool) -> some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 6) {
            Text(message.text)
                .font(ZD.Font.body())
                .foregroundStyle(isMe ? Color.black : ZD.Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            isMe
                            ? AnyShapeStyle(ZD.Gradient.gold)
                            : AnyShapeStyle(ZD.Color.card)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            isMe
                            ? ZD.Color.accentSoft.opacity(0.38)
                            : ZD.Color.border.opacity(0.28),
                            lineWidth: ZD.Stroke.thin
                        )
                )
                .shadow(
                    color: isMe ? ZD.Color.glow.opacity(0.78) : ZD.Color.shadow.opacity(0.42),
                    radius: isMe ? 10 : 8,
                    x: 0,
                    y: 5
                )

            Text(message.createdAt.formatted(.dateTime.hour().minute()))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(ZD.Color.muted)
                .padding(.horizontal, 4)
        }
    }

    private var composerBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Write from what you noticed", text: $composerText, axis: .vertical)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(promptPillBackground(cornerRadius: ZD.Radius.l))

            PrimaryButton(
                title: "Send",
                action: sendCurrentMessage,
                isDisabled: trimmedComposerText.isEmpty,
                icon: "paperplane.fill",
                fullWidth: false
            )
        }
        .padding(.horizontal, ZD.Spacing.l)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(
            ZD.Color.bgSecondary
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ZD.Color.divider)
                        .frame(height: 1)
                        .opacity(0.9)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var trimmedComposerText: String {
        composerText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendCurrentMessage() {
        sendMessage(trimmedComposerText)
    }

    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let isFirstMessageInThread = threadMessages.isEmpty
        let totalMessagesAfterSend = threadMessages.count + 1

        let message = ChatMessage(
            matchID: match.id,
            senderRaw: ChatSender.me.rawValue,
            text: trimmed,
            isRead: true
        )

        context.insert(message)
        composerText = ""
        if isFirstMessageInThread && match.firstMessageSentAt == nil {
            match.firstMessageSentAt = Date()
        }
        saveContext()
        if isFirstMessageInThread {
            AnalyticsService.shared.track(
                .firstMessageSent(
                    matchID: match.id.uuidString,
                    archetypeID: match.archetypeId
                )
            )
            trackPatternMemoryThreadEvent(.startThreadTapped)
        }
        scheduleAutoReplyIfNeeded(totalMessagesAfterSend: totalMessagesAfterSend)
    }

    private func trackPatternMemoryThreadEvent(_ type: PatternMemoryEventType) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent.savedProfileEvent(type: type, match: match)
        )
    }

    private func scheduleAutoReplyIfNeeded(totalMessagesAfterSend: Int) {
        pendingReplyTask?.cancel()

        guard totalMessagesAfterSend < 12 else { return }

        pendingReplyTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }

            let reply = ChatMessage(
                matchID: match.id,
                senderRaw: ChatSender.match.rawValue,
                text: generatedReply(),
                isRead: false
            )

            context.insert(reply)
            saveContext()
        }
    }

    private func generatedReply() -> String {
        let options = [
            "That feels like a good place to start.",
            "I like the way you put that.",
            "That says more than it looks like.",
            "You got my attention with that.",
            "There’s something real in that.",
            "I’d answer that better in person.",
            "That’s a thoughtful opener."
        ]

        return options.randomElement() ?? "That got my attention."
    }

    private func scrollToLatest(with proxy: ScrollViewProxy, animated: Bool) {
        guard let lastID = threadMessages.last?.id else { return }

        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save chat thread: \(error)")
        }
    }

    private func markThreadAsReadIfNeeded() {
        guard !hasMarkedThreadReadOnPresentation else { return }
        hasMarkedThreadReadOnPresentation = true

        let unreadMessages = threadMessages.filter { $0.isFromMatch && !$0.isRead }
        guard !unreadMessages.isEmpty else { return }

        unreadMessages.forEach { $0.isRead = true }
        saveContext()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: SavedMatch.self,
        ChatMessage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let match = SavedMatch(
        name: "Selene",
        archetypeId: "libra-snake",
        archetypeTitle: "The Velvet Dagger",
        westernSignRaw: "libra",
        chineseSignRaw: "snake",
        compatibilityScore: 92,
        matchStyleRaw: "magnetic",
        essence: "Elegant, observant, and difficult to forget",
        connectionPrompt: "A connection that stays interesting after the first impression",
        frictionNote: "Both of you hold back at first, which can slow things down",
        intent: "Something real",
        imageName: "pexelsFeminine01",
        imageAnchorRaw: "top",
        primaryReasonTitle: "Magnetic Contrast",
        primaryReasonDetail: "Differences create enough tension to keep the read open."
    )

    container.mainContext.insert(match)
    container.mainContext.insert(
        ChatMessage(matchID: match.id, senderRaw: ChatSender.match.rawValue, text: "I had a feeling we’d end up talking")
    )
    container.mainContext.insert(
        ChatMessage(matchID: match.id, senderRaw: ChatSender.me.rawValue, text: "That makes two of us")
    )

    return NavigationStack {
        ChatView(match: match)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
