import SwiftUI
import SwiftData
import UIKit

struct OnboardingFlowView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    @StateObject private var vm = OnboardingFlowViewModel()

    @State private var didRunEntrance = false

    @State private var step: Step = .form
    @State private var revealScale: CGFloat = 0.92
    @State private var revealOpacity: Double = 0.0
    @State private var revealGlow = false

    @State private var loadingMessageIndex = 0
    @State private var loadingMessageOpacity: Double = 1.0

    @State private var ritualGlow = false
    @State private var ritualBandPulse = false
    @State private var lastBirthdaySelection = Date.distantPast

    @State private var headerVisible = true
    @State private var cardVisible = true
    @State private var heroScrollOffset: CGFloat = 0
    @State private var titleShimmer = false

    @State private var introLine1Visible = true
    @State private var introLine2Visible = true
    
    @State private var revealBackdropVisible = false
    @State private var revealHeaderVisible = false
    @State private var revealComboVisible = false
    @State private var revealTitleVisible = false
    @State private var revealTaglineVisible = false
    @State private var revealOverviewVisible = false
    @State private var revealButtonVisible = false
    @State private var revealFlash = false
    @State private var revealCardLift: CGFloat = 28
    @State private var sharePayload: SharePayload?

    @State private var logoGlow = false

    private let revealDelay: Double = 5.0

    private let loadingMessages = [
        "Tracing cosmic signature...",
        "Aligning East & West...",
        "Your archetype revealed..."
    ]

    enum Step {
        case form
        case calculating
        case reveal
    }

    var body: some View {
        ZStack {
            backgroundLayer

            switch step {
            case .form:
                formView
                    .transition(.opacity)

            case .calculating:
                calculatingView
                    .transition(.opacity)
                    .onDisappear {
                        vm.isLoading = false
                    }

            case .reveal:
                revealView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
        .preferredColorScheme(.dark)
        .onAppear {
            lastBirthdaySelection = vm.birthday
            startRitualAmbientAnimation()
            runEntranceAnimations()
        }
        .onChange(of: vm.birthday) { newValue in
            guard !Calendar.current.isDate(newValue, inSameDayAs: lastBirthdaySelection) else { return }
            lastBirthdaySelection = newValue
            feedbackRitualTick()
            pulseRitualBand()
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(activityItems: payload.activityItems)
        }
    }

    // MARK: - Entrance

    private func runEntranceAnimations() {
        guard !didRunEntrance else { return }
        didRunEntrance = true

        headerVisible = false
        titleShimmer = false
        cardVisible = false
        introLine1Visible = false
        introLine2Visible = false

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.55)) {
                headerVisible = true
            }

            withAnimation(.spring(response: 0.72, dampingFraction: 0.84).delay(0.10)) {
                cardVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.5)) {
                    introLine1Visible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    introLine2Visible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                    titleShimmer = true
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZD.Color.bg
            .overlay(
                LinearGradient(
                    colors: [
                        ZD.Color.forest.opacity(0.22),
                        .clear,
                        ZD.Color.card.opacity(0.12)
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
                    startRadius: 10,
                    endRadius: 460
                )
            )
            .ignoresSafeArea()
    }

    // MARK: - Form

    private var formView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: ZD.Spacing.m) {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: HeroScrollOffsetKey.self,
                                value: proxy.frame(in: .named("onboardingScroll")).minY
                            )
                    }
                    .frame(height: 0)

                    heroSection

                    onboardingCard

                    footerPrivacyNote

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.top, -10)
                .padding(.bottom, 20)
            }
            .coordinateSpace(name: "onboardingScroll")
            .onPreferenceChange(HeroScrollOffsetKey.self) { value in
                heroScrollOffset = value
            }

            bottomRevealBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var heroLogo: some View {
        ZStack {
            Image("zodianMark")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .blur(radius: logoGlow ? 18 : 10)
                .opacity(logoGlow ? 0.22 : 0.10)

            Image("zodianMark")
                .resizable()
                .scaledToFit()
                .frame(width: 82, height: 82)
                .scaleEffect(logoGlow ? 1.02 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                logoGlow = true
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 2) {
            heroLogo
                .offset(y: max(min(-heroScrollOffset * 0.12, 10), -10))
                .shadow(color: ZD.Color.accent.opacity(0.18), radius: 18, y: 0)

            VStack(spacing: 2) {
                ZStack {
                    Text("Welcome to Zodian")
                        .font(ZD.Font.display())
                        .foregroundStyle(ZD.Color.accent.opacity(ritualGlow ? 0.16 : 0.08))
                        .blur(radius: ritualGlow ? 14 : 8)

                    Text("Welcome to Zodian")
                        .font(ZD.Font.display())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("Welcome to Zodian")
                        .font(ZD.Font.display())
                        .foregroundStyle(.clear)
                        .overlay(
                            GeometryReader { proxy in
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                Color.white.opacity(0.05),
                                                Color.white.opacity(0.22),
                                                Color.white.opacity(0.95),
                                                ZD.Color.accent.opacity(0.70),
                                                Color.white.opacity(0.95),
                                                Color.white.opacity(0.22),
                                                Color.white.opacity(0.05),
                                                .clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 160, height: proxy.size.height + 14)
                                    .rotationEffect(.degrees(12))
                                    .offset(x: titleShimmer ? proxy.size.width + 180 : -180)
                            }
                        )
                        .mask(
                            Text("Welcome to Zodian")
                                .font(ZD.Font.display())
                        )
                        .allowsHitTesting(false)
                }
                .fixedSize()
                .compositingGroup()
                .multilineTextAlignment(.center)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 10)

                VStack(spacing: 8) {
                    Text("Two cosmic halves shape who you are.")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted.opacity(0.90))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                        .opacity(introLine1Visible ? 1 : 0)
                        .offset(y: introLine1Visible ? 0 : 14)

                    Text("Together, they reveal your complete self.")
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted.opacity(0.84))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                        .opacity(introLine2Visible ? 1 : 0)
                        .offset(y: introLine2Visible ? 0 : 14)
                }
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
        .animation(.easeOut(duration: 0.55), value: headerVisible)
    }

    private var onboardingCard: some View {
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
                .shadow(color: ZD.Color.accent.opacity(0.10), radius: 24, y: 10)

            VStack(alignment: .leading, spacing: ZD.Spacing.s) {
                HStack(spacing: 8) {
                    Image(systemName: "character.textbox.badge.sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)

                    Text("First Half")
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                }

                Text("Enter your name to begin.")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: ZD.Spacing.m) {
                    TextField("Name", text: $vm.name)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                                .fill(ZD.Color.cardAlt)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                                        .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                                )
                        )
                        .foregroundStyle(ZD.Color.textPrimary)

                    ritualDivider

                    ritualBirthdaySelector
                }
            }
            .padding(ZD.Spacing.l)
        }
        .frame(maxWidth: 350)
        .frame(maxWidth: .infinity)
        .opacity(cardVisible ? 1 : 0)
        .offset(y: cardVisible ? 0 : 24)
        .scaleEffect(cardVisible ? 1 : 0.985)
        .animation(.spring(response: 0.72, dampingFraction: 0.84).delay(0.10), value: cardVisible)
    }

    private var ritualDivider: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(ZD.Color.border.opacity(0.35))
                    .frame(height: 1)

                Image(systemName: "moonphase.waxing.crescent")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ZD.Color.accent.opacity(0.9))

                Rectangle()
                    .fill(ZD.Color.border.opacity(0.35))
                    .frame(height: 1)
            }
        }
        .padding(.vertical, 4)
    }

    private var ritualBirthdaySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text("Second Half")
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
            }

            Text("Choose the day your story began.")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)

            ZStack {
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(ZD.Color.cardAlt)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.28), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ZD.Color.accent.opacity(ritualBandPulse ? 0.16 : 0.08))
                    .frame(height: 42)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                ZD.Color.accent.opacity(ritualBandPulse ? 0.28 : 0.16),
                                lineWidth: 1
                            )
                            .padding(.horizontal, 10)
                    )
                    .scaleEffect(ritualBandPulse ? 1.015 : 1.0)
                    .shadow(
                        color: ZD.Color.accent.opacity(ritualBandPulse ? 0.16 : 0.08),
                        radius: ritualBandPulse ? 12 : 6,
                        y: 0
                    )

                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ZD.Color.accent.opacity(ritualGlow ? 0.05 : 0.02),
                                .clear,
                                ZD.Color.forest.opacity(ritualGlow ? 0.05 : 0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            ZD.Color.cardAlt.opacity(0.92),
                            ZD.Color.cardAlt.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 26)

                    Spacer()

                    LinearGradient(
                        colors: [
                            ZD.Color.cardAlt.opacity(0.0),
                            ZD.Color.cardAlt.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 26)
                }
                .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                .allowsHitTesting(false)

                DatePicker(
                    "",
                    selection: $vm.birthday,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "en_US"))
                .tint(ZD.Color.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 142)
                .clipped()
                .padding(.horizontal, 4)
                .colorScheme(.dark)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 142)
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
            .shadow(color: ZD.Color.accent.opacity(0.08), radius: 10, y: 4)
        }
    }

    private var footerPrivacyNote: some View {
        VStack(spacing: 4) {
            Text("Private by design")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)

            Text("Your details stay local while you explore your identity.")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var bottomRevealBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.bg.opacity(0.0),
                            ZD.Color.bg.opacity(0.88),
                            ZD.Color.bg
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 18)
                .allowsHitTesting(false)

            VStack(spacing: 8) {
                PrimaryButton(
                    title: "Reveal Your Complete Self",
                    action: beginReveal,
                    isDisabled: !vm.canContinue,
                    icon: "sparkles",
                    fullWidth: true
                )
            }
            .padding(.horizontal, ZD.Spacing.l)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(
                ZD.Color.bg
                    .overlay(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.08),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
    }

    // MARK: - Calculating

    private var calculatingView: some View {
        VStack(spacing: ZD.Spacing.l) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(ZD.Color.accent.opacity(0.14), lineWidth: 1)
                    .frame(width: 128, height: 128)

                Circle()
                    .trim(from: 0.08, to: 0.84)
                    .stroke(
                        ZD.Gradient.gold,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 108, height: 108)
                    .rotationEffect(.degrees(vm.isLoading ? 360 : 0))
                    .animation(
                        .linear(duration: 1.35).repeatForever(autoreverses: false),
                        value: vm.isLoading
                    )

                ZStack {
                    Image("zodianMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .blur(radius: 12)
                        .opacity(0.16)

                    Image("zodianMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 54)
                }
            }
            .zGoldGlow(active: true)

            VStack(spacing: 10) {
                Text(loadingMessages[loadingMessageIndex])
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(loadingMessageOpacity)
                    .animation(.easeInOut(duration: 0.35), value: loadingMessageOpacity)
                    .id(loadingMessageIndex)

                Text("Hold steady while your two halves resolve into one archetype.")
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ZD.Spacing.l)
            }

            Spacer()
        }
        .onAppear {
            vm.isLoading = true
            loadingMessageIndex = 0
            loadingMessageOpacity = 1.0
            cycleLoadingMessages()
        }
    }

    // MARK: - Reveal

    private var revealView: some View {
        ZStack {
            backgroundLayer

            // cinematic spotlight / atmosphere
            RadialGradient(
                colors: [
                    ZD.Color.accent.opacity(revealBackdropVisible ? 0.20 : 0.0),
                    ZD.Color.accent.opacity(revealBackdropVisible ? 0.08 : 0.0),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()
            .blur(radius: 10)
            .opacity(revealBackdropVisible ? 1 : 0)

            // reveal flash
            Color.white
                .opacity(revealFlash ? 0.08 : 0.0)
                .ignoresSafeArea()
                .blendMode(.screen)

            VStack(spacing: 22) {
                Spacer(minLength: 20)

                if let content = vm.identityContent {
                    VStack(spacing: 14) {
                        ZStack {
                            Text("Your Cosmic Identity")
                                .font(ZD.Font.body(.semibold))
                                .tracking(0.4)
                                .foregroundStyle(ZD.Color.textSecondary.opacity(0.88))
                                .multilineTextAlignment(.center)

                            HStack {
                                Spacer()

                                Button {
                                    shareIdentityCard(content, source: "onboarding_reveal_header")
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(ZD.Color.textPrimary)
                                        .frame(width: 38, height: 38)
                                        .background(
                                            Circle()
                                                .fill(ZD.Color.card.opacity(0.92))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(ZD.Color.border.opacity(0.55), lineWidth: ZD.Stroke.thin)
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Share your identity")
                                .disabled(!revealButtonVisible)
                                .opacity(revealButtonVisible ? 1 : 0.6)
                            }
                        }
                        .padding(.horizontal, ZD.Spacing.l)
                        .opacity(revealHeaderVisible ? 1 : 0)
                        .offset(y: revealHeaderVisible ? 0 : 14)

                        revealIdentityCard(
                            content: content,
                            includeBrandFooter: false,
                            forceVisible: false
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 560)
                        .padding(.horizontal, ZD.Spacing.l)
                        .scaleEffect(revealGlow ? 1.0 : 0.94)
                        .offset(y: revealCardLift)
                        .opacity(revealBackdropVisible ? 1 : 0)
                        .zGoldGlow(active: revealGlow)

                        PrimaryButton(
                            title: "Step Into Your Identity",
                            action: {
                                feedbackSuccess()
                                vm.completeOnboarding(store: store, context: context)
                            },
                            isDisabled: false,
                            icon: "arrow.right",
                            fullWidth: true
                        )
                        .padding(.horizontal, ZD.Spacing.l)
                        .opacity(revealButtonVisible ? 1 : 0)
                        .offset(y: revealButtonVisible ? 0 : 14)
                        .scaleEffect(revealButtonVisible ? 1.0 : 0.96)

                        SecondaryButton(
                            title: "Share Your Identity ✦",
                            action: {
                                shareIdentityCard(content, source: "onboarding_reveal_cta")
                            },
                            icon: "square.and.arrow.up",
                            fullWidth: true
                        )
                        .padding(.horizontal, ZD.Spacing.l)
                        .opacity(revealButtonVisible ? 1 : 0)
                        .offset(y: revealButtonVisible ? 0 : 14)
                        .scaleEffect(revealButtonVisible ? 1.0 : 0.96)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            revealScale = 0.94
            revealOpacity = 0.0
            revealGlow = false

            revealBackdropVisible = false
            revealHeaderVisible = false
            revealComboVisible = false
            revealTitleVisible = false
            revealTaglineVisible = false
            revealOverviewVisible = false
            revealButtonVisible = false
            revealFlash = false
            revealCardLift = 18

            // initial atmosphere
            withAnimation(.easeOut(duration: 0.45)) {
                revealBackdropVisible = true
            }

            // little flash + haptic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                feedbackSuccess()
                revealFlash = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    withAnimation(.easeOut(duration: 0.22)) {
                        revealFlash = false
                    }
                }
            }

            // card settles in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.72, dampingFraction: 0.82)) {
                    revealCardLift = 0
                    revealGlow = true
                }
            }

            // staggered cinematic sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeOut(duration: 0.42)) {
                    revealHeaderVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
                withAnimation(.spring(response: 0.50, dampingFraction: 0.78)) {
                    revealComboVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.74) {
                withAnimation(.spring(response: 0.58, dampingFraction: 0.74)) {
                    revealTitleVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                withAnimation(.easeOut(duration: 0.40)) {
                    revealTaglineVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.30) {
                withAnimation(.easeOut(duration: 0.48)) {
                    revealOverviewVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.58) {
                withAnimation(.spring(response: 0.46, dampingFraction: 0.80)) {
                    revealButtonVisible = true
                }
            }
        }
    }

    @ViewBuilder
    private func revealIdentityCard(
        content: ZodiacIdentityContent,
        includeBrandFooter: Bool,
        forceVisible: Bool
    ) -> some View {
        let comboVisible = forceVisible || revealComboVisible
        let titleVisible = forceVisible || revealTitleVisible
        let taglineVisible = forceVisible || revealTaglineVisible
        let overviewVisible = forceVisible || revealOverviewVisible

        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.98),
                            ZD.Color.cardAlt.opacity(0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(cardGoldStroke, lineWidth: 1.15)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            ZD.Color.accent.opacity(0.10),
                            Color.clear,
                            ZD.Color.accent.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .padding(8)

            revealCardOrnaments

            VStack(spacing: 14) {
                Text("\(content.westernSign.capitalized) × \(content.chineseSign.capitalized)")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.95))
                    .tracking(2.2)
                    .multilineTextAlignment(.center)
                    .opacity(comboVisible ? 1 : 0)
                    .scaleEffect(comboVisible ? 1.0 : 0.92)
                    .offset(y: comboVisible ? 0 : 10)

                ZStack {
                    Text(content.title)
                        .font(ZD.Font.display())
                        .foregroundStyle(ZD.Color.accent.opacity(titleVisible ? 0.24 : 0.0))
                        .blur(radius: 20)

                    Text(content.title)
                        .font(ZD.Font.display())
                        .foregroundStyle(cardGoldStroke)
                        .multilineTextAlignment(.center)
                        .scaleEffect(titleVisible ? 1.0 : 0.82)
                        .opacity(titleVisible ? 1 : 0)
                }

                Text(content.tagline)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .opacity(taglineVisible ? 1 : 0)
                    .offset(y: taglineVisible ? 0 : 8)

                Text(content.identitySummary)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                    .opacity(overviewVisible ? 1 : 0)
                    .offset(y: overviewVisible ? 0 : 10)

                if includeBrandFooter {
                    Text("ZODIAN ✦ Discover your cosmic identity")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.72))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
        }
    }

    private func shareIdentityCard(_ content: ZodiacIdentityContent, source: String) {
        let shareCardSize = CGSize(width: 354, height: 560)

        let shareView = ZStack {
            ZD.Color.bg

            revealIdentityCard(
                content: content,
                includeBrandFooter: false,
                forceVisible: true
            )
            .frame(width: shareCardSize.width, height: shareCardSize.height)
            .zGoldGlow(active: true)
        }
        .frame(
            width: shareCardSize.width + 28,
            height: shareCardSize.height + 28
        )

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0

        guard let image = renderer.uiImage else { return }

        let shareText = """
        I just unlocked my cosmic identity on Zodian:

        "\(content.title)"

        Kind of scary how accurate this is. You have to try, I need to know yours!
        """

        sharePayload = SharePayload(activityItems: [shareText, image])
        AnalyticsService.shared.track(
            .identitySharePresented(
                identityID: content.id,
                title: content.title,
                source: source
            )
        )
    }

    private struct SharePayload: Identifiable {
        let id = UUID()
        let activityItems: [Any]
    }

    private var cardGoldStroke: LinearGradient {
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

   
    private struct HeroScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    private var revealCardOrnaments: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .position(x: 60, y: 70)

                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: w - 60, y: 70)

                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .scaleEffect(x: 1, y: -1)
                    .position(x: 60, y: h - 70)

                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .scaleEffect(x: -1, y: -1)
                    .position(x: w - 60, y: h - 70)

                Image("bottomMedallion")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .position(x: w / 2, y: h - 22)
            }
        }
        .allowsHitTesting(false)
    }
    // MARK: - Actions

    private func beginReveal() {
        feedbackSoft()
        vm.prepareReveal()
        vm.isLoading = true
        loadingMessageIndex = 0
        loadingMessageOpacity = 1.0

        withAnimation {
            step = .calculating
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
            vm.isLoading = false
            withAnimation {
                step = .reveal
            }
        }
    }

    private func cycleLoadingMessages() {
        let stepDuration = revealDelay / Double(loadingMessages.count)

        guard loadingMessages.count > 1 else { return }

        for index in 1..<loadingMessages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (stepDuration * Double(index))) {
                guard step == .calculating else { return }

                withAnimation(.easeInOut(duration: 0.25)) {
                    loadingMessageOpacity = 0.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    guard step == .calculating else { return }
                    loadingMessageIndex = index

                    withAnimation(.easeInOut(duration: 0.3)) {
                        loadingMessageOpacity = 1.0
                    }
                }
            }
        }
    }

    private func startRitualAmbientAnimation() {
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            ritualGlow = true
        }
    }

    private func pulseRitualBand() {
        ritualBandPulse = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.28)) {
                ritualBandPulse = false
            }
        }
    }

    private func feedbackSoft() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    private func feedbackSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func feedbackRitualTick() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
