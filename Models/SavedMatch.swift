import Foundation
import SwiftData

@Model
final class SavedMatch {
    var id: UUID = UUID()
    var createdAt: Date = Date()

    var name: String
    var archetypeId: String
    var archetypeTitle: String = ""

    var westernSignRaw: String
    var chineseSignRaw: String

    var compatibilityScore: Int
    var matchStyleRaw: String = ""

    var essence: String = ""
    var connectionPrompt: String = ""
    var frictionNote: String = ""
    var intent: String = ""

    var imageName: String = ""
    var imageAnchorRaw: String = "center"

    var primaryReasonTitle: String = ""
    var primaryReasonDetail: String = ""

    init(
        name: String,
        archetypeId: String,
        archetypeTitle: String = "",
        westernSignRaw: String,
        chineseSignRaw: String,
        compatibilityScore: Int,
        matchStyleRaw: String = "",
        essence: String = "",
        connectionPrompt: String = "",
        frictionNote: String = "",
        intent: String = "",
        imageName: String = "",
        imageAnchorRaw: String = "center",
        primaryReasonTitle: String = "",
        primaryReasonDetail: String = ""
    ) {
        self.name = name
        self.archetypeId = archetypeId
        self.archetypeTitle = archetypeTitle
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.compatibilityScore = compatibilityScore
        self.matchStyleRaw = matchStyleRaw
        self.essence = essence
        self.connectionPrompt = connectionPrompt
        self.frictionNote = frictionNote
        self.intent = intent
        self.imageName = imageName
        self.imageAnchorRaw = imageAnchorRaw
        self.primaryReasonTitle = primaryReasonTitle
        self.primaryReasonDetail = primaryReasonDetail
    }

    var displayArchetypeTitle: String {
        archetypeTitle.isEmpty ? "Aligned Match" : archetypeTitle
    }

    var chatImageName: String {
        imageName.isEmpty ? "zodianMark" : imageName
    }
}
