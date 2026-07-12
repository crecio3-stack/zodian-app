import SwiftUI

struct MergingStepView<NameSection: View, TimeSection: View, PlaceSection: View>: View {
    let scrollOffset: CGFloat
    let keyboardHeight: CGFloat
    let uiFadeOut: Bool
    let revealState: MergingRevealAnimationState
    let optionalRefinementExpanded: Bool
    let footerRevealProgress: CGFloat
    let isBeginRevealDisabled: Bool
    let onBeginReveal: () -> Void
    let onToggleOptionalRefinement: () -> Void
    let onAppear: () -> Void
    let onScrollOffsetChange: (CGFloat) -> Void
    let onFooterSentinelChange: (CGFloat, CGFloat) -> Void
    @ViewBuilder let nameSection: () -> NameSection
    @ViewBuilder let timeSection: () -> TimeSection
    @ViewBuilder let placeSection: () -> PlaceSection

    var body: some View {
        OnboardingExperienceView(
            layoutStyle: .arrival,
            parallaxOffset: parallaxShift(from: scrollOffset),
            hero: {
                Color.clear.frame(height: 0)
            },
            content: {
                ScrollViewReader { scrollProxy in
                    GeometryReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: OnboardingScrollOffsetKey.self,
                                            value: geo.frame(in: .named("mergeOnboardingScroll")).minY
                                        )
                                }
                                .frame(height: 0)

                                OnboardingHeroHeader(
                                    eyebrow: "Convergence",
                                    title: "Bring the two together",
                                    subtitle: "Western is your month and day. Eastern follows your birth year. Put them together here",
                                    tone: .ritual,
                                    isVisible: true,
                                    shimmerActive: false,
                                    shimmerMode: .singleSweep
                                )
                                .padding(.top, OnboardingHeroMetrics.topSpacing)
                                .padding(.bottom, 18)
                                .opacity(uiFadeOut ? 0 : 1)
                                .offset(y: (parallaxShift(from: scrollOffset) * 0.22) + (uiFadeOut ? -12 : 0))

                                Spacer(minLength: 34)

                                MergingConvergencePreview(
                                    westernVisible: revealState.westernVisible,
                                    easternVisible: revealState.easternVisible,
                                    combinedVisible: revealState.combinedVisible
                                )
                                .frame(maxWidth: .infinity, minHeight: 220)
                                .scaleEffect(uiFadeOut ? 1.04 : 1.0)
                                .offset(
                                    y: (parallaxShift(from: scrollOffset) * 0.08) + (uiFadeOut ? -6 : 0)
                                )

                                Spacer(minLength: 32)

                                nameSection()
                                    .frame(maxWidth: 336)
                                    .opacity(uiFadeOut ? 0 : (revealState.contentVisible ? 1 : 0))
                                    .offset(y: uiFadeOut ? 20 : (revealState.contentVisible ? 0 : 14))

                                MergingOptionalRefinementSection(
                                    isExpanded: optionalRefinementExpanded,
                                    onToggle: onToggleOptionalRefinement,
                                    timeSection: timeSection,
                                    placeSection: placeSection
                                )
                                .frame(maxWidth: 336)
                                .opacity(uiFadeOut ? 0 : (revealState.contentVisible ? 1 : 0))
                                .offset(y: uiFadeOut ? 20 : (revealState.contentVisible ? 0 : 14))
                                .padding(.top, optionalRefinementExpanded ? 18 : 14)

                                Color.clear
                                    .frame(height: 1)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: OnboardingFooterSentinelKey.self,
                                                value: geo.frame(in: .named("mergeOnboardingScroll")).minY
                                            )
                                        }
                                    )

                                Spacer(minLength: 20)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(
                                minHeight: max(
                                    proxy.size.height - (keyboardHeight > 0 ? keyboardHeight + 24 : OnboardingHeroMetrics.footerReservedHeight),
                                    0
                                ),
                                alignment: .top
                            )
                            .padding(.horizontal, ZD.Spacing.l)
                            .padding(
                                .bottom,
                                keyboardHeight > 0
                                    ? keyboardHeight + 24
                                    : OnboardingHeroMetrics.footerReservedHeight
                            )
                        }
                        .coordinateSpace(name: "mergeOnboardingScroll")
                        .onPreferenceChange(OnboardingScrollOffsetKey.self, perform: onScrollOffsetChange)
                        .onPreferenceChange(OnboardingFooterSentinelKey.self) { minY in
                            onFooterSentinelChange(minY, proxy.size.height)
                        }
                        .onChange(of: optionalRefinementExpanded) { _, isExpanded in
                            guard isExpanded else { return }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation(.easeInOut(duration: 0.42)) {
                                    scrollProxy.scrollTo("timeSection", anchor: .top)
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            },
            footer: {
                let progress = revealState.ctaVisible && keyboardHeight == 0 ? footerRevealProgress : 0
                Group {
                    if keyboardHeight > 0 {
                        Color.clear.frame(height: 0)
                    } else {
                        AtmosphericCTADock(
                            progress: progress,
                            lagOffset: parallaxShift(from: scrollOffset) * 0.06,
                            hitThreshold: 0.6
                        ) {
                            PrimaryButton(
                                title: "See my pattern",
                                action: onBeginReveal,
                                isDisabled: isBeginRevealDisabled,
                                icon: "sparkles",
                                fullWidth: true
                            )
                            .opacity(uiFadeOut ? 0 : 1)
                            .offset(y: uiFadeOut ? 16 : 0)
                        }
                    }
                }
            }
        )
        .onAppear(perform: onAppear)
    }

    private func parallaxShift(from scrollOffset: CGFloat) -> CGFloat {
        let limited = max(min(scrollOffset, 180), -220)
        return limited * 0.16
    }
}

