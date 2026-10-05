import SwiftUI
import AppKit

// この中に、飼育スペースの見た目を少しずつ作っていきます。
struct ContentView: View {
    @AppStorage("creatureName")private var creatureName = "なぞちゃん"
    @AppStorage("creatureClickCnt")private var clickCnt = 0
    @AppStorage("lastWelcomedActivityDay") private var lastWelcomedActivityDay = 0.0
    @AppStorage("lastStreakGreetingDay") private var lastStreakGreetingDay = 0.0
    @ObservedObject var activityStore: ActivityStore
    @State private var welcomeBackTrigger = 0
    @State private var streakGreetingTrigger = 0
    @State private var aquariumDate = Date()
    @State private var showingAchievements = false
    @State private var isPopoverVisible = false
    #if DEBUG
    @State private var showingDebug = false
    @State private var isPreviewing = false
    @State private var previewControlsExpanded = true
    @State private var previewPersonalityExpanded = false
    @State private var previewActivityLevel = 0.0
    @State private var previewBubbleCount = 4
    @State private var previewHeartSparkle = false
    @State private var previewFlowerAccessory = false
    @State private var previewCaution = 0.0
    @State private var previewMimicry = 0.0
    @State private var previewAffection = 0.0
    @State private var previewExploration = 0.0
    @State private var previewCornerAffinity = 0.0
    @State private var previewFloatiness = 0.0
    @State private var previewBodyShape = 0.0
    @State private var previewHue = 0.35
    @State private var previewAquariumHour = 12
    @State private var previewSpaceJump = 0.8
    @State private var previewLandingRing = false
    @State private var previewMimicBubbles = false
    @State private var previewDecisionSparkle = false
    @State private var previewHesitation = false
    @State private var previewBubbleTrail = false
    @State private var previewWaterPlant = false
    @State private var previewExtraWaterPlants = 0
    @State private var previewNightGlow = false
    @State private var previewUndoEcho = false
    @State private var previewNightStars = false
    @State private var previewNightMoon = false
    @State private var previewSandSparkleLevel = 0
    @State private var previewAchievementKind = 0
    @State private var previewBadgesInAchievements = true
    #endif

    private var displayedAquariumHour: Double {
        #if DEBUG
        if isPreviewing { return Double(previewAquariumHour) }
        #endif
        let hour = Calendar.current.component(.hour, from: aquariumDate)
        let minute = Calendar.current.component(.minute, from: aquariumDate)
        return Double(hour) + Double(minute) / 60
    }

    private var daylightLevel: Double {
        func smoothstep(_ start: Double, _ end: Double) -> Double {
            let progress = min(max((displayedAquariumHour - start) / (end - start), 0), 1)
            return progress * progress * (3 - 2 * progress)
        }
        return min(smoothstep(5, 8), 1 - smoothstep(17, 20))
    }

    private var waterColor: Color {
        Color(
            red: 0.10 + 0.78 * daylightLevel,
            green: 0.20 + 0.76 * daylightLevel,
            blue: 0.32 + 0.66 * daylightLevel
        )
    }

    private var sandColor: Color {
        Color(
            red: 0.37 + 0.51 * daylightLevel,
            green: 0.37 + 0.45 * daylightLevel,
            blue: 0.40 + 0.25 * daylightLevel
        )
    }

    private var displayedActivityLevel: Double {
        #if DEBUG
        if isPreviewing { return previewActivityLevel }
        #endif
        return activityStore.activityLevel
    }

    private var displayedBubbleCount: Int {
        #if DEBUG
        if isPreviewing { return previewBubbleCount }
        #endif
        return activityStore.bubbleCount
    }

    private var displayedSparkleChance: Double {
        #if DEBUG
        if isPreviewing { return previewHeartSparkle ? 1 : 0 }
        #endif
        return activityStore.hasHeartSparkle ? 0.3 : 0
    }

