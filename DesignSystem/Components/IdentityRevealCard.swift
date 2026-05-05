import SwiftUI
import UIKit

struct IdentityRevealCardView: View {
    let content: ZodiacIdentityContent
    var includeBrandFooter: Bool = false

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

                ZStack {
                    Text(content.title)
                        .font(ZD.Font.display())
                        .foregroundStyle(ZD.Color.accent.opacity(0.24))
                        .blur(radius: 20)

                    Text(content.title)
                        .font(ZD.Font.display())
                        .foregroundStyle(cardGoldStroke)
                        .multilineTextAlignment(.center)
                }

                Text(content.tagline)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.85))
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    Text(content.revealPrimaryBody)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)

                if includeBrandFooter {
                    Text("ZODIAN ✦ The pattern is yours")
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

    private var revealCardOrnaments: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

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
                    .position(x: width - 60, y: 70)

                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .scaleEffect(x: 1, y: -1)
                    .position(x: 60, y: height - 70)

                Image("cornerOrnament")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .scaleEffect(x: -1, y: -1)
                    .position(x: width - 60, y: height - 70)

                Image("bottomMedallion")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .position(x: width / 2, y: height - 22)
            }
        }
        .allowsHitTesting(false)
    }
}

extension IdentityRevealCardView {
    init(entry: IdentityProfileEntry, includeBrandFooter: Bool = false) {
        self.init(
            content: IdentityProfileFormatter.revealCardContentModel(from: entry),
            includeBrandFooter: includeBrandFooter
        )
    }
}

enum IdentityRevealShareRenderer {
    static func renderImage(for content: ZodiacIdentityContent) -> UIImage? {
        let shareCardSize = CGSize(width: 354, height: 560)

        let shareView = ZStack {
            ZD.Color.bg

            IdentityRevealCardView(
                content: content,
                includeBrandFooter: false
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
        return renderer.uiImage
    }
}
