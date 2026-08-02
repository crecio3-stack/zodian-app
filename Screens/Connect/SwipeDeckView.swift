import SwiftUI
import UIKit

private enum SwipeDeckLayout {
    static let cardContentHeight: CGFloat = 420
    static let cardStackHeight: CGFloat = 460
    static let totalHeight: CGFloat = 534
}

struct SwipeDeckView: View {
    fileprivate enum Motion {
        static let horizontalIntentThreshold: CGFloat = 12
        static let horizontalIntentRatio: CGFloat = 1.2
        static let swipeThreshold: CGFloat = 104
        static let swipeDispatchDelay = 0.09
        static let dragTiltDivisor: CGFloat = 20
        static let dragLiftFactor: CGFloat = 0.022
        static let maxDragLift: CGFloat = 8
    }

    private enum DragIntent {
        case undecided
        case horizontal
        case vertical
    }
    struct SwipeDragValue {
        let translation: CGSize
    }
    struct MoodPalette {
        let ambient: Color
        let accent: Color
        let accentSecondary: Color
        let overlayOpacity: Double
        let glowOpacity: Double
        let entryResponse: Double
        let entryDamping: Double
        let resetResponse: Double
        let resetDamping: Double
        let swipeResponse: Double
        let swipeDamping: Double
        let stackSettleResponse: Double
        let stackSettleDamping: Double
    }

    struct SwipeCommand: Equatable {
        let action: SwipeAction
        let profileID: UUID
    }

    let profiles: [DeckProfile]
    let mood: ConnectFilter
    let isSwipeLocked: Bool
    @Binding var pendingCommand: SwipeCommand?
    let onSwipe: (SwipeAction, DeckProfile) -> Void
    let onPreview: (DeckProfile) -> Void
    let onUndo: () -> Void

    static let preferredHeight: CGFloat = SwipeDeckLayout.totalHeight

    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var hasAnimatedIn = false
    @State private var dragIntent: DragIntent = .undecided

    private var moodPalette: MoodPalette {
        switch mood {
        case .compatible:
            return MoodPalette(
                ambient: Color(red: 0.34, green: 0.47, blue: 0.61),
                accent: Color(red: 0.74, green: 0.82, blue: 0.90),
                accentSecondary: Color(red: 0.46, green: 0.60, blue: 0.74),
                overlayOpacity: 0.115,
                glowOpacity: 0.135,
                entryResponse: 0.50,
                entryDamping: 0.915,
                resetResponse: 0.29,
                resetDamping: 0.86,
                swipeResponse: 0.25,
                swipeDamping: 0.90,
                stackSettleResponse: 0.32,
                stackSettleDamping: 0.91
            )
        case .similar:
            return MoodPalette(
                ambient: ZD.Color.accent,
                accent: ZD.Color.accent,
                accentSecondary: ZD.Color.forest,
                overlayOpacity: 0.11,
                glowOpacity: 0.13,
                entryResponse: 0.50,
                entryDamping: 0.9,
                resetResponse: 0.28,
                resetDamping: 0.84,
                swipeResponse: 0.24,
                swipeDamping: 0.88,
                stackSettleResponse: 0.30,
                stackSettleDamping: 0.90
            )
        case .newEnergy:
            return MoodPalette(
                ambient: Color(red: 0.82, green: 0.66, blue: 0.22),
                accent: Color(red: 0.93, green: 0.81, blue: 0.49),
                accentSecondary: Color(red: 0.70, green: 0.52, blue: 0.17),
                overlayOpacity: 0.115,
                glowOpacity: 0.14,
                entryResponse: 0.44,
                entryDamping: 0.89,
                resetResponse: 0.25,
                resetDamping: 0.82,
                swipeResponse: 0.22,
                swipeDamping: 0.86,
                stackSettleResponse: 0.28,
                stackSettleDamping: 0.88
            )
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ForEach(Array(profiles.prefix(1).enumerated()), id: \.element.id) { index, profile in
                    SwipeDeckCard(
                        profile: profile,
                        mood: mood,
                        isTopCard: index == 0,
                        dragOffset: index == 0 ? dragOffset : .zero,
                        cardRotation: index == 0 ? cardRotation : 0,
                        stackedOffset: CGFloat(index) * 10,
                        stackedScale: 1.0 - (CGFloat(index) * 0.028),
                        likeOpacity: index == 0 ? min(max(dragOffset.width / Motion.swipeThreshold, 0), 1) : 0,
                        passOpacity: index == 0 ? min(max(-dragOffset.width / Motion.swipeThreshold, 0), 1) : 0,
                        moodPalette: moodPalette,
                        hasAnimatedIn: hasAnimatedIn,
                        onDrag: handleDrag,
                        onEnd: { handleEnd($0, profile: profile) },
                        onTap: { onPreview(profile) }
                    )
                    .zIndex(Double(profiles.count - index))
                }
            }
            .frame(height: SwipeDeckLayout.cardStackHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))

