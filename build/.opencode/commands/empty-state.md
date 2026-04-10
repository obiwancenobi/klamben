---
name: empty-state
description: Generate empty/error/loading state widgets for a screen.
trigger: /empty-state [screen name]
reads: [rules/rules.json, skill/references/ux-writing.md]
writes: true
---

# /empty-state

Add the three missing states to a screen: empty, error, loading.

## Actions

1. **Empty:** Centered icon + title + body + optional CTA
2. **Error:** Centered error icon + title + body + retry button
3. **Loading:** Skeleton loader (matches content shape) OR centered spinner
   for short loads
4. **Wire them:** Replace the screen's render logic to pick state based
   on loading/error/data

## Do NOT

- Generate placeholder illustrations (use Material icons)
- Add third-party skeleton packages unless user asks
