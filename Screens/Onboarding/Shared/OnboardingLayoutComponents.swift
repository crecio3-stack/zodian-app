import SwiftUI

struct OnboardingMark: View {
    var size: CGFloat = OnboardingHeroMetrics.logoSize

    var body: some View {
        Image("zodianMark")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: ZD.Color.accent.opacity(0.16), radius: 18, y: 0)
    }
}

struct OnboardingHeroHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let tone: OnboardingHeroTone
    let isVisible: Bool
    let shimmerActive: Bool
    let shimmerMode: OnboardingHeroShimmerMode

    @State private var singleSweepActive = false

    var body: some View {
        VStack(spacing: OnboardingHeroMetrics.logoToEyebrowSpacing) {
            OnboardingMark()

            VStack(spacing: 0) {
                shimmerText(eyebrow, active: activeShimmer)
                    .font(ZD.Font.caption(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(ZD.Color.accent.opacity(tone == .arrival ? 0.92 : 0.80))

                Text(title)
                    .font(titleFont)
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, OnboardingHeroMetrics.eyebrowToTitleSpacing)

                Text(subtitle)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320)
                    .padding(.top, OnboardingHeroMetrics.subtitleTopSpacing)
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .animation(.easeOut(duration: 0.55), value: isVisible)
        .onAppear {
            guard shimmerMode == .singleSweep else { return }
            singleSweepActive = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.linear(duration: 1.9)) {
                    singleSweepActive = true
                }
            }
        }
        .onDisappear {
            if shimmerMode == .singleSweep {
                singleSweepActive = false
            }
        }
    }

    private var titleFont: Font {
        switch tone {
        case .arrival:
            return ZD.Font.display()
        case .ritual:
            return ZD.Font.title()
        }
    }

    private var activeShimmer: Bool {
        switch shimmerMode {
        case .looping:
            return shimmerActive
        case .singleSweep:
            return singleSweepActive
        case .none:
            return false
        }
    }

    private func shimmerText(_ text: String, active: Bool) -> some View {
        ZStack {
            Text(text)
                .foregroundStyle(ZD.Color.accent.opacity(0.16))
                .blur(radius: 10)

            Text(text)
                .foregroundStyle(ZD.Color.accent.opacity(0.88))

            Text(text)
                .foregroundStyle(.clear)
                .overlay(
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        Color.white.opacity(0.04),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.95),
                                        ZD.Color.accent.opacity(0.60),
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.04),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 120, height: proxy.size.height + 10)
                            .rotationEffect(.degrees(12))
                            .offset(x: active ? proxy.size.width + 150 : -150)
                    }
                )
                .mask(Text(text))
                .allowsHitTesting(false)
        }
        .fixedSize()
        .compositingGroup()
    }
}

struct OnboardingExperienceView<Hero: View, Content: View, Footer: View>: View {
    let layoutStyle: OnboardingStepLayoutStyle
    let parallaxOffset: CGFloat
    @ViewBuilder let hero: () -> Hero
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    @State private var ambientFloat = false

    var body: some View {
        switch layoutStyle {
        case .arrival:
            ZStack(alignment: .bottom) {
                content()
                    .frame(maxWidth: .infinity)

                footer()
                    .offset(y: parallaxOffset * 0.10)
                    .padding(.bottom, 4)
            }
        case .card:
            VStack(spacing: 0) {
                Spacer(minLength: OnboardingHeroMetrics.topSpacing)

                hero()
                    .offset(y: parallaxOffset * 0.38)
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.bottom, OnboardingHeroMetrics.bottomSpacing)

                persistentCard

                Spacer(minLength: 8)

                footer()
                    .offset(y: parallaxOffset * 0.14)
                    .padding(.bottom, 20)
            }
        }
    }

    private var persistentCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.96),
                            ZD.Color.cardAlt.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.16), lineWidth: 1)
                )

            content()
        }
        .frame(maxWidth: 350)
        .frame(maxWidth: .infinity)
        .frame(minHeight: OnboardingHeroMetrics.cardMinHeight, alignment: .top)
        .padding(.horizontal, ZD.Spacing.l)
        .shadow(color: ZD.Color.accent.opacity(0.10), radius: 24, y: 10)
        .offset(y: ambientFloat ? -1.5 : 1.5)
        .scaleEffect(ambientFloat ? 1.002 : 0.998)
        .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: ambientFloat)
        .onAppear {
            ambientFloat = true
        }
    }
}

