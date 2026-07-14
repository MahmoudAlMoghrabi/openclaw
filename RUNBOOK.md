# Workshop runbook, the whole plan in plain language

This is the step-by-step guide for running the TechNL OpenClaw workshop.
No background needed: follow it top to bottom. Technical detail and sources
live in [BRIEF.md](BRIEF.md).

## What we need (the complete list)

**Accounts and money:**

1. **One Google account for the workshop.** Created fresh, controlled by
   TechNL (not anyone's personal account), with billing enabled (a card, or
   prepaid credit). This single account powers every attendee's AI agent.
2. **A budget of $100 approved.** We expect to actually spend $15-30 for 50
   people (worst realistic case ~$45). The account is capped at $100 so it
   physically cannot spend more, and Google adds its own automatic $250
   ceiling on top. These are the exact numbers already given to TechNL.
3. **A GitHub account that owns this repo,** with the repo made public and
   Codespaces prebuilds turned on. Attendees use their own GitHub accounts,
   which cost them nothing.

**People and time:**

4. **~1 hour this week** to create the Google account and run its first
   checks (the dry run depends on it existing).
5. **One half-day dry run** one to two weeks before the event: a full
   rehearsal by one person, timed and measured.
6. **On the day: 2-3 helpers** who did the dry run, plus one person watching
   the spending dashboard during the session.

**From TechNL** (already asked in [comms/technl-ask.md](comms/technl-ask.md)):

7. Final headcount, session length, room with solid wifi and power outlets,
   a projector, and whether attendees bring personal or work laptops.

That's everything. No servers, no installs, no software licences.

## The plan, step by step

### Step 1: This week

- [ ] Answer TechNL's cost question before their Thursday newsletter:
      *"Roughly $15-30 for 50 attendees, capped at $100, keys revoked right
      after."* (These match what Arash already sent them.)
- [ ] Create the dedicated Google account, enable billing, and note whether
      Google put it on prepaid credit or a normal card.
- [ ] In Google AI Studio (aistudio.google.com), check two pages:
      **Settings → Spend** (confirm the spend-cap feature exists on this
      account) and the **rate-limit page** (note the real numbers).

### Step 2: Dry run (1-2 weeks before)

The click-by-click version of this step is [EXPERIMENT.md](EXPERIMENT.md),
anyone can run it solo in ~30 minutes on a free key.

- [ ] One person runs the whole attendee journey: create the Codespace, drop
      in a key, chat with the agent, build a skill.
- [ ] Confirm the agent runs on the model we pinned
      (`gemini-2.5-flash-lite`). If OpenClaw rejects it, switch the config to
      `gemini-3.1-flash-lite` (one line) and re-check the numbers in BRIEF.md
      §5 against the $100 cap.
- [ ] Chat for a full 30 minutes, then read the token usage off the AI Studio
      dashboard. Multiply by 50. That number must sit clearly below $100,
      it will, by a wide margin, unless something is misconfigured.
- [ ] Pin the OpenClaw version that worked in
      [.devcontainer/setup.sh](.devcontainer/setup.sh).
- [ ] Make the repo public, enable Codespaces prebuilds, rehearse the
      teardown script once.

### Step 3: A few days before

- [ ] Send the attendee email ([comms/attendee-email.md](comms/attendee-email.md))
      after filling its three placeholders: date/location, repo link, contact.
- [ ] Create the keys with one command:
      `BILLING_ACCOUNT=<id> ./keys/provision-keys.sh 5 10 technl-ws`
      That makes 5 projects with 10 keys each = 50 keys, and sets up the
      spending alerts automatically.
- [ ] Set the enforced cap: AI Studio → Settings → Spend → $100. (The script
      prints a reminder; this one step is manual because Google offers no
      command for it.)
- [ ] Print each key on its own slip. Shuffle the slips before handing out,
      so people sitting together aren't all on the same project.

### Step 4: Event day

- [ ] Hand each attendee one slip at the door.
- [ ] One person keeps the AI Studio usage page open for the whole session.
      Alert emails arrive automatically at $50, $90, and $100.
- [ ] If one attendee's agent misbehaves, revoke just their key; nobody else
      is affected.
- [ ] Stuck agent? Helpers run `./scripts/start-gateway.sh` and refresh.

### Step 5: Same evening

- [ ] Run `./keys/teardown-keys.sh`, it disconnects billing and deletes
      every project (all keys die with them).
- [ ] Remove the AI Studio cap and the alert budget (the script prints how).
- [ ] Confirm the account shows zero ongoing spend, and tell TechNL the final
      actual cost.

## If something goes wrong on the day

| Problem | Fix |
|---|---|
| Agents slow down / "rate limit" errors | Move half the room to the overflow model `gemini-3.1-flash-lite` (limits are counted per model, so this doubles capacity instantly) |
| The $100 cap trips | You'll have had two warning emails first ($50, $90); raise the cap in AI Studio, takes ~10 min to apply. Honest usage cannot reach it, investigate abuse before raising |
| Someone can't create a Codespace | Pair them with a neighbor; keys are individual but every exercise works in pairs |
| A key leaks or is abused | Revoke that one key; the other 49 keep working |

## One date to remember

The pinned model (`gemini-2.5-flash-lite`) is retired by Google on
**October 16, 2026**. This plan works as-is for any event before that date.
For a rerun after it, change the config to `gemini-3.1-flash-lite` and use
BRIEF.md §5 to re-derive the numbers (they roughly triple).
