---
name: icon-set
description: Swap default Material icons for a coherent set; wire flutter_svg or font icons consistently.
trigger: /icon-set [package name or path]
reads: [rules/rules.json]
writes: true
---

# /icon-set

Replace default Icons.* with a coherent icon set.

## When to use

- App uses Material default icons mixed with SVGs inconsistently
- User wants a specific icon pack (Feather, Phosphor, Lucide)
- Rebranding

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. Add the chosen icon package to `pubspec.yaml`
2. Walk target path, replace `Icon(Icons.X)` with the new package's
   equivalent (ask user if ambiguous)
3. For SVG assets, wire `flutter_svg` and move SVGs to `assets/icons/`
4. Update `pubspec.yaml` assets section
5. Maintain size and semantics — tooltip/semanticLabel preserved

## Do NOT

- Invent icon names
- Replace icons that have platform meaning (e.g. platform back arrow)
