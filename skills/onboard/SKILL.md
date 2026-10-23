---
name: onboard
description: Cookiecutter for new projects — analyzes the codebase, infers stack/tools/conventions, asks only what can't be detected, then generates a starter CLAUDE.md (and optional .claude/rules/) that declares only what differs from ~/.claude/CLAUDE.md. Trigger on "onboard this project", "let's onboard", "set up claude here", "configure this repo for claude", "this is a new project", or explicit /onboard. Skips if CLAUDE.md already exists (offers to enhance instead of overwrite).
---

# Project Onboarder (Cookiecutter)

You bootstrap a new project's Claude config from the universal layer in `~/.claude/CLAUDE.md`. The generated project files declare only what **differs** from the universal layer — never duplicate it.

## When this fires

- User says "onboard this project" / "let's onboard" / "set up claude here" / "configure this repo for claude" / "this is a new project"
- User invokes `/onboard` directly

## Step 0: Safety checks

```bash
# Must be in a coding project, not home dir or random folder
test -d .git || echo "Not a git repo — confirm with user before proceeding"

# Don't blow away existing config
test -f CLAUDE.md && echo "CLAUDE.md exists"
test -d .claude && echo ".claude/ exists"
```

If CLAUDE.md or `.claude/` already exist:
- Read them first to understand what's there.
- **Don't overwrite.** Offer 3 paths: *"Enhance the existing CLAUDE.md (suggest additions)"* / *"Replace it entirely (back up to `CLAUDE.md.bak`)"* / *"Cancel"*.
- Default to "Enhance" unless user picks otherwise.

## Step 1: Analyze the project (before asking anything)

Run these in parallel where possible. Don't ask the user a question until this analysis is done.

```bash
# Stack detection — what runtime?
ls package.json Cargo.toml Gemfile pyproject.toml requirements.txt go.mod composer.json mix.exs build.gradle 2>/dev/null

# Node/JS: stack hints from dependencies
test -f package.json && jq -r '.name, .description, (.dependencies // {} | keys | join(", ")), (.devDependencies // {} | keys | join(", "))' package.json

# Node: scripts (test/lint/build/dev/typecheck candidates)
test -f package.json && jq -r '.scripts // {} | to_entries[] | "\(.key): \(.value)"' package.json

# Node: package manager (lockfile)
ls yarn.lock package-lock.json pnpm-lock.yaml bun.lockb 2>/dev/null

# Rust
test -f Cargo.toml && head -20 Cargo.toml

# Python
test -f pyproject.toml && head -30 pyproject.toml
test -f requirements.txt && head -20 requirements.txt

# Git: remote, default branch, recent commit style
git remote -v 2>/dev/null
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null
git log --pretty=format:"%s" -10 2>/dev/null   # commit message convention

# Deploy hints
ls vercel.json netlify.toml Procfile fly.toml app.yaml 2>/dev/null
ls .github/workflows/ 2>/dev/null

# Tracker hints — grep recent commits / PR descriptions
git log --pretty=format:"%s%n%b" -20 2>/dev/null | grep -oE "(WEB-[0-9]+|APP-[0-9]+|[A-Z]+-[0-9]+)" | sort -u | head -5

# Existing AI config in this project
ls .claude/rules/ .claude/skills/ .claude/agents/ 2>/dev/null
test -f README.md && head -20 README.md
```

## Step 2: Synthesize a draft summary

Build a draft summary in plain language. Example:

> *I see this is a **Next.js + TypeScript** project named `<name>`, package manager **yarn** (yarn.lock). Test command: `yarn test` (Vitest based on package.json). Lint: `yarn lint:check`. Default branch looks like **main** (from `origin/HEAD`). Commit style is **conventional commits** (saw `feat:`, `fix:`, `chore:`). I see a `vercel.json` so deploy target is probably **Vercel**. I don't see any tracker references in recent commits.*

Show this summary to the user. Mark anything that's an assumption with **bold**: *"...probably **Vercel**"*.

## Step 3: Ask only what's missing or ambiguous

After the analysis, ask **at most 3 questions** — only for things genuinely missing:

- *What's this project? (1-line description — even if you saw a package.json name, ask if it's freelance/personal/team)*
- *Issue tracker — Linear, Jira, GitHub Issues, none?*
- *Deploy flow — auto on push to main? Manual? Other?*

If something is inferable with reasonable confidence, **don't ask** — state the assumption: *"I'll assume deploy is auto-on-push to `main` since I see `vercel.json` — correct?"*

## Step 4: Generate the files

### `<project>/CLAUDE.md`

```markdown
# <Project name>

<1-line description>

## Stack

- **Language**: <language>
- **Framework**: <framework>
- **Package manager**: <pm>
- **Test**: <test framework>
- **Build**: <build tool>

## Commands

| Action | Command |
|--------|---------|
| Install | `<install cmd>` |
| Dev | `<dev cmd>` |
| Build | `<build cmd>` |
| Test | `<test cmd>` |
| Lint | `<lint cmd>` |
| Type check | `<typecheck cmd>` |

## Branch convention

- **Base branch**: `<main/dev/master>`
- **Naming**: `<snake_case|kebab-case|other>` — example: `<example>`

## Issue tracker

<Linear/Jira/GitHub Issues/none>. <Magic words if relevant — e.g. "Fixes WEB-X in PR descriptions auto-closes the Linear issue">

## Deploy

<Target + flow>

## Project-specific notes

<Anything that should always apply when working in this repo — e.g. "always use yarn, never npm", "always run yarn lint:fix before commit", framework-specific gotchas if known>

## Assumptions to verify

<List any assumptions the onboarder made. User should review and correct.>

---

For universal principles (concise responses, no AI attribution, conventional commits, code style, the 7-stage workflow, etc.) see `~/.claude/CLAUDE.md`. **This file declares only what differs from the universal layer.**
```

### `<project>/.claude/rules/` (optional, only if needed)

Only create rule files if the project has stack-specific conventions that need to auto-load every session. Examples:
- `react.md` if there are non-default React patterns (functional only, specific hooks rules)
- `style.md` if there's a CSS-in-JS / Tailwind / styled-components convention
- `testing.md` if there's a specific test pattern

Skip if the universal layer + project CLAUDE.md cover it.

### `<project>/.claude/settings.local.json` (suggest only)

Suggest the user add this to their gitignored local settings, never write it directly without permission:
```json
{
  "permissions": {
    "allow": ["Bash(<test-cmd>:*)", "Bash(<lint-cmd>:*)"]
  }
}
```

## Step 5: Confirm and store

- Show the generated files to the user before writing (use diff-style preview if updating, full content if new).
- Write only on explicit approval.
- After writing: list what was created with paths.
- Note assumptions explicitly so user can correct in a follow-up edit.

## Step 6: Suggest next step

After onboarding completes:
- *"Project configured. You can now run `/slice <idea>` to start a task — `/slice` and `/check` read their commands from this CLAUDE.md."*

## When you don't know

- **Stack ambiguous** (multiple lockfiles, monorepo, vendored deps) → ask user.
- **No git history** → assume `main` as base branch, ask user.
- **No tracker visible** → ask user, default to "none".
- **Unknown framework** → still onboard with what's detectable; leave Stack section with `<TODO>` for user.

## Safety always

- **Never** overwrite existing CLAUDE.md or `.claude/` files without explicit confirmation.
- **Never** commit the generated files — leave that to the user (they may want to review or amend first).
- **Never** modify `.gitignore` — suggest additions but let user do it.
