#!/usr/bin/env bash
# Deploys this repo to the live WoW retail AddOns folder.
#
# Trigger phrase (in chat): "ok im ready to test" → run this script.
#
# What it does:
#   1. Bumps the trailing version segment in AutoBodyRes.toc
#      (1.3.N → 1.3.(N+1)). Done first so a malformed .toc fails
#      fast before anything destructive happens to the live install.
#   2. Wipes /Applications/World of Warcraft/_retail_/Interface/AddOns/AutoBodyRes
#   3. Mirrors this repo into that path, excluding dev-only files
#
# Excludes (dev-only, not part of the addon distribution):
#   .git/             — version control
#   .gitignore        — version control
#   .DS_Store         — macOS Finder noise
#   .claude/          — agent state
#   .vscode/          — editor config
#   .luarc.json       — lua-language-server config
#   .libraries/       — Blizzard UI reference source (read-only docs for devs)
#   AGENTS.md         — agent instructions
#   CLAUDE.md         — agent instructions
#   README.md         — repo readme (not addon metadata)
#   CHANGELOG.md      — repo changelog (not part of addon distribution)
#   LICENSE           — repo legal file (GitHub only, not shipped with addon)
#   cspell.json       — spell-check config
#   stylua.toml       — lua formatter config
#   deploy-to-wow.sh  — this script itself
#
# Kept:
#   .toc / .xml / .lua  — addon code
#   libs/             — embedded Ace3 / LibStub / LibSharedMedia (required at runtime)
#   logo.tga          — addon logo

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/Applications/World of Warcraft/_retail_/Interface/AddOns/AutoBodyRes"

if [[ ! -d "$(dirname "$DEST")" ]]; then
  echo "ERROR: AddOns parent dir missing: $(dirname "$DEST")" >&2
  exit 1
fi

echo "Deploying"
echo "   from: $SRC"
echo "   to:   $DEST"

# --- Step 1: bump the .toc version --------------------------------------
# Only the trailing numeric segment is bumped (1.3.N -> 1.3.(N+1)).
# The prefix (1.3) is preserved — bump it manually for larger releases.
TOC="$SRC/AutoBodyRes.toc"
# tr -d '[:space:]' strips any trailing newline/CR/space from awk's output.
# Versions don't contain whitespace, so trimming is safe and avoids the
# subtle bug where `=~ ^[0-9]+$` rejects "8\n" because of the trailing newline.
current=$(awk -F': ' '/^## Version:/ { print $2; exit }' "$TOC" | tr -d '[:space:]')
if [[ -z "$current" ]]; then
  echo "ERROR: no '## Version:' line found in $TOC" >&2
  exit 1
fi
prefix="${current%.*}"
last="${current##*.}"
if ! [[ "$last" =~ ^[0-9]+$ ]]; then
  echo "ERROR: trailing version segment not numeric: '$last' (from '$current')" >&2
  exit 1
fi
next=$((last + 1))
new="${prefix}.${next}"
echo "Bumping version: $current -> $new"
# macOS BSD sed: -i '' = in-place, no backup file.
sed -i '' -E "s/^(## Version:) .*/\1 ${new}/" "$TOC"

# --- Step 2: wipe-and-replace the live install --------------------------
# Per the user's spec ("delete the existing folder... replace with a copy
# of the repo folder"). rsync --delete would also work; the explicit rm
# makes intent obvious and guarantees no orphan files survive between
# deploys.
rm -rf "$DEST"
mkdir -p "$DEST"

rsync -a \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='.DS_Store' \
  --exclude='.claude/' \
  --exclude='.vscode/' \
  --exclude='.luarc.json' \
  --exclude='.libraries/' \
  --exclude='AGENTS.md' \
  --exclude='CLAUDE.md' \
  --exclude='README.md' \
  --exclude='CHANGELOG.md' \
  --exclude='LICENSE' \
  --exclude='cspell.json' \
  --exclude='stylua.toml' \
  --exclude='deploy-to-wow.sh' \
  "$SRC/" "$DEST/"

echo "Done. Reload UI in-game (/reload) or relaunch the client to pick up changes."
