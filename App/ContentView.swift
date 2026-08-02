import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.onboardingComplete {
#if DEBUG || BETA
                if ProcessInfo.processInfo.arguments.contains("-ZodianOpenIdentityProfile") {
                    PatternView()
                } else {
                    mainApplicationTabs
                }
#else
                mainApplicationTabs
#endif
            } else {
                OnboardingEntryView()
            }
        }
        .sheet(isPresented: $store.showNotificationPrePrompt) {
            NotificationPrePromptView(
                onEnable: { store.requestNotificationPermissionFromPrePrompt() },
                onNotNow: { store.dismissNotificationPrePrompt() }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .zScreenBackground()
        .preferredColorScheme(.dark)
        .onAppear {
            if let identifier = NotificationService.consumePendingDailyReadNotificationIdentifier() {
                store.openDailyReadFromNotification(identifier: identifier)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NotificationService.notificationOpened)) { notification in
            guard let identifier = NotificationService.consumePendingDailyReadNotificationIdentifier()
                ?? notification.object as? String else { return }
            store.openDailyReadFromNotification(identifier: identifier)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            store.refreshDailyReadAvailabilityForCurrentDay(context: context)
        }
    }

    private var mainApplicationTabs: some View {
        MainTabView()
            .onAppear {
                store.loadUserIfNeeded(context: context)
                if store.currentUser == nil {
                    store.resetEphemeralStateForRecovery()
                }
                store.refreshDailyReadAvailabilityForCurrentDay(context: context)
                store.refreshNotificationScheduling()
            }
    }
}

#Preview("ContentView - Onboarding") {
    let store = AppStore()
    store.onboardingComplete = false

    return ContentView()
        .environmentObject(store)
        .environmentObject(AccountOwnershipController())
        .modelContainer(for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self])
}

#Preview("ContentView - Main App") {
    let store = AppStore()
    store.onboardingComplete = true
    store.points = 120
    store.streak = 5

    let sample = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 631152000),
        westernSignRaw: "leo",
        chineseSignRaw: "dragon",
        archetypeId: "leo-dragon"
    )
    store.currentUser = sample

    return ContentView()
        .environmentObject(store)
        .environmentObject(AccountOwnershipController())
        .modelContainer(for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self])
}
