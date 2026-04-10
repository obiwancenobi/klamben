---
name: quieter
description: Tone down overly aggressive designs — softer colors, lighter weights, more whitespace, reduced visual noise.
trigger: /quieter [path]
reads: [skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /quieter

Calm down a noisy design. For screens that feel overwhelming,
cluttered, or visually exhausting.

## When to use

- Too many competing elements on screen
- User says "it's too much" / "tone it down" / "too busy"
- After `/critique` says there's no clear hierarchy

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand personality.
1. **Reduce typographic noise:**
   - Fewer font sizes (max 3 distinct sizes per screen)
   - Lighter weights for secondary text (`w400` not `w600`)
   - Use `onSurfaceVariant` for supporting text instead of `onSurface`
2. **Soften color usage:**
   - Replace `primary` fills with `primaryContainer` or `surfaceVariant`
   - Move secondary actions from `FilledButton` → `OutlinedButton` or `TextButton`
   - Reduce the number of distinct colors on screen (max 3 + neutrals)
3. **Add breathing room:**
   - Increase spacing between sections (16 → 24 or 24 → 32)
   - Remove unnecessary dividers (whitespace is a divider)
   - Reduce information density — consider progressive disclosure
4. **Reduce decorative elements:**
   - Remove redundant icons next to labels
   - Remove shadows where tonal elevation suffices
   - Simplify nested Card structures
5. **Show before/after reasoning** for each change

## Do NOT

- Strip away essential information
- Remove accessibility features (labels, contrast)
- Make the screen feel empty — quieter ≠ barren
- Remove interactive affordances (users still need to know what's tappable)
