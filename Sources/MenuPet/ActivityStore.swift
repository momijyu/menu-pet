import Foundation
import Combine

@MainActor
final class ActivityStore: ObservableObject {
    @Published var dailyStats: [DailyStats] = []
    @Published var hasUnsavedChanges = false
    @Published var hasLoaded = false

    func recordClick() {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyStats.firstIndex(where: { $0.date == today }) {
            dailyStats[index].clickCount += 1
        } else {
            dailyStats.append(
                DailyStats(date: today, clickCount: 1)
            )
        }

        hasUnsavedChanges = true
    }
    func loadDailyStats() {
        guard !hasLoaded else { return }

        do {
            let supportDirectory = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let fileURL = supportDirectory
                .appendingPathComponent("MenuPet", isDirectory: true)
                .appendingPathComponent("daily-stats.json")

            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                dailyStats = try decoder.decode(
                    [DailyStats].self,
                    from: data
                )

                print("読み込みました: \(dailyStats.count)日分")
            }

            hasLoaded = true
        } catch {
            print("読み込みに失敗しました: \(error)")
        }
    }
    func saveDailyStats(){
        guard hasLoaded && hasUnsavedChanges else { return }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(dailyStats)

            let supportDirectory = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directory = supportDirectory
                .appendingPathComponent("MenuPet", isDirectory: true)

            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true)
            
            let fileURL = directory
                .appendingPathComponent(
                    "daily-stats.json"
                    )
            try data.write(to: fileURL, options: .atomic)
            hasUnsavedChanges = false

            print("保存しました: \(fileURL.path)")
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }
}