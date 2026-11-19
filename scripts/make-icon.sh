#!/usr/bin/env bash
# Generates AppIcon.icns in the project root.
set -euo pipefail
cd "$(dirname "$0")/.."
swift scripts/make-icon.swift /tmp/watercan-1024.png
rm -rf Watercan.iconset && mkdir Watercan.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s /tmp/watercan-1024.png --out Watercan.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) /tmp/watercan-1024.png --out Watercan.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns Watercan.iconset -o AppIcon.icns
rm -rf Watercan.iconset
echo "Created AppIcon.icns"
