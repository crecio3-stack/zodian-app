import SwiftUI

struct WesternStepView: View {
    @Binding var selectedSign: WesternZodiac
    let currentSignName: String
    let supportText: String
    let dateRange: String
    let isSelecting: Bool
    let isRevealed: Bool
    let glyphVisible: Bool
    let identityVisible: Bool
    let supportingVisible: Bool
    let ctaVisible: Bool
    let footerRevealProgress: CGFloat
    let centerBoosted: Bool
    let transitionLineVisible: Bool
    let revealActive: Bool
    let ctaTitle: String
    let isCTAEnabled: Bool
    let onSignChange: (WesternZodiac) -> Void
    let onPrimaryAction: () -> Void
    let onAppear: () -> Void

    var body: some View {
        OnboardingExperienceView(
            layoutStyle: .arrival,
            parallaxOffset: 0,
            hero: {
                Color.clear.frame(height: 0)
            },
            content: {
                GeometryReader { _ in
                    VStack(spacing: 0) {
                        OnboardingHeroHeader(
                            eyebrow: "Western Astrology · Month + Day",
                            title: "What arrives first",
                            subtitle: "Choose the sign tied to the month and day you were born",
                            tone: .ritual,
                            isVisible: true,
                            shimmerActive: false,
                            shimmerMode: .singleSweep
                        )
                        .padding(.top, OnboardingHeroMetrics.topSpacing)
                        .padding(.bottom, 24)

                        Spacer(minLength: 24)

                        WesternZodiacWheelSelectorView(
                            signs: WesternZodiac.allCases,
                            selectedSign: $selectedSign,
                            isSelecting: isSelecting,
                            isRevealed: isRevealed,
                            signName: currentSignName,
                            supportText: supportText,
                            dateRange: dateRange,
                            glyphVisible: glyphVisible,
                            identityVisible: identityVisible,
                            supportingVisible: supportingVisible,
                            centerBoosted: centerBoosted,
                            transitionLineVisible: transitionLineVisible,
                            revealActive: revealActive,
                            onSelectSign: onSignChange
                        )
                        .frame(maxWidth: .infinity, minHeight: 320)

                        Spacer(minLength: 36)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.bottom, OnboardingHeroMetrics.footerReservedHeight)
                }
            },
            footer: {
                AtmosphericCTADock(
                    progress: revealActive ? (ctaVisible ? 1 : 0) : footerRevealProgress,
                    lagOffset: 0,
                    hitThreshold: 0.6
                ) {
                    PrimaryButton(
                        title: ctaTitle,
                        action: onPrimaryAction,
                        isDisabled: !isCTAEnabled,
                        icon: nil,
                        fullWidth: true
                    )
                }
            }
        )
        .onAppear(perform: onAppear)
    }
}

private struct WesternZodiacWheelSelectorView: View {
    let signs: [WesternZodiac]
    @Binding var selectedSign: WesternZodiac
    let isSelecting: Bool
    let isRevealed: Bool
    let signName: String
    let supportText: String
    let dateRange: String
    let glyphVisible: Bool
    let identityVisible: Bool
    let supportingVisible: Bool
    let centerBoosted: Bool
    let transitionLineVisible: Bool
    let revealActive: Bool
    let onSelectSign: (WesternZodiac) -> Void

