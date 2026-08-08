import SwiftUI

struct PremiumTileRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var isPremium: Bool = false
    var showPremiumBadge: Bool = true

    var body: some View {
        HStack(alignment: .center, spacing: ZD.Spacing.m) {
            iconView

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.7))
                .padding(.top, 6)
        }
        .padding(.horizontal, ZD.Spacing.l)
        .padding(.vertical, ZD.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isPremium
                            ? [
                                ZD.Color.cardAlt,
                                ZD.Color.card
                              ]
                            : [
                                ZD.Color.card,
                                ZD.Color.surface
                              ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(
                            isPremium
                                ? ZD.Color.premium.opacity(0.65)
                                : ZD.Color.border.opacity(0.5),
                            lineWidth: ZD.Stroke.thin
                        )
                )
        )
        .shadow(
            color: isPremium ? ZD.Color.glow : ZD.Color.shadow,
            radius: isPremium ? 16 : 12,
            x: 0,
            y: isPremium ? 8 : 6
        )
        .overlay(alignment: .topTrailing) {
            if isPremium && showPremiumBadge {
                premiumBadge
                    .padding(.top, 14)
                    .padding(.trailing, 44)
            }
        }
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                .fill(isPremium ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.cardAlt))
                .frame(width: 46, height: 46)
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                        .stroke(
                            isPremium
                                ? ZD.Color.accentSoft.opacity(0.45)
                                : ZD.Color.border.opacity(0.45),
                            lineWidth: ZD.Stroke.thin
                        )
                )

            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isPremium ? Color.black : ZD.Color.accent)
        }
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
}

#Preview("Premium Tile Row") {
    VStack(spacing: ZD.Spacing.l) {
        PremiumTileRow(
            title: "Pattern Archive",
            subtitle: "Revisit the Daily Lens entries you kept",
            icon: "archivebox.fill",
            isPremium: false
        )

        PremiumTileRow(
            title: "Archive Active",
            subtitle: "Saved reads kept in one place",
            icon: "archivebox.fill",
            isPremium: true
        )
    }
    .padding()
    .zScreenBackground()
    .preferredColorScheme(.dark)
}
