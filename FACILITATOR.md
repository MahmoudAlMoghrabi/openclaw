# Facilitator notes (AI Garage)

This repo is the one-click attendee environment. An attendee creates a Codespace,
runs one command to drop in their key, and opens port 18789. That is the whole
"get running" step.

**Companion docs:** attendees follow [docs/ATTENDEE_GUIDE.md](docs/ATTENDEE_GUIDE.md);
the minute-by-minute clock, T-minus checklist, and failure playbook live in
[docs/FACILITATOR_RUNBOOK.md](docs/FACILITATOR_RUNBOOK.md); the deck is
[docs/slides.html](docs/slides.html). This file is the cost, model, and
key-provisioning plan.

## How the files map to the session

| Agenda step | What powers it |
|---|---|
| Get your agent running | The Codespace + `scripts/use-key.sh` (then `scripts/healthcheck.sh` to confirm green) |
| Use a skill (demo) | `skills/fortune-teller/` ("tell me my tech fortune for the week"); `skills/standup-writer/` is a second demo |
| Build a skill | `skills/guided-skill/` (the `code-roaster` guided template, 5 TODOs) |
| Let the agent build a skill | In chat: the agent drafts a skill, you review and approve (propose, review, approve, verify) |

## Run of show (90 min), the interactive arc

The arc: **laugh → "wait, I built that?" → make your own → show off → why it's
more than a chatbot → the agent builds its own skill.** Funny hooks them; the
informative beats make it stick. Skill menu for attendees: [skills/EXAMPLES.md](skills/EXAMPLES.md).

| Time | Block | Do this | Funny / interactive | Informative beat |
|---|---|---|---|---|
| 10 min | **Intro** | What an agent is; the 🦞 mascot; safety ground rules | Open with the CLI's jokey tagline on screen | "Same brain as a chatbot, but it has hands (tools) and you can teach it." Safety: treat it as public, no secrets |
| 15 min | **Get running** | Everyone runs `./scripts/use-key.sh` and pastes their key at the hidden prompt, opens 18789, connects, says hello; `./scripts/healthcheck.sh` confirms a green board | First one to get a reply shouts it out | Note the "overloaded" message is normal; retry. It costs pennies (show the token meter once). Keys paste invisibly, so no one's key shows on a projector |
| 30 min | **Build a skill** (`code-roaster`) | See the segment below | Same-skill sprint, then build-your-own + gallery + vote | "You just programmed an AI in plain English. No code. That's a skill." |
| 20 min | **Let the agent build a skill** | In chat, the agent drafts a skill; you review and approve before it saves anything | "Stump the agent" 30-sec game while drafts generate | Human-in-the-loop: the agent proposes, a human approves. This is the real agentic pattern |
| 15 min | **Demos + wrap** | 5-6 volunteers cast their agent to the projector; vote best | Crowd vote, tiny prize | Answer "why not just ChatGPT?" with your one stronger-model tool demo (meme/diagram). Recap safety |

Interactive mechanics to sprinkle in:

- **Same-skill sprint:** whole room builds ONE funny skill together (excuse
  generator is a good first one), then everyone fires it at once. Shared laugh,
  nobody stuck for an idea.
