---
name: theme-init
description: Bootstrap a full ThemeData — ColorScheme, TextTheme, extensions — from a seed color.
trigger: /theme-init [seed color]
reads: [rules/rules.json, skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /theme-init

Generate a theme scaffold for a new project.

## Actions

1. Create `lib/theme/app_theme.dart` with:
   - `ColorScheme.fromSeed` for light and dark
   - `TextTheme` via `google_fonts` (ask user for font; default Inter)
   - `Spacing` theme extension
   - Full `ThemeData.light()` and `ThemeData.dark()` builders
2. Wire into `MaterialApp` in `lib/main.dart`
3. Create `lib/theme/spacing.dart` with the `Spacing` extension class
4. Create `lib/theme/motion.dart` with `Durations` tokens

## Interaction

Ask user:
- Seed color (default `0xFF6750A4`)
- Font (default Inter)

## Output

List every file created + diff summary.
