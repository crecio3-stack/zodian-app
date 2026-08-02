//
//  PassedProfile.swift
//  Zodian
//
//  Created by Ian Recio on 4/8/26.
//


import Foundation
import SwiftData

@Model
final class PassedProfile {
    var id: UUID
    var createdAt: Date

    var name: String
    var archetypeId: String

    init(
        name: String,
        archetypeId: String
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.archetypeId = archetypeId
    }
}