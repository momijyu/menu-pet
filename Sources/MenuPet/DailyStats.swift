import Foundation

struct DailyStats: Codable {
    let date: Date
    var clickCount: Int = 0
    var petClickCount: Int = 0
    var leftClickCount: Int = 0
    var rightClickCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case date
        case clickCount
        case petClickCount
        case leftClickCount
        case rightClickCount
    }

    init(
        date: Date,
        clickCount: Int = 0,
        petClickCount: Int = 0,
        leftClickCount: Int = 0,
        rightClickCount: Int = 0
    ) {
        self.date = date
        self.clickCount = clickCount
        self.petClickCount = petClickCount
        self.leftClickCount = leftClickCount
        self.rightClickCount = rightClickCount
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

        leftClickCount = try container.decodeIfPresent(
            Int.self,
            forKey: .leftClickCount
        ) ?? 0

        rightClickCount = try container.decodeIfPresent(
            Int.self,
            forKey: .rightClickCount
            //ここまでやると慣れてくる。
        ) ?? 0
    }
}