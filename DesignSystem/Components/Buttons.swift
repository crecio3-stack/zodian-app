import SwiftUI

/// The restrained metallic CTA treatment established by onboarding. A single slow sweep
/// keeps it feeling alive without turning a primary action into a continuous animation.
struct PremiumGoldShimmerButton: View {
    let title: String
    let action: () -> Void

    var icon: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmerActive = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: ZD.Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .tracking(0.4)
            }
            .foregroundStyle(Color.black.opacity(0.88))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(buttonBackground)
            .overlay(topSpecularHighlight)
            .overlay(innerGlowStroke)
            .overlay(edgeStroke)
            .overlay {
                if !reduceMotion { shimmer }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.28), radius: 16, y: 10)
            .shadow(color: ZD.Color.accent.opacity(0.12), radius: 20, y: 6)
        }
        .buttonStyle(.plain)
        .task(id: reduceMotion) {
            shimmerActive = false
            guard !reduceMotion else { return }
            try? await Task.sleep(for: .milliseconds(650))
            withAnimation(.easeInOut(duration: 2.2)) {
                shimmerActive = true
            }
        }
        .accessibilityAddTraits(.isButton)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.49, green: 0.35, blue: 0.09),
                        Color(red: 0.76, green: 0.60, blue: 0.21),
                        Color(red: 0.96, green: 0.87, blue: 0.63),
                        Color(red: 0.83, green: 0.66, blue: 0.27),
                        Color(red: 0.52, green: 0.38, blue: 0.10)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [Color.white.opacity(0.10), .clear, Color.black.opacity(0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
    }

    private var topSpecularHighlight: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.34), Color.white.opacity(0.10), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .blendMode(.screen)
    }

    private var innerGlowStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .inset(by: 1.2)
            .stroke(
                LinearGradient(
                    colors: [Color.white.opacity(0.20), .clear, Color.black.opacity(0.10)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
    }

    private var edgeStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.42),
                        Color(red: 0.96, green: 0.87, blue: 0.60).opacity(0.42),
                        Color(red: 0.38, green: 0.27, blue: 0.06).opacity(0.58)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.15
            )
    }

    private var shimmer: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.035),
                            Color.white.opacity(0.16),
                            Color.white.opacity(0.42),
                            Color.white.opacity(0.16),
                            Color.white.opacity(0.035),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 94, height: proxy.size.height + 12)
                .rotationEffect(.degrees(8))
                .offset(x: shimmerActive ? proxy.size.width + 130 : -130)
        }
        .mask(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

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

struct HoldToConfirmButton: View {
    let title: String
    let onComplete: () -> Void

    var icon: String? = nil
    var accent: AnyShapeStyle = AnyShapeStyle(ZD.Gradient.gold)
    var foreground: Color = .black
    var minDuration: Double = 0.7
    var fullWidth: Bool = true

    @GestureState private var isPressing = false
    @State private var didComplete = false

    var body: some View {
        let gesture = LongPressGesture(minimumDuration: minDuration, maximumDistance: 20)
            .updating($isPressing) { value, state, _ in
                state = value
            }
            .onEnded { _ in
                guard !didComplete else { return }
                didComplete = true
                onComplete()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    didComplete = false
                }
            }

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                .fill(ZD.Color.card)
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.4), lineWidth: ZD.Stroke.thin)
                )

            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .fill(accent)
                    .frame(width: proxy.size.width * (isPressing ? 1 : 0))
                    .animation(.easeInOut(duration: minDuration), value: isPressing)
            }
            .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous))

            HStack(spacing: ZD.Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }

                Text(isPressing ? "Hold..." : title)
                    .font(ZD.Font.button())
                    .tracking(0.3)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.vertical, ZD.Spacing.sm)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .frame(height: 48)
        .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous))
        .gesture(gesture)
        .scaleEffect(isPressing ? 0.985 : 1)
        .shadow(
            color: isPressing ? ZD.Color.glow.opacity(0.75) : .clear,
            radius: isPressing ? 16 : 0,
            x: 0,
            y: 8
        )
        .animation(.easeOut(duration: 0.16), value: isPressing)
    }
}
