import SwiftUI

struct WelcomeStepView: View {
    let isActive: Bool
    let onContinue: () -> Void

    var body: some View {
        WelcomeCinematicStep(isActive: isActive, onContinue: onContinue)
    }
}

private struct WelcomeCinematicStep: View {
    let isActive: Bool
    let onContinue: () -> Void

    @State private var phase: WelcomePhase = .idle
    @State private var ctaBreathing = false
    @State private var ctaShimmer = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingAmbientBackground(style: .welcome)

                VStack(spacing: 0) {
                    WelcomeHeroLogo(
                        phase: phase,
                        dockedTop: geometry.safeAreaInsets.top + 54,
                        introCenterY: geometry.size.height * 0.50
                    )

                    Spacer()
                }
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 142)

                    WelcomeHeadlineBlock(phase: phase)
                        .padding(.horizontal, ZD.Spacing.l)

                    Spacer(minLength: 24)

                    HStack(alignment: .center, spacing: 16) {
                        WesternNode(phase: phase)

                        ZStack {
                            StaticConvergenceBridge()
                                .opacity(phase.hasReached(.systems) ? 0.92 : 0)
                                .scaleEffect(phase.hasReached(.systems) ? 1.0 : 0.92)
                                .offset(y: phase.hasReached(.systems) ? 0 : 10)
                        }
                        .frame(width: 140, height: 100)

                        EasternNode(phase: phase)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28)

                    Text("Start with what shows. Then go deeper.")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(0.3)
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.84))
                        .multilineTextAlignment(.center)
                        .opacity(phase.hasReached(.framing) ? 1 : 0)
                        .offset(y: phase.hasReached(.framing) ? 18 : 28)
                        .padding(.top, 38)
                        .padding(.horizontal, 36)

                    Spacer()

                    WelcomeCTA(
                        isVisible: phase.hasReached(.cta),
                        isBreathing: ctaBreathing,
                        shimmerActive: ctaShimmer,
                        action: onContinue
                    )
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10) + 14)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task(id: isActive) {
            guard isActive else { return }
            await runSequence()
        }
    }

    @MainActor
    private func runSequence() async {
        phase = .idle
        ctaBreathing = false
        ctaShimmer = false

        await animatePhase(.logoIntro, animation: .easeOut(duration: 1.2), delay: 0.12)

        Task {
            await animatePhase(.logoDocked, animation: .spring(duration: 1.0, bounce: 0.10), delay: 0.75)
        }

        Task {
            await animatePhase(.headline, animation: .easeOut(duration: 0.85), delay: 1.0)
        }

        Task {
            await animatePhase(.subheadline, animation: .easeOut(duration: 0.75), delay: 1.15)
        }

        Task {
            await animatePhase(.systems, animation: .spring(duration: 0.85, bounce: 0.08), delay: 1.35)
        }

        Task {
            await animatePhase(.framing, animation: .easeOut(duration: 0.7), delay: 1.5)
        }

        Task {
            await animatePhase(.cta, animation: .spring(duration: 0.9, bounce: 0.08), delay: 1.65)

            try? await Task.sleep(for: .seconds(0.2))

            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                ctaBreathing = true
            }
            withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                ctaShimmer = true
            }
        }
    }

    @MainActor
    private func animatePhase(_ nextPhase: WelcomePhase, animation: Animation, delay: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        withAnimation(animation) {
            phase = nextPhase
        }
    }
}

private struct WelcomeHeroLogo: View {
    let phase: WelcomePhase
    let dockedTop: CGFloat
    let introCenterY: CGFloat

    var body: some View {
        GeometryReader { geo in
            let isDocked = phase.hasReached(.logoDocked)

            VStack(spacing: 12) {
                OnboardingMark(size: isDocked ? OnboardingHeroMetrics.logoSize : 88)
                    .scaleEffect(phase == .logoIntro ? 1.18 : 1.0)
                    .opacity(phase == .idle ? 0 : 1)
                    .shadow(
                        color: ZD.Color.accent.opacity(phase.hasReached(.logoIntro) ? 0.22 : 0),
                        radius: phase.hasReached(.logoIntro) ? 34 : 0,
                        y: 0
                    )

                Text("WELCOME TO ZODIAN")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(ZD.Color.accent.opacity(0.88))
                    .opacity(phase.hasReached(.logoIntro) ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .position(
                x: geo.size.width / 2,
                y: isDocked ? (dockedTop + 26) : introCenterY
            )
            .animation(.spring(duration: 1.2, bounce: 0.10), value: isDocked)
        }
        .allowsHitTesting(false)
    }
}

private struct WelcomeHeadlineBlock: View {
    let phase: WelcomePhase

    var body: some View {
        VStack(spacing: 0) {
            Text("Your sign is only the start")
                .font(ZD.Font.display())
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(phase.hasReached(.headline) ? 1 : 0)
                .offset(y: phase.hasReached(.headline) ? 0 : 18)

            Text("Zodian reads Western and Eastern astrology together to reveal what sits beneath")
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.muted)
                .opacity(0.88)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)
                .opacity(phase.hasReached(.subheadline) ? 1 : 0)
                .offset(y: phase.hasReached(.subheadline) ? 0 : 10)
        }
    }
}

