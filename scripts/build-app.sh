#!/usr/bin/env bash
# Builds build/Watercan.app
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f AppIcon.icns ] || ./scripts/make-icon.sh
swift build -c release
APP="build/Watercan.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Watercan "$APP/Contents/MacOS/Watercan"
cp Info.plist "$APP/Contents/Info.plist"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --deep --sign - "$APP"
echo "Built $APP"
