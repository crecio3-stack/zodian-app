import SwiftUI

struct PatternMemorySavedProfileFocus: Identifiable {
    let id = UUID()
    let title: String
    let matches: [SavedMatch]
}

struct PatternMemorySavedProfilesView: View {
    let title: String
    let matches: [SavedMatch]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("People you saved because something about them stayed in focus.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)

                    ForEach(matches, id: \.id) { match in
                        savedProfileRow(match)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
            .background(ZD.Color.bg.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func savedProfileRow(_ match: SavedMatch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(match.name)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 10)

                Text(savedProfileIdentity(for: match))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(ZD.Color.muted)
                    .lineLimit(1)
            }

            Text(savedProfileSignal(for: match))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.78))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private func savedProfileIdentity(for match: SavedMatch) -> String {
        guard let western = WesternZodiac(rawValue: match.westernSignRaw)?.displayName,
              let eastern = ChineseZodiac(rawValue: match.chineseSignRaw)?.displayName
        else {
            return "Saved profile"
        }

        return "\(western) × \(eastern)"
    }

    private func savedProfileSignal(for match: SavedMatch) -> String {
        if let signal = match.signals.first {
            let response = signal.response.trimmingCharacters(in: .whitespacesAndNewlines)
            return response.isEmpty ? signal.prompt : response
        }

        let reason = match.primaryReasonDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !reason.isEmpty {
            return reason
        }

        let essence = match.essence.trimmingCharacters(in: .whitespacesAndNewlines)
        return essence.isEmpty ? "A saved profile that stayed with you." : essence
    }
}
