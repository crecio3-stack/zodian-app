import Foundation
import UserNotifications

struct NotificationScheduleContext {
    let dailyReminderEnabled: Bool
    let streakSaverEnabled: Bool
    let preferredReminderTime: Date
    let streak: Int
    let ritualCompletedToday: Bool
    let skyTone: String?
    let westernSign: String?
    let easternSign: String?
}

enum ZodianNotificationStatus: String {
    case notDetermined
    case denied
    case authorized
}

enum NotificationService {
    static let dailyPullIdentifier = "zodian.dailyPull"
    static let dailyReadyBadgeIdentifier = "zodian.dailyReadyBadge"
    static let streakSaverIdentifier = "zodian.streakSaver"
    static let notificationOpened = Notification.Name("zodian.notificationOpened")
    private static let dailyPullLookaheadDays = 7
    private static let pendingDailyReadNotificationIdentifierKey = "zodian.pendingDailyReadNotificationIdentifier"
    private static let notificationSelectionPrefix = "zodian.notificationSelection"
    private static let recentNotificationIDsKey = "zodian.recentNotificationIDs"
    private static let recentNotificationLimit = 45

    static func recordDailyReadNotificationOpen(identifier: String) {
        UserDefaults.standard.set(identifier, forKey: pendingDailyReadNotificationIdentifierKey)
        NotificationCenter.default.post(name: notificationOpened, object: identifier)
    }

    static func consumePendingDailyReadNotificationIdentifier() -> String? {
        let defaults = UserDefaults.standard
        guard let identifier = defaults.string(forKey: pendingDailyReadNotificationIdentifierKey) else {
            return nil
        }

        defaults.removeObject(forKey: pendingDailyReadNotificationIdentifierKey)
        return identifier
    }

    static func clearAppBadge() {
        setDailyReadBadge(isWaiting: false)
    }

