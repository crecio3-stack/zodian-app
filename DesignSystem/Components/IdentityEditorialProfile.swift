import SwiftUI
import Foundation
import UIKit

enum IdentityEditorialSectionKind: String, CaseIterable, Identifiable {
    case howItShowsUp
    case whatGetsInTheWay
    case loveAndFriendship
    case trustAndCloseness
    case decisionMaking
    case workAndPurpose
    case underPressure
    case restoration
    case closeCompany
    case growth
    case closingSynthesis

    var id: String { rawValue }

    /// Reader-facing order only. The frozen editorial schema keeps its own
    /// field order; this sequence gives the profile an affirming first pass
    /// before it moves into friction and recovery.
    static let presentationOrder: [IdentityEditorialSectionKind] = [
        .howItShowsUp,
        .loveAndFriendship,
        .trustAndCloseness,
        .decisionMaking,
        .workAndPurpose,
        .whatGetsInTheWay,
        .underPressure,
        .restoration,
        .closeCompany,
        .growth,
        .closingSynthesis
    ]

    var eyebrow: String {
        switch self {
        case .howItShowsUp: "HOW IT SHOWS UP"
        case .whatGetsInTheWay: "WHAT GETS IN THE WAY"
        case .loveAndFriendship: "LOVE AND FRIENDSHIP"
        case .trustAndCloseness: "TRUST AND CLOSENESS"
        case .decisionMaking: "DECISION-MAKING"
        case .workAndPurpose: "WORK AND PURPOSE"
        case .underPressure: "UNDER PRESSURE"
        case .restoration: "RESTORATION"
        case .growth: "GROWTH"
        case .closingSynthesis: "WHAT YOU RETURN TO"
        case .closeCompany: "CLOSE COMPANY"
        }
    }

    func content(
        from presentation: IdentityPresentation,
        closeCompany: String?
    ) -> String? {
        switch self {
        case .howItShowsUp: presentation.howItShowsUp
        case .whatGetsInTheWay: presentation.whatGetsInTheWay
        case .loveAndFriendship: presentation.loveAndFriendship
        case .trustAndCloseness: presentation.trustAndCloseness
        case .decisionMaking: presentation.decisionMaking
        case .workAndPurpose: presentation.workAndPurpose
        case .underPressure: presentation.underPressure
        case .restoration: presentation.restoration
        case .growth: presentation.growth
        case .closingSynthesis: Self.deepSynthesis(
            core: presentation.coreSynthesis,
            closing: presentation.closingSynthesis
        )
        case .closeCompany: closeCompany
        }
    }

    private static func deepSynthesis(core: String, closing: String?) -> String? {
        let core = core.trimmingCharacters(in: .whitespacesAndNewlines)
        let closing = closing?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let values = [core, closing].filter { !$0.isEmpty }
        guard let first = values.first else { return nil }
        guard values.count > 1,
              !IdentityEditorialOpeningCopy.isNearDuplicate(first, values[1]) else {
            return first
        }
        return values.joined(separator: "\n\n")
    }
}

enum IdentityEditorialNavigationClearance {
    /// The floating tab treatment occupies more than the system safe area.
    /// Combining both keeps the final inline expansion comfortably reachable
    /// on compact and home-indicator devices without route-specific padding.
    static func bottomInset(safeAreaBottom: CGFloat) -> CGFloat {
        max(152, safeAreaBottom + 108)
    }
}

