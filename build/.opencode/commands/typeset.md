---
name: typeset
description: Install google_fonts, wire type scale, fix weights and line heights.
trigger: /typeset [font name or path]
reads: [rules/rules.json, skill/references/typography.md]
writes: true
---

# /typeset

Escape default Roboto. Wire a proper type system.

## When to use

- New project
- `/audit` flags visual/roboto-default
- Rebrand

## Actions

1. **Add `google_fonts`** to `pubspec.yaml` if missing
2. **Set `textTheme`** on `ThemeData` with `GoogleFonts.<font>TextTheme()`
3. **Font choice** — if user doesn't specify, recommend one of:
   - **Inter** (neutral, modern, safe bet)
   - **Manrope** (friendly, tech-forward)
   - **DM Sans** (geometric, editorial feel)
4. **Fix inline TextStyle** — replace with `Theme.of(context).textTheme.*`
5. **Check line-heights** — ensure overrides preserve `height`

## Interaction

If no font given, ask. Show the 3 recommended options and why.

## Do NOT

- Bundle a font via assets unless user explicitly asks (google_fonts
  CDN-loads by default)
- Change to a serif for body text