            dock(for: profiles.first)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .onAppear {
            guard !hasAnimatedIn else { return }
            dragOffset = CGSize(width: 0, height: 10)
            withAnimation(.spring(response: moodPalette.entryResponse, dampingFraction: moodPalette.entryDamping)) {
                hasAnimatedIn = true
                dragOffset = .zero
            }
        }
        .onChange(of: profiles.first?.id) {
            withAnimation(.spring(response: moodPalette.stackSettleResponse, dampingFraction: moodPalette.stackSettleDamping)) {
                dragOffset = .zero
                cardRotation = 0
            }
            dragIntent = .undecided
        }
        .onChange(of: pendingCommand) {
            let command = pendingCommand
            guard let command, let profile = profiles.first, profile.id == command.profileID else { return }
            animateProgrammaticSwipe(command.action, profile: profile)
        }
    }

    private func dock(for profile: DeckProfile?) -> some View {
        HStack(spacing: 12) {
            dockOrb(
                systemName: "arrow.uturn.backward",
                size: 44,
                isPrimary: false,
                action: onUndo
            )

            dockOrb(
                systemName: "xmark",
                size: 44,
                isPrimary: false,
                action: {
                    guard let profile else { return }
                    pendingCommand = .init(action: .pass, profileID: profile.id)
                }
            )

            dockOrb(
                systemName: "sparkles",
                size: 44,
                isPrimary: true,
                action: {
                    guard let profile else { return }
                    pendingCommand = .init(action: .like, profileID: profile.id)
                }
            )

            dockOrb(
                systemName: "eye.fill",
                size: 44,
                isPrimary: false,
                action: {
                    guard let profile else { return }
                    onPreview(profile)
                }
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.80),
                            moodPalette.accentSecondary.opacity(0.15),
                            ZD.Color.cardAlt.opacity(0.32)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: ZD.Stroke.thin)
                )
                .shadow(color: moodPalette.ambient.opacity(0.12), radius: 18, y: 10)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private func dockOrb(
        systemName: String,
        size: CGFloat,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let isPassAction = systemName == "xmark"

        return Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isPrimary ? Color.black : ZD.Color.textPrimary.opacity(isPassAction ? 0.95 : 0.72))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            isPrimary
                            ? AnyShapeStyle(ZD.Gradient.gold)
                            : isPassAction
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.86, green: 0.20, blue: 0.18),
                                        Color(red: 0.48, green: 0.07, blue: 0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        moodPalette.accentSecondary.opacity(0.18),
                                        ZD.Color.cardAlt.opacity(0.44)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isPrimary
                                    ? moodPalette.accent.opacity(0.24)
                                    : isPassAction
                                    ? Color.white.opacity(0.20)
                                    : Color.white.opacity(0.18),
                                    lineWidth: ZD.Stroke.thin
                                )
                        )
                )
                .shadow(
                    color: isPrimary
                    ? moodPalette.accent.opacity(moodPalette.glowOpacity)
                    : isPassAction
                    ? Color(red: 0.86, green: 0.20, blue: 0.18).opacity(0.18)
                    : moodPalette.ambient.opacity(0.05),
                    radius: isPrimary ? 10 : (isPassAction ? 8 : 4),
                    y: isPrimary ? 5 : (isPassAction ? 4 : 2)
                )
        }
        .buttonStyle(SwipeDockOrbButtonStyle(isPrimary: isPrimary))
        .disabled(isSwipeLocked && systemName != "arrow.uturn.backward")
        .opacity(isPrimary ? 1.0 : 0.92)
    }

    private func handleDrag(_ value: SwipeDragValue) {
        guard !isSwipeLocked else { return }

        let horizontal = value.translation.width
        let vertical = value.translation.height
        let absHorizontal = abs(horizontal)
        let absVertical = abs(vertical)

        switch dragIntent {
        case .undecided:
            if absHorizontal > Motion.horizontalIntentThreshold,
               absHorizontal > absVertical * Motion.horizontalIntentRatio {
                dragIntent = .horizontal
            } else if absVertical > Motion.horizontalIntentThreshold {
                dragIntent = .vertical
                return
            } else {
                return
            }

        case .horizontal:
            break

        case .vertical:
            return
        }

        dragOffset = CGSize(
            width: horizontal,
            height: min(absHorizontal * Motion.dragLiftFactor, Motion.maxDragLift)
        )
        cardRotation = Double(horizontal / Motion.dragTiltDivisor)
    }

    private func handleEnd(_ value: SwipeDragValue, profile: DeckProfile) {
        defer { dragIntent = .undecided }

        guard !isSwipeLocked else {
            resetCardPosition()
            return
        }

        guard dragIntent == .horizontal else { return }

        let horizontal = value.translation.width

        if horizontal > Motion.swipeThreshold {
            animateSwipe(.like, profile: profile)
        } else if horizontal < -Motion.swipeThreshold {
            animateSwipe(.pass, profile: profile)
        } else {
            resetCardPosition()
        }
    }

    private func animateProgrammaticSwipe(_ action: SwipeAction, profile: DeckProfile) {
        guard !isSwipeLocked else { return }
        animateSwipe(action, profile: profile)
    }

    private func animateSwipe(_ action: SwipeAction, profile: DeckProfile) {
        let destinationX: CGFloat = action == .like ? 420 : -420

        withAnimation(.spring(response: moodPalette.swipeResponse, dampingFraction: moodPalette.swipeDamping)) {
            dragOffset = CGSize(width: destinationX, height: 8)
            cardRotation = action == .like ? 11 : -11
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Motion.swipeDispatchDelay) {
            onSwipe(action, profile)
        }
    }

    private func resetCardPosition() {
        withAnimation(.spring(response: moodPalette.resetResponse, dampingFraction: moodPalette.resetDamping)) {
            dragOffset = .zero
            cardRotation = 0
        }
    }
}

