#!/usr/bin/env bash
# The one command an attendee runs: registers their Gemini key, applies the
# workshop config, and (re)starts the agent.
#
# Recommended (key stays hidden, never shown on screen or saved in history):
#   ./scripts/use-key.sh
#   then paste the key at the prompt and press Enter.
set -euo pipefail

# Read the key WITHOUT displaying it. Preferred flow is no argument: we prompt
# with a hidden read so the key never appears on screen, on a projector, or in
# shell history. (Passing the key as an argument still works but is discouraged.)
KEY="${1:-}"
if [ -z "$KEY" ]; then
  # Prompt with a hidden read (up to 3 tries) and sanity-check the format, so
  # the key never appears on screen, on a projector, or in shell history.
  for attempt in 1 2 3; do
    printf 'Paste your Gemini API key, then press Enter (it stays hidden): ' >&2
    read -rs KEY
    printf '\n' >&2
    case "$KEY" in
      AIza*|AQ*) break ;;
      *) KEY=""; printf '  That does not look like a Gemini key (they start with AIza or AQ). Try again.\n' >&2 ;;
    esac
  done
fi
if [ -z "$KEY" ]; then
  echo "No valid key entered. Re-run ./scripts/use-key.sh and paste your key at the prompt."
  exit 1
fi

CLI="openclaw"
if ! command -v "$CLI" >/dev/null 2>&1; then
  CLI="clawdbot"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"

# Make the key available now and in future terminals. Update the line in place
# if it already exists, so a replacement key never leaves a stale one behind.
export GEMINI_API_KEY="$KEY"
if grep -q "^export GEMINI_API_KEY=" "$HOME/.bashrc" 2>/dev/null; then
  sed -i "s|^export GEMINI_API_KEY=.*|export GEMINI_API_KEY=\"$KEY\"|" "$HOME/.bashrc"
else
  echo "export GEMINI_API_KEY=\"$KEY\"" >> "$HOME/.bashrc"
fi

# Register the key. This OpenClaw version REQUIRES --accept-risk for
# non-interactive onboarding, and --skip-health so onboard doesn't fail waiting
# for a gateway that isn't up yet (we start it ourselves below). Writes
# ~/.openclaw/openclaw.json.
"$CLI" onboard --non-interactive --accept-risk --skip-health --mode local \
  --auth-choice gemini-api-key --gemini-api-key "$KEY"

# onboard leaves settings we must correct: it defaults the model to an expensive
# Pro model, doesn't allow the Codespaces control-UI origin, and sets token auth.
# patch-config.js fixes all three (see that file for the why).
node "$HERE/patch-config.js"

# Install the workshop skills. OpenClaw reads skills from ~/.openclaw/workspace/
# skills (a COPY it makes), NOT from this repo, so the agent can't see them until
# we install them explicitly. Non-fatal if already installed (re-runs).
for skill in fortune-teller standup-writer my-first-skill; do
  "$CLI" skills install "$HERE/../skills/$skill" \
    || echo "  (skill '$skill' already installed or install skipped)"
done

# (Re)start the gateway so it loads the patched config and skills. start-gateway.sh
# uses --force, replacing the keyless gateway that Codespaces starts at boot.
bash "$HERE/start-gateway.sh"

echo ""
echo "All set. Open the PORTS tab, find port 18789, and click the globe icon."
echo "In the browser, leave the token and password fields blank and click Connect."
