enum AchievementGoals {
    static let allKeys = [50_000, 200_000, 500_000, 1_000_000]
    static let enter = [5_000, 20_000, 50_000, 100_000]
    static let space = [3_000, 10_000, 25_000, 50_000]
    static let backspace = [10_000, 30_000, 75_000, 150_000]
    static let arrows = [1_000, 4_000, 10_000, 20_000]
    static let copyPaste = [500, 2_000, 5_000, 10_000]
    static let undo = [100, 500, 2_000, 5_000]
    static let selectAll = [100, 500, 1_500, 4_000]
    static let mouseDistance = [50_000_000, 150_000_000, 400_000_000, 1_000_000_000]
    static let activeStreak = [7, 30, 90, 365]
    static let nightActivityDays = [10, 30, 90, 180]
    static let waterPlantActiveDays = 100
    static let visits = [30, 150, 500, 1_500]
    static let petTouches = [100, 400, 1_000, 2_000]
    static let visitDailyLimit = 3
    static let petTouchDailyLimit = 5

    static func cappedTotal(_ dailyCounts: [Int], dailyLimit: Int) -> Int {
        dailyCounts.reduce(0) { $0 + min(max($1, 0), dailyLimit) }
    }

    private static let ringChances = [0.0, 0.30, 0.45, 0.55, 0.70]

    static func landingRingChance(for spaceCount: Int) -> Double {
        let stage = space.prefix { spaceCount >= $0 }.count
        return ringChances[stage]
    }

    static func decisionSparkleChance(for enterCount: Int) -> Double {
        enterCount >= enter[0] ? 0.35 : 0
    }

    static func hesitationChance(for backspaceCount: Int) -> Double {
        backspaceCount >= backspace[0] ? 0.25 : 0
    }

    static func mimicBubbleChance(for copyPasteCount: Int) -> Double {
        let stage = copyPaste.prefix { copyPasteCount >= $0 }.count
        return [0.0, 0.20, 0.30, 0.40, 0.50][stage]
    }

    static func undoEchoChance(for undoCount: Int) -> Double {
        let stage = undo.prefix { undoCount >= $0 }.count
        return [0.0, 0.10, 0.14, 0.18, 0.22][stage]
    }

}
