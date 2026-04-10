---
name: craft
description: Guided shape-then-build flow — design the screen's purpose, layout, and hierarchy before writing widgets. Full creation workflow with visual iteration.
trigger: /craft <screen or feature description>
reads: [skill/references/]
writes: true
---

# /craft

Design-first screen creation. Shape the concept, then build the
widgets. Prevents the "just start coding" trap that produces
generic-looking screens.

## When to use

- Building a new screen from scratch
- User says "build me a..." / "create a..." / "make a screen for..."
- Whenever the output is a full screen or major feature, not a tweak

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.

### Phase 1: Shape (no code yet)

1. **Clarify purpose** — What does this screen do? What's the one
   thing the user accomplishes here? If unclear, ask.
2. **Identify content hierarchy** — What's the most important element?
   What's secondary? What's optional? Sketch a mental wireframe:
   - Primary action (FAB, bottom CTA, inline button)
   - Key content (hero, list, form, card)
   - Supporting info (subtitle, metadata, timestamp)
   - Navigation (back, tabs, drawer)
3. **Choose layout pattern** — Based on content:
   - List → `ListView.builder` + item widgets
   - Detail → scroll + hero + sections
   - Form → `SingleChildScrollView` + `Form`
   - Dashboard → grid or card stack
   - Empty/loading/error states for each
4. **Present the shape** to the user as a text wireframe:
   ```
   [AppBar: "Screen Title"]
   [Hero image / avatar]
   [Title — headlineMedium]
   [Subtitle — bodyMedium, onSurfaceVariant]
   [--- Divider ---]
   [List of items]
   [FAB: "Add item"]
   ```
   Ask: "Does this layout match what you need?"

### Phase 2: Build

5. **Write the widget** using theme tokens, not hardcoded values.
   Apply all klamben rules from the start — no cleanup pass needed.
6. **Add states** — loading, error, empty (using `/empty-state` patterns)
7. **Add platform adaptation** if `.klamben.md` says cross-platform
8. **Present the result** — show the code, explain key design decisions

### Phase 3: Iterate

9. Ask: "What would you change?" Iterate on feedback.
10. When satisfied, suggest: "Run `/audit` to verify, then `/polish`
    for final cleanup."

## Do NOT

- Skip Phase 1 and jump straight to code
- Use hardcoded colors, sizes, or strings
- Build without considering empty/error states
- Ignore platform adaptation if the project targets both platforms
