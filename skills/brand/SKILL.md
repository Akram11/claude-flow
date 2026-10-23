---
name: brand
description: Design pipeline for any project — asks the brief questions, shows 2–3 visual directions in Claude Design, locks the chosen one into repo design tokens, generates the platform theme (React Native, web CSS, docs/slides) and writes DESIGN.md so every later session stays on-system. Trigger on "/brand", "set up a design system", "visual identity", "brand this project", "we need a design system". Not for one-off UI tweaks — those follow the existing DESIGN.md.
---

# Brand — design pipeline

Goal: a consistent, original design system without a designer. AI slop comes from decisions
nobody made — defaults fill the gap (Inter, purple gradients, rounded cards, emoji icons). This
skill forces the decisions first, lets the user choose between real options, then locks the
choice where code reads it.

**The source of truth is `design/tokens.json` in the repo.** Visual tools show and change it;
they never own it.

## Step 0: Read before asking

- Project `CLAUDE.md` / `AGENTS.md`, `package.json`, existing theme files, a few screens or pages.
- If `design/tokens.json` exists, this is a re-run: ask what should change, edit tokens, regenerate.
  Never start over silently.
- Detect the target: React Native/Expo → mobile; Next/Vite/Astro → web; both → both;
  no app code → docs/slides.
- Note hard-coded colours, sizes, radii and fonts already in use — they show the implicit system.

## Step 1: The brief — ask, don't guess

Use AskUserQuestion, at most 2 rounds. Offer concrete options with a recommended default.

1. **Target** — confirm what was detected (mobile / web / both / docs-slides).
2. **Feel** — 3 words it should feel like. Offer sets drawn from the product.
3. **Must not feel** — 3 words. This is the anti-slop lever; push for specifics.
4. **Content** — does the product show varying content (images, scenes, user media)? If yes,
   the UI is a **neutral frame** and colour comes from the content (see Principles).
5. **Type** — system fonts (no dependency) or a custom family (adds a font dependency — ask).
6. **Level** — basic (tokens + rules) or complete (adds logo, icons, image style).

Also ask for 3–10 references the user likes (links or screenshots), if they have them.
Write the answers to `design/brief.md`: one page, no padding.

## Step 2: Directions — 2 or 3, clearly different

Make them in Claude Design (Artifact tool: `action: "quickstart"`, `intent: "design"`). Each
direction is one board:

- Palette: neutrals, text, one accent, status colours — with contrast ratios for text pairs.
- Type: the scale (display, title, body, caption) with real product copy, not lorem ipsum.
- Shape: radius, spacing rhythm, elevation or none.
- One real screen of the product, using its real content.
- One line: what this direction is *for* and what it gives up.

Directions must differ in a decision, not a shade: e.g. warm vs cool neutrals, soft vs sharp
shape, quiet vs expressive type. Then ask the user to pick or mix ("A's colour, B's type").

## Step 3: Lock the tokens

Write `design/tokens.json` in the W3C Design Tokens (DTCG) shape, two layers:

```json
{
  "primitive": {
    "color": { "ink": { "900": { "$type": "color", "$value": "#16141f" } } },
    "size":  { "4": { "$type": "dimension", "$value": "16px" } }
  },
  "semantic": {
    "color": {
      "surface": { "$type": "color", "$value": "{primitive.color.ink.900}" },
      "text":    { "$type": "color", "$value": "{primitive.color.sand.100}" }
    },
    "space":  { "md": { "$type": "dimension", "$value": "{primitive.size.4}" } },
    "radius": { "card": { "$type": "dimension", "$value": "12px" } },
    "font":   { "body": { "$type": "typography", "$value": { "fontSize": "16px", "fontWeight": 400, "lineHeight": 1.4 } } }
  }
}
```

- **Primitives** are raw values. **Semantic tokens** are what code uses: `surface`, `text`,
  `textMuted`, `accent`, `onAccent`, `scrim`, `space.md`, `radius.card`, `font.title`.
- Code never references primitives directly, and never hard-codes a value a token covers.
- Add a component token only when a pattern repeats a second time.

## Step 4: Generate the theme

Add one no-dependency script, `scripts/build-tokens.mjs`, that resolves `{references}` and
writes one output per target:

| Target | Output | Shape |
|---|---|---|
| React Native | `src/theme/tokens.ts` | typed `as const` object: `color`, `space`, `radius`, `font` (numbers, not `px`) |
| Web | `src/styles/tokens.css` | CSS custom properties; a Tailwind theme extension only if Tailwind is already used |
| Docs / slides | `design/theme.css` | CSS custom properties for the deck or doc template |

Generated files start with a "generated — edit design/tokens.json" comment. Add a `tokens`
script to `package.json` only if the user agrees (it is a checked-in file).

Then migrate existing screens to semantic tokens. Verify with a grep for leftover hex literals.

**Mobile:** add a dev-only style preview route (guarded by `__DEV__`) that renders the palette,
type scale, a card and a button — HTML boards are close, the device is exact.

## Step 5: DESIGN.md

Write `DESIGN.md` at the repo root, short, for humans and agents:

- **Feel / must not feel** — from the brief.
- **Using tokens** — semantic names only; how to add one; run the generator after editing.
- **UI rules** — do/don't list specific to this system (e.g. "one accent per screen").
- **Content rules** — only if content varies: how content colour reaches the UI, and the
  style rules for producing new content (style references, composition, motion).
- **Changing the system** — edit `design/tokens.json` → run the generator → check the preview.

Add one pointer line to the project `CLAUDE.md` / `AGENTS.md`: "UI work follows `DESIGN.md`;
values come from `design/tokens.json`." That file is checked in — the pointer is the only edit.

## Step 6: Sync with a Design System page (optional, two-way)

A Design System artifact gives the tokens a browsable, editable page. The repo stays the source
of truth.

- **The page's format differs.** Its `project/tokens.json` holds families as LISTS
  (`{"color":{"themes":[…],"tokens":[{"name","value","usage"}]}}`, `type.groups[].styles[]`).
  A DTCG map shows empty there. Never publish `design/tokens.json` as-is.
- **Converter:** add `scripts/design-sync.mjs` (no dependencies) with two commands:
  - `export`: semantic tokens resolved to values, with `$description` as `usage`, written to
    `design/.system/project/` (gitignored) along with a `README.md` built from `DESIGN.md`.
  - `import <file> [--write]`: diff a pulled `tokens.json` against the repo. A changed colour
    updates its primitive when only that token uses it. A changed dimension is set on the token,
    because size primitives are named by value. Line height moves only if its px value changed.
    New or renamed names are reported, never mapped. Writes only with `--write`.
- **Create once:** Artifact `publish` with the Design System `type_url` and a `title`, no files.
  Then publish `project/tokens.json`, `project/README.md`, a cover at
  `project/components/Cover/preview.html` (read the type's `artifact-type/reference/cover.md`),
  and the index `project/design-system.json` LAST. Record the page URL in `DESIGN.md`.
- **Push:** `export`, then publish only the changed files to the page's `url`.
- **Pull:** Artifact `read` with `path: "project/tokens.json"`, run `import` on the saved file,
  show the diff, `--write` on approval, then the theme generator.
- Every `$description` in `design/tokens.json` becomes the page's usage note, so write one per
  semantic token.
- The page saves edits on its own (no save button), and it fills `letterSpacing: "0"` into every
  text style. `import` must treat that default as no change.

## Principles

- **Neutral frame for varying content.** When the product shows many images or scenes, UI
  tokens stay neutral and quiet; each piece of content supplies its own accent, computed once
  where the content is produced (not at runtime on the device) and stored next to it.
- **Fewer, firmer choices.** One accent, one type family, one radius scale. Restraint reads as
  designed; variety reads as generated.
- **Real content in every board.** Lorem ipsum and stock placeholders hide whether it works.
- **Contrast is checked, not eyeballed.** Text pairs meet WCAG AA (4.5:1 body, 3:1 large).

## Verify

- Generator runs; type-check passes; no hex literals left outside generated files.
- Mobile: open the style preview on device or emulator. Web: open the page in the browser.
- Report what the user should check visually.

## Later slices (not this skill yet)

- Logo and icon set; image style references for the "complete" level.
- Figma variables for large or collaborative projects.
