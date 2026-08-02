import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: ZD.Spacing.s) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(ZD.Font.heading())
                    .foregroundStyle(ZD.Color.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                }
            }

            Spacer()

            if let trailing {
                trailing
            }
        }
    }
}

// MARK: - Convenience Init (for trailing view)

extension SectionHeader {
    init<Trailing: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = AnyView(trailing())
    }
}

// MARK: - Divider Variant (Optional)

struct SectionDividerHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: ZD.Spacing.s) {
            Rectangle()
                .fill(ZD.Color.divider)
                .frame(height: 1)

            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.muted)

            Rectangle()
                .fill(ZD.Color.divider)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview("Section Header") {
    VStack(spacing: ZD.Spacing.l) {
        SectionHeader(title: "Quick Actions")

        SectionHeader(
            title: "Your Blueprint",
            subtitle: "Identity at a glance"
        )

        SectionHeader(
            title: "Connect",
            subtitle: "Find your energetic match"
        ) {
            Text("See All")
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
        }

        SectionDividerHeader(title: "Premium")

    }
    .padding()
    .zScreenBackground()
    .preferredColorScheme(.dark)
}
