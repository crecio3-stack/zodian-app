import Foundation

struct MatchThreadPreview {
    let latestText: String
    let unreadCount: Int

    var hasUnread: Bool {
        unreadCount > 0
    }
}
