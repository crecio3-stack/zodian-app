import SwiftUI

enum ZD {
    enum Color {
        static let bg = SwiftUI.Color(hex: "#0F1111")
        static let bgSecondary = SwiftUI.Color(hex: "#151716")

        static let card = SwiftUI.Color(hex: "#1B1A18")
        static let cardAlt = SwiftUI.Color(hex: "#12201A")
        static let surface = SwiftUI.Color(hex: "#211F1C")

        static let accent = SwiftUI.Color(hex: "#C9A86A")
        static let accentSoft = SwiftUI.Color(hex: "#E2C89A")
        static let premium = SwiftUI.Color(hex: "#E5C97B")

        static let textPrimary = SwiftUI.Color(hex: "#ECE4D8")
        static let textSecondary = SwiftUI.Color(hex: "#CFC4B3")
        static let muted = SwiftUI.Color(hex: "#8F877B")
        static let disabled = SwiftUI.Color(hex: "#6E655C")

        static let olive = SwiftUI.Color(hex: "#4A5847")
        static let forest = SwiftUI.Color(hex: "#0F1A16")
        static let border = SwiftUI.Color(hex: "#7A6742")
        static let divider = SwiftUI.Color(hex: "#2B2A27")

        static let success = SwiftUI.Color(hex: "#8FAF6A")
        static let warning = SwiftUI.Color(hex: "#C78B2A")
        static let error = SwiftUI.Color(hex: "#8E3B3B")

        static let shadow = SwiftUI.Color.black.opacity(0.45)
        static let glow = accentSoft.opacity(0.20)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let sm: CGFloat = 12
        static let m: CGFloat = 16
        static let ml: CGFloat = 20
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
    }

    enum Radius {
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Stroke {
        static let thin: CGFloat = 1
        static let regular: CGFloat = 1.5
        static let strong: CGFloat = 2
    }

    enum Shadow {
        static let cardRadius: CGFloat = 18
        static let cardY: CGFloat = 10

        static let elevatedRadius: CGFloat = 24
        static let elevatedY: CGFloat = 14

        static let glowRadius: CGFloat = 18
        static let glowY: CGFloat = 8
    }

    enum Font {
        static func display() -> SwiftUI.Font {
            .system(size: 34, weight: .regular, design: .serif)
        }

        static func title() -> SwiftUI.Font {
            .system(size: 28, weight: .regular, design: .serif)
        }

        static func heading(_ weight: SwiftUI.Font.Weight = .semibold) -> SwiftUI.Font {
            .system(size: 20, weight: weight, design: .default)
        }

        static func body(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 16, weight: weight, design: .default)
        }

        static func bodyLarge(_ weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: 17, weight: weight, design: .default)
        }

        static func caption(_ weight: SwiftUI.Font.Weight = .medium) -> SwiftUI.Font {
            .system(size: 13, weight: weight, design: .default)
        }

        static func button() -> SwiftUI.Font {
            .system(size: 16, weight: .semibold, design: .default)
        }

        static func badge() -> SwiftUI.Font {
            .system(size: 12, weight: .semibold, design: .default)
        }
    }

    enum Gradient {
        static let card = LinearGradient(
            colors: [
                ZD.Color.card,
                ZD.Color.surface
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let hero = LinearGradient(
            colors: [
                ZD.Color.card,
                ZD.Color.forest,
                ZD.Color.bg
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let gold = LinearGradient(
            colors: [
                ZD.Color.accentSoft,
                ZD.Color.accent
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func zScreenBackground() -> some View {
        background(
            ZD.Color.bg
                .overlay(
                    LinearGradient(
                        colors: [
                            ZD.Color.forest.opacity(0.22),
                            .clear,
                            ZD.Color.card.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
        )
    }

    func zCardStyle(cornerRadius: CGFloat = ZD.Radius.l) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ZD.Gradient.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(ZD.Color.border.opacity(0.55), lineWidth: ZD.Stroke.thin)
                    )
            )
            .shadow(
                color: ZD.Color.shadow,
                radius: ZD.Shadow.cardRadius,
                x: 0,
                y: ZD.Shadow.cardY
            )
    }

    func zGoldGlow(active: Bool = true) -> some View {
        self.shadow(
            color: active ? ZD.Color.glow : .clear,
            radius: active ? ZD.Shadow.glowRadius : 0,
            x: 0,
            y: active ? ZD.Shadow.glowY : 0
        )
    }
}

extension SwiftUI.Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch sanitized.count {
        case 3:
            (a, r, g, b) = (
                255,
                ((int >> 8) & 0xF) * 17,
                ((int >> 4) & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6:
            (a, r, g, b) = (
                255,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        case 8:
            (a, r, g, b) = (
                (int >> 24) & 0xFF,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
