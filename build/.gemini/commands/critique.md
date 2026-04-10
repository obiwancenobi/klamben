---
name: critique
description: Subjective UX and visual hierarchy review of a screen widget. Comments on affordance, spacing, copy, and layout balance. Read-only.
trigger: /critique <file or widget>
reads: [skill/references/]
writes: false
---

# /critique

Subjective UX critique of a screen or widget. Not a linter — a design
review.

## When to use

- User asks "how does this look" / "is this good UX" / "what would you change"
- Before a visual design review
- After `/audit` is clean but the UX still feels off

## Process

1. Read the target widget file
2. Build a mental model of the rendered layout (visual hierarchy, grouping, flow)
3. Apply principles from `skill/references/` (especially spacing,
   typography, interaction, ux-writing)
4. Review for:
   - **Hierarchy:** Is the primary action obvious? Is less-important
     content visually recessed?
   - **Grouping:** Are related elements close? Are unrelated
     elements separated?
   - **Affordance:** Is it clear what's tappable? Are disabled states
     distinguishable?
   - **Copy:** Are button labels verbs? Are errors actionable?
   - **Flow:** Does the user's eye follow a sensible path?
5. **Do not modify any file.** Write comments only.

## Output format

```
Critique of home_screen.dart

HIERARCHY
- "Save" is the primary action but rendered as OutlinedButton.
  Consider FilledButton to match its importance.
- Card headers all use titleMedium — consider titleLarge for the top
  one to create a clear anchor.

GROUPING
- Name field and avatar are visually distant. Moving avatar above name
  would match user mental model ("this is about [person]").

AFFORDANCE
- The gray row at L47 has an onTap but no ripple or chevron.
  Users won't know it's tappable. Add InkWell + trailing chevron icon.

COPY
- Button "Submit" (L62) → "Send feedback"
- Error "Try again" (L89) → "Couldn't send. Check your connection and
  try again."

FLOW
- The save CTA is below the fold on small phones. Sticky it to the
  bottom or move it above the optional fields.
```
