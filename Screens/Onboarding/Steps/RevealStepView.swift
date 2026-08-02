import SwiftUI

struct MergingCalculatingView: View {
    let background: AnyView
    let phase: RevealPhase
    let revealFlashActive: Bool
    let onAppear: () -> Void

    var body: some View {
        ZStack {
            background

            Rectangle()
                .fill(Color.black.opacity(0.18))
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(phase == .suspended ? 0.18 : 0.12),
                    ZD.Color.accent.opacity(0.05),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 260
            )
            .blur(radius: 18)
            .opacity(0.72)

            VStack(spacing: 24) {
                ZStack {
                    StaticConvergenceBridge()
                        .frame(width: 170, height: 92)
                        .opacity(phase == .revealing ? 0.14 : 0.28)

                    LoadingConvergenceAnimationView(phase: phase)
                        .frame(width: 190, height: 190)
                        .scaleEffect(loadingCoreScale(for: phase))
                        .opacity(loadingCoreOpacity(for: phase))

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(phase == .revealing ? 0.22 : 0.10),
                                    ZD.Color.accent.opacity(phase == .suspended ? 0.28 : 0.14),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 92
                            )
                        )
                        .frame(width: 148, height: 148)
                        .blur(radius: phase == .suspended ? 10 : 16)
                        .scaleEffect(phase == .compressing ? 0.84 : (phase == .suspended ? 1.03 : 1.12))
                        .opacity(phase == .suspended ? 0.42 : 0.22)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(revealFlashActive ? 0.20 : 0.0),
                                    ZD.Color.accent.opacity(revealFlashActive ? 0.12 : 0.0),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                        .scaleEffect(revealFlashActive ? 1.08 : 0.82)
                        .opacity(revealFlashActive ? 1 : 0)
                        .blendMode(.screen)
                }
                .frame(height: 220)

                Text(loadingCopy(for: phase))
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: onAppear)
    }

    private func loadingCopy(for phase: RevealPhase) -> String {
        switch phase {
        case .idle, .compressing:
            return "Bringing both lenses together..."
        case .suspended:
            return "Looking for the pattern..."
        case .revealing:
            return "Your pattern is coming into focus..."
        }
    }

    private func loadingCoreScale(for phase: RevealPhase) -> CGFloat {
        switch phase {
        case .idle:
            return 1.0
        case .compressing:
            return 0.90
        case .suspended:
            return 0.95
        case .revealing:
            return 0.88
        }
    }

    private func loadingCoreOpacity(for phase: RevealPhase) -> Double {
        switch phase {
        case .idle:
            return 1.0
        case .compressing:
            return 0.94
        case .suspended:
            return 0.80
        case .revealing:
            return 0.18
        }
    }
}

private struct LoadingConvergenceAnimationView: View {
    let phase: RevealPhase

    @State private var leftOffset: CGFloat = -72
    @State private var rightOffset: CGFloat = 72
    @State private var collisionProgress: CGFloat = 0
    @State private var flashActive = false
    @State private var suspensionPulse = false

    var body: some View {
        ConvergenceOrbPair(
            leftOffset: leftOffset,
            rightOffset: rightOffset,
            collisionProgress: collisionProgress,
            flashActive: flashActive,
            suspendedPulse: suspensionPulse
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            applyPhase(phase, animated: false)
        }
        .onChange(of: phase) { _, newPhase in
            applyPhase(newPhase, animated: true)
        }
    }

    private func applyPhase(_ phase: RevealPhase, animated: Bool) {
        suspensionPulse = false

        switch phase {
        case .idle:
            if animated {
                withAnimation(.easeOut(duration: 0.35)) {
                    leftOffset = -62
                    rightOffset = 62
                    collisionProgress = 0.08
                    flashActive = false
                }
            } else {
                leftOffset = -62
                rightOffset = 62
                collisionProgress = 0.08
                flashActive = false
            }

        case .compressing:
            withAnimation(.easeInOut(duration: 2.15)) {
                leftOffset = -10
                rightOffset = 10
                collisionProgress = 0.68
                flashActive = false
            }

        case .suspended:
            withAnimation(.easeInOut(duration: 0.55)) {
                leftOffset = 0
                rightOffset = 0
                collisionProgress = 0.96
                flashActive = false
            }

            withAnimation(.easeInOut(duration: 0.8)) {
                suspensionPulse = true
            }

        case .revealing:
            withAnimation(.easeInOut(duration: 0.5)) {
                leftOffset = 0
                rightOffset = 0
                collisionProgress = 1.0
                flashActive = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                withAnimation(.easeOut(duration: 0.18)) {
                    flashActive = false
                }
            }
        }
    }
}

