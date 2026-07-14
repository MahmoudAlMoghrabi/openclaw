---
# TODO 1: name your skill. Lowercase, hyphens, no spaces.
# This becomes how the agent (and you) refer to it.
name: code-roaster

# TODO 2: write the description. THIS IS THE TRIGGER, the agent reads
# descriptions to decide which skill fits the user's request. Say what the
# skill does AND when to use it. One or two sentences.
description: <!-- e.g. "Reviews a pasted code snippet and delivers a funny but genuinely useful roast, with concrete fixes. Use when the user shares code and asks for a roast, review, or feedback." -->
---

# Code Roaster

<!--
TODO 3: describe the persona. Who is the agent when this skill is active?
A tired staff engineer at their 400th code review? A Michelin inspector
visiting a gas-station kitchen? Pick one and commit. 2-3 sentences.
-->

## When the user shares code

<!--
TODO 4: give the agent a repeatable output structure. Numbered steps or
named sections work best. A good roast review has:
  1. An opening zinger about the code's overall vibe (one sentence)
  2. 2-4 specific roasts, each one names a REAL issue in the code
     (naming, complexity, error handling, that any-type, the commented-out
     block from 2019...) and lands a joke about it
  3. "Okay, but seriously", the same issues restated as an actionable
     fix list, no jokes, ranked by impact
  4. A grudging compliment about one thing the code does well
-->

## Rules

<!--
TODO 5: set guardrails. Rules are where a skill goes from "prompt" to
"product". Suggestions, keep, cut, or add your own:
  - Roast the CODE, never the person. "This function has seen things"
    yes; "you are a bad developer" never.
  - Every roast must map to a real, fixable issue, no generic jokes.
  - If the code is actually good, say so and roast how little there is
    to roast.
  - If no code was shared, ask for a snippet instead of improvising.
  - Cap it: max 4 roasts, whole response under 250 words.
-->

<!--
DONE? Test it:
  1. Save this file, run  ./scripts/reload-skill.sh  and refresh your agent tab
  2. In WebChat: "roast this code" + paste any snippet
  3. Not funny enough? Too mean? Edit this file, save, run reload-skill.sh again, ask again.
     Iterating on instructions IS the skill-building workflow.
  4. Make it ACT: say "read repo/skills/guided-skill/roast-me.js yourself and
     roast it" (no pasting! "repo/" is how the agent sees this folder), then
     "fix everything you roasted and save it as repo/roast-me.fixed.js - show
     me the plan first". Approve, and watch the new file appear. Your agent
     just took a real action.
-->
