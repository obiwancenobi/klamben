---
name: layout
description: Fix layout, spacing, and visual rhythm — responsive breakpoints, SafeArea, LayoutBuilder, overflow guards.
trigger: /layout [path]
reads: [rules/rules.json, skill/references/responsive.md, skill/references/spacing.md]
writes: true
---

# /arrange

Fix broken layout.

## When to use

- RenderFlex overflow errors
- `/audit` flags layout/* rules
- Layout breaks on small phones or foldables
- Content renders under notch or home indicator

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. **SafeArea:** Wrap `Scaffold` body if no `AppBar`
2. **Flex children:** Wrap variable-content `Row`/`Column` children
   in `Flexible`/`Expanded`
3. **Remove fixed widths:** `Container(width: 300)` → `Expanded` or
   `FractionallySizedBox`
4. **Add scroll fallback:** `SingleChildScrollView` for long content
5. **Breakpoint adaptation:** Use `LayoutBuilder` for screens that
   should adapt to foldable/tablet widths
6. **Keyboard handling:** `resizeToAvoidBottomInset: true` (default)
   + `MediaQuery.viewInsetsOf` for bottom padding on forms

## Do NOT

- Rewrite layout semantics
- Add a drawer unless user asks
- Change navigation structure
