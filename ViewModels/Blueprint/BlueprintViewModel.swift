import Foundation
import Combine

@MainActor
final class BlueprintViewModel: ObservableObject {
    @Published private(set) var presentation: BlueprintPresentation = .empty

    func refresh(user: UserProfile?, archetype: Archetype?) {
        presentation = BlueprintContentResolver.resolve(user: user, archetype: archetype)
    }
}
