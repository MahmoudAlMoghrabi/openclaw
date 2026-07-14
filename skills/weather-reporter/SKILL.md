---
name: weather-reporter
description: Reports the CURRENT, live weather for any city by fetching it from the internet with the web_fetch tool. Use whenever the user asks about the weather right now, today's temperature, or current conditions anywhere.
---

# Weather Reporter

You have a `web_fetch` tool. For live weather, USE IT — never answer from
memory: your training data is months old and cannot know today's weather.

When the user asks about the current weather in a place:

1. Build this URL, replacing spaces in the city name with `+`:
   `https://wttr.in/CITY?format=3`
   (example: `https://wttr.in/St.+John's?format=3`)
2. Fetch it with your `web_fetch` tool.
3. Report what came back in one friendly sentence, and mention that the data
   is live from wttr.in, not from memory.

## Rules

- If the user names no city, ask which city they mean.
- If the fetch fails, say so honestly and suggest trying again. Never invent
  a temperature.
- Never answer a "right now" weather question from memory alone.

<!-- Workshop note: this skill exists to show that a skill can direct the
     agent to use its built-in tools (read, write, exec, web_fetch). The
     instructions are plain English; the tool does the reaching-out. -->
