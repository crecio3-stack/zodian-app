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
    var signalsRaw: String = ""

    var imageName: String = ""
    var imageAnchorRaw: String = "center"

    var primaryReasonTitle: String = ""
    var primaryReasonDetail: String = ""
    var secondaryReasonTitle: String = ""
    var secondaryReasonDetail: String = ""

    var firstMessageSentAt: Date?
    var firstMessageDeadline: Date?

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
        signalsRaw: String = "",
        imageName: String = "",
        imageAnchorRaw: String = "center",
        primaryReasonTitle: String = "",
        primaryReasonDetail: String = "",
        secondaryReasonTitle: String = "",
        secondaryReasonDetail: String = "",
        firstMessageSentAt: Date? = nil,
        firstMessageDeadline: Date? = nil
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
        self.signalsRaw = signalsRaw
        self.imageName = imageName
        self.imageAnchorRaw = imageAnchorRaw
        self.primaryReasonTitle = primaryReasonTitle
        self.primaryReasonDetail = primaryReasonDetail
        self.secondaryReasonTitle = secondaryReasonTitle
        self.secondaryReasonDetail = secondaryReasonDetail
        self.firstMessageSentAt = firstMessageSentAt
        self.firstMessageDeadline = firstMessageDeadline ?? Self.defaultFirstMessageDeadline(from: createdAt)
    }

    var displayArchetypeTitle: String {
        archetypeTitle.isEmpty ? "Aligned Match" : archetypeTitle
    }

    var chatImageName: String {
        imageName.isEmpty ? "zodianMark" : imageName
    }

    var signals: [ConnectProfileSignal] {
        ConnectProfileSignal.parseRaw(signalsRaw)
    }

    var hasSentFirstMessage: Bool {
        firstMessageSentAt != nil
    }

    var firstMessageDeadlineDate: Date {
        firstMessageDeadline ?? Self.defaultFirstMessageDeadline(from: createdAt)
    }

    var isAwaitingFirstMessage: Bool {
        !hasSentFirstMessage
    }

    var isFirstMessageAtRisk: Bool {
        isAwaitingFirstMessage && Date() >= firstMessageDeadlineDate
    }

    var firstMessageWindowText: String {
        if hasSentFirstMessage {
            return "Thread opened"
        }

        let remainingSeconds = firstMessageDeadlineDate.timeIntervalSince(Date())
        guard remainingSeconds > 0 else {
            return "At risk"
        }

        let remainingHours = Int(ceil(remainingSeconds / 3600))
        if remainingHours >= 24 {
            return "Message today"
        }

        return "\(max(1, remainingHours))h left"
    }

    static func defaultFirstMessageDeadline(from date: Date) -> Date {
        date.addingTimeInterval(24 * 60 * 60)
    }
}
