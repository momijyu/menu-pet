import ApplicationServices
import Foundation
import Combine
import AppKit

@MainActor
final class ActivityStore: ObservableObject {
    @Published var dailyStats: [DailyStats] = []
    @Published var hasUnsavedChanges = false
    @Published var hasLoaded = false
    private var autoSaveTask: Task<Void, Never>?
    private var mouseMonitor: Any?
    private var mouseTrackingTask: Task<Void, Never>?
    private var previousMouseLocation: NSPoint?
    //データがないから?を使用してるよー
    private var pendingMouseDistance: Double = 0

    init(){
        //print("Accessibility許可: \(AXIsProcessTrusted())")
        requestAccessibilityPermission()
        loadDailyStats()
        startAutoSave()
        startMouseMonitoring()
        startMouseTracking()
    }
    deinit{
        autoSaveTask?.cancel()
        mouseTrackingTask?.cancel()

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
            let hour = Calendar.current.component(.hour, from: Date())
            stats.activityByHour[hour] += 1
        }
    }
    func recordRightClick(){
        updateToday { stats in
            stats.rightClickCount += 1
            let hour = Calendar.current.component(.hour, from: Date())
            stats.activityByHour[hour] += 1
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
        flushPendingMouseDistance()
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
            matching: [.leftMouseDown, .rightMouseDown, .keyDown]
        ) { [weak self] event in
            Task { @MainActor in
                switch event.type {
                case .leftMouseDown:
                    self?.recordLeftClick()
                    //print("左クリック")

                case .rightMouseDown:
                    self?.recordRightClick()
                    //print("右クリック")

                case .keyDown:
                    self?.recordKeyPress(
                        keyCode: event.keyCode,
                        isCommandPressed: event.modifierFlags.contains(.command)
                    )
                default:
                    break
                }
            }
        }
    }
    //どこに何置いたかわかんなくなってきた。
    private func recordMouseMovement(at location: NSPoint) {
        guard let previousLocation = previousMouseLocation else {
            previousMouseLocation = location
            return
        }

        let deltaX = location.x - previousLocation.x
        let deltaY = location.y - previousLocation.y

        let distance = hypot(deltaX, deltaY)
        pendingMouseDistance += distance

        previousMouseLocation = location
    }
    private func flushPendingMouseDistance() {
        guard pendingMouseDistance > 0 else { return }

        let distance = pendingMouseDistance
        pendingMouseDistance = 0

        updateToday { stats in
            stats.mouseDistance += distance
        }
    }
    private func startMouseTracking() {
        guard mouseTrackingTask == nil else { return }

        mouseTrackingTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .milliseconds(50))
                } catch {
                    return
                }

                guard !Task.isCancelled, let self else { return }

                self.recordMouseMovement(
                    at: NSEvent.mouseLocation
                )
            }
        }
    }
    func recordKeyPress(keyCode: UInt16, isCommandPressed: Bool) {
        updateToday { stats in
            stats.keyCount += 1
            let hour = Calendar.current.component(.hour, from: Date())
            stats.activityByHour[hour] += 1

            switch keyCode {
            case 51:
                stats.backspaceCount += 1

            case 36, 76:
                stats.enterCount += 1

            case 49:
                stats.spaceCount += 1

            case 123, 124, 125, 126:
                stats.arrowCount += 1
            
            default:
                break
            }
            if isCommandPressed{
                switch keyCode{
                case 8:
                    stats.copyCount += 1

                case 9:
                    stats.pasteCount += 1

                case 0:
                    stats.selectAllCount += 1

                case 6:
                    stats.undoCount += 1
                default:
                    break
                }
            }
        }
    }
    var recentStats: [DailyStats] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let firstDay = Calendar.current.date(
            byAdding: .day,
            value: -6,
            to: today
        ) else {
            return []
        }

        return dailyStats.filter { stats in
            stats.date >= firstDay && stats.date <= today
        }
    }
    var recent30Stats: [DailyStats] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let firstDay = Calendar.current.date(
            byAdding: .day,
            value: -29,
            to: today
        ) else {
            return []
        }

        return dailyStats.filter { stats in
            stats.date >= firstDay && stats.date <= today
        }
    }
    private var activeDayDates: Set<Date> {
        Set(dailyStats.filter { day in
            day.keyCount + day.leftClickCount + day.rightClickCount >= 50
                || day.mouseDistance >= 50_000
        }.map { Calendar.current.startOfDay(for: $0.date) })
    }
    var petTouchDays: Int {
        Set(dailyStats.filter { $0.petClickCount > 0 }
            .map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    var totalActiveDays: Int {
        activeDayDates.count
    }
    var hasHeartSparkle: Bool {
        petTouchDays >= 20
    }
    var hasFamiliarPlace: Bool {
        totalActiveDays >= 30
    }
    var consecutiveActiveDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activeDays = activeDayDates
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return 0
        }
        var day = activeDays.contains(today) ? today : yesterday
        var count = 0

        while activeDays.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }
        return count
    }
    var habitStrength: Double {
        min(Double(consecutiveActiveDays) / 14, 1)
    }
    var lastActiveDayBeforeToday: Date? {
        let today = Calendar.current.startOfDay(for: Date())
        return activeDayDates.filter { $0 < today }.max()
    }
    var daysSinceLastActiveDay: Int? {
        guard let previousDay = lastActiveDayBeforeToday else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.dateComponents(
            [.day], from: previousDay, to: today
        ).day
    }
    private var recent60Stats: [DailyStats] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let firstDay = Calendar.current.date(
            byAdding: .day,
            value: -59,
            to: today
        ) else {
            return []
        }

        return dailyStats.filter { stats in
            stats.date >= firstDay && stats.date <= today
        }
    }
    var sleepSampleDays: Int {
        SleepProfile.eligibleDays(from: recent60Stats).count
    }
    var sleepProfile: SleepProfile {
        SleepProfile.calculate(from: recent60Stats)
    }
    var floatiness: Double {
        let days = recent30Stats
        guard !days.isEmpty else { return 0 }

        let distance = days.reduce(0.0) { $0 + $1.mouseDistance }
        let dailyAverage = distance / Double(days.count)
        let movement = min(dailyAverage / 2_000_000, 1)
        let growth = min(Double(days.count) / 7, 1)
        return movement * growth
    }
    var bubbleCount: Int {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        guard keys >= 1_000 else { return 4 }

        let enters = recent30Stats.reduce(0) { $0 + $1.enterCount }
        let enterRate = Double(enters) / Double(keys)
        let extraBubbles = Int((enterRate / 0.27 * 14).rounded())
        return min(16, max(2, 2 + extraBubbles))
    }
    var bodyShape: Double {
        let days = recent30Stats.filter {
            $0.keyCount + $0.leftClickCount + $0.rightClickCount >= 50
        }
        guard !days.isEmpty else { return 0 }

        let keyboard = Double(days.reduce(0) { $0 + $1.keyCount }) / 3_000
        let clicks = Double(days.reduce(0) {
            $0 + $1.leftClickCount + $1.rightClickCount
        }) / 500
        let mouse = days.reduce(0.0) { $0 + $1.mouseDistance } / 500_000
        let pointer = (clicks + mouse) / 2
        guard keyboard + pointer > 0 else { return 0 }

        let balance = (pointer - keyboard) / (pointer + keyboard)
        let tendency = min(max(balance / 0.25, -1), 1)
        let range = tendency >= 0 ? 0.3 : 0.2
        let maturity = min(Double(days.count) / 14, 1)
        return tendency * range * maturity
    }
    var colorTendency: Double {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        let shortcuts = recent30Stats.reduce(0) {
            $0 + $1.copyCount + $1.pasteCount
        }
        let leftClicks = recent30Stats.reduce(0) { $0 + $1.leftClickCount }
        let rightClicks = recent30Stats.reduce(0) { $0 + $1.rightClickCount }

        let shortcutRate = keys > 0
            ? min(Double(shortcuts) / Double(keys) * 100, 1)
            : 0.5
        let clicks = leftClicks + rightClicks
        let rightClickRate = clicks > 0
            ? min(Double(rightClicks) / Double(clicks) * 50, 1)
            : 0.5

        return (shortcutRate + rightClickRate) / 2
    }
    //慎重さ
    var caution: Double {
        let backspace = recentStats.reduce(0) { total, day in
            total + day.backspaceCount
        }
        let enter = recentStats.reduce(0) { total, day in
            total + day.enterCount
        }

        guard backspace + enter > 0 else { return 0.5 }
        return Double(backspace) / Double(backspace + enter)
    }
    var spaceJump: Double {
        let keys = recentStats.reduce(0) { $0 + $1.keyCount }
        let spaces = recentStats.reduce(0) { $0 + $1.spaceCount }
        guard keys > 0 else { return 0 }
        return min(Double(spaces) / Double(keys) * 4, 1)
    }
    var mimicry: Double {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        let copies = recent30Stats.reduce(0) { $0 + $1.copyCount + $1.pasteCount }
        guard keys > 0 else { return 0 }
        return min(Double(copies) / Double(keys) * 50, 1)
    }
    var affection: Double {
        let touches = recent30Stats.reduce(0) { $0 + min($1.petClickCount, 5) }
        return min(Double(touches) / 60, 1)
    }
    var exploration: Double {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        let arrows = recent30Stats.reduce(0) { $0 + $1.arrowCount }
        guard keys > 0 else { return 0 }

        let arrowRate = Double(arrows) / Double(keys)
        let experience = min(Double(keys) / 1_000, 1)
        return min(arrowRate * 12, 1) * experience
    }
    var cornerAffinity: Double {
        let days = recent30Stats.filter {
            $0.keyCount + $0.leftClickCount + $0.rightClickCount >= 50
        }
        guard !days.isEmpty else { return 0 }

        let backspaces = days.reduce(0) { $0 + $1.backspaceCount }
        let enters = days.reduce(0) { $0 + $1.enterCount }
        guard backspaces + enters > 0 else { return 0 }

        let cautionRate = Double(backspaces) / Double(backspaces + enters)
        let dailyMouseDistance = days.reduce(0.0) { $0 + $1.mouseDistance }
            / Double(days.count)
        let stillness = 1 - min(dailyMouseDistance / 500_000, 1)
        let tendency = (cautionRate - 0.45) * 1.2 + (stillness - 0.5) * 0.6
        let maturity = min(Double(days.count) / 7, 1)
        return min(max(tendency, 0), 1) * maturity
    }
    var undoTendency: Double {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        let undos = recent30Stats.reduce(0) { $0 + $1.undoCount }
        guard keys > 0 else { return 0 }

        let experience = min(Double(keys) / 1_000, 1)
        return min(Double(undos) / Double(keys) * 80, 1) * experience
    }
    var tidiness: Double {
        let keys = recent30Stats.reduce(0) { $0 + $1.keyCount }
        let selectAlls = recent30Stats.reduce(0) { $0 + $1.selectAllCount }
        guard keys > 0 else { return 0 }

        let experience = min(Double(keys) / 1_000, 1)
        return min(Double(selectAlls) / Double(keys) * 100, 1) * experience
    }

    //活動量キー
    var keyActivity: Double {
        guard !recentStats.isEmpty else { return 0 }
        let total = recentStats.reduce(0) { sum, day in
            sum + day.keyCount
        } 
        let dailyAverage = Double(total) / Double(recentStats.count)
        return min(dailyAverage / 10_000, 1)
    }
    //活動量クリック
    var clickActivity: Double {
        guard !recentStats.isEmpty else { return 0 }

        let total = recentStats.reduce(0) { sum, day in
            sum + day.leftClickCount + day.rightClickCount
        }
        let dailyAverage = Double(total) / Double(recentStats.count)

        return min(dailyAverage / 1_500, 1)
    }
    //活動量マウス
    var mouseActivity: Double {
        guard !recentStats.isEmpty else { return 0 }

        let total = recentStats.reduce(0.0) { sum, day in
            sum + day.mouseDistance
        }
        let dailyAverage = total / Double(recentStats.count)

        return min(dailyAverage / 2_000_000, 1)
    }
    //活動量(合計)
    var activityLevel: Double {
        (keyActivity + clickActivity + mouseActivity) / 3
    }
    var totalKeyCount: Int {
        dailyStats.reduce(0) { total, day in
            total + day.keyCount
        }
    }
    var creatureSize: CGFloat {
        45 + min(CGFloat(totalKeyCount) / 100_000, 1) * 15
    }
    var creatureHue: Double {
        let activeDays = recent30Stats.filter {
            $0.keyCount + $0.leftClickCount + $0.rightClickCount >= 50
        }.count
        let maturity = min(Double(activeDays) / 14, 1)
        return 0.35 + (colorTendency - 0.5) * 0.2 * maturity
    }
    var mossiness: Double {
        let totalClicks = dailyStats.reduce(0) { total, day in
            total + day.leftClickCount + day.rightClickCount
        }
        let keyProgress = min(Double(totalKeyCount) / 150_000, 1)
        let clickProgress = min(Double(totalClicks) / 30_000, 1)
        return (keyProgress + clickProgress) / 2
    }
    //権限関係↓
    private func requestAccessibilityPermission() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        let trusted = AXIsProcessTrustedWithOptions(options)

        print("Accessibility許可: \(trusted)")
    }
}
