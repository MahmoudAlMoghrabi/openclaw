#!/usr/bin/env bash
# Run this after you EDIT a skill in skills/, so your agent picks up the change.
#
# WHY IT'S NEEDED: OpenClaw runs your agent against an installed COPY of each
# skill (in ~/.openclaw/workspace/skills/), not the file in this repo. So editing
# skills/<name>/SKILL.md does nothing until the copy is refreshed and the gateway
# reloads it. This script does both.
#
# Usage:  ./scripts/reload-skill.sh [skill-name]     (defaults to my-first-skill)
set -euo pipefail

CLI="openclaw"
if ! command -v "$CLI" >/dev/null 2>&1; then
  CLI="clawdbot"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL="${1:-my-first-skill}"
DIR="$HERE/../skills/$SKILL"
DEST="$HOME/.openclaw/workspace/skills/$SKILL"

if [ ! -d "$DIR" ]; then
  echo "No skill folder at skills/$SKILL. Check the name."
  exit 1
fi

echo "Reloading skill '$SKILL'..."
# Re-install over the existing copy. Prefer --force; if this build doesn't accept
# that flag, replace the copy cleanly (a fresh install always works).
if ! "$CLI" skills install "$DIR" --force >/dev/null 2>&1; then
  rm -rf "$DEST"
  "$CLI" skills install "$DIR" >/dev/null
fi

# Restart the gateway so the running agent loads the new version.
bash "$HERE/start-gateway.sh"

echo ""
echo "Done. Refresh your agent's browser tab, then try your skill again:"
echo "    \"use the $SKILL skill\""
