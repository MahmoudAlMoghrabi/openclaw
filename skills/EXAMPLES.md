# Skill ideas, a menu to pick from

Pick one, and make it your skill. **How to use any of these:**

1. Open `skills/my-first-skill/SKILL.md` and replace everything with the block.
2. Save (Ctrl+S).
3. In the terminal, run `./scripts/reload-skill.sh`.
4. Refresh your agent's browser tab.
5. In the chat, type **"use the my-first-skill skill on: ..."**

Want more than one at a time? Make a new folder `skills/<your-name>/SKILL.md`,
set `name:` to match, then run `./scripts/reload-skill.sh <your-name>`.

Tip: one clear instruction beats five fuzzy ones. Keep it short.

---

## 😂 Funny ones (great for the room)

**Excuse generator**
```
---
name: my-first-skill
description: Invents a ridiculous excuse for anything
---

When I tell you what I need to get out of, invent one funny, over-the-top excuse in a single sentence.
```
Try: *use the my-first-skill skill on: skipping the gym today*

**Pirate rewriter**
```
---
name: my-first-skill
description: Rewrites my text as a dramatic pirate
---

When I paste text, rewrite it in the voice of a dramatic pirate. Keep the meaning the same.
```
Try: *use the my-first-skill skill on: the meeting is moved to 3pm tomorrow*

**Gen-Z translator**
```
---
name: my-first-skill
description: Rewrites my text in Gen-Z slang
---

When I paste text, rewrite it in exaggerated Gen-Z internet slang. Keep it readable.
```
Try: *use the my-first-skill skill on: I am very tired and need a coffee*

**Corporate jargon translator**
```
---
name: my-first-skill
description: Turns plain talk into buzzword-filled corporate speak
---

When I paste a plain sentence, rewrite it packed with corporate buzzwords, then add the honest one-line translation underneath.
```
Try: *use the my-first-skill skill on: we are behind and need more time*

**Emoji-only translator**
```
---
name: my-first-skill
description: Retells a sentence using only emojis
---

When I paste a sentence, reply with only emojis that tell the same story. No words.
```
Try: *use the my-first-skill skill on: I woke up late, missed the bus, but still got coffee*

**Pep talk**
```
---
name: my-first-skill
description: Gives a punchy pep talk for whatever I am facing
---

When I tell you what I am struggling with, reply with one short, energetic pep talk (2 sentences max) and a fitting emoji.
```
Try: *use the my-first-skill skill on: I have to present to the whole company*

---

## 🧠 Useful ones

**Grammar fixer**
```
---
name: my-first-skill
description: Fixes spelling and grammar without changing my wording
---

When I paste text, fix the spelling and grammar. Keep my wording and tone, and show only the fixed version.
```
Try: *use the my-first-skill skill on: their going too the store tommorow*

**Explain simply (ELI5)**
```
---
name: my-first-skill
description: Explains tricky topics in super simple words
---

When I ask about a topic, explain it like I am 5 years old, in 3 short sentences, with one everyday example.
```
Try: *use the my-first-skill skill on: what is an API?*

**Tweet writer**
```
---
name: my-first-skill
description: Turns any text into a punchy tweet
---

Turn what I paste into a punchy tweet under 200 characters, with one or two relevant hashtags.
```
Try: *use the my-first-skill skill on: we just launched our new app after months of work*

**Pros and cons**
```
---
name: my-first-skill
description: Weighs a decision as pros and cons
---

When I describe a decision, list 3 pros and 3 cons as short bullets, then give a one-line recommendation.
```
Try: *use the my-first-skill skill on: should I bike or drive to work?*

**Recipe from ingredients**
```
---
name: my-first-skill
description: Suggests a simple recipe from ingredients I have
---

When I list ingredients, suggest one simple recipe using mostly those, with quick steps. Keep it under 8 steps.
```
Try: *use the my-first-skill skill on: eggs, spinach, cheese, bread*

**Quiz maker**
```
---
name: my-first-skill
description: Makes a quick quiz on any topic
---

When I give a topic, write 3 multiple-choice questions (A-C), then list the answers at the bottom.
```
Try: *use the my-first-skill skill on: the solar system*

---

## 🎤 Facilitator demo only (needs a stronger model)

These use tools/produce visuals and are hit-or-miss on the cheap `flash-lite`
model. Demo them from your screen on a stronger model:

```
OPENCLAW_MODEL="google/gemini-3.5-flash" node scripts/patch-config.js
bash scripts/start-gateway.sh
```
(then reload the tab; switch back with `node scripts/patch-config.js && bash scripts/start-gateway.sh`)

- **meme-maker** (bundled, "ready"), *"use the meme-maker skill: a developer at 3am when the bug fixes itself"*
- **diagram-maker** (bundled, "ready"), *"use the diagram-maker skill to draw: user signs up, gets email, clicks link, account active"*

Test these before the day, if they don't produce output even on the strong
model, skip them and lean on the "let the agent build a skill" step for the wow.