    static func clearAllScheduledAndDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        clearAppBadge()

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: pendingDailyReadNotificationIdentifierKey)
        defaults.removeObject(forKey: recentNotificationIDsKey)
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(notificationSelectionPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    static func setDailyReadBadge(isWaiting: Bool) {
        UNUserNotificationCenter.current().setBadgeCount(isWaiting ? 1 : 0)
    }

    static func authorizationStatus() async -> ZodianNotificationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            OperationalLogger.error(
                OperationalError(
                    kind: .permission,
                    category: .notifications,
                    code: "authorization_request_failed",
                    underlyingError: error
                )
            )
            return false
        }
    }

    static func refreshSchedules(using context: NotificationScheduleContext, now: Date = Date()) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: pendingNotificationIdentifiers(now: now, lookaheadDays: dailyPullLookaheadDays) + [streakSaverIdentifier]
        )

        guard await authorizationStatus() == .authorized else { return }

        if context.dailyReminderEnabled {
            let badgeRequests = await dailyReadyBadgeRequests(using: context, now: now)
            for request in badgeRequests {
                try? await center.add(request)
            }

            let requests = await dailyPullRequests(using: context, now: now)
            for request in requests {
                try? await center.add(request)
            }
        }

        if context.streakSaverEnabled && !context.ritualCompletedToday,
           let request = streakSaverRequest(using: context, now: now) {
            try? await center.add(request)
        }
    }

    private static func dailyReadyBadgeRequests(
        using context: NotificationScheduleContext,
        now: Date
    ) async -> [UNNotificationRequest] {
        let availableDates = await availableLensDates(
            upcomingDailyReadyBadgeDates(
            now: now,
            lookaheadDays: dailyPullLookaheadDays,
            skipTodayIfCompleted: context.ritualCompletedToday
            ),
            context: context
        )
        return availableDates.map { date in
            let content = UNMutableNotificationContent()
            content.badge = 1
            content.userInfo = ["zodian_destination": "daily_read"]

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            return UNNotificationRequest(
                identifier: dailyReadyBadgeIdentifier(for: date),
                content: content,
                trigger: trigger
            )
        }
    }

    private static func dailyPullRequests(
        using context: NotificationScheduleContext,
        now: Date
    ) async -> [UNNotificationRequest] {
        let availableDates = await availableLensDates(
            upcomingDailyReminderDates(
            preferredReminderTime: context.preferredReminderTime,
            now: now,
            lookaheadDays: dailyPullLookaheadDays,
            skipTodayIfCompleted: context.ritualCompletedToday
            ),
            context: context
        )
        return availableDates.enumerated().map { index, date in
            let content = dailyPullContent(
                date: date,
                streak: context.streak,
                skyTone: context.skyTone,
                occurrenceIndex: index
            )

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            return UNNotificationRequest(
                identifier: dailyPullIdentifier(for: date),
                content: content,
                trigger: trigger
            )
        }
    }

    private static func availableLensDates(
        _ dates: [Date],
        context: NotificationScheduleContext
    ) async -> [Date] {
        guard let westernSign = context.westernSign,
              let easternSign = context.easternSign else {
            return []
        }

        var available: [Date] = []
        for date in dates {
#if DEBUG
            if DailyLensCandidateRuntimeFixture.isEditorialVoiceV21Amendment1Enabled {
                if DailyLensCandidateRuntimeFixture.editorialVoiceV21Amendment1CandidateIsAvailable(
                    date: dailyIdentifierDateString(for: date),
                    westernSign: westernSign,
                    easternSign: easternSign
                ) {
                    available.append(date)
                }
                continue
            }
#endif
            if await DailyRitualService.shared.hasAvailableTodaysLens(
                date: date,
                westernSign: westernSign,
                easternSign: easternSign
            ) {
                available.append(date)
            }
        }
        return available
    }

    private static func dailyPullContent(
        date: Date,
        streak: Int,
        skyTone: String?,
        occurrenceIndex: Int
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let variant = notificationVariant(
            date: date,
            channel: "daily",
            occurrenceIndex: occurrenceIndex
        )
        content.title = variant.title
        content.body = variant.body
        content.sound = .default
        content.badge = 1
        content.userInfo = ["zodian_destination": "daily_read"]

        return content
    }

    private static func streakSaverRequest(using context: NotificationScheduleContext, now: Date) -> UNNotificationRequest? {
        guard let fireDate = nextStreakSaverDate(preferredReminderTime: context.preferredReminderTime, now: now) else {
            return nil
        }

        let content = UNMutableNotificationContent()
        let variant = notificationVariant(
            date: fireDate,
            channel: "streak",
            occurrenceIndex: context.streak
        )
        content.title = variant.title
        content.body = variant.body
        content.sound = .default
        content.badge = 1
        content.userInfo = ["zodian_destination": "daily_read"]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(identifier: streakSaverIdentifier, content: content, trigger: trigger)
    }

    private static func nextStreakSaverDate(preferredReminderTime: Date, now: Date) -> Date? {
        let calendar = Calendar.current
        let reminderComponents = calendar.dateComponents([.hour, .minute], from: preferredReminderTime)
        let reminderHour = reminderComponents.hour ?? 9
        let reminderMinute = reminderComponents.minute ?? 0

        let baseMinutes = reminderHour * 60 + reminderMinute
        let saverMinutes = min(max(baseMinutes + 600, 18 * 60), 21 * 60)

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = saverMinutes / 60
        components.minute = saverMinutes % 60

        guard let candidate = calendar.date(from: components), candidate > now else {
            return nil
        }

        return candidate
    }

    private static func notificationVariant(
        date: Date,
        channel: String,
        occurrenceIndex: Int
    ) -> (title: String, body: String) {
        let selectionKey = "\(notificationSelectionPrefix).\(channel).\(dailyIdentifierDateString(for: date))"
        let defaults = UserDefaults.standard

        if let selectedID = defaults.string(forKey: selectionKey),
           let selected = notificationLibrary.first(where: { $0.id == selectedID }) {
            return selected.display
        }

        let seed = calendarDaySeed(date) + occurrenceIndex + stableSeed(for: channel)
        let preferredCategory = notificationCategories[abs(seed) % notificationCategories.count]
        let categoryPool = notificationLibrary.filter { $0.category == preferredCategory }
        let basePool = categoryPool.isEmpty ? notificationLibrary : categoryPool
        let recentIDs = defaults.stringArray(forKey: recentNotificationIDsKey) ?? []
        let freshPool = basePool.filter { !recentIDs.contains($0.id) }
        let pool = freshPool.isEmpty ? notificationLibrary.filter { !recentIDs.contains($0.id) } : freshPool
        let finalPool = pool.isEmpty ? notificationLibrary : pool
        let selected = finalPool[abs(seed) % finalPool.count]

        defaults.set(selected.id, forKey: selectionKey)
        rememberNotificationID(selected.id)
        return selected.display
    }

    private static func rememberNotificationID(_ id: String) {
        let defaults = UserDefaults.standard
        var ids = defaults.stringArray(forKey: recentNotificationIDsKey) ?? []
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        if ids.count > recentNotificationLimit {
            ids = Array(ids.prefix(recentNotificationLimit))
        }
        defaults.set(ids, forKey: recentNotificationIDsKey)
    }

    private static func upcomingDailyReminderDates(
        preferredReminderTime: Date,
        now: Date,
        lookaheadDays: Int,
        skipTodayIfCompleted: Bool
    ) -> [Date] {
        let calendar = Calendar.current
        let reminderComponents = calendar.dateComponents([.hour, .minute], from: preferredReminderTime)
        let reminderHour = reminderComponents.hour ?? 9
        let reminderMinute = reminderComponents.minute ?? 0

        let currentDay = calendar.startOfDay(for: now)
        let startOffset = skipTodayIfCompleted ? 1 : 0

        return (startOffset..<(startOffset + lookaheadDays)).compactMap { dayOffset in
            guard let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: currentDay) else {
                return nil
            }

            var components = calendar.dateComponents([.year, .month, .day], from: targetDay)
            components.hour = reminderHour
            components.minute = reminderMinute

            guard let scheduledDate = calendar.date(from: components), scheduledDate > now else {
                return nil
            }

            return scheduledDate
        }
    }

    private static func upcomingDailyReadyBadgeDates(
        now: Date,
        lookaheadDays: Int,
        skipTodayIfCompleted: Bool
    ) -> [Date] {
        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: now)
        let startOffset = skipTodayIfCompleted ? 1 : 0

        return (startOffset..<(startOffset + lookaheadDays)).compactMap { dayOffset in
            guard let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: currentDay) else {
                return nil
            }

            var components = calendar.dateComponents([.year, .month, .day], from: targetDay)
            components.hour = 0
            components.minute = 1

            guard let scheduledDate = calendar.date(from: components), scheduledDate > now else {
                return nil
            }

            return scheduledDate
        }
    }

    private static func pendingNotificationIdentifiers(now: Date, lookaheadDays: Int) -> [String] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)

        return (0..<lookaheadDays).flatMap { offset -> [String] in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                return []
            }

            return [
                dailyPullIdentifier(for: date),
                dailyReadyBadgeIdentifier(for: date)
            ]
        }
    }

    private static func dailyPullIdentifier(for date: Date) -> String {
        "\(dailyPullIdentifier).\(dailyIdentifierDateString(for: date))"
    }

    private static func dailyReadyBadgeIdentifier(for date: Date) -> String {
        "\(dailyReadyBadgeIdentifier).\(dailyIdentifierDateString(for: date))"
    }

    private static func dailyIdentifierDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }

    private static func calendarDaySeed(_ date: Date) -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        return year * 400 + dayOfYear
    }

    private static func stableSeed(for input: String) -> Int {
        input.unicodeScalars.reduce(0) { partial, scalar in
            ((partial * 31) + Int(scalar.value)) % 1_000_003
        }
    }

    private struct NotificationLine {
        let id: String
        let category: String
        let title: String
        let body: String

        var display: (title: String, body: String) {
            (title, body)
        }
    }

    private static let notificationCategories = [
        "call-out",
        "curiosity",
        "best-friend",
        "lens-bridge"
    ]

    private static let notificationLibrary: [NotificationLine] = [
        NotificationLine(id: "call-out-01", category: "call-out", title: "You’re doing it again.", body: "Today’s Lens is ready. See what today brings into focus."),
        NotificationLine(id: "call-out-02", category: "call-out", title: "You almost missed this.", body: "Today’s Lens is ready. A new Lens is waiting."),
        NotificationLine(id: "call-out-03", category: "call-out", title: "That thing you noticed?", body: "Today’s Lens is ready. It may have something to say about it."),
        NotificationLine(id: "call-out-04", category: "call-out", title: "Do not pretend you missed it.", body: "Today’s Lens is ready. See what today brings up."),
        NotificationLine(id: "call-out-05", category: "call-out", title: "The day has a tell.", body: "Today’s Lens is ready. Your personal Lens is waiting."),
        NotificationLine(id: "call-out-06", category: "call-out", title: "You know this mood.", body: "Today’s Lens is ready. See what the Lens makes of it."),

        NotificationLine(id: "curiosity-01", category: "curiosity", title: "Something feels different today.", body: "Today’s Lens is ready. A new Lens is waiting."),
        NotificationLine(id: "curiosity-02", category: "curiosity", title: "There’s a twist in this one.", body: "Today’s Lens is ready. See what today brings into focus."),
        NotificationLine(id: "curiosity-03", category: "curiosity", title: "This day has an angle.", body: "Today’s Lens is ready. A new Lens. A new perspective."),
        NotificationLine(id: "curiosity-04", category: "curiosity", title: "One detail may matter.", body: "Today’s Lens is ready to read."),
        NotificationLine(id: "curiosity-05", category: "curiosity", title: "The interesting part is small.", body: "Today’s Lens is ready. See what it catches."),
        NotificationLine(id: "curiosity-06", category: "curiosity", title: "Today has a little edge.", body: "Today’s Lens is ready. Your personal Lens is waiting."),

        NotificationLine(id: "best-friend-01", category: "best-friend", title: "Okay, this one is very you.", body: "Today’s Lens is ready. A new Lens is waiting."),
        NotificationLine(id: "best-friend-02", category: "best-friend", title: "I would read this.", body: "Today’s Lens is ready. See what today brings into focus."),
        NotificationLine(id: "best-friend-03", category: "best-friend", title: "This feels relevant.", body: "Today’s Lens is ready. A new Lens is waiting."),
        NotificationLine(id: "best-friend-04", category: "best-friend", title: "You may want to see this.", body: "Today’s Lens is ready. Your personal Lens is here."),
        NotificationLine(id: "best-friend-05", category: "best-friend", title: "This one has your name on it.", body: "Today’s Lens is ready. See what your Lens says about today."),
        NotificationLine(id: "best-friend-06", category: "best-friend", title: "Not to be dramatic, but read it.", body: "Today’s Lens is ready. A new Lens is waiting."),

        NotificationLine(id: "lens-bridge-01", category: "lens-bridge", title: "Today’s Lens is ready.", body: "Your personal Lens is waiting."),
        NotificationLine(id: "lens-bridge-02", category: "lens-bridge", title: "Today’s Lens is ready.", body: "Today’s Lens brings the day into focus."),
        NotificationLine(id: "lens-bridge-03", category: "lens-bridge", title: "A new Lens just opened.", body: "Your personal Lens is ready."),
        NotificationLine(id: "lens-bridge-04", category: "lens-bridge", title: "Today has a read.", body: "Today’s Lens is ready. See what it brings up."),
        NotificationLine(id: "lens-bridge-05", category: "lens-bridge", title: "Today’s Lens is here.", body: "Today’s Lens is ready when you are."),
        NotificationLine(id: "lens-bridge-06", category: "lens-bridge", title: "A new day, a new Lens.", body: "Your personal Lens is ready.")
    ]
}
