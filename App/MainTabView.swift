import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            BlueprintView()
                .tag(AppTab.blueprint)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Blueprint")
                }

            ConnectView()
                .tag(AppTab.connect)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Connect")
                }

            NavigationStack {
                MatchesView()
            }
            .tag(AppTab.matches)
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Matches")
            }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(ZD.Color.accent)
        .background(ZD.Color.bg.ignoresSafeArea())
    }
}

#Preview("Main Tabs") {
    let store = AppStore()
    store.onboardingComplete = true
    store.points = 120
    store.streak = 6

    let sample = UserProfile(
        name: "Nova",
        birthday: Date(timeIntervalSince1970: 631152000),
        westernSignRaw: "leo",
        chineseSignRaw: "dragon",
        archetypeId: "leo-dragon"
    )
    store.currentUser = sample

    return MainTabView()
        .environmentObject(store)
        .preferredColorScheme(.dark)
}
