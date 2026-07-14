# TechNL "Build a Real AI Agent in 90 Minutes with OpenClaw", internal brief

Pickup-cold context for the team. Covers the event, the verified model and cost
facts, the cap strategy, and what still needs the dry run. All external facts
re-verified against official Google sources on **July 6, 2026** by a
multi-agent audit (pricing, deprecations, billing, rate limits, each
adversarially cross-checked). Plain-language execution steps live in
[RUNBOOK.md](RUNBOOK.md); the solo 30-minute rehearsal script is
[EXPERIMENT.md](EXPERIMENT.md).

## 1. What the event is

- 90-min hands-on workshop: each attendee builds and runs an AI agent in the
  browser (proposal by Arash, June 26). Follow-up to TechNL's OpenClaw session
  with Jack Harrhy. ~50 max attendees. Flexes 60/120 min.
- Stack: GitHub Codespace + OpenClaw + a Gemini API key per attendee. Attendee
  flow: open Codespace, run `./scripts/use-key.sh` and paste the key at the hidden prompt, open port 18789.
- NOTE: the 120-min flex ("connect an external tool") is NOT built in this
  repo yet. 60/90-min versions are fully covered.

## 2. Status and the commitment we are honoring

- TechNL approved; newsletter promotion planned for Thursday.
- **Arash already told TechNL: cost roughly $15-30, cap $100, dedicated
  billing-enabled account, keys revoked after.** The configuration in this
  repo is deliberately chosen to make those numbers true as sent (see §3), so
  no client-facing correction is needed.
- Answer Rahaf's cost question before the newsletter; keep the proposed
  meeting for logistics.

## 3. Model: `google/gemini-2.5-flash-lite` (pinned in config)

Set in [.openclaw/config.json5](.openclaw/config.json5). Why:

1. Cheapest stable model: $0.10 in / $0.40 out per 1M tokens. It is the only
   model on which the committed "$15-30, $100 cap" is honest with margin
   (worst case ~$45 for 50 people).
2. Shuts down **Oct 16, 2026** (official deprecations page), fine for this
   event, do not reuse after. For a rerun later in the year, move to
   `gemini-3.1-flash-lite`.
3. **Overflow/fallback: `gemini-3.1-flash-lite`** ($0.25/$1.50, GA May 7,
   2026). Used if OpenClaw rejects the primary, or live on the day to double
   rate-limit headroom (limits are per project per model).
4. "Gemini Flash 3" as a cheap model **does not exist**: `gemini-3-flash-preview`
   ($0.50/$3.00) costs more than 2.5-flash, never went GA, and preview models
   keep free-tier-level daily quotas even on paid billing.
5. **Do NOT use** `gemini-3.5-flash` ($1.50/$9.00): heavy usage ≈ $825 for 50,
   which trips every cap layer and pauses the room.

## 4. Verified prices (per 1M tokens, paid tier, July 6, 2026)

| Model | Input | Output | Status |
|---|---|---|---|
| **`gemini-2.5-flash-lite`** (ours) | **$0.10** | **$0.40** | stable; shuts down Oct 16, 2026 |
| `gemini-3.1-flash-lite` (overflow) | $0.25 | $1.50 | GA May 7, 2026 |
| `gemini-2.5-flash` | $0.30 | $2.50 | shuts down Oct 16, 2026 |
| `gemini-3-flash-preview` (avoid) | $0.50 | $3.00 | preview, crippled quotas |
| `gemini-3.5-flash` (avoid) | $1.50 | $9.00 | GA, too expensive |

Source: <https://ai.google.dev/gemini-api/docs/pricing> +
<https://ai.google.dev/gemini-api/docs/deprecations> (each figure confirmed by
two independent fetches).

## 5. Cost estimate for 50 attendees (on 2.5-flash-lite)

Per-attendee tokens are ESTIMATES, measure one real run in the dry run.
OpenClaw resends context every turn, so input dominates.

| Scenario | Tokens / attendee | Cost / attendee | × 50 |
|---|---|---|---|
| Light | 0.5M in + 0.1M out | $0.09 | ~$4.50 |
| Moderate (plan around this) | 2M in + 0.4M out | $0.36 | ~$18 |
| Heavy | 5M in + 1M out | $0.90 | ~$45 |

**Quoted to TechNL (already sent by Arash, and honest under this config):
roughly $15-30 expected, capped at $100, Google independently enforces $250.**
If the room splits onto the overflow model mid-session, blended worst case
rises but stays under the $100 cap unless more than half the room runs heavy
on overflow, watch the dashboard if the split is invoked.

## 6. Spend caps, what actually enforces (changed March 2026)

Three layers, from soft to hard:

1. **Cloud Billing budget** ($100, [keys/set-budget.sh](keys/set-budget.sh)):
   **ALERTS ONLY**, never stops spend. Emails at $50 / $90 / $100.
2. **AI Studio project spend cap** (manual: aistudio.google.com → Settings →
   Spend): the user-settable ENFORCED cap. Pauses API traffic when hit, ~10 min
   enforcement lag (lag-window overage is billed). Experimental feature.
   **Set $100**, that is 2x the worst case, so it cannot trip on honest usage.
3. **Google's mandatory tier cap**: Tier 1 accounts hard-pause at **$250/month**
   across all linked projects. Automatic. (Tier 2: $2,000.)

