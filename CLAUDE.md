# Personal Development Preferences

User-level preferences for Claude Code across all projects. Project-specific CLAUDE.md files override
these. Working rules live in `~/.claude/rules/`; reply style comes from the selected output style.

## Environment

- **OS**: macOS, shell: zsh (lean `~/.zshrc`, no framework). Mostly works in the Claude desktop app; Warp for a terminal.
- **Runtimes**: mise manages Node, Java 17 and corepack (`~/.config/mise/config.toml`). Projects pin
  versions with `.nvmrc`, `.node-version` or `.tool-versions`.
- **Package manager**: whatever the lockfile says (`yarn.lock`, `package-lock.json`, `pnpm-lock.yaml`,
  `bun.lock`). Never mix.
- **Projects**: own repos in `~/Developer/<repo>`, other people's or organizations' repos in
  `~/Developer/work/<repo>`. Project facts (stack, commands, conventions) live in that project's own
  `CLAUDE.md` / `AGENTS.md`.
- **GitHub**: `gh` keyring login over HTTPS (account `Akram11`). No `GITHUB_TOKEN`, no SSH key.
- **Check before suggesting a command.** Confirm the tool is installed before telling the user to run it.
- **Show files locally.** While the user is at the Mac, give a path or an `open` command. Send files
  to the phone only when the user says they are away.

## Scope of action

- **A question or complaint gets an answer, not work.** Answer "what do you think", "why does Y
  happen" directly; diagnose a complaint and offer the fix, then wait.
- **Do exactly what was named.** An instruction or approval covers the thing it names, not the
  category around it. Anything wider or extra goes in one line as a suggestion.
- **Never edit a shared or checked-in file on inferred authority** (a team repo, a config others
  read). Propose it in one line instead.
- **Plan before wide changes.** Before touching more than ~3 files, list the files and what changes
  in each, and wait for an OK.
- **Act when allowed.** If a requested change is within permissions — `settings.json` included — make
  it. Don't hand the user instructions to do it themselves.
- **"Just do X" means do X.** Raise a concern at most once, then do it. The user's current request
  beats any rule written earlier in the session.

## Commands

`/slice`, `/check`, `/review-commit` and `/flowlog` exist; use them when the user asks. The flow is
still being worked out, so don't push it.

## Safety

- Never print, log, or commit secrets or `.env` contents.
- Ask before anything destructive: `rm -rf`, database resets, force pushes, migrations on real data.
