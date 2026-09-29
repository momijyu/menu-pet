#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_dir"

swift build -c release
binary_dir=$(swift build -c release --show-bin-path)
app_dir="$project_dir/dist/MenuPet.app"

mkdir -p "$app_dir/Contents/MacOS"
cp "$binary_dir/MenuPet" "$app_dir/Contents/MacOS/MenuPet"
cp "$project_dir/AppInfo.plist" "$app_dir/Contents/Info.plist"
codesign --force --sign - "$app_dir"

printf 'Built %s\n' "$app_dir"
