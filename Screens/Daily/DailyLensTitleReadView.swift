import SwiftUI

/// Shared primary renderer for the versioned title/read consumer contract.
struct DailyLensTitleReadView: View {
    let content: DailyLensContent
    var titleFont: Font = .system(size: 32, weight: .bold, design: .serif)
    var readFont: Font = .system(size: 16, weight: .medium)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(content.title)
                .font(titleFont)
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.read)
                .font(readFont)
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.92))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today’s Lens. \(content.title). \(content.read)")
    }
}
