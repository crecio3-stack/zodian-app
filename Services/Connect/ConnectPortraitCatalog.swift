import Foundation
import SwiftUI

enum ConnectPortraitCatalog {
    enum Presentation {
        case feminine
        case masculine
        case neutral
    }

    // Replace or expand these asset names as licensed Pexels portraits are added.
    // Keep the names stable once used so saved matches continue to render correctly.
    static let feminineAssetNames = [
        "pexelsFeminine01",
        "pexelsFeminine02",
        "pexelsFeminine03",
        "pexelsFeminine04",
        "pexelsFeminine05",
        "pexelsFeminine06",
        "pexelsFeminine07",
        "pexelsFeminine08",
        "pexelsFeminine09",
        "pexelsFeminine10"
    ]

    static let masculineAssetNames = [
        "pexelsMasculine01",
        "pexelsMasculine02",
        "pexelsMasculine03",
        "pexelsMasculine04",
        "pexelsMasculine05",
        "pexelsMasculine06",
        "pexelsMasculine07",
        "pexelsMasculine08",
        "pexelsMasculine09",
        "pexelsMasculine10"
    ]

    static let neutralAssetNames = feminineAssetNames + masculineAssetNames

    static let anchors: [UnitPoint] = [
        .center,
        .top,
        .topLeading,
        .topTrailing,
        .leading,
        .trailing
    ]

    static func assetName(seed: Int, presentation: Presentation) -> String {
        let source: [String]

        switch presentation {
        case .feminine:
            source = feminineAssetNames
        case .masculine:
            source = masculineAssetNames
        case .neutral:
            source = neutralAssetNames
        }

        guard !source.isEmpty else { return "zodianMark" }

        let mixedSeed = stableMixedSeed(seed)
        return source[mixedSeed % source.count]
    }

    static func anchor(seed: Int) -> UnitPoint {
        guard !anchors.isEmpty else { return .center }

        let mixedSeed = stableMixedSeed(seed + 97)
        return anchors[mixedSeed % anchors.count]
    }

    private static func stableMixedSeed(_ seed: Int) -> Int {
        var value = UInt64(bitPattern: Int64(seed))
        value &+= 0x9E3779B97F4A7C15
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        value = value ^ (value >> 31)
        return Int(value % UInt64(Int.max))
    }
}
