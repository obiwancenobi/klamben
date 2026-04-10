---
name: animate
description: Add tasteful motion — Hero transitions, AnimatedSwitcher, implicit animations, duration tokens. Respects reduced-motion.
trigger: /animate [path]
reads: [rules/rules.json, skill/references/motion.md]
writes: true
---

# /animate

Add motion to a static screen. Restraint-first.

## When to use

- User says "this feels flat" / "add some life" / "animate the X"
- After design polish but before ship

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. **Implicit animations first:** `AnimatedContainer`, `AnimatedOpacity`,
   `AnimatedSwitcher` for single-property changes
2. **Hero transitions:** Matching pairs across navigation
3. **Enter transitions:** `FadeTransition` + `SlideTransition` on first
   build for hero content
4. **Duration tokens:** Use `Durations.fast/medium/slow` from
   `lib/theme/motion.dart` (create if missing)
5. **Curves:** `Curves.easeOutCubic` for entry, `easeInCubic` for exit
6. **Reduced motion:** Respect `MediaQuery.disableAnimations`
7. **Dispose controllers** — always

## Do NOT

- Animate more than 2-3 elements at once
- Use durations over 400ms
- Use `Curves.linear`
- Animate color changes if the theme already handles it (ThemeData
  transitions are automatic)
