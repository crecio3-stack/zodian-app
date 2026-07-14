import SwiftUI

/// Shared primary renderer for the versioned title/read consumer contract.
struct DailyLensTitleReadView: View {
    let content: DailyLensContent
    var titleBaseSize: CGFloat = 32
    var readBaseSize: CGFloat = 16
    @ScaledMetric(relativeTo: .title) private var titleScale: CGFloat = 1
    @ScaledMetric(relativeTo: .body) private var readScale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(content.title)
                .font(.system(size: titleBaseSize * titleScale, weight: .bold, design: .serif))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.read)
                .font(.system(size: readBaseSize * readScale, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.92))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today’s Lens. \(content.title). \(content.read)")
    }
}
