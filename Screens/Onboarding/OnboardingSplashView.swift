import SwiftUI

struct OnboardingSplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var orbitalPulse = false
    @State private var loadingProgress: CGFloat = 0.22

    var body: some View {
        ZStack {
            launchBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                loadingGlyph

                VStack(spacing: 10) {
                    Text("Reading your pattern")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .tracking(0.7)
                        .foregroundStyle(ZD.Color.textSecondary)

                    loadingBar
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            await startLoadingMotion()
        }
    }

    private var launchBackground: some View {
        GeometryReader { proxy in
            Image("zodianLaunchBackground")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .allowsHitTesting(false)
    }

    private var loadingGlyph: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(orbitalPulse ? 0.18 : 0.08),
                            ZD.Color.accent.opacity(orbitalPulse ? 0.22 : 0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 96
                    )
                )
                .frame(width: 170, height: 170)
                .blur(radius: 14)
                .opacity(appeared ? 1 : 0)

            Image("zodianLaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 176, height: 176)
                .scaleEffect(orbitalPulse ? 1.025 : 0.985)
                .shadow(color: ZD.Color.accent.opacity(orbitalPulse ? 0.30 : 0.16), radius: orbitalPulse ? 28 : 16)
                .shadow(color: Color.black.opacity(0.30), radius: 18, y: 12)
        }
        .frame(width: 240, height: 240)
    }

    private var loadingBar: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .continuous)
                .fill(ZD.Color.cardAlt.opacity(0.72))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(ZD.Color.border.opacity(0.22), lineWidth: 1)
                )

            Capsule(style: .continuous)
                .fill(ZD.Gradient.gold)
                .frame(width: 160 * loadingProgress)
                .shadow(color: ZD.Color.accent.opacity(0.26), radius: 12)
        }
        .frame(width: 160, height: 5)
        .opacity(0.9)
    }

    @MainActor
    private func startLoadingMotion() async {
        withAnimation(.easeOut(duration: 0.55)) {
            appeared = true
        }

        let progressDuration = reduceMotion ? 0.65 : 1.25
        withAnimation(.easeOut(duration: progressDuration)) {
            loadingProgress = 1
        }

        guard !reduceMotion else { return }

        withAnimation(.easeInOut(duration: 1.65).repeatForever(autoreverses: true)) {
            orbitalPulse = true
        }

        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1_350_000_000)
        }
    }
}

#Preview("Onboarding Splash") {
    OnboardingSplashView()
        .preferredColorScheme(.dark)
}
