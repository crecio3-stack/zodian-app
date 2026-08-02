//
//  MatchCelebrationView.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//


import SwiftUI

struct MatchCelebrationView: View {
    let name: String
    let compatibilityScore: Int
    let onClose: () -> Void

    @State private var hasAppeared = false
    @State private var pulseIcon = false
    @State private var showScore = false
    @State private var showCTA = false

    private var presentation: ConnectCelebrationPresentation {
        ConnectPresentationBuilder.buildCelebration(
            name: name,
            compatibilityScore: compatibilityScore
        )
    }

    var body: some View {
        ZStack {
            Color.black.opacity(hasAppeared ? 0.55 : 0)
                .animation(.easeOut(duration: 0.18), value: hasAppeared)
                .ignoresSafeArea()

            VStack(spacing: ZD.Spacing.m) {
                ZStack {
                    Circle()
                        .fill(ZD.Color.accent.opacity(pulseIcon ? 0.16 : 0.1))
                        .frame(width: 98, height: 98)
                        .scaleEffect(pulseIcon ? 1.04 : 0.96)

                    Circle()
                        .stroke(ZD.Color.accent.opacity(pulseIcon ? 0.32 : 0.24), lineWidth: 1.5)
                        .frame(width: 82, height: 82)
                        .scaleEffect(pulseIcon ? 1.02 : 0.96)

                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(ZD.Color.accent)
                }
                .zGoldGlow(active: true)
                .animation(.spring(response: 0.40, dampingFraction: 0.70), value: pulseIcon)

                VStack(spacing: 6) {
                    Text(presentation.title)
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(presentation.message)
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .multilineTextAlignment(.center)

                    Text(presentation.compatibilityText)
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                        .opacity(showScore ? 1 : 0)

                    Text("Start the thread if you want to understand what you noticed")
                        .font(ZD.Font.caption(.medium))
                        .foregroundStyle(ZD.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                        .opacity(showScore ? 1 : 0)
                }

                if showCTA {
                    PrimaryButton(
                        title: "Continue",
                        action: onClose,
                        icon: "arrow.right",
                        fullWidth: true
                    )
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, ZD.Spacing.xl)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(ZD.Gradient.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.34), lineWidth: ZD.Stroke.thin)
                    )
            )
            .padding(.horizontal, ZD.Spacing.l)
            .scaleEffect(hasAppeared ? 1 : 0.96)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.spring(response: 0.34, dampingFraction: 0.84), value: hasAppeared)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            hasAppeared = true

            DispatchQueue.main.async {
                pulseIcon = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                showScore = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                showCTA = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                pulseIcon = false
            }
        }
    }
}

#Preview {
    MatchCelebrationView(
        name: "Selene",
        compatibilityScore: 92,
        onClose: {}
    )
}
