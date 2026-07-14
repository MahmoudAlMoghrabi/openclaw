# Attendee Guide: Build a Real AI Agent in 90 Minutes

Keep this open in a tab for the whole session. Each part ends with a
**Checkpoint**: if you hit it, you're on pace. If you're stuck for more
than 2 minutes, raise a hand; facilitators are faster than debugging alone.

---

## Part 0: Before the intro ends (do this now)

1. Sign in to **github.com**.
2. Open the workshop repo link (on the screen or in the event chat).
3. Click **Code**, then **Codespaces**, then **Create codespace on main** (or the badge in the README).
4. Let it build while you listen to the intro (about 2 min). When you see a
   terminal at the bottom of the browser window, you're ready.

**Checkpoint:** a VS Code editor in your browser with a terminal prompt.

---

## Part 1: Get your agent running (15 min)

You'll need the **Gemini API key slip** handed out in the room.

1. In the terminal, run:
   ```bash
   ./scripts/use-key.sh
   ```
2. Paste your key at the hidden prompt and press Enter. Nothing shows on
   screen as you paste; that is expected. The key is format-checked, and you
   get 3 tries.
3. Wait for the script to print **All set.** It onboards your agent, applies
   the workshop config, installs your skills, and starts the gateway for you.
4. Open the **PORTS** tab (next to the terminal), find port **18789**, and
   click the globe icon. A page opens asking you to connect: leave the token
   and password fields blank and click **Connect**.
5. In the chat, introduce yourself:
   > hello! introduce yourself in one paragraph

6. Your agent came with a pre-installed demo skill. Try it:
   > tell me my tech fortune for the week

   Then look at what just happened: open
   [`skills/fortune-teller/SKILL.md`](../skills/fortune-teller/SKILL.md) in the
   editor. **That Markdown file is the entire capability.** The
   `description` in the frontmatter is how the agent knew "tell me my tech
   fortune" should trigger it; the body is the instructions it followed.
   (A second demo skill, `standup-writer`, is installed too if you want to
   poke at another one.)

**Checkpoint:** your agent responds in the chat, and the fortune comes back in
the exact structure the SKILL.md dictates (The Vision, The Prophecy, The
Warning, Lucky item). Optional: run `./scripts/healthcheck.sh` for a green
board.

> **If something's broken:** re-run `./scripts/use-key.sh` (it's safe), then
> `bash scripts/start-gateway.sh`, then `tail -50 /tmp/openclaw-gateway.log`
> to read the last log lines, then `./scripts/healthcheck.sh`, then raise a
> hand. If the agent says it's "temporarily overloaded", that's a transient
> Google hiccup: just resend your message (the configured fallback model helps
> too).

---

## Part 2: Build a skill, `code-roaster` (30 min), the core

You're going to give your agent a new capability: reviewing code as a
world-weary staff engineer whose feedback is a roast. Funny, but every burn
maps to a real, fixable issue.

### 2.1 Open the template (5 min)

Your starting point already exists in the repo, pre-named `code-roaster`:

```bash
code skills/guided-skill/SKILL.md
```

You edit this file directly. There is nothing to copy or rename.

### 2.2 Work through the 5 TODOs (15 min)

The template walks you through them; here's why each one matters:

| TODO | What you write | The lesson |
|---|---|---|
| 1. `name` | `code-roaster` (done for you) | How the skill is addressed |
| 2. `description` | What it does **and when to use it** | **This is the trigger.** The agent picks skills by reading descriptions: vague description, skill never fires |
| 3. Persona | Who the agent *is* while the skill runs | Personality is configuration, not magic |
| 4. Output structure | Numbered sections the response must follow | Structure is what separates a skill from a vibe |
| 5. Rules | Guardrails: roast code not people, real issues only, length cap | Rules are where prompts become products |

Write real content; don't just uncomment the suggestions. Your roaster
should not sound like your neighbour's.

> **Falling behind?** The finished answer key lives at
> [`skills/guided-skill/SOLUTION.md`](../skills/guided-skill/SOLUTION.md).
> Peek if you're stuck, but try your own version first.

### 2.3 Load it and test it (5 min)

Editing the file isn't enough on its own. Your agent runs against an installed
copy of the skill, so you have to reload it:

```bash
./scripts/reload-skill.sh guided-skill
```

Then **refresh your agent's browser tab**. In the chat:

> roast this code

then paste the contents of
[`skills/guided-skill/roast-me.js`](../skills/guided-skill/roast-me.js): a
sample stuffed with real, findable problems (swallowed exceptions, duplicated
branches, an unbounded recursion, a `flag, flag2, mode` signature).