struct AtmosphericCTADock<Content: View>: View {
    let progress: CGFloat
    let lagOffset: CGFloat
    let hitThreshold: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        let clampedProgress = min(max(progress, 0), 1)

        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    ZD.Color.bg.opacity(0.0),
                    ZD.Color.bg.opacity(0.04 * clampedProgress),
                    ZD.Color.bg.opacity(0.10 * clampedProgress),
                    ZD.Color.bg.opacity(0.18 * clampedProgress)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 112)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        ZD.Color.accent.opacity(0.06 * clampedProgress),
                        ZD.Color.accent.opacity(0.015 * clampedProgress),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 34)
                .blur(radius: 16)
            }
            .overlay(alignment: .bottom) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.08 * clampedProgress),
                                Color.black.opacity(0.08 * clampedProgress),
                                .clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 180
                        )
                    )
                    .frame(width: 420, height: 92)
                    .blur(radius: 20)
                    .offset(y: 14)
            }
            .allowsHitTesting(false)

            content()
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.top, 10)
                .padding(.bottom, 6)
                .opacity(clampedProgress)
                .offset(y: ((1 - clampedProgress) * 18) + lagOffset)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(clampedProgress > hitThreshold)
    }
}

struct WelcomeStarLayer: View {
    let points: [CGPoint]
    let size: CGFloat
    let opacity: Double
    let driftX: CGFloat
    let driftY: CGFloat
    let twinkleStrength: Double

    @State private var twinkle = false

    var body: some View {
        ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(Color.white.opacity(twinkleOpacity(for: index)))
                    .frame(width: starSize(for: index), height: starSize(for: index))
                    .shadow(
                        color: ZD.Color.accent.opacity(twinkleOpacity(for: index) * 0.8),
                        radius: starSize(for: index) * 2.2,
                        y: 0
                    )
                    .blur(radius: starSize(for: index) > 2 ? 0.15 : 0.0)
                    .offset(
                        x: point.x + (driftX * motionVector(for: index).x),
                        y: point.y + (driftY * motionVector(for: index).y)
                    )
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: Double.random(in: 2.2...4.6))
                    .repeatForever(autoreverses: true)
            ) {
                twinkle = true
            }
        }
    }

    private func starSize(for index: Int) -> CGFloat {
        if index.isMultiple(of: 5) { return size * 1.35 }
        if index.isMultiple(of: 3) { return size * 1.15 }
        return size
    }

    private func twinkleOpacity(for index: Int) -> Double {
        let base = opacity * (index.isMultiple(of: 4) ? 1.12 : 1.0)
        return twinkle ? base : base * twinkleStrength
    }

    private func motionVector(for index: Int) -> CGPoint {
        let angle = Double((index * 47) % 360) * .pi / 180
        let x = CGFloat(cos(angle))
        let y = CGFloat(sin(angle))
        return CGPoint(x: x == 0 ? 0.35 : x, y: y == 0 ? -0.35 : y)
    }
}

struct WelcomeBrightStarLayer: View {
    let points: [CGPoint]
    let driftX: CGFloat
    let driftY: CGFloat

    @State private var twinkle = false

    var body: some View {
        ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(twinkle ? 0.92 : 0.52))
                        .frame(width: 2.8, height: 2.8)
                        .shadow(color: Color.white.opacity(0.85), radius: 6, y: 0)
                        .shadow(color: ZD.Color.accent.opacity(0.55), radius: 10, y: 0)

                    Circle()
                        .stroke(Color.white.opacity(twinkle ? 0.24 : 0.10), lineWidth: 0.6)
                        .frame(width: 7, height: 7)
                        .blur(radius: 0.2)
                }
                .offset(
                    x: point.x + (driftX * motionVector(for: index).x) + CGFloat(index * 2),
                    y: point.y + (driftY * motionVector(for: index).y) - CGFloat(index * 2)
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true)) {
                twinkle = true
            }
        }
    }

    private func motionVector(for index: Int) -> CGPoint {
        let angle = Double((index * 73) % 360) * .pi / 180
        let x = CGFloat(cos(angle))
        let y = CGFloat(sin(angle))
        return CGPoint(x: x == 0 ? -0.42 : x, y: y == 0 ? 0.42 : y)
    }
}

struct OnboardingAmbientBackground: View {
    let style: OnboardingAmbientStyle

    @State private var ambientDrift = false

