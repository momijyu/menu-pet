import SwiftUI
import AppKit

// この中に、飼育スペースの見た目を少しずつ作っていきます。
struct ContentView: View {
    @AppStorage("creatureName")private var creatureName = "なぞちゃん"
    @AppStorage("creatureClickCnt")private var clickCnt = 0
    @State private var dailyStats: [DailyStats] = []
    @State private var hasLoaded = false
    @State private var hasUnsavedChanges = false
    private var todayClickCount: Int{
        let today = Calendar.current.startOfDay(for: Date())
        return dailyStats.first(where: { $0.date == today })?.clickCount ?? 0
    }
    var body: some View {
        ZStack{
            Color(red: 0.88,green: 0.96, blue: 0.98)

            VStack{
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.82, blue: 0.65))
                    .frame( height: 50)
            }
            CreatureView(size: 45, onTap: {
                clickCnt += 1
                recordClick()
            })
        }
        .frame(width: 360, height: 420)
        .overlay(alignment: .top) {
            TextField("生物の名前", text: $creatureName)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .padding(16)
        }
        .overlay(alignment: .bottom) {
            HStack{
                Text("今日:\(todayClickCount)回")
                Text("累計:\(clickCnt)回")

                Button("保存"){
                    saveDailyStats()
                }
                .disabled(!hasLoaded)

                Button("終了"){
                    saveDailyStats()
                    guard !hasUnsavedChanges else{ return }

                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(16)
        }
        .onAppear(){
            loadDailyStats()
        }
        .task{
            while !Task.isCancelled{
                do{
                    try await Task.sleep(for: .seconds(30))
                }catch{
                    return
                }
                saveDailyStats()
            }
        }
    }
    private func recordClick(){
        let today = Calendar.current.startOfDay(for: Date())
        if let index = dailyStats.firstIndex(where: { $0.date == today }) {
            dailyStats[index].clickCount += 1
        }else{
            dailyStats.append(
                    DailyStats(date: today, clickCount: 1) 
                )
        }

        hasUnsavedChanges = true
    }
    private func saveDailyStats(){
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
}