    @State private var wheelRotation: Double = 0
    @State private var dragStartRotation: Double = 0
    @State private var isDraggingWheel = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(isSelecting ? 0.18 : 0.12))
                    .frame(width: 360, height: 360)
                    .blur(radius: 54)

                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1.1)
                    .frame(width: 320, height: 320)

                Circle()
                    .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1.4)
                    .frame(width: 342, height: 342)

                radialGuides
                    .rotationEffect(.degrees(wheelRotation))
                    .opacity(revealActive ? 0.18 : 1.0)
                    .animation(.easeInOut(duration: 0.22), value: revealActive)

                selectedSegmentHighlight
                    .rotationEffect(.degrees(wheelRotation))
                    .opacity(revealActive ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: revealActive)

                ForEach(Array(signs.enumerated()), id: \.element.id) { index, sign in
                    wheelNode(for: sign, index: index)
                        .opacity(revealActive ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.22), value: revealActive)
                }

                centerMedallion
                    .scaleEffect(centerBoosted ? 1.04 : 1.0)
                    .scaleEffect(revealActive ? 1.34 : 1.0)
                    .opacity(revealActive ? 0.0 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: revealActive)

                if revealActive {
                    expandedRevealSun
                        .transition(.opacity.combined(with: .scale(scale: 0.82)))
                }

                fixedSelectionIndicator
                    .opacity(revealActive ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: revealActive)
            }
            .frame(width: 360, height: 360)
            .frame(maxWidth: .infinity)
            .contentShape(Circle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 6)
                    .onChanged { value in
                        if !isDraggingWheel {
                            isDraggingWheel = true
                            dragStartRotation = wheelRotation
                        }

                        let delta = -value.translation.width * 0.3
                        wheelRotation = dragStartRotation + delta
                    }
                    .onEnded { value in
                        isDraggingWheel = false

                        let projectedDelta = -value.predictedEndTranslation.width * 0.3
                        let projectedRotation = dragStartRotation + projectedDelta
                        let snappedIndex = normalizedIndex(for: projectedRotation)

                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

                        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                            selectedSign = signs[snappedIndex]
                            wheelRotation = rotationDegrees(for: snappedIndex)
                        }
                        onSelectSign(signs[snappedIndex])
                    }
            )

            if !revealActive {
                Text("Tap or scroll to select your sign")
                    .font(ZD.Font.caption(.semibold))
                    .tracking(0.4)
                    .foregroundStyle(ZD.Color.muted.opacity(isSelecting ? 0.72 : 0.58))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            wheelRotation = rotationDegrees(for: selectedIndex)
        }
        .onChange(of: selectedSign) { _, _ in
            withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
                wheelRotation = rotationDegrees(for: selectedIndex)
            }
        }
    }

    private var selectedIndex: Int {
        signs.firstIndex(of: selectedSign) ?? 0
    }

    private func westernRevealTitle(for sign: WesternZodiac) -> String {
        switch sign {
        case .aries: return "The Initiator"
        case .taurus: return "The Anchor"
        case .gemini: return "The Messenger"
        case .cancer: return "The Protector"
        case .leo: return "The Radiant"
        case .virgo: return "The Refiner"
        case .libra: return "The Harmonizer"
        case .scorpio: return "The Alchemist"
        case .sagittarius: return "The Seeker"
        case .capricorn: return "The Architect"
        case .aquarius: return "The Visionary"
        case .pisces: return "The Dreamer"
        }
    }

    private func revealDescription(for sign: WesternZodiac) -> String {
        switch sign {
        case .aries: return "Direct, immediate, and impossible to ignore"
        case .taurus: return "Steady, grounded, and deeply rooted"
        case .gemini: return "Quick, curious, and always in motion"
        case .cancer: return "Intuitive, protective, and emotionally tuned"
        case .leo: return "Radiant, expressive, and built to be seen"
        case .virgo: return "Precise, thoughtful, and quietly powerful"
        case .libra: return "Balanced, magnetic, and naturally harmonizing"
        case .scorpio: return "Intense, private, and deeply perceptive"
        case .sagittarius: return "Expansive, bold, and always seeking"
        case .capricorn: return "Structured, driven, and quietly dominant"
        case .aquarius: return "Original, detached, and forward-thinking"
        case .pisces: return "Fluid, dreamy, and deeply intuitive"
        }
    }

    private func normalizedIndex(for rotation: Double) -> Int {
        let step = 360.0 / Double(signs.count)
        let raw = (-rotation / step).rounded()
        let wrapped = Int(raw).quotientAndRemainder(dividingBy: signs.count).remainder
        return wrapped >= 0 ? wrapped : wrapped + signs.count
    }

    private var centerMedallion: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(centerBoosted ? 0.44 : 0.24),
                            ZD.Color.accent.opacity(centerBoosted ? 0.14 : 0.06),
                            Color.black.opacity(0.96)
                        ],
                        center: .center,
                        startRadius: 18,
                        endRadius: 180
                    )
                )
                .frame(width: centerBoosted ? 198 : 188, height: centerBoosted ? 198 : 188)
                .scaleEffect(centerBoosted ? 1.04 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: centerBoosted)
                .shadow(color: ZD.Color.accent.opacity(centerBoosted ? 0.34 : 0.18), radius: centerBoosted ? 26 : 14, y: 0)
                .shadow(color: Color.white.opacity(centerBoosted ? 0.10 : 0.04), radius: centerBoosted ? 10 : 4, y: 0)

            Circle()
                .stroke(Color.white.opacity(0.16), lineWidth: 1.2)
                .frame(width: 184, height: 184)

            Circle()
                .stroke(ZD.Color.accent.opacity(centerBoosted ? 0.42 : 0.22), lineWidth: 1)
                .frame(width: centerBoosted ? 194 : 186, height: centerBoosted ? 194 : 186)

            VStack(spacing: 6) {
                Text(selectedSign.glyph)
                    .font(.system(size: centerBoosted ? 72 : 62, weight: .medium, design: .serif))
                    .foregroundStyle(heroGoldGradient)
                    .shadow(color: ZD.Color.accent.opacity(centerBoosted ? 0.42 : 0.24), radius: centerBoosted ? 20 : 16, y: 0)
                    .scaleEffect(glyphVisible ? 1 : 0.92)
                    .opacity(glyphVisible ? 1 : 0.28)

                Text(signName)
                    .offset(y: -4)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(revealActive ? (identityVisible ? 1 : 0) : 1)

                Text(dateRange)
                    .offset(y: -2)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .foregroundStyle(ZD.Color.accent.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .opacity(revealActive ? (supportingVisible ? 1 : 0) : 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .frame(width: 170)
        }
        .scaleEffect(centerBoosted ? 1.07 : 1.0)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: centerBoosted)
    }

    private var expandedRevealSun: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.58),
                            ZD.Color.accent.opacity(0.22),
                            Color.black.opacity(0.97)
                        ],
                        center: .center,
                        startRadius: 26,
                        endRadius: 260
                    )
                )
                .frame(width: 338, height: 338)
                .shadow(color: ZD.Color.accent.opacity(0.34), radius: 34, y: 0)
                .shadow(color: Color.white.opacity(0.08), radius: 10, y: 0)

            Circle()
                .stroke(Color.white.opacity(0.16), lineWidth: 1.2)
                .frame(width: 324, height: 324)

            Circle()
                .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1.0)
                .frame(width: 338, height: 338)

            VStack(spacing: 8) {
                Text(selectedSign.glyph)
                    .font(.system(size: 62, weight: .medium, design: .serif))
                    .foregroundStyle(heroGoldGradient)
                    .shadow(color: ZD.Color.accent.opacity(0.30), radius: 14, y: 0)

                Text(signName)
                    .font(.system(size: 33, weight: .semibold, design: .serif))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(dateRange)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .tracking(0.7)
                    .foregroundStyle(ZD.Color.accent.opacity(0.88))
                    .multilineTextAlignment(.center)

                Text(westernRevealTitle(for: selectedSign))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .tracking(1.0)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ZD.Color.textPrimary)
                    .padding(.top, 2)

                Text(revealDescription(for: selectedSign))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 28)
            .frame(width: 272)
        }
        .scaleEffect(revealActive ? 1.0 : 0.72)
        .opacity(revealActive ? 1.0 : 0.0)
        .animation(.spring(response: 0.52, dampingFraction: 0.86), value: revealActive)
    }

    private var fixedSelectionIndicator: some View {
        VStack(spacing: 0) {
            Image(systemName: "triangle.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.94, green: 0.96, blue: 1.0),
                            Color(red: 0.78, green: 0.82, blue: 0.90),
                            Color(red: 0.56, green: 0.60, blue: 0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.white.opacity(0.18), radius: 8, y: 0)
                .offset(y: -2)

            Spacer()
        }
        .padding(.top, 10)
        .allowsHitTesting(false)
    }

    private var radialGuides: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 1, height: 74)
                    .offset(y: -135)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
        }
    }

    private var selectedSegmentHighlight: some View {
        Circle()
            .trim(from: 0.955, to: 0.045)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.92, blue: 0.76).opacity(0.95),
                        Color(red: 0.84, green: 0.68, blue: 0.22).opacity(0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
            )
            .frame(width: 342, height: 342)
            .shadow(color: ZD.Color.accent.opacity(0.24), radius: 10, y: 0)
    }

    private func wheelNode(for sign: WesternZodiac, index: Int) -> some View {
        let isSelected = sign == selectedSign
        let segmentOffset = (.pi * 2) / Double(signs.count) / 2
        let angle = ((Double(index) / Double(signs.count)) * (.pi * 2) - (.pi / 2) + segmentOffset) + (wheelRotation * .pi / 180)
        let radius: CGFloat = 131
        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return Button {
            guard let tappedIndex = signs.firstIndex(of: sign) else { return }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                selectedSign = sign
                wheelRotation = rotationDegrees(for: tappedIndex)
            }
            onSelectSign(sign)
        } label: {
            VStack(spacing: 3) {
                Text(sign.glyph)
                    .font(.system(size: isSelected ? 32 : 27, weight: .medium, design: .serif))
                    .foregroundStyle(isSelected ? AnyShapeStyle(heroGoldGradient) : AnyShapeStyle(Color(red: 0.92, green: 0.84, blue: 0.66).opacity(0.96)))
                    .shadow(color: ZD.Color.accent.opacity(isSelected ? 0.38 : 0.12), radius: isSelected ? 16 : 5, y: 0)

                Text(sign.displayName)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(ZD.Color.textPrimary.opacity(isSelected ? 0.96 : 0.64))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(width: 62, height: 48)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .opacity(isSelected ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .position(x: 180 + x, y: 180 + y)
    }

    private func rotationDegrees(for index: Int) -> Double {
        -(Double(index) * 30 + 15)
    }

    private var heroGoldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.91, blue: 0.72),
                Color(red: 0.84, green: 0.68, blue: 0.22),
                Color(red: 0.55, green: 0.41, blue: 0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
