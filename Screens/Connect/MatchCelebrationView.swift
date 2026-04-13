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

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: ZD.Spacing.l) {
                ZStack {
                    Circle()
                        .fill(ZD.Color.accent.opacity(0.12))
                        .frame(width: 110, height: 110)

                    Circle()
                        .stroke(ZD.Color.accent.opacity(0.28), lineWidth: 1.5)
                        .frame(width: 92, height: 92)

                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(ZD.Color.accent)
                }
                .zGoldGlow(active: true)

                VStack(spacing: 8) {
                    Text("It’s a vibe")
                        .font(ZD.Font.title())
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text("You saved \(name) to your matches.")
                        .font(ZD.Font.body())
                        .foregroundStyle(ZD.Color.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("\(compatibilityScore)% compatibility")
                        .font(ZD.Font.caption(.semibold))
                        .foregroundStyle(ZD.Color.accent)
                }

                PrimaryButton(
                    title: "Keep Exploring",
                    action: onClose,
                    icon: "arrow.right",
                    fullWidth: true
                )
            }
            .padding(ZD.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                    .fill(ZD.Gradient.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: ZD.Radius.xl, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.45), lineWidth: ZD.Stroke.thin)
                    )
            )
            .padding(.horizontal, ZD.Spacing.l)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MatchCelebrationView(
        name: "Selene",
        compatibilityScore: 92,
        onClose: {}
    )
}