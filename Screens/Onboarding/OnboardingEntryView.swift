import SwiftUI

struct OnboardingEntryView: View {
    var body: some View {
        OnboardingFlowView()
        .preferredColorScheme(.dark)
    }
}

#Preview("Onboarding Entry") {
    OnboardingEntryView()
        .environmentObject(AppStore())
}