**Judge the output against your own spec:**
- Did it follow *your* structure, or freestyle?
- Is every roast tied to a real issue in the snippet?
- Did the "okay, but seriously" section give genuinely good fixes?

### 2.4 Iterate (5 min)

Wherever it disappointed you, don't argue with it in chat. **Edit the
SKILL.md**, save, run `./scripts/reload-skill.sh guided-skill` again, refresh
the tab, and ask again. Too mean? Add a rule. Ignored your structure? Number
the sections and say "exactly this structure". Too long? Hard word cap.

This loop, edit instructions, reload, retry, is the actual craft of
skill-building. Chat fixes one answer; the skill file fixes every future
answer.

**Checkpoint:** your roaster follows your structure on `roast-me.js`, and
you've done at least one edit, reload, retry iteration.

**Done early?** Pick a stretch skill: [`skills/stretch-ideas.md`](../skills/stretch-ideas.md).

---

## Part 3: Let the agent build a skill (20 min)

Now flip the roles: the agent writes, **you** review. This
human-in-the-loop pattern is the entire point of working agentically.

### 3.1 Commission a skill (5 min)

In the chat, adapt this prompt (pick any capability you actually want):

> Draft a new skill for yourself called `pr-describer`. When I paste a diff
> or describe a change, it should write a pull-request description with
> sections: Summary, Changes, Test plan, Risk. Write the complete SKILL.md,
> frontmatter with name and description, persona, output structure, and
> rules, but **show it to me in chat first. Do not save any files until I
> approve.**

That last sentence is the important one. You're the approval gate.

### 3.2 Review the draft like a pull request (10 min)

Read what it wrote *before* letting it near the filesystem. Check:

- **Frontmatter:** is the `description` specific enough to trigger at the
  right moments (and *not* fire on unrelated requests)?
- **Scope creep:** did it grant itself abilities you didn't ask for
  (running commands, reading files, "and I'll also...")? Ask it to remove them.
- **Vague instructions:** "be helpful and thorough" is not a spec. Make it
  demand the structure you'd demand in code review.
- **Rules:** does it have real guardrails, or is it all persona?

Ask for at least **one revision**: even a good draft has something worth
tightening. Then, and only then:

> Approved. Save it to skills/pr-describer/SKILL.md

### 3.3 Verify (5 min)

Load the new skill the same way you loaded your roaster, then ask the agent to
use it on a real input:

```bash
./scripts/reload-skill.sh pr-describer
```

Refresh the tab, try it in chat, and confirm the file it saved matches what
you approved:

```bash
cat skills/pr-describer/SKILL.md
```

**Checkpoint:** an agent-authored, human-reviewed, working skill, and you
rejected at least one thing along the way.

> **Meta-note:** you just ran the loop every serious agent deployment runs:
> propose, review, approve, verify. The agent drafts fast; the human owns the
> judgment. Skip the review step at home and you'll eventually approve
> something you shouldn't have.

---

## Part 4: Demos and wrap-up (15 min)

**Demoing?** Best formula: one-line setup ("I built a shell-explainer"),
paste a spicy input, let the output land. Strong personality plus strict
format wins the room.

### Safety recap: what today's setup quietly did right

| Ground rule today | The principle at home |
|---|---|
| Agent lived in a throwaway Codespace | Sandbox first: container or VM, never your main machine on day 1 |
| Chat only, gateway bound to localhost | Don't expose the gateway; leave DM policy on pairing-required |
| Gateway auth disabled (`auth=none`) and only the localhost origin allow-listed, but the forwarded port is **Private**, so GitHub authenticates you before any request reaches it | Auth layers can be traded, never dropped: we relied on the Codespace's private forwarded port as the gate. At home, keep device auth **on**; there's no private port guarding your laptop |
| Pooled Gemini keys, revoked tonight | Scope and rotate keys; never commit them |
| Agent-written skill needed *your* approval | Keep exec approvals on; review anything an agent writes before it runs |
| One attendee per agent | OpenClaw's trust model is one operator per gateway; don't share one |

Running it at home later? Start at [docs.openclaw.ai](https://docs.openclaw.ai),
read the **security** page before connecting any messaging channel, and run
`openclaw security audit --deep` after config changes.

### Before you leave

1. Your Codespace: github.com/codespaces, then choose **... then Delete** (or
   keep it to play; it auto-stops when idle, but the pool key dies tonight, so
   bring your own key from
   [aistudio.google.com](https://aistudio.google.com/app/apikey)).
2. Take your skill files with you; they're just Markdown:
   ```bash
   cat skills/guided-skill/SKILL.md
   ```
   Copy anywhere. They'll work in any OpenClaw install.

Thanks for building with us. AI Garage x TechNL
