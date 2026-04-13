import SwiftUI

struct BlueprintView: View {
    @EnvironmentObject private var store: AppStore

    @State private var heroTitleShimmer = false
    @State private var premiumLockVisible = false
    @State private var premiumLockGlow = false
    @State private var showPremiumSheet = false
    @State private var resolvedIdentityContent: ZodiacIdentityContent?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    heroSection
                    corePatternSection
                    strengthsAndShadowsSection
                    deeperLayersSection
                    evolutionPathSection
                    compatibilitySection
                    hiddenInsightSection
                    premiumPromptIfNeeded
                }
                .padding(.top, 12)
                .padding(.horizontal, ZD.Spacing.m)
                .padding(.bottom, 24)
            }
            .background(
                ZD.Color.bg
                    .overlay(
                        LinearGradient(
                            colors: [
                                ZD.Color.card.opacity(0.14),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RadialGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.06),
                                .clear
                            ],
                            center: .top,
                            startRadius: 10,
                            endRadius: 420
                        )
                    )
                    .ignoresSafeArea()
            )
            .navigationTitle("Blueprint")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPremiumSheet) {
                PremiumRewardsSheet(source: "blueprint")
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
            .onAppear {
                refreshIdentityContent()
                heroTitleShimmer = false
                withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                    heroTitleShimmer = true
                }

                guard !store.effectivePremiumAccess else { return }

                premiumLockVisible = false
                premiumLockGlow = false

                withAnimation(.easeOut(duration: 0.32)) {
                    premiumLockVisible = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    premiumLockGlow = true
                }
            }
            .onChange(of: identityLookupKey) { _, _ in
                refreshIdentityContent()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Your Blueprint",
                subtitle: "A deeper look at the identity beneath your surface"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentArchetype?.combinedName ?? currentCombinedSigns)
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textSecondary)

                        shimmeringGoldTitle(
                            zodiacIdentityContent?.title ?? "The Hidden Pattern",
                            font: ZD.Font.title(),
                            shimmerActive: heroTitleShimmer,
                            baseOpacity: 0.14
                        )
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)

                        Text(zodiacIdentityContent?.tagline ?? "A pattern still unfolding.")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 8) {
                        archetypePill(text: currentCombinedSigns, icon: "sparkles")
                        if store.effectivePremiumAccess {
                            premiumBadge
                        }
                    }

                    divider

                    Text(zodiacIdentityContent?.identitySummary ?? fallbackOverview)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.55),
                                ZD.Color.accent.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Core Pattern

    private var corePatternSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Core Pattern",
                subtitle: "Your emotional rhythm and energetic signature"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 14) {
                    infoRow(
                        label: "Core Energy",
                        value: zodiacIdentityContent?.coreEnergy ?? fallbackCoreEnergy,
                        icon: "heart.text.square.fill",
                        tint: ZD.Color.accent
                    )

                    divider

                    infoRow(
                        label: "Emotional Pattern",
                        value: zodiacIdentityContent?.emotionalPattern ?? fallbackEmotionalPattern,
                        icon: "person.2.fill",
                        tint: ZD.Color.accent
                    )
                }
            }
        }
    }

    // MARK: - Strengths & Shadows

    private var strengthsAndShadowsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Strengths & Shadows",
                subtitle: "What empowers you, and what asks to be refined"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 18) {
                    traitGroup(
                        title: "Strengths",
                        items: zodiacIdentityContent?.strengths ?? fallbackStrengths,
                        titleIcon: "sparkles",
                        titleTint: ZD.Color.success,
                        bulletTint: ZD.Color.success
                    )

                    divider

                    traitGroup(
                        title: "Growth Edges",
                        items: zodiacIdentityContent?.growthEdges ?? fallbackGrowthEdges,
                        titleIcon: "moon.fill",
                        titleTint: ZD.Color.warning,
                        bulletTint: ZD.Color.warning
                    )
                }
            }
        }
    }

    // MARK: - Deeper Layers

    private var deeperLayersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Deeper Layers",
                subtitle: "How your archetype moves through love, work, and growth"
            )

            ZStack {
                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        compatibilityBlock(
                            title: "Love Style",
                            content: zodiacIdentityContent?.loveStyle ?? fallbackLoveStyle,
                            icon: "heart.fill",
                            tint: ZD.Color.error.opacity(0.9)
                        )

                        divider

                        compatibilityBlock(
                            title: "Work Style",
                            content: zodiacIdentityContent?.workStyle ?? fallbackWorkStyle,
                            icon: "briefcase.fill",
                            tint: ZD.Color.accent
                        )

                        divider

                        compatibilityBlock(
                            title: "Mantra",
                            content: zodiacIdentityContent?.mantra ?? fallbackMantra,
                            icon: "sparkles",
                            tint: ZD.Color.success
                        )
                    }
                    .blur(radius: store.effectivePremiumAccess ? 0 : 5)
                    .opacity(store.effectivePremiumAccess ? 1 : 0.22)
                }

                if !store.effectivePremiumAccess {
                    premiumLockOverlay(
                        title: "Premium",
                        subtitle: "Unlock deeper love, work, and growth layers."
                    )
                }
            }
        }
    }

    // MARK: - Evolution Path

    private var evolutionPathSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Evolution Path",
                subtitle: "How your pattern matures with consistency"
            )

            ZStack {
                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        compatibilityBlock(
                            title: "Early Expression",
                            content: fallbackEarlyExpression,
                            icon: "circle.hexagongrid.fill",
                            tint: ZD.Color.accent
                        )

                        divider

                        compatibilityBlock(
                            title: "Mature Expression",
                            content: fallbackMatureExpression,
                            icon: "leaf.fill",
                            tint: ZD.Color.success
                        )

                        divider

                        compatibilityBlock(
                            title: "Shadow Loop",
                            content: fallbackShadowLoop,
                            icon: "moon.fill",
                            tint: ZD.Color.warning
                        )
                    }
                    .blur(radius: store.effectivePremiumAccess ? 0 : 5)
                    .opacity(store.effectivePremiumAccess ? 1 : 0.22)
                }

                if !store.effectivePremiumAccess {
                    premiumLockOverlay(
                        title: "Premium",
                        subtitle: "Unlock a deeper read on how your archetype evolves over time."
                    )
                }
            }
        }
    }

    // MARK: - Compatibility

    private var compatibilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Compatibility",
                subtitle: "Where your energy finds harmony or friction"
            )

            TarotCardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    compatibilityBlock(
                        title: "Harmony Energy",
                        content: currentArchetype?.compatibilityNotes ?? fallbackCompatibility,
                        icon: "sparkles",
                        tint: ZD.Color.accent
                    )

                    divider

                    compatibilityBlock(
                        title: "Friction Energy",
                        content: fallbackFriction,
                        icon: "flame.fill",
                        tint: ZD.Color.warning
                    )
                }
            }
        }
    }

    // MARK: - Hidden Insight

    private var hiddenInsightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Hidden Insight",
                subtitle: store.hasHiddenInsightUnlocked
                    ? "Unlocked through your 14-day streak"
                    : "Unlock at a 14-day streak"
            )

            ZStack {
                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What lives beneath the visible self")
                            .font(ZD.Font.heading())
                            .foregroundStyle(ZD.Color.textPrimary)

                        Text(currentArchetype?.hiddenInsight ?? fallbackHiddenInsight)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .blur(radius: store.hasHiddenInsightUnlocked ? 0 : 5)
                            .opacity(store.hasHiddenInsightUnlocked ? 1 : 0.20)
                    }
                }

                if !store.hasHiddenInsightUnlocked {
                    premiumLockOverlay(
                        title: "14-Day Unlock",
                        subtitle: "Keep your ritual going to reveal the quieter truth beneath your pattern."
                    )
                }
            }
        }
    }

    // MARK: - CTA

    private var premiumPromptIfNeeded: some View {
        Group {
            if !store.effectivePremiumAccess {
                Button {
                    showPremiumSheet = true
                } label: {
                    PremiumTileRow(
                        title: "Unlock Full Blueprint",
                        subtitle: "Open deeper archetype, evolution, and compatibility layers.",
                        icon: "crown.fill",
                        isPremium: false
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Components

    private func archetypePill(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)

            Text(text)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(ZD.Color.cardAlt)
                .overlay(
                    Capsule()
                        .stroke(ZD.Color.border.opacity(0.35), lineWidth: ZD.Stroke.thin)
                )
        )
    }

    private func infoRow(label: String, value: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 46)

            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(value)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func traitGroup(
        title: String,
        items: [String],
        titleIcon: String,
        titleTint: Color,
        bulletTint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(title)
                    .font(ZD.Font.title())
                    .foregroundStyle(ZD.Color.textPrimary)

                Spacer()

                Image(systemName: titleIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(titleTint.opacity(0.9))
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .center, spacing: 14) {
                        Circle()
                            .fill(bulletTint.opacity(0.9))
                            .frame(width: 10, height: 10)
                            .frame(width: 18)

                        Text(item)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func compatibilityBlock(title: String, content: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 46)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(content)
                    .font(ZD.Font.body())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func premiumLockOverlay(title: String, subtitle: String) -> some View {
        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
            .fill(Color.black.opacity(0.82))
            .overlay {
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .stroke(
                        ZD.Color.accent.opacity(premiumLockGlow ? 0.30 : 0.14),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: ZD.Color.accent.opacity(premiumLockGlow ? 0.22 : 0.08),
                radius: premiumLockGlow ? 18 : 8,
                x: 0,
                y: 0
            )
            .overlay(
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(ZD.Color.accent.opacity(premiumLockGlow ? 0.14 : 0.07))
                            .frame(width: 44, height: 44)
                            .scaleEffect(premiumLockGlow ? 1.06 : 0.94)
                            .blur(radius: premiumLockGlow ? 6 : 2)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(ZD.Color.accent)
                    }

                    Text(title)
                        .font(ZD.Font.heading())
                        .foregroundStyle(ZD.Color.accent)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                }
                .padding(20)
                .opacity(premiumLockVisible ? 1 : 0)
                .scaleEffect(premiumLockVisible ? 1 : 0.965)
            )
            .opacity(premiumLockVisible ? 1 : 0)
            .scaleEffect(premiumLockVisible ? 1 : 0.985)
            .animation(.easeOut(duration: 0.32), value: premiumLockVisible)
            .animation(
                .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                value: premiumLockGlow
            )
            .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous))
            .onTapGesture {
                showPremiumSheet = true
            }
    }

    private var divider: some View {
        Rectangle()
            .fill(ZD.Color.border.opacity(0.28))
            .frame(height: 1)
    }

    private var premiumBadge: some View {
        Text("PREMIUM")
            .font(ZD.Font.caption(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(ZD.Gradient.gold)
            )
    }

    // MARK: - Shared Gold Styling

    private func shimmeringGoldTitle(
        _ text: String,
        font: Font,
        shimmerActive: Bool,
        baseOpacity: Double = 0.18
    ) -> some View {
        ZStack {
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
                                        Color.white.opacity(0.04),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.95),
                                        ZD.Color.accent.opacity(0.72),
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.04),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 140, height: proxy.size.height + 12)
                            .rotationEffect(.degrees(12))
                            .offset(x: shimmerActive ? proxy.size.width + 160 : -160)
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

    // MARK: - Data

    private var currentArchetype: Archetype? {
        store.currentArchetype
    }

    private var zodiacIdentityContent: ZodiacIdentityContent? {
        resolvedIdentityContent
    }

    private var identityLookupKey: String {
        guard let user = store.currentUser else { return "no-user" }
        return "\(user.westernSignRaw)|\(user.chineseSignRaw)"
    }

    private var currentCombinedSigns: String {
        guard let user = store.currentUser else { return "—" }
        return "\(user.westernSign.displayName) • \(user.chineseSign.displayName)"
    }

    private var fallbackOverview: String {
        "Your identity blends two systems into something uniquely yours. As Zodian evolves, deeper insights will reveal your full archetype."
    }

    private var fallbackCoreEnergy: String {
        "A layered energy that blends instinct, perception, and self-invention."
    }

    private var fallbackEmotionalPattern: String {
        "You process experiences through multiple lenses, often seeking deeper meaning beneath the surface."
    }

    private var fallbackStrengths: [String] {
        ["Adaptable nature", "Layered personality", "Intuitive awareness"]
    }

    private var fallbackGrowthEdges: [String] {
        ["Unclear direction", "Internal conflict", "Overthinking identity"]
    }

    private var fallbackLoveStyle: String {
        "You are exploratory in love, seeking connection that feels both grounding and expansive."
    }

    private var fallbackWorkStyle: String {
        "You adapt quickly and thrive when your instinct can collaborate with structure."
    }

    private var fallbackMantra: String {
        "I trust the deeper pattern unfolding within me."
    }

    private var fallbackCompatibility: String {
        "You resonate with individuals who bring balance and clarity to your layered perspective."
    }

    private var fallbackFriction: String {
        "You may feel friction with chaotic, inconsistent, or emotionally evasive energy that disrupts your natural rhythm."
    }

    private var fallbackHiddenInsight: String {
        "Your deeper pattern may be teaching you how to trust your power without needing to harden or erase either side of your nature."
    }

    private var fallbackEarlyExpression: String {
        "At first, your pattern may appear subtle or even contradictory, but over time your inner structure can become clear."
    }

    private var fallbackMatureExpression: String {
        "As your archetype matures, you become more deeply embodied in your natural strengths and more intentional with your energy."
    }

    private var fallbackShadowLoop: String {
        "When under strain, you may overthink, withdraw, or mistake self-protection for self-trust."
    }

    private func refreshIdentityContent() {
        guard let user = store.currentUser else {
            resolvedIdentityContent = nil
            return
        }

        let content = ZodiacIdentityContentService.shared.safeContent(
            forWestern: user.westernSignRaw,
            chinese: user.chineseSignRaw
        )
        resolvedIdentityContent = content

#if DEBUG
        let usedFallback = content.id == "mystic-blend"
        print("[BlueprintView] westernSignRaw='\(user.westernSignRaw)' chineseSignRaw='\(user.chineseSignRaw)' resolved='\(content.id)' fallback=\(usedFallback)")
#endif
    }
}

#Preview("Blueprint - Free") {
    let store = AppStore()
    store.updatePremiumStatus(.free)
    store.currentUser = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 631152000),
        westernSignRaw: "leo",
        chineseSignRaw: "dragon",
        archetypeId: "leo-dragon"
    )

    return BlueprintView()
        .environmentObject(store)
        .preferredColorScheme(.dark)
}

#Preview("Blueprint - Premium") {
    let store = AppStore()
    store.updatePremiumStatus(.premium)
    store.currentUser = UserProfile(
        name: "Ari",
        birthday: Date(timeIntervalSince1970: 915177600),
        westernSignRaw: "aries",
        chineseSignRaw: "rabbit",
        archetypeId: "aries-rabbit"
    )

    return BlueprintView()
        .environmentObject(store)
        .preferredColorScheme(.dark)
}
