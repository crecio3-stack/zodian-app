//
//  ConnectFilter.swift
//  Zodian
//
//  Created by Ian Recio on 4/11/26.
//


import Foundation
import SwiftUI

enum ConnectFilter: String, CaseIterable, Identifiable, Codable {
    case compatible
    case similar
    case newEnergy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compatible: return "Compatible"
        case .similar: return "Similar Archetypes"
        case .newEnergy: return "New Energy"
        }
    }

    var subtitle: String {
        switch self {
        case .compatible: return "People whose energy complements yours"
        case .similar: return "People who mirror your rhythm"
        case .newEnergy: return "Unexpected dynamics worth exploring"
        }
    }
}

enum SwipeAction: String, Codable {
    case like
    case pass
}

enum MatchStyle: String, Codable {
    case harmonious
    case mirrored
    case magnetic
    case growth
    case intense

    var label: String {
        switch self {
        case .harmonious: return "Harmonious"
        case .mirrored: return "Mirrored"
        case .magnetic: return "Magnetic"
        case .growth: return "Growth"
        case .intense: return "Intense"
        }
    }
}

struct MatchReason: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

struct CompatibilityBreakdown: Equatable {
    let totalScore: Int
    let westernScore: Int
    let chineseScore: Int
    let archetypeScore: Int
    let style: MatchStyle
    let reasons: [MatchReason]
    let frictionNote: String
}

struct DeckProfile: Identifiable, Equatable {
    let id: UUID
    let name: String
    let age: Int
    let archetypeId: String
    let archetypeTitle: String
    let combinedSigns: String
    let westernSign: WesternZodiac
    let chineseSign: ChineseZodiac
    let essence: String
    let connectionPrompt: String
    let compatibilityScore: Int
    let matchStyle: MatchStyle
    let matchReasons: [MatchReason]
    let frictionNote: String
    let imageName: String
    let imageAnchor: UnitPoint
    let intent: String

    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        archetypeId: String,
        archetypeTitle: String,
        combinedSigns: String,
        westernSign: WesternZodiac,
        chineseSign: ChineseZodiac,
        essence: String,
        connectionPrompt: String,
        compatibilityScore: Int,
        matchStyle: MatchStyle,
        matchReasons: [MatchReason],
        frictionNote: String,
        imageName: String,
        imageAnchor: UnitPoint,
        intent: String
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.archetypeId = archetypeId
        self.archetypeTitle = archetypeTitle
        self.combinedSigns = combinedSigns
        self.westernSign = westernSign
        self.chineseSign = chineseSign
        self.essence = essence
        self.connectionPrompt = connectionPrompt
        self.compatibilityScore = compatibilityScore
        self.matchStyle = matchStyle
        self.matchReasons = matchReasons
        self.frictionNote = frictionNote
        self.imageName = imageName
        self.imageAnchor = imageAnchor
        self.intent = intent
    }
}