private struct SwipeDeckCard: View {
    let profile: DeckProfile
    let mood: ConnectFilter
    let isTopCard: Bool
    let dragOffset: CGSize
    let cardRotation: Double
    let stackedOffset: CGFloat
    let stackedScale: CGFloat
    let likeOpacity: Double
    let passOpacity: Double
    let moodPalette: SwipeDeckView.MoodPalette
    let hasAnimatedIn: Bool
    let onDrag: (SwipeDeckView.SwipeDragValue) -> Void
    let onEnd: (SwipeDeckView.SwipeDragValue) -> Void
    let onTap: () -> Void

    private var hookLine: String {
        let connectionPrompt = profile.connectionPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let essence = profile.essence.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !connectionPrompt.isEmpty else { return essence }
        guard !essence.isEmpty else { return connectionPrompt }

        return essence.count <= connectionPrompt.count ? essence : connectionPrompt
    }

    var body: some View {
        TarotCardContainer {
            ZStack {
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(Color.white.opacity(0.035))
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: ZD.Stroke.thin)
                    )

                swipeableCardContent
            }
            .frame(height: SwipeDeckLayout.cardContentHeight)
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
        }
        .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
        .offset(y: stackedOffset)
        .scaleEffect(isTopCard ? activeScale : stackedScale)
        .opacity(isTopCard ? (hasAnimatedIn ? 1 : 0) : 1)
        .shadow(color: Color.black.opacity(isTopCard ? 0.18 : 0.06), radius: isTopCard ? 24 : 10, y: isTopCard ? 16 : 6)
        .animation(.spring(response: moodPalette.resetResponse, dampingFraction: moodPalette.resetDamping), value: dragOffset)
        .animation(.easeOut(duration: 0.16), value: stackedOffset)
        .overlay {
            HorizontalSwipeCaptureView(
                isEnabled: isTopCard,
                onChanged: onDrag,
                onEnded: onEnd,
                onTap: onTap
            )
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
        }
    }

    private var swipeableCardContent: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                ConnectProfileImage(
                    assetName: profile.imageName,
                    size: CGSize(width: proxy.size.width, height: proxy.size.height + 40),
                    focalPoint: profile.imageAnchor,
                    clipShape: .roundedRectangle(ZD.Radius.xl)
                )
                .offset(y: -20)
            }

            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.12),
                    Color.black.opacity(0.46),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [moodPalette.accent.opacity(moodPalette.overlayOpacity * cardOverlayMultiplier), .clear],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    SwipeDeckBadge(score: profile.compatibilityScore, moodPalette: moodPalette)
                    Spacer()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(profile.name)
                            .font(.system(size: 33, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text("· \(profile.age)")
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.76))
                    }

                    Text(profile.combinedSigns)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(1.2)

                    Text(profile.archetypeTitle)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(red: 0.93, green: 0.83, blue: 0.63))
                        .lineLimit(1)

                    Text(hookLine)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.78))
                        .padding(.top, 2)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .padding(.bottom, 14)

            HStack {
                if passOpacity > 0 {
                    SwipeStamp(title: "SKIP", isLike: false)
                        .opacity(passOpacity)
                        .rotationEffect(.degrees(-12))
                        .padding(.leading, 18)
                        .padding(.top, 18)
                }

                Spacer()

                if likeOpacity > 0 {
                    SwipeStamp(title: "KEEP", isLike: true)
                        .opacity(likeOpacity)
                        .rotationEffect(.degrees(12))
                        .padding(.trailing, 18)
                        .padding(.top, 18)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: ZD.Stroke.thin)
        )
        .shadow(color: moodPalette.ambient.opacity(0.12), radius: 24, y: 12)
        .offset(
            x: isTopCard ? dragOffset.width : 0,
            y: isTopCard ? dragOffset.height : 0
        )
        .rotationEffect(isTopCard ? .degrees(cardRotation) : .degrees(0))
    }

    private var activeScale: CGFloat {
        let travel = min(abs(dragOffset.width) / 240, 1)
        return 1.008 + (travel * 0.01)
    }

    private var cardOverlayMultiplier: Double {
        switch mood {
        case .newEnergy:
            return 0.85
        case .compatible, .similar:
            return 1.0
        }
    }
}

