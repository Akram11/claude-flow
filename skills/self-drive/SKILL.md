---
name: self-drive
description: Per-task autonomous mode. Triggers on "self-drive this", "go self-driving", "self-drive X", or explicit /self-drive. Commits Claude to the self-driving behavior rules from ~/.claude/CLAUDE.md (no check-ins, batch calls, only pause for genuinely risky ops) AND registers an end-of-task PushNotification so the user knows when to come back. Reminds the user to Shift+Tab into acceptEdits/auto mode if they haven't — that's the one piece a skill can't automate.
---

# Self-driving mode (per-task)

The user wants this task run autonomously — they walk away, you finish, you ping them. This is **scoped to the current task**, not the whole session.

## Step 1: Confirm what the task is

If the user said "self-drive this" with a clear referent in the preceding messages, restate the task in one sentence to lock scope:

> "Self-driving this: <one-sentence restatement of the task>. Will ping you when done."

If the trigger came with no task ("go self-driving" with no preceding context), ask once — autonomous mode without a defined goal will drift. Don't proceed until the task is named.

## Step 2: Permission-mode handoff

A skill can't flip permission mode. Tell the user in one line:

> "If you haven't already, Shift+Tab to `acceptEdits` (auto-approves edits, still asks for risky bash) or `auto` (smart classifier). Otherwise every Edit/Bash will still prompt and self-driving is moot."

Do NOT block waiting for confirmation — assume the user will handle it. Proceed with the work.

## Step 3: Behavior rules for the rest of this task

Follow the **Self-driving mode** section of `~/.claude/CLAUDE.md` verbatim. Specifically:

- **Skip optional check-ins.** No "should I proceed?" between approved steps. No clarifying questions unless genuinely blocked (ambiguous goal, missing critical info, conflicting instructions).
- **Batch tool calls aggressively.** All independent calls in a single message.
- **Only pause for risky/destructive ops** that hit the `ask` list OR aren't covered by the user's permission mode:
  - force-push, `rm -rf`, branch delete, `git reset --hard`
  - publishing externally (PR create/edit/comment, issue-tracker or chat posts)
  - npm/yarn install of new deps
  - anything touching prod, secrets, or shared infra
- **Communicate sparingly** — one short line at meaningful inflection points (plan ready, build passed, PR opened). No running commentary, no "let me think about this" prose.
- **Report once at the end**, not after each step.

## Step 4: Register the end-of-task ping

When the task is genuinely done (all exit gates met for whichever stages applied), send a `PushNotification` so the user gets pinged on phone.

The PushNotification tool is deferred — load its schema first:

```
ToolSearch with query "select:PushNotification"
```

Then call it with a concise message:

> "Self-drive task done: <one-sentence summary>. <one-line status: PR opened / tests pass / blocked on X>."

If `PushNotification` isn't available in this environment, fall back to a clearly-flagged final message in the chat:

> "🔔 SELF-DRIVE TASK COMPLETE — <summary>"

(This is the one place emoji is warranted: it's the visual ping the user is waiting for.)

## Step 5: Exit conditions

Self-driving exits when ANY of these hold:
- Task is unambiguously complete and the end-of-task ping has been sent
- User says "I'll drive", "stop", "pause", or otherwise takes over
- You hit a genuine blocker that requires a decision the user has to make (ambiguous requirement, conflicting signals, missing access)

When you exit due to a blocker, **send the ping immediately** with the specific question — don't silently wait. The whole point of self-driving is that the user isn't watching; if you need them, you have to actively pull them back.

## What this skill is NOT

- Not a permission-bypass. The user still has to Shift+Tab.
- Not a license to skip `/check` before declaring done — autonomous still means *complete*, not *fast and sloppy*.
- Not for tasks where you don't already understand the scope. If you'd normally ask 2+ clarifying questions, ask them up front (Step 1) instead of guessing autonomously.
- Not for risky/exploratory tasks. If the user says "self-drive" on a refactor you haven't planned yet, push back — "this needs a plan first; want me to plan, get your sign-off, then self-drive the implementation?"
