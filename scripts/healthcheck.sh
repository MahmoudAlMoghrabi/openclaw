#!/usr/bin/env bash
#
# OpenClaw workshop, room healthcheck. One command to confirm an attendee's
# environment is fully working:
#   ./scripts/healthcheck.sh
#
set -u

GATEWAY_PORT=18789
PASS=0
FAIL=0

check() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '  \033[32m*\033[0m %s\n' "$label"
    PASS=$((PASS + 1))
  else
    printf '  \033[31mx\033[0m %s\n' "$label"
    FAIL=$((FAIL + 1))
  fi
}

node_recent_enough() {
  local major
  major="$(node -e 'process.stdout.write(String(process.versions.node.split(".")[0]))')" || return 1
  [ "$major" -ge 22 ]
}

model_configured() {
  grep -q 'gemini' "$HOME/.openclaw/openclaw.json" 2>/dev/null
}

demo_skill_installed() {
  [ -f "$HOME/.openclaw/workspace/skills/fortune-teller/SKILL.md" ]
}

agent_responds() {
  # End-to-end: gateway to agent to Gemini and back. Takes a few seconds.
  openclaw agent --message "Reply with exactly the word: ready" 2>/dev/null | grep -qi "ready"
}

printf '\033[1mOpenClaw workshop healthcheck\033[0m\n\n'

check "openclaw CLI installed"               command -v openclaw
check "Node 22+ available"                   node_recent_enough
check "config file exists"                   test -f "$HOME/.openclaw/openclaw.json"
check "Gemini model configured"              model_configured
check "gateway healthy (port $GATEWAY_PORT)" curl -fsS "http://127.0.0.1:${GATEWAY_PORT}/healthz"
check "demo skill installed"                 demo_skill_installed
check "agent responds end-to-end"            agent_responds

echo
if [ "$FAIL" -eq 0 ]; then
  printf '\033[1;32mAll %d checks passed, you are ready for the workshop.\033[0m\n' "$PASS"
else
  printf '\033[1;31m%d check(s) failed.\033[0m Fix-it order:\n' "$FAIL"
  echo "  1. ./scripts/use-key.sh          (safe to re-run; paste your key at the hidden prompt)"
  echo "  2. bash scripts/start-gateway.sh"
  echo "  3. tail -50 /tmp/openclaw-gateway.log"
  echo "  4. Raise a hand, facilitators are faster than debugging alone."
  exit 1
fi
