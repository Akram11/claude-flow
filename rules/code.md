# Code, verification and commits

## Code style

- **TypeScript**: strict. No `any` without a comment explaining why.
- **Path aliases**: use the project's defined aliases (e.g. `@src/*`).
- **Comments**: only the _why_, never the _what_.
- **Dependencies**: prefer existing deps and repo patterns. Ask before adding a dependency.
- **Stay in scope**: don't touch unrelated code, formatting, or lockfiles unless asked.

## Verification

- **Done means checked.** A task is done when it type-checks, lints, and the relevant tests pass —
  or the user has been told there are none.
- **Never claim something works without having run it.** Type checks verify _code correctness_, not
  _feature correctness_.
- **UI changes**: drive it yourself when a tool for it is available; otherwise say exactly what to
  check on device or in the browser.
- **Parallel agents**: other sessions may share this machine. Before verifying on a dev server,
  simulator or test run, confirm it serves *this* checkout (cwd, branch, port owner). Never change
  global toolchains; if another session's setup breaks things, report and stop.
- **Check authorship before blaming**: `git log --format='%an %ae'`.
- **Pushes are gated** by a hook (type-check, lint, tests). Fix the failure; don't bypass the hook.

## Commits & PRs

- **Never commit, push, or rewrite history unless asked.** `/review-commit` counts as asking.
- **No AI attribution** — never add "Generated with Claude" or co-author credits.

## Plans

- Save implementation plans to `~/.claude/plans/` — never inside repositories — with descriptive
  kebab-case names (e.g. `auth-flow-refactor.md`). Finished plans move to `~/.claude/plans/done/`.
