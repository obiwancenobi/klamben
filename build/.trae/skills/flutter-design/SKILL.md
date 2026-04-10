---
name: flutter-design
description: Use when writing, reviewing, or refactoring Flutter mobile UI code. Teaches Flutter-specific design principles (Material 3 + Cupertino adaptive), type scales, theming, spacing grids, motion, interaction, responsive layout, and UX writing. Prevents common Flutter AI-slop patterns like hardcoded Colors.purple, missing SafeArea, nested Container/Padding chains, Material widgets on iOS paths, missing const, and absent semantic labels.
---

# Flutter Design

You are working in a Flutter mobile project. Apply the rules below to
every widget you create, read, or modify. When the user asks for UI
work, read the relevant reference module first.

## Getting started

Run `/teach` once when you first add klamben to a project. It scans
your codebase and asks a few questions to build a design context file
(`.klamben.md`). All other commands reference this context for
project-specific guidance.

If `.klamben.md` doesn't exist, commands still work but give generic
Flutter advice instead of project-tailored suggestions.

## Design context

Before doing any UI work, check if `.klamben.md` exists in the project
root. If it does, read it and apply the project's brand, platform
targets, accessibility tier, and existing patterns to your work.

## Core principles

1. **Theme over hardcode.** Never write `Colors.purple`, `Color(0xFF...)`,
   or inline `TextStyle(fontSize: ...)`. Always reach for
   `Theme.of(context).colorScheme.*` and `.textTheme.*`.
2. **Platform-adaptive by default.** On screens that render cross-platform,
   branch on `Platform.isIOS` or use `.adaptive` constructors
   (`Switch.adaptive`, `Icon.adaptive`) when they exist.
3. **Safe by construction.** Every `Scaffold` body with visible content
   at the top needs a `SafeArea` (or an `AppBar` which handles the inset).
4. **Widget economy.** No `Container` wrapping `Padding` wrapping
   `Container`. One widget per responsibility.
5. **Performance is a design decision.** `const` constructors wherever
   possible. `ListView.builder` for long lists. `RepaintBoundary` for
   expensive subtrees.
6. **Accessibility is non-negotiable.** Every icon-only button has a
   `tooltip`. Touch targets are ≥48dp Material / ≥44pt iOS. Text contrast
   meets WCAG AA.
7. **Localize from day one.** No hardcoded user-facing strings. Wire
   `flutter_localizations` + ARB files before shipping Text widgets.

## Reference modules

When a task touches one of these areas, read the corresponding file:

- [typography.md](references/typography.md) — text themes, type scale,
  fonts, line-height
- [color.md](references/color.md) — ColorScheme, seed colors, semantic
  tokens, dark mode
- [spacing.md](references/spacing.md) — 4/8pt grid, EdgeInsets, SafeArea
- [motion.md](references/motion.md) — AnimationController, Curves,
  Hero, implicit animations
- [interaction.md](references/interaction.md) — buttons, touch targets,
  haptics, loading states
- [responsive.md](references/responsive.md) — LayoutBuilder, breakpoints,
  Flex children
- [ux-writing.md](references/ux-writing.md) — button labels, errors,
  empty states, i18n

## Commands

Twenty-two slash commands are available. Use them as explicit entry
points for specific design operations:

**Setup:** `/teach` (run once per project)

**Assessment (read-only):** `/audit`, `/critique`, `/check-a11y`,
`/check-platform`

**Refinement:** `/normalize`, `/polish`, `/distill`, `/harden`

**Enhancement:** `/animate`, `/colorize`, `/typeset`, `/arrange`,
`/delight`, `/optimize`

**Specialized:** `/adapt`, `/theme-init`, `/widgetize`, `/localize`,
`/form`, `/empty-state`, `/icon-set`

## Rule catalog

All 24 anti-pattern rules this skill enforces are defined in
`src/rules/rules.json` (in the klamben repo). Each rule has an ID
like `visual/hardcoded-color`. When you flag an issue in a review,
cite the rule ID so the user can look up the full rationale.

Rules are grouped by category:

- `visual/*` — typography, color, elevation, nested Cards
- `layout/*` — SafeArea, padding nesting, grid values, fluid widths
- `platform/*` — Material/Cupertino adaptive patterns
- `code-quality/*` — const, dispose, semantics, async safety

## When in doubt

Prefer boring and consistent over novel and clever. A well-themed,
accessible, platform-adaptive Flutter app is worth more than a clever
animation on a rigid layout.
