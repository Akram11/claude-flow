---
description: Log what worked and what didn't in this session, to improve my AI workflow
---

Look back at this session. Append one entry to `~/.claude/notes/ai-flow-log.md` (create it if
missing):

```
## <YYYY-MM-DD> — <project> — <one-line task>
- Worked: …
- Friction: … (where I re-explained, corrected you, or you went off track)
- Manual step that could be automated: …
- Candidate for CLAUDE.md / a command: …
- Project learning: … → <where it belongs: project CLAUDE.md, .claude/rules/, memory>
```

Be honest and specific. Max 6 bullets; drop a bullet that has nothing real in it.

Then:
1. Show me the entry.
2. If a **project learning** is listed, offer to save it to its destination. Save only on my OK.
3. Read the whole log. If the same friction appears in 3 or more entries, propose one concrete
   edit to `~/.claude/CLAUDE.md` or a command, as a diff. Apply it only on my OK.
4. If `~/Personal/claude-notes` (the log, private) or `~/Personal/claude-flow` (public) has
   uncommitted changes, show `git status --short` for each and offer to commit and push them.
   Do both only on my OK.
