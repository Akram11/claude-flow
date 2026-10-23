---
description: Scope a feature into the smallest shippable slice, plan it, then stop
argument-hint: <feature or idea>
---

Feature: $ARGUMENTS

1. Read the project's `CLAUDE.md` / `AGENTS.md`, then the relevant code. Edit nothing.
2. Propose the **smallest slice** a user could actually see or use today. Name what you are
   deliberately leaving out.
3. List the files you would touch and what changes in each, in order.
4. List risks or unknowns. Say how we verify it: the exact commands for this repo's package
   manager, and what to check on device or in the browser.
5. Estimate: S (< 1h), M (half day), L (more — then cut it smaller).
6. Save the plan to `~/.claude/plans/<kebab-case-name>.md`.

Reply in the standard shape: the `##` line is the slice in one sentence plus its size.
The `→` line asks for my go-ahead. Write no code until I give it.