struct RevealStepView: View {
    let background: AnyView
    let revealState: RevealAnimationState
    let content: IdentityCardContent?
    let onComplete: () -> Void
    let onShare: () -> Void
    let onAppear: () -> Void

    var body: some View {
        ZStack {
            background

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(revealState.revealBackdropVisible ? 0.20 : 0.0),
                    ZD.Color.accent.opacity(revealState.revealBackdropVisible ? 0.08 : 0.0),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()
            .blur(radius: 10)
            .opacity(revealState.revealBackdropVisible ? 1 : 0)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(revealState.revealFlash ? 0.35 : 0),
                            ZD.Color.accent.opacity(revealState.revealFlash ? 0.25 : 0),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .ignoresSafeArea()
                .blur(radius: 30)
                .blendMode(.screen)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer(minLength: 8)

                    if let content {
                        VStack(spacing: 12) {
                            VStack(spacing: 10) {
                                OnboardingMark()
                                    .opacity(revealState.revealHeaderVisible ? 1 : 0)
                                    .offset(y: revealState.revealHeaderVisible ? 0 : 10)

                                Text("This is you")
                                    .font(ZD.Font.title())
                                    .foregroundStyle(ZD.Color.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .opacity(revealState.revealHeaderVisible ? 1 : 0)
                                    .offset(y: revealState.revealHeaderVisible ? 0 : 10)
                            }

                            OnboardingRevealIdentityCard(
                                content: content,
                                revealState: revealState,
                                includeBrandFooter: false,
                                forceVisible: false
                            )
                            .scaleEffect(revealState.revealScale)
                            .opacity(revealState.revealOpacity)
                            .offset(y: revealState.revealCardLift)
                            .shadow(
                                color: ZD.Color.accent.opacity(revealState.revealGlow ? 0.26 : 0.08),
                                radius: revealState.revealGlow ? 42 : 14,
                                y: 12
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))

                            PrimaryButton(
                                title: "Enter Zodian",
                                action: onComplete,
                                isDisabled: false,
                                icon: "arrow.right",
                                fullWidth: true
                            )
                            .opacity(revealState.revealButtonVisible ? 1 : 0)
                            .offset(y: revealState.revealButtonVisible ? 0 : 12)

                            SecondaryButton(
                                title: "Share Your Identity ✦",
                                action: onShare,
                                icon: "square.and.arrow.up",
                                fullWidth: true
                            )
                            .opacity(revealState.revealShareVisible ? 1 : 0)
                            .offset(y: revealState.revealShareVisible ? 0 : 12)
                        }
                        .frame(maxWidth: 360)
                        .padding(.horizontal, ZD.Spacing.l)
                    }

                    Spacer(minLength: 42)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: UIScreen.main.bounds.height - 40)
                .padding(.vertical, 12)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 28)
            }
        }
        .onAppear(perform: onAppear)
    }
}

private struct OnboardingRevealIdentityCard: View {
    let content: IdentityCardContent
    let revealState: RevealAnimationState
    let includeBrandFooter: Bool
    let forceVisible: Bool

    var body: some View {
        IdentityRevealCardView(
            content: content,
            includeBrandFooter: includeBrandFooter
        )
        .overlay {
            if !forceVisible {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(revealState.revealGlow ? 0.34 : 0.0),
                                ZD.Color.accent.opacity(revealState.revealGlow ? 0.30 : 0.0),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.15
                    )
                    .padding(8)
                    .blendMode(.screen)
                    .opacity(revealState.revealGlow ? 1 : 0)
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white,
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(8))
                            .offset(x: revealState.revealGlow ? 180 : -180)
                    )
                    .animation(.easeInOut(duration: 1.05), value: revealState.revealGlow)
            }
        }
    }
}
