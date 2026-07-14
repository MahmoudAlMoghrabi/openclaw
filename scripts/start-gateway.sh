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
if "$CLI" status >/dev/null 2>&1; then
  echo "Gateway is up."
else
  echo "Gateway is still starting; give it a few seconds, then refresh the browser."
fi
echo "Logs: /tmp/openclaw-gateway.log"
