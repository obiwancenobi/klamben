---
name: check-a11y
description: Accessibility audit — Semantics labels, contrast ratios, touch target sizes, screen reader flow. Read-only.
trigger: /check-a11y [path]
reads: [rules/rules.json, skill/references/interaction.md, skill/references/color.md, skill/references/ux-writing.md]
writes: false
---

# /check-a11y

Accessibility-focused audit. Catches what `/audit` doesn't always
surface.

## When to use

- Before shipping any user-facing screen
- After a layout change
- User asks "is this accessible" / "check a11y"

## Checks

1. **Semantic labels** — IconButton without tooltip, Image.asset
   without Semantics label, tappable Container without accessible name
2. **Touch targets** — Interactive elements <48dp/44pt
3. **Contrast** — Text color vs background (flag obvious fails:
   `Colors.grey` on `Colors.white`, custom pairs)
4. **Focus order** — Form fields in visual order, no trapped focus
5. **Scaled text** — Text that would overflow at `textScaleFactor = 2.0`
6. **Reduced motion** — Animations that ignore `MediaQuery.disableAnimations`
7. **Screen reader labels** — Semantics exclusion on decorative images,
   label on meaningful ones

## Output format

```
A11y check for lib/screens/settings.dart

CRITICAL (2)
  11:7  IconButton(Icons.close) missing tooltip
  24:15 Icon(Icons.warning) standalone — no accessible name

WARNING (3)
  33:8  Tap target 32×32 on reminder toggle — needs ≥48dp
  47:11 Text('Reminder') on Color(0xFFCCCCCC) bg — 2.8:1 (needs 4.5:1)
  62:4  Text widget will overflow Row at textScaleFactor=2.0

OK
- Form fields in visual order
- No trapped focus
- Navigation respects reduced motion

5 issues (2 critical, 3 warning).
```

## Do NOT

- Fix the issues automatically — this is read-only
- Suggest rewriting unrelated code
- Skip silent issues (tooltip absence is *silent* but critical)
