import SwiftUI

struct RefineBirthdateStepView: View {
    @Binding var birthMonth: Int
    @Binding var birthDay: Int
    let availableBirthMonths: [Int]
    let availableBirthDays: [Int]
    let monthName: (Int) -> String
    let onContinue: () -> Void
    let onAppear: () -> Void

    var body: some View {
        OnboardingExperienceView(
            layoutStyle: .arrival,
            parallaxOffset: 0,
            hero: {
                Color.clear.frame(height: 0)
            },
            content: {
                VStack(spacing: 0) {
                    OnboardingHeroHeader(
                        eyebrow: "Refine your identity",
                            title: "Let’s bring it into focus",
                            subtitle: "Your month and day help Zodian read the pattern more clearly",
                        tone: .ritual,
                        isVisible: true,
                        shimmerActive: false,
                        shimmerMode: .singleSweep
                    )
                    .padding(.top, OnboardingHeroMetrics.topSpacing)
                    .padding(.bottom, 16)

                    Spacer(minLength: 8)

                    OnboardingBirthdaySelector(
                        monthSelection: $birthMonth,
                        daySelection: $birthDay,
                        availableMonths: availableBirthMonths,
                        availableDays: availableBirthDays,
                        monthName: monthName,
                        onInteraction: nil
                    )
                    .frame(maxWidth: 336)
                    .offset(y: -20)

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, ZD.Spacing.l)
                .padding(.bottom, OnboardingHeroMetrics.footerReservedHeight)
            },
            footer: {
                AtmosphericCTADock(
                    progress: 1,
                    lagOffset: 0,
                    hitThreshold: 0.6
                ) {
                    PrimaryButton(
                        title: "Continue",
                        action: onContinue,
                        isDisabled: false,
                        icon: nil,
                        fullWidth: true
                    )
                }
            }
        )
        .onAppear(perform: onAppear)
    }
}
