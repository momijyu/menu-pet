// swift-tools-version: 5.9
import PackageDescription

// アプリをビルドするための設定です。
let package = Package(
    name: "MenuPet",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "MenuPet")
    ]
)
