#!/usr/bin/env bash
# Builds, moves the app to /Applications, and puts an alias on the Desktop.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/build-app.sh
rm -rf /Applications/Watercan.app
cp -R build/Watercan.app /Applications/Watercan.app
rm -f "$HOME/Desktop/Watercan"
osascript -e "tell application \"Finder\" to make alias file to POSIX file \"/Applications/Watercan.app\" at POSIX file \"$HOME/Desktop\""
open /Applications/Watercan.app
echo "Installed to /Applications and added Desktop shortcut."
