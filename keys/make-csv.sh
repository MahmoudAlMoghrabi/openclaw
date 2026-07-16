#!/usr/bin/env bash
# For when you HAVE keys but no access to the Google account that made them.
# Turns a plain list of keys into the keys.csv that encrypt-keys.sh expects.
#
# 1. Create keys/raw-keys.txt — ONE key per line (both it and keys.csv are
#    gitignored). If you know the keys come from different Google projects,
#    order the lines so consecutive keys alternate projects: slips are handed
#    out in number order, so this spreads neighbours across rate-limit pools.
# 2. Run:  ./keys/make-csv.sh
# 3. Then: ./keys/encrypt-keys.sh   (and commit keys/keys.enc)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RAW="$HERE/raw-keys.txt"
CSV="$HERE/keys.csv"

if [ ! -f "$RAW" ]; then
  echo "No $RAW found. Create it with one API key per line."
  exit 1
fi

COUNT=0
echo "key_seq,project_id,key_name,api_key" > "$CSV"
while IFS= read -r line; do
  key="$(printf '%s' "$line" | tr -d '[:space:]')"
  [ -z "$key" ] && continue
  case "$key" in
    AIza*|AQ*) ;;
    \#*) continue ;;
    *) echo "Line skipped (does not look like a Gemini key): ${key:0:8}..." >&2; continue ;;
  esac
  COUNT=$((COUNT + 1))
  printf '%d,pool,key-%02d,%s\n' "$COUNT" "$COUNT" "$key" >> "$CSV"
done < "$RAW"

if [ "$COUNT" -eq 0 ]; then
  echo "No valid keys found in raw-keys.txt."
  exit 1
fi

echo "Wrote $COUNT keys to keys/keys.csv (slip numbers 1-$COUNT)."
echo "Next: ./keys/encrypt-keys.sh  — then commit keys/keys.enc and push."
echo "After that, delete raw-keys.txt (or keep it somewhere safer than this repo)."
