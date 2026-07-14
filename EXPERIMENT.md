# Try the workshop yourself, the 30-minute experiment

Pretend you're an attendee and test everything, start to finish. It's free,
takes about 30 minutes, and everything happens in your web browser. Doing this
once answers most of the official dry-run questions in
[RUNBOOK.md](RUNBOOK.md) Step 2.

## Before you start

You need two things: your GitHub account and a Google account. That's all.

## The experiment

### Step 1: Get your test key (2 minutes)

1. Go to <https://aistudio.google.com/apikey> and sign in with Google.
2. Click **Create API key**.
3. Copy the long code it gives you. That code is your "key."

### Step 2: Open the workshop environment (3 minutes)

1. Go to the repo on GitHub.
2. If you are testing an unmerged branch: click the branch dropdown (says
   **main**) and pick the branch first.
3. Click the green **Code** button → **Codespaces** tab → **Create codespace**.
4. Wait about a minute. A code editor opens in your browser. This is the same
   screen every attendee will see. In its terminal you should see
   "Installing OpenClaw" scroll by.

### Step 3: Plug in your key (1 minute)

In the black terminal panel at the bottom, type this and press Enter:

```bash
./scripts/use-key.sh
```

It prompts for your key. Paste it and press Enter, it stays hidden as you paste
(nothing shows on screen). That is intentional, so no one can read your key off
the screen.

### Step 4: Meet your agent

A new browser tab should open by itself with a chat screen. If it doesn't:
click the **Ports** tab next to the terminal, find the row with **18789**,
and click the little globe icon. Then:

- Say hello.
- Paste some messy notes about your day and say:
  *"use the standup-writer skill."*
- Open `skills/my-first-skill/SKILL.md`, follow the notes inside, save it,
  and watch your agent learn a new trick.

If all of that works, the workshop works. That's the whole test.

## What "working" looks like

After Step 3, the Control UI footer should read **"Gemini 2.5 Flash-Lite"** and
the agent should reply to a message. The July 6 dry run found and fixed five
issues (executable bit, `--accept-risk`, model pin via patch-config.js, forced
gateway restart, and the `http://localhost:18789` origin), so on a fresh
Codespace the single `use-key.sh` command should now handle everything.

Two things still worth capturing while you test:

1. After ~30 minutes of chatting, how many tokens does AI Studio
   (<https://aistudio.google.com>) say you used? Multiply by 50 = the real
   event cost, which replaces our estimate.
2. `npm ls -g openclaw`, the version number to pin in
   [.devcontainer/setup.sh](.devcontainer/setup.sh) (dry run confirmed 2026.6.11).

## When you're done, 3 cleanup steps

1. **Stop the Codespace:** go to <https://github.com/codespaces>, click the
   **⋯** next to yours, click **Stop**. (Leaving it running uses up your free
   monthly hours.)
2. **Delete your test key** at <https://aistudio.google.com/apikey>.
3. Record your 5 answers where the team can see them.

## If something looks stuck

Type this in the terminal and refresh the agent's browser tab:

```bash
./scripts/start-gateway.sh
```

Still stuck? `cat /tmp/openclaw-gateway.log` shows the agent's diary, it
will say exactly what went wrong.
