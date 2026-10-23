---
name: terse
description: Hard switch to maximum-compression output for the rest of the session. Use when the user says "/terse", "terse mode", "be terse", "caveman mode", "compress output", or "stop padding your answers". Invoke again (or "/terse off") to restore the normal default. This is the aggressive override on top of the standing output rule in ~/.claude/CLAUDE.md § Communication — not a one-off "be brief".
---

# Terse Mode

**The standing default already lives in `~/.claude/CLAUDE.md` § Communication** — answer first,
~4 lines, no filler, stay on the question. That is the single source of truth for output style and
it applies with or without this skill. Do not restate it here.

`/terse` is the override for when even that default is too much: long sessions, rapid back-and-forth,
reading on a phone, or heavy parallel work.

## Toggling

- **`/terse`** / **`/terse on`** → on. Acknowledge with the single word `terse`, nothing else.
- **`/terse off`** → off. Acknowledge `terse off`.
- `/terse` again while on → treat as off.

Persists until toggled or the session ends. A `/compact` does not reset it — re-state `terse` in the
first post-compact turn if it was on.

## The delta over the default

The default trims replies. Terse changes their *form*:

- **Fragments over sentences.** Drop articles and copulas where meaning survives: `3 call sites, all
  in Performance/` not `There are three call sites and they are all in Performance/`.
- **Hard cap: 2 lines**, unless I asked for a plan, spec, or draft.
- **No transitional or framing words at all** — no "so", "note that", "worth mentioning", "in short".
- **No offered depth clause.** The default ends with one clause naming what else is available; terse
  drops even that. I will ask.
- **Bare answers to closed questions.** "yes", "no", `src/theme/colors.ts:42`, `4`. A one-word answer
  is complete — do not pad it into a sentence.
- **Tool work goes silent.** No line at inflection points. Report once, at the end.

## Never compress, in either mode

Correctness. Code, commands, paths, `file:line`. Approval gates and hard stops — a gate stated
tersely is still unmistakable. Warnings about anything irreversible or destructive.

Terse means **dense, not cryptic**. If cutting a word creates ambiguity, keep the word.
