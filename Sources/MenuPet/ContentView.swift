import SwiftUI
import AppKit

// この中に、飼育スペースの見た目を少しずつ作っていきます。
struct ContentView: View {
    @AppStorage("creatureName")private var creatureName = "なぞちゃん"
    @AppStorage("creatureClickCnt")private var clickCnt = 0
    @ObservedObject var activityStore: ActivityStore

    private var todayClickCount: Int{
        let today = Calendar.current.startOfDay(for: Date())
        return activityStore.dailyStats.first(where: { $0.date == today })?.clickCount ?? 0
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
                activityStore.recordClick()
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
                    activityStore.saveDailyStats()
                }
                .disabled(!activityStore.hasLoaded)

                Button("終了"){
                    activityStore.saveDailyStats()
                    guard !activityStore.hasUnsavedChanges else{ return }

                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(16)
        }
        .onAppear(){
            activityStore.loadDailyStats()
        }
        .task{
            while !Task.isCancelled{
                do{
                    try await Task.sleep(for: .seconds(30))
                }catch{
                    return
                }
                activityStore.saveDailyStats()
            }
        }
    }
}