**The failure mode to respect: a cap below worst-case usage pauses every key
mid-workshop.** $100 vs $45 worst case gives 2x margin. (Some new AI Studio
accounts are prepaid, hard stop at $0 balance. If TechNL's account lands on
prepaid, load ~$100 of credit; worst case is then bounded by the balance.)

## 7. Rate limits, the sizing solution

- Limits are per PROJECT per MODEL (official). Google no longer publishes
  numbers; third-party consensus for Tier 1 flash: ~300 RPM / ~1M TPM /
  ~1,000-1,500 RPD per project. The ONLY authority is
  <https://aistudio.google.com/rate-limit> viewed from the real account.
- Demand math: 50 users × ~30k tokens/req × 2-4 req/min ≈ **3-6M TPM** and
  9,000-18,000 requests in 90 min.
- **The plan: 5 projects × 2 models = ~10 quota pools ≈ 10M TPM**, which
  covers worst-case demand at Tier 1. Primary model for everyone; move half
  the room to the overflow model only if 429s appear.
- Tier 2 (5-10x limits) exists but requires **$100 of real spend + 3 days**,
  pointless at flash-lite prices where the whole event costs ~$18. Skip it.
- Tier 1 activates instantly when billing is linked (no waiting period).
- Free tier is dead for this format: Flash-only, ~10-15 RPM per project,
  ~250-1,500 RPD, cut without notice twice since Dec 2025.

## 8. Provisioning (scripts updated July 6)

- `BILLING_ACCOUNT=<id> ./keys/provision-keys.sh 5 10 technl-ws` → 5
  billing-linked projects × 10 keys, `keys/keys.csv`
  (`key_seq,project_id,key_name,api_key`, gitignored). One key per attendee;
  keys give revocation granularity, projects give quota.
- The script links billing per project, validates project-id length, applies
  the $100 alert budget, and prints the manual AI Studio cap steps.
- [keys/set-budget.sh](keys/set-budget.sh): $100 default, resolves project
  NUMBERS for `--filter-projects` (the API rejects project IDs), tries to
  enable the budgets API itself.
- [keys/teardown-keys.sh](keys/teardown-keys.sh): unlinks billing before
  deleting each project, then prints the manual cleanup (AI Studio caps,
  alert budget, $0 verification).

## 9. Dry-run findings (July 6, resolved in the scripts)

A live dry run in a real Codespace found five things that each would have broken
the workshop. All are now fixed in the repo; a fresh Codespace works with only
`./scripts/use-key.sh` (key pasted at a hidden prompt):

1. Scripts weren't executable → set the exec bit (commit `716622f`).
2. `openclaw onboard` needs `--accept-risk` (new in 2026.6.11) → added in
   [scripts/use-key.sh](scripts/use-key.sh).
3. **OpenClaw ignores `.openclaw/config.json5`** and reads `~/.openclaw/openclaw.json`;
   onboard defaulted the model to `gemini-3.1-pro-preview` (expensive Pro). →
   [scripts/patch-config.js](scripts/patch-config.js) rewrites the model to
   `gemini-2.5-flash-lite` after onboard.
4. The gateway auto-starts at boot before the key exists and wasn't being
   restarted → [scripts/start-gateway.sh](scripts/start-gateway.sh) now always
   uses `--force`.
5. The Codespaces proxy rewrites every browser origin to `http://localhost:18789`,
   which the gateway blocked → patch-config.js allowlists it and sets `auth: none`.

## 10. Still open for the dry run (billing side, not yet tested)

1. **Read the real rate limits** at aistudio.google.com/rate-limit on the
   TechNL account; re-do the §7 math with real numbers.
2. **Measure real tokens per attendee** in one full rehearsal; replace the
   §5 estimates.
3. Set the AI Studio spend cap and TEST it exists on this account (experimental).
4. Check whether the new account is prepaid or postpaid billing.
5. Rehearse the billing provision + teardown scripts against the real account.
6. Codespaces prebuild cost lands on AI Garage's GitHub account, not attendees'.
7. Pin `OPENCLAW_VERSION` in [.devcontainer/setup.sh](.devcontainer/setup.sh) to
   the tested version (confirmed working: 2026.6.11).

## 11. Team alignment

Arash's email to TechNL ("cheap Gemini flash 3, $15-30, $100 cap") is honored
by this configuration: the model that makes his numbers true is
`gemini-2.5-flash-lite` (the "flash 3" name doesn't map to any cheap stable
model, internal detail only, TechNL doesn't need it). One nuance to keep
internal: the cap "guarantee" has a ~10-minute enforcement lag, so worst-case
exposure is the cap plus a few dollars, bounded hard by Google's $250 tier cap.

## Sources

- Pricing: <https://ai.google.dev/gemini-api/docs/pricing>
- Deprecations: <https://ai.google.dev/gemini-api/docs/deprecations>
- Billing/caps: <https://ai.google.dev/gemini-api/docs/billing> and
  <https://blog.google/innovation-and-ai/technology/developers-tools/more-control-over-gemini-api-costs/>
- Rate limits: <https://ai.google.dev/gemini-api/docs/rate-limits> and
  <https://aistudio.google.com/rate-limit> (per-account truth)
- Cloud budgets (alert-only): <https://docs.cloud.google.com/billing/docs/how-to/budgets>
