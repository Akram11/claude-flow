# Project kit — `/kickoff` for any project

Created: 2026-10-15. Toolkit repo: `~/Personal/claude-flow` (private `Akram11/claude-flow`).

## How to pick this up
Status: planned, nothing built yet.

```
cd ~/Personal/claude-flow
claude
```

First message:

```
/rename project-kit
Read docs/project-kit.md. Start with its "Decisions to make" section,
then /slice the first slice.
```

## Context
The core baseline (`CLAUDE.md` + `/slice` → `/check` → `/review-commit` → `/flowlog`) is
tool-agnostic. The kit adds the project layer: any project, new or old, client or personal, gets
the same foundation in minutes instead of being set up from scratch.

## Decisions to make at session start
- [ ] Tracker for personal projects / for client projects (GitHub Issues, Linear, markdown file…)
- [x] Design-system tool — repo tokens (`design/tokens.json`) as source of truth, Claude Design as the visual surface. See `skills/brand`.
- [ ] Where PRDs and plans live: in the project repo or in `~/.claude/plans`. For client repos this changes what the client can see.
- [ ] What client mode includes: time estimates, reply drafts, invoicing

## Approach
**`/kickoff`** (absorbs `/onboard`; safe to re-run):
1. Detect the stack, package manager and scripts.
2. Ask only what can't be detected: what the product is, who it's for, and which tools fill the slots.
3. Write the project `CLAUDE.md` from one template with fixed slots.
4. Draft `docs/PRD.md` and a scope list.

**Slots** (sections in the project `CLAUDE.md`):

| Slot | Example values | Used by |
|---|---|---|
| Commands | install, dev, typecheck, lint, test, build, deploy | `/check`, the pre-push hook |
| Verification | simulator, browser URL, production URL | `/check` proof of done |
| Design system | the tool and where its tokens live | `/slice`, UI work |
| Tracker | GitHub Issues, Linear, a markdown file | `/slice`, `/review-commit` |
| Mode | personal / client | client mode adds reply drafts and time estimates |

**Adapters**: one small skill per tool (`tracker-github`, `design-figma`, …). Each knows a few actions:
create a task, update its status, fetch a design. Flow commands say "the tracker"; the slot decides which adapter runs.

**Flow changes**:
- `/slice` reads the PRD, creates a tracker item, and checks the design.
- `/check` uses the project's own commands and its verification target.
- New `/ship`: push → PR → deploy → verify; in client mode it also drafts the reply and a time estimate.

## First slice
- `/kickoff` + the `CLAUDE.md` template + one tracker adapter, all in `~/Personal/claude-flow`.
- Fold `/onboard` into `/kickoff`.
- Leave out for now: `/ship`, design adapters, client mode.

## Verification
- Run `/kickoff` on an existing project. It should write a project `CLAUDE.md` with filled slots and ask only for what it couldn't detect.
- On the same project, run one real task through `/slice` → `/check` → `/review-commit` → `/flowlog`. This is also the pending test of the core baseline.
- Run `/kickoff` again. It should change nothing.
