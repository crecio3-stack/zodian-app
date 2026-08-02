import SwiftUI

/// Debug consolidation renderer. It consumes only `IdentityProfile`, never a
/// resonance service, Base64 payload, or editorial fixture dictionary.
struct IdentityCanonicalProfileView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let cardContent: IdentityCardContent
    let profile: IdentityProfile
    var heroInstruction: String? = nil
    var heroShareAccessibilityLabel: String? = nil
    var onShareHero: (() -> Void)? = nil
    var onSectionExpanded: ((String) -> Void)? = nil

    @State private var expandedAreaID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            IdentityEditorialHeroView(
                cardContent: cardContent,
                instruction: heroInstruction,
                shareAccessibilityLabel: heroShareAccessibilityLabel,
                onShare: onShareHero
            )

            IdentityEditorialTraitsView(
                strength: profile.strengths.joined(separator: "\n"),
                shadow: profile.shadows.joined(separator: "\n")
            )

            IdentityCanonicalSignatureView(text: profile.signature)

            ForEach(Array(profile.lifeAreas.enumerated()), id: \.element.id) { index, area in
                IdentityCanonicalAccordion(
                    area: area,
                    isHighlighted: index.isMultiple(of: 2) == false,
                    isExpanded: expandedAreaID == area.id,
                    onToggle: { toggle(area.id) }
                )
                .id(area.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggle(_ id: String) {
        let opens = expandedAreaID != id
        let update = { expandedAreaID = opens ? id : nil }
        if reduceMotion {
            update()
        } else {
            withAnimation(.easeInOut(duration: 0.24), update)
        }
        guard opens else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.12)) {
            onSectionExpanded?(id)
        }
    }
}

private struct IdentityCanonicalSignatureView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            IdentityEditorialEyebrow(title: "YOUR SIGNATURE", accent: ZD.Color.premium)
            Text(EditorialParagraphFormatter.format(text))
                .font(.system(.body, weight: .regular))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your Signature. \(text)")
    }
}

private struct IdentityCanonicalAccordion: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let area: IdentityProfile.LifeArea
    let isHighlighted: Bool
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 11) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        IdentityEditorialEyebrow(title: title, accent: accent)
                        Text(area.hook)
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Color.clear
                        .frame(width: 44, height: 44)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .padding(.top, 4)
                                .padding(.trailing, 2)
                        }
                        .contentShape(Rectangle())
                        .accessibilityHidden(true)
                }

                if isExpanded {
                    Divider().overlay(ZD.Color.border.opacity(0.18))
                    Text(EditorialParagraphFormatter.format(area.expandedRead))
                        .font(.system(.body, weight: .regular))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, isExpanded ? 19 : 16)
            .frame(minHeight: 44, alignment: .leading)
            .background(background)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(area.hook)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityHint(isExpanded ? "Double tap to collapse." : "Double tap to expand.")
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.24), value: isExpanded)
    }

    private var title: String { area.area.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).uppercased() }
    private var accent: Color { isHighlighted ? ZD.Color.accent : ZD.Color.muted }

    @ViewBuilder private var background: some View {
        if isHighlighted {
            IdentityEditorialPanelBackground(accent: ZD.Color.accent, glowOpacity: 0.055)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.card.opacity(0.34))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(ZD.Color.border.opacity(0.14), lineWidth: 1))
        }
    }
}
