import Foundation

struct DailyStats: Codable {
    let date: Date
    var clickCount: Int = 0
    var petClickCount: Int = 0
    var leftClickCount: Int = 0
    var rightClickCount: Int = 0
    var mouseDistance = 0.0
    var keyCount: Int = 0
    var backspaceCount = 0
    var enterCount = 0
    var spaceCount = 0
    var activityByHour: [Int] = Array(repeating: 0, count: 24)

    enum CodingKeys: String, CodingKey {
        case date
        case clickCount
        case petClickCount
        case leftClickCount
        case rightClickCount
        case mouseDistance
        case keyCount
        case backspaceCount
        case enterCount
        case spaceCount
        case activityByHour
    }

    init(
        date: Date,
        clickCount: Int = 0,
        petClickCount: Int = 0,
        leftClickCount: Int = 0,
        rightClickCount: Int = 0,
        mouseDistance: Double = 0.0,
        keyCount: Int = 0,
        backspaceCount: Int = 0,
        enterCount: Int = 0,
        spaceCount: Int = 0,
        activityByHour: [Int] = Array(repeating: 0, count: 24)


    ) {
        self.date = date
        self.clickCount = clickCount
        self.petClickCount = petClickCount
        self.leftClickCount = leftClickCount
        self.rightClickCount = rightClickCount
        self.mouseDistance = mouseDistance
        self.keyCount = keyCount
        self.enterCount = enterCount
        self.backspaceCount = backspaceCount
        self.spaceCount = spaceCount
        self.activityByHour = activityByHour
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

        mouseDistance = try container.decodeIfPresent(
            Double.self,
            forKey: .mouseDistance
        ) ?? 0

        keyCount = try container.decodeIfPresent(
            Int.self,
            forKey: .keyCount
        ) ?? 0
        backspaceCount = try container.decodeIfPresent(
            Int.self,
            forKey: .backspaceCount
        ) ?? 0

        enterCount = try container.decodeIfPresent(
            Int.self,
            forKey: .enterCount
        ) ?? 0

        spaceCount = try container.decodeIfPresent(
            Int.self,
            forKey: .spaceCount
        ) ?? 0
        
        activityByHour = try container.decodeIfPresent(
            [Int].self,
            forKey: .activityByHour
        ) ?? Array(repeating: 0, count: 24)
    }
}