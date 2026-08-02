import SwiftUI

struct PointsStreakBadge: View {
    let points: Int
    let streak: Int

    var body: some View {
        Text("\(points) • \(streak)")
            .foregroundStyle(ZD.Color.textPrimary)
    }
}
