import SwiftUI

struct OnboardingRitualWheelContainer<Content: View>: View {
    let onInteraction: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        onInteraction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onInteraction = onInteraction
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in
                onInteraction?()
            }
        )
    }
}

struct OnboardingRitualMoonWheelContainer<Content: View>: View {
    let onInteraction: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        onInteraction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onInteraction = onInteraction
        self.content = content
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.025),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 150, height: 44)
                .blur(radius: 14)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.16),
                        Color.black.opacity(0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)

                Spacer()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)
            }
            .allowsHitTesting(false)

            content()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in
                onInteraction?()
            }
        )
    }
}

struct OnboardingBirthdaySelector: View {
    @Binding var monthSelection: Int
    @Binding var daySelection: Int
    let availableMonths: [Int]
    let availableDays: [Int]
    let monthName: (Int) -> String
    let onInteraction: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent.opacity(0.88))

                    Text("Birth month and day")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(0.35)
                        .foregroundStyle(ZD.Color.textPrimary)
                }
                .frame(maxWidth: .infinity)

                Text("Western astrology uses the month and day you were born")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)

            OnboardingRitualWheelContainer(onInteraction: onInteraction) {
                HStack(spacing: 0) {
                    Picker("Birth Month", selection: $monthSelection) {
                        ForEach(availableMonths, id: \.self) { month in
                            Text(monthName(month))
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .compositingGroup()
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .clipped()
                    .mask(Rectangle())
                    .colorScheme(.dark)

                    Picker("Birth Day", selection: $daySelection) {
                        ForEach(availableDays, id: \.self) { day in
                            Text(String(day))
                                .tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .compositingGroup()
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .clipped()
                    .mask(Rectangle())
                    .colorScheme(.dark)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 142)
                .clipped()
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingRefinementSectionLabel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)

                Text(title)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
            }

            Text(subtitle)
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OnboardingRefinementFieldBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
            .fill(ZD.Color.card.opacity(0.34))
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.16), lineWidth: ZD.Stroke.thin)
            )
    }
}
