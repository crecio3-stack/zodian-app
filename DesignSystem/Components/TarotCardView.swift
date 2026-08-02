import SwiftUI

enum TarotCardStyle {
    case standard
    case featured
}

struct TarotCardContainer<Content: View>: View {
    let style: TarotCardStyle
    let content: Content

    init(
        style: TarotCardStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        ZStack {
            cardBackground

            if style == .featured {
                featuredOrnaments
            }

            content
                .padding(ZD.Spacing.l)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                .stroke(borderColor, lineWidth: ZD.Stroke.thin)
        )
        .shadow(color: ZD.Color.shadow.opacity(style == .featured ? 1.0 : 0.7), radius: style == .featured ? 20 : 14, x: 0, y: style == .featured ? 10 : 8)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
            .fill(ZD.Gradient.card)
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(style == .featured ? 0.03 : 0.015),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var borderColor: Color {
        style == .featured
        ? ZD.Color.accent.opacity(0.26)
        : ZD.Color.border.opacity(0.22)
    }

    private var featuredOrnaments: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                ornament
                    .position(x: 22, y: 22)

                ornament
                    .position(x: width - 22, y: 22)

                ornament
                    .position(x: 22, y: height - 22)

                ornament
                    .position(x: width - 22, y: height - 22)

                Circle()
                    .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                    .frame(width: 14, height: 14)
                    .position(x: width / 2, y: height - 12)
            }
        }
        .allowsHitTesting(false)
    }

    private var ornament: some View {
        ZStack {
            Circle()
                .stroke(ZD.Color.accent.opacity(0.20), lineWidth: 1)
                .frame(width: 18, height: 18)

            Image(systemName: "sparkle")
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(ZD.Color.accent.opacity(0.75))
        }
    }
}
