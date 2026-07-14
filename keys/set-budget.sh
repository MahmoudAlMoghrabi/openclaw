#!/usr/bin/env bash
# Puts a Cloud Billing budget (default $100) + alert thresholds on the billing
# account, so we get emails as workshop spend climbs.
#
# IMPORTANT - what this does and does NOT do (verified July 2026):
#   - It DOES create a Cloud Billing budget with alerts at 50%, 90%, 100%.
#   - Cloud Billing budgets ALERT ONLY. They never stop spend.
#   - The ENFORCED caps are elsewhere, and we rely on those:
#       1. AI Studio project spend caps (Settings -> Spend): user-set monthly
#          caps that PAUSE API traffic when hit. Experimental, ~10 min
#          enforcement lag (overage during the lag is billed). SET THIS
#          MANUALLY - there is no gcloud command for it.
#       2. Google's mandatory tier cap: Tier 1 accounts are hard-paused at
#          $250/month across ALL linked projects. Automatic backstop.
#       3. Prepaid accounts (some new AI Studio accounts): hard stop at $0.
#   - SIZE CAPS ABOVE WORST-CASE USAGE. Because caps now enforce, a cap set
#     below what the room can burn pauses every key MID-WORKSHOP. Expected
#     spend ~$18 for 50 attendees on gemini-2.5-flash-lite, worst ~$45,
#     so $100 alerts + a $100 AI Studio cap + Google's $250 backstop.
#
# Prerequisites:
#   - gcloud CLI installed and logged in:   gcloud auth login
#   - Billing Account Administrator on the account you pass in.
#   - The Cloud Billing Budget API (this script tries to enable it for you).
#
# Usage:
#   ./keys/set-budget.sh <BILLING_ACCOUNT_ID> [amount_usd] [--scope-to-projects]
#     e.g.  ./keys/set-budget.sh 0X0X0X-0X0X0X-0X0X0X
#           ./keys/set-budget.sh 0X0X0X-0X0X0X-0X0X0X 100
#           ./keys/set-budget.sh 0X0X0X-0X0X0X-0X0X0X 100 --scope-to-projects
#
#   <BILLING_ACCOUNT_ID>  Find it with:  gcloud billing accounts list
#   [amount_usd]          Defaults to 100.
#   --scope-to-projects   Limit the budget to the projects in keys/projects.txt.
#                         Omit to cap the WHOLE billing account (safest ceiling).
set -euo pipefail

BILLING_ACCOUNT="${1:-}"
AMOUNT="${2:-100}"
SCOPE_FLAG="${3:-}"
MANIFEST="keys/projects.txt"

if [ -z "$BILLING_ACCOUNT" ]; then
  echo "Usage: ./keys/set-budget.sh <BILLING_ACCOUNT_ID> [amount_usd] [--scope-to-projects]"
  echo "Find your billing account id with:  gcloud billing accounts list"
  exit 1
fi

# Strip a leading "billingAccounts/" if the full resource name was pasted in.
BILLING_ACCOUNT="${BILLING_ACCOUNT#billingAccounts/}"

DISPLAY_NAME="openclaw-workshop-cap-$(date +%y%m%d)"

# The Budget API must be enabled on the project gcloud bills the call to.
QUOTA_PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
if [ -n "$QUOTA_PROJECT" ] && [ "$QUOTA_PROJECT" != "(unset)" ]; then
  echo "==> Ensuring billingbudgets.googleapis.com is enabled on $QUOTA_PROJECT"
  if ! gcloud services enable billingbudgets.googleapis.com \
      --project="$QUOTA_PROJECT" >/dev/null 2>&1; then
    echo "    (could not enable automatically - if the create below fails, run:"
    echo "     gcloud services enable billingbudgets.googleapis.com --project=<your project>)"
  fi
else
  echo "NOTE: no default gcloud project set; if the budget create fails with an"
  echo "API-not-enabled error, run: gcloud services enable billingbudgets.googleapis.com --project=<any project you own>"
fi

# Build the optional per-project scoping flags from the manifest.
# NOTE: the Budget API filter wants project NUMBERS, not project IDs, so we
# resolve each id via `gcloud projects describe`.
PROJECT_FLAGS=()
if [ "$SCOPE_FLAG" = "--scope-to-projects" ]; then
  if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: --scope-to-projects given but $MANIFEST not found."
    echo "Run keys/provision-keys.sh first, or drop the flag to cap the whole account."
    exit 1
  fi
  while read -r PROJECT_ID; do
    [ -z "$PROJECT_ID" ] && continue
    PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" \
        --format='value(projectNumber)')"
    PROJECT_FLAGS+=( "--filter-projects=projects/${PROJECT_NUMBER}" )
  done < "$MANIFEST"
  echo "==> Scoping budget to ${#PROJECT_FLAGS[@]} project(s) from $MANIFEST"
else
  echo "==> Capping the ENTIRE billing account (no project filter)"
fi

echo "==> Creating budget '$DISPLAY_NAME': \$${AMOUNT} USD on billing account $BILLING_ACCOUNT"
echo "    Alert thresholds: 50%, 90%, 100% of \$${AMOUNT}"

# percent values are 1.0-based: 0.5 == 50%. (Verified against gcloud reference.)
# The "${PROJECT_FLAGS[@]+...}" guard keeps this safe under `set -u` when the
# array is empty (older bash treats a bare empty-array expansion as unbound).
gcloud billing budgets create \
  --billing-account="$BILLING_ACCOUNT" \
  --display-name="$DISPLAY_NAME" \
  --budget-amount="${AMOUNT}USD" \
  --threshold-rule=percent=0.5 \
  --threshold-rule=percent=0.9 \
  --threshold-rule=percent=1.0 \
  "${PROJECT_FLAGS[@]+"${PROJECT_FLAGS[@]}"}"

echo ""
echo "Done. A \$${AMOUNT} ALERT budget is now watching this billing account."
echo ""
echo "REMEMBER: this budget only emails you. The enforced caps are:"
echo "  - AI Studio project spend cap (set manually: aistudio.google.com ->"
echo "    Settings -> Spend). Pauses traffic, ~10 min lag."
echo "  - Google's automatic \$250/month Tier 1 account cap (hard backstop)."
echo "During the session, watch live usage at https://aistudio.google.com"
echo "Docs: https://ai.google.dev/gemini-api/docs/billing"
