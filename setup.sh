#!/usr/bin/env bash
# One-time setup: move this folder to ~/workspace/watercan, create a PUBLIC GitHub repo, install the app.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/workspace/watercan"
mkdir -p "$HOME/workspace"
if [ "$SRC" != "$DEST" ]; then
  [ -e "$DEST" ] && { echo "$DEST already exists. Move or delete it first."; exit 1; }
  mv "$SRC" "$DEST"
fi
cd "$DEST"
gh auth status >/dev/null 2>&1 || gh auth login
[ -d .git ] || git init -b main
git add .
git commit -m "Initial commit: Watercan" || true
gh repo create watercan --public --source=. --remote=origin --push
./scripts/install.sh
echo "Done. Code is in $DEST"