private struct MergingOptionalRefinementSection<TimeSection: View, PlaceSection: View>: View {
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let timeSection: () -> TimeSection
    @ViewBuilder let placeSection: () -> PlaceSection

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: onToggle) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sharpen the lens")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text("Optional — add birth time or birthplace for a clearer read")
                            .font(ZD.Font.caption())
                            .foregroundStyle(ZD.Color.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent.opacity(0.72))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                        .fill(ZD.Color.card.opacity(0.16))
                        .overlay(
                            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                                .stroke(ZD.Color.border.opacity(0.08), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 18) {
                    timeSection()
                    placeSection()
                }
                .transition(.opacity.combined(with: .offset(y: 10)))
            }
        }
    }
}

private struct MergingConvergencePreview: View {
    let westernVisible: Bool
    let easternVisible: Bool
    let combinedVisible: Bool

    @State private var leftDrift = false
    @State private var rightDrift = false
    @State private var bridgeDrift = false
    @State private var magneticBreathe = false

    var body: some View {
        ZStack {
            StaticConvergenceBridge()
                .frame(width: 170, height: 92)
                .opacity(0.30)
                .offset(
                    x: bridgeDrift ? -2 : 2,
                    y: bridgeDrift ? 2 : -2
                )
                .scaleEffect(bridgeDrift ? 1.008 : 0.992)

            ConvergenceOrbPair(
                leftOffset: westernVisible ? (leftDrift ? -86 : -72) : -96,
                rightOffset: easternVisible ? (rightDrift ? 88 : 72) : 96,
                collisionProgress: combinedVisible ? 0.08 : 0.02,
                flashActive: false,
                suspendedPulse: magneticBreathe
            )
        }
        .frame(width: 280, height: 220)
        .opacity(combinedVisible ? 1 : 0.92)
        .scaleEffect(combinedVisible ? 1 : 0.96)
        .scaleEffect(x: magneticBreathe ? 1.01 : 0.985, y: magneticBreathe ? 0.995 : 1.01)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
                leftDrift = true
            }

            withAnimation(.easeInOut(duration: 5.6).repeatForever(autoreverses: true)) {
                rightDrift = true
            }

            withAnimation(.easeInOut(duration: 6.8).repeatForever(autoreverses: true)) {
                bridgeDrift = true
            }

            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                magneticBreathe = true
            }
        }
    }
}
