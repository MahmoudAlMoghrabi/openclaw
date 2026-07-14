#!/usr/bin/env bash
# Run this after you EDIT a skill in skills/, so your agent picks up the change.
#
# WHY IT'S NEEDED: OpenClaw runs your agent against an installed COPY of each
# skill (in ~/.openclaw/workspace/skills/), not the file in this repo. So editing
# skills/<name>/SKILL.md does nothing until the copy is refreshed and the gateway
# reloads it. This script does both.
#
# Usage:
#   ./scripts/reload-skill.sh                   reload EVERY skill in skills/
#   ./scripts/reload-skill.sh <name> [name...]  reload just the named skill(s)
set -euo pipefail

CLI="openclaw"
if ! command -v "$CLI" >/dev/null 2>&1; then
  CLI="clawdbot"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HERE/../skills"

# No names given? Reload every folder that holds a SKILL.md. One command,
# nothing to remember, nothing left stale.
if [ "$#" -eq 0 ]; then
  NAMES=()
  for d in "$SKILLS_DIR"/*/; do
    [ -f "${d}SKILL.md" ] && NAMES+=("$(basename "$d")")
  done
  if [ "${#NAMES[@]}" -eq 0 ]; then
    echo "No skills found in skills/."
    exit 1
  fi
  set -- "${NAMES[@]}"
fi

for SKILL in "$@"; do
  DIR="$SKILLS_DIR/$SKILL"
  DEST="$HOME/.openclaw/workspace/skills/$SKILL"

  if [ ! -d "$DIR" ]; then
    echo "No skill folder at skills/$SKILL. Check the name (skipping)."
    continue
  fi

  echo "Reloading skill '$SKILL'..."
  # Re-install over the existing copy. Prefer --force; if this build doesn't
  # accept that flag, replace the copy cleanly (a fresh install always works).
  if ! "$CLI" skills install "$DIR" --force >/dev/null 2>&1; then
    rm -rf "$DEST"
    "$CLI" skills install "$DIR" >/dev/null
  fi
done

# One gateway restart loads every refreshed copy into the running agent.
bash "$HERE/start-gateway.sh"

echo ""
echo "=================================================================="
echo "  Done — now REFRESH your agent's browser tab (F5) BEFORE sending"
echo "  another message. The gateway just restarted; chatting through"
echo "  the old page causes 'reply session initialization conflicted'."
echo "=================================================================="
echo "After the refresh, ask for your skill in the chat."
