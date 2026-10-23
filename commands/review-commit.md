# /review-commit

Review staged/unstaged changes, understand what was done, and create a concise commit message following the repository's style.

## Pre-computed Context

Run these commands to gather context before proceeding:

```bash
# Check current branch and repository state
git branch --show-current

# Show what's staged
git diff --cached --stat
git diff --cached

# Show what's unstaged (if anything)
git diff --stat
git diff

# Check recent commit style (last 10 commits)
git log --oneline -10

# Full status
git status
```

## Workflow

1. **Analyze Changes**:
   - Review the diff output to understand what was changed
   - Identify the scope: bug fix, feature, refactor, docs, etc.
   - Note any patterns or themes in the changes

2. **Check Commit Style**:
   - Look at recent commits (`git log --oneline -10`)
   - Match the existing style (conventional commits, prefixes, format)
   - Keep message brief but descriptive

3. **Stage Files** (if needed):
   - If changes are unstaged, stage them: `git add <files>`
   - Or stage all: `git add .`

4. **Write Commit Message**:
   - Follow the repository's commit style
   - Be concise - one line preferred, max two lines
   - Format: `type: brief description` (e.g., `feat: add user profile screen`)
   - Common types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

5. **Commit**:
   - Run: `git commit -m "message"`
   - Confirm success

## Guidelines

- **No AI attribution**: Never add "Generated with Claude" or co-author credits
- **Match existing style**: Always check `git log` first
- **Be concise**: Shorter is better, but must be clear
- **One logical change**: If changes are unrelated, ask if they should be separate commits

## Example Flow

```
Current branch: feature/user-profile
Staged changes: 
  src/screens/ProfileScreen.tsx | 45 +++
  src/components/Avatar.tsx     | 20 ++

Recent commits:
  feat: add settings screen
  fix: navigation type error
  refactor: extract button component

Commit message: "feat: add user profile screen"
```

## Notes

- This command assumes you're in a git repository
- If no changes are staged, will stage all changes (or ask which files)
- Always verify the commit message follows the project's style