    private var displayedFlowerAccessory: Bool {
        #if DEBUG
        if isPreviewing { return previewFlowerAccessory }
        #endif
        return activityStore.hasFamiliarPlace
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

    private var displayedSpaceJump: Double {
        #if DEBUG
        if isPreviewing { return previewSpaceJump }
        #endif
        return activityStore.spaceJump
    }

    private var landingRingChance: Double {
        // 水槽が夜（20〜5時）の間だけ、着地の輪を出す。
        guard daylightLevel == 0 else { return 0 }
        #if DEBUG
        if isPreviewing { return previewLandingRing ? 1 : 0 }
        #endif
        return activityStore.landingRingChance
    }

    private var mimicBubbleChance: Double {
        #if DEBUG
        if isPreviewing { return previewMimicBubbles ? 1 : 0 }
        #endif
        return activityStore.mimicBubbleChance
    }

    private var decisionSparkleChance: Double {
        #if DEBUG
        if isPreviewing { return previewDecisionSparkle ? 1 : 0 }
        #endif
        return activityStore.decisionSparkleChance
    }

    private var hesitationChance: Double {
        #if DEBUG
        if isPreviewing { return previewHesitation ? 1 : 0 }
        #endif
        return activityStore.hesitationChance
    }

    private var showsBubbleTrail: Bool {
        #if DEBUG
        if isPreviewing { return previewBubbleTrail }
        #endif
        return activityStore.hasBubbleTrail
    }

    private var showsWaterPlant: Bool {
        #if DEBUG
        if isPreviewing { return previewWaterPlant }
        #endif
        return activityStore.hasWaterPlant
    }

    private var showsNightGlow: Bool {
        #if DEBUG
        if isPreviewing { return previewNightGlow && daylightLevel < 0.25 }
        #endif
        return activityStore.hasNightGlow && daylightLevel < 0.25
    }

    private var undoEchoChance: Double {
        #if DEBUG
        if isPreviewing { return previewUndoEcho ? 1 : 0 }
        #endif
        return activityStore.undoEchoChance
    }

    private var nightStarCount: Int {
        guard daylightLevel == 0 else { return 0 }
        #if DEBUG
        if isPreviewing { return previewNightStars ? 4 : 0 }
        #endif
        return activityStore.nightStarCount
    }

    private var showsNightMoon: Bool {
        guard daylightLevel == 0 else { return false }
        #if DEBUG
        if isPreviewing { return previewNightMoon }
        #endif
        return activityStore.hasNightMoon
    }

    private var sandSparkleLevel: Int {
        #if DEBUG
        if isPreviewing { return previewSandSparkleLevel }
        #endif
        return activityStore.sandSparkleLevel
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
    private func greetForStreakIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        guard activityStore.consecutiveActiveDays >= AchievementGoals.activeStreak[0],
              lastStreakGreetingDay != today else { return }
        lastStreakGreetingDay = today
        streakGreetingTrigger += 1
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("生物の名前", text: $creatureName)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                #if DEBUG
                if !showingAchievements {
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
                }
                #endif
            }
            .padding(12)

            if showingAchievements {
                achievementsPage
            } else {
                #if DEBUG
                if showingDebug {
                    debugPage
                } else {
                    aquarium
                }
                #else
                aquarium
                #endif
            }

            HStack {
                Button(showingAchievements ? "水槽に戻る" : "実績") {
                    if !showingAchievements {
                        #if DEBUG
                        showingDebug = false
                        isPreviewing = false
                        #endif
                    }
                    showingAchievements.toggle()
                }

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
        .onAppear {
            guard !isPopoverVisible else { return }
            isPopoverVisible = true
            activityStore.recordVisit()
        }
        .onDisappear {
            isPopoverVisible = false
            showingAchievements = false
            #if DEBUG
            isPreviewing = false
            #endif
        }
    }

    private var aquarium: some View {
        ZStack {
            waterColor
                .animation(.easeInOut(duration: 1.5), value: daylightLevel)
            if showsNightMoon {
                AquariumMoonView()
                    .transition(.opacity)
            }
            BubbleLayer(
                count: displayedBubbleCount,
                affection: displayedAffection,
                sparkleChance: displayedSparkleChance,
                mimicChance: mimicBubbleChance,
                creatureHue: displayedHue
            )
            if nightStarCount > 0 {
                NightStarsView(count: nightStarCount)
            }
            if showsWaterPlant {
                VStack {
                    Spacer()
                    WaterPlantView()
                        .frame(width: 80, height: 105)
                        .padding(.bottom, 47)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .allowsHitTesting(false)
            }
            #if DEBUG
            if isPreviewing && previewExtraWaterPlants >= 1 {
                VStack {
                    Spacer()
                    AquaticGrassView(compact: false)
                        .frame(width: 72, height: 126)
                        .padding(.bottom, 47)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 12)
                .allowsHitTesting(false)
            }
            if isPreviewing && previewExtraWaterPlants >= 2 {
                VStack {
                    Spacer()
                    AquaticGrassView(compact: true)
                        .frame(width: 58, height: 55)
                        .padding(.bottom, 47)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 105)
                .allowsHitTesting(false)
            }
            #endif

            VStack {
                Spacer()
                Rectangle()
                    .fill(sandColor)
                    .frame(height: 50)
                    .overlay {
                        if sandSparkleLevel > 0 {
                            SandSparklesView(level: sandSparkleLevel)
                                .id(sandSparkleLevel)
                        }
                    }
                    .animation(.easeInOut(duration: 1.5), value: daylightLevel)
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
                    spaceJump: displayedSpaceJump,
                    floatiness: displayedFloatiness,
                    mimicry: displayedMimicry,
                    affection: displayedAffection,
                    exploration: displayedExploration,
                    cornerAffinity: displayedCornerAffinity,
                    undoTendency: activityStore.undoTendency,
                    tidiness: activityStore.tidiness,
                    habitStrength: activityStore.habitStrength,
                    showsFlowerAccessory: displayedFlowerAccessory,
                    welcomeBackTrigger: welcomeBackTrigger,
                    streakGreetingTrigger: streakGreetingTrigger,
                    sleepProfile: activityStore.sleepProfile,
                    landingRingChance: landingRingChance,
                    decisionSparkleChance: decisionSparkleChance,
                    hesitationChance: hesitationChance,
                    showsBubbleTrail: showsBubbleTrail,
                    showsNightGlow: showsNightGlow,
                    undoEchoChance: undoEchoChance,
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
        .animation(.easeInOut(duration: 1.5), value: showsNightMoon)
        .onAppear {
            aquariumDate = Date()
            greetAfterAbsenceIfNeeded()
            greetForStreakIfNeeded()
        }
        .task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(60))
                } catch {
                    return
                }
                aquariumDate = Date()
            }
        }
        .onDisappear {
            welcomeBackTrigger = 0
            streakGreetingTrigger = 0
        }
    }

