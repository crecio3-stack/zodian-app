import Foundation
import SwiftData

@Model
final class ConnectUserProfile {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var age: Int?
    var showsAge: Bool
    var bio: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var intent: String
    var isVisible: Bool
    var photoFileName: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String = "",
        age: Int? = nil,
        showsAge: Bool = true,
        bio: String = "",
        prompt1: String = "",
        prompt2: String = "",
        prompt3: String = "",
        intent: String = "",
        isVisible: Bool = true,
        photoFileName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.age = age
        self.showsAge = showsAge
        self.bio = bio
        self.prompt1 = prompt1
        self.prompt2 = prompt2
        self.prompt3 = prompt3
        self.intent = intent
        self.isVisible = isVisible
        self.photoFileName = photoFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
