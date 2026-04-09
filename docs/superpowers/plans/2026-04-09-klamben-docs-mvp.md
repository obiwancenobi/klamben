# klamben Docs MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a working Flutter-mobile design skill installable into Claude Code — 1 skill + 7 reference modules + 21 commands + rule contract (`rules.json`) + single-harness build script (claude only). CLI detector and multi-harness fan-out are deferred to later sub-plans.

**Architecture:** Single source of truth in `src/`. Canonical markdown files reference rule IDs from `src/rules/rules.json`. A Dart build script (`tool/build.dart`) transforms canonical `src/` into Claude Code's `.claude/` layout under `build/.claude/`. Users copy `build/.claude/` into their Flutter project to get the skill + 21 slash commands.

**Tech Stack:** Pure Dart (SDK 3.3+), Markdown with YAML frontmatter, `package:path` + `package:yaml` for the build script. No Flutter SDK needed for this sub-plan.

---

## File Structure

**Canonical sources (hand-written, source of truth):**
- `src/rules/rules.json` — 24 anti-pattern rule definitions (contract)
- `src/skill/SKILL.md` — main skill frontmatter + entry
- `src/skill/references/{typography,color,spacing,motion,interaction,responsive,ux-writing}.md` — 7 reference modules
- `src/commands/*.md` — 21 slash command definitions

**Build tooling:**
- `tool/build.dart` — Dart script that transforms `src/` → `build/.claude/`
- `tool/pubspec.yaml` — declares `path` + `yaml` deps for the build script
- `tool/test/build_test.dart` — unit tests for the build script

**Generated output (committed, do not hand-edit):**
- `build/.claude/skills/flutter-design/SKILL.md`
- `build/.claude/skills/flutter-design/references/*.md`
- `build/.claude/commands/*.md`

**Repo metadata:**
- `README.md` — project overview + install instructions for Claude Code
- `LICENSE` — Apache 2.0
- `NOTICE` — credit upstream `pbakaus/impeccable`
- `.gitignore` — Dart conventions
- `CHANGELOG.md` — versioned changelog seed

---

## Task 1: Scaffold repo skeleton

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/.gitignore`
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/LICENSE`
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/NOTICE`
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/CHANGELOG.md`
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/README.md` (stub)

- [ ] **Step 1: Initialize git repo**

```bash
cd /Users/arif.ariyan/Documents/Development/ai/klamben
git init
```

Expected: `Initialized empty Git repository in .../klamben/.git/`

- [ ] **Step 2: Write `.gitignore`**

```
# Dart
.dart_tool/
.packages
build/.dart_tool/
pubspec.lock

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db

# Logs
*.log
```

- [ ] **Step 3: Write `LICENSE` (Apache 2.0)**

Fetch exact Apache 2.0 text from `https://www.apache.org/licenses/LICENSE-2.0.txt` and save verbatim to `LICENSE`. Replace the `[yyyy] [name of copyright owner]` line with `2026 klamben contributors`.

- [ ] **Step 4: Write `NOTICE`**

```
klamben
Copyright 2026 klamben contributors

This product is a derivative work of Impeccable
(https://github.com/pbakaus/impeccable) by Paul Bakaus,
licensed under the Apache License, Version 2.0.

Impeccable targets web frontend design. klamben adapts the
architecture, command naming, and anti-pattern taxonomy to
Flutter mobile app development. All Flutter-specific
content, rules, and examples are original to klamben.
```

- [ ] **Step 5: Write `CHANGELOG.md` seed**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Initial docs MVP: skill, 7 reference modules, 21 commands, rule contract, Claude Code build target
```

- [ ] **Step 6: Write `README.md` stub**

```markdown
# klamben

