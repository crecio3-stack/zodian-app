import SwiftUI
import SwiftData
import UIKit

struct DailyRitualView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @StateObject private var viewModel = DailyRitualViewModel()
    @State private var holdWorkItem: DispatchWorkItem?
    @State private var hasCompletedHold = false
    @State private var isPressing = false
    @State private var holdProgress: CGFloat = 0
    @State private var showCompletionExtras = false
    @State private var ritualTitleShimmer = false
    @State private var isDeeperReadExpanded = false
    @State private var trackedDailyReadOpenKeys: Set<String> = []

    private var requestKey: String {
        viewModel.requestKey(for: store.currentUser)
    }

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    topBar
                    contentArea
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task(id: requestKey) {
            isDeeperReadExpanded = false
            await viewModel.load(for: store.currentUser)
            showCompletionExtras = store.ritualCompletedToday
        }
        .onAppear {
            showCompletionExtras = store.ritualCompletedToday
            ritualTitleShimmer = false
            withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                ritualTitleShimmer = true
            }
        }
        .onChange(of: viewModel.phase) { _, phase in
            if case .loaded = phase {
                showCompletionExtras = store.ritualCompletedToday
                isDeeperReadExpanded = false
            }
        }
    }
}

// MARK: - Background

private extension DailyRitualView {
    var background: some View {
        ZD.Color.bg
            .overlay(
                RadialGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.16),
                        .clear
                    ],
                    center: .top,
                    startRadius: 24,
                    endRadius: 620
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(0.10),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }
}

// MARK: - Navigation

