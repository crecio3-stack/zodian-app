import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var isDisabled: Bool = false
    var icon: String? = nil
    var fullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: ZD.Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }

                Text(title)
                    .font(ZD.Font.button())
                    .tracking(0.3)
            }
            .foregroundStyle(isDisabled ? ZD.Color.disabled : Color.black)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.vertical, ZD.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .fill(isDisabled ? AnyShapeStyle(ZD.Color.disabled.opacity(0.18)) : AnyShapeStyle(ZD.Gradient.gold))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .stroke(
                        isDisabled ? ZD.Color.border.opacity(0.25) : ZD.Color.accentSoft.opacity(0.45),
                        lineWidth: ZD.Stroke.thin
                    )
            )
            .shadow(
                color: isDisabled ? .clear : ZD.Color.glow,
                radius: isDisabled ? 0 : 14,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.72 : 1.0)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var isDisabled: Bool = false
    var icon: String? = nil
    var fullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: ZD.Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }

                Text(title)
                    .font(ZD.Font.button())
                    .tracking(0.3)
            }
            .foregroundStyle(isDisabled ? ZD.Color.disabled : ZD.Color.textPrimary)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.vertical, ZD.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .fill(ZD.Color.card.opacity(isDisabled ? 0.55 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .stroke(
                        isDisabled ? ZD.Color.border.opacity(0.20) : ZD.Color.border.opacity(0.65),
                        lineWidth: ZD.Stroke.thin
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.72 : 1.0)
    }
}

struct TextOnlyButton: View {
    let title: String
    let action: () -> Void

    var icon: String? = nil
    var tint: Color = ZD.Color.accent

    var body: some View {
        Button(action: action) {
            HStack(spacing: ZD.Spacing.xs) {
                Text(title)
                    .font(ZD.Font.body(.semibold))

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }
}

struct IconCircleButton: View {
    let systemName: String
    let action: () -> Void

    var size: CGFloat = 44
    var isHighlighted: Bool = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isHighlighted ? Color.black : ZD.Color.textPrimary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isHighlighted ? AnyShapeStyle(ZD.Gradient.gold) : AnyShapeStyle(ZD.Color.card))
                )
                .overlay(
                    Circle()
                        .stroke(
                            isHighlighted ? ZD.Color.accentSoft.opacity(0.4) : ZD.Color.border.opacity(0.55),
                            lineWidth: ZD.Stroke.thin
                        )
                )
                .shadow(
                    color: isHighlighted ? ZD.Color.glow : .clear,
                    radius: isHighlighted ? 12 : 0,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(.plain)
    }
}
