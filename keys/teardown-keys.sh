#!/usr/bin/env bash
# Deletes every project created by provision-keys.sh, which removes the keys too.
# Run this right after the workshop to clean up.
#
# Usage:   ./keys/teardown-keys.sh
set -euo pipefail

MANIFEST="keys/projects.txt"
if [ ! -f "$MANIFEST" ]; then
  echo "No $MANIFEST found. Nothing to tear down (run from the repo root)."
  exit 1
fi

echo "This will DELETE the following projects and all their API keys:"
echo ""
cat "$MANIFEST"
echo ""
read -r -p "Type 'delete' to confirm: " CONFIRM
if [ "$CONFIRM" != "delete" ]; then
  echo "Aborted. Nothing was deleted."
  exit 1
fi

while read -r PROJECT_ID; do
  [ -z "$PROJECT_ID" ] && continue
  # Unlink billing FIRST: even if the delete below fails, an unlinked project
  # cannot spend another cent.
  echo "==> Unlinking billing from $PROJECT_ID"
  gcloud billing projects unlink "$PROJECT_ID" --quiet 2>/dev/null \
    || echo "    (no billing link to remove, or unlink failed - check by hand)"
  echo "==> Deleting $PROJECT_ID"
  gcloud projects delete "$PROJECT_ID" --quiet \
    || echo "    (could not delete $PROJECT_ID, please check it by hand)"
done < "$MANIFEST"

echo ""
echo "Teardown complete. The projects are scheduled for deletion by Google."
echo ""
echo "Finish the cleanup by hand (no gcloud commands for these):"
echo "  1. Remove the AI Studio spend caps: aistudio.google.com -> Settings -> Spend"
echo "  2. Delete the alert budget:  gcloud billing budgets list --billing-account=<id>"
echo "     then  gcloud billing budgets delete <budget-id> --billing-account=<id>"
echo "  3. Confirm the billing account shows no active projects and \$0 ongoing spend."
