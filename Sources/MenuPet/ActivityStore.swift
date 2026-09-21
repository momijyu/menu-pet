import Foundation
import Combine
import AppKit

@MainActor
final class ActivityStore: ObservableObject {
    @Published var dailyStats: [DailyStats] = []
    @Published var hasUnsavedChanges = false
    @Published var hasLoaded = false
    //@Published var leftClickCount = 0
    private var autoSaveTask: Task<Void, Never>?
    private var mouseMonitor: Any?

    init(){
        loadDailyStats()
        startAutoSave()
        startMouseMonitoring()
    }
    deinit{
        autoSaveTask?.cancel()

        if let mouseMonitor {
            NSEvent.removeMonitor(mouseMonitor)
        }
    }
    func recordPetClick() {
        updateToday { stats in
            stats.petClickCount += 1
        }
    }

    func recordLeftClick() {
        updateToday { stats in
            stats.leftClickCount += 1
        }
    }
    func recordRightClick(){
        updateToday { stats in
            stats.rightClickCount += 1
        }
    }

    private func updateToday(_ update: (inout DailyStats) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())

        if let index = dailyStats.firstIndex(where: { $0.date == today }) {
            update(&dailyStats[index])
        } else {
            var newStats = DailyStats(date: today)
            update(&newStats)
            dailyStats.append(newStats)
        }

        hasUnsavedChanges = true
    }
    private func loadDailyStats() {
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
    private func startAutoSave() {
        guard autoSaveTask == nil else { return }

        autoSaveTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    return
                }

                guard !Task.isCancelled, let self else { return }
                self.saveDailyStats()
            }
        }
    }
    private func startMouseMonitoring() {
        //startMouseMonitoring自体は一度しか呼ばれていないがnsevent.⚪︎⚪︎を使用することでmac本体に()内のイベントの監視を追加できる。らしい。ほえー
        //nsevent〇〇(条件){命令文}
        guard mouseMonitor == nil else { return }

        mouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            Task { @MainActor in
                switch event.type {
                case .leftMouseDown:
                    self?.recordLeftClick()
                    print("左クリック")

                case .rightMouseDown:
                    self?.recordRightClick()
                    print("右クリック")

                default:
                    break
                }
            }
        }
    }
    //どこに何置いたかわかんなくなってきた。
}