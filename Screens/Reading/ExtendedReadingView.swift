import SwiftUI

struct ExtendedReadingView: View {
    let reading: DailyReading
    let archetype: Archetype

    @State private var goldShimmer = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                header

                sectionCard(
                    title: "Insight",
                    content: reading.insight,
                    icon: "sparkles",
                    tint: ZD.Color.accent
                )

                sectionCard(
                    title: "Focus",
                    content: reading.focus,
                    icon: "briefcase.fill",
                    tint: ZD.Color.accent
                )

                sectionCard(
                    title: "Caution",
                    content: reading.caution,
                    icon: "exclamationmark.triangle.fill",
                    tint: ZD.Color.warning
                )

                sectionCard(
                    title: "Anchor",
                    content: reading.affirmation,
                    icon: "heart.fill",
                    tint: ZD.Color.error.opacity(0.9)
                )

                closingCard
            }
            .padding(.top, 12)
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.bottom, 24)
        }
        .background(
            ZD.Color.bg
                .overlay(
                    RadialGradient(
                        colors: [
                            ZD.Color.card.opacity(0.16),
                            .clear
                        ],
                        center: .top,
                        startRadius: 10,
                        endRadius: 500
                    )
                )
                .ignoresSafeArea()
        )
        .navigationTitle("Reading")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            goldShimmer = false
            withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                goldShimmer = true
            }
        }
    }

    // MARK: - Hero

    private var header: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Reading")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.muted)

                shimmeringGoldTitle(
                    archetype.title,
                    font: .system(size: 28, weight: .medium, design: .serif),
                    shimmerActive: goldShimmer,
                    baseOpacity: 0.16
                )
                .lineLimit(2)
                .minimumScaleFactor(0.82)

                Text(reading.identity)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(reading.insight)
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
                            ZD.Color.accent.opacity(0.7),
                            ZD.Color.accent.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Section Card

    private func sectionCard(
        title: String,
        content: String,
        icon: String,
        tint: Color
    ) -> some View {
        TarotCardContainer {
            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 52, alignment: .center)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title.uppercased())
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(tint)

                    Text(content)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .stroke(
                    tint.opacity(0.15),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Closing Card

    private var closingCard: some View {
        TarotCardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("Closing Note")
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(closingText)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .stroke(
                    ZD.Color.accent.opacity(0.25),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Derived

    private var closingText: String {
        "Everything points back to \(reading.identity.lowercased()). Move cleanly. Don't force it."
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
}
