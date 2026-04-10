---
name: check-platform
description: iOS vs Android divergence audit — flags Material-only widgets on iOS, missing Cupertino variants, wrong navigation patterns. Read-only.
trigger: /check-platform [path]
reads: [rules/rules.json, skill/references/interaction.md]
writes: false
---

# /check-platform

Audit platform adaptation. Mobile apps must feel native on both iOS
and Android — this command finds the gaps.

## When to use

- Before a cross-platform release
- After adding a new screen
- User asks "does this work on iOS" / "is this Cupertino-ready"

## Checks

1. **Platform-specific code paths** — `Platform.isIOS` branches
   using Material widgets (and vice versa)
2. **Missing .adaptive constructors** — `Switch` not `Switch.adaptive`,
   `Slider` not `.adaptive`
3. **Navigation patterns** — `MaterialPageRoute` on iOS without
   `CupertinoPageRoute` fallback
4. **Dialog style** — `AlertDialog` not `showAdaptiveDialog`
5. **Scroll physics** — missing `BouncingScrollPhysics` on iOS paths
6. **Typography** — Roboto on iOS (San Francisco expected)
7. **Status bar** — dark icons on light bg without
   `SystemUiOverlayStyle` applied

## Output format

```
Platform check for lib/screens/profile.dart

ISSUES
  14:8  Switch used — consider Switch.adaptive
        → Use Switch.adaptive(value: ..., onChanged: ...)

  28:3  AlertDialog used — consider showAdaptiveDialog
        → showAdaptiveDialog(context: ..., builder: ...)

  42:11 BottomNavigationBar on iOS path without CupertinoTabBar
        → Use PlatformTabScaffold or branch on Platform.isIOS

OK
- No Material widgets under Platform.isIOS branches
- Navigator pushes use adaptive route
```
