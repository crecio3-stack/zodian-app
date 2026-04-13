import SwiftUI
import SwiftData

struct ChatView: View {
    let match: SavedMatch

    @Environment(\.modelContext) private var context
    @Query(sort: \ChatMessage.createdAt, order: .forward) private var allMessages: [ChatMessage]

    @State private var composerText = ""
    @State private var pendingReplyTask: Task<Void, Never>?
    @State private var hasMarkedThreadReadOnPresentation = false

    private let starterPrompts = [
        "What kind of connection are you hoping to find here?",
        "What usually catches your attention first about someone?",
        "What does an ideal first date look like for you?"
    ]

    private var threadMessages: [ChatMessage] {
        allMessages.filter { $0.matchID == match.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerCard

            Divider()
                .background(ZD.Color.divider)
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.top, ZD.Spacing.m)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ZD.Spacing.m) {
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
                    .padding(.top, ZD.Spacing.m)
                    .padding(.bottom, ZD.Spacing.l)
                }
                .onAppear {
                    scrollToLatest(with: proxy, animated: false)
                }
                .onChange(of: threadMessages.count) { _ in
                    scrollToLatest(with: proxy, animated: true)
                }
            }

            composerBar
        }
        .background(backgroundView)
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
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
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.forest.opacity(0.22),
                        .clear,
                        ZD.Color.card.opacity(0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.08),
                        .clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 460
                )
            )
            .ignoresSafeArea()
    }

    private var headerCard: some View {
        TarotCardContainer(style: .featured) {
            HStack(spacing: ZD.Spacing.m) {
                ZStack {
                    Image(match.chatImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.30), lineWidth: ZD.Stroke.thin)
                }
                .shadow(color: ZD.Color.glow, radius: 14, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text(match.name)
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineLimit(1)

                    Text(match.displayArchetypeTitle)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(ZD.Color.success)
                            .frame(width: 8, height: 8)

                        Text("Local prototype thread")
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary)
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, ZD.Spacing.l)
        .padding(.top, ZD.Spacing.m)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: ZD.Spacing.m) {
            TarotCardContainer {
                VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                    Text("Start the Energy")
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Choose a conversation starter to open the thread with \(match.name).")
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(starterPrompts, id: \.self) { prompt in
                    Button {
                        sendMessage(prompt)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(ZD.Color.accent)

                            Text(prompt)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 0)
                        }
                        .padding(ZD.Spacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                .fill(ZD.Color.cardAlt.opacity(0.88))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                        .stroke(ZD.Color.border.opacity(0.38), lineWidth: ZD.Stroke.thin)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
                .padding(.vertical, 12)
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
                            : ZD.Color.border.opacity(0.34),
                            lineWidth: ZD.Stroke.thin
                        )
                )
                .shadow(
                    color: isMe ? ZD.Color.glow : ZD.Color.shadow.opacity(0.55),
                    radius: isMe ? 14 : 10,
                    x: 0,
                    y: 6
                )

            Text(message.createdAt.formatted(.dateTime.hour().minute()))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(ZD.Color.muted)
                .padding(.horizontal, 4)
        }
    }

    private var composerBar: some View {
        HStack(alignment: .bottom, spacing: ZD.Spacing.sm) {
            TextField("Say something intriguing...", text: $composerText, axis: .vertical)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .fill(ZD.Color.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                                .stroke(ZD.Color.border.opacity(0.36), lineWidth: ZD.Stroke.thin)
                        )
                )

            PrimaryButton(
                title: "Send",
                action: sendCurrentMessage,
                isDisabled: trimmedComposerText.isEmpty,
                icon: "paperplane.fill",
                fullWidth: false
            )
        }
        .padding(.horizontal, ZD.Spacing.l)
        .padding(.top, ZD.Spacing.sm)
        .padding(.bottom, ZD.Spacing.l)
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
        saveContext()
        if isFirstMessageInThread {
            AnalyticsService.shared.track(
                .firstMessageSent(
                    matchID: match.id.uuidString,
                    archetypeID: match.archetypeId
                )
            )
        }
        scheduleAutoReplyIfNeeded(totalMessagesAfterSend: totalMessagesAfterSend)
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
            "I like that question. You make this feel easy in the best way.",
            "That got my attention. Is that your usual energy or just tonight?",
            "You make \(match.displayArchetypeTitle.lowercased()) sound even more intriguing somehow.",
            "I was hoping you’d say something like that. What’s your read on this connection so far?",
            "You seem thoughtful, which I really like. What are you curious about lately?",
            "That feels easy to answer with you. What kind of spark do you usually trust first?",
            "I’m into the vibe already. Tell me one thing people never guess about you."
        ]

        return options.randomElement() ?? "You have my attention. Tell me a little more."
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
        essence: "Elegant, observant, and difficult to forget.",
        connectionPrompt: "A connection with strong chemistry and emotional intelligence.",
        frictionNote: "Both of you may hold back at first, which can slow momentum.",
        intent: "Something intentional",
        imageName: "selene",
        imageAnchorRaw: "top",
        primaryReasonTitle: "Magnetic Contrast",
        primaryReasonDetail: "Differences create intrigue, tension, and chemistry."
    )

    container.mainContext.insert(match)
    container.mainContext.insert(
        ChatMessage(matchID: match.id, senderRaw: ChatSender.match.rawValue, text: "I had a feeling we’d end up talking.")
    )
    container.mainContext.insert(
        ChatMessage(matchID: match.id, senderRaw: ChatSender.me.rawValue, text: "That makes two of us.")
    )

    return NavigationStack {
        ChatView(match: match)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
