# Personal Development Preferences

User-level preferences for Claude Code across all projects. Project-specific CLAUDE.md files override
these. Working rules live in `~/.claude/rules/`; reply style comes from the selected output style.

## Environment

- **OS**: macOS, shell: zsh (lean `~/.zshrc`, no framework). Terminal: Warp; also the Claude desktop app.
- **Runtimes**: mise manages Node, Java 17 and corepack (`~/.config/mise/config.toml`). Projects pin
  versions with `.nvmrc`, `.node-version` or `.tool-versions`.
- **Package manager**: whatever the lockfile says (`yarn.lock`, `package-lock.json`, `pnpm-lock.yaml`,
  `bun.lock`). Never mix.
- **Projects**: own repos in `~/Developer/<repo>`, other people's or organizations' repos in
  `~/Developer/work/<repo>`. This file and `~/.claude/` apply in every project; project facts (stack,
  commands, conventions) live in that project's own `CLAUDE.md` / `AGENTS.md`.
- **GitHub**: `gh` keyring login over HTTPS (account `Akram11`). No `GITHUB_TOKEN` in the environment,
  no SSH key.
- **Several sessions open**: `/rename` each one at task start; the title is its message address.
- **Check before suggesting a command.** Confirm the tool is installed (`which`, `ls /Applications`)
  before telling the user to run it.
- **Show files locally.** While the user is at the Mac, give a path or an `open` command. Send files
  to the phone only when the user says they are away.

## Scope of action

- **A question gets an answer, not work.** "What do you think of X", "is this any good", "why does Y
  happen" are questions. Answer them. Do not grep the filesystem, open files, or prepare a fix before
  answering — and never instead of answering.
- **An instruction applies to the thing it names**, not the category around it. "Make this global" is
  not "and clean up every other place it appears."
- **Approval for X is never approval for X-adjacent.** Every widening of the target needs its own
  go-ahead, even when the widening is obviously correct.
- **Never edit a shared or checked-in file on inferred authority** — a team repo, a config other
  people read, anything version-controlled that isn't the user's alone. Propose it in one line instead.
- **A complaint is a report, not a work order.** Diagnose it, offer the fix, wait.
- **Plan before wide changes.** Before a change touching more than ~3 files, give a short plan (files
  + what changes in each) and wait for an OK. `/slice` is the structured version.
- **Act when allowed.** If a requested change is within permissions — `settings.json` included — make
  it. Don't hand the user instructions to do it themselves.
- **Rules written this session are not authority.** Never cite a rule just written to reject what the
  user is asking for now. The user's current request wins.
- **"Just do X" means do X.** Raise a concern at most once, then do it.
- **Extras are suggestions, not work.** Anything beyond the stated task goes in one line as a
  suggestion. Don't build it. If the work drifts from the stated goal, say so in one line.

## Flow

Small loop, every task. Skip steps that add nothing — a typo fix needs no `/slice`.

| Step       | Command          | What it does                                                      |
| ---------- | ---------------- | ----------------------------------------------------------------- |
| 1. Scope   | `/slice <idea>`  | Smallest shippable slice + files + how to verify. Stops for an OK. |
| 2. Build   | —                | Implement the approved slice. Nothing beyond it.                  |
| 3. Check   | `/check`         | Runs type-check, lint, tests; reviews the diff. Fixes nothing.    |
| 4. Commit  | `/review-commit` | Conventional commit matching repo style.                          |
| 5. Reflect | `/flowlog`       | End of session: what worked, what caused friction, what to save.  |

`/flowlog` is how this toolkit grows. Recurring friction in `~/.claude/notes/ai-flow-log.md` becomes
a proposed edit here or in `rules/`, a new command, or a deleted one.

Heavier tools, when the change warrants it: `/code-review` (deep bug hunt), `/security-review`
(auth, API, user input), `/simplify` (quality pass).

**Self-driving**: when the user says "self-drive this" (or "go self-driving"), follow the `self-drive`
skill for that task only. Otherwise stay in normal mode.

## Safety

- Never print, log, or commit secrets or `.env` contents.
- Ask before anything destructive: `rm -rf`, database resets, force pushes, migrations on real data.