Flutter mobile design skill for AI code assistants. A Flutter-flavored
clone of [impeccable](https://github.com/pbakaus/impeccable).

Teaches AI harnesses to avoid Flutter-specific AI slop:
hardcoded `Colors.purple`, missing `SafeArea`, nested
`Container > Padding > Container`, Material widgets on iOS paths,
missing `const`, and more.

## What's inside

- 1 skill with 7 reference modules (typography, color, spacing, motion,
  interaction, responsive, UX writing) — all Flutter-first
- 21 slash commands (`/audit`, `/polish`, `/normalize`, `/animate`, ...)
- Single source of truth rule catalog (`src/rules/rules.json`) — 24 rules
  across visual/layout/platform/code-quality categories

## Install (Claude Code)

See [Task 19 / README] for details — will be filled in at the end of this plan.

## License

Apache 2.0. Derivative of [pbakaus/impeccable](https://github.com/pbakaus/impeccable).
See `NOTICE`.
```

- [ ] **Step 7: First commit**

```bash
git add .gitignore LICENSE NOTICE CHANGELOG.md README.md
git commit -m "chore: scaffold repo with license and readme stub"
```

Expected: 1 commit on branch, 5 files.

---

## Task 2: Rule contract — `src/rules/rules.json`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/rules/rules.json`

The rule catalog is the contract shared between skill markdown, build script, and (future) CLI detector. This task writes all 24 rule definitions.

- [ ] **Step 1: Create directory**

```bash
mkdir -p src/rules
```

- [ ] **Step 2: Write `src/rules/rules.json`**

```json
{
  "version": "1.0.0",
  "rules": [
    {
      "id": "visual/hardcoded-color",
      "category": "visual",
      "severity": "warning",
      "title": "Hardcoded Color constant",
      "description": "Use ColorScheme semantic tokens instead of Colors.purple or Color(0xFF...).",
      "rationale": "Hardcoded colors bypass theme, break dark mode, and block rebranding.",
      "detect": {
        "type": "ast",
        "pattern": "PropertyAccess(target='Colors', name=NOT_IN['transparent'])",
        "alt_pattern": "InstanceCreationExpression(type='Color', const=true)"
      },
      "fix_hint": "Replace with Theme.of(context).colorScheme.primary (or appropriate semantic token).",
      "references": ["color.md#semantic-tokens"],
      "examples": {
        "bad": "Container(color: Colors.purple)",
        "good": "Container(color: Theme.of(context).colorScheme.primary)"
      }
    },
    {
      "id": "visual/roboto-default",
      "category": "visual",
      "severity": "info",
      "title": "Roboto default font",
      "description": "Relying on platform default Roboto signals default AI output. Use google_fonts or a bundled custom font.",
      "rationale": "Default Roboto is the most common AI-generated Flutter font choice. A distinct type pairing is the fastest way to escape generic aesthetics.",
      "detect": {
        "type": "regex",
        "pattern": "ThemeData\\s*\\(\\s*\\)(?![^)]*textTheme)"
      },
      "fix_hint": "Use GoogleFonts.interTextTheme() or load a bundled font via pubspec assets.",
      "references": ["typography.md#choosing-fonts"],
      "examples": {
        "bad": "ThemeData()",
        "good": "ThemeData(textTheme: GoogleFonts.manropeTextTheme())"
      }
    },
    {
      "id": "visual/gradient-abuse",
      "category": "visual",
      "severity": "info",
      "title": "Purple gradient background",
      "description": "Purple/pink LinearGradient on Scaffold or hero is an AI-slop tell.",
      "rationale": "LLMs default to purple gradients for 'premium' feel. Use a subtle single color or brand-derived seed.",
      "detect": {
        "type": "ast",
        "pattern": "LinearGradient(colors contains PURPLE_FAMILY)"
      },
      "fix_hint": "Replace with ColorScheme.surfaceTint or a brand-derived seed color.",
      "references": ["color.md#gradients"],
      "examples": {
        "bad": "LinearGradient(colors: [Colors.purple, Colors.pink])",
        "good": "Container(color: colorScheme.surface)"
      }
    },
    {
      "id": "visual/pure-black-text",
      "category": "visual",
      "severity": "warning",
      "title": "Pure black text color",
      "description": "Colors.black has too much contrast against white surfaces and fails in dark mode.",
      "rationale": "Material 3 uses onSurface which resolves to a tuned near-black/near-white per brightness.",
      "detect": {
        "type": "ast",
        "pattern": "TextStyle(color=Colors.black)"
      },
      "fix_hint": "Use Theme.of(context).colorScheme.onSurface.",
      "references": ["color.md#text-colors"],
      "examples": {
        "bad": "Text('Hello', style: TextStyle(color: Colors.black))",
        "good": "Text('Hello', style: Theme.of(context).textTheme.bodyLarge)"
      }
    },
    {
      "id": "visual/nested-cards",
      "category": "visual",
      "severity": "warning",
      "title": "Card nested inside Card",
      "description": "Nested Card widgets double-up elevation and create visual noise.",
      "rationale": "Each Card adds shadow and rounded corners. Nesting amplifies both. Use a single Card with internal structure instead.",
      "detect": {
        "type": "ast",
        "pattern": "Card(child DESCENDANT Card)"
      },
      "fix_hint": "Collapse to a single Card; use Divider or ListTile sections for internal structure.",
      "references": ["spacing.md#card-hierarchy"],
      "examples": {
        "bad": "Card(child: Card(child: Text('x')))",
        "good": "Card(child: ListTile(title: Text('x')))"
      }
    },
    {
      "id": "visual/shadow-overuse",
      "category": "visual",
      "severity": "info",
      "title": "Excessive elevation",
      "description": "Elevation > 8 on a non-floating surface creates cartoonish shadows.",
      "rationale": "Material 3 uses tonal elevation (surfaceTint) more than shadow. High elevation values are a holdover from Material 2.",
      "detect": {
        "type": "ast",
        "pattern": "Card(elevation > 8) OR Material(elevation > 8)"
      },
      "fix_hint": "Use elevation 0-4 with surfaceTintColor, or rely on Material 3 default tonal elevation.",
      "references": ["spacing.md#elevation"],
      "examples": {
        "bad": "Card(elevation: 16, child: ...)",
        "good": "Card(elevation: 1, child: ...)"
      }
    },
    {
      "id": "visual/inline-textstyle",
      "category": "visual",
      "severity": "warning",
      "title": "Inline TextStyle instead of theme",
      "description": "Writing TextStyle(fontSize: 18, fontWeight: ...) inline bypasses the type scale.",
      "rationale": "Theme-driven typography guarantees consistency and dark-mode safety. Inline styles fragment the scale.",
      "detect": {
        "type": "ast",
        "pattern": "TextStyle(fontSize=LITERAL)"
      },
      "fix_hint": "Use Theme.of(context).textTheme.bodyLarge (etc.) and .copyWith() for deltas.",
      "references": ["typography.md#type-scale"],
      "examples": {
        "bad": "Text('Hi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))",
        "good": "Text('Hi', style: Theme.of(context).textTheme.titleMedium)"
      }
    },
    {
      "id": "layout/missing-safearea",
      "category": "layout",
      "severity": "error",
      "title": "Scaffold body without SafeArea",
      "description": "Scaffold body content collides with status bar, notch, and gesture insets without SafeArea.",
      "rationale": "SafeArea applies MediaQuery.padding to children; without it, content renders under system UI on modern devices.",
      "detect": {
        "type": "ast",
        "pattern": "Scaffold(body=NOT_DESCENDANT_OF(SafeArea) AND appBar==null)"
      },
      "fix_hint": "Wrap body in SafeArea(child: ...), or use Scaffold(appBar: ...) which handles the top inset.",
      "references": ["spacing.md#safe-areas"],
      "examples": {
        "bad": "Scaffold(body: Column(children: [...]))",
        "good": "Scaffold(body: SafeArea(child: Column(children: [...])))"
      }
    },
    {
      "id": "layout/nested-padding",
      "category": "layout",
      "severity": "warning",
      "title": "Padding inside Container with padding",
      "description": "Container has its own padding; wrapping it in Padding duplicates the concept.",
      "rationale": "Decoration-free Container wrapping a Padding wrapping a child is three widgets where one suffices.",
      "detect": {
        "type": "ast",
        "pattern": "Padding(child=Container(padding!=null)) OR Container(child=Padding)"
      },
      "fix_hint": "Use a single Container(padding: ...) or a single Padding(padding: ...).",
      "references": ["spacing.md#widget-economy"],
      "examples": {
        "bad": "Padding(padding: ..., child: Container(padding: ..., child: Text('x')))",
        "good": "Container(padding: EdgeInsets.all(16), child: Text('x'))"
      }
    },
    {
      "id": "layout/magic-numbers",
      "category": "layout",
      "severity": "info",
      "title": "Non-grid padding/margin values",
      "description": "EdgeInsets values not aligned to 4/8pt grid (e.g. 17, 23, 11) are an AI tell and break visual rhythm.",
      "rationale": "The 4pt grid is the de-facto Material standard. Odd values look designed by committee.",
      "detect": {
        "type": "ast",
        "pattern": "EdgeInsets(any value NOT IN {0,2,4,6,8,12,16,20,24,32,40,48,56,64})"
      },
      "fix_hint": "Round to the nearest 4/8 multiple, or extract to named const tokens (kSpaceSm = 8, kSpaceMd = 16).",
      "references": ["spacing.md#grid-values"],
      "examples": {
        "bad": "EdgeInsets.all(17)",
        "good": "EdgeInsets.all(16)"
      }
    },
    {
      "id": "layout/hardcoded-width",
      "category": "layout",
      "severity": "warning",
      "title": "Fixed Container width in mobile layout",
      "description": "Hardcoded widths (e.g. width: 300) break on small phones and foldables.",
      "rationale": "Mobile must work from 320dp (small phones) to 900dp+ (foldables unfolded). Fixed pixel widths assume a median device.",
      "detect": {
        "type": "ast",
        "pattern": "Container(width=LITERAL where LITERAL > 120)"
      },
      "fix_hint": "Use Expanded, Flexible, or FractionallySizedBox. For images, use AspectRatio.",
      "references": ["responsive.md#fluid-widths"],
      "examples": {
        "bad": "Container(width: 300, child: Text('long...'))",
        "good": "Expanded(child: Text('long...'))"
      }
    },
    {
      "id": "layout/no-flexible",
      "category": "layout",
      "severity": "warning",
      "title": "Row/Column children with implicit sizing",
      "description": "Row or Column with long Text children but no Flexible/Expanded will overflow.",
      "rationale": "RenderFlex overflow is the #1 Flutter layout bug in AI-generated code.",
      "detect": {
        "type": "ast",
        "pattern": "Row(children contains Text without Flexible ancestor)"
      },
      "fix_hint": "Wrap variable-length children in Flexible or Expanded.",
      "references": ["responsive.md#flex-children"],
      "examples": {
        "bad": "Row(children: [Icon(Icons.person), Text('Very long name...')])",
        "good": "Row(children: [Icon(Icons.person), Flexible(child: Text('Very long name...'))])"
      }
    },
    {
      "id": "layout/fixed-row-overflow",
      "category": "layout",
      "severity": "error",
      "title": "Row/Column explicit width/height exceeds parent",
      "description": "SizedBox(width: double.infinity) inside a Row causes immediate overflow.",
      "rationale": "Infinite width constraints propagate up and produce cryptic 'RenderBox was not laid out' errors.",
      "detect": {
        "type": "ast",
        "pattern": "Row(children contains SizedBox(width=double.infinity))"
      },
      "fix_hint": "Use Expanded instead of infinite SizedBox inside flex widgets.",
      "references": ["responsive.md#constraint-propagation"],
      "examples": {
        "bad": "Row(children: [SizedBox(width: double.infinity, child: Text('x'))])",
        "good": "Row(children: [Expanded(child: Text('x'))])"
      }
    },
    {
      "id": "platform/material-on-ios",
      "category": "platform",
      "severity": "info",
      "title": "Material widget on iOS-only path",
      "description": "A MaterialButton or ElevatedButton inside a Platform.isIOS branch is a platform mismatch.",
      "rationale": "iOS users expect Cupertino affordances. Material on iOS paths is a tell of unconsidered adaptation.",
      "detect": {
        "type": "ast",
        "pattern": "IfStatement(condition=Platform.isIOS, body contains MaterialWidget)"
      },
      "fix_hint": "Use the Cupertino equivalent (CupertinoButton) or an adaptive wrapper.",
      "references": ["interaction.md#platform-adaptation"],
      "examples": {
        "bad": "if (Platform.isIOS) ElevatedButton(...)",
        "good": "if (Platform.isIOS) CupertinoButton(...)"
      }
    },
    {
      "id": "platform/cupertino-on-android",
      "category": "platform",
      "severity": "info",
      "title": "Cupertino widget on Android-only path",
      "description": "Mirror of material-on-ios: CupertinoButton inside Platform.isAndroid.",
      "rationale": "Android users expect Material Design affordances.",
      "detect": {
        "type": "ast",
        "pattern": "IfStatement(condition=Platform.isAndroid, body contains CupertinoWidget)"
      },
      "fix_hint": "Use the Material equivalent (ElevatedButton) or an adaptive wrapper.",
      "references": ["interaction.md#platform-adaptation"],
      "examples": {
        "bad": "if (Platform.isAndroid) CupertinoButton(...)",
        "good": "if (Platform.isAndroid) FilledButton(...)"
      }
    },
    {
      "id": "platform/wrong-nav-pattern",
      "category": "platform",
      "severity": "info",
      "title": "BottomNavigationBar on iOS without Cupertino variant",
      "description": "Using Material BottomNavigationBar on iOS skips Cupertino's native tab bar feel.",
      "rationale": "Platform-idiomatic navigation reduces user friction and signals attention to detail.",
      "detect": {
        "type": "ast",
        "pattern": "BottomNavigationBar in project without CupertinoTabBar branch"
      },
      "fix_hint": "Use PlatformTabScaffold from package:flutter_platform_widgets or branch on Platform.isIOS.",
      "references": ["interaction.md#navigation-patterns"],
      "examples": {
        "bad": "Scaffold(bottomNavigationBar: BottomNavigationBar(...))",
        "good": "Platform.isIOS ? CupertinoTabScaffold(...) : Scaffold(bottomNavigationBar: ...)"
      }
    },
    {
      "id": "platform/missing-adaptive",
      "category": "platform",
      "severity": "info",
      "title": "Switch without Switch.adaptive",
      "description": "Switch renders as Material on both platforms; Switch.adaptive uses CupertinoSwitch on iOS.",
      "rationale": "Flutter provides .adaptive constructors specifically for this — use them.",
      "detect": {
        "type": "ast",
        "pattern": "InstanceCreationExpression(type='Switch', constructor!='adaptive')"
      },
      "fix_hint": "Use Switch.adaptive(value: ..., onChanged: ...).",
      "references": ["interaction.md#adaptive-controls"],
      "examples": {
        "bad": "Switch(value: on, onChanged: f)",
        "good": "Switch.adaptive(value: on, onChanged: f)"
      }
    },
    {
      "id": "code-quality/missing-const",
      "category": "code-quality",
      "severity": "info",
      "title": "Missing const constructor",
      "description": "Widgets that can be const should be const — affects rebuild performance.",
      "rationale": "Const widgets are identity-stable and skip rebuild. This is the single biggest Flutter perf win.",
      "detect": {
        "type": "lint-reuse",
        "rule": "prefer_const_constructors"
      },
      "fix_hint": "Prefix with const where all args are const.",
      "references": ["interaction.md#performance"],
      "examples": {
        "bad": "Text('Hello')",
        "good": "const Text('Hello')"
      }
    },
    {
      "id": "code-quality/missing-semantics",
      "category": "code-quality",
      "severity": "warning",
      "title": "Icon-only button missing semantic label",
      "description": "IconButton without tooltip or semanticLabel is inaccessible to screen readers.",
      "rationale": "Accessibility is not optional. TalkBack/VoiceOver users need verbal labels on icon-only controls.",
      "detect": {
        "type": "ast",
        "pattern": "IconButton(tooltip==null) OR Icon(semanticLabel==null WHERE in GestureDetector)"
      },
      "fix_hint": "Add tooltip: 'Action name' to IconButton, or wrap in Semantics(label: ...).",
      "references": ["ux-writing.md#a11y-labels"],
      "examples": {
        "bad": "IconButton(icon: Icon(Icons.close), onPressed: f)",
        "good": "IconButton(icon: Icon(Icons.close), tooltip: 'Close', onPressed: f)"
      }
    },
    {
      "id": "code-quality/missing-dispose",
      "category": "code-quality",
      "severity": "error",
      "title": "Controller created in State without dispose",
      "description": "AnimationController, TextEditingController, ScrollController etc. must be disposed.",
      "rationale": "Undisposed controllers leak memory and fire callbacks after widget unmount.",
      "detect": {
        "type": "ast",
        "pattern": "State with Controller field AND no dispose() method"
      },
      "fix_hint": "Override dispose(), call controller.dispose(), then super.dispose().",
      "references": ["motion.md#lifecycle"],
      "examples": {
        "bad": "class _S extends State { final c = AnimationController(...); }",
        "good": "class _S extends State { final c = ...; @override void dispose() { c.dispose(); super.dispose(); } }"
      }
    },
    {
      "id": "code-quality/hardcoded-strings",
      "category": "code-quality",
      "severity": "info",
      "title": "Hardcoded user-facing string",
      "description": "Text('Welcome') is untranslatable; use AppLocalizations.of(context).welcome.",
      "rationale": "Apps that ship without i18n scaffolding have to rewrite every Text widget later. Start correct.",
      "detect": {
        "type": "ast",
        "pattern": "Text(LITERAL_STRING) WHERE literal is not empty and not debug"
      },
      "fix_hint": "Extract to ARB file and use AppLocalizations.of(context).<key>.",
      "references": ["ux-writing.md#localization"],
      "examples": {
        "bad": "Text('Welcome')",
        "good": "Text(AppLocalizations.of(context)!.welcome)"
      }
    },
    {
      "id": "code-quality/setstate-after-async",
      "category": "code-quality",
      "severity": "error",
      "title": "setState after async gap without mounted check",
      "description": "Calling setState after an await without checking mounted throws if the widget was disposed.",
      "rationale": "This is the most common crash in Flutter async code. Always guard.",
      "detect": {
        "type": "lint-reuse",
        "rule": "use_build_context_synchronously"
      },
      "fix_hint": "Guard with `if (!mounted) return;` before setState.",
      "references": ["interaction.md#async-safety"],
      "examples": {
        "bad": "await fetch(); setState(() => data = result);",
        "good": "await fetch(); if (!mounted) return; setState(() => data = result);"
      }
    },
    {
      "id": "code-quality/missing-key",
      "category": "code-quality",
      "severity": "info",
      "title": "Widget in list without Key",
      "description": "Widgets inside a list without stable keys cause incorrect state preservation on reorder.",
      "rationale": "Flutter uses position-based matching by default; keys fix identity-based matching.",
      "detect": {
        "type": "ast",
        "pattern": "ListView children OR Column children with StatefulWidget and no key"
      },
      "fix_hint": "Pass key: ValueKey(uniqueId) to list children.",
      "references": ["interaction.md#list-keys"],
      "examples": {
        "bad": "items.map((i) => TodoTile(i)).toList()",
        "good": "items.map((i) => TodoTile(key: ValueKey(i.id), i)).toList()"
      }
    },
    {
      "id": "code-quality/swallowed-errors",
      "category": "code-quality",
      "severity": "warning",
      "title": "Empty catch block",
      "description": "try { ... } catch (_) {} hides bugs and makes debugging impossible.",
      "rationale": "Errors should be logged, surfaced to the user, or rethrown — never silently swallowed.",
      "detect": {
        "type": "ast",
        "pattern": "CatchClause(body is empty Block)"
      },
      "fix_hint": "At minimum: debugPrint('$e'); Better: show SnackBar or log to crash reporter.",
      "references": ["interaction.md#error-handling"],
      "examples": {
        "bad": "try { api.call(); } catch (_) {}",
        "good": "try { api.call(); } catch (e, st) { debugPrint('$e'); reportError(e, st); }"
      }
    }
  ]
}
```

- [ ] **Step 3: Validate JSON**

```bash
python3 -c "import json; json.load(open('src/rules/rules.json'))"
```

Expected: no output (exit 0). Any parse error must be fixed before proceeding.

- [ ] **Step 4: Verify rule count**

```bash
python3 -c "import json; d=json.load(open('src/rules/rules.json')); print(len(d['rules']))"
```

Expected output: `24`

- [ ] **Step 5: Commit**

```bash
git add src/rules/rules.json
git commit -m "feat: add rules.json with 24 anti-pattern definitions"
```

---

## Task 3: Main skill entry — `src/skill/SKILL.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/SKILL.md`

- [ ] **Step 1: Create directory**

```bash
mkdir -p src/skill/references
```

- [ ] **Step 2: Write `src/skill/SKILL.md`**

```markdown
---
name: flutter-design
description: Use when writing, reviewing, or refactoring Flutter mobile UI code. Teaches Flutter-specific design principles (Material 3 + Cupertino adaptive), type scales, theming, spacing grids, motion, interaction, responsive layout, and UX writing. Prevents common Flutter AI-slop patterns like hardcoded Colors.purple, missing SafeArea, nested Container/Padding chains, Material widgets on iOS paths, missing const, and absent semantic labels.
---

# Flutter Design

You are working in a Flutter mobile project. Apply the rules below to
every widget you create, read, or modify. When the user asks for UI
work, read the relevant reference module first.

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

Twenty-one slash commands are available. Use them as explicit entry
points for specific design operations:

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
```

- [ ] **Step 3: Commit**

```bash
git add src/skill/SKILL.md
git commit -m "feat: add main SKILL.md entry"
```

---

## Task 4: Reference module — `typography.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/typography.md`

- [ ] **Step 1: Write `src/skill/references/typography.md`**

```markdown
---
name: typography
description: Flutter typography — ThemeData.textTheme, Material 3 type scale, google_fonts, line-height, font pairing, and anti-patterns to avoid.
---

# Typography

## The Material 3 type scale

Material 3 defines 15 roles across 5 size groups:

| Role          | Size | Weight | Use for                    |
|---------------|------|--------|----------------------------|
| displayLarge  | 57   | 400    | Splash/hero                |
| displayMedium | 45   | 400    | Hero                       |
| displaySmall  | 36   | 400    | Large headers              |
| headlineLarge | 32   | 400    | Section headers            |
| headlineMedium| 28   | 400    | Section headers            |
| headlineSmall | 24   | 400    | Section headers            |
| titleLarge    | 22   | 500    | Dialog, appbar title       |
| titleMedium   | 16   | 500    | List headers               |
| titleSmall    | 14   | 500    | Subtitles                  |
| bodyLarge     | 16   | 400    | Primary body copy          |
| bodyMedium    | 14   | 400    | Secondary body             |
| bodySmall     | 12   | 400    | Captions, timestamps       |
| labelLarge    | 14   | 500    | Button labels              |
| labelMedium   | 12   | 500    | Small button labels, chips |
| labelSmall    | 11   | 500    | Tabs, overlines            |

**Apply it via theme, never inline:**

```dart
// GOOD
Text('Welcome', style: Theme.of(context).textTheme.headlineMedium);

// BAD — rule visual/inline-textstyle
Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400));
```

## Setting up the text theme

Use `google_fonts` for a custom font without bundling:

```dart
// main.dart
import 'package:google_fonts/google_fonts.dart';

MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    textTheme: GoogleFonts.manropeTextTheme(),
    useMaterial3: true,
  ),
);
```

Or bundle a variable font via `pubspec.yaml` for offline-first apps:

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-VariableFont.ttf
```

```dart
ThemeData(
  textTheme: Typography.material2021().black.apply(fontFamily: 'Inter'),
);
```

## Line-height matters

Material 3 base styles already set `height` correctly. If you override
a style, preserve `height`:

```dart
// BAD — kills line-height
theme.textTheme.bodyLarge!.copyWith(fontSize: 18);

// GOOD
theme.textTheme.bodyLarge!.copyWith(fontSize: 18, height: 1.5);
```

## Anti-patterns

### Rule `visual/roboto-default`

Leaving `ThemeData()` with no `textTheme` means you get platform-default
Roboto. This is the single most common AI-slop signal in Flutter.

```dart
// BAD
MaterialApp(theme: ThemeData());

// GOOD
MaterialApp(
  theme: ThemeData(
    textTheme: GoogleFonts.interTextTheme(),
  ),
);
```

### Rule `visual/inline-textstyle`

Inline `TextStyle` bypasses the type scale and fragments design.

```dart
// BAD
Text('Hello', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600));

// GOOD
Text('Hello', style: Theme.of(context).textTheme.titleMedium);

// GOOD (with override)
Text('Hello', style: Theme.of(context).textTheme.titleMedium?.copyWith(
  color: Theme.of(context).colorScheme.primary,
));
```

## When iOS matters

iOS expects San Francisco. On Cupertino surfaces use
`CupertinoTheme.of(context).textTheme`:

```dart
CupertinoPageScaffold(
  child: Text(
    'Hello',
    style: CupertinoTheme.of(context).textTheme.textStyle,
  ),
);
```

Cross-platform? Pick a neutral font (Inter, Manrope, DM Sans) that
reads well on both. Avoid serifs for body text on small screens.

## Checklist before shipping

- [ ] `textTheme` set at `ThemeData` level — no default Roboto
- [ ] All `Text` widgets use `Theme.of(context).textTheme.*`
- [ ] No inline `TextStyle(fontSize: ...)` except for brand/display cases
- [ ] Dark theme inherits the same text theme
- [ ] Line-heights preserved on overrides
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/typography.md
git commit -m "feat: add typography reference module"
```

---

## Task 5: Reference module — `color.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/color.md`

- [ ] **Step 1: Write `src/skill/references/color.md`**

```markdown
---
name: color
description: Flutter color — ColorScheme.fromSeed, semantic tokens, dark mode, CupertinoColors, gradient discipline, and anti-patterns.
---

# Color

## Start with a seed

Material 3 derives a full accessible palette from one seed color:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4), // brand color
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);
```

And a matching dark variant:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
```

Wire them into `MaterialApp`:

```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
);
```

## Semantic tokens — always use these

Never reach for `Colors.*` directly. Use the `ColorScheme` semantic
role that matches the purpose of the color:

| Token                      | Use for                        |
|----------------------------|--------------------------------|
| `primary`                  | FAB, primary button, key brand |
| `onPrimary`                | Text/icons on primary          |
| `primaryContainer`         | Tonal filled button            |
| `onPrimaryContainer`       | Text/icons on primaryContainer |
| `secondary`                | Less-prominent accents         |
| `tertiary`                 | Contrasting accents            |
| `error`                    | Destructive actions, errors    |
| `onError`                  | Text/icons on error            |
| `surface`                  | Card, sheet, dialog background |
| `onSurface`                | Primary body text              |
| `onSurfaceVariant`         | Secondary/muted body text      |
| `outline`                  | Borders, dividers              |
| `outlineVariant`           | Subtle dividers                |
| `surfaceTint`              | M3 tonal elevation overlay     |

```dart
// GOOD
Container(
  color: Theme.of(context).colorScheme.primaryContainer,
  child: Text(
    'Hi',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
);

// BAD — rule visual/hardcoded-color
Container(
  color: Colors.purple,
  child: Text('Hi', style: TextStyle(color: Colors.white)),
);
```

## Dark mode is free — if you use the tokens

Every token above has a correctly tuned dark variant. If your code uses
only semantic tokens, dark mode works without effort. If you use
`Colors.black` anywhere, it breaks.

```dart
// BAD — rule visual/pure-black-text
Text('Hi', style: TextStyle(color: Colors.black));

// GOOD
Text('Hi', style: TextStyle(
  color: Theme.of(context).colorScheme.onSurface,
));
```

## Gradients: one rule

**No purple→pink gradients.** This is the #1 AI-slop tell. If you need
a gradient:

- Use brand-derived colors only
- Use Material 3 tonal elevation (`surfaceTint` with alpha) where possible
- Keep the contrast ratio inside the gradient high enough for any
  overlaid text

```dart
// BAD — rule visual/gradient-abuse
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Colors.purple, Colors.pink]),
  ),
);

// GOOD
Container(
  color: Theme.of(context).colorScheme.surface,
);

// GOOD (if gradient is truly needed)
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primaryContainer,
      ],
    ),
  ),
);
```

## Contrast

Material 3 semantic pairs (e.g. `primary`/`onPrimary`) are designed
for WCAG AA. If you invent color pairings, check contrast with
a tool like https://webaim.org/resources/contrastchecker/.

Minimums:

- 4.5:1 for normal text
- 3:1 for large text (≥18pt or ≥14pt bold)
- 3:1 for non-text UI (icons, focus indicators)

## When iOS matters

On Cupertino surfaces, use `CupertinoColors`:

```dart
CupertinoButton(
  color: CupertinoColors.activeBlue,
  child: Text(
    'Tap',
    style: TextStyle(color: CupertinoColors.white),
  ),
  onPressed: () {},
);
```

For cross-platform screens, `ColorScheme` works on both — Cupertino
widgets inherit colors from it via adaptive constructors.

## Checklist

- [ ] `ColorScheme.fromSeed` at theme level
- [ ] Dark theme variant defined
- [ ] No `Colors.purple`, `Colors.pink`, `Color(0xFF...)` outside theme setup
- [ ] No `Colors.black` or `Colors.white` for text
- [ ] All text uses an `on*` token appropriate for its background
- [ ] No purple→pink gradients
- [ ] Contrast ratios verified for custom pairings
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/color.md
git commit -m "feat: add color reference module"
```

---

## Task 6: Reference module — `spacing.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/spacing.md`

- [ ] **Step 1: Write `src/skill/references/spacing.md`**

```markdown
---
name: spacing
description: Flutter spacing and layout hygiene — 4/8pt grid, EdgeInsets decision tree, SafeArea, notch handling, widget economy, card hierarchy, elevation.
---

# Spacing

## The 4/8pt grid

All padding and margin values must align to a 4pt grid. Allowed values:

```
0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 120
```

Extract them as const tokens in a theme extension:

```dart
// lib/theme/spacing.dart
class Spacing extends ThemeExtension<Spacing> {
  final double xs, sm, md, lg, xl, xxl;
  const Spacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
  });

  @override
  Spacing copyWith({...}) => Spacing(...);
  @override
  Spacing lerp(Spacing? other, double t) => this;
}

// Register on ThemeData
ThemeData(
  extensions: const [Spacing()],
);

// Use it
final s = Theme.of(context).extension<Spacing>()!;
Padding(padding: EdgeInsets.all(s.md));
```

## Anti-pattern: magic numbers

```dart
// BAD — rule layout/magic-numbers
Padding(padding: EdgeInsets.all(17));

// GOOD
Padding(padding: EdgeInsets.all(16));
```

## EdgeInsets decision tree

- All four sides equal? → `EdgeInsets.all(n)`
- Horizontal + vertical different? → `EdgeInsets.symmetric(horizontal: h, vertical: v)`
- Only one/two sides? → `EdgeInsets.only(left: l, top: t)`
- Never use `.fromLTRB` unless all four are different

## SafeArea is not optional

Any `Scaffold` body without an `AppBar` needs `SafeArea`. This applies
`MediaQuery.padding` to keep content out of status bar, notch, home
indicator, and gesture inset regions.