    private var achievementsPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                #if DEBUG
                Toggle("バッジ配置プレビュー", isOn: $previewBadgesInAchievements)
                #endif
                achievementRows
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var achievementRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            achievementRow("会いに来てくれた", count: activityStore.petTouchDays,
                           goal: 20, unit: "日")
            achievementRow("いつもの場所", count: activityStore.totalActiveDays,
                           goal: 30, unit: "日")
            achievementRow("根を張る", count: activityStore.totalActiveDays,
                           goal: AchievementGoals.waterPlantActiveDays, unit: "日")
            keyAchievementRow("ずっと一緒", count: activityStore.longestActiveStreak,
                              milestones: AchievementGoals.activeStreak, symbol: "♡", unit: "日")
            keyAchievementRow("夜の常連", count: activityStore.nightActivityDays,
                              milestones: AchievementGoals.nightActivityDays, symbol: "✦", unit: "日")
            keyAchievementRow("また来たよ", count: activityStore.visitAchievementCount,
                              milestones: AchievementGoals.visits, symbol: "⌂")
            keyAchievementRow("なかよしの証", count: activityStore.petTouchAchievementCount,
                              milestones: AchievementGoals.petTouches, symbol: "♡")
            #if DEBUG
            Text("訪問は1日最大3回、ふれあいは1日最大5回を実績に加算")
                .font(.caption)
                .foregroundStyle(.secondary)
            #endif
            Divider()
            keyAchievementRow("積み重ね", count: activityStore.totalKeyCount,
                              milestones: AchievementGoals.allKeys, symbol: "⌨")
            keyAchievementRow("決めた！", count: activityStore.totalCount(for: \.enterCount),
                              milestones: AchievementGoals.enter, symbol: "↵")
            keyAchievementRow("ひとっ飛び", count: activityStore.totalCount(for: \.spaceCount),
                              milestones: AchievementGoals.space, symbol: "━")
            keyAchievementRow("考え直し", count: activityStore.totalCount(for: \.backspaceCount),
                              milestones: AchievementGoals.backspace, symbol: "⌫")
            keyAchievementRow("道しるべ", count: activityStore.totalCount(for: \.arrowCount),
                              milestones: AchievementGoals.arrows, symbol: "✥")
            keyAchievementRow("ものまね好き", count: activityStore.totalCopyPasteCount,
                              milestones: AchievementGoals.copyPaste, symbol: "⧉")
            keyAchievementRow("やり直し上手", count: activityStore.totalCount(for: \.undoCount),
                              milestones: AchievementGoals.undo, symbol: "↶")
            keyAchievementRow("きれい好き", count: activityStore.totalCount(for: \.selectAllCount),
                              milestones: AchievementGoals.selectAll, symbol: "▦")
            keyAchievementRow("水槽の旅人", count: activityStore.totalMouseDistance,
                              milestones: AchievementGoals.mouseDistance, symbol: "≈", unit: "pt")
        }
    }

    private func keyAchievementRow(_ title: String, count: Int, milestones: [Int], symbol: String,
                                   unit: String = "回") -> some View {
        let reached = milestones.prefix { count >= $0 }.count
        let previousGoal = reached == 0 ? 0 : milestones[reached - 1]
        let medalNames = ["銅", "銀", "金"]
        let status = reached == 0 ? "未獲得" : reached == milestones.count
            ? "トロフィー獲得" : "\(medalNames[reached - 1])メダル獲得"
        #if DEBUG
        let showBadges = showingAchievements && previewBadgesInAchievements
        #else
        let showBadges = true
        #endif

        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(status)
                    .foregroundStyle(reached > 0 ? Color.green : Color.secondary)
            }
            if reached < milestones.count {
                let nextGoal = milestones[reached]
                ProgressView(value: Double(min(count - previousGoal, nextGoal - previousGoal)),
                             total: Double(nextGoal - previousGoal))
                #if DEBUG
                Text("累計 \(count.formatted()) \(unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                #endif
            } else {
                ProgressView(value: 1, total: 1)
                #if DEBUG
                Text("累計 \(count.formatted()) \(unit)・最終目標達成")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                #endif
            }
            #if DEBUG
            Text("区切り: \(milestones.map { $0.formatted() }.joined(separator: " → ")) \(unit)")
                .font(.caption)
                .foregroundStyle(.secondary)
            #endif
            if showBadges {
                HStack(spacing: 8) {
                    ForEach(0..<milestones.count, id: \.self) { tier in
                        AchievementBadgeView(symbol: symbol, tier: tier, isUnlocked: tier < reached)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func achievementRow(
        _ title: String,
        count: Int,
        goal: Int,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(count >= goal ? "獲得" : "未獲得")
                    .foregroundStyle(count >= goal ? Color.green : Color.secondary)
            }
            ProgressView(value: Double(min(count, goal)), total: Double(goal))
            #if DEBUG
            Text("\(count.formatted()) / \(goal.formatted()) \(unit)")
                .font(.caption)
                .foregroundStyle(.secondary)
            #endif
        }
    }

    #if DEBUG
    private func openPreview() {
        if !isPreviewing {
            previewControlsExpanded = true
            previewActivityLevel = activityStore.activityLevel
            previewBubbleCount = activityStore.bubbleCount
            previewHeartSparkle = activityStore.hasHeartSparkle
            previewFlowerAccessory = activityStore.hasFamiliarPlace
            previewCaution = activityStore.caution
            previewMimicry = activityStore.mimicry
            previewAffection = activityStore.affection
            previewExploration = activityStore.exploration
            previewCornerAffinity = activityStore.cornerAffinity
            previewFloatiness = activityStore.floatiness
            previewBodyShape = activityStore.bodyShape
            previewHue = activityStore.creatureHue
            previewAquariumHour = Calendar.current.component(.hour, from: Date())
            isPreviewing = true
        }
        showingDebug = false
    }

    private var previewControls: some View {
        DisclosureGroup("調整パネル", isExpanded: $previewControlsExpanded) {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    DisclosureGroup("実績ごほうび") {
                        Toggle("夜の輪っか泡（毎回）", isOn: $previewLandingRing)
                            .onChange(of: previewLandingRing) { enabled in
                                if enabled { previewAquariumHour = 22 }
                            }
                        Toggle("ものまね泡（毎回）", isOn: $previewMimicBubbles)
                        Toggle("決断のきらめき（毎回）", isOn: $previewDecisionSparkle)
                        Toggle("考え直しの揺れ（毎回）", isOn: $previewHesitation)
                        Toggle("移動中の泡の軌跡", isOn: $previewBubbleTrail)
                        Toggle("小さな水草", isOn: $previewWaterPlant)
                        Stepper("追加の水草: \(previewExtraWaterPlants)株",
                                value: $previewExtraWaterPlants, in: 0...2)
                        Toggle("夜の淡い発光", isOn: $previewNightGlow)
                        Toggle("やり直しの残像（毎回）", isOn: $previewUndoEcho)
                        Toggle("夜の小さな星", isOn: $previewNightStars)
                            .onChange(of: previewNightStars) { enabled in
                                if enabled { previewAquariumHour = 22 }
                            }
                        Toggle("ぼんやりした月", isOn: $previewNightMoon)
                            .onChange(of: previewNightMoon) { enabled in
                                if enabled { previewAquariumHour = 22 }
                            }
                        Stepper("砂のきらめき: \(previewSandSparkleLevel)段階",
                                value: $previewSandSparkleLevel, in: 0...4)
                        Button("連続記録の挨拶を再生") {
                            streakGreetingTrigger += 1
                        }
                        Text("跳ねやすさ: \(previewSpaceJump, specifier: "%.1f")")
                        Slider(value: $previewSpaceJump, in: 0...1, step: 0.1)
                    }
                    Text("活動量: \(previewActivityLevel, specifier: "%.1f")")
                    Slider(value: $previewActivityLevel, in: 0...1, step: 0.1)
                    Stepper("泡: \(previewBubbleCount)個", value: $previewBubbleCount, in: 2...16)
                    Toggle("きらめき確認", isOn: $previewHeartSparkle)
                    Toggle("花飾り", isOn: $previewFlowerAccessory)
                    Stepper("水槽の時刻: \(previewAquariumHour)時", value: $previewAquariumHour, in: 0...23)
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
                        Text("ふれあい度: \(previewAffection, specifier: "%.2f")")
                        Slider(value: $previewAffection, in: 0...1, step: 0.05)
                        Text("探検度: \(previewExploration, specifier: "%.1f")")
                        Slider(value: $previewExploration, in: 0...1, step: 0.1)
                        Text("すみっこ好き: \(previewCornerAffinity, specifier: "%.1f")")
                        Slider(value: $previewCornerAffinity, in: 0...1, step: 0.1)
                    }
                }
            }
            .frame(height: 235)
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

    private var achievementBadgePreview: some View {
        let symbols = ["⌨", "↵", "━", "⌫", "✥"]

        return VStack(alignment: .leading, spacing: 8) {
            Text("実績バッジの試作").font(.headline)
            Picker("キー", selection: $previewAchievementKind) {
                Text("全キー入力").tag(0)
                Text("Enter").tag(1)
                Text("Space").tag(2)
                Text("Backspace").tag(3)
                Text("矢印キー").tag(4)
            }
            .pickerStyle(.menu)

            HStack(spacing: 8) {
                ForEach(0..<4) { tier in
                    AchievementBadgeView(symbol: symbols[previewAchievementKind], tier: tier, isUnlocked: true)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("見た目の確認用です。達成状況には連動しません。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var debugPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Button(isPreviewing ? "プレビューに戻る" : "動き・見た目のプレビューを開く") {
                    openPreview()
                }
                achievementBadgePreview
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日・全期間").font(.headline)
                    Group {
                        Text("ペット累計: \(clickCnt)回")
                        Text("ペット今日: \(todayStats?.petClickCount ?? 0)回")
                        Text("訪問今日: \(todayStats?.visitCount ?? 0)回")
                        Text("訪問累計: \(activityStore.totalVisitCount)回（5分以上の間隔）")
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
                    Text("実績").font(.headline)
                    achievementRows
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
