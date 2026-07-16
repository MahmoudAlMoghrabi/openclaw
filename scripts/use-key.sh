#!/usr/bin/env bash
# The one command an attendee runs: registers their Gemini key, applies the
# workshop config, and (re)starts the agent.
#
# Recommended (key stays hidden, never shown on screen or saved in history):
#   ./scripts/use-key.sh
#   then paste the key at the prompt and press Enter.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# Read the key WITHOUT displaying it. Preferred flow is no argument: we prompt
# with a hidden read so the key never appears on screen, on a projector, or in
# shell history. (Passing the key as an argument still works but is discouraged.)
KEY="${1:-}"

# A GEMINI_API_KEY already present in the environment — e.g. injected by an
# account-level GitHub Codespaces secret, handy for facilitator dry runs —
# is used automatically. Attendees have no such secret, so they move on to
# the workshop unlock. Precedence: argument > environment > pool > prompt.
KEY_FROM_ENV=0
if [ -z "$KEY" ] && [ -n "${GEMINI_API_KEY:-}" ]; then
  KEY="$GEMINI_API_KEY"
  KEY_FROM_ENV=1
  echo "Using GEMINI_API_KEY from the environment (Codespaces secret)."
fi

# Workshop mode: if the encrypted key pool ships with the repo, unlock ONE
# key with the room passphrase + the attendee's slip number. The decrypted
# pool never touches disk — it is piped straight into the row lookup.
# (Press Enter at the slip-number prompt to skip and paste your own key,
# e.g. when running this at home after the pool has been revoked.)
ENC="$HERE/../keys/keys.enc"
if [ -z "$KEY" ] && [ -f "$ENC" ]; then
  echo "Workshop unlock: type the passphrase shown on the screen, then your"
  echo "slip number. (No slip? Press Enter at the number to paste your own key.)"
  for attempt in 1 2 3; do
    printf 'Passphrase (stays hidden): ' >&2
    read -rs PASS
    printf '\n' >&2
    printf 'Your slip number: ' >&2
    read -r NUM
    NUM="$(printf '%s' "$NUM" | tr -d '[:space:]')"
    if [ -z "$NUM" ]; then
      echo "  Skipping the pool; you can paste a key directly below."
      break
    fi
    KEY="$(printf '%s\n' "$PASS" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 \
            -in "$ENC" -pass stdin 2>/dev/null \
          | awk -F, -v n="$NUM" '$1==n{print $4; exit}')" || KEY=""
    KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
    case "$KEY" in
      AIza*|AQ*) echo "  Key #$NUM unlocked."; break ;;
      *) KEY=""; echo "  Could not unlock key #$NUM. Check the passphrase and number, then try again." >&2 ;;
    esac
  done
fi

if [ -z "$KEY" ]; then
  # Prompt with a hidden read (up to 3 tries) and sanity-check the format, so
  # the key never appears on screen, on a projector, or in shell history.
  for attempt in 1 2 3; do
    printf 'Paste your Gemini API key, then press Enter (it stays hidden): ' >&2
    read -rs KEY
    printf '\n' >&2
    # Strip whitespace a copy-paste can smuggle in — invisible characters
    # would fail the format check with no clue why.
    KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
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

# Make the key available now and in future terminals. Update the line in place
# if it already exists, so a replacement key never leaves a stale one behind.
# Skip the .bashrc write when the key came from a Codespaces secret: GitHub
# re-injects the (possibly rotated) secret on every start, and a stale
# .bashrc export would run afterwards and shadow the fresh value.
export GEMINI_API_KEY="$KEY"
if [ "$KEY_FROM_ENV" != "1" ]; then
  if grep -q "^export GEMINI_API_KEY=" "$HOME/.bashrc" 2>/dev/null; then
    sed -i "s|^export GEMINI_API_KEY=.*|export GEMINI_API_KEY=\"$KEY\"|" "$HOME/.bashrc"
  else
    echo "export GEMINI_API_KEY=\"$KEY\"" >> "$HOME/.bashrc"
  fi
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

# Give the agent a path to this repo. Its file tools resolve relative paths
# against ~/.openclaw/workspace (its own home), NOT this checkout — so
# "skills/guided-skill/roast-me.js" doesn't exist from the agent's point of
# view. The symlink makes "repo/..." work in chat prompts, and files the
# agent writes under repo/ appear in the attendee's file explorer.
mkdir -p "$HOME/.openclaw/workspace"
ln -sfn "$(cd "$HERE/.." && pwd)" "$HOME/.openclaw/workspace/repo" 2>/dev/null || true

# Prove the workshop MCP tool server (dice + weather) starts and lists its
# tools: `mcp probe` opens a real MCP connection (docs.openclaw.ai/cli/mcp).
# Non-fatal — everything else works without it.
if "$CLI" mcp probe workshop-tools >/dev/null 2>&1; then
  echo "MCP tools ready: roll_dice, get_weather."
else
  echo "  (MCP probe failed; the dice demo may be off. Debug with:"
  echo "   $CLI mcp doctor workshop-tools --probe)"
fi

# Install the workshop skills. OpenClaw reads skills from ~/.openclaw/workspace/
# skills (a COPY it makes), NOT from this repo, so the agent can't see them until
# we install them explicitly. Non-fatal if already installed (re-runs).
# (weather-reporter is the built-in-tools demo: it directs the agent to its
# own web_fetch tool. The MCP server above is the plugged-in-tools demo.)
for skill in fortune-teller standup-writer my-first-skill weather-reporter; do
  "$CLI" skills install "$HERE/../skills/$skill" \
    || echo "  (skill '$skill' already installed or install skipped)"
done

# (Re)start the gateway so it loads the patched config and skills. start-gateway.sh
# uses --force, replacing the keyless gateway that Codespaces starts at boot.
bash "$HERE/start-gateway.sh"

# Work out the Control UI's browser URL. Inside Codespaces every forwarded
# port has a stable HTTPS URL built from these two env vars; anywhere else
# (local testing) fall back to localhost.
PORT="${OPENCLAW_PORT:-18789}"
if [ -n "${CODESPACE_NAME:-}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]; then
  UI_URL="https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/"
else
  UI_URL="http://localhost:${PORT}/"
fi

echo ""
echo "=================================================================="
echo "  All set. Your agent lives here:"
echo ""
echo "  👉  $UI_URL"
echo ""
echo "  A tab should open by itself. If not, Ctrl+Click the link above."
echo "  On the page: leave both boxes EMPTY and click Connect. (No token"
echo "  needed, your Codespace is the key.)"
echo "=================================================================="

# Auto-open the Control UI in the attendee's own browser — but only on the
# FIRST successful run. Re-runs would open a second tab, and two live tabs
# on the same agent race each other ("reply session initialization
# conflicted"). Codespaces sets $BROWSER to a helper that opens URLs on the
# user's machine; if it's absent (local run), the printed link is the
# fallback.
OPENED_MARKER="$HOME/.openclaw/.workshop-ui-opened"
if [ -n "${BROWSER:-}" ] && [ ! -f "$OPENED_MARKER" ]; then
  "$BROWSER" "$UI_URL" >/dev/null 2>&1 || true
  touch "$OPENED_MARKER"
elif [ -f "$OPENED_MARKER" ]; then
  echo ""
  echo "  (Not opening a new tab: you already have one. Keep just ONE agent"
  echo "   tab open — two tabs on the same agent conflict. Refresh the tab"
  echo "   you have, or Ctrl+Click the link above if you closed it.)"
fi
