import SwiftUI

struct EasternStepView: View {
    let currentSign: ChineseZodiac
    let currentYearText: String
    let signName: String
    let supportText: String
    let revealState: EasternRevealAnimationState
    let revealActive: Bool
    @Binding var selectedYear: Int
    let availableBirthYears: [Int]
    let onSelectSign: (ChineseZodiac) -> Void
    let onPrimaryAction: () -> Void
    let onClearFocus: () -> Void
    let onAppear: () -> Void

    @State private var ctaHasAppeared = false

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
                            eyebrow: "Eastern Astrology · Birth Year",
                            title: "What changes the feel",
                            subtitle: "Select the animal for your birth year.",
                            tone: .ritual,
                            isVisible: true,
                            shimmerActive: false,
                            shimmerMode: .singleSweep
                        )
                        .padding(.top, 18)
                        .padding(.bottom, 6)

                        Spacer(minLength: 0)

                        EasternZodiacWheelSelectorView(
                            signs: ChineseZodiac.allCases,
                            selectedSign: currentSign,
                            selectedYearText: currentYearText,
                            signName: signName,
                            supportText: supportText,
                            symbolVisible: revealState.symbolVisible,
                            identityVisible: revealState.identityVisible,
                            supportingVisible: revealState.supportingVisible,
                            centerBoosted: false,
                            transitionLineVisible: true,
                            revealActive: revealActive,
                            onSelectSign: onSelectSign
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 384)

                        Spacer(minLength: 0)

                        if !revealActive {
                            EasternYearSelector(
                                selectedYear: $selectedYear,
                                availableBirthYears: availableBirthYears,
                                onInteraction: onClearFocus
                            )
                            .padding(.top, 14)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        Spacer(minLength: OnboardingHeroMetrics.footerReservedHeight + 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, ZD.Spacing.l)
                }
            },
            footer: {
                AtmosphericCTADock(
                    progress: ctaHasAppeared ? 1 : 0,
                    lagOffset: 0,
                    hitThreshold: 0.6
                ) {
                    PrimaryButton(
                            title: revealActive ? "Bring it together" : "Reveal the deeper pattern",
                        action: onPrimaryAction,
                        isDisabled: false,
                        icon: "sparkles",
                        fullWidth: true
                    )
                }
            }
        )
        .onAppear {
            onAppear()

            if revealState.ctaVisible {
                ctaHasAppeared = true
            }
        }
        .onChange(of: revealState.ctaVisible) { _, isVisible in
            guard isVisible, !ctaHasAppeared else { return }

            withAnimation(.easeOut(duration: 0.55)) {
                ctaHasAppeared = true
            }
        }
    }
}

private struct EasternYearSelector: View {
    @Binding var selectedYear: Int
    let availableBirthYears: [Int]
    let onInteraction: () -> Void