struct IdentityEditorialProfileView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let cardContent: IdentityCardContent
    let presentation: IdentityPresentation
    var closeCompany: String? = nil
    var heroInstruction: String? = nil
    var heroShareAccessibilityLabel: String? = nil
    var onShareHero: (() -> Void)? = nil
    var onSectionExpanded: ((IdentityEditorialSectionKind) -> Void)? = nil

    // This intentionally stays local to each rendered profile. Owner and
    // saved-person identities do not share expansion state, and it resets
    // when either screen is recreated.
    @State private var expandedSection: IdentityEditorialSectionKind?

    var body: some View {
        let opening = IdentityEditorialOpeningCopy.resolve(
            cardContent: cardContent,
            tell: presentation.tell
        )

        VStack(alignment: .leading, spacing: 22) {
            IdentityEditorialHeroView(
                cardContent: opening.cardContent,
                instruction: heroInstruction,
                shareAccessibilityLabel: heroShareAccessibilityLabel,
                onShare: onShareHero
            )

            if !opening.tell.isEmpty {
                IdentityEditorialTellView(statement: opening.tell)
            }

            IdentityEditorialTraitsView(
                strength: presentation.strength,
                shadow: presentation.shadow
            )

            ForEach(Array(visibleSections.enumerated()), id: \.element.id) { index, section in
                IdentityExpandableSection(
                    section: section,
                    isHighlighted: index.isMultiple(of: 2) == false,
                    isExpanded: expandedSection == section.kind,
                    onToggle: { toggle(section.kind) }
                )
                .id(section.kind.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var visibleSections: [IdentityEditorialSectionContent] {
        var seenContent: Set<String> = []

        return IdentityEditorialSectionKind.presentationOrder.compactMap { kind in
            guard let content = kind.content(
                from: presentation,
                closeCompany: closeCompany
            )?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !content.isEmpty else {
                return nil
            }

            let semanticKey = content
                .lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            guard seenContent.insert(semanticKey).inserted else {
                return nil
            }

            let pieces = IdentityEditorialSentenceRhythm.split(content)
            return IdentityEditorialSectionContent(
                kind: kind,
                lead: pieces.lead,
                detail: pieces.supporting
            )
        }
    }

    private func toggle(_ kind: IdentityEditorialSectionKind) {
        let opensSection = expandedSection != kind
        let update = {
            expandedSection = opensSection ? kind : nil
        }

        if reduceMotion {
            update()
        } else {
            withAnimation(.easeInOut(duration: 0.24), update)
        }

        guard opensSection else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0 : 0.12)) {
            onSectionExpanded?(kind)
        }
    }
}

/// Resolves the adjacent reveal-card and Tell roles without rewriting source
/// copy. The Tell wins when a compact field is missing or repeats it; a
/// duplicated hero line is omitted rather than silently replaced.
enum IdentityEditorialOpeningCopy {
    struct Resolved: Equatable {
        let cardContent: IdentityCardContent
        let tell: String
    }

    static func resolve(cardContent: IdentityCardContent, tell: String) -> Resolved {
        let tell = trimmed(tell)
        var descriptor = trimmed(cardContent.descriptor)
        var teaser = trimmed(cardContent.patternSummary)

        if isNearDuplicate(teaser, descriptor) {
            teaser = ""
        }
        if isNearDuplicate(descriptor, tell) {
            descriptor = ""
        }
        if isNearDuplicate(teaser, tell) {
            teaser = ""
        }

        return Resolved(
            cardContent: IdentityCardContent(
                id: cardContent.id,
                signCombination: cardContent.signCombination,
                identityName: cardContent.identityName,
                descriptor: descriptor,
                patternSummary: teaser
            ),
            tell: tell
        )
    }

    static func isNearDuplicate(_ lhs: String, _ rhs: String) -> Bool {
        let left = normalizedWords(lhs)
        let right = normalizedWords(rhs)
        guard !left.isEmpty, !right.isEmpty else { return false }
        if left == right { return true }

        let shorter = min(left.count, right.count)
        let longer = max(left.count, right.count)
        guard shorter >= 4, Double(shorter) / Double(longer) >= 0.75 else {
            return false
        }

        let leftSet = Set(left)
        let rightSet = Set(right)
        let overlap = leftSet.intersection(rightSet).count
        let union = leftSet.union(rightSet).count
        return union > 0 && Double(overlap) / Double(union) >= 0.86
    }

    private static func normalizedWords(_ value: String) -> [String] {
        value.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init)
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct IdentityEditorialSectionContent: Identifiable {
    let kind: IdentityEditorialSectionKind
    let lead: String
    let detail: String

    var id: String { kind.id }
}

struct IdentityEditorialHeroView: View {
    let cardContent: IdentityCardContent
    let instruction: String?
    let shareAccessibilityLabel: String?
    let onShare: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            heroCard

            if let instruction, !instruction.isEmpty {
                Text(instruction)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(ZD.Color.muted.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var heroCard: some View {
        let accessibilitySummary = [
            cardContent.signCombination,
            cardContent.identityName,
            cardContent.descriptor,
            cardContent.patternSummary
        ]
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")

        let card = IdentityRevealCardView(
            content: cardContent,
            animatesIdentityTitle: !UIAccessibility.isReduceMotionEnabled
        )
        .frame(maxWidth: 380)
        .shadow(color: ZD.Color.accent.opacity(0.14), radius: 22, y: 10)
        .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)

        if let onShare {
            card
                .onLongPressGesture(minimumDuration: 0.45) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShare()
                }
                .accessibilityAction(named: shareAccessibilityLabel ?? "Share identity") {
                    onShare()
                }
        } else {
            card
        }
    }
}

private struct IdentityEditorialTellView: View {
    let statement: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            IdentityEditorialEyebrow(title: "THE TELL", accent: ZD.Color.premium)

            Text(statement)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
        .padding(.horizontal, 4)
    }
}

private struct IdentityEditorialTraitsWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct IdentityEditorialTraitsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var availableWidth = UIScreen.main.bounds.width
    let strength: String
    let shadow: String

    var body: some View {
        Group {
            if shouldStackTraits {
                VStack(alignment: .leading, spacing: 18) {
                    trait(
                        label: "STRENGTH",
                        text: strength,
                        accent: ZD.Color.accent,
                        rightAligned: false
                    )
                    divider
                    trait(
                        label: "SHADOW",
                        text: shadow,
                        accent: ZD.Color.muted,
                        rightAligned: false
                    )
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    trait(
                        label: "STRENGTH",
                        text: strength,
                        accent: ZD.Color.accent,
                        rightAligned: false
                    )
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    Rectangle()
                        .fill(ZD.Color.border.opacity(0.18))
                        .frame(width: 1)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 14)

                    trait(
                        label: "SHADOW",
                        text: shadow,
                        accent: ZD.Color.muted,
                        rightAligned: false
                    )
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(contrastBackground)
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: IdentityEditorialTraitsWidthPreferenceKey.self,
                    value: proxy.size.width
                )
            }
        )
        .onPreferenceChange(IdentityEditorialTraitsWidthPreferenceKey.self) { width in
            guard width > 0, abs(availableWidth - width) > 0.5 else { return }
            availableWidth = width
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(ZD.Color.border.opacity(0.18))
            .frame(height: 1)
    }

    private var shouldStackTraits: Bool {
        // Standard phone widths retain the visual contrast. Narrow containers
        // and accessibility text sizes stack before either column gets cramped.
        dynamicTypeSize.isAccessibilitySize || availableWidth < 350
    }

    private var contrastBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        ZD.Color.cardAlt.opacity(0.72),
                        ZD.Color.card.opacity(0.70)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.16), lineWidth: 1)
            )
    }

    private func trait(
        label: String,
        text: String,
        accent: Color,
        rightAligned: Bool
    ) -> some View {
        VStack(alignment: rightAligned ? .trailing : .leading, spacing: 9) {
            IdentityEditorialEyebrow(title: label, accent: accent)
                .frame(maxWidth: .infinity, alignment: rightAligned ? .trailing : .leading)

            ForEach(Array(items(in: text).enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if rightAligned {
                        Spacer(minLength: 0)
                    } else {
                        traitBullet(accent: accent)
                    }

                    Text(item)
                        .font(.system(.body, weight: .regular))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(2)
                        .multilineTextAlignment(rightAligned ? .trailing : .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if rightAligned {
                        traitBullet(accent: accent)
                    } else {
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: rightAligned ? .trailing : .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func traitBullet(accent: Color) -> some View {
        Circle()
            .fill(accent.opacity(0.78))
            .frame(width: 4, height: 4)
            .accessibilityHidden(true)
    }

    private func items(in text: String) -> [String] {
        let items = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return items.isEmpty ? [text] : items
    }
}

private struct IdentityExpandableSection: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let section: IdentityEditorialSectionContent
    let isHighlighted: Bool
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        IdentityEditorialEyebrow(title: section.kind.eyebrow, accent: accent)

                        Text(section.lead)
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(ZD.Color.textPrimary)
                            .lineSpacing(3)
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

                if isExpanded, !section.detail.isEmpty {
                    Divider()
                        .overlay(ZD.Color.border.opacity(0.18))
                        .transition(.opacity)

                    Text(section.detail)
                        .font(.system(.body, weight: .regular))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, isExpanded ? 18 : 15)
            .frame(minHeight: 44, alignment: .leading)
            .background(background)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(section.kind.eyebrow). \(section.lead)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityHint(isExpanded ? "Double tap to collapse." : "Double tap to expand.")
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.24), value: isExpanded)
    }

    private var accent: Color {
        isHighlighted ? ZD.Color.accent : ZD.Color.muted
    }

    @ViewBuilder
    private var background: some View {
        if isHighlighted {
            IdentityEditorialPanelBackground(accent: ZD.Color.accent, glowOpacity: 0.055)
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.card.opacity(0.34))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.14), lineWidth: 1)
                )
        }
    }
}

