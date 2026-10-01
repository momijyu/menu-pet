import SwiftUI
import AppKit

// この中に、飼育スペースの見た目を少しずつ作っていきます。
struct ContentView: View {
    @AppStorage("creatureName")private var creatureName = "なぞちゃん"
    @AppStorage("creatureClickCnt")private var clickCnt = 0
    @AppStorage("lastWelcomedActivityDay") private var lastWelcomedActivityDay = 0.0
    @ObservedObject var activityStore: ActivityStore
    @State private var welcomeBackTrigger = 0
    #if DEBUG
    @State private var showingDebug = false
    @State private var isPreviewing = false
    @State private var previewControlsExpanded = true
    @State private var previewPersonalityExpanded = false
    @State private var previewActivityLevel = 0.0
    @State private var previewCaution = 0.0
    @State private var previewMimicry = 0.0
    @State private var previewAffection = 0.0
    @State private var previewExploration = 0.0
    @State private var previewCornerAffinity = 0.0
    @State private var previewFloatiness = 0.0
    @State private var previewBodyShape = 0.0
    @State private var previewHue = 0.35
    #endif

    private var displayedActivityLevel: Double {
        #if DEBUG
        if isPreviewing { return previewActivityLevel }
        #endif
        return activityStore.activityLevel
    }

    private var displayedCaution: Double {
        #if DEBUG
        if isPreviewing { return previewCaution }
        #endif
        return activityStore.caution
    }

    private var displayedMimicry: Double {
        #if DEBUG
        if isPreviewing { return previewMimicry }
        #endif
        return activityStore.mimicry
    }

    private var displayedAffection: Double {
        #if DEBUG
        if isPreviewing { return previewAffection }
        #endif
        return activityStore.affection
    }

    private var displayedExploration: Double {
        #if DEBUG
        if isPreviewing { return previewExploration }
        #endif
        return activityStore.exploration
    }

    private var displayedCornerAffinity: Double {
        #if DEBUG
        if isPreviewing { return previewCornerAffinity }
        #endif
        return activityStore.cornerAffinity
    }

    private var displayedFloatiness: Double {
        #if DEBUG
        if isPreviewing { return previewFloatiness }
        #endif
        return activityStore.floatiness
    }

    private var displayedBodyShape: Double {
        #if DEBUG
        if isPreviewing { return previewBodyShape }
        #endif
        return activityStore.bodyShape
    }

    private var displayedHue: Double {
        #if DEBUG
        if isPreviewing { return previewHue }
        #endif
        return activityStore.creatureHue
    }

    private var todayStats: DailyStats? {
        let today = Calendar.current.startOfDay(for: Date())

        return activityStore.dailyStats.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    private func greetAfterAbsenceIfNeeded() {
        guard let previousDay = activityStore.lastActiveDayBeforeToday,
              let dayGap = activityStore.daysSinceLastActiveDay,
              dayGap >= 4 else {
            return
        }
        let previousDayValue = previousDay.timeIntervalSince1970
        guard lastWelcomedActivityDay != previousDayValue else {
            return
        }
        lastWelcomedActivityDay = previousDayValue
        welcomeBackTrigger += 1
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("生物の名前", text: $creatureName)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                #if DEBUG
                if isPreviewing && !showingDebug {
                    Button("デバッグへ") {
                        showingDebug = true
                    }
                }
                Button(showingDebug ? "戻る" : isPreviewing ? "プレビュー終了" : "デバッグ") {
                    if showingDebug {
                        showingDebug = false
                    } else if isPreviewing {
                        isPreviewing = false
                    } else {
                        showingDebug = true
                    }
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
        .onDisappear {
            #if DEBUG
            isPreviewing = false
            #endif
        }
    }

    private var aquarium: some View {
        ZStack {
            Color(red: 0.88,green: 0.96, blue: 0.98)
            BubbleLayer(count: activityStore.bubbleCount)

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.82, blue: 0.65))
                    .frame(height: 50)
            }
            VStack {
                Spacer()
                CreatureView(
                    size: activityStore.creatureSize,
                    activityLevel: displayedActivityLevel,
                    caution: displayedCaution,
                    hue: displayedHue,
                    mossiness: activityStore.mossiness,
                    bodyShape: displayedBodyShape,
                    spaceJump: activityStore.spaceJump,
                    floatiness: displayedFloatiness,
                    mimicry: displayedMimicry,
                    affection: displayedAffection,
                    exploration: displayedExploration,
                    cornerAffinity: displayedCornerAffinity,
                    undoTendency: activityStore.undoTendency,
                    tidiness: activityStore.tidiness,
                    habitStrength: activityStore.habitStrength,
                    welcomeBackTrigger: welcomeBackTrigger,
                    sleepProfile: activityStore.sleepProfile,
                    onTap: {
                        #if DEBUG
                        guard !isPreviewing else { return }
                        #endif
                        clickCnt += 1
                        activityStore.recordPetClick()
                    }
                )
                .padding(.bottom, 58 + CGFloat(displayedActivityLevel) * 80)
            }
            #if DEBUG
            if isPreviewing {
                previewControls
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            greetAfterAbsenceIfNeeded()
        }
        .onDisappear {
            welcomeBackTrigger = 0
        }
    }