- **Gallery + vote:** volunteers project their agent's funniest output; room votes.
- **Skill swap:** pairs trade skill names and try each other's.
- **Stump the agent:** 30-sec challenge to make it do something badly. Funny,
  and teaches limits + hallucination ("it can confidently make things up, that's
  why good skills give it rules").

## Running the "Build a skill" segment (~30 min core)

Guiding principle: **everyone builds the SAME skill together first**, then
customizes. Beginners freeze when asked to invent an idea from scratch, so the
guided template gives them one: `code-roaster`. The template is pre-named, so
there is nothing to rename; they just fill in the 5 TODOs.

1. **Show what a skill is (~5 min).** On your projected screen, demo the
   pre-built one: say "tell me my tech fortune for the week" and let them watch
   `fortune-teller` transform it. Now "a skill" is concrete.
2. **Build one together, live (~10 min).** Everyone opens
   `skills/guided-skill/SKILL.md` (the `code-roaster` template). Do **TODO 2,
   the `description`, together**, since the description is the trigger: project
   a vague one that fails to fire, then a specific one that does. Then **save**
   (Ctrl+S), run **`./scripts/reload-skill.sh guided-skill`** in the terminal,
   and **refresh the agent tab**. In the chat, say **"roast this code"** and
   paste the sample from `skills/guided-skill/roast-me.js`. Everyone sees their
   own agent do the thing they just wrote, the "whoa" moment.
3. **Make it theirs (~15 min).** Invite them to fill in the remaining TODOs
   (persona, output structure, rules) so the roaster is genuinely theirs. Same
   loop: edit, save, `./scripts/reload-skill.sh guided-skill`, refresh, retry.
   Helpers roam. The answer key is `skills/guided-skill/SOLUTION.md` for anyone
   who falls behind; early finishers go to `skills/stretch-ideas.md`.

Put on a slide the loop: **edit -> save -> `./scripts/reload-skill.sh guided-skill`
-> refresh -> "roast this code".**

Why the reload step: OpenClaw runs the agent against an installed COPY of each
skill (in `~/.openclaw/workspace/skills/`), not the repo file. `use-key.sh`
installs the demo skills at setup so the fortune demo works out of the box; the
`code-roaster` template installs the first time an attendee runs
`./scripts/reload-skill.sh guided-skill`, and after any edit the copy must be
refreshed. `reload-skill.sh` does that (force-reinstall + gateway restart).

The three things that trip people (pre-empt them):

- **Editing without reloading:** the file change is invisible until
  `./scripts/reload-skill.sh guided-skill` runs and the tab is refreshed.
- **Breaking the top block:** the `---` lines and the words before the colons
  must stay intact; only edit after `description:` and in the body.
- **Typing instructions inside the `<!-- -->` notes** instead of on a plain line
  (the template uses `<!-- -->` for its TODO hints, so this one is common).

**Confirm in the final dry run:** the reload path (force-reinstall + gateway
restart) is deterministic and works, but is the restart strictly necessary? If
editing the installed copy reloads live, `reload-skill.sh` can drop the restart
for a smoother, session-preserving flow. Test once and simplify if so.

## Dry run done (July 6, 2026), connection flow verified

A full dry run on OpenClaw 2026.6.11 confirmed the attendee flow works with the
single command `./scripts/use-key.sh` (key pasted at a hidden prompt). Five issues were found and fixed in
the scripts (details in [BRIEF.md](BRIEF.md) §9):

1. Scripts made executable.
2. `onboard` now passes `--accept-risk` (required in this version).
3. OpenClaw reads `~/.openclaw/openclaw.json`, NOT `config.json5`; onboard
   defaulted to a Pro model, so [scripts/patch-config.js](scripts/patch-config.js)
   forces `google/gemini-2.5-flash-lite` after onboard.
4. `start-gateway.sh` always `--force`-restarts (the boot gateway ran keyless).
5. The Codespaces proxy rewrites the browser origin to `http://localhost:18789`;
   patch-config.js allowlists it and sets `auth: none`.

Still confirm each time you install a new version:

- **Model in use.** After `use-key.sh`, the Control UI footer should read
  "Gemini 2.5 Flash-Lite". If a new OpenClaw changes config keys, patch-config.js
  may need updating.
- **CLI name.** Confirmed `openclaw` (scripts still fall back to `clawdbot`).
- **Node image tag.** `javascript-node:22-bookworm` is safe.
- **Gateway stays up** for the full session once started.

## Before the day

- **Pin the version.** Set `OPENCLAW_VERSION` in `.devcontainer/setup.sh` to the
  exact version you tested. Never ship `latest` on workshop day.
- **Turn on Codespaces prebuilds** for this repo (Settings > Codespaces >
  Prebuilds). With 25 people building at once, prebuilds turn a 5-minute wait
  into seconds.
- **Make this a template repo** (Settings > Template repository) if you want each
  attendee to take a copy home.

## The key plan (paid tier, decided July 2026)

The event runs on the PAID tier of a dedicated TechNL-controlled billing
account. Free tier is out: free quotas (~10-15 req/min per project, low daily
caps) cannot carry 50 people on shared projects, and Google cut free limits
without notice twice since Dec 2025.

- **Provision:** `BILLING_ACCOUNT=<id> ./keys/provision-keys.sh 5 10 technl-ws`
  gives 5 billing-linked projects x 10 keys (one key per attendee). Rate limits
  are per PROJECT per model, so projects carry the load; extra keys just let us
  revoke one attendee without disrupting the rest.
- **Model:** `google/gemini-2.5-flash-lite` ($0.10/$0.40 per 1M tokens, the
  cheapest stable model; shuts down Oct 16, 2026, fine, the event is before
  that). Overflow/fallback: `gemini-3.1-flash-lite` ($0.25/$1.50, GA).
  NOT 3.5-flash (would blow the cap), NOT any -preview (crippled quotas).
- **Cost:** expected ~$18 for 50 attendees, worst case ~$45. These make the
  numbers quoted to TechNL ($15-30, $100 cap) true with margin.
- **Caps (three layers, verified July 2026):**
  1. AI Studio project spend cap, the ENFORCED one. Set manually in
     aistudio.google.com -> Settings -> Spend at $100. It pauses traffic
     (~10 min lag). Never set it below worst-case usage or it will pause the
     whole room mid-workshop ($100 vs $45 worst case = 2x margin).
  2. Google's automatic Tier 1 cap: $250/month hard pause across the account.
  3. Our Cloud Billing budget ($100, via `set-budget.sh`), ALERTS ONLY
     (emails at $50 / $90 / $100).
- **Rate limits:** Tier 1 is roughly 300 RPM / ~1M TPM per project per model
  (unofficial; Google no longer publishes). 50 agent users need ~3-6M TPM.
  Limits are per project PER MODEL, so 5 projects x 2 models (primary +
  overflow) = ~10 pools ≈ 10M TPM, which covers demand at Tier 1. If 429s
  appear on the day, move half the room to the overflow model. (Tier 2 exists
  but costs $100 of real spend to reach, pointless at flash-lite prices.)
  Read the REAL numbers for the actual account at
  <https://aistudio.google.com/rate-limit>, that page is the only authority.
- **Teardown:** `./keys/teardown-keys.sh` unlinks billing and deletes the
  projects; then remove the AI Studio caps and the alert budget by hand (the
  script prints the steps).
