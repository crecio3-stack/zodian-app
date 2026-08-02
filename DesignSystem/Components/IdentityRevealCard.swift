import SwiftUI
import UIKit

struct IdentityRevealCardView: View {
    let content: IdentityCardContent
    var includeBrandFooter: Bool = false
    var animatesIdentityTitle: Bool = true
    @State private var identityTitleShimmer = false

    var body: some View {
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
                            Color.white.opacity(0.12),
                            ZD.Color.accent.opacity(0.14),
                            Color.clear,
                            ZD.Color.accent.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .padding(8)

            revealCardAtmosphere

            VStack(spacing: 15) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(cardGoldStroke)
                    .shadow(color: ZD.Color.accent.opacity(0.24), radius: 12, y: 0)

                Text(content.signCombination)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.9))
                    .tracking(1.9)
                    .multilineTextAlignment(.center)

                shimmeringIdentityTitle(content.identityName)

                if !content.descriptor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(content.descriptor)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !content.patternSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(content.patternSummary)
                        .font(ZD.Font.body(.medium))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }

                if includeBrandFooter {
                    Text("YOUR IDENTITY REVEALED")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(2.4)
                        .foregroundStyle(ZD.Color.accentSoft.opacity(0.66))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 30)
        }
        .onAppear {
            guard animatesIdentityTitle else { return }
            identityTitleShimmer = false
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                    identityTitleShimmer = true
                }
            }
        }
        .onDisappear {
            identityTitleShimmer = false
        }
    }

    private func shimmeringIdentityTitle(_ text: String) -> some View {
        ZStack {
            titleText(text)
                .foregroundStyle(ZD.Color.accent.opacity(0.24))
                .blur(radius: 20)

            titleText(text)
                .foregroundStyle(cardGoldStroke)
                .overlay(
                    Group {
                        if animatesIdentityTitle {
                            titleShimmerBand
                                .mask(titleText(text))
                        }
                    }
                    .allowsHitTesting(false)
                )
        }
        .compositingGroup()
    }

    private var titleShimmerBand: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.05),
                            ZD.Color.accent.opacity(0.34),
                            Color.white.opacity(0.82),
                            ZD.Color.accent.opacity(0.38),
                            Color.white.opacity(0.06),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 92, height: max(proxy.size.height + 18, 44))
                .rotationEffect(.degrees(11))
                .offset(x: identityTitleShimmer ? proxy.size.width + 110 : -110)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .blendMode(.screen)
        }
        .drawingGroup()
    }

    private func titleText(_ text: String) -> some View {
        Text(text.replacingOccurrences(of: "The ", with: "The\u{00A0}", options: [.anchored, .caseInsensitive]))
            .font(ZD.Font.display())
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.72)
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

    private var revealCardAtmosphere: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.075))
                    .frame(width: min(width, height) * 0.58, height: min(width, height) * 0.58)
                    .blur(radius: 28)
                    .position(x: width * 0.72, y: height * 0.26)

                Circle()
                    .stroke(ZD.Color.accent.opacity(0.11), lineWidth: 1)
                    .frame(width: min(width, height) * 0.90, height: min(width, height) * 0.90)
                    .position(x: width * 0.24, y: height * 0.68)

                Ellipse()
                    .stroke(Color.white.opacity(0.055), lineWidth: 1)
                    .frame(width: width * 1.10, height: height * 0.62)
                    .rotationEffect(.degrees(-10))
                    .position(x: width / 2, y: height * 0.52)

                Ellipse()
                    .stroke(ZD.Color.accent.opacity(0.07), style: StrokeStyle(lineWidth: 1, dash: [6, 10]))
                    .frame(width: width * 0.78, height: height * 0.46)
                    .rotationEffect(.degrees(16))
                    .position(x: width * 0.54, y: height * 0.52)

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                ZD.Color.accent.opacity(0.42),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 108, height: 1)
                    .position(x: width / 2, y: height - 28)
            }
        }
        .allowsHitTesting(false)
    }

}

enum IdentityRevealShareRenderer {
    static func renderImage(for content: IdentityCardContent) -> UIImage? {
        let cardWidth: CGFloat = 360
        let shareView = IdentityRevealCardView(content: content, animatesIdentityTitle: false)
            .frame(width: cardWidth)
            .fixedSize(horizontal: false, vertical: true)
            .padding(24)
            .background(ZD.Color.bg)

        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

#if DEBUG
#Preview("Canonical identity card") {
    ZStack {
        ZD.Color.bg.ignoresSafeArea()

        IdentityRevealCardView(
            content: IdentityCardContent(
                id: "libra-snake",
                signCombination: "Libra × Snake",
                identityName: "The Velvet Dagger",
                descriptor: "Warm face, private center",
                patternSummary: "You want closeness to feel balanced, and you notice imbalance early."
            )
        )
        .padding(20)
    }
    .preferredColorScheme(.dark)
}

#Preview("Long canonical identity card") {
    ZStack {
        ZD.Color.bg.ignoresSafeArea()

        IdentityRevealCardView(
            content: IdentityCardContent(
                id: "long-preview",
                signCombination: "Sagittarius × Rooster",
                identityName: "The Uncompromising Horizon Keeper",
                descriptor: "Expansive vision, exacting private standards",
                patternSummary: "You move toward possibility while tracking every detail that could weaken it, creating a pattern that needs both freedom and precision before it fully trusts the direction."
            )
        )
        .padding(20)
    }
    .preferredColorScheme(.dark)
}
#endif