```dart
// BAD — rule layout/missing-safearea
Scaffold(
  body: Column(children: [
    Text('Welcome'), // rendered under notch on iPhone X+
  ]),
);

// GOOD
Scaffold(
  body: SafeArea(
    child: Column(children: [
      Text('Welcome'),
    ]),
  ),
);
```

For finer control:

```dart
SafeArea(
  top: true,
  bottom: false,
  child: ...,
);
```

## Widget economy

Don't stack widgets that do the same thing:

```dart
// BAD — rule layout/nested-padding
Padding(
  padding: EdgeInsets.all(16),
  child: Container(
    padding: EdgeInsets.all(8),
    child: Text('Hi'),
  ),
);

// GOOD
Container(
  padding: EdgeInsets.all(16),
  child: Text('Hi'),
);
```

Rules of thumb:

- `Container` with no decoration → use `Padding` or `SizedBox`
- `Padding` inside a `Container(padding)` → merge
- `Center` inside a `Column(mainAxisAlignment: center)` → drop `Center`
- `Column(children: [SizedBox(height: X), ...])` everywhere → use a
  `Column.separated`-style helper

## Card hierarchy

```dart
// BAD — rule visual/nested-cards
Card(
  child: Card(
    child: ListTile(title: Text('x')),
  ),
);

// GOOD
Card(
  child: ListTile(title: Text('x')),
);
```

One card per surface. Use `ListTile`, `Divider`, or a nested `Column`
with internal padding for structure within a single card.

## Elevation

Material 3 prefers tonal elevation (`surfaceTint`) over shadow.
Don't exceed elevation 4 on stationary surfaces:

```dart
// BAD — rule visual/shadow-overuse
Card(elevation: 16, child: ...);

// GOOD
Card(elevation: 1, child: ...);
```

Elevation guidance:

- 0 → flat on background
- 1 → cards
- 3 → raised cards
- 6 → FAB, bottom sheet
- 8 → modal bottom sheet, dialog
- >8 → reserved for dragged/elevated content

## When iOS matters

Cupertino rarely uses elevation. On iOS surfaces, rely on dividers
(`CupertinoListSection`) rather than shadows.

## Checklist

- [ ] All padding/margin values on the 4/8pt grid
- [ ] Spacing tokens defined as theme extension or const
- [ ] Every `Scaffold` body without `AppBar` uses `SafeArea`
- [ ] No `Container` wrapping `Padding` wrapping `Container`
- [ ] No nested `Card` widgets
- [ ] Elevation ≤ 8
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/spacing.md
git commit -m "feat: add spacing reference module"
```

---

## Task 7: Reference module — `motion.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/motion.md`

- [ ] **Step 1: Write `src/skill/references/motion.md`**

```markdown
---
name: motion
description: Flutter motion — AnimationController lifecycle, Curves, Tween, Hero, implicit animations, duration tokens, and disposal discipline.
---

# Motion

## Duration tokens

Three canonical durations cover ~95% of UI animation:

```dart
class Durations {
  static const fast = Duration(milliseconds: 150);     // press feedback, small state changes
  static const medium = Duration(milliseconds: 250);   // element entry/exit, sheet open
  static const slow = Duration(milliseconds: 400);     // page transition, hero
}
```

Anything above 400ms feels sluggish. Anything below 100ms reads as
instantaneous (use 0 instead).

## Curves — prefer easing

```dart
// GOOD (standard Material)
Curves.easeOutCubic        // entry
Curves.easeInCubic         // exit
Curves.easeInOutCubic      // bidirectional
Curves.fastOutSlowIn       // Material standard easing

// BAD
Curves.linear              // reads as janky / unfinished
```

## Implicit animations — the easy win

For single-property transitions, use `AnimatedContainer`,
`AnimatedOpacity`, `AnimatedSwitcher`, `AnimatedAlign`, etc. No
controller needed:

```dart
AnimatedContainer(
  duration: Durations.medium,
  curve: Curves.easeOutCubic,
  color: selected ? colors.primaryContainer : colors.surface,
  padding: EdgeInsets.all(selected ? 24 : 16),
  child: Text('Tap me'),
);
```

## Explicit animations — controller lifecycle

For complex sequences use `AnimationController`. **You must dispose it.**

```dart
class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Durations.medium,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();        // REQUIRED — rule code-quality/missing-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      child: const Text('Hello'),
    );
  }
}
```

## Hero transitions

For element continuity across screens:

```dart
// List screen
Hero(
  tag: 'avatar-${user.id}',
  child: CircleAvatar(backgroundImage: NetworkImage(user.photo)),
);

// Detail screen — SAME tag
Hero(
  tag: 'avatar-${user.id}',
  child: CircleAvatar(radius: 60, backgroundImage: NetworkImage(user.photo)),
);
```

Tag must be unique per hero pair per route stack.

## AnimatedSwitcher for content swaps

```dart
AnimatedSwitcher(
  duration: Durations.fast,
  child: loading
    ? const CircularProgressIndicator(key: ValueKey('loading'))
    : Text(data, key: const ValueKey('data')),
);
```

The children need distinct `Key`s so the switcher knows to transition.

## Performance: animate with AnimatedBuilder, not setState

```dart
// BAD — rebuilds entire subtree each frame
controller.addListener(() => setState(() {}));

// GOOD — rebuilds only what needs it
AnimatedBuilder(
  animation: controller,
  builder: (context, child) => Transform.rotate(
    angle: controller.value * 2 * pi,
    child: child,
  ),
  child: const Icon(Icons.refresh),  // built once
);
```

## Accessibility: respect reduced motion

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;

AnimatedContainer(
  duration: reduceMotion ? Duration.zero : Durations.medium,
  ...
);
```

## When iOS matters

iOS uses more subtle, springier motion. Use
`CupertinoPageRoute` for pushes (native iOS slide). For custom
springs, use `Curves.easeOutBack` sparingly.

## Checklist

- [ ] Durations from the canonical set (150/250/400)
- [ ] No `Curves.linear` for UI animations
- [ ] Every `AnimationController` is disposed in `dispose()`
- [ ] Hero tags are unique per pair
- [ ] Heavy animations use `AnimatedBuilder`, not `setState`
- [ ] Reduced-motion users are respected
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/motion.md
git commit -m "feat: add motion reference module"
```

---

## Task 8: Reference module — `interaction.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/interaction.md`

- [ ] **Step 1: Write `src/skill/references/interaction.md`**

```markdown
---
name: interaction
description: Flutter interaction — button choice, touch targets, haptics, loading/disabled/error states, async safety, error handling, navigation, list keys, performance.
---

# Interaction

## Button choice

| Widget                 | Use for                                          |
|------------------------|--------------------------------------------------|
| `FilledButton`         | Primary action (Material 3)                      |
| `FilledButton.tonal`   | Secondary action                                 |
| `OutlinedButton`       | Tertiary / destructive                           |
| `TextButton`           | Low-emphasis / dialog action                     |
| `IconButton`           | Icon-only, must have `tooltip`                   |
| `ElevatedButton`       | Legacy Material 2; prefer `FilledButton` on M3   |
| `CupertinoButton`      | iOS-only surfaces                                |
| `InkWell`              | Custom tappable container with ripple            |
| `GestureDetector`      | No ripple, custom gestures                       |

**Prefer `InkWell` over `GestureDetector`** when you want visual feedback:

```dart
// BAD — no ripple, no feedback
GestureDetector(
  onTap: open,
  child: Container(padding: EdgeInsets.all(16), child: Text('Open')),
);

// GOOD
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: open,
    child: Padding(padding: EdgeInsets.all(16), child: Text('Open')),
  ),
);
```

## Touch targets

- Material: ≥48dp × 48dp
- iOS HIG: ≥44pt × 44pt

Use `IconButton` (default 48dp) or wrap in `SizedBox(width: 48, height: 48)`:

```dart
// BAD — 24dp touch area
Icon(Icons.close, size: 24);

// GOOD
IconButton(
  icon: const Icon(Icons.close),
  tooltip: 'Close',
  onPressed: close,
);
```

## Semantic labels — rule code-quality/missing-semantics

Every icon-only interactive widget needs a tooltip or semantic label:

```dart
// BAD
IconButton(icon: Icon(Icons.close), onPressed: close);

// GOOD
IconButton(
  icon: const Icon(Icons.close),
  tooltip: 'Close',
  onPressed: close,
);
```

For non-interactive icons with meaning:

```dart
Semantics(
  label: 'Verified',
  child: const Icon(Icons.verified),
);
```

## Loading / disabled states

Any async action must show a loading indicator. Any disabled button
must be visually disabled.

```dart
class _State extends State<SaveButton> {
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await api.save();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, st) {
      if (!mounted) return;
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _loading ? null : _save,
      child: _loading
        ? const SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text('Save'),
    );
  }
}
```

## Async safety — rule code-quality/setstate-after-async

**Always guard `setState` after `await`:**

```dart
// BAD — rule code-quality/setstate-after-async
await api.fetch();
setState(() => data = result);

// GOOD
await api.fetch();
if (!mounted) return;
setState(() => data = result);
```

Same for any `BuildContext` usage:

```dart
// BAD
await api.fetch();
Navigator.of(context).pop();

// GOOD
await api.fetch();
if (!mounted) return;
Navigator.of(context).pop();
```

## Error handling — rule code-quality/swallowed-errors

```dart
// BAD
try {
  await api.call();
} catch (_) {}

// GOOD
try {
  await api.call();
} catch (e, st) {
  debugPrint('API call failed: $e');
  reportToCrashlytics(e, st);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Couldn\'t save. Try again.')),
    );
  }
}
```

## Haptics

Add subtle feedback for state-changing actions:

```dart
import 'package:flutter/services.dart';

onPressed: () {
  HapticFeedback.lightImpact();
  toggleFavorite();
}
```

Scale:
- `selectionClick` → tab/selection change
- `lightImpact` → toggle, confirm
- `mediumImpact` → page transition
- `heavyImpact` → destructive confirmation
- `vibrate` → notification

## List keys — rule code-quality/missing-key

```dart
// BAD
ListView(
  children: items.map((i) => TodoTile(item: i)).toList(),
);

// GOOD
ListView(
  children: items
    .map((i) => TodoTile(key: ValueKey(i.id), item: i))
    .toList(),
);

// BETTER for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, idx) => TodoTile(
    key: ValueKey(items[idx].id),
    item: items[idx],
  ),
);
```

## Performance

- `const` everywhere possible — rule code-quality/missing-const
- `ListView.builder` for >10 items
- `RepaintBoundary` around animated expensive subtrees
- Cache network images with `cached_network_image`

## Platform adaptation

| Widget              | Cross-platform pattern                       |
|---------------------|----------------------------------------------|
| `Switch`            | `Switch.adaptive`                            |
| `Slider`            | `Slider.adaptive`                            |
| `CircularProgress…` | `CircularProgressIndicator.adaptive`         |
| `AlertDialog`       | `showAdaptiveDialog`                         |
| `Icon`              | `Icon.adaptive` (for system-meaning icons)   |

For navigation:

```dart
Navigator.push(
  context,
  Platform.isIOS
    ? CupertinoPageRoute(builder: (_) => const Detail())
    : MaterialPageRoute(builder: (_) => const Detail()),
);
```

Or use `package:flutter_platform_widgets` for a full adaptive layer.

## When iOS matters

iOS uses `CupertinoListTile`, `CupertinoSwitch`, `CupertinoButton`.
Native iOS apps rarely use ripples — consider opacity or scale on
press instead.

## Checklist

- [ ] Every `IconButton` has a `tooltip`
- [ ] Touch targets ≥48dp / ≥44pt
- [ ] Every async action shows loading state
- [ ] Every `setState` after `await` is guarded with `mounted`
- [ ] No empty `catch` blocks
- [ ] List children have stable keys
- [ ] Haptics on meaningful state changes
- [ ] `.adaptive` constructors used where available
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/interaction.md
git commit -m "feat: add interaction reference module"
```

---

## Task 9: Reference module — `responsive.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/responsive.md`

