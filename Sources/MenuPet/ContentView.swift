import SwiftUI
import AppKit

// この中に、飼育スペースの見た目を少しずつ作っていきます。
struct ContentView: View {
    @AppStorage("creatureName")private var creatureName = "なぞちゃん"
    @AppStorage("creatureClickCnt")private var clickCnt = 0
    @ObservedObject var activityStore: ActivityStore
    #if DEBUG
    @State private var showingDebug = false
    #endif

    private var todayStats: DailyStats? {
        let today = Calendar.current.startOfDay(for: Date())

        return activityStore.dailyStats.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("生物の名前", text: $creatureName)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                #if DEBUG
                Button(showingDebug ? "戻る" : "デバッグ") {
                    showingDebug.toggle()
                }
                #endif
            }
            .padding(12)

            #if DEBUG
            if showingDebug {
                debugPage
            } else {
                aquarium
            }
            #else
            aquarium
            #endif

            HStack {
                Button("保存") {
                    activityStore.saveDailyStats()
                }
                .disabled(!activityStore.hasLoaded)

                Button("終了") {
                    activityStore.saveDailyStats()
                    guard !activityStore.hasUnsavedChanges else { return }
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(12)
        }
        .frame(width: 360, height: 420)
    }

    private var aquarium: some View {
        ZStack {
            Color(red: 0.88,green: 0.96, blue: 0.98)

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.82, blue: 0.65))
                    .frame(height: 50)
            }
            CreatureView(
                size: activityStore.creatureSize,
                activityLevel: activityStore.activityLevel,
                caution: activityStore.caution,
                hue: activityStore.creatureHue,
                mossiness: activityStore.mossiness,
                spaceJump: activityStore.spaceJump,
                sleepProfile: activityStore.sleepProfile,
                onTap: {
                    clickCnt += 1
                    activityStore.recordPetClick()
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    #if DEBUG
    private func recent30Total(_ keyPath: KeyPath<DailyStats, Int>) -> Int {
        activityStore.recent30Stats.reduce(0) { total, day in
            total + day[keyPath: keyPath]
        }
    }

    private var recent30MouseDistance: Double {
        activityStore.recent30Stats.reduce(0) { total, day in
            total + day.mouseDistance
        }
    }

    private var debugPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日・全期間").font(.headline)
                    Group {
                        Text("ペット累計: \(clickCnt)回")
                        Text("ペット今日: \(todayStats?.petClickCount ?? 0)回")
                        Text("左クリック: \(todayStats?.leftClickCount ?? 0)回")
                        Text("右クリック: \(todayStats?.rightClickCount ?? 0)回")
                        Text("マウス移動: \(todayStats?.mouseDistance ?? 0, specifier: "%.0f")pt")
                        Text("キー今日: \(todayStats?.keyCount ?? 0)回")
                        Text("キー累計: \(activityStore.totalKeyCount)回")
                    }
                    Group {
                        Text("Backspace: \(todayStats?.backspaceCount ?? 0)回")
                        Text("Enter: \(todayStats?.enterCount ?? 0)回")
                        Text("Space: \(todayStats?.spaceCount ?? 0)回")
                        Text("⌘C: \(todayStats?.copyCount ?? 0)回")
                        Text("⌘V: \(todayStats?.pasteCount ?? 0)回")
                        Text("⌘A: \(todayStats?.selectAllCount ?? 0)回")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("直近30日合計").font(.headline)
                    Text("記録のある日: \(activityStore.recent30Stats.count)日")
                    Group {
                        Text("ペット: \(recent30Total(\.petClickCount))回")
                        Text("左クリック: \(recent30Total(\.leftClickCount))回")
                        Text("右クリック: \(recent30Total(\.rightClickCount))回")
                        Text("マウス移動: \(recent30MouseDistance, specifier: "%.0f")pt")
                        Text("キー入力: \(recent30Total(\.keyCount))回")
                        Text("Backspace: \(recent30Total(\.backspaceCount))回")
                        Text("Enter: \(recent30Total(\.enterCount))回")
                    }
                    Group {
                        Text("Space: \(recent30Total(\.spaceCount))回")
                        Text("⌘C: \(recent30Total(\.copyCount))回")
                        Text("⌘V: \(recent30Total(\.pasteCount))回")
                        Text("⌘A: \(recent30Total(\.selectAllCount))回")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("内部ステータス").font(.headline)
                    Text("慎重さ: \(activityStore.caution, specifier: "%.2f")")
                    Text("キー活動量: \(activityStore.keyActivity, specifier: "%.2f")")
                    Text("クリック活動量: \(activityStore.clickActivity, specifier: "%.2f")")
                    Text("マウス活動量: \(activityStore.mouseActivity, specifier: "%.2f")")
                    Text("活動量: \(activityStore.activityLevel, specifier: "%.2f")")
                    Text("色傾向: \(activityStore.colorTendency, specifier: "%.2f")")
                    Text("モサモサ度: \(activityStore.mossiness, specifier: "%.2f")")
                    Text("Space跳ね: \(activityStore.spaceJump, specifier: "%.2f")")
                    Text("睡眠の型: \(activityStore.sleepProfile.rhythm.name)")
                    Text("睡眠タイプ: \(activityStore.sleepProfile.trait?.name ?? "なし")")
                    Text("睡眠時間: \(activityStore.sleepProfile.sleepDescription)")
                    Text("睡眠判定の活動日: \(activityStore.sleepSampleDays)/14日")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
    #endif
}