private extension DailyRitualView {
    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(ZD.Color.card.opacity(0.90))
                            .overlay(
                                Circle()
                                    .stroke(ZD.Color.border.opacity(0.18), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

// MARK: - Content

private extension DailyRitualView {
    @ViewBuilder
    var contentArea: some View {
        switch viewModel.state {
        case .loading:
            loadingState
        case .loaded(let ritual):
            loadedState(ritual)
        case .empty:
            emptyState
        case .failed(let message):
            errorState(message)
        }
    }

    var loadingState: some View {
        VStack(spacing: 18) {
            ritualShellHeader(
                kicker: "TODAY’S LENS",
                subtitle: "Preparing today’s lens..."
            )

            loadingCard
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    func loadedState(_ ritual: DailyRitualResponse) -> some View {
        let subtitle = ritualSubtitle(for: ritual)

        return VStack(spacing: 18) {
            ritualShellHeader(
                kicker: "TODAY’S LENS",
                subtitle: subtitle
            )

            if ritual.isUnavailableDailyRead {
                fallbackCard(
                    title: "Today’s Lens is still being prepared",
                    message: ritual.unavailableMessage
                )
            } else {
                ritualCard(ritual)

                if store.ritualCompletedToday || showCompletionExtras {
                    completedState
                    momentumMoment
                    postRitualActions
                } else {
                    holdButton
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    func ritualSubtitle(for ritual: DailyRitualResponse) -> String {
        let western = ritual.westernSign?.trimmingCharacters(in: .whitespacesAndNewlines)
        let eastern = ritual.easternSign?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let western, !western.isEmpty, let eastern, !eastern.isEmpty {
            return "\(western) × \(eastern)"
        }

        return "Today’s Lens"
    }

    var emptyState: some View {
        VStack(spacing: 18) {
            ritualShellHeader(
                kicker: "TODAY’S LENS",
                subtitle: "Almost ready"
            )

            fallbackCard(
                title: "Today’s Lens is still being prepared, check back shortly",
                message: ""
            )
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    func errorState(_ message: String) -> some View {
        VStack(spacing: 18) {
            ritualShellHeader(
                kicker: "TODAY’S LENS",
                subtitle: "Could not load right now"
            )

            fallbackCard(
                title: "We could not load Today’s Lens",
                message: message,
                ctaTitle: "Try Again",
                ctaAction: {
                    Task {
                        await viewModel.reload(for: store.currentUser)
                    }
                }
            )
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    func ritualShellHeader(kicker: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(kicker)
                .font(.system(size: 12, weight: .semibold))
                .tracking(3)
                .foregroundStyle(ZD.Color.muted)

            Text("Today’s Lens")
                .font(.system(size: 29, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Cards

private extension DailyRitualView {
    var loadingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(ZD.Color.accent)
                .scaleEffect(1.15)

            Text("Preparing Today’s Lens")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .multilineTextAlignment(.center)

            Text("We’ll show it here once today’s pattern is ready")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ZD.Color.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .padding(20)
        .background(cardBackground(accent: ZD.Color.accent.opacity(0.15), glow: ZD.Color.premium.opacity(0.12)))
    }

    @ViewBuilder
    func ritualCard(_ ritual: DailyRitualResponse) -> some View {
        let content = viewModel.lensContent(for: ritual)
        if content.isCandidate, content.isReadyForDisplay {
            DailyLensTitleReadView(
                content: content,
                titleBaseSize: 27,
                readBaseSize: 16
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(cardBackground(accent: ZD.Color.accent.opacity(0.18), glow: ZD.Color.premium.opacity(0.10)))
            .onAppear {
                trackDailyReadOpened(ritual)
            }
        } else {
            sixFieldRitualCard(ritual)
        }
    }

    func sixFieldRitualCard(_ ritual: DailyRitualResponse) -> some View {
        let intro = dailyReadField(
            ritual.intro,
            fallback: firstDailyRitualSentence(from: ritual.ritualText)
        ) ?? "Today’s Lens is here."

        let pullQuote = dailyReadField(
            ritual.validPullQuote ?? ritual.pullQuote,
            fallback: secondDailyRitualSentence(from: ritual.ritualText)
        )

        let deeperRead = dailyReadField(
            ritual.validDeeperRead ?? ritual.deeperRead,
            fallback: remainingDailyRitualSentences(from: ritual.ritualText, after: 2)
        )

        let watchFor = dailyReadField(
            ritual.validWatchFor ?? ritual.watchFor,
            fallback: ritual.actionText
        )

        let move = dailyReadField(
            ritual.validMove ?? ritual.move,
            fallback: ritual.actionText
        ) ?? ritual.actionText

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                shimmeringGoldTitle(
                    ritual.title,
                    font: .system(size: 27, weight: .bold, design: .serif),
                    shimmerActive: ritualTitleShimmer,
                    baseOpacity: 0.14
                )
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(intro)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if let pullQuote {
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(ZD.Color.accent.opacity(0.72))
                        .frame(width: 3, height: 52)

                    Text(pullQuote)
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let deeperRead {
                dailyReadDeeperDisclosure(deeperRead, ritual: ritual)
            }

            if let watchFor {
                compactDailyReadField(
                    title: "Watch",
                    text: watchFor,
                    titleSize: 11,
                    bodySize: 15
                )
            }

            Divider()
                .overlay(ZD.Color.border.opacity(0.32))

            VStack(alignment: .leading, spacing: 8) {
                Text("WHAT TO DO")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(ZD.Color.muted)

                Text(move)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cardBackground(accent: ZD.Color.accent.opacity(0.18), glow: ZD.Color.premium.opacity(0.10)))
        .onAppear {
            trackDailyReadOpened(ritual)
        }
    }

    func compactDailyReadField(title: String, text: String, titleSize: CGFloat, bodySize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ZD.Color.muted)

            Text(text)
                .font(.system(size: bodySize, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func dailyReadDeeperDisclosure(_ text: String, ritual: DailyRitualResponse) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Button {
                let willExpand = !isDeeperReadExpanded
                withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
                    isDeeperReadExpanded.toggle()
                }
                if willExpand {
                    trackDailyReadEvent(.dailyReadExpanded, ritual: ritual, isSaved: store.ritualCompletedToday)
                }
            } label: {
                HStack(spacing: 7) {
                    Text(isDeeperReadExpanded ? "Hide deeper read" : "Behind the Lens")
                        .font(.system(size: 13, weight: .bold, design: .rounded))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .rotationEffect(.degrees(isDeeperReadExpanded ? 180 : 0))
                }
                .foregroundStyle(ZD.Color.accent)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isDeeperReadExpanded ? "Hide deeper read" : "Behind the Lens")

            if isDeeperReadExpanded {
                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.86))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    func fallbackCard(
        title: String,
        message: String,
        ctaTitle: String? = nil,
        ctaAction: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(.center)

            if !message.isEmpty {
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let ctaTitle, let ctaAction {
                Button(action: ctaAction) {
                    Text(ctaTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(ZD.Color.accent))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(20)
        .background(cardBackground(accent: ZD.Color.cardAlt.opacity(0.85), glow: ZD.Color.accent.opacity(0.10)))
    }

    var completedState: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(ZD.Color.accent)

            HStack(spacing: 0) {
                Text("Lens saved for today ")
                    .foregroundStyle(ZD.Color.textPrimary)

                Text("+5 points added")
                    .foregroundStyle(ZD.Color.accent)
            }
            .font(.system(size: 14, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(ZD.Color.card.opacity(0.85))
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.accent.opacity(0.16), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    var momentumMoment: some View {
        if let moment = store.dailyReadMomentumMoment,
           moment.dateKey == DailyReadingStore.dateKey() {
            Text(moment.message)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
        }
    }

    func cardBackground(accent: Color, glow: Color) -> some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        ZD.Color.card.opacity(0.98),
                        ZD.Color.cardAlt.opacity(0.90),
                        ZD.Color.card.opacity(0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        accent.opacity(0.16),
                        .clear,
                        glow.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .fill(glow.opacity(0.10))
                    .frame(width: 150, height: 150)
                    .blur(radius: 16)
                    .offset(x: 88, y: -74)
            )
            .overlay(
                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .blur(radius: 14)
                    .offset(x: -62, y: 128)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.14),
                                accent.opacity(0.16),
                                Color.black.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: ZD.Color.shadow.opacity(0.22), radius: 22, x: 0, y: 12)
    }

    func shimmeringGoldTitle(
        _ text: String,
        font: Font,
        shimmerActive: Bool,
        baseOpacity: Double = 0.18
    ) -> some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(font)
                .foregroundStyle(ZD.Color.accent.opacity(baseOpacity))
                .blur(radius: 10)

            Text(text)
                .font(font)
                .foregroundStyle(cardGoldStroke)

            Text(text)
                .font(font)
                .foregroundStyle(.clear)
                .overlay(
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white.opacity(0.05),
                                        ZD.Color.accent.opacity(0.34),
                                        Color.white.opacity(0.84),
                                        ZD.Color.accent.opacity(0.38),
                                        Color.white.opacity(0.06),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 104, height: proxy.size.height + 18)
                            .rotationEffect(.degrees(12))
                            .offset(x: shimmerActive ? proxy.size.width + 124 : -124)
                    }
                )
                .mask(
                    Text(text)
                        .font(font)
                )
                .allowsHitTesting(false)
        }
        .compositingGroup()
    }

    var cardGoldStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.60, green: 0.45, blue: 0.13),
                Color(red: 0.90, green: 0.79, blue: 0.44),
                Color(red: 0.74, green: 0.58, blue: 0.20),
                Color(red: 0.96, green: 0.88, blue: 0.60),
                Color(red: 0.58, green: 0.42, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Hold Button

private extension DailyRitualView {
    var holdButton: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isPressing ? ZD.Color.accent.opacity(0.95) : ZD.Color.accent)

                Capsule()
                    .fill(Color.white.opacity(isPressing ? 0.28 : 0.24))
                    .frame(width: holdProgress)

                Text("Hold to lock it in")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 56)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        startHold(width: geo.size.width)
                    }
                    .onEnded { _ in
                        endHold()
                    }
            )
        }
        .frame(height: 56)
    }

    func startHold(width: CGFloat) {
        guard !store.ritualCompletedToday else { return }
        guard holdWorkItem == nil else { return }

        isPressing = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        hasCompletedHold = false

        withAnimation(.linear(duration: 0.65)) {
            holdProgress = width
        }

        let workItem = DispatchWorkItem {
            hasCompletedHold = true
            complete()
        }

        holdWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65, execute: workItem)
    }

    func endHold() {
        guard !store.ritualCompletedToday else { return }

        if !hasCompletedHold {
            holdWorkItem?.cancel()
            resetHold()
        }

        holdWorkItem = nil
    }

    func complete() {
        guard !store.ritualCompletedToday else { return }

        holdWorkItem?.cancel()
        holdWorkItem = nil

        store.completeDailyRitual(context: context, reward: 5)

        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            holdProgress = 0
            isPressing = false
            showCompletionExtras = true
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func trackDailyReadOpened(_ ritual: DailyRitualResponse) {
        guard ritual.hasRealDailyReadContent else { return }
        let trackingKey = dailyReadDateKey(for: ritual)
        guard trackedDailyReadOpenKeys.insert(trackingKey).inserted else { return }
        trackDailyReadEvent(.dailyReadOpened, ritual: ritual, isSaved: store.ritualCompletedToday)
    }

    func trackDailyReadEvent(
        _ type: PatternMemoryEventType,
        ritual: DailyRitualResponse,
        isSaved: Bool?
    ) {
        PatternMemoryService.shared.track(
            event: PatternMemoryEvent(
                type: type,
                dateKey: dailyReadDateKey(for: ritual),
                identity: currentPatternMemoryIdentity,
                title: ritual.title,
                theme: ritual.title,
                focus: ritual.validDeeperRead ?? ritual.intro,
                isSaved: isSaved
            )
        )
    }

    func dailyReadDateKey(for ritual: DailyRitualResponse) -> String {
        ritual.ritualDate?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? (ritual.ritualDate ?? DailyReadingStore.dateKey())
            : DailyReadingStore.dateKey()
    }

    var currentPatternMemoryIdentity: String? {
        store.currentUser.map { "\($0.westernSign.displayName) × \($0.chineseSign.displayName)" }
    }

    func resetHold() {
        holdWorkItem?.cancel()
        holdWorkItem = nil
        hasCompletedHold = false

        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
            isPressing = false
        }
    }
}

// MARK: - Post Completion Actions

private extension DailyRitualView {
    var postRitualActions: some View {
        VStack(spacing: 12) {
            Button {
                store.selectedTab = .home
                dismiss()
            } label: {
                ritualActionCard(
                    title: "Return to Lens",
                    subtitle: "Today’s Lens is saved",
                    icon: "sun.max.fill",
                    accent: ZD.Color.accent
                )
            }
            .buttonStyle(.plain)

            Button {
                store.selectedTab = .blueprint
                dismiss()
            } label: {
                ritualActionCard(
                    title: "Open Identity",
                    subtitle: "See the profile behind your Lens",
                    icon: "book.fill",
                    accent: ZD.Color.accent
                )
            }
            .buttonStyle(.plain)

            Button {
                store.selectedTab = .connect
                dismiss()
            } label: {
                ritualActionCard(
                    title: "See who matches today",
                    subtitle: "Find people who fit Today’s Lens",
                    icon: "person.2.fill",
                    accent: ZD.Color.premium
                )
            }
            .buttonStyle(.plain)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    func ritualActionCard(title: String, subtitle: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.muted)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ZD.Color.card.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )
        )
    }

    func dailyReadField(_ primary: String?, fallback: String?) -> String? {
        let primaryValue = normalizedDailyReadText(primary)
        if let primaryValue {
            return primaryValue
        }

        return normalizedDailyReadText(fallback)
    }

    func normalizedDailyReadText(_ value: String?) -> String? {
        guard let value else { return nil }
        let collapsed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return collapsed.isEmpty ? nil : collapsed
    }

    func firstDailyRitualSentence(from text: String) -> String? {
        splitDailyRitualSentences(text).first
    }

    func secondDailyRitualSentence(from text: String) -> String? {
        splitDailyRitualSentences(text).dropFirst().first
    }

    func remainingDailyRitualSentences(from text: String, after count: Int) -> String? {
        let sentences = splitDailyRitualSentences(text)
        guard sentences.count > count else { return nil }
        return sentences.dropFirst(count).joined(separator: " ")
    }

    func splitDailyRitualSentences(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let matches = trimmed.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return matches.isEmpty ? [trimmed] : matches
    }
}