    #if DEBUG
    private var previewControls: some View {
        DisclosureGroup("調整パネル", isExpanded: $previewControlsExpanded) {
            VStack(alignment: .leading, spacing: 2) {
                Text("活動量: \(previewActivityLevel, specifier: "%.1f")")
                Slider(value: $previewActivityLevel, in: 0...1, step: 0.1)
                if !previewPersonalityExpanded {
                    Text("浮きやすさ: \(previewFloatiness, specifier: "%.1f")")
                    Slider(value: $previewFloatiness, in: 0...1, step: 0.1)
                    Text("体型: \(previewBodyShape, specifier: "%.1f")")
                    Slider(value: $previewBodyShape, in: -0.2...0.3, step: 0.1)
                    Text("色相: \(previewHue, specifier: "%.2f")")
                    Slider(value: $previewHue, in: 0.25...0.45, step: 0.01)
                }
                DisclosureGroup("性格", isExpanded: $previewPersonalityExpanded) {
                    Text("慎重さ: \(previewCaution, specifier: "%.1f")")
                    Slider(value: $previewCaution, in: 0...1, step: 0.1)
                    Text("ものまね度: \(previewMimicry, specifier: "%.1f")")
                    Slider(value: $previewMimicry, in: 0...1, step: 0.1)
                    Text("ふれあい度: \(previewAffection, specifier: "%.1f")")
                    Slider(value: $previewAffection, in: 0...1, step: 0.1)
                    Text("探検度: \(previewExploration, specifier: "%.1f")")
                    Slider(value: $previewExploration, in: 0...1, step: 0.1)
                    Text("すみっこ好き: \(previewCornerAffinity, specifier: "%.1f")")
                    Slider(value: $previewCornerAffinity, in: 0...1, step: 0.1)
                }
            }
        }
        .frame(width: 200)
        .padding(8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

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
                Button(isPreviewing ? "プレビューに戻る" : "動き・見た目のプレビューを開く") {
                    if !isPreviewing {
                        previewControlsExpanded = true
                        previewActivityLevel = activityStore.activityLevel
                        previewCaution = activityStore.caution
                        previewMimicry = activityStore.mimicry
                        previewAffection = activityStore.affection
                        previewExploration = activityStore.exploration
                        previewCornerAffinity = activityStore.cornerAffinity
                        previewFloatiness = activityStore.floatiness
                        previewBodyShape = activityStore.bodyShape
                        previewHue = activityStore.creatureHue
                        isPreviewing = true
                    }
                    showingDebug = false
                }
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
                        Text("矢印キー: \(todayStats?.arrowCount ?? 0)回")
                        Text("⌘C: \(todayStats?.copyCount ?? 0)回")
                        Text("⌘V: \(todayStats?.pasteCount ?? 0)回")
                        Text("⌘A: \(todayStats?.selectAllCount ?? 0)回")
                        Text("⌘Z: \(todayStats?.undoCount ?? 0)回")
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
                        Text("矢印キー: \(recent30Total(\.arrowCount))回")
                        Text("⌘C: \(recent30Total(\.copyCount))回")
                        Text("⌘V: \(recent30Total(\.pasteCount))回")
                        Text("⌘A: \(recent30Total(\.selectAllCount))回")
                        Text("⌘Z: \(recent30Total(\.undoCount))回")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("内部ステータス").font(.headline)
                    Text("慎重さ: \(activityStore.caution, specifier: "%.2f")")
                    Text("ものまね度: \(activityStore.mimicry, specifier: "%.2f")")
                    Text("ふれあい度: \(activityStore.affection, specifier: "%.2f")")
                    Text("探検度: \(activityStore.exploration, specifier: "%.2f")")
                    Text("すみっこ好き: \(activityStore.cornerAffinity, specifier: "%.2f")")
                    Text("うっかり度: \(activityStore.undoTendency, specifier: "%.2f")")
                    Text("整頓好き: \(activityStore.tidiness, specifier: "%.2f")")
                    Text("連続活動日: \(activityStore.consecutiveActiveDays)日")
                    Text("習慣度: \(activityStore.habitStrength, specifier: "%.2f")")
                    Text("キー活動量: \(activityStore.keyActivity, specifier: "%.2f")")
                    Text("クリック活動量: \(activityStore.clickActivity, specifier: "%.2f")")
                    Text("マウス活動量: \(activityStore.mouseActivity, specifier: "%.2f")")
                    Text("活動量: \(activityStore.activityLevel, specifier: "%.2f")")
                    Text("色傾向: \(activityStore.colorTendency, specifier: "%.2f")")
                    Text("モサモサ度: \(activityStore.mossiness, specifier: "%.2f")")
                    Text("Space跳ね: \(activityStore.spaceJump, specifier: "%.2f")")
                    Text("浮きやすさ: \(activityStore.floatiness, specifier: "%.2f")")
                    Text("体型: \(activityStore.bodyShape, specifier: "%.2f")")
                    Text("泡の数: \(activityStore.bubbleCount)個")
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