- [ ] **Step 1: Write `src/skill/references/responsive.md`**

```markdown
---
name: responsive
description: Flutter responsive layout — LayoutBuilder, MediaQuery, Material 3 breakpoints, Flex children, constraint propagation, overflow avoidance.
---

# Responsive

## Breakpoints

Material 3 defines three window-size classes. For mobile, you'll
usually target the first two:

| Class    | Width       | Typical device                  |
|----------|-------------|---------------------------------|
| Compact  | <600dp      | Phones (portrait)               |
| Medium   | 600-839dp   | Phones (landscape), small tablet|
| Expanded | 840-1199dp  | Large tablets, foldables open   |

```dart
class Breakpoints {
  static const compact = 600.0;
  static const medium = 840.0;
}

enum WindowSize { compact, medium, expanded }

WindowSize windowSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < Breakpoints.compact) return WindowSize.compact;
  if (w < Breakpoints.medium) return WindowSize.medium;
  return WindowSize.expanded;
}
```

## LayoutBuilder for adaptive structure

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.compact) {
      return const _SingleColumn();
    }
    return const _TwoColumn();
  },
);
```

Use `LayoutBuilder` when the layout decision depends on the **parent's
constraints**, not the screen size. Use `MediaQuery.sizeOf(context)`
when it depends on the full screen.

## Flex children — rule layout/no-flexible

Any `Row`/`Column` child whose size depends on content must be
`Flexible` or `Expanded`:

```dart
// BAD — overflows if name is long
Row(
  children: [
    const Icon(Icons.person),
    Text(user.name),
  ],
);

// GOOD
Row(
  children: [
    const Icon(Icons.person),
    const SizedBox(width: 8),
    Flexible(child: Text(user.name, overflow: TextOverflow.ellipsis)),
  ],
);
```

`Flexible` = takes available space, but not more than it needs.
`Expanded` = takes all available space (equivalent to `Flexible(flex: 1, fit: FlexFit.tight)`).

## Fixed widths are suspicious — rule layout/hardcoded-width

```dart
// BAD — breaks on small phones
Container(width: 300, child: Text('long content...'));

// GOOD
Expanded(child: Text('long content...'));
```

Exceptions:
- Icons, avatars, and other intrinsically sized elements
- Buttons with a standard width from the design system
- Images with explicit `AspectRatio`

## Wrap for variable-count items

```dart
// BAD — overflows with many chips
Row(children: chips);

// GOOD
Wrap(spacing: 8, runSpacing: 8, children: chips);
```

## Infinite constraints in Row — rule layout/fixed-row-overflow

```dart
// BAD — Row has tight width, SizedBox wants infinite
Row(
  children: [
    SizedBox(width: double.infinity, child: Text('x')),
  ],
);

// GOOD
Row(
  children: [
    Expanded(child: Text('x')),
  ],
);
```

## Scrolling as a safety net

For any content that might exceed the screen (forms, long text,
keyboard-sensitive layouts):

```dart
SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [...]),
  ),
);
```

For forms, also handle the keyboard:

```dart
Scaffold(
  resizeToAvoidBottomInset: true,  // default true
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: _form,
    ),
  ),
);
```

## Orientation

```dart
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.portrait
      ? const _PortraitLayout()
      : const _LandscapeLayout();
  },
);
```

Use sparingly — usually breakpoint-based layout is better than
orientation-based.

## Foldables

Foldable devices can change size mid-session. Rebuild on size changes
via `LayoutBuilder` or listen to `WidgetsBindingObserver.didChangeMetrics`.

## When iOS matters

`CupertinoPageScaffold` works with responsive widths, but Cupertino
doesn't have a native "master-detail" pattern. On iPad, consider a
custom two-column layout with `Row`.

## Checklist

- [ ] Breakpoint tokens defined once, reused
- [ ] `Row`/`Column` children with variable content use `Flexible`/`Expanded`
- [ ] No hardcoded `Container(width: X)` in layout code
- [ ] Forms wrapped in `SingleChildScrollView` + `SafeArea`
- [ ] `Wrap` for variable-count chip rows
- [ ] Breakpoint logic uses `LayoutBuilder` or `MediaQuery.sizeOf`
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/responsive.md
git commit -m "feat: add responsive reference module"
```

---

## Task 10: Reference module — `ux-writing.md`

**Files:**
- Create: `/Users/arif.ariyan/Documents/Development/ai/klamben/src/skill/references/ux-writing.md`

- [ ] **Step 1: Write `src/skill/references/ux-writing.md`**

```markdown
---
name: ux-writing
description: Flutter UX writing — button labels, error messages, empty states, i18n via flutter_localizations and ARB, accessibility labels.
---

# UX Writing

## Button labels

Use **verb + object**, not generic text:

```dart
// BAD
FilledButton(onPressed: save, child: Text('Submit'));
FilledButton(onPressed: save, child: Text('OK'));

// GOOD
FilledButton(onPressed: save, child: Text('Save changes'));
FilledButton(onPressed: pay, child: Text('Pay \$12.99'));
```

For destructive actions, be explicit:

```dart
TextButton(
  onPressed: deleteAll,
  child: Text('Delete 42 items', style: TextStyle(color: colors.error)),
);
```

## Error messages — cause → fix

```dart
// BAD
'Error occurred'
'Something went wrong'
'Failed'

// GOOD
'Couldn\'t save. Check your connection and try again.'
'Email is already in use. Try signing in instead.'
'Payment declined. Try a different card.'
```

Three-part structure:

1. What happened (plain language)
2. Why (if known)
3. What to do next

## Empty states

Every list/grid screen needs a non-empty "empty" state:

```dart
if (items.isEmpty) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 64),
        const SizedBox(height: 16),
        Text('No items yet', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Tap + to add your first item',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
```

## Loading states

Prefer skeleton loaders over spinners for layouts:

```dart
loading
  ? const _SkeletonList()   // matches the shape of loaded content
  : _ItemList(items: items);
```

Use a spinner only for actions (saving, posting).

## Localize from day one — rule code-quality/hardcoded-strings

Set up `flutter_localizations` + `intl` in the first commit of any app:

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

Create `l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

`lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "welcome": "Welcome",
  "save": "Save changes",
  "deleteConfirm": "Delete {count, plural, =1{1 item} other{{count} items}}?",
  "@deleteConfirm": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

Use it:

```dart
// BAD — rule code-quality/hardcoded-strings
Text('Welcome');

// GOOD
Text(AppLocalizations.of(context)!.welcome);
```

## Pluralization

Always use ICU message syntax for counts:

```json
"deleteConfirm": "Delete {count, plural, =1{1 item} other{{count} items}}?"
```

```dart
Text(AppLocalizations.of(context)!.deleteConfirm(count));
```

## Accessibility labels

Screen readers need clear descriptions:

```dart
Semantics(
  label: 'Profile photo of ${user.name}',
  image: true,
  child: CircleAvatar(backgroundImage: NetworkImage(user.photo)),
);
```

Hide decorative elements:

```dart
Semantics(
  excludeSemantics: true,
  child: Image.asset('assets/decorative-wave.png'),
);
```

## Capitalization

- Button labels: Sentence case ('Save changes', not 'Save Changes')
- Titles: Sentence case on Android, Title Case on iOS
- Errors: Sentence case, ending with a period

Use `.adaptiveCapitalization()` helpers if you need both.

## Length limits

- Button labels: ≤20 characters
- Empty-state headlines: ≤4 words
- Error messages: ≤1 sentence (plus optional second clarifying sentence)

## When iOS matters

iOS conventions:
- Dialog titles: Title Case
- Destructive action: red text, leftmost in iOS dialog
- "Cancel" is always present and first

Cupertino dialogs handle this automatically with
`CupertinoAlertDialog`.

## Checklist

- [ ] No generic "Submit" / "OK" / "Error occurred"
- [ ] Every error message has a cause and a next step
- [ ] Every list screen has a meaningful empty state
- [ ] `flutter_localizations` wired up before shipping
- [ ] All user-facing strings in ARB files
- [ ] Pluralization via ICU syntax, not if/else
- [ ] Screen reader labels on avatars, icons, and images with meaning
```

- [ ] **Step 2: Commit**

```bash
git add src/skill/references/ux-writing.md
git commit -m "feat: add ux-writing reference module"
```

---

## Task 11: Commands — assessment category (4 files)

**Files:**
- Create: `src/commands/audit.md`
- Create: `src/commands/critique.md`
- Create: `src/commands/check-a11y.md`
- Create: `src/commands/check-platform.md`

- [ ] **Step 1: Create directory**

```bash
mkdir -p src/commands
```

- [ ] **Step 2: Write `src/commands/audit.md`**

```markdown
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
```

- [ ] **Step 3: Write `src/commands/critique.md`**

```markdown
---
name: critique
description: Subjective UX and visual hierarchy review of a screen widget. Comments on affordance, spacing, copy, and layout balance. Read-only.
trigger: /critique <file or widget>
reads: [skill/references/]
writes: false
---

# /critique

Subjective UX critique of a screen or widget. Not a linter — a design
review.

## When to use

- User asks "how does this look" / "is this good UX" / "what would you change"
- Before a visual design review
- After `/audit` is clean but the UX still feels off

## Process

1. Read the target widget file
2. Build a mental model of the rendered layout (visual hierarchy, grouping, flow)
3. Apply principles from `skill/references/` (especially spacing,
   typography, interaction, ux-writing)
4. Review for:
   - **Hierarchy:** Is the primary action obvious? Is less-important
     content visually recessed?
   - **Grouping:** Are related elements close? Are unrelated
     elements separated?
   - **Affordance:** Is it clear what's tappable? Are disabled states
     distinguishable?
   - **Copy:** Are button labels verbs? Are errors actionable?
   - **Flow:** Does the user's eye follow a sensible path?
5. **Do not modify any file.** Write comments only.

## Output format

```
Critique of home_screen.dart

HIERARCHY
- "Save" is the primary action but rendered as OutlinedButton.
  Consider FilledButton to match its importance.
- Card headers all use titleMedium — consider titleLarge for the top
  one to create a clear anchor.

GROUPING
- Name field and avatar are visually distant. Moving avatar above name
  would match user mental model ("this is about [person]").

AFFORDANCE
- The gray row at L47 has an onTap but no ripple or chevron.
  Users won't know it's tappable. Add InkWell + trailing chevron icon.

COPY
- Button "Submit" (L62) → "Send feedback"
- Error "Try again" (L89) → "Couldn't send. Check your connection and
  try again."

FLOW
- The save CTA is below the fold on small phones. Sticky it to the
  bottom or move it above the optional fields.
```
```

- [ ] **Step 4: Write `src/commands/check-a11y.md`**

```markdown
---
name: check-a11y
description: Accessibility audit — Semantics labels, contrast ratios, touch target sizes, screen reader flow. Read-only.
trigger: /check-a11y [path]
reads: [rules/rules.json, skill/references/interaction.md, skill/references/color.md, skill/references/ux-writing.md]
writes: false
---

# /check-a11y

Accessibility-focused audit. Catches what `/audit` doesn't always
surface.

## When to use

- Before shipping any user-facing screen
- After a layout change
- User asks "is this accessible" / "check a11y"

## Checks

1. **Semantic labels** — IconButton without tooltip, Image.asset
   without Semantics label, tappable Container without accessible name
2. **Touch targets** — Interactive elements <48dp/44pt
3. **Contrast** — Text color vs background (flag obvious fails:
   `Colors.grey` on `Colors.white`, custom pairs)
4. **Focus order** — Form fields in visual order, no trapped focus
5. **Scaled text** — Text that would overflow at `textScaleFactor = 2.0`
6. **Reduced motion** — Animations that ignore `MediaQuery.disableAnimations`
7. **Screen reader labels** — Semantics exclusion on decorative images,
   label on meaningful ones

## Output format

