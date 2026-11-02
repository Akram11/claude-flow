# Working rules

Each rule exists because skipping it once cost real work.

- **Verify what a signal measured.** A pass/fail result counts only after confirming the commit,
  branch and working tree it ran against. A killed or partial run is unrun, not passing. After a
  commit, read the diffstat (`git show --stat --format="" HEAD`), not the success line. Ask: would a
  green look any different if the thing were still broken?
- **Never name an identifier you have not read.** Config keys, flags, env vars, symbols, files:
  quote the line that shows it, or mark the name as inferred.
- **Confirm before killing processes.** Show the exact targets (PID, what it is, why it looks stale)
  and wait for an explicit yes, in self-driving mode too. Same for `tmux kill-server` and
  `git branch -D`.
- **Never delete an existing user-facing feature without an explicit instruction naming it.**
  "Replaced by X" is not authorisation. If the replacement is behind a flag, retiring the old surface
  waits for the same flag. Ask: if this merges with the flag off, what does a user see?
- **Amend fix-ups on your own feature branch.** Tweaks to the same logical change →
  `git commit --amend`, then `git push --force-with-lease`. A new commit only for a distinct change.
  Never amend after a failed pre-commit hook (it would rewrite the previous commit), after the commit
  was reviewed, or on `main` / shared branches.
- **Reuse before building.** Search for existing components, hooks and helpers first (try synonyms,
  read the API). Extend a close match instead of forking it. Ask before creating a new shared
  primitive; put new general helpers in the shared utils file, not inline.
- **Branch from a freshly fetched `origin/main`**, never a local `main` or whatever is checked out.
  After pulling in remote changes, re-sync dependencies.
- **Reproduce a UI bug on screen before choosing a component.** Components can share names; grep for
  text visible in the screenshot and narrow by route.
