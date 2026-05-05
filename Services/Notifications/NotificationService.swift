import Foundation
import UserNotifications

struct NotificationScheduleContext {
    let dailyReminderEnabled: Bool
    let streakSaverEnabled: Bool
    let preferredReminderTime: Date
    let streak: Int
    let ritualCompletedToday: Bool
    let skyTone: String?
}

enum ZodianNotificationStatus: String {
    case notDetermined
    case denied
    case authorized
}

enum NotificationService {
    static let dailyPullIdentifier = "zodian.dailyPull"
    static let streakSaverIdentifier = "zodian.streakSaver"
    private static let dailyPullLookaheadDays = 7

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
            print("Failed requesting notifications authorization: \(error)")
            return false
        }
    }

    static func refreshSchedules(using context: NotificationScheduleContext, now: Date = Date()) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: pendingNotificationIdentifiers(now: now, lookaheadDays: dailyPullLookaheadDays) + [streakSaverIdentifier])

        guard await authorizationStatus() == .authorized else { return }

        if context.dailyReminderEnabled {
            let requests = dailyPullRequests(using: context, now: now)
            for request in requests {
                try? await center.add(request)
            }
        }

        if context.streakSaverEnabled && !context.ritualCompletedToday,
           let request = streakSaverRequest(using: context, now: now) {
            try? await center.add(request)
        }
    }

    private static func dailyPullRequests(using context: NotificationScheduleContext, now: Date) -> [UNNotificationRequest] {
        upcomingDailyReminderDates(
            preferredReminderTime: context.preferredReminderTime,
            now: now,
            lookaheadDays: dailyPullLookaheadDays,
            skipTodayIfCompleted: context.ritualCompletedToday
        )
        .enumerated()
        .map { index, date in
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

    private static func dailyPullContent(
        date: Date,
        streak: Int,
        skyTone: String?,
        occurrenceIndex: Int
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let variant = dailyPullVariant(
            date: date,
            streak: streak,
            skyTone: skyTone,
            occurrenceIndex: occurrenceIndex
        )
        content.title = variant.title
        content.body = variant.body
        content.sound = .default

        return content
    }

    private static func streakSaverRequest(using context: NotificationScheduleContext, now: Date) -> UNNotificationRequest? {
        guard let fireDate = nextStreakSaverDate(preferredReminderTime: context.preferredReminderTime, now: now) else {
            return nil
        }

        let content = UNMutableNotificationContent()
        let variant = streakSaverVariant(streak: context.streak, skyTone: context.skyTone)
        content.title = variant.title
        content.body = variant.body
        content.sound = .default

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

    private static func dailyPullVariant(
        date: Date,
        streak: Int,
        skyTone: String?,
        occurrenceIndex: Int
    ) -> (title: String, body: String) {
        let variants: [(title: String, body: String)] = [
            ("Today's read is waiting.", "Open Zodian and see what the day is saying."),
            ("Your daily read is ready.", "Finish it and keep your thread moving."),
            ("The pattern is ready.", "Open the app and read today before it slips by."),
            ("Still time to check today.", "Your read is waiting when you are."),
            ("Before the day is gone.", "Open today's read and lock it in."),
            ("Come back to your pattern.", "A few minutes now can keep the day clear.")
        ]

        let toneOffset: Int
        switch skyTone?.lowercased() {
        case "bold":
            toneOffset = 1
        case "deep":
            toneOffset = 2
        case "social":
            toneOffset = 3
        default:
            toneOffset = 0
        }

        let seed = calendarDaySeed(date) + streak + occurrenceIndex + toneOffset
        let index = abs(seed) % variants.count
        return variants[index]
    }

    private static func streakSaverVariant(streak: Int, skyTone: String?) -> (title: String, body: String) {
        if streak >= 7 {
            return ("Keep the thread going.", "You are one read away from holding today's read.")
        }

        let variants: [(title: String, body: String)] = [
            ("Still time to finish today.", "Open Zodian and lock in today's read."),
            ("Don't leave today unfinished.", "There is still room to keep the thread going."),
            ("Your streak can still hold.", "Open the app and finish today's read."),
            ("One more read keeps it going.", "You still have time to close the day out.")
        ]

        let toneOffset: Int
        switch skyTone?.lowercased() {
        case "bold":
            toneOffset = 1
        case "deep":
            toneOffset = 2
        case "social":
            toneOffset = 3
        default:
            toneOffset = 0
        }

        let index = abs(streak + toneOffset) % variants.count
        return variants[index]
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

    private static func pendingNotificationIdentifiers(now: Date, lookaheadDays: Int) -> [String] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)

        return (0..<lookaheadDays).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                return nil
            }

            return dailyPullIdentifier(for: date)
        }
    }

    private static func dailyPullIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd"
        return "\(dailyPullIdentifier).\(formatter.string(from: date))"
    }

    private static func calendarDaySeed(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .dayOfYear], from: date)
        return (components.year ?? 0) * 400 + (components.dayOfYear ?? 0)
    }
}
