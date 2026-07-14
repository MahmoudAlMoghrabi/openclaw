<div align="center">
  <img src="docs/openclaw-banner-dark.png" alt="OpenClaw" width="760" />
</div>

# Build Your First AI Agent

**A hands-on workshop, powered by [OpenClaw](https://openclaw.ai)** · No installs · runs in your browser · about 90 minutes

Welcome! Everything is already installed for you, **no setup, no code.** In a few
minutes you'll have your own AI agent running right in your browser. By the end,
you'll have taught it a brand-new skill *you* wrote. Just three things to start 👇

## 🚀 1. Open this in a Codespace

You are probably already here. If not, click the green **Code** button on the
GitHub page, then **Create codespace on main**. Give it about a minute to load.

## 🔑 2. Drop in your key

In the terminal at the bottom of the screen, run this and press **Enter**:

```
./scripts/use-key.sh
```

It will ask for your key. Paste the key we handed you and press **Enter**. Your
key stays hidden as you paste (nothing shows on screen), which is expected.

Wait a few seconds until it says **All set.**

## 💬 3. Open your agent

Click the **Ports** tab (next to the terminal), find port **18789**, and click
the globe icon. A page opens asking you to connect, **leave the boxes empty and
click Connect.** Then type "hello" in the chat.

If your agent replies, you are running a real AI agent. 🎉

> **If you see "The AI service is temporarily overloaded":** that is normal and
> not your fault, just send your message again. It usually works on the next try.

---

## 🛠️ During the workshop

**1. Try the demo skill.** Your agent already knows a skill called
`fortune-teller`. In the chat, say **"tell me my tech fortune for the week"**
and watch what it does. (A second demo skill, `standup-writer`, is installed
too if you want to try another.)

**2. Build your own skill.** The main exercise is `code-roaster`, a guided
build with a ready-made template. Open `skills/guided-skill/SKILL.md` and work
through the 5 TODOs to make the agent roast pasted code (funny, but every burn
is a real, fixable issue). The loop is:

- **Edit** `skills/guided-skill/SKILL.md` and **save** (Ctrl+S).
- In the terminal, run **`./scripts/reload-skill.sh guided-skill`** so your
  agent picks up the change.
- **Refresh** your agent's browser tab.
- In the chat, say **"roast this code"** and paste the sample from
  `skills/guided-skill/roast-me.js`. Then edit, reload, and retry to make it
  yours.

**Want more ideas?** Open [skills/EXAMPLES.md](skills/EXAMPLES.md) for a menu of
fun and useful skills (an excuse generator, a pirate rewriter, a grammar fixer,
a quiz maker, and more), and [skills/stretch-ideas.md](skills/stretch-ideas.md)
if you finish early.

**Want the full walkthrough?** The complete, checkpoint-by-checkpoint guide is
in [docs/ATTENDEE_GUIDE.md](docs/ATTENDEE_GUIDE.md), and the slide deck is at
[docs/slides.html](docs/slides.html).

Two things to watch:

- **Save, then reload:** editing the file isn't enough on its own; run
  `./scripts/reload-skill.sh guided-skill` (then refresh the tab) so the agent
  sees changes.
- **Do not touch the `---` lines or the words before the colons:** only edit
  after `description:` and in the body.

## 🆘 If something looks stuck

Wave down a helper, or paste this into the terminal:

```
./scripts/start-gateway.sh
```

Then refresh the browser tab with your agent in it. To confirm everything is
green, run:

```
./scripts/healthcheck.sh
```

---

<div align="center">
  <img src="docs/openclaw-mark.svg" alt="OpenClaw" width="44" />
  <br />
  <sub>Built with <a href="https://openclaw.ai">OpenClaw</a> 🦞</sub>
</div>
