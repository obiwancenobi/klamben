---
name: extract
description: Pull reusable components, tokens, and patterns out of screens into the design system. Creates shared widgets, theme extensions, and const token files.
trigger: /extract [path]
reads: [skill/references/spacing.md, skill/references/color.md, skill/references/typography.md]
writes: true
---

# /extract

Mine existing screens for reusable design system pieces. The opposite
of building top-down — this works bottom-up from what already exists.

## When to use

- After building 3+ screens and seeing repeated patterns
- Before a design system formalization effort
- User says "we keep building the same thing" / "extract a component"

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. **Scan for repetition** — Walk the target path looking for:
   - Repeated color literals → extract to `ColorScheme` extensions
   - Repeated spacing values → extract to `Spacing` theme extension
   - Repeated `TextStyle` patterns → map to `textTheme` roles
   - Repeated widget subtrees (3+ occurrences) → extract to shared widgets
   - Repeated padding/margin patterns → extract to spacing tokens
2. **Group findings** by type:
   - **Tokens** (colors, spacing, typography, durations)
   - **Components** (buttons, cards, list items, headers)
   - **Patterns** (loading states, error handling, form layouts)
3. **Propose extractions** to the user:
   ```
   Found 3 reusable patterns:
   1. UserAvatar widget (used in 4 screens) → lib/widgets/user_avatar.dart
   2. Spacing tokens (8, 16, 24 used 47 times) → lib/theme/spacing.dart
   3. SectionHeader widget (used in 3 screens) → lib/widgets/section_header.dart
   ```
4. **Ask for approval** before creating files
5. **Create shared files** in `lib/widgets/` or `lib/theme/`
6. **Replace inline usage** with the new shared references
7. **Show the diff** — before/after for each screen touched

## Do NOT

- Extract one-off patterns (YAGNI)
- Create a shared widget library without user approval
- Move files without showing the plan first
- Break existing functionality
