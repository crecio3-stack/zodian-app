import SwiftUI

struct PremiumConstellationPath: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }

        path.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))

        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
        }

        return path
    }
}

struct StaticConvergenceBridge: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            let mainPoints: [CGPoint] = [
                CGPoint(x: 0.16, y: 0.56),
                CGPoint(x: 0.30, y: 0.44),
                CGPoint(x: 0.45, y: 0.36),
                CGPoint(x: 0.58, y: 0.40),
                CGPoint(x: 0.72, y: 0.34),
                CGPoint(x: 0.84, y: 0.46)
            ]

            let upperBranch: [CGPoint] = [
                CGPoint(x: 0.45, y: 0.36),
                CGPoint(x: 0.52, y: 0.24),
                CGPoint(x: 0.60, y: 0.16)
            ]

            let lowerBranch: [CGPoint] = [
                CGPoint(x: 0.45, y: 0.36),
                CGPoint(x: 0.48, y: 0.54),
                CGPoint(x: 0.52, y: 0.66)
            ]

            ZStack {
                PremiumConstellationPath(points: mainPoints)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.16),
                                Color.white.opacity(0.20),
                                ZD.Color.accent.opacity(0.14)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round)
                    )

                PremiumConstellationPath(points: upperBranch)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.10),
                                Color.white.opacity(0.14)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        style: StrokeStyle(lineWidth: 0.9, lineCap: .round, lineJoin: .round)
                    )

                PremiumConstellationPath(points: lowerBranch)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ZD.Color.accent.opacity(0.10),
                                Color.white.opacity(0.14)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 0.9, lineCap: .round, lineJoin: .round)
                    )

                ForEach(Array(mainPoints.enumerated()), id: \.offset) { index, point in
                    node(
                        x: point.x * size.width,
                        y: point.y * size.height,
                        size: index == 2 || index == 3 ? 5.8 : 4.4,
                        bright: index == 2 || index == 4
                    )
                }

                ForEach(Array(upperBranch.enumerated()), id: \.offset) { index, point in
                    node(
                        x: point.x * size.width,
                        y: point.y * size.height,
                        size: index == 1 ? 4.8 : 4.0,
                        bright: index == 1
                    )
                }

                ForEach(Array(lowerBranch.enumerated()), id: \.offset) { index, point in
                    node(
                        x: point.x * size.width,
                        y: point.y * size.height,
                        size: index == 1 ? 4.6 : 4.0,
                        bright: false
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func node(x: CGFloat, y: CGFloat, size: CGFloat, bright: Bool) -> some View {
        ZStack {
            Circle()
                .fill(ZD.Color.accent.opacity(bright ? 0.18 : 0.10))
                .frame(width: size * 2.6, height: size * 2.6)
                .blur(radius: 4)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(bright ? 0.88 : 0.68),
                            ZD.Color.accent.opacity(bright ? 0.84 : 0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
        }
        .position(x: x, y: y)
    }
}

struct ConvergenceOrbPair: View {
    let leftOffset: CGFloat
    let rightOffset: CGFloat
    let collisionProgress: CGFloat
    let flashActive: Bool
    let suspendedPulse: Bool

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.16 + (0.10 * collisionProgress)),
                            Color.white.opacity(0.04 + (0.04 * collisionProgress)),
                            .clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 96
                    )
                )
                .frame(width: 190, height: 136)
                .blur(radius: 22)
                .scaleEffect(suspendedPulse ? 1.03 : 0.98)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.10 * magneticProgress),
                            ZD.Color.accent.opacity(0.12 * magneticProgress),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 72
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 18)
                .scaleEffect(0.8 + (0.5 * magneticProgress))

            leftOrb
                .offset(x: leftOffset)

            rightOrb
                .offset(x: rightOffset)

            if flashActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.46),
                                ZD.Color.accent.opacity(0.26),
                                .clear
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: 92
                        )
                    )
                    .frame(width: 164, height: 164)
                    .blur(radius: 14)
                    .blendMode(.screen)
            }
        }
    }

    private var magneticProgress: CGFloat {
        min(max((collisionProgress - 0.58) / 0.30, 0), 1)
    }

    private var leftOrb: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.40),
                            ZD.Color.accent.opacity(0.18),
                            .clear
                        ],
                        center: .center,
                        startRadius: 18,
                        endRadius: 96
                    )
                )
                .frame(width: 174, height: 174)
                .blur(radius: 34)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.98),
                            ZD.Color.accent.opacity(0.88),
                            ZD.Color.accent.opacity(0.34),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 86
                    )
                )
                .frame(width: 122, height: 122)
                .blur(radius: 18)

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 70, height: 70)
                .blur(radius: 20)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 0.9)
                .frame(width: 110, height: 110)
                .blur(radius: 1.5)

            Circle()
                .stroke(ZD.Color.accent.opacity(0.10), lineWidth: 2.8)
                .frame(width: 116, height: 116)
                .blur(radius: 8)
        }
    }

    private var rightOrb: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.72, green: 0.78, blue: 0.90).opacity(0.22),
                            Color(red: 0.46, green: 0.52, blue: 0.66).opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: 14,
                        endRadius: 88
                    )
                )
                .frame(width: 154, height: 154)
                .blur(radius: 30)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.94, green: 0.96, blue: 0.99).opacity(0.20),
                            Color(red: 0.62, green: 0.68, blue: 0.80).opacity(0.12),
                            Color.black.opacity(0.985)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 72
                    )
                )
                .frame(width: 102, height: 102)
                .blur(radius: 7)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 44, height: 44)
                .blur(radius: 14)

            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 0.9)
                .frame(width: 98, height: 98)
                .blur(radius: 1.2)

            Circle()
                .stroke(Color(red: 0.72, green: 0.78, blue: 0.88).opacity(0.08), lineWidth: 2.4)
                .frame(width: 104, height: 104)
                .blur(radius: 7)
        }
    }
}
