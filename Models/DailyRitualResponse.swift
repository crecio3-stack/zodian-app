import Foundation

struct DailyRitualResponse: Codable, Equatable {
    let id: String?
    let ritualDate: String?
    let westernSign: String?
    let easternSign: String?
    let title: String
    let ritualText: String
    let actionText: String
    let createdAt: String?

    init(
        id: String? = nil,
        ritualDate: String? = nil,
        westernSign: String? = nil,
        easternSign: String? = nil,
        title: String,
        ritualText: String,
        actionText: String,
        createdAt: String? = nil
    ) {
        self.id = id
        self.ritualDate = ritualDate
        self.westernSign = westernSign
        self.easternSign = easternSign
        self.title = title
        self.ritualText = ritualText
        self.actionText = actionText
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ritualDate = "ritual_date"
        case westernSign = "western_sign"
        case easternSign = "eastern_sign"
        case title
        case ritualText = "ritual_text"
        case actionText = "action_text"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        ritualDate = try container.decodeIfPresent(String.self, forKey: .ritualDate)
        westernSign = try container.decodeIfPresent(String.self, forKey: .westernSign)
        easternSign = try container.decodeIfPresent(String.self, forKey: .easternSign)
        title = try container.decode(String.self, forKey: .title)
        ritualText = try container.decode(String.self, forKey: .ritualText)
        actionText = try container.decode(String.self, forKey: .actionText)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
