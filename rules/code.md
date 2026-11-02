# Code, verification and commits

## Code style

- **TypeScript**: strict. No `any` without a comment explaining why. Prefer `interface` for
  extendable objects, `type` for unions/intersections. Use async/await over `.then()`.
- **React/RN**: functional components and hooks only. Destructure props in function parameters.
  Keep components small; extract logic into hooks.
- **Path aliases**: use the project's defined aliases (e.g. `@src/*`).
- **Comments**: never explain _what_ — clear naming does that. Keep comments that explain _why_.
- **Errors**: always handle them. Never silently fail.
- **Dependencies**: prefer existing deps and repo patterns. Ask before adding a dependency.
- **Stay in scope**: don't touch unrelated code, formatting, or lockfiles unless asked.

## Verification

- **Done means checked.** A task is done when it type-checks, lints, and the relevant tests pass —
  or the user has been told there are none. `/check` runs this.
- **Never claim something works without having run it.** Type checks verify _code correctness_, not
  _feature correctness_.
- **UI changes**: say exactly what to check on device or in the browser. Drive it yourself when a
  tool for it is available.
- **Parallel agents**: other sessions may share this machine. Before verifying on a dev server,
  simulator or test run, confirm it serves *this* checkout (cwd, branch, port owner). Never change
  global toolchains; if another session's setup breaks things, report and stop.
- **Check authorship before blaming.** Before attributing a commit, trailer or change to the user or
  another session, check `git log --format='%an %ae'`.
- **Pushes are gated**: a hook runs the project's type-check, lint and tests before `git push` and
  blocks the push on failure. Fix the failure; don't bypass the hook.
- **Polling**: if you are about to write `sleep N && <check>` more than once, switch to `/loop`
  (≥2m for CI/deploys).

## Commits & PRs

- **Never commit, push, or rewrite history unless asked.** `/review-commit` counts as asking.
- **No AI attribution** — never add "Generated with Claude" or co-author credits.

## Plans

- Save implementation plans to `~/.claude/plans/` — never inside repositories.
- Name them descriptive kebab-case (e.g. `auth-flow-refactor.md`). Never leave harness
  auto-generated names like `eventual-questing-zephyr.md`.
- A `/slice` plan is saved here too. Plans that are finished move to `~/.claude/plans/done/`.
