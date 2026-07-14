# Facilitator Run-book: TechNL OpenClaw Workshop

Internal document. Attendees never need this.

This is the minute-by-minute companion to [`../FACILITATOR.md`](../FACILITATOR.md),
which holds the cost, model, and key-provisioning plan. Read that first for the
"why"; use this for the "when".

---

## T-minus checklist

### T-2 weeks
- [ ] Create or verify the GitHub org repo; replace `YOUR-ORG/openclaw-workshop` in the README badge link.
- [ ] Enable **Codespaces prebuilds** on `main` (repo Settings, Codespaces, Set up prebuild) so first launch is about 30s, not about 3 min.
- [ ] Confirm attendee comms went out: *GitHub account required; sign in once beforehand; brand-new accounts may need phone verification; bring a laptop.*

### T-1 week, dress rehearsal (non-negotiable)
- [ ] Fresh Codespace on a **free-tier personal GitHub account** (matches attendee conditions), run the full attendee guide start to finish, timing each part.
- [ ] **Confirm the model ID:** run `openclaw models list --provider google` and confirm the flash-lite identifiers. The single source of truth is `MODEL` in [`../scripts/patch-config.js`](../scripts/patch-config.js) (overridable with `OPENCLAW_MODEL`); update it only if it differs from `google/gemini-2.5-flash-lite`. Send one test message on both primary and fallback (`google/gemini-3.1-flash-lite`).
- [ ] **Verify onboarding flags** against the installed OpenClaw version: `openclaw onboard --help`. The pinned assumption in `use-key.sh` is `--non-interactive --accept-risk --skip-health --mode local --auth-choice gemini-api-key --gemini-api-key <key>`. Flag names have churned between releases; do not skip this.
- [ ] Confirm `patch-config.js` writes the model paths this OpenClaw version reads in `~/.openclaw/openclaw.json` (`agents.defaults.model.primary` and `.fallbacks`); fix syntax if the schema moved.
- [ ] Run `./scripts/healthcheck.sh`: all green.
- [ ] Note the OpenClaw version that rehearsed clean. The pin lives in `OPENCLAW_VERSION` in `.devcontainer/setup.sh` (currently `2026.6.11`). If a release lands between rehearsal and event day, keep the pin at the tested version and re-trigger the prebuild.

