# claude-flow

My personal Claude Code toolkit. Works in any project, new or old.
Project facts live in each project's own `CLAUDE.md`, never here.

## The flow

`/slice <idea>` → build → `/check` → `/review-commit` → `/flowlog`

| Piece | What it is |
|---|---|
| `CLAUDE.md` | Environment, scope of action, the flow, safety. Start here. |
| `rules/` | `working.md` (habits that each cost real work once), `code.md` (style, verification, commits, plans) |
| `commands/` | `/slice`, `/check`, `/review-commit`, `/flowlog` |
| `skills/` | `self-drive`, `terse`, `onboard`, `browse`, `brand`, `react-native` |
| `settings.json` | Auto mode, permissions, auto-mode environment, hooks |
| `hooks/` | `pre-push-check.sh`: blocks `git push` until type-check, lint and tests pass |
| `docs/` | Not installed. `project-kit.md` (next step), `mcp-setup.md` |

Reply style comes from the Concise output style, set in `settings.json`.
The flow log (`notes/ai-flow-log.md`, grown by `/flowlog`) is linked in from the private
`claude-notes` repo.

## Install

    zsh install.sh

Symlinks everything into `~/.claude`, so edits here take effect immediately.
Existing files are moved to `~/.claude/_archive/<date>/` first. Safe to re-run;
re-run it after adding a new skill or rule. MCP servers are set up separately: see
`docs/mcp-setup.md`.

## Growing it

`/flowlog` logs friction at the end of a session. When the same friction shows up
3 times, it proposes an edit here. Review it, commit it.
