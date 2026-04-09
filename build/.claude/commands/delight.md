---
name: delight
description: Add micro-interactions — haptics, subtle motion, skeleton loaders, pull-to-refresh polish.
trigger: /delight [path]
reads: [rules/rules.json, skill/references/interaction.md, skill/references/motion.md]
writes: true
---

# /delight

Micro-interactions that make an app feel alive. Subtle only.

## When to use

- App works but feels flat
- User says "add some polish" / "make it feel nice"
- After `/harden` is done

## Actions

1. **Haptics** on state-changing buttons (`HapticFeedback.lightImpact`)
2. **Skeleton loaders** for list/grid loading states
3. **Pull-to-refresh** on scrollable lists (`RefreshIndicator` /
   `CupertinoSliverRefreshControl`)
4. **Success confirmations** — SnackBar or Material 3 `showAdaptiveDialog`
5. **Loading button states** — button shows inline spinner while working
6. **Transitions** between loading and loaded via `AnimatedSwitcher`

## Do NOT

- Add confetti, sparkles, or over-the-top effects
- Animate every transition
- Use heavy haptics for routine actions
