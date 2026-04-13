import SwiftUI

struct OnboardingEntryView: View {
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingFlowView()
                    .transition(.opacity)
            } else {
                OnboardingSplashView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showOnboarding = true
                }
            }
        }
    }
}

#Preview("Onboarding Entry") {
    OnboardingEntryView()
        .environmentObject(AppStore())
}
