#!/usr/bin/env bash
# Starts (or restarts) the OpenClaw gateway in the background.
# Codespaces has no systemd, so we launch it with nohup. We ALWAYS pass --force:
# Codespaces auto-starts a gateway at boot (before any key/config exists), and
# --force kills that one so the fresh gateway loads the current, patched config.
set -euo pipefail

CLI="openclaw"
if ! command -v "$CLI" >/dev/null 2>&1; then
  CLI="clawdbot"
fi

echo "Starting OpenClaw gateway (force-restart)..."
nohup "$CLI" gateway run --force > /tmp/openclaw-gateway.log 2>&1 &
sleep 3

# The Control UI's browser URL (stable HTTPS URL inside Codespaces,
# localhost anywhere else), printed so it's always one click away.
PORT="${OPENCLAW_PORT:-18789}"
if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
  UI_URL="https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/"
else
  UI_URL="http://localhost:${PORT}/"
fi

if "$CLI" status >/dev/null 2>&1; then
  echo "Gateway is up. Your agent: $UI_URL (refresh the tab if it was open)"
else
  echo "Gateway is still starting; give it a few seconds, then open/refresh:"
  echo "  $UI_URL"
fi
echo "Logs: /tmp/openclaw-gateway.log"
