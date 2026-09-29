import SwiftUI

// @main は、この型がアプリの入口であることを示します。
@main
struct MenuPetApp: App {
    @StateObject private var activityStore = ActivityStore()

    init() {
        let oldSettings = UserDefaults(suiteName: "MenuPet")
        let settings = UserDefaults.standard

        if settings.object(forKey: "creatureName") == nil,
           let name = oldSettings?.string(forKey: "creatureName") {
            settings.set(name, forKey: "creatureName")
        }
        if settings.object(forKey: "creatureClickCnt") == nil,
           let count = oldSettings?.object(forKey: "creatureClickCnt") as? Int {
            settings.set(count, forKey: "creatureClickCnt")
        }
    }

    var body: some Scene {
        MenuBarExtra("謎の生物", systemImage: "triangle.fill") {
            ContentView(activityStore: activityStore)
        }
        .menuBarExtraStyle(.window)
    }
}