```
A11y check for lib/screens/settings.dart

CRITICAL (2)
  11:7  IconButton(Icons.close) missing tooltip
  24:15 Icon(Icons.warning) standalone — no accessible name

WARNING (3)
  33:8  Tap target 32×32 on reminder toggle — needs ≥48dp
  47:11 Text('Reminder') on Color(0xFFCCCCCC) bg — 2.8:1 (needs 4.5:1)
  62:4  Text widget will overflow Row at textScaleFactor=2.0

OK
- Form fields in visual order
- No trapped focus
- Navigation respects reduced motion

5 issues (2 critical, 3 warning).
```

## Do NOT

- Fix the issues automatically — this is read-only
- Suggest rewriting unrelated code
- Skip silent issues (tooltip absence is *silent* but critical)
```

- [ ] **Step 5: Write `src/commands/check-platform.md`**

```markdown
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
```

- [ ] **Step 6: Commit**

```bash
git add src/commands/audit.md src/commands/critique.md src/commands/check-a11y.md src/commands/check-platform.md
git commit -m "feat: add assessment commands (audit, critique, check-a11y, check-platform)"
```

---

## Task 12: Commands — refinement category (4 files)

**Files:**
- Create: `src/commands/normalize.md`
- Create: `src/commands/polish.md`
- Create: `src/commands/distill.md`
- Create: `src/commands/harden.md`

- [ ] **Step 1: Write `src/commands/normalize.md`**

```markdown
---
name: normalize
description: Pull hardcoded values (colors, spacing, text styles) into theme tokens. Replaces magic numbers with semantic references.
trigger: /normalize [path]
reads: [rules/rules.json, skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /normalize

Hoist hardcoded values into theme. Edits files.

## When to use

- After `/audit` flags visual/hardcoded-color, visual/inline-textstyle,
  or layout/magic-numbers
- When preparing a screen for dark mode
- Before a rebrand

## Process

1. Find hardcoded colors (`Colors.X`, `Color(0xFF...)`)
   - Replace with `Theme.of(context).colorScheme.<semantic>`
   - If no semantic exists in the current theme, add it to the theme
     extension
2. Find inline `TextStyle` with literal `fontSize`
   - Replace with `Theme.of(context).textTheme.<role>` (+ `.copyWith`
     if overrides needed)
3. Find magic-number EdgeInsets (17, 23, etc.)
   - Snap to nearest 4/8 grid value
   - Extract repeated values to `Spacing` theme extension tokens
4. Verify theme is set at `MaterialApp` level; add if missing
5. Show the diff

## Output

```
normalize lib/screens/home.dart

- Container(color: Colors.purple)
+ Container(color: Theme.of(context).colorScheme.primary)

- TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
+ Theme.of(context).textTheme.titleMedium

- EdgeInsets.all(17)
+ EdgeInsets.all(16)

3 replacements in 1 file.
```

## Do NOT

- Change visual behavior (swap primary for secondary arbitrarily)
- Add new widgets or restructure layout
- Invent semantic tokens without user confirmation
```

- [ ] **Step 2: Write `src/commands/polish.md`**

```markdown
---
name: polish
description: Final pre-ship refinement. Adds const, fixes key hygiene, removes dead code, tightens copy. Safe edits only.
trigger: /polish [path]
reads: [rules/rules.json]
writes: true
---

# /polish

Last-mile cleanup before shipping. Only safe, mechanical changes.

## When to use

- Before creating a PR
- Before merging to main
- After `/audit` shows only info-level issues

## Actions

1. Add `const` to every eligible constructor (respects
   `prefer_const_constructors` lint)
2. Add `key: ValueKey(...)` to list children that lack keys
3. Remove unused imports
4. Remove commented-out code blocks
5. Tighten button labels and error messages (generic → specific)
6. Add trailing commas to multi-line arg lists (for consistent formatting)

## Do NOT

- Refactor logic
- Restructure widgets
- Rename variables
- Touch tests unless they break from the edits above

## Output

```
polish lib/screens/home.dart

+ const Text('Welcome')
+ const SizedBox(height: 16)
- // TODO: remove this old code
- Container(child: ... // unused)
- 'Submit' → 'Save changes'

8 edits in 1 file.
Run tests before committing.
```
```

- [ ] **Step 3: Write `src/commands/distill.md`**

```markdown
---
name: distill
description: Reduce widget nesting and extract repeated trees into named widgets. Flattens Container/Padding/Container chains.
trigger: /distill [path]
reads: [rules/rules.json, skill/references/spacing.md]
writes: true
---

# /distill

Collapse redundant widgets and extract duplication.

## When to use

- A widget file exceeds ~200 lines
- `/audit` flags layout/nested-padding or visual/nested-cards
- A subtree repeats 3+ times

## Actions

1. **Flatten redundant wrappers:**
   - `Padding > Container > Padding` → single `Container(padding: ...)`
   - `Container > Center > Text` → `Container(alignment: Alignment.center, child: Text)`
   - `Card > Card` → single `Card` with internal structure
2. **Extract repeated subtrees** into private StatelessWidget classes
   at the bottom of the file
3. **Name extracted widgets** descriptively (`_UserRow`, not `_Row1`)
4. **Drop unused Container decorations** (empty `BoxDecoration`)

## Do NOT

- Extract widgets that appear only once (premature abstraction)
- Create public API widgets without the user asking
- Move widgets to new files (that's `/widgetize`)

## Output

```
distill lib/screens/home.dart

- Padding(padding: EdgeInsets.all(16),
-   child: Container(padding: EdgeInsets.all(16), child: Text('Hi')))
+ Container(padding: EdgeInsets.all(32), child: Text('Hi'))

Extracted 3 repeated _UserRow subtrees into class _UserRow at L187.

4 collapses, 1 extraction.
```
```

- [ ] **Step 4: Write `src/commands/harden.md`**

```markdown
---
name: harden
description: Add loading/error/empty states, mounted guards, disposal, null safety tightening. Makes screens production-ready.
trigger: /harden [path]
reads: [rules/rules.json, skill/references/interaction.md]
writes: true
---

# /harden

Prep a screen for production. Add the safety scaffolding most AI-
generated code misses.

## When to use

- Taking a prototype to production
- After `/audit` shows errors in code-quality category
- Before a real-user launch

## Actions

1. **Loading states:** Any async button/action gets a `_loading` flag
   and disabled-while-loading UI
2. **Error states:** Wrap async calls in try/catch; show user-facing
   error (SnackBar or inline); log to `debugPrint`
3. **Empty states:** Any list screen gets a meaningful empty state
4. **Mounted guards:** Every `setState` or `context` use after `await`
   gets `if (!mounted) return;`
5. **Dispose:** Every `*Controller` field in `State` gets disposed in
   `dispose()`
6. **Null safety:** `!` → explicit null check where possible
7. **Swallowed errors:** Empty `catch (_)` → logged + reported

## Output

```
harden lib/screens/home.dart

+ late bool _loading = false;
+ try/catch around api.save() with user-facing SnackBar on error
+ if (!mounted) return; guards on 3 async methods
+ @override void dispose() { _controller.dispose(); super.dispose(); }
+ Empty state widget when items.isEmpty

8 safety additions.
Run tests before committing.
```

## Do NOT

- Change business logic
- Add features the user didn't ask for
- Touch unrelated screens
```

- [ ] **Step 5: Commit**

```bash
git add src/commands/normalize.md src/commands/polish.md src/commands/distill.md src/commands/harden.md
git commit -m "feat: add refinement commands (normalize, polish, distill, harden)"
```

---

## Task 13: Commands — enhancement category (6 files)

**Files:**
- Create: `src/commands/animate.md`
- Create: `src/commands/colorize.md`
- Create: `src/commands/typeset.md`
- Create: `src/commands/arrange.md`
- Create: `src/commands/delight.md`
- Create: `src/commands/optimize.md`

- [ ] **Step 1: Write `src/commands/animate.md`**

```markdown
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
```

- [ ] **Step 2: Write `src/commands/colorize.md`**

```markdown
---
name: colorize
description: Apply ColorScheme.fromSeed + semantic tokens throughout. Generates matching dark theme.
trigger: /colorize [seed color or path]
reads: [rules/rules.json, skill/references/color.md]
writes: true
---

# /colorize

Give a project a coherent color system from one seed.

## When to use

- Starting a new app
- Rebranding an existing app
- After `/normalize` flags widespread hardcoded colors

## Actions

1. **Derive scheme:** `ColorScheme.fromSeed(seedColor: <user input>, brightness: light)`
2. **Dark variant:** Same seed, `brightness: dark`
3. **Wire both** into `MaterialApp.theme` / `darkTheme` / `themeMode: system`
4. **Replace hardcoded colors** in the target path with semantic tokens
5. **Flag** any pair that can't be mapped automatically (custom brand
   accent that doesn't fit a scheme role)

## Interaction

If no seed given, ask the user for their brand color. Default suggestion:
`const Color(0xFF6750A4)` (Material 3 default indigo).

## Do NOT

- Invent multi-color branding without confirmation
- Touch assets (SVGs, images)
```

- [ ] **Step 3: Write `src/commands/typeset.md`**

```markdown
---
name: typeset
description: Install google_fonts, wire type scale, fix weights and line heights.
trigger: /typeset [font name or path]
reads: [rules/rules.json, skill/references/typography.md]
writes: true
---

# /typeset

Escape default Roboto. Wire a proper type system.

## When to use

- New project
- `/audit` flags visual/roboto-default
- Rebrand

## Actions

1. **Add `google_fonts`** to `pubspec.yaml` if missing
2. **Set `textTheme`** on `ThemeData` with `GoogleFonts.<font>TextTheme()`
3. **Font choice** — if user doesn't specify, recommend one of:
   - **Inter** (neutral, modern, safe bet)
   - **Manrope** (friendly, tech-forward)
   - **DM Sans** (geometric, editorial feel)
4. **Fix inline TextStyle** — replace with `Theme.of(context).textTheme.*`
5. **Check line-heights** — ensure overrides preserve `height`

## Interaction

If no font given, ask. Show the 3 recommended options and why.

## Do NOT

- Bundle a font via assets unless user explicitly asks (google_fonts
  CDN-loads by default)
- Change to a serif for body text
```

- [ ] **Step 4: Write `src/commands/arrange.md`**

```markdown
---
name: arrange
description: Fix layout — responsive breakpoints, SafeArea, LayoutBuilder, overflow guards.
trigger: /arrange [path]
reads: [rules/rules.json, skill/references/responsive.md, skill/references/spacing.md]
writes: true
---

# /arrange

Fix broken layout.

## When to use

- RenderFlex overflow errors
- `/audit` flags layout/* rules
- Layout breaks on small phones or foldables
- Content renders under notch or home indicator

## Actions

1. **SafeArea:** Wrap `Scaffold` body if no `AppBar`
2. **Flex children:** Wrap variable-content `Row`/`Column` children
   in `Flexible`/`Expanded`
3. **Remove fixed widths:** `Container(width: 300)` → `Expanded` or
   `FractionallySizedBox`
4. **Add scroll fallback:** `SingleChildScrollView` for long content
5. **Breakpoint adaptation:** Use `LayoutBuilder` for screens that
   should adapt to foldable/tablet widths
6. **Keyboard handling:** `resizeToAvoidBottomInset: true` (default)
   + `MediaQuery.viewInsetsOf` for bottom padding on forms

## Do NOT

- Rewrite layout semantics
- Add a drawer unless user asks
- Change navigation structure
```

- [ ] **Step 5: Write `src/commands/delight.md`**

```markdown
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
```

- [ ] **Step 6: Write `src/commands/optimize.md`**

```markdown
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
```

- [ ] **Step 7: Commit**

```bash
git add src/commands/animate.md src/commands/colorize.md src/commands/typeset.md src/commands/arrange.md src/commands/delight.md src/commands/optimize.md
git commit -m "feat: add enhancement commands (animate, colorize, typeset, arrange, delight, optimize)"
```

---

## Task 14: Commands — specialized category (7 files)

**Files:**
- Create: `src/commands/adapt.md`
- Create: `src/commands/theme-init.md`
- Create: `src/commands/widgetize.md`
- Create: `src/commands/localize.md`
- Create: `src/commands/form.md`
- Create: `src/commands/empty-state.md`
- Create: `src/commands/icon-set.md`

- [ ] **Step 1: Write `src/commands/adapt.md`**

```markdown
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
```

- [ ] **Step 2: Write `src/commands/theme-init.md`**

```markdown
---
name: theme-init
description: Bootstrap a full ThemeData — ColorScheme, TextTheme, extensions — from a seed color.
trigger: /theme-init [seed color]
reads: [rules/rules.json, skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /theme-init

Generate a theme scaffold for a new project.

## Actions

1. Create `lib/theme/app_theme.dart` with:
   - `ColorScheme.fromSeed` for light and dark
   - `TextTheme` via `google_fonts` (ask user for font; default Inter)
   - `Spacing` theme extension
   - Full `ThemeData.light()` and `ThemeData.dark()` builders
2. Wire into `MaterialApp` in `lib/main.dart`
3. Create `lib/theme/spacing.dart` with the `Spacing` extension class
4. Create `lib/theme/motion.dart` with `Durations` tokens

## Interaction

Ask user:
- Seed color (default `0xFF6750A4`)
- Font (default Inter)

## Output

List every file created + diff summary.
```

- [ ] **Step 3: Write `src/commands/widgetize.md`**

```markdown
---
name: widgetize
description: Extract inline widget trees into named StatelessWidget classes with documented params.
trigger: /widgetize [widget or file]
reads: [rules/rules.json, skill/references/spacing.md]
writes: true
---

# /widgetize

Extract a subtree into a reusable widget class.

## When to use

- A build method exceeds ~100 lines
- Same tree repeats 3+ times
- Prep for testing an isolated component

## Actions

1. Identify the target subtree
2. Create a new private `StatelessWidget` (or `StatefulWidget` if
   it has state) in the same file, below the parent class
3. Pass captured variables as constructor parameters
4. Add dartdoc to the new class
5. Replace the inline tree with a call to the new widget

## Do NOT

- Move widgets to new files (unless the file is > 500 lines)
- Make widgets public without user confirmation
- Extract one-use widgets (YAGNI)
```

- [ ] **Step 4: Write `src/commands/localize.md`**

```markdown
---
name: localize
description: Wire flutter_localizations + intl, extract hardcoded strings to ARB files.
trigger: /localize [path]
reads: [rules/rules.json, skill/references/ux-writing.md]
writes: true
---

# /localize

Add i18n scaffolding to a project that doesn't have it.

## Actions

1. Add `flutter_localizations` and `intl` to `pubspec.yaml`
2. Set `flutter: generate: true`
3. Create `l10n.yaml` with ARB paths
4. Create `lib/l10n/app_en.arb` with seed strings
5. Update `MaterialApp` with `localizationsDelegates` and `supportedLocales`
6. Walk the target path, replace hardcoded `Text('...')` strings with
   `AppLocalizations.of(context)!.<key>` and add keys to the ARB

## Do NOT

- Translate to other languages (user's job)
- Rewrite copy while extracting (keep semantically identical)
- Extract debug strings (e.g. `debugPrint`)
```

- [ ] **Step 5: Write `src/commands/form.md`**

```markdown
---
name: form
description: Build a validated form with TextFormField, error states, focus flow, and correct keyboard types.
trigger: /form [description or path]
reads: [rules/rules.json, skill/references/interaction.md, skill/references/ux-writing.md]
writes: true
---

# /form

Generate a production-grade form.

## Actions

1. Use `Form` + `GlobalKey<FormState>` for validation
2. `TextFormField` per field with `validator`
3. Correct `keyboardType` per field (email, number, phone, multiline)
4. `textInputAction` for focus flow (next, done)
5. `FocusNode` wiring for next-field
6. Error messages from `/ux-writing.md` style (specific, actionable)
7. Submit button with loading state, disabled while invalid
8. `SingleChildScrollView` + keyboard inset padding
9. Success → `/harden`-style error handling

## Do NOT

- Use third-party form packages unless user asks
- Persist state without being told where
- Add analytics hooks
```

- [ ] **Step 6: Write `src/commands/empty-state.md`**

```markdown
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
```

- [ ] **Step 7: Write `src/commands/icon-set.md`**

```markdown
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

1. Add the chosen icon package to `pubspec.yaml`
2. Walk target path, replace `Icon(Icons.X)` with the new package's
   equivalent (ask user if ambiguous)
3. For SVG assets, wire `flutter_svg` and move SVGs to `assets/icons/`
4. Update `pubspec.yaml` assets section
5. Maintain size and semantics — tooltip/semanticLabel preserved

## Do NOT

- Invent icon names
- Replace icons that have platform meaning (e.g. platform back arrow)
```

- [ ] **Step 8: Commit**

```bash
git add src/commands/adapt.md src/commands/theme-init.md src/commands/widgetize.md src/commands/localize.md src/commands/form.md src/commands/empty-state.md src/commands/icon-set.md
git commit -m "feat: add specialized commands (adapt, theme-init, widgetize, localize, form, empty-state, icon-set)"
```

---

## Task 15: Build script scaffold — `tool/pubspec.yaml` + entry file

**Files:**
- Create: `tool/pubspec.yaml`
- Create: `tool/build.dart`

- [ ] **Step 1: Create directory and `tool/pubspec.yaml`**

```bash
mkdir -p tool
```

`tool/pubspec.yaml`:

```yaml
name: klamben_build
description: Build script that fans out canonical skill + commands to harness-specific layouts.
publish_to: none
version: 0.0.1

environment:
  sdk: ^3.3.0

dependencies:
  path: ^1.9.0
  yaml: ^3.1.2

dev_dependencies:
  test: ^1.25.0
  lints: ^4.0.0
```

- [ ] **Step 2: Write minimal `tool/build.dart`**

```dart
// tool/build.dart
//
// Fans out canonical src/ files to harness-specific build/<harness>/
// layouts. Sub-plan 1 ships claude-only; later sub-plans add the other
// harnesses.

import 'dart:io';
import 'package:path/path.dart' as p;

const repoRoot = '.';
const srcSkillDir = 'src/skill';
const srcCommandsDir = 'src/commands';
const srcRulesFile = 'src/rules/rules.json';

/// A harness is an AI tool with its own layout conventions (file paths,
/// frontmatter keys, invocation style). One instance per supported tool.
class HarnessSpec {
  final String name;
  final String rootDir;              // e.g. '.claude'
  final String skillPath;            // e.g. 'skills/flutter-design/SKILL.md'
  final String referencesDir;        // e.g. 'skills/flutter-design/references'
  final String commandsDir;          // e.g. 'commands'

  const HarnessSpec({
    required this.name,
    required this.rootDir,
    required this.skillPath,
    required this.referencesDir,
    required this.commandsDir,
  });
}

const harnesses = <HarnessSpec>[
  HarnessSpec(
    name: 'claude',
    rootDir: '.claude',
    skillPath: 'skills/flutter-design/SKILL.md',
    referencesDir: 'skills/flutter-design/references',
    commandsDir: 'commands',
  ),
];

void main(List<String> args) async {
  final verify = args.contains('--verify');

  stdout.writeln(verify ? 'Verifying build/...' : 'Building build/...');

  for (final h in harnesses) {
    await _buildHarness(h, verify: verify);
  }

  stdout.writeln('OK');
}

Future<void> _buildHarness(HarnessSpec h, {required bool verify}) async {
  final outRoot = p.join(repoRoot, 'build', h.rootDir);
  final files = await _computeFiles(h);

  if (verify) {
    for (final entry in files.entries) {
      final path = p.join(outRoot, entry.key);
      final file = File(path);
      if (!file.existsSync()) {
        stderr.writeln('MISSING: $path');
        exit(2);
      }
      final onDisk = await file.readAsString();
      if (onDisk != entry.value) {
        stderr.writeln('STALE: $path');
        exit(2);
      }
    }
    return;
  }

  // Write mode: clear and regenerate
  final dir = Directory(outRoot);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);

  for (final entry in files.entries) {
    final path = p.join(outRoot, entry.key);
    File(path).parent.createSync(recursive: true);
    await File(path).writeAsString(entry.value);
  }

  stdout.writeln('  ${h.name}: ${files.length} files → $outRoot');
}

Future<Map<String, String>> _computeFiles(HarnessSpec h) async {
  // Filled in by Task 16 (skill fan-out) and Task 17 (commands fan-out)
  return {};
}
```

- [ ] **Step 3: Install deps and verify it runs**

```bash
cd tool && dart pub get && cd ..
dart run tool/build.dart
```

Expected output:

```
Building build/...
  claude: 0 files → ./build/.claude
OK
```

- [ ] **Step 4: Commit**

```bash
git add tool/pubspec.yaml tool/build.dart tool/.gitignore
# (tool/.gitignore can just contain "pubspec.lock" and ".dart_tool/" — create if needed)
git commit -m "feat: scaffold build.dart with claude harness spec"
```

---

## Task 16: Build script — skill fan-out with tests

**Files:**
- Modify: `tool/build.dart` (`_computeFiles` — add skill + references)
- Create: `tool/test/build_test.dart`

- [ ] **Step 1: Write failing test `tool/test/build_test.dart`**

```dart
// tool/test/build_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('build.dart', () {
    test('claude harness writes SKILL.md', () async {
      // Run from repo root
      final result = await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());
      expect(result.exitCode, 0,
          reason: 'build failed: ${result.stderr}');

      final skillFile = File('${_repoRoot()}/build/.claude/skills/flutter-design/SKILL.md');
      expect(skillFile.existsSync(), isTrue,
          reason: 'expected SKILL.md to be generated');
      expect(skillFile.readAsStringSync(), contains('name: flutter-design'));
    });

    test('claude harness writes 7 reference files', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final refDir = Directory('${_repoRoot()}/build/.claude/skills/flutter-design/references');
      expect(refDir.existsSync(), isTrue);
      final files = refDir.listSync().whereType<File>().toList();
      expect(files.length, 7,
          reason: 'expected 7 reference modules, got ${files.length}');
    });
  });
}

String _repoRoot() {
  // tests run from tool/, need to go up one
  final cwd = Directory.current.path;
  return cwd.endsWith('/tool') ? '${cwd}/..' : cwd;
}
```

- [ ] **Step 2: Run the test — expect FAIL**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: both tests fail with "expected SKILL.md to be generated" / "expected 7 reference modules, got 0".

- [ ] **Step 3: Implement skill fan-out in `tool/build.dart`**

Replace `_computeFiles` with:

```dart
Future<Map<String, String>> _computeFiles(HarnessSpec h) async {
  final files = <String, String>{};

  // Main SKILL.md
  final skillSrc = File(p.join(repoRoot, srcSkillDir, 'SKILL.md'));
  files[h.skillPath] = await skillSrc.readAsString();

  // Reference modules
  final refSrcDir = Directory(p.join(repoRoot, srcSkillDir, 'references'));
  for (final entity in refSrcDir.listSync().whereType<File>()) {
    if (!entity.path.endsWith('.md')) continue;
    final basename = p.basename(entity.path);
    final outPath = p.join(h.referencesDir, basename);
    files[outPath] = await entity.readAsString();
  }

  return files;
}
```

- [ ] **Step 4: Run tests — expect PASS**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: both tests pass.

- [ ] **Step 5: Verify generated files**

```bash
dart run tool/build.dart
find build/.claude -type f
```

Expected output (order may vary):

```
Building build/...
  claude: 8 files → ./build/.claude
OK
build/.claude/skills/flutter-design/SKILL.md
build/.claude/skills/flutter-design/references/typography.md
build/.claude/skills/flutter-design/references/color.md
build/.claude/skills/flutter-design/references/spacing.md
build/.claude/skills/flutter-design/references/motion.md
build/.claude/skills/flutter-design/references/interaction.md
build/.claude/skills/flutter-design/references/responsive.md
build/.claude/skills/flutter-design/references/ux-writing.md
```

- [ ] **Step 6: Commit**

```bash
git add tool/build.dart tool/test/build_test.dart build/.claude/
git commit -m "feat: fan out skill + references to claude harness"
```

---

## Task 17: Build script — commands fan-out with tests

**Files:**
- Modify: `tool/build.dart` (`_computeFiles` — add commands)
- Modify: `tool/test/build_test.dart` (add commands test)

- [ ] **Step 1: Add failing test**

Append to `tool/test/build_test.dart` inside the existing `group`:

```dart
    test('claude harness writes 21 command files', () async {
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final cmdDir = Directory('${_repoRoot()}/build/.claude/commands');
      expect(cmdDir.existsSync(), isTrue);
      final files = cmdDir.listSync().whereType<File>().toList();
      expect(files.length, 21,
          reason: 'expected 21 commands, got ${files.length}');
    });
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: new test fails with "expected 21 commands, got 0".

- [ ] **Step 3: Implement commands fan-out**

In `tool/build.dart`, extend `_computeFiles`:

```dart
Future<Map<String, String>> _computeFiles(HarnessSpec h) async {
  final files = <String, String>{};

  // Main SKILL.md
  final skillSrc = File(p.join(repoRoot, srcSkillDir, 'SKILL.md'));
  files[h.skillPath] = await skillSrc.readAsString();

  // Reference modules
  final refSrcDir = Directory(p.join(repoRoot, srcSkillDir, 'references'));
  for (final entity in refSrcDir.listSync().whereType<File>()) {
    if (!entity.path.endsWith('.md')) continue;
    final basename = p.basename(entity.path);
    final outPath = p.join(h.referencesDir, basename);
    files[outPath] = await entity.readAsString();
  }

  // Commands
  final cmdSrcDir = Directory(p.join(repoRoot, srcCommandsDir));
  for (final entity in cmdSrcDir.listSync().whereType<File>()) {
    if (!entity.path.endsWith('.md')) continue;
    final basename = p.basename(entity.path);
    final outPath = p.join(h.commandsDir, basename);
    files[outPath] = await entity.readAsString();
  }

  return files;
}
```

- [ ] **Step 4: Run tests — expect PASS**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: all 3 tests pass.

- [ ] **Step 5: Verify build output**

```bash
dart run tool/build.dart
ls build/.claude/commands/ | wc -l
```

Expected: `21`

- [ ] **Step 6: Commit**

```bash
git add tool/build.dart tool/test/build_test.dart build/.claude/commands/
git commit -m "feat: fan out 21 commands to claude harness"
```

---

## Task 18: Build script — verify mode with test

**Files:**
- Modify: `tool/test/build_test.dart` (add verify mode test)

The `--verify` path in `_buildHarness` is already implemented in Task 15
but never tested. This task locks it in.

- [ ] **Step 1: Add failing test for verify success**

Append to `tool/test/build_test.dart`:

```dart
    test('--verify exits 0 when build is fresh', () async {
      // Ensure build is current
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      final result = await Process.run(
        'dart',
        ['run', 'tool/build.dart', '--verify'],
        workingDirectory: _repoRoot(),
      );
      expect(result.exitCode, 0,
          reason: 'verify should succeed after fresh build: ${result.stderr}');
    });

    test('--verify exits nonzero when build is stale', () async {
      // Fresh build
      await Process.run('dart', ['run', 'tool/build.dart'],
          workingDirectory: _repoRoot());

      // Tamper: overwrite generated SKILL.md with different content
      final skill = File(
          '${_repoRoot()}/build/.claude/skills/flutter-design/SKILL.md');
      final original = await skill.readAsString();
      await skill.writeAsString('tampered');

      try {
        final result = await Process.run(
          'dart',
          ['run', 'tool/build.dart', '--verify'],
          workingDirectory: _repoRoot(),
        );
        expect(result.exitCode, isNot(0),
            reason: 'verify should fail when build is stale');
      } finally {
        // Restore
        await skill.writeAsString(original);
      }
    });
```

- [ ] **Step 2: Run tests — both new tests should PASS**

```bash
cd tool && dart test test/build_test.dart -r expanded
```

Expected: 5 tests pass (3 from earlier + 2 new).

If they fail, debug `_buildHarness(verify: true)` in `tool/build.dart`
— the logic is correct but file comparison should be exact.

- [ ] **Step 3: Commit**

```bash
git add tool/test/build_test.dart
git commit -m "test: cover build --verify mode (fresh and stale)"
```

---

## Task 19: README install instructions

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite `README.md`**

```markdown
# klamben

Flutter mobile design skill for AI code assistants. A Flutter-flavored
clone of [impeccable](https://github.com/pbakaus/impeccable).

Teaches AI harnesses (Claude Code today; more harnesses in future
sub-plans) to generate Flutter code that avoids AI slop patterns:
hardcoded `Colors.purple`, missing `SafeArea`, nested
`Container > Padding > Container`, Material widgets on iOS paths,
missing `const`, missing semantic labels, and more.

## What's inside

- **1 skill** with 7 reference modules:
  - [Typography](src/skill/references/typography.md)
  - [Color](src/skill/references/color.md)
  - [Spacing](src/skill/references/spacing.md)
  - [Motion](src/skill/references/motion.md)
  - [Interaction](src/skill/references/interaction.md)
  - [Responsive](src/skill/references/responsive.md)
  - [UX Writing](src/skill/references/ux-writing.md)

- **21 slash commands:**
  - Assessment: `/audit`, `/critique`, `/check-a11y`, `/check-platform`
  - Refinement: `/normalize`, `/polish`, `/distill`, `/harden`
  - Enhancement: `/animate`, `/colorize`, `/typeset`, `/arrange`,
    `/delight`, `/optimize`
  - Specialized: `/adapt`, `/theme-init`, `/widgetize`, `/localize`,
    `/form`, `/empty-state`, `/icon-set`

- **24 anti-pattern rules** in [`src/rules/rules.json`](src/rules/rules.json),
  covering visual, layout, platform, and code-quality categories.

## Install into Claude Code

From the root of your Flutter project:

```bash
# Clone klamben somewhere
git clone https://github.com/<you>/klamben.git ~/klamben

# Copy the generated .claude/ folder into your Flutter project
cp -r ~/klamben/build/.claude /path/to/your/flutter-app/.claude
```

Open your Flutter project in Claude Code. The skill auto-activates
for `.dart` files. Invoke commands with `/audit`, `/polish`, etc.

## Develop klamben itself

```bash
git clone https://github.com/<you>/klamben.git
cd klamben
cd tool && dart pub get && cd ..

# Regenerate build/ from src/
dart run tool/build.dart

# Verify build is current
dart run tool/build.dart --verify

# Run build tests
cd tool && dart test
```

## Contributing

Edit canonical files under `src/` — never edit `build/` directly.
Then run `dart run tool/build.dart` to regenerate.

## License

Apache 2.0. Derivative work of [pbakaus/impeccable](https://github.com/pbakaus/impeccable).
See [NOTICE](NOTICE).
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: write README with install and develop instructions"
```

---

## Task 20: End-to-end verification

**Files:** none modified

- [ ] **Step 1: Clean build**

```bash
rm -rf build/.claude
dart run tool/build.dart
```

Expected: `claude: 29 files → ./build/.claude` (1 SKILL.md + 7 references + 21 commands = 29 files)

- [ ] **Step 2: Verify mode passes on fresh checkout**

```bash
dart run tool/build.dart --verify
```

Expected: exits 0 with `OK`.

- [ ] **Step 3: Run full test suite**

```bash
cd tool && dart test -r expanded
```

Expected: 5 tests pass.

- [ ] **Step 4: Dart analyze + format clean**

```bash
dart analyze tool/
dart format --set-exit-if-changed tool/
```

Expected: no issues.

- [ ] **Step 5: Validate rules.json**

```bash
python3 -c "import json; d=json.load(open('src/rules/rules.json')); assert len(d['rules'])==24; assert all('id' in r and 'category' in r and 'severity' in r for r in d['rules']); print('OK: 24 rules')"
```

Expected: `OK: 24 rules`

- [ ] **Step 6: Manual smoke test into a real Flutter project**

```bash
cd /tmp && flutter create klamben_smoke
cp -r /Users/arif.ariyan/Documents/Development/ai/klamben/build/.claude /tmp/klamben_smoke/.claude
cd /tmp/klamben_smoke
claude
```

Inside Claude Code:

1. Open `/tmp/klamben_smoke/lib/main.dart`
2. Verify Claude recognizes the `flutter-design` skill (it should
   mention it when asked "what skills are available")
3. Run `/audit lib/main.dart` — expect output listing any rule
   violations (Flutter's generated main.dart has a few, e.g. the
   counter Text widget can be const, inline TextStyle in theme)
4. Run `/polish lib/main.dart` — verify it suggests edits but the
   command frontmatter is parsed correctly
5. Cleanup: `rm -rf /tmp/klamben_smoke`

- [ ] **Step 7: Count everything**

```bash
ls src/skill/references/ | wc -l                    # 7
ls src/commands/ | wc -l                             # 21
ls build/.claude/skills/flutter-design/references/ | wc -l  # 7
ls build/.claude/commands/ | wc -l                   # 21
python3 -c "import json; print(len(json.load(open('src/rules/rules.json'))['rules']))"  # 24
```

Expected: 7, 21, 7, 21, 24.

- [ ] **Step 8: Final commit if anything changed**

```bash
git status
# If there are changes (unlikely):
git add .
git commit -m "chore: final build + verification pass"
```

- [ ] **Step 9: Summary for the user**

Report:

```
Sub-plan 1 complete.

✓ Scaffolded repo (LICENSE, NOTICE, README, .gitignore, CHANGELOG)
✓ Rule catalog: 24 rules across 4 categories in src/rules/rules.json
✓ Skill: SKILL.md + 7 reference modules under src/skill/
✓ Commands: 21 slash commands under src/commands/
✓ Build script: tool/build.dart with --verify mode
✓ Claude harness generated: 29 files under build/.claude/
✓ Test suite: 5 tests pass
✓ Manual smoke test on fresh Flutter project: passed

Ready to ship as a Claude Code installable skill.

Next sub-plans:
  Sub-plan 2 — Dart CLI detector (cli/ package, 4 seed rules)
  Sub-plan 3 — Expand CLI from 4 to 24 rules
  Sub-plan 4 — Multi-harness fan-out (cursor, gemini, codex, ...)
```

---

## Sub-plan 1 acceptance criteria

- [ ] Repo scaffolded with Apache 2.0 LICENSE, NOTICE crediting upstream
- [ ] `src/rules/rules.json` has exactly 24 rules across visual/layout/platform/code-quality
- [ ] `src/skill/SKILL.md` + 7 reference modules written
- [ ] `src/commands/` has exactly 21 `.md` files
- [ ] `tool/build.dart` fans out to `build/.claude/` correctly
- [ ] `dart run tool/build.dart` produces 29 files under `build/.claude/`
- [ ] `dart run tool/build.dart --verify` exits 0 on a clean build
- [ ] `cd tool && dart test` passes 5 tests
- [ ] `dart analyze tool/` clean
- [ ] Manual install into a real Flutter project works — Claude Code
      recognizes the skill and commands

## Out of scope for sub-plan 1 (deferred)

- CLI detector (`klamben detect`) → sub-plan 2
- Additional harnesses beyond Claude Code → sub-plan 4
- Expanding from 4 seed rules to 24 in the CLI → sub-plan 3
- GitHub Actions CI workflow → sub-plan 2 (alongside CLI)
- Website → never (dropped from scope)