struct IdentityEditorialEyebrow: View {
    let title: String
    let accent: Color

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(1.6)
            .foregroundStyle(accent.opacity(0.9))
            .accessibilityAddTraits(.isHeader)
    }
}

struct IdentityEditorialPanelBackground: View {
    let accent: Color
    let glowOpacity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        ZD.Color.cardAlt.opacity(0.84),
                        ZD.Color.card.opacity(0.90),
                        ZD.Color.bg.opacity(0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.16),
                                accent.opacity(glowOpacity),
                                ZD.Color.border.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(accent.opacity(glowOpacity))
                    .frame(width: 110, height: 110)
                    .blur(radius: 20)
                    .offset(x: 30, y: -36)
                    .allowsHitTesting(false)
            }
    }
}

private enum IdentityEditorialSentenceRhythm {
    static func split(_ text: String) -> (lead: String, supporting: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "") }

        var sentences: [String] = []
        trimmed.enumerateSubstrings(
            in: trimmed.startIndex..<trimmed.endIndex,
            options: [.bySentences, .substringNotRequired]
        ) { _, range, _, _ in
            let sentence = String(trimmed[range])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
        }

        guard let lead = sentences.first else { return (trimmed, "") }
        return (lead, sentences.dropFirst().joined(separator: " "))
    }
}

#if DEBUG
#Preview("Shared Identity editorial profile") {
    ScrollView {
        IdentityEditorialProfileView(
            cardContent: IdentityCardContent(
                id: "libra-snake",
                signCombination: "Libra × Snake",
                identityName: "The Velvet Dagger",
                descriptor: "Warm face, private center",
                patternSummary: "You want closeness to feel balanced, and you notice imbalance early."
            ),
            presentation: IdentityPresentation.make(from: .placeholder),
            closeCompany: "People who respect both warmth and privacy tend to stay close."
        )
        .padding(20)
    }
    .background(ZD.Color.bg)
    .preferredColorScheme(.dark)
}
#endif
