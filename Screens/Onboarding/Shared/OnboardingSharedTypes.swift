import SwiftUI

enum OnboardingHeroTone {
    case arrival
    case ritual
}

enum OnboardingHeroShimmerMode {
    case looping
    case singleSweep
    case none
}

enum WelcomePhase: Int, CaseIterable {
    case idle
    case logoIntro
    case logoDocked
    case headline
    case subheadline
    case systems
    case framing
    case cta
}

enum OnboardingStepLayoutStyle {
    case arrival
    case card
}

enum OnboardingAmbientStyle {
    case welcome
    case subtle
}

enum RevealPhase {
    case idle
    case compressing
    case suspended
    case revealing
}

enum OnboardingHeroMetrics {
    static let logoSize: CGFloat = 58
    static let loadingInnerMarkSize: CGFloat = 54
    static let topSpacing: CGFloat = 26
    static let bottomSpacing: CGFloat = 24
    static let maxWidth: CGFloat = 360
    static let cardMinHeight: CGFloat = 438
    static let footerReservedHeight: CGFloat = 104
    static let logoToEyebrowSpacing: CGFloat = 14
    static let eyebrowToTitleSpacing: CGFloat = 10
    static let subtitleTopSpacing: CGFloat = 12
}

struct WesternRevealAnimationState {
    var heroVisible = false
    var glyphVisible = false
    var identityVisible = false
    var supportingVisible = false
    var selectorVisible = false
    var ctaVisible = false
}

struct EasternRevealAnimationState {
    var heroVisible = false
    var symbolVisible = false
    var identityVisible = false
    var supportingVisible = false
    var selectorVisible = false
    var ctaVisible = false
}

struct MergingRevealAnimationState {
    var heroVisible = false
    var westernVisible = false
    var easternVisible = false
    var combinedVisible = false
    var contentVisible = false
    var ctaVisible = false
}

struct RevealAnimationState {
    var revealScale: CGFloat = 0.92
    var revealOpacity: Double = 0
    var revealGlow = false

    var revealBackdropVisible = false
    var revealHeaderVisible = false
    var revealComboVisible = false
    var revealTitleVisible = false
    var revealTaglineVisible = false
    var revealOverviewVisible = false
    var revealOverviewLineCount = 0
    var revealButtonVisible = false
    var revealShareVisible = false
    var revealFlash = false
    var revealCardLift: CGFloat = 28
}

extension WelcomePhase {
    func hasReached(_ other: WelcomePhase) -> Bool {
        rawValue >= other.rawValue
    }
}
