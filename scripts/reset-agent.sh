#!/usr/bin/env bash
# Panic button. Fixes "reply session initialization conflicted" and other
# wedged-agent states by stopping the gateway, clearing the main agent's
# session state (workshop chats are throwaway), and starting fresh.
#
# Usage:  ./scripts/reset-agent.sh
# After it finishes: keep ONE agent tab, refresh it, reconnect.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "Stopping any running gateway..."
# Match the gateway process specifically ("gateway run"), NOT plain
# "openclaw" — that pattern would also match this script's own path.
pkill -f "gateway run" 2>/dev/null || true
sleep 2

SESS="$HOME/.openclaw/agents/main/sessions"
if [ -d "$SESS" ]; then
  echo "Clearing agent session state..."
  rm -rf "$SESS"/* 2>/dev/null || true
fi

bash "$HERE/start-gateway.sh"

echo ""
echo "=================================================================="
echo "  Fresh start. Close EVERY agent tab except one, refresh it (F5),"
echo "  leave both boxes empty, and click Connect."
echo "=================================================================="
