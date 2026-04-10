---
name: colorize
description: Apply ColorScheme.fromSeed + semantic tokens throughout. Generates matching dark theme.
trigger: /colorize [seed color or path]
reads: [rules/rules.json, skill/references/color.md]
writes: true
---

# /colorize

Give a project a coherent color system from one seed.

## When to use

- Starting a new app
- Rebranding an existing app
- After `/normalize` flags widespread hardcoded colors

## Actions

1. **Derive scheme:** `ColorScheme.fromSeed(seedColor: <user input>, brightness: light)`
2. **Dark variant:** Same seed, `brightness: dark`
3. **Wire both** into `MaterialApp.theme` / `darkTheme` / `themeMode: system`
4. **Replace hardcoded colors** in the target path with semantic tokens
5. **Flag** any pair that can't be mapped automatically (custom brand
   accent that doesn't fit a scheme role)

## Interaction

If no seed given, ask the user for their brand color. Default suggestion:
`const Color(0xFF6750A4)` (Material 3 default indigo).

## Do NOT

- Invent multi-color branding without confirmation
- Touch assets (SVGs, images)
