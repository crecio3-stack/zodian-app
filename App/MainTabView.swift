import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Lens")
                }

            PatternView()
                .tag(AppTab.blueprint)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Identity")
                }

            ConnectView()
                .tag(AppTab.connect)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Connect")
                }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(ZD.Color.accent)
        .toolbarBackground(ZD.Color.bg.opacity(0.42), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .background(ZD.Color.bg.ignoresSafeArea())
        .overlay {
            if store.showReturningDailyExperienceMessage {
                returningDailyExperienceMessage
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .zIndex(20)
            }
        }
        .overlay(alignment: .top) {
            if store.showFirstDailyReadReinforcement {
                firstDailyReadReinforcement
                    .padding(.top, 18)
                    .padding(.horizontal, ZD.Spacing.l)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .onChange(of: store.showFirstDailyReadReinforcement) { _, isShowing in
            guard isShowing else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    store.dismissFirstDailyReadReinforcement()
                }
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: store.showReturningDailyExperienceMessage)
        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: store.showFirstDailyReadReinforcement)
    }

    private var returningDailyExperienceMessage: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome back.")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("There’s more to discover.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ZD.Color.textPrimary)
                        .lineSpacing(4)

                    Text("Read a more personal Daily Lens, explore your identity in greater depth, and understand the people you save through the redesigned Connect experience.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Everything you saved is still here.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    store.dismissReturningDailyExperienceMessage()
                } label: {
                    Text("See What’s New")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(ZD.Color.accent))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See What’s New")
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(ZD.Color.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(ZD.Color.accent.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, ZD.Spacing.l)
        }
    }

    private var firstDailyReadReinforcement: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ZD.Color.accent)
                .padding(.top, 2)

            Text("Your Identity stays the same.\nTomorrow’s Lens brings a fresh perspective.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ZD.Color.textPrimary)
                .lineSpacing(3)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(ZD.Color.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.24), radius: 16, y: 8)
        )
        .allowsHitTesting(false)
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
        .environmentObject(AccountOwnershipController())
        .preferredColorScheme(.dark)
}
