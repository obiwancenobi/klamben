---
name: normalize
description: Pull hardcoded values (colors, spacing, text styles) into theme tokens. Replaces magic numbers with semantic references.
trigger: /normalize [path]
reads: [rules/rules.json, skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /normalize

Hoist hardcoded values into theme. Edits files.

## When to use

- After `/audit` flags visual/hardcoded-color, visual/inline-textstyle,
  or layout/magic-numbers
- When preparing a screen for dark mode
- Before a rebrand

## Process

1. Find hardcoded colors (`Colors.X`, `Color(0xFF...)`)
   - Replace with `Theme.of(context).colorScheme.<semantic>`
   - If no semantic exists in the current theme, add it to the theme
     extension
2. Find inline `TextStyle` with literal `fontSize`
   - Replace with `Theme.of(context).textTheme.<role>` (+ `.copyWith`
     if overrides needed)
3. Find magic-number EdgeInsets (17, 23, etc.)
   - Snap to nearest 4/8 grid value
   - Extract repeated values to `Spacing` theme extension tokens
4. Verify theme is set at `MaterialApp` level; add if missing
5. Show the diff

## Output

```
normalize lib/screens/home.dart

- Container(color: Colors.purple)
+ Container(color: Theme.of(context).colorScheme.primary)

- TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
+ Theme.of(context).textTheme.titleMedium

- EdgeInsets.all(17)
+ EdgeInsets.all(16)

3 replacements in 1 file.
```

## Do NOT

- Change visual behavior (swap primary for secondary arbitrarily)
- Add new widgets or restructure layout
- Invent semantic tokens without user confirmation