private struct WesternNode: View {
    let phase: WelcomePhase

    var body: some View {
        WelcomeSystemNode(
            title: "Western",
            subtitle: "What people see first",
            style: .western,
            isVisible: phase.hasReached(.systems),
            direction: -1
        )
    }
}

private struct EasternNode: View {
    let phase: WelcomePhase

    var body: some View {
        WelcomeSystemNode(
            title: "Eastern",
            subtitle: "What shifts everything",
            style: .eastern,
            isVisible: phase.hasReached(.systems),
            direction: 1
        )
    }
}

private struct WelcomeSystemNode: View {
    enum SystemStyle {
        case western
        case eastern
    }

    let title: String
    let subtitle: String
    let style: SystemStyle
    let isVisible: Bool
    let direction: CGFloat

    @State private var float = false

    var body: some View {
        VStack(spacing: 12) {
            miniOrb
                .offset(y: float ? -2 : 2)
                .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: float)

            VStack(spacing: 6) {
                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 120)
        }
        .frame(maxWidth: .infinity)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : 34 * direction, y: isVisible ? 0 : 8)
        .onAppear {
            float = true
        }
    }

    @ViewBuilder
    private var miniOrb: some View {
        switch style {
        case .western:
            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.16))
                    .frame(width: 74, height: 74)
                    .blur(radius: 18)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                ZD.Color.accent.opacity(0.82),
                                ZD.Color.accent.opacity(0.22),
                                .clear
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: 38
                        )
                    )
                    .frame(width: 52, height: 52)
                    .blur(radius: 6)

                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    .frame(width: 56, height: 56)
                    .blur(radius: 0.6)
            }
        case .eastern:
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 74, height: 74)
                    .blur(radius: 18)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.92),
                                Color(red: 0.78, green: 0.82, blue: 0.90).opacity(0.72),
                                Color(red: 0.38, green: 0.42, blue: 0.50).opacity(0.28),
                                .clear
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: 38
                        )
                    )
                    .frame(width: 52, height: 52)
                    .blur(radius: 6)

                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 56, height: 56)
                    .blur(radius: 0.5)
            }
        }
    }
}

private struct WelcomeCTA: View {
    let isVisible: Bool
    let isBreathing: Bool
    let shimmerActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Reveal My Identity")
                .font(.system(size: 17, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Color.black.opacity(0.88))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(buttonBackground)
                .overlay(topSpecularHighlight)
                .overlay(innerGlowStroke)
                .overlay(edgeStroke)
                .overlay(buttonShimmer)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.28), radius: 16, y: 10)
                .shadow(color: ZD.Color.accent.opacity(isBreathing ? 0.18 : 0.08), radius: isBreathing ? 26 : 14, y: 6)
                .scaleEffect(isBreathing ? 1.01 : 0.995)
        }
        .buttonStyle(.plain)
        .background(buttonHalo)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.94)
        .offset(y: isVisible ? 0 : 18)
    }

    private var buttonHalo: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(ZD.Color.accent.opacity(0.08))
            .blur(radius: 26)
            .scaleEffect(isBreathing ? 1.08 : 0.96)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.49, green: 0.35, blue: 0.09),
                        Color(red: 0.76, green: 0.60, blue: 0.21),
                        Color(red: 0.96, green: 0.87, blue: 0.63),
                        Color(red: 0.83, green: 0.66, blue: 0.27),
                        Color(red: 0.52, green: 0.38, blue: 0.10)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        .clear,
                        Color.black.opacity(0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
    }

    private var topSpecularHighlight: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.34),
                        Color.white.opacity(0.10),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .blendMode(.screen)
    }

    private var innerGlowStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .inset(by: 1.2)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.clear,
                        Color.black.opacity(0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
    }

    private var edgeStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.42),
                        Color(red: 0.96, green: 0.87, blue: 0.60).opacity(0.42),
                        Color(red: 0.38, green: 0.27, blue: 0.06).opacity(0.58)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.15
            )
    }

    private var buttonShimmer: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.clear)
            .overlay(
                GeometryReader { proxy in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.22),
                                    Color.white.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 118, height: proxy.size.height + 12)
                        .rotationEffect(.degrees(8))
                        .offset(x: shimmerActive ? proxy.size.width + 130 : -130)
                }
            )
            .mask(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
    }
}
