---
name: browse
description: Browser operator for any task requiring a browser — manual testing, UI verification, debugging, visual comparison. Uses playwright-cli (persistent Chromium daemon, ~100ms/cmd, no MCP overhead). Invoke whenever you need to open a browser, interact with the app, take screenshots, or verify UI. A project-level browse skill (if present) overrides this with project-specific auth and selector guidance.
---

# Browser Operator (personal baseline)

You are operating a browser via `playwright-cli` — a persistent Chromium daemon installed globally. Every browser task goes through this skill: manual testing, UI verification, visual comparison with designs, debugging network calls, anything that requires a browser.

If the current project has its own `/browse` skill (`.claude/skills/browse/SKILL.md`), that one takes precedence — it'll include project-specific auth flows and selector conventions.

## Command Reference

### Navigation
```bash
playwright-cli open [url]       # open browser (first call starts daemon, ~3s)
playwright-cli goto <url>       # navigate to URL
playwright-cli go-back          # go back
playwright-cli reload           # reload page
playwright-cli tab-list         # list open tabs
playwright-cli tab-new [url]    # open new tab
playwright-cli tab-select <idx> # switch tab
```

### Find Elements — Always Snapshot First
```bash
playwright-cli snapshot         # accessibility tree with eN refs — use this to find elements
```

Output looks like:
```yaml
- textbox "Email" [ref=e28]
- textbox "Password" [ref=e31]
- button "Log in" [ref=e38]
```

Use `eN` refs in all subsequent commands. Never guess refs — always snapshot first.

### Interact
```bash
playwright-cli click <ref>              # click element (click e38)
playwright-cli fill <ref> <text>        # fill input (fill e28 "user@example.com")
playwright-cli select <ref> <value>     # select dropdown option
playwright-cli type <text>              # type into focused element
playwright-cli press <key>              # press key (press Enter, press Tab, press Escape)
playwright-cli hover <ref>              # hover over element
playwright-cli check <ref>              # check checkbox/radio
playwright-cli uncheck <ref>            # uncheck
playwright-cli drag <ref1> <ref2>       # drag and drop
playwright-cli upload <file>            # upload file
playwright-cli dialog-accept [prompt]   # accept browser dialog
playwright-cli dialog-dismiss           # dismiss browser dialog
playwright-cli dblclick <ref>           # double click
```

### Inspect
```bash
playwright-cli eval <js>         # run JS — computed styles, DOM state, fetch()
playwright-cli network           # all network requests since page load
playwright-cli console           # console messages (errors, warnings, logs)
playwright-cli cookie-list       # list cookies
playwright-cli localstorage-list # list localStorage
```

### Network Mocking
```bash
playwright-cli route <pattern>              # mock requests matching pattern
playwright-cli route-list                   # list active mocks
playwright-cli unroute [pattern]            # remove mocks (or all if no pattern)
```

Options for `route`: `--status`, `--body`, `--content-type`, `--header`, `--remove-header`

Example:
```bash
playwright-cli route "**/api/users*" --body '[{"id":1,"name":"Mock User"}]' --content-type "application/json"
```

### Screenshot & Visual
```bash
playwright-cli screenshot               # capture viewport → .playwright-cli/ (gitignored)
playwright-cli screenshot <ref>         # capture specific element
playwright-cli resize <w> <h>           # set viewport (resize 1440 900)
playwright-cli pdf                      # save page as PDF
```

**Important:** `screenshot <path>` treats the argument as a CSS selector, not a file path. Use bare `screenshot` to save to `.playwright-cli/`.

### Session & Auth
```bash
playwright-cli state-save <file>  # save cookies + localStorage to file
playwright-cli state-load <file>  # restore saved auth state (skip re-login)
playwright-cli close              # close session cleanly
playwright-cli kill-all           # force-kill all sessions (for zombies)
playwright-cli list               # list active sessions
playwright-cli delete-data        # clear all session data
```

## Auth (generic)

Most projects gate test pages behind a login. The cleanest pattern:

1. **Find a per-project credentials source.** Common spots: `.env.local`, `.test.env`, `.manual-test.env`. Ask the user if you can't find one.
2. **Log in once, save state, reload later.** Avoids re-authenticating on every navigation step:
   ```bash
   # after login UI flow:
   playwright-cli state-save .playwright-cli/auth.json
   # later, in a new session:
   playwright-cli state-load .playwright-cli/auth.json
   playwright-cli goto http://localhost:3000/whatever
   ```
3. **Role-aware navigation.** If the app has roles, the wrong account → redirect or 404. Confirm which role you need before logging in.

## Environment

- Always test against `http://localhost:<port>` — never dev/prod
- Don't start, restart, or kill dev servers unless the user explicitly asks — user manages them
- Before testing in a worktree: tell user the worktree path, ask which port the dev server is on
- Prefer real API data over mocks — mocks add fragility and are lost on reload

## Selectors

1. **Use `snapshot` refs (`eN`)** — primary targeting, always works
2. **`data-testid`** — if an element needs a stable identity, add it to the component source first
3. **Never use translation text** — breaks in other locales
4. **Never use hashed class names** — CSS module hashes change between builds
5. **Stable library classes** are acceptable (e.g. Ant Design's `.ant-table-row`, MUI's `.MuiButton-root`) — only when no better selector exists

## Verification

- **Take a screenshot** after every meaningful interaction — analyse it visually before declaring pass
- **Compare with the design source** (Figma, mockup) side-by-side for any UI verification task
- **Present screenshot + design to user**, wait for "looks good" before committing
- Use `eval` to inspect computed styles, widths, DOM state when something looks wrong
- Use `network` to verify API calls fired and returned expected data
- Never declare "passed" without verifying data actually renders
- Investigate root cause when something looks wrong — don't work around it

## Browser Management

- First command auto-starts daemon + Chromium (~3s cold start)
- Subsequent commands: ~100ms (browser stays warm)
- `close` — clean reset (preferred)
- `kill-all` — force-kill if browser becomes unresponsive; next command auto-restarts
- Sessions are isolated with `-s=<name>` flag when parallel testing needed
- Screenshots save to `.playwright-cli/` (gitignored — add to project `.gitignore` if not already)

## Cleanup

- Keep screenshot files until user explicitly confirms done
- After confirmation: `rm .playwright-cli/*.png .playwright-cli/*.yml`
- Remove any test data created via UI forms
- Reset viewport after responsive testing: `playwright-cli resize 1280 720`

## Pitfalls
<!-- Append new entries as they are discovered. Project-specific learnings go in the project-level browse skill, not here. -->

| # | Type | Learning |
|---|------|----------|
| 1 | pitfall | `screenshot <path>` treats the argument as a CSS selector — use bare `screenshot` |
| 2 | pitfall | Never assume empty data is "expected" — check `network` output to verify the API returned something |
| 3 | pattern | `state-save` after login → `state-load` in subsequent steps to skip re-login |
| 4 | preference | Combine related checks into one session — one test per CRUD flow, not one test per field |
| 5 | preference | Screenshot + design-source comparison before committing any UI change |
| 6 | pitfall | For network mocking, use `playwright-cli route "<pattern>" --body '<json>' --content-type "application/json"`. Never spin up a standalone `node` script with `require('playwright')` — `playwright-cli route` does this natively within the persistent daemon. Use `route-list` to check active mocks and `unroute` to remove them. |
| 7 | pitfall | Links with `target="_blank"` open in a new tab — `snapshot` still shows the original tab. Use `tab-list` to see the new tab, then `tab-select <idx>` to switch before taking snapshots. |
