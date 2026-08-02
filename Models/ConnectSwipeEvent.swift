//
//  ConnectSwipeEvent.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//


import Foundation
import SwiftData

@Model
final class ConnectSwipeEvent {
    var id: UUID
    var createdAt: Date

    var name: String
    var archetypeId: String

    var westernSignRaw: String
    var chineseSignRaw: String

    var compatibilityScore: Int
    var actionRaw: String

    init(
        name: String,
        archetypeId: String,
        westernSignRaw: String,
        chineseSignRaw: String,
        compatibilityScore: Int,
        actionRaw: String
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.archetypeId = archetypeId
        self.westernSignRaw = westernSignRaw
        self.chineseSignRaw = chineseSignRaw
        self.compatibilityScore = compatibilityScore
        self.actionRaw = actionRaw
    }
}