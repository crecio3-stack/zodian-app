import SwiftUI

struct OnboardingSplashView: View {
    @State private var auraPulse = false
    @State private var orbitRotation = 0.0
    @State private var markLifted = false

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
                .overlay(backgroundGrain)
                .ignoresSafeArea()

            ZStack {
                ambientHalo

                orbitRing(size: 188, opacity: 0.18, lineWidth: 1.1)
                    .rotationEffect(.degrees(orbitRotation))

                orbitRing(size: 232, opacity: 0.10, lineWidth: 0.9)
                    .rotationEffect(.degrees(-orbitRotation * 0.58))

                Image("zodianMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
                    .shadow(color: ZD.Color.glow.opacity(0.42), radius: 22, x: 0, y: 10)
                    .scaleEffect(markLifted ? 1.02 : 0.985)
                    .opacity(0.98)

                shimmerSweep
            }
            .frame(width: 270, height: 270)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                auraPulse.toggle()
            }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                orbitRotation = 360
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                markLifted.toggle()
            }
        }
    }

    private var ambientHalo: some View {
        ZStack {
            Circle()
                .fill(ZD.Color.accent.opacity(auraPulse ? 0.18 : 0.10))
                .frame(width: auraPulse ? 182 : 156, height: auraPulse ? 182 : 156)
                .blur(radius: auraPulse ? 34 : 28)

            Circle()
                .fill(ZD.Color.forest.opacity(auraPulse ? 0.10 : 0.06))
                .frame(width: 228, height: 228)
                .blur(radius: 54)
        }
    }

    private func orbitRing(size: CGFloat, opacity: Double, lineWidth: CGFloat) -> some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.06),
                        ZD.Color.accent.opacity(opacity),
                        Color.white.opacity(0.04),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: lineWidth
            )
            .frame(width: size, height: size)
    }

    private var shimmerSweep: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.clear)
            .overlay {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.white.opacity(0.04),
                                    Color.white.opacity(0.14),
                                    Color.white.opacity(0.04),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 86, height: proxy.size.height + 26)
                        .rotationEffect(.degrees(12))
                        .offset(x: auraPulse ? proxy.size.width * 0.44 : -proxy.size.width * 0.44)
                }
            }
            .frame(width: 118, height: 118)
            .mask {
                Image("zodianMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
            }
            .blendMode(.screen)
            .allowsHitTesting(false)
    }

    private var backgroundGrain: some View {
        Color.white
            .opacity(0.014)
            .blendMode(.overlay)
    }
}

#Preview("Onboarding Splash") {
    OnboardingSplashView()
        .preferredColorScheme(.dark)
}
