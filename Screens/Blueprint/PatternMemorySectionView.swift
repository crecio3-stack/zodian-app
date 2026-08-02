import SwiftUI

struct PatternMemorySectionView: View {
    let summary: PatternMemorySummary
    let reflection: PatternMemoryMonthlyReflection
    let onSelectObservation: (PatternMemoryObservationTarget) -> Void
    var showsObservationActions = true

    private var hasMemory: Bool {
        summary.totalSavedReads > 0
            || summary.totalSavedProfiles > 0
            || !summary.lensCounts.isEmpty
            || !summary.topThemes.isEmpty
            || !summary.topSignals.isEmpty
            || summary.archiveVisits > 0
            || summary.archiveItemOpens > 0
            || summary.threadStarts > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            if hasMemory {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(visibleObservations) { observation in
                        memoryRow(observation)
                    }
                }
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: ZD.Color.accent.opacity(0.08), radius: 18, y: 10)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("PATTERN MEMORY")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(ZD.Color.accent.opacity(0.9))

                Text("What Zodian is beginning to notice")
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("A reflection on what keeps asking for your attention.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Image(systemName: "brain.head.profile")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(ZD.Color.accent.opacity(0.86))
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memory starts when something begins to repeat.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Save, revisit, or continue something; this section will begin noticing what still has a pull.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var visibleObservations: [PatternMemoryObservation] {
        let candidates = [
            returningObservation,
            attentionObservation,
            whoStayedObservation,
            actionObservation,
            monthlyObservation
        ].compactMap { $0 }

        var seen = Set<String>()
        let unique = candidates.filter { observation in
            let key = observation.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }

        return Array(unique.prefix(4))
    }

    private var returningObservation: PatternMemoryObservation? {
        guard let line = usefulLine(
            from: reflection.recurringThemes,
            rejecting: ["nothing has repeated", "still gathering signal"]
        ) else {
            return nil
        }

        return PatternMemoryObservation(
            eyebrow: "WHAT HAD A PULL",
            icon: "arrow.triangle.2.circlepath",
            text: line,
            target: .savedReads(query: summary.topSavedReadThemes.first?.value)
        )
    }

    private var attentionObservation: PatternMemoryObservation? {
        guard let payload = attentionObservationPayload else { return nil }

        return PatternMemoryObservation(
            eyebrow: "WHERE YOU LOOKED",
            icon: "scope",
            text: payload.text,
            target: payload.target
        )
    }

    private var whoStayedObservation: PatternMemoryObservation? {
        guard let payload = whoStayedObservationPayload else { return nil }

        return PatternMemoryObservation(
            eyebrow: "WHO LINGERED",
            icon: "person.crop.circle.badge.checkmark",
            text: payload.text,
            target: payload.target
        )
    }

    private var actionObservation: PatternMemoryObservation? {
        guard let payload = actionObservationPayload else { return nil }

        return PatternMemoryObservation(
            eyebrow: "WHAT BECAME REAL",
            icon: "bolt.fill",
            text: payload.text,
            target: payload.target
        )
    }

    private var monthlyObservation: PatternMemoryObservation? {
        guard let line = usefulLine(
            from: reflection.reflectionLines,
            rejecting: [
                "nothing has repeated",
                "no clear",
                "not developed",
                "too varied",
                "no specific",
                "no identity",
                "no saved read",
                "no saved identity",
                "no saved profile",
                "has not become part",
                "not revisited",
                "more observational than conversational"
            ]
        ) else {
            return nil
        }

        return PatternMemoryObservation(
            eyebrow: "A QUIET THREAD",
            icon: "moon.stars.fill",
            text: line,
            target: .savedReads(query: summary.topSavedReadThemes.first?.value)
        )
    }

    private var whoStayedObservationPayload: (text: String, target: PatternMemoryObservationTarget)? {
        if let line = reflection.repeatedSavedIdentities.first,
           !line.isEmpty,
           !line.localizedCaseInsensitiveContains("too varied") {
            return (line, .savedProfiles(query: summary.repeatedSavedIdentities.first?.value))
        }

        if let line = reflection.threadStartedIdentities.first,
           !line.isEmpty,
           !line.localizedCaseInsensitiveContains("no saved identity") {
            return (line, .savedProfiles(query: summary.threadStartedIdentities.first?.value))
        }

        if let repeated = summary.repeatedIdentities.first {
            return (
                "\(repeated.value) may be echoing something you are learning to recognize.",
                .savedProfiles(query: repeated.value)
            )
        }

        return nil
    }

    private var attentionObservationPayload: (text: String, target: PatternMemoryObservationTarget)? {
        if !reflection.mostUsedLens.localizedCaseInsensitiveContains("no clear") {
            return (reflection.mostUsedLens, .none)
        }

        if let theme = summary.topThemes.first {
            return (
                "\(theme.value) seems to be one of the places your attention slows down.",
                .savedReads(query: theme.value)
            )
        }

        if let signal = summary.topSignals.first {
            return (
                "\(signal.value) may be something you notice before you can explain why.",
                .savedProfiles(query: signal.value)
            )
        }

        return nil
    }

    private var actionObservationPayload: (text: String, target: PatternMemoryObservationTarget)? {
        if !reflection.threadActivity.localizedCaseInsensitiveContains("no saved profile"),
           !reflection.threadActivity.localizedCaseInsensitiveContains("more observational than conversational") {
            return (
                reflection.threadActivity,
                .savedProfiles(query: summary.threadStartedIdentities.first?.value)
            )
        }

        if !reflection.archiveUsage.localizedCaseInsensitiveContains("has not become part") {
            return (
                reflection.archiveUsage,
                .savedReads(query: summary.revisitedSavedReadThemes.first?.value)
            )
        }

        if summary.totalSavedReads > 0 {
            return (
                "The reads you kept may be showing what you are trying to understand.",
                .savedReads(query: nil)
            )
        }

        if summary.totalSavedProfiles > 0 {
            return (
                "The profiles you kept may be pointing at what feels familiar.",
                .savedProfiles(query: nil)
            )
        }

        return nil
    }

    @ViewBuilder
    private func memoryRow(_ observation: PatternMemoryObservation) -> some View {
        if showsObservationActions && observation.target.isActionable {
            Button {
                onSelectObservation(observation.target)
            } label: {
                memoryRowContent(observation)
            }
            .buttonStyle(.plain)
        } else {
            memoryRowContent(observation)
        }
    }

    private func memoryRowContent(_ observation: PatternMemoryObservation) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: observation.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.accent.opacity(0.82))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(ZD.Color.card.opacity(0.72))
                        .overlay(
                            Circle()
                                .stroke(ZD.Color.accent.opacity(0.14), lineWidth: 1)
                        )
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(observation.eyebrow)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(ZD.Color.muted)

                Text(observation.text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if showsObservationActions, let ctaText = observation.target.ctaText {
                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Text(ctaText)
                        .font(.system(size: 12, weight: .bold, design: .rounded))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(ZD.Color.premium.opacity(0.86))
                .padding(.top, 19)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }

    private func usefulLine(from lines: [String], rejecting rejectedPhrases: [String]) -> String? {
        lines.first { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return false }
            return !rejectedPhrases.contains { phrase in
                trimmed.localizedCaseInsensitiveContains(phrase)
            }
        }
    }
}

enum PatternMemoryObservationTarget: Equatable {
    case savedReads(query: String?)
    case savedProfiles(query: String?)
    case none

    var isActionable: Bool {
        switch self {
        case .savedReads, .savedProfiles:
            return true
        case .none:
            return false
        }
    }

    var ctaText: String? {
        switch self {
        case .savedReads:
            return "See read"
        case .savedProfiles:
            return "See who"
        case .none:
            return nil
        }
    }
}

private struct PatternMemoryObservation: Identifiable {
    let eyebrow: String
    let icon: String
    let text: String
    let target: PatternMemoryObservationTarget

    var id: String {
        eyebrow
    }
}
