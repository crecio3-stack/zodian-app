import SwiftUI

struct OnboardingSplashView: View {
    @State private var flipAngle: Double = 0
    @State private var glow = false

    var body: some View {
        ZStack {
            ZD.Color.bg
                .overlay(
                    LinearGradient(
                        colors: [
                            ZD.Color.forest.opacity(0.18),
                            .clear,
                            ZD.Color.card.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.08),
                            .clear
                        ],
                        center: .top,
                        startRadius: 10,
                        endRadius: 420
                    )
                )
                .ignoresSafeArea()

            ZStack {
                Image("zodianMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 112)
                    .blur(radius: glow ? 24 : 12)
                    .opacity(glow ? 0.22 : 0.10)

                Image("zodianMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .rotation3DEffect(
                        .degrees(flipAngle),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.75
                    )
                    .scaleEffect(glow ? 1.02 : 0.98)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                glow = true
            }

            flipAngle = 0
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                flipAngle = 360
            }
        }
    }
}

#Preview("Onboarding Splash") {
    OnboardingSplashView()
        .preferredColorScheme(.dark)
}
