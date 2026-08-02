import Foundation

enum IdentityProfileRuleChecker {
    static func validationErrors(for profile: LegacyIdentityProfile) -> [String] {
        var errors: [String] = []

        if profile.strengths.contains(where: { !$0.hasPrefix("You ") }) {
            errors.append("Every strength must start with 'You'.")
        }

        if profile.shadows.contains(where: { !$0.hasPrefix("You ") }) {
            errors.append("Every shadow must start with 'You'.")
        }

        if !containsTension(in: profile) {
            errors.append("Each identity should contain at least one visible tension or contradiction.")
        }

        return errors
    }

    private static func containsTension(in profile: LegacyIdentityProfile) -> Bool {
        let tensionMarkers = [" but ", " yet ", " while ", " underneath ", " although ", " even when ", " instead of "]

        let fields = [
            profile.thesis.lowercased(),
            profile.combinedSummary.lowercased(),
            profile.relationshipStyle.lowercased(),
            profile.stressPattern.lowercased(),
            profile.growthEdge.lowercased()
        ]

        return fields.contains { field in
            tensionMarkers.contains { field.contains($0) }
        }
    }
}
