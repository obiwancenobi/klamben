---
name: adapt
description: Add iOS Cupertino variant for a Material widget/screen. Creates platform-adaptive wrapper.
trigger: /adapt [path]
reads: [rules/rules.json, skill/references/interaction.md]
writes: true
---

# /adapt

Make a Material screen platform-adaptive.

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. Identify Material widgets with Cupertino equivalents
2. Replace with `.adaptive` where the constructor exists
3. For more complex widgets (Scaffold, AppBar, BottomNavigationBar),
   create a `PlatformXyz` wrapper or branch on `Platform.isIOS`
4. Use `CupertinoPageRoute` on iOS navigator pushes
5. Use `showAdaptiveDialog` instead of `showDialog`

## Do NOT

- Rewrite navigation structure
- Add `flutter_platform_widgets` dependency without asking
- Touch Android-specific code paths
