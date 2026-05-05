import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if store.onboardingComplete {
                MainTabView()
                    .onAppear {
                        store.loadUserIfNeeded(context: context)
                        store.refreshNotificationScheduling()
                    }
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
    }
}

#Preview("ContentView - Onboarding") {
    let store = AppStore()
    store.onboardingComplete = false

    return ContentView()
        .environmentObject(store)
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
        .modelContainer(for: [UserProfile.self, PointsLedgerItem.self, StreakDay.self])
}
