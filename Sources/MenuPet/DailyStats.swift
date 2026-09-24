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
        func readCount(_ key: CodingKeys) throws -> Int {
            try container.decodeIfPresent(Int.self, forKey: key) ?? 0
        }
        date = try container.decode(Date.self, forKey: .date)


        clickCount = try readCount(.clickCount)

        petClickCount = try readCount(.petClickCount)

        leftClickCount = try readCount(.leftClickCount)

        rightClickCount = try readCount(.rightClickCount)

        mouseDistance = try container.decodeIfPresent(
            Double.self,
            forKey: .mouseDistance
        ) ?? 0

        keyCount = try readCount(.keyCount)

        backspaceCount = try readCount(.backspaceCount)

        enterCount = try readCount(.enterCount)

        spaceCount = try readCount(.spaceCount)

        activityByHour = try container.decodeIfPresent(
            [Int].self,
            forKey: .activityByHour
        ) ?? Array(repeating: 0, count: 24)
        
    }
}