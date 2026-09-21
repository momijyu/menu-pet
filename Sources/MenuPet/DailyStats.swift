import Foundation

struct DailyStats: Codable {
    let date: Date
    var clickCount: Int = 0
    var petClickCount: Int = 0
    var externalClickCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case date
        case clickCount
        case petClickCount
        case externalClickCount
    }

    init(
        date: Date,
        clickCount: Int = 0,
        petClickCount: Int = 0,
        externalClickCount: Int = 0
    ) {
        self.date = date
        self.clickCount = clickCount
        self.petClickCount = petClickCount
        self.externalClickCount = externalClickCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        date = try container.decode(Date.self, forKey: .date)

        clickCount = try container.decodeIfPresent(
            Int.self,
            forKey: .clickCount
        ) ?? 0

        petClickCount = try container.decodeIfPresent(
            Int.self,
            forKey: .petClickCount
        ) ?? 0

        externalClickCount = try container.decodeIfPresent(
            Int.self,
            forKey: .externalClickCount
        ) ?? 0
    }
}