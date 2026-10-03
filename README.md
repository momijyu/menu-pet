# menu-pet

macOSのメニューバーで謎の生物を飼うアプリです。Macを普段どおり使うことが育成になり、操作の集計に応じて見た目や動き、生活リズムが少しずつ変わります。餌やりのような毎日の操作は必要ありません。

現在は、メニューバーから小さな水槽を開き、まりもを眺められます。キー入力・クリック・マウス移動を日ごとに集計し、成長や行動に反映しています。水槽は時刻に合わせて昼夜の色が変わり、開いている間だけ生物や泡が動きます。

## 動作環境・使用言語

- macOS 13以降
- 使用言語: Swift
- UIフレームワーク: SwiftUI（画面とメニューバーアプリ）
- AppKit の `NSEvent`（キー・クリックの監視）
- ApplicationServices（アクセシビリティ権限の確認）
- Swift Package Manager（ビルド）

## 使い方

リポジトリのフォルダで、次を実行します。

```sh
swift run
```

メニューバーに現れる仮アイコン（三角形）をクリックすると水槽が開きます。「保存」で集計データを保存し、「終了」で保存してアプリを閉じます。`swift run` の開発版には、動きや見た目を試すデバッグ画面もあります。

アプリ形式で起動する場合は、次のコマンドで `dist/MenuPet.app` を作れます。

```sh
sh scripts/build-app.sh
open dist/MenuPet.app
```

## 権限とプライバシー

ほかのアプリを使っている間のキーやクリックを数えるため、起動時にmacOSのアクセシビリティ権限を確認します。案内が出た場合は「システム設定」→「プライバシーとセキュリティ」→「アクセシビリティ」で許可してください。キー入力が集計されない場合は、同じ画面の「入力監視」も確認してください。

**キー入力イベントは受け取りますが、入力された文章を文字列として取得・保存していません。** コードが参照するのはキーコードと⌘キーが押されているかどうかで、`event.characters` は参照しません。保存するのは総入力数や特定キー・ショートカットの回数などの集計値です。入力した文字列、パスワード、キーを押した順序は保存しません。マウスの軌跡も保存せず、移動距離だけを集計します。

日ごとの集計はローカルの `~/Library/Application Support/MenuPet/daily-stats.json` に保存します。変更があるときに約30秒ごとに自動保存し、次回起動時に読み込みます。生物の名前などの設定はmacOSの `UserDefaults` に保存します。

## ディレクトリ構成

```text
menu-pet/
├── Package.swift                 Swift Package Managerの設定
├── AppInfo.plist                 アプリ形式の設定
├── Sources/MenuPet/
│   ├── MenuPetApp.swift          起動点・MenuBarExtra
│   ├── ContentView.swift         水槽とデバッグ画面
│   ├── CreatureView.swift        生物の見た目と動き
│   ├── BubbleView.swift          泡の表示
│   ├── ActivityStore.swift       操作の集計・保存・成長の計算
│   ├── DailyStats.swift          日次データの形式
│   └── SleepProfile.swift        睡眠リズムの判定
├── scripts/build-app.sh          .appを作るスクリプト
└── assets/                       現在は未使用の試作画像
```