private struct SwipeDeckBadge: View {
    let score: Int
    let moodPalette: SwipeDeckView.MoodPalette

    private var pullLabel: String {
        switch score {
        case 90...:
            return "Clear"
        case 82..<90:
            return "Strong"
        case 74..<82:
            return "Notable"
        default:
            return "Subtle"
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(pullLabel)
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundStyle(Color.white.opacity(0.96))

            Text("Signal")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(Color.white.opacity(0.76))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.14),
                            moodPalette.accentSecondary.opacity(0.16),
                            ZD.Color.cardAlt.opacity(0.24)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(moodPalette.accent.opacity(0.25), lineWidth: 1)
                )
        )
        .shadow(color: moodPalette.accent.opacity(0.25), radius: 10, y: 4)
    }
}

private struct SwipeStamp: View {
    let title: String
    let isLike: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(isLike ? ZD.Color.success : ZD.Color.error)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isLike ? ZD.Color.success : ZD.Color.error,
                        lineWidth: 2.5
                    )
            )
    }
}

private struct SwipeDockOrbButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? (isPrimary ? 0.94 : 0.955) : 1)
            .brightness(configuration.isPressed ? 0.02 : 0)
            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}
private struct HorizontalSwipeCaptureView: UIViewRepresentable {
    let isEnabled: Bool
    let onChanged: (SwipeDeckView.SwipeDragValue) -> Void
    let onEnded: (SwipeDeckView.SwipeDragValue) -> Void
    let onTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.delegate = context.coordinator
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.onChanged = onChanged
        context.coordinator.onEnded = onEnded
        context.coordinator.onTap = onTap
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isEnabled: isEnabled, onChanged: onChanged, onEnded: onEnded, onTap: onTap)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var isEnabled: Bool
        var onChanged: (SwipeDeckView.SwipeDragValue) -> Void
        var onEnded: (SwipeDeckView.SwipeDragValue) -> Void
        var onTap: () -> Void

        init(
            isEnabled: Bool,
            onChanged: @escaping (SwipeDeckView.SwipeDragValue) -> Void,
            onEnded: @escaping (SwipeDeckView.SwipeDragValue) -> Void,
            onTap: @escaping () -> Void
        ) {
            self.isEnabled = isEnabled
            self.onChanged = onChanged
            self.onEnded = onEnded
            self.onTap = onTap
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isEnabled else { return false }

            if let pan = gestureRecognizer as? UIPanGestureRecognizer,
               let view = pan.view {
                let velocity = pan.velocity(in: view)
                return abs(velocity.x) > abs(velocity.y) * 1.35
            }

            return true
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard let view = recognizer.view else { return }

            let translation = recognizer.translation(in: view)
            let value = SwipeDeckView.SwipeDragValue(
                translation: CGSize(width: translation.x, height: translation.y)
            )

            switch recognizer.state {
            case .changed:
                onChanged(value)
            case .ended, .cancelled, .failed:
                onEnded(value)
            default:
                break
            }
        }

        @objc func handleTap() {
            guard isEnabled else { return }
            onTap()
        }
    }
}
