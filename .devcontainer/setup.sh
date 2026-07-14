#!/usr/bin/env bash
# Runs once when the Codespace is first created.
set -euo pipefail

# ---------------------------------------------------------------------------
# PIN THE VERSION before the workshop.
# Set this to a version you confirmed works in your dry run. Do NOT ship
# "latest" on the day: an OpenClaw release the night before could break setup.
# ---------------------------------------------------------------------------
OPENCLAW_VERSION="${OPENCLAW_VERSION:-2026.6.11}"

echo "==> Installing OpenClaw (${OPENCLAW_VERSION})"
npm install -g "openclaw@${OPENCLAW_VERSION}"

# NOTE: we do NOT copy .openclaw/config.json5, OpenClaw 2026.6.11 ignores it.
# The real config (~/.openclaw/openclaw.json) is created by `openclaw onboard`
# and then patched by scripts/patch-config.js, both run from scripts/use-key.sh.
echo "==> Setup complete. Run  ./scripts/use-key.sh  then paste your key at the hidden prompt to start your agent."
