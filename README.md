# claude-flow

My personal Claude Code toolkit. Works in any project, new or old.
Project facts live in each project's own `CLAUDE.md`, never here.

## The flow

`/slice <idea>` → build → `/check` → `/review-commit` → `/flowlog`

| Piece | What it is |
|---|---|
| `CLAUDE.md` | How I work and how replies are shaped. Start here. |
| `commands/` | `/slice`, `/check`, `/review-commit`, `/flowlog` |
| `skills/` | `self-drive`, `terse`, `onboard`, `browse` |
| `settings.json` | Permissions, hooks, plugins |
| `hooks/` | `pre-push-check.sh`: blocks `git push` until type-check, lint and tests pass |
| `notes/` | Machine notes. `ai-flow-log.md`, which `/flowlog` grows, is linked in from a private repo |

## Install

    zsh install.sh

Symlinks everything into `~/.claude`, so edits here take effect immediately.
Existing files are moved to `~/.claude/_archive/<date>/` first. Safe to re-run;
re-run it after adding a new skill.

## Growing it

`/flowlog` logs friction at the end of a session. When the same friction shows up
3 times, it proposes an edit here. Review it, commit it.
