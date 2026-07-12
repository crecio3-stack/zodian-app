import Foundation
import SwiftUI

struct ConnectProfileAdapter {
    static func makeDeckProfile(
        from user: ConnectUserProfile,
        currentUser: UserProfile
    ) -> DeckProfile {
        let western = currentUser.westernSign
        let chinese = currentUser.chineseSign

        let archetype = ArchetypeService.shared.archetype(
            for: western,
            chinese: chinese
        )

        let compatibility = CompatibilityScoringService.shared.score(
            userWestern: currentUser.westernSign,
            userChinese: currentUser.chineseSign,
            userArchetypeId: currentUser.archetypeId,
            candidateWestern: western,
            candidateChinese: chinese,
            candidateArchetypeId: archetype.id
        )

        return DeckProfile(
            name: user.displayName,
            age: user.age.map { user.showsAge ? $0 : 0 } ?? 0,
            archetypeId: archetype.id,
            archetypeTitle: archetype.title,
            combinedSigns: "\(western.displayName) × \(chinese.displayName)",
            westernSign: western,
            chineseSign: chinese,
            essence: user.bio.isEmpty ? archetype.overview : user.bio,
            connectionPrompt: user.prompt1.isEmpty ? "Open" : user.prompt1,
            compatibilityScore: compatibility.totalScore,
            matchStyle: compatibility.style,
            matchReasons: compatibility.reasons,
            frictionNote: compatibility.frictionNote,
            imageName: user.photoFileName ?? "placeholder",
            imageAnchor: .center,
            intent: user.intent.isEmpty ? "Open" : user.intent,
            signals: [user.prompt1, user.prompt2, user.prompt3]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .enumerated()
                .map {
                    ConnectProfileSignal(
                        prompt: ConnectProfileSignal.promptPool[$0.offset % ConnectProfileSignal.promptPool.count],
                        response: $0.element
                    )
                }
        )
    }
}
