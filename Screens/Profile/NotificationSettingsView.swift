import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Notifications",
	                    subtitle: "Small nudges to notice today’s pattern"
                )

                TarotCardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        statusRow

                        divider

                        toggleRow(
                            title: "Today’s Lens Reminder",
	                            subtitle: "A reminder to see what today brings into focus",
                            isOn: $store.dailyReminderEnabled
                        )

                        divider

                        toggleRow(
                            title: "Streak Saver",
	                            subtitle: "A later nudge if today’s pattern is still open",
                            isOn: $store.streakSaverEnabled
                        )

                        divider

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Reminder Time")
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)

	                                Text("Choose when the reminder lands")
                                .font(ZD.Font.caption())
                                .foregroundStyle(ZD.Color.muted)

                            DatePicker(
                                "Reminder Time",
                                selection: $store.preferredReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .tint(ZD.Color.accent)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                if store.notificationStatus == .denied {
                    TarotCardContainer {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notifications are off in Settings")
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(ZD.Color.textPrimary)

                            Text("Turn them on there to get reminders again")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, ZD.Spacing.m)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .task {
            await store.refreshNotificationAuthorizationStatus()
        }
        .onChange(of: store.dailyReminderEnabled) { _, enabled in
            if enabled && store.notificationStatus != .authorized {
                store.ensureNotificationPermissionForSettings()
            }
        }
        .onChange(of: store.streakSaverEnabled) { _, enabled in
            if enabled && store.notificationStatus != .authorized {
                store.ensureNotificationPermissionForSettings()
            }
        }
    }

    private var statusRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ZD.Color.accent.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: statusIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ZD.Color.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)

                Text(statusSubtitle)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(ZD.Font.body(.semibold))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(subtitle)
                        .font(ZD.Font.caption())
                        .foregroundStyle(ZD.Color.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(ZD.Color.accent)
            }
        }
    }

    private var statusTitle: String {
        switch store.notificationStatus {
        case .authorized: return "Notifications are on"
        case .denied: return "Notifications are off"
        case .notDetermined: return "Not enabled yet"
        }
    }

    private var statusSubtitle: String {
        switch store.notificationStatus {
	        case .authorized: return "Today’s Lens reminders can show up on this device"
        case .denied: return "Zodian can't send reminders until notifications are allowed"
	        case .notDetermined: return "Turn them on when you want Today’s Lens reminders"
        }
    }

    private var statusIcon: String {
        switch store.notificationStatus {
        case .authorized: return "bell.badge.fill"
        case .denied: return "bell.slash.fill"
        case .notDetermined: return "bell.fill"
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(ZD.Color.border.opacity(0.24))
            .frame(height: 1)
    }
}

struct NotificationPrePromptView: View {
    let onEnable: () -> Void
    let onNotNow: () -> Void

    var body: some View {
        ZD.Color.bg
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 18) {
                    TarotCardContainer {
                        VStack(spacing: 14) {
	                            Text("Keep today in focus")
                                .font(ZD.Font.title())
                                .foregroundStyle(ZD.Color.textPrimary)
                                .multilineTextAlignment(.center)

	                            Text("Get a reminder to notice today’s pattern\nGet a later nudge if you still haven’t")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            PrimaryButton(
                                title: "Turn On",
                                action: onEnable,
                                icon: "bell.badge.fill",
                                fullWidth: true
                            )

                            SecondaryButton(
                                title: "Not Now",
                                action: onNotNow,
                                fullWidth: true
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                }
            }
            .preferredColorScheme(.dark)
    }
}
