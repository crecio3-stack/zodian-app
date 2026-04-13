import Foundation
import SwiftData

enum ChatSender: String, Codable {
    case me
    case match
}

@Model
final class ChatMessage {
    var id: UUID
    var createdAt: Date
    var matchID: UUID
    var senderRaw: String
    var text: String
    var isRead: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        matchID: UUID,
        senderRaw: String = ChatSender.me.rawValue,
        text: String,
        isRead: Bool = true
    ) {
        self.id = id
        self.createdAt = createdAt
        self.matchID = matchID
        self.senderRaw = senderRaw
        self.text = text
        self.isRead = isRead
    }

    var sender: ChatSender {
        get { ChatSender(rawValue: senderRaw) ?? .me }
        set { senderRaw = newValue.rawValue }
    }

    var isFromMatch: Bool {
        sender == .match
    }
}
