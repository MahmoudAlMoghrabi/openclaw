#!/usr/bin/env bash
# Encrypts keys/keys.csv into keys/keys.enc — and keys.enc IS meant to be
# committed to the (public) repo. On the day, attendees unlock exactly one
# key with the room passphrase + their slip number (scripts/use-key.sh).
#
# Why this is acceptable HERE and nowhere else:
#   - the whole pool is revoked the same evening (teardown-keys.sh), so the
#     blob guards hours-lived throwaway keys, not durable secrets
#   - plaintext keys in a public repo would be auto-detected by secret
#     scanning (and Google may disable them); an encrypted blob is not
# The blob is still public: a GUESSABLE passphrase can be brute-forced
# offline. Use 3-4 random words. After the event: run teardown-keys.sh,
# then delete keys.enc from the repo.
#
# Usage:  ./keys/encrypt-keys.sh     (after provision-keys.sh)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CSV="$HERE/keys.csv"
ENC="$HERE/keys.enc"

if [ ! -f "$CSV" ]; then
  echo "No $CSV found. Run provision-keys.sh first."
  exit 1
fi

printf 'Choose the workshop passphrase (hidden, 3-4 random words): ' >&2
read -rs P1; printf '\n' >&2
printf 'Repeat it: ' >&2
read -rs P2; printf '\n' >&2
if [ "$P1" != "$P2" ]; then
  echo "Passphrases do not match."
  exit 1
fi
if [ "${#P1}" -lt 12 ]; then
  echo "Too short (${#P1} chars). The blob is public: use at least 12"
  echo "characters, e.g. three random words."
  exit 1
fi

printf '%s\n' "$P1" | openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -salt \
  -in "$CSV" -out "$ENC" -pass stdin

echo "Wrote $(basename "$ENC") ($(wc -c < "$ENC") bytes). Commit and push it:"
echo "    git add keys/keys.enc && git commit -m 'Workshop key pool (encrypted)' && git push"
echo ""
echo "On the day: passphrase goes on the projector, slip numbers at the door."
echo "NEVER commit keys.csv. After the event: teardown-keys.sh, then delete"
echo "keys.enc from the repo."
