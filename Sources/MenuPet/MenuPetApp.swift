import SwiftUI

// @main は、この型がアプリの入口であることを示します。
@main
struct MenuPetApp: App {
    var body: some Scene {
        MenuBarExtra("謎の生物", systemImage: "triangle.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
