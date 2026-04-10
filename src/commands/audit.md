---
name: audit
description: Scan Flutter code for anti-patterns across visual, layout, platform, and code-quality categories. Read-only.
trigger: /audit [path]
reads: [rules/rules.json, skill/references/]
writes: false
---

# /audit

Scan Flutter code for anti-patterns. Read-only — never modifies files.

## When to use

- User asks "check this file" / "audit my code" / "what's wrong here"
- Before running `/polish` or `/normalize` to see the full issue list
- After adding a feature, to verify it doesn't introduce regressions

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. Load the full rule catalog from `src/rules/rules.json` (or equivalent
   in the installed project)
2. For the target path (default: current file or `lib/`), walk every
   `.dart` file
3. For each rule, check matching AST patterns
4. Produce a ranked issue list grouped by severity (error > warning > info)
5. **Do not modify any file.** Report only.

## Output format

```
Audit for lib/screens/home.dart

ERROR (1)
  24:7  layout/missing-safearea  Scaffold body without SafeArea
        → Wrap body in SafeArea(child: ...)

WARNING (2)
  11:15 visual/hardcoded-color  Container uses Colors.purple
        → Use Theme.of(context).colorScheme.primary
  47:3  visual/nested-cards     Card inside Card
        → Collapse to a single Card with ListTile children

INFO (1)
  3:7   code-quality/missing-const  Text widget can be const
        → Add const

4 issues (1 error, 2 warnings, 1 info) in 1 file.
```

## After audit

Suggest next step based on severity mix:
- Errors present → run `/harden` or fix manually, then re-audit
- Warnings only → run `/polish` or `/normalize`
- Info only → optional cleanup via `/polish`
