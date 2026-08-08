#if DEBUG
import SwiftUI

struct PatternMemoryPreviewView: View {
    @State private var summary = PatternMemoryService.shared.monthlySummary()
    @State private var reflection = PatternMemoryService.shared.monthlyReflection()
    @State private var eventCounts = PatternMemoryPreviewView.makeEventCounts()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                previewSection(title: "Debug Counts") {
                    metricRow("Total saved reads", "\(summary.totalSavedReads)")
                    metricRow("Total saved profiles", "\(summary.totalSavedProfiles)")
                    metricRow("Most-used lens", summary.mostUsedLens ?? "None")
                    metricRow("Archive visits", "\(summary.archiveVisits)")
                    metricRow("Thread starts", "\(summary.threadStarts)")
                }

                previewSection(title: "Reflection Preview") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(reflection.monthTitle)
                            .font(ZD.Font.caption(.semibold))
                            .foregroundStyle(ZD.Color.accent)

                        ForEach(Array(reflection.reflectionLines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                previewSection(title: "Event Sources") {
                    if eventCounts.isEmpty {
                        Text("No Pattern Memory events recorded.")
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
                    } else {
                        ForEach(eventCounts, id: \.type) { item in
                            metricRow(item.type.displayTitle, "\(item.count)")
                        }
                    }
                }

                previewSection(title: "Debug Actions") {
                    VStack(spacing: 10) {
                        debugButton("Regenerate reflection", icon: "arrow.clockwise") {
                            refresh()
                        }

                        debugButton("Clear Pattern Memory", icon: "trash", tint: ZD.Color.error) {
                            PatternMemoryService.shared.reset()
                            refresh()
                        }

                        debugButton("Export summary to console", icon: "terminal") {
                            exportSummaryToConsole()
                        }
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 18)
            .padding(.bottom, 60)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Pattern Memory")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear(perform: refresh)
    }

    private func previewSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.muted)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .fill(ZD.Color.card.opacity(0.76))
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.16), lineWidth: 1)
                    )
            )
        }
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)

            Text(value)
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func debugButton(
        _ title: String,
        icon: String,
        tint: Color = ZD.Color.accent,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))

                Text(title)
                    .font(ZD.Font.body(.semibold))

                Spacer()
            }
            .foregroundStyle(tint)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                    .fill(tint.opacity(0.10))
            )
        }
        .buttonStyle(.plain)
    }

    private func refresh() {
        summary = PatternMemoryService.shared.monthlySummary()
        reflection = PatternMemoryService.shared.monthlyReflection()
        eventCounts = Self.makeEventCounts()
    }

    private func exportSummaryToConsole() {
        refresh()

        print("🧠 Pattern Memory Summary")
        print("totalSavedReads=\(summary.totalSavedReads)")
        print("totalSavedProfiles=\(summary.totalSavedProfiles)")
        print("mostUsedLens=\(summary.mostUsedLens ?? "none")")
        print("archiveVisits=\(summary.archiveVisits)")
        print("archiveItemOpens=\(summary.archiveItemOpens)")
        print("threadStarts=\(summary.threadStarts)")
        print("reflectionLineCount=\(reflection.reflectionLines.count)")
        print("eventCounts=\(eventCounts.map { "\($0.type.rawValue):\($0.count)" }.joined(separator: ", "))")
    }

    private static func makeEventCounts() -> [(type: PatternMemoryEventType, count: Int)] {
        let counts = Dictionary(
            grouping: PatternMemoryService.shared.allEvents(),
            by: \.type
        )
            .mapValues(\.count)

        return PatternMemoryEventType.allCases
            .compactMap { type in
                guard let count = counts[type], count > 0 else { return nil }
                return (type: type, count: count)
            }
    }
}

private extension PatternMemoryEventType {
    var displayTitle: String {
        switch self {
        case .dailyReadOpened:
            return "Daily Lens opened"
        case .dailyReadExpanded:
            return "Daily Lens revisited"
        case .dailyReadSaved:
            return "Daily Lens saved"
        case .dailyReadUnsaved:
            return "Daily Lens removed"
        case .dailyReadShared:
            return "Daily Lens shared"
        case .patternScreenOpened:
            return "Pattern visits"
        case .patternArchiveOpened, .patternArchiveViewed:
            return "Archive visits"
        case .savedReadOpenedFromArchive, .archiveItemOpened:
            return "Saved signals opened"
        case .lensSelected:
            return "Connect lenses selected"
        case .profileViewed:
            return "Profiles viewed"
        case .profileSaved:
            return "Profiles saved"
        case .profileUnsaved:
            return "Profiles removed"
        case .threadProfileOpened:
            return "Saved profiles opened"
        case .startThreadTapped:
            return "Notes started"
        case .archivePreviewViewed:
            return "Archive previews viewed"
        }
    }
}
#endif
