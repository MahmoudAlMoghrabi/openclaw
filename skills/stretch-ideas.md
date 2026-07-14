# Stretch skills, finished `code-roaster` early?

Pick one, create a new folder in `~/.openclaw/workspace/skills/<name>/SKILL.md`,
and build it the same way: frontmatter → persona → output structure → rules →
test in WebChat → iterate. Specs below are deliberately loose, the design
decisions are the exercise.

## 1. `standup-summarizer`

**Spec:** You paste a messy braindump of what you did yesterday (bullet
fragments, half sentences, commit-message shrapnel) and it returns a crisp
three-line standup update: *yesterday / today / blockers*.

**Hint:** The hard part is the rules. What should it do with items it can't
classify? (Suggest: an explicit "you mentioned this, where does it go?"
question rather than silent guessing.) Cap the output length, standups that
scroll are lies.

## 2. `commit-critic`

**Spec:** Paste a `git diff` (or just describe a change) and it proposes a
conventional-commit message, type, scope, imperative subject ≤ 50 chars,
body explaining *why* not *what*, then critiques the message *you* were
going to use, if you offer one.

**Hint:** Give it the conventional-commit types in the skill body
(`feat`, `fix`, `refactor`, `chore`, ...) with one-line definitions.
Models know these, but pinning them in the skill makes output consistent,
that's a core lesson about skills.

## 3. `shell-explainer`

**Spec:** Paste any scary shell one-liner and it explains what the command
does piece by piece, flags whether it's destructive, and rates it:
🟢 safe / 🟡 changes things / 🔴 do not run this from Reddit.

**Hint:** The interesting rule: *it explains, it never executes.* Write
that into the skill explicitly and then try to talk your agent into running
one anyway, a perfect segue into this afternoon's safety recap.

## 4. `changelog-poet`

**Spec:** Feed it a list of merged PR titles or commit subjects and it
writes user-facing release notes: grouped (Features / Fixes / Internal),
de-jargoned, with one optional tasteful pun per release, never two.

**Hint:** "Never two" is the fun constraint, models *love* puns. Watch how
firmly you have to phrase a rule before the model reliably obeys it. That
tension is real-world prompt engineering in miniature.

---

**Show-off tip:** the demo segment is coming. A skill with a strong
personality and a strict output format demos far better than a clever-but-
formless one.