### T-1 day
- [ ] **Gemini key pool:** provision with the `keys/` scripts per [`../FACILITATOR.md`](../FACILITATOR.md) and [`../RUNBOOK.md`](../RUNBOOK.md) (1 key per expected attendee plus 30% spares plus 2 facilitator keys). Paid-tier billing account, as decided in the key plan.
- [ ] Print key slips (key plus the repo short-link). Number the slips; keep a numbered spare stack.
- [ ] Prepare 2 to 3 **spare Codespaces** on facilitator-owned GitHub accounts, already set up past `./scripts/use-key.sh`: these are the loaner machines for attendees whose accounts won't launch.
- [ ] Load `docs/slides.html` on the presenter laptop (it's fully offline-safe).
- [ ] Re-trigger one fresh Codespace launch to confirm the prebuild still works.

### T-0 (in the room)
- [ ] Venue wifi sanity test: launch one Codespace, one chat round-trip.
- [ ] Repo short-link on screen plus in event chat.
- [ ] Whiteboard the fix-it ladder: `./scripts/use-key.sh` (re-run) then `bash scripts/start-gateway.sh` then `./scripts/healthcheck.sh` then raise a hand.

---

## Minute-by-minute (90 min)

| Clock | Segment | Facilitator actions |
|---|---|---|
| 0:00 to 0:03 | Doors, settle | Slide 1 up. **Tell everyone to start their Codespace *now*:** builds happen during the intro. |
| 0:03 to 0:13 | **Intro** (slides 2 to 6) | What an agent is (model plus tools plus loop), why OpenClaw is the moment, safety ground rules. Keep to 10; the room wants to build. |
| 0:13 to 0:28 | **Part 1: agent running** | Hand out key slips. Live-demo `./scripts/use-key.sh` on the projector (the key pastes invisibly, so nothing leaks on screen). Floaters sweep for red marks. **0:23 checkpoint call-out:** "who has a fortune?", expect over 80% hands. |
| 0:28 to 0:58 | **Part 2: build code-roaster**, the core | Slide 8 (skill anatomy) stays up. Live-edit TODO 2 (the description), worth doing badly first: show a vague description *not* triggering, then fix it. **0:43:** everyone should be running `./scripts/reload-skill.sh guided-skill` and testing against `roast-me.js`. **0:50:** force one edit, reload, retry iteration even for happy campers. Early finishers to `stretch-ideas.md`. |
| 0:58 to 1:18 | **Part 3: agent builds a skill** | Slide 10 (human-in-the-loop) up. Emphasize the *"show me first, don't save files until I approve"* clause; walk the room; anyone whose agent wrote straight to disk gets the teachable moment. Require one revision before approval. |
| 1:18 to 1:28 | **Demos** | 3 to 4 volunteers, 2 min each: one-liner setup, spicy input, let output land. Have your own rehearsed demo as filler. |
| 1:28 to 1:30 | **Wrap-up** (slides 12 to 14) | Safety recap table, delete-your-Codespace moment (do it together), keys die tonight, where to go next. |

### Flex: 60-minute version
Drop Part 3 entirely; compress demos to 5 min. Intro 8 min, Part 1 stays 15 (it's floor-limited by wifi, not content), Part 2 stays 30, it's the product.

### Flex: 120-minute version
Insert after Part 3: **Connect an external channel (25 min)**. Telegram is the lightest lift (BotFather token, `openclaw channels add telegram` flow, message your agent from your phone; pairing-required stays ON, which *is* the security demo). Verify the exact channel-add CLI during rehearsal. Extend demos by 5.

---

## Failure playbook

| Symptom | Fix | Notes |
|---|---|---|
| Codespace won't create (new account, quota, verification) | Ladder: retry create, then **loaner spare Codespace** from facilitator stack, then pair with neighbour | Never debug an attendee's GitHub account live; hand them a loaner and move on |
| `openclaw: command not found` | postCreate still running or failed, then `npm install -g openclaw@2026.6.11` | About 60s; keep them talking |
| Key rejected at the hidden prompt | Typo (slips have ambiguous chars): the prompt format-checks and gives 3 tries; if it still fails, issue a spare slip | Cross out dead slips so they don't circulate |
| `429` or quota errors mid-session | Swap in a spare key: re-run `./scripts/use-key.sh` with the new slip | If it's several people at once, the *pool project* rate limit is hit. Announce a 2-min breather. The overflow model `gemini-3.1-flash-lite` is already configured and auto-engages; to move a person fully onto it, re-run `OPENCLAW_MODEL=google/gemini-3.1-flash-lite ./scripts/use-key.sh` |
| Agent replies "temporarily overloaded" | Transient Google 503; just resend | The configured fallback also absorbs these; not an attendee error |
| Gateway won't start or `EADDRINUSE` | `bash scripts/start-gateway.sh` (it force-restarts); read `tail -50 /tmp/openclaw-gateway.log` | One gateway per Codespace, usually a double-run of `use-key.sh`. `start-gateway.sh` always passes `--force` to replace the keyless boot gateway |
| Control UI asks for a token or password | `use-key.sh` runs `patch-config.js`, which sets `auth: none`, so just leave both fields blank and click **Connect**. If it still prompts, the patch didn't apply: re-run `./scripts/use-key.sh` (safe) and refresh the tab | Auth is intentionally off here; the gate is the Private forwarded port |
| Control UI blank | Must use the **HTTPS forwarded URL** from the Ports tab (WebCrypto needs a secure context): open it via the globe icon, not a raw IP. Port visibility can stay Private (it's their own session) | |
| "Browser origin not allowed" | Should not happen: `patch-config.js` allow-lists `http://localhost:18789` (the origin the Codespaces proxy rewrites to) and every Codespace uses the same value. If it appears, the patch didn't apply: re-run `./scripts/use-key.sh` and refresh | **Why disabling device auth is OK here and ONLY here:** the forwarded port is Private, so GitHub authenticates the Codespace owner before any request reaches the gateway. The port's visibility must stay Private; flipping it Public removes the only gate. Never use `auth: none` outside a sandboxed single-user environment |
| Agent replies but skill never triggers | 90% a vague `description` in frontmatter, that *is* the lesson of TODO 2; fix the description, run `./scripts/reload-skill.sh guided-skill`, refresh the tab. Also confirm the edit landed in the repo file `skills/guided-skill/SKILL.md` (reload installs the copy the agent runs) | Turn it into a room-wide teaching beat if 3 or more people hit it |
| Agent saved files without approval in Part 3 | The prompt's "do not save until I approve" was dropped or softened | Also a teaching beat: instruction precision equals control |
| Room-wide catastrophe (npm registry down, Gemini outage) | Facilitator's pre-built spare Codespace on projector, convert to guided group demo; attendees follow in pairs on whatever environments are alive | The show goes on |

## Post-session
- [ ] **Revoke and tear down every pool key** with `./keys/teardown-keys.sh`, then remove the AI Studio caps and alert budget by hand (the script prints the steps). Full procedure in [`../RUNBOOK.md`](../RUNBOOK.md) and [`../BRIEF.md`](../BRIEF.md).
- [ ] Delete facilitator spare Codespaces.
- [ ] Note timings and failures observed, then update this run-book.
- [ ] Share the repo link plus a "run it at home safely" pointer (docs.openclaw.ai security page) in the event follow-up.
