import Foundation

struct DailyStats: Codable{ 
    let date: Date
    var clickCount: Int = 0
}