import CoreGraphics
import Foundation

enum DailyLensRevealGeometry {
    /// One typography contract for the concealed preview, active lens, and
    /// inline revealed state. Keeping these values outside the views prevents
    /// the optical reveal layers from drifting apart.
    static let titleFontSize: CGFloat = 28
    static let readFontSize: CGFloat = 13.5

    static func centerRange(
        cardHeight: CGFloat,
        contentBounds: CGRect,
        viewfinderHeight: CGFloat,
        cardInset: CGFloat
    ) -> ClosedRange<CGFloat> {
        let halfHeight = max(0, viewfinderHeight / 2)
        let cardMinimum = halfHeight + cardInset
        let cardMaximum = max(cardMinimum, cardHeight - halfHeight - cardInset)
        let contentMinimum = contentBounds.minY - halfHeight
        let contentMaximum = contentBounds.maxY + halfHeight
        let minimum = max(cardMinimum, contentMinimum)
        let maximum = min(cardMaximum, max(minimum, contentMaximum))
        return minimum...maximum
    }

#if DEBUG
    static func assertReachability(
        range: ClosedRange<CGFloat>,
        contentBounds: CGRect,
        viewfinderHeight: CGFloat
    ) {
        let halfHeight = viewfinderHeight / 2
        assert(range.lowerBound - halfHeight <= contentBounds.minY)
        assert(range.upperBound + halfHeight >= contentBounds.maxY)
    }
#endif
}
