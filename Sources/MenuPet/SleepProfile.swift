import Foundation

enum SleepRhythm: Equatable {
    case morning
    case daytime
    case night

    var name: String {
        switch self {
        case .morning: "朝型"
        case .daytime: "昼型"
        case .night: "夜型"
        }
    }

    var bedtimeHour: Int {
        switch self {
        case .morning: 21
        case .daytime: 23
        case .night: 3
        }
    }
}

enum SleepTrait: Equatable {
    case light
    case oversleeper
    case deep
    case sleepless

    var name: String {
        switch self {
        case .light: "眠りが浅い"
        case .oversleeper: "寝過ぎ"
        case .deep: "眠りが深い"
        case .sleepless: "眠らない"
        }
    }
}

struct SleepProfile: Equatable {
    let rhythm: SleepRhythm
    let trait: SleepTrait?

    static let initial = SleepProfile(rhythm: .daytime, trait: nil)

    // 呼び出し側が渡した直近60日の中から、最近の活動日を最大14日選ぶ。
    static func eligibleDays(from stats: [DailyStats]) -> [DailyStats] {
        Array(stats.filter {
            $0.activityByHour.count == 24 && $0.activityByHour.reduce(0, +) >= 50
        }.sorted { $0.date > $1.date }.prefix(14))
    }

    static func calculate(from stats: [DailyStats]) -> SleepProfile {
        let days = eligibleDays(from: stats)
        guard days.count >= 7 else { return .initial }

        let morningHours = [5, 6, 7, 8, 9]
        let nightHours = [21, 22, 23, 0, 1, 2]
        let timeDifference = days.reduce(0.0) { sum, day in
            let capped = day.activityByHour.map { min(max($0, 0), 60) }
            let total = Double(capped.reduce(0, +))
            let morning = morningHours.reduce(0) { $0 + capped[$1] }
            let night = nightHours.reduce(0) { $0 + capped[$1] }
            return sum + Double(morning - night) / total
        } / Double(days.count)

        let rhythm: SleepRhythm
        if timeDifference > 0.08 {
            rhythm = .morning
        } else if timeDifference < -0.08 {
            rhythm = .night
        } else {
            rhythm = .daytime
        }

        guard days.count >= 14 else {
            return SleepProfile(rhythm: rhythm, trait: nil)
        }

        let averageActiveHours = Double(days.reduce(0) { sum, day in
            sum + day.activityByHour.filter { $0 >= 5 }.count
        }) / Double(days.count)

        let trait: SleepTrait?
        if averageActiveHours >= 13 {
            trait = .sleepless
        } else if averageActiveHours <= 5 {
            trait = .oversleeper
        } else {
            let baseProfile = SleepProfile(rhythm: rhythm, trait: nil)
            let interruptedDays = days.filter { day in
                day.activityByHour.indices.contains { hour in
                    baseProfile.isSleeping(atHour: hour)
                        && day.activityByHour[hour] >= 5
                }
            }.count
            let interruptedRate = Double(interruptedDays) / Double(days.count)

            if interruptedRate >= 0.3 {
                trait = .light
            } else if interruptedRate <= 0.05
                        && (7...11).contains(averageActiveHours) {
                trait = .deep
            } else {
                trait = nil
            }
        }

        return SleepProfile(rhythm: rhythm, trait: trait)
    }

    var wakeDuration: TimeInterval {
        switch trait {
        case .light: 180
        case .oversleeper: 20
        case .deep, .sleepless, nil: 60
        }
    }

    var sleepDescription: String {
        if trait == .sleepless { return "3時間ごとに5分居眠り" }
        let start = sleepStartMinute / 60
        let end = (sleepStartMinute + sleepDurationMinutes) % 1440 / 60
        return String(format: "%02d:00〜%02d:00", start, end)
    }

    func isSleeping(at date: Date, calendar: Calendar = .current) -> Bool {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let minute = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        return isSleeping(atMinute: minute)
    }

    private var sleepStartMinute: Int {
        let shift = trait == .oversleeper ? -60 : 0
        return (rhythm.bedtimeHour * 60 + shift + 1440) % 1440
    }

    private var sleepDurationMinutes: Int {
        trait == .oversleeper ? 600 : 480
    }

    private func isSleeping(atHour hour: Int) -> Bool {
        isSleeping(atMinute: hour * 60)
    }

    private func isSleeping(atMinute minute: Int) -> Bool {
        if trait == .sleepless { return minute % 180 < 5 }
        let elapsed = (minute - sleepStartMinute + 1440) % 1440
        return elapsed < sleepDurationMinutes
    }
}
