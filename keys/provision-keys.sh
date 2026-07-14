#!/usr/bin/env bash
# Provisions the workshop's Google Cloud projects and Gemini API keys.
#
# PLAN (paid tier, July 2026): a small number of billing-linked projects, each
# holding several API keys, shared by the room. Rate limits are per PROJECT
# (not per key), so projects spread the load; extra keys within a project add
# no quota but let us revoke one attendee's key without disrupting the rest.
#
# WHY NOT free tier: free-tier quotas (~10-15 req/min, low daily caps, per
# project) cannot carry a 50-person room on shared projects, and Google has
# tightened free limits without notice twice since Dec 2025.
#
# RATE-LIMIT SIZING (verify at https://aistudio.google.com/rate-limit, Google
# no longer publishes numbers): Tier 1 is roughly 300 RPM / ~1M TPM per project
# per model. 50 agent users demand ~3-6M TPM. Limits are per project PER MODEL,
# so 5 projects x 2 models (primary gemini-2.5-flash-lite + overflow
# gemini-3.1-flash-lite) = ~10 quota pools, which covers the demand at Tier 1.
# (Tier 2 exists but costs $100 of real spend to reach - pointless at flash-lite
# prices; use the two-model split instead.)
#
# Prerequisites:
#   - gcloud CLI installed and logged in:   gcloud auth login
#   - A dedicated billing account (TechNL-controlled), you have Billing Account
#     Administrator on it. Note: a billing account links ~5 projects by default.
#   - AFTER running this, set the ENFORCED spend cap in AI Studio (see the
#     instructions this script prints at the end). The Cloud Billing budget we
#     create only ALERTS.
#
# Usage:   BILLING_ACCOUNT=<id> ./keys/provision-keys.sh <num_projects> <keys_per_project> [prefix]
#   e.g.   BILLING_ACCOUNT=0X0X0X-0X0X0X-0X0X0X ./keys/provision-keys.sh 5 10 technl-ws
#          (5 projects x 10 keys = 50 keys, one per attendee)
#
#   FREE_TIER=1 skips billing (single-user testing only, NOT for the event).
set -euo pipefail

NUM_PROJECTS="${1:-}"
KEYS_PER_PROJECT="${2:-}"
PREFIX="${3:-openclaw-ws}"
API="generativelanguage.googleapis.com"
OUT="keys/keys.csv"            # gitignored: holds secrets, never commit
MANIFEST="keys/projects.txt"   # list of project ids, used by teardown
BILLING_ACCOUNT="${BILLING_ACCOUNT:-}"
BUDGET_USD="${BUDGET_USD:-100}"

if [ -z "$NUM_PROJECTS" ] || [ -z "$KEYS_PER_PROJECT" ]; then
  echo "Usage: BILLING_ACCOUNT=<id> ./keys/provision-keys.sh <num_projects> <keys_per_project> [prefix]"
  echo "  e.g. BILLING_ACCOUNT=0X0X0X-0X0X0X-0X0X0X ./keys/provision-keys.sh 5 10 technl-ws"
  exit 1
fi

if [ -z "$BILLING_ACCOUNT" ] && [ "${FREE_TIER:-}" != "1" ]; then
  echo "ERROR: BILLING_ACCOUNT is not set."
  echo "The workshop plan is paid tier: without billing, projects stay on the"
  echo "free tier and 50 shared users will be throttled within the first minute."
  echo "Find the id with:  gcloud billing accounts list"
  echo "(For solo free-tier testing only, re-run with FREE_TIER=1.)"
  exit 1
fi
BILLING_ACCOUNT="${BILLING_ACCOUNT#billingAccounts/}"

STAMP="$(date +%y%m%d)"
# Project ids max out at 30 chars: prefix + '-' + 6 (date) + '-' + 2 (seq).
if [ "${#PREFIX}" -gt 20 ]; then
  echo "ERROR: prefix '$PREFIX' is too long (${#PREFIX} chars, max 20)."
  exit 1
fi

mkdir -p keys
echo "key_seq,project_id,key_name,api_key" > "$OUT"
: > "$MANIFEST"

SEQ=0
for p in $(seq 1 "$NUM_PROJECTS"); do
  PN="$(printf '%02d' "$p")"
  PROJECT_ID="${PREFIX}-${STAMP}-${PN}"
  echo "==> [project $p/$NUM_PROJECTS] Creating $PROJECT_ID"

  gcloud projects create "$PROJECT_ID" --name="$PROJECT_ID" >/dev/null
  echo "$PROJECT_ID" >> "$MANIFEST"

  if [ -n "$BILLING_ACCOUNT" ]; then
    echo "    linking billing account (paid tier activates instantly)"
    gcloud billing projects link "$PROJECT_ID" \
      --billing-account="$BILLING_ACCOUNT" >/dev/null
  fi

  echo "    enabling $API"
  gcloud services enable "$API" --project="$PROJECT_ID" >/dev/null

  for k in $(seq 1 "$KEYS_PER_PROJECT"); do
    SEQ=$((SEQ + 1))
    KN="$(printf '%02d' "$k")"
    KEY_NAME="${PROJECT_ID}-key-${KN}"
    echo "    creating key $k/$KEYS_PER_PROJECT (restricted to the Gemini API)"
    KEY="$(gcloud services api-keys create \
        --project="$PROJECT_ID" \
        --display-name="$KEY_NAME" \
        --api-target=service="$API" \
        --format='value(response.keyString)')"
    echo "${SEQ},${PROJECT_ID},${KEY_NAME},${KEY}" >> "$OUT"
  done
done

echo ""
echo "Done. $SEQ keys across $NUM_PROJECTS projects written to ${OUT}"
echo "That file is gitignored. Never commit it or email the whole sheet."
echo "Hand each attendee ONE row's api_key, privately. Assign rows round-robin"
echo "across projects so the load spreads evenly (row order already does this"
echo "if you hand them out in project blocks, mix blocks across the room)."

if [ -n "$BILLING_ACCOUNT" ]; then
  echo ""
  echo "==> Applying the \$${BUDGET_USD} Cloud Billing budget (ALERTS ONLY)"
  bash "$(dirname "$0")/set-budget.sh" "$BILLING_ACCOUNT" "$BUDGET_USD"
  echo ""
  echo "REQUIRED MANUAL STEP - the ENFORCED cap lives in AI Studio, not gcloud:"
  echo "  1. Open https://aistudio.google.com -> Settings -> Billing/Spend."
  echo "  2. Set a project spend cap of \$${BUDGET_USD} (it PAUSES traffic when hit,"
  echo "     with ~10 min lag). Worst case on gemini-2.5-flash-lite is ~\$45 for"
  echo "     50 people, so \$100 has comfortable margin. Never set a cap below"
  echo "     worst-case usage or it will pause every key MID-WORKSHOP."
  echo "  3. Google also enforces a \$250/month Tier 1 cap on the whole account"
  echo "     automatically - that is the hard backstop."
  echo "  4. If agents hit 429s on the day, move half the room to the overflow"
  echo "     model (gemini-3.1-flash-lite) - limits are per project per model."
else
  echo ""
  echo "FREE_TIER=1: no billing linked. Single-user testing only."
fi
