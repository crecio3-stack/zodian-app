//
//  ConnectDeckEntry.swift
//  Zodian
//
//  Created by Ian Recio on 4/22/26.
//


import Foundation
import SwiftData

@Model
final class ConnectDeckEntry {
    @Attribute(.unique) var id: UUID

    var deckDateKey: String
    var position: Int

    var name: String
    var archetypeId: String
    var archetypeTitle: String

    var westernSignRaw: String
    var chineseSignRaw: String

    var compatibilityScore: Int
    var matchStyleRaw: String

    var essence: String
    var connectionPrompt: String
    var frictionNote: String
    var intent: String
    var signalsRaw: String = ""

    var imageName: String
    var imageAnchorRaw: String

    var primaryReasonTitle: String
    var primaryReasonDetail: String
    var secondaryReasonTitle: String = ""
    var secondaryReasonDetail: String = ""

    var isDismissed: Bool
    var wasLiked: Bool
    var wasPassed: Bool

    var createdAt: Date

    init(
        id: UUID = UUID(),
        deckDateKey: String,
        position: Int,
        name: String,
        archetypeId: String,
        archetypeTitle: String,
        westernSignRaw: String,
        chineseSignRaw: String,
        compatibilityScore: Int,
        matchStyleRaw: String,
        essence: String,
        connectionPrompt: String,
        frictionNote: String,
        intent: String,
        signalsRaw: String = "",
        imageName: String,
        imageAnchorRaw: String,
        primaryReasonTitle: String,
        primaryReasonDetail: String,
        secondaryReasonTitle: String = "",
        secondaryReasonDetail: String = "",
        isDismissed: Bool = false,
        wasLiked: Bool = false,
        wasPassed: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.deckDateKey = deckDateKey
        self.position = position
        self.name = name
        self.archetypeId = archetypeId
        self.archetypeTitle = archetypeTitle
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.compatibilityScore = compatibilityScore
        self.matchStyleRaw = matchStyleRaw
        self.essence = essence
        self.connectionPrompt = connectionPrompt
        self.frictionNote = frictionNote
        self.intent = intent
        self.signalsRaw = signalsRaw
        self.imageName = imageName
        self.imageAnchorRaw = imageAnchorRaw
        self.primaryReasonTitle = primaryReasonTitle
        self.primaryReasonDetail = primaryReasonDetail
        self.secondaryReasonTitle = secondaryReasonTitle
        self.secondaryReasonDetail = secondaryReasonDetail
        self.isDismissed = isDismissed
        self.wasLiked = wasLiked
        self.wasPassed = wasPassed
        self.createdAt = createdAt
    }
}
