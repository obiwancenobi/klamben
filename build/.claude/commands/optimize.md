---
name: optimize
description: Performance pass — const, RepaintBoundary, ListView.builder, image caching, minimize rebuilds.
trigger: /optimize [path]
reads: [rules/rules.json, skill/references/interaction.md]
writes: true
---

# /optimize

Performance cleanup. Mechanical, safe changes only.

## When to use

- Jank on scroll
- Slow rebuilds
- Before shipping to low-end devices
- `/audit` flags code-quality/missing-const

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. **Add `const`** to every eligible constructor
2. **`ListView.builder`** for lists > 10 items
3. **`RepaintBoundary`** around animated or expensive subtrees
4. **`cached_network_image`** for network images (add to pubspec if needed)
5. **`ValueListenableBuilder`** / `AnimatedBuilder` instead of
   `setState` on animations
6. **Lazy loading** — `ListView.builder` with `itemCount` over
   `ListView(children: map(...).toList())`
7. **Avoid `Opacity`** for fade animations — prefer `FadeTransition`

## Do NOT

- Cache data without understanding invalidation
- Add profile-mode benchmarks unless user asks
- Change business logic