    var body: some View {
        ZStack {
            ZD.Color.bg
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(goldPrimaryOpacity),
                    ZD.Color.accent.opacity(goldSecondaryOpacity),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .scaleEffect(ambientDrift ? 1.12 : 0.96)
            .offset(x: ambientDrift ? -18 : 14, y: ambientDrift ? -34 : -6)
            .blur(radius: style == .welcome ? 16 : 20)
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    ZD.Color.forest.opacity(forestOpacity),
                    .clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 260
            )
            .scaleEffect(ambientDrift ? 1.08 : 0.94)
            .offset(x: ambientDrift ? 26 : -20, y: ambientDrift ? 56 : 18)
            .blur(radius: style == .welcome ? 18 : 22)
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.clear,
                    ZD.Color.bg.opacity(style == .welcome ? 0.50 : 0.72)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 520
            )
            .ignoresSafeArea()

            WelcomeStarLayer(
                points: farStarPoints,
                size: 1.1,
                opacity: style == .welcome ? 0.16 : 0.07,
                driftX: ambientDrift ? 6 : -6,
                driftY: ambientDrift ? -8 : 8,
                twinkleStrength: style == .welcome ? 0.55 : 0.72
            )

            WelcomeStarLayer(
                points: midStarPoints,
                size: 1.8,
                opacity: style == .welcome ? 0.26 : 0.10,
                driftX: ambientDrift ? 10 : -10,
                driftY: ambientDrift ? -12 : 12,
                twinkleStrength: style == .welcome ? 0.72 : 0.80
            )

            WelcomeStarLayer(
                points: nearStarPoints,
                size: 2.6,
                opacity: style == .welcome ? 0.42 : 0.14,
                driftX: ambientDrift ? 14 : -14,
                driftY: ambientDrift ? -16 : 16,
                twinkleStrength: style == .welcome ? 0.9 : 0.84
            )

            WelcomeBrightStarLayer(
                points: heroStarPoints,
                driftX: ambientDrift ? 12 : -12,
                driftY: ambientDrift ? -14 : 14
            )
            .opacity(style == .welcome ? 1 : 0.42)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7.2).repeatForever(autoreverses: true)) {
                ambientDrift = true
            }
        }
    }

    private var goldPrimaryOpacity: Double {
        style == .welcome ? 0.14 : 0.05
    }

    private var goldSecondaryOpacity: Double {
        style == .welcome ? 0.03 : 0.012
    }

    private var forestOpacity: Double {
        style == .welcome ? 0.24 : 0.08
    }

    private var farStarPoints: [CGPoint] {
        [
            CGPoint(x: -150, y: -270),
            CGPoint(x: 132, y: -246),
            CGPoint(x: -176, y: -96),
            CGPoint(x: 162, y: -54),
            CGPoint(x: -132, y: 94),
            CGPoint(x: 168, y: 128),
            CGPoint(x: -98, y: 246),
            CGPoint(x: 112, y: 264),
            CGPoint(x: -28, y: -188),
            CGPoint(x: 34, y: 204),
            CGPoint(x: -170, y: 20),
            CGPoint(x: 176, y: 20)
        ]
    }

    private var midStarPoints: [CGPoint] {
        [
            CGPoint(x: -118, y: -232),
            CGPoint(x: 102, y: -202),
            CGPoint(x: -146, y: -42),
            CGPoint(x: 136, y: -12),
            CGPoint(x: -122, y: 128),
            CGPoint(x: 142, y: 162),
            CGPoint(x: -74, y: 222),
            CGPoint(x: 82, y: 232),
            CGPoint(x: -12, y: -152),
            CGPoint(x: 18, y: 172),
            CGPoint(x: -154, y: 86),
            CGPoint(x: 148, y: 88)
        ]
    }

    private var nearStarPoints: [CGPoint] {
        [
            CGPoint(x: -96, y: -186),
            CGPoint(x: 78, y: -166),
            CGPoint(x: -124, y: 18),
            CGPoint(x: 126, y: 34),
            CGPoint(x: -92, y: 156),
            CGPoint(x: 104, y: 188),
            CGPoint(x: -48, y: 246),
            CGPoint(x: 56, y: 258)
        ]
    }

    private var heroStarPoints: [CGPoint] {
        [
            CGPoint(x: -142, y: -118),
            CGPoint(x: 148, y: -86),
            CGPoint(x: -116, y: 188),
            CGPoint(x: 122, y: 204)
        ]
    }
}