    var body: some View {
        OnboardingRitualMoonWheelContainer(onInteraction: onInteraction) {
            Picker("Birth Year", selection: $selectedYear) {
                ForEach(availableBirthYears, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .clipped()
            .padding(.horizontal, 4)
            .colorScheme(.dark)
        }
        .frame(maxWidth: 160)
    }
}

private struct EasternZodiacWheelSelectorView: View {
    let signs: [ChineseZodiac]
    let selectedSign: ChineseZodiac
    let selectedYearText: String
    let signName: String
    let supportText: String
    let symbolVisible: Bool
    let identityVisible: Bool
    let supportingVisible: Bool
    let centerBoosted: Bool
    let transitionLineVisible: Bool
    let revealActive: Bool
    let onSelectSign: (ChineseZodiac) -> Void

    @State private var wheelRotation: Double = 0
    @State private var dragPreviousAngle: Double = 0
    @State private var isDraggingWheel = false
    @State private var hintPulse = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                easternBackgroundGlow

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.012),
                                Color.white.opacity(0.004),
                                .clear
                            ],
                            center: .center,
                            startRadius: 18,
                            endRadius: 185
                        )
                    )
                    .frame(width: 344, height: 344)
                    .blur(radius: 26)

                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1.1)
                    .frame(width: 320, height: 320)

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.92, green: 0.94, blue: 0.98).opacity(0.34),
                                Color(red: 0.74, green: 0.78, blue: 0.86).opacity(0.22),
                                Color(red: 0.54, green: 0.58, blue: 0.66).opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.4
                    )
                    .frame(width: 342, height: 342)

                easternRadialGuides
                    .rotationEffect(.degrees(wheelRotation))
                    .opacity(revealActive ? 0.18 : 1.0)
                    .animation(.easeInOut(duration: 0.22), value: revealActive)

                easternSelectedSegmentHighlight
                    .rotationEffect(.degrees(wheelRotation))
                    .opacity(revealActive ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: revealActive)

                ForEach(Array(signs.enumerated()), id: \.element.id) { index, sign in
                    easternWheelNode(for: sign, index: index)
                        .opacity(revealActive ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.22), value: revealActive)
                }

                easternCenterMoon
                    .opacity(revealActive ? 0.0 : 1.0)
                    .scaleEffect(revealActive ? 1.30 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.82), value: revealActive)

                if revealActive {
                    expandedRevealMoon
                        .transition(.opacity.combined(with: .scale(scale: 0.82)))
                }

                easternSelectionIndicator
                    .opacity(revealActive ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: revealActive)
            }
            .frame(width: 360, height: 360)
            .frame(maxWidth: .infinity)
            .contentShape(Circle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 6)
                    .onChanged { value in
                        guard !revealActive else { return }

                        if !isDraggingWheel {
                            isDraggingWheel = true
                            dragPreviousAngle = dragAngle(for: value.startLocation)
                        }

                        let currentAngle = dragAngle(for: value.location)
                        wheelRotation += normalizedAngleDelta(from: dragPreviousAngle, to: currentAngle)
                        dragPreviousAngle = currentAngle
                    }
                    .onEnded { value in
                        guard !revealActive else { return }
                        isDraggingWheel = false

                        let projectedAngle = dragAngle(for: value.predictedEndLocation)
                        let projectedRotation = wheelRotation + normalizedAngleDelta(from: dragPreviousAngle, to: projectedAngle)
                        let snappedIndex = normalizedIndex(for: projectedRotation)
                        let sign = signs[snappedIndex]

                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                            wheelRotation = rotationDegrees(for: snappedIndex)
                        }
                        onSelectSign(sign)
                    }
            )
            .onAppear {
                wheelRotation = rotationDegrees(for: selectedIndex)

                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    hintPulse = true
                }
            }
            .onChange(of: selectedSign) { _, _ in
                guard !isDraggingWheel else { return }
                withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
                    wheelRotation = rotationDegrees(for: selectedIndex)
                }
            }

            if !revealActive {
                Text("Tap or spin the wheel.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(moonMutedText.opacity(hintPulse ? 0.88 : 0.66))
                    .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Eastern astrology animal wheel")
        .accessibilityValue(selectedSign.displayName)
        .accessibilityHint("Swipe up or down to change your animal. Tap or spin the wheel to select.")
        .accessibilityAdjustableAction { direction in
            let nextIndex: Int
            switch direction {
            case .increment:
                nextIndex = (selectedIndex + 1) % signs.count
            case .decrement:
                nextIndex = (selectedIndex - 1 + signs.count) % signs.count
            @unknown default:
                return
            }

            let sign = signs[nextIndex]
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                wheelRotation = rotationDegrees(for: nextIndex)
            }
            onSelectSign(sign)
        }
    }

    private var easternBackgroundGlow: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.15),
                            ZD.Color.accent.opacity(0.07),
                            .clear
                        ],
                        center: .center,
                        startRadius: 14,
                        endRadius: 190
                    )
                )
                .frame(width: 286, height: 286)
                .blur(radius: 34)
                .offset(x: -8, y: 10)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 160
                    )
                )
                .frame(width: 228, height: 228)
                .blur(radius: 22)
                .offset(x: -2, y: 14)
        }
        .mask(
            Circle()
                .frame(width: 330, height: 330)
        )
        .allowsHitTesting(false)
    }

    private var selectedIndex: Int {
        signs.firstIndex(of: selectedSign) ?? 0
    }

    private func normalizedIndex(for rotation: Double) -> Int {
        let step = 360.0 / Double(signs.count)
        let raw = ((-rotation - step / 2) / step).rounded()
        let wrapped = Int(raw).quotientAndRemainder(dividingBy: signs.count).remainder
        return wrapped >= 0 ? wrapped : wrapped + signs.count
    }

    private func dragAngle(for point: CGPoint) -> Double {
        atan2(point.y - 180, point.x - 180) * 180 / .pi
    }

    private func normalizedAngleDelta(from previous: Double, to current: Double) -> Double {
        var delta = current - previous
        while delta > 180 { delta -= 360 }
        while delta < -180 { delta += 360 }
        return delta
    }

    private var easternCenterMoon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.88, green: 0.91, blue: 0.96).opacity(0.14),
                            Color(red: 0.54, green: 0.58, blue: 0.68).opacity(0.06),
                            Color.black.opacity(0.992)
                        ],
                        center: UnitPoint(x: 0.46, y: 0.40),
                        startRadius: 8,
                        endRadius: 132
                    )
                )
                .frame(width: 188, height: 188)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.06),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.42, y: 0.34),
                                startRadius: 2,
                                endRadius: 64
                            )
                        )
                        .blur(radius: 6)
                )
                .shadow(color: Color.black.opacity(0.28), radius: 18, y: 8)
                .shadow(color: Color.white.opacity(0.04), radius: 8, y: -1)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color(red: 0.72, green: 0.76, blue: 0.86).opacity(0.14),
                            Color.black.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.15
                )
                .frame(width: 184, height: 184)

            VStack(spacing: 6) {
                Text(selectedSign.emoji)
                    .font(.system(size: 58))
                    .grayscale(1.0)
                    .brightness(0.26)
                    .contrast(0.94)
                    .shadow(color: Color.white.opacity(0.12), radius: 8, y: 0)

                Text(signName)
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.97, green: 0.97, blue: 0.95))
                    .shadow(color: Color.white.opacity(0.08), radius: 5, y: 0)

                Text(selectedYearText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(0.9)
                    .foregroundStyle(Color(red: 0.68, green: 0.75, blue: 0.88))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .frame(width: 170)
        }
    }

    private var expandedRevealMoon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.90, green: 0.93, blue: 0.98).opacity(0.16),
                            Color(red: 0.56, green: 0.60, blue: 0.70).opacity(0.07),
                            Color.black.opacity(0.992)
                        ],
                        center: UnitPoint(x: 0.47, y: 0.42),
                        startRadius: 10,
                        endRadius: 230
                    )
                )
                .frame(width: 350, height: 350)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.02),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.42, y: 0.36),
                                startRadius: 4,
                                endRadius: 120
                            )
                        )
                        .blur(radius: 8)
                )
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.black.opacity(0.18),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.55, y: 0.65),
                                startRadius: 40,
                                endRadius: 200
                            )
                        )
                        .blendMode(.multiply)
                )
                .shadow(color: Color.black.opacity(0.34), radius: 26, y: 10)
                .shadow(color: Color.white.opacity(0.05), radius: 10, y: -2)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.20),
                            Color(red: 0.74, green: 0.78, blue: 0.88).opacity(0.16),
                            Color.black.opacity(0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
                .frame(width: 336, height: 336)

            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 0.8)
                .frame(width: 326, height: 326)

            VStack(spacing: 8) {
                Text(selectedSign.emoji)
                    .font(.system(size: 58))
                    .grayscale(1.0)
                    .brightness(0.28)
                    .contrast(0.94)
                    .shadow(color: Color.white.opacity(0.14), radius: 8, y: 0)

                Text(signName)
                    .font(.system(size: 33, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.98, green: 0.98, blue: 0.96))
                    .shadow(color: Color.white.opacity(0.10), radius: 6, y: 0)

                Text(selectedYearText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .tracking(0.9)
                    .foregroundStyle(Color(red: 0.70, green: 0.78, blue: 0.92))

                Text(revealTitle(for: selectedSign))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .tracking(1.1)
                    .foregroundStyle(Color(red: 0.86, green: 0.88, blue: 0.93))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Text(revealDescription(for: selectedSign))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.72, green: 0.75, blue: 0.80).opacity(0.94))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 28)
            .frame(width: 272)
        }
    }

    private var easternSelectionIndicator: some View {
        VStack(spacing: 0) {
            Image(systemName: "triangle.fill")
                .font(.system(size: 10, weight: .bold))
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
                .offset(y: -6)

            Spacer()
        }
        .padding(.top, 10)
        .allowsHitTesting(false)
    }

    private var easternRadialGuides: some View {
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

    private var moonPrimaryText: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.98, blue: 0.96),
                Color(red: 0.86, green: 0.88, blue: 0.92),
                Color(red: 0.70, green: 0.74, blue: 0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var moonMutedText: Color {
        Color(red: 0.82, green: 0.84, blue: 0.89).opacity(0.88)
    }

    private var easternSelectedSegmentHighlight: some View {
        ZStack {
            Circle()
                .trim(from: 0.955, to: 0.045)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.97, blue: 1.0).opacity(0.72),
                            Color(red: 0.78, green: 0.82, blue: 0.90).opacity(0.50)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
                )
                .frame(width: 342, height: 342)
                .shadow(color: Color.white.opacity(0.12), radius: 8, y: 0)
        }
    }

    private func easternWheelNode(for sign: ChineseZodiac, index: Int) -> some View {
        let isSelected = sign == selectedSign
        let segmentOffset = (.pi * 2) / Double(signs.count) / 2
        let angle = ((Double(index) / Double(signs.count)) * (.pi * 2) - (.pi / 2) + segmentOffset) + (wheelRotation * .pi / 180)

        let radius: CGFloat = 126
        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return Button {
            guard !revealActive else { return }
            guard let tappedIndex = signs.firstIndex(of: sign) else { return }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
                wheelRotation = rotationDegrees(for: tappedIndex)
            }
            onSelectSign(sign)
        } label: {
            VStack(spacing: 2) {
                Text(sign.emoji)
                    .font(.system(size: isSelected ? 24 : 21))
                    .grayscale(1.0)
                    .brightness(isSelected ? 0.24 : 0.14)
                    .contrast(isSelected ? 0.94 : 0.88)
                    .opacity(isSelected ? 1.0 : 0.78)
                    .shadow(color: Color.white.opacity(isSelected ? 0.10 : 0.04), radius: 6, y: 0)

                Text(sign.displayName)
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        isSelected
                            ? AnyShapeStyle(moonPrimaryText)
                            : AnyShapeStyle(Color(red: 0.72, green: 0.75, blue: 0.80).opacity(0.72))
                    )
                    .lineLimit(1)
            }
            .frame(width: 60, height: 52)
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .opacity(isSelected ? 1.0 : 0.62)
        }
        .buttonStyle(.plain)
        .position(x: 180 + x, y: 180 + y)
    }

    private func rotationDegrees(for index: Int) -> Double {
        -(Double(index) * 30 + 15)
    }

    private func revealTitle(for sign: ChineseZodiac) -> String {
        switch sign {
        case .rat: return "The Tactician"
        case .ox: return "The Foundation"
        case .tiger: return "The Drive"
        case .rabbit: return "The Sensor"
        case .dragon: return "The Core"
        case .snake: return "The Oracle"
        case .horse: return "The Surge"
        case .goat: return "The Vessel"
        case .monkey: return "The Shifter"
        case .rooster: return "The Edge"
        case .dog: return "The Sentinel"
        case .pig: return "The Well"
        }
    }

    private func revealDescription(for sign: ChineseZodiac) -> String {
        switch sign {
        case .rat: return "Quick, perceptive, and always reading the room"
        case .ox: return "Grounded, enduring, and slow to bend"
        case .tiger: return "Bold, reactive, and driven by real feeling"
        case .rabbit: return "Sensitive, composed, and highly attuned"
        case .dragon: return "Powerful, instinctive, and impossible to ignore"
        case .snake: return "Private, intuitive, and tuned beneath the surface"
        case .horse: return "Fast-moving, expressive, and fiercely alive"
        case .goat: return "Emotional, artistic, and deeply receptive"
        case .monkey: return "Inventive, flexible, and always pattern-seeking"
        case .rooster: return "Precise, direct, and sharpened by clarity"
        case .dog: return "Protective, loyal, and guided by inner truth"
        case .pig: return "Warm, sincere, and led by the heart"
        }
    }
}
