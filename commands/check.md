---
description: Self-review the current uncommitted changes before I commit
---

Review the current uncommitted changes: `git status`, `git diff`, `git diff --cached`, and any
untracked files.

1. **Run the checks.** Find the commands in this order: the project's `CLAUDE.md` / `AGENTS.md`,
   then `package.json` scripts (type-check, lint, test). Use the lockfile's package manager.
   If a check has no command, say `none` for it — do not invent one.
2. **Review the diff** for: bugs and edge cases, leftover debug code / `console.log`, `any`
   without a why-comment, unhandled promises or errors, secrets, unrelated changes that crept
   in, and missing loading / error states in UI.
3. **Reply in the standard shape.** The `##` line is the verdict: `clean`, or `N blockers`.
   Then:
   - **Checks**: one line each, pass / fail / none.
   - **Blockers**: must fix, with `file:line`.
   - **Worth fixing**: short list.
   - **UI to check by hand**: what to look at on device or in the browser, if UI changed.
   - **Proof of done**: a table — item | verified where (test, browser, device, prod URL) |
     evidence. End with a line naming anything **not** verified. Never leave that line out.

Fix nothing — I pick what to fix. If the diff is large or risky, suggest `/code-review` in one
line. When it is clean, the `→` line offers `/review-commit`.
