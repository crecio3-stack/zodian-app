#if DEBUG
import Foundation

/// Canonical identities used for provider-free Identity presentation QA.
/// These IDs are never consulted by Beta/Release runtime paths.
enum IdentityPresentationDebugFixtures {
    static let ids = [
        "libra-snake",
        "taurus-horse",
        "cancer-pig",
        "virgo-goat",
        "gemini-tiger",
        "leo-horse",
        "pisces-dog",
        "aquarius-snake"
    ]

    static let isValid: Bool = {
        ids.count == 8 && Set(ids).count == ids.count && ids.allSatisfy { $0.contains("-") }
    }()
}
#endif
