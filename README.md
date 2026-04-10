```
  ╔═══════════════════════════════════════════╗
  ║  ┌─┐   ┌─┐                                ║
  ║ ┌┘ └───┘ └┐  klamben                      ║
  ║ │         │  flutter design skill         ║
  ║ └─────────┘  for AI code assistants       ║
  ╚═══════════════════════════════════════════╝
```

A Flutter-flavored clone of [impeccable](https://github.com/pbakaus/impeccable).

1 skill, 28 commands, 24 anti-pattern rules, 1 CLI detector — for
Flutter mobile apps. Distributed to 10 AI harnesses.

## The problem

All LLMs trained on the same Flutter templates produce the same slop:
`Colors.purple`, missing `SafeArea`, nested `Container > Padding > Container`,
Material widgets on iOS paths, missing `const`, no semantic labels,
`EdgeInsets.all(17)`, empty `catch` blocks, and more.

**klamben** teaches AI code assistants to avoid these patterns with
explicit rules, reference modules, and slash commands.

## What's inside

### Skill + 7 reference modules

One skill with Flutter-first design guidance across:

| Module | Covers |
|--------|--------|
| [Typography](src/skill/references/typography.md) | TextTheme, Material 3 type scale, google_fonts, line-height |
| [Color](src/skill/references/color.md) | ColorScheme.fromSeed, semantic tokens, dark mode, gradients |
| [Spacing](src/skill/references/spacing.md) | 4/8pt grid, EdgeInsets, SafeArea, widget economy, elevation |
| [Motion](src/skill/references/motion.md) | AnimationController, Curves, Hero, implicit animations |
| [Interaction](src/skill/references/interaction.md) | Buttons, touch targets, haptics, async safety, error handling |
| [Responsive](src/skill/references/responsive.md) | LayoutBuilder, breakpoints, Flex children, overflow guards |
| [UX Writing](src/skill/references/ux-writing.md) | Button labels, errors, empty states, i18n/ARB |

### 28 slash commands

| Category | Commands |
|----------|----------|
| **Setup** | `/teach` — one-time project scan + design context setup |
| **Creation** | `/craft` — guided shape-then-build flow | `/extract` — pull tokens + components into design system |
| **Assessment** (read-only) | `/audit` `/critique` `/check-a11y` `/check-platform` |
| **Refinement** (edits code) | `/normalize` `/polish` `/distill` `/clarify` `/harden` |
| **Enhancement** | `/animate` `/colorize` `/typeset` `/layout` `/delight` `/optimize` `/bolder` `/quieter` `/overdrive` |
| **Specialized** | `/adapt` `/theme-init` `/widgetize` `/localize` `/form` `/empty-state` `/icon-set` |

### 24 anti-pattern rules

Defined in [`src/rules/rules.json`](src/rules/rules.json). Each rule
has an ID, category, severity, rationale, and good/bad examples.

| Category | Rules |
|----------|-------|
| **Visual** (7) | hardcoded-color, roboto-default, gradient-abuse, pure-black-text, nested-cards, shadow-overuse, inline-textstyle |
| **Layout** (6) | missing-safearea, nested-padding, magic-numbers, hardcoded-width, no-flexible, fixed-row-overflow |
| **Platform** (4) | missing-adaptive, material-on-ios, cupertino-on-android, wrong-nav-pattern |
| **Code Quality** (7) | missing-const, missing-semantics, missing-dispose, hardcoded-strings, setstate-after-async, missing-key, swallowed-errors |

## Install (AI harness)

```bash
git clone https://github.com/obiwancenobi/klamben.git ~/klamben
cd ~/klamben && cd tool && dart pub get && cd ..

# Install into your Flutter project (safe merge — won't overwrite existing files):
dart run tool/install.dart ~/my-flutter-app

# Specify harness explicitly:
dart run tool/install.dart ~/my-flutter-app --harness cursor

# Preview without writing:
dart run tool/install.dart ~/my-flutter-app --dry-run

# Overwrite conflicting files:
dart run tool/install.dart ~/my-flutter-app --force

# Remove klamben from a project:
dart run tool/install.dart ~/my-flutter-app --uninstall
```

The install script auto-detects your harness (claude, cursor, gemini,
codex, opencode, kiro, trae, rovo, copilot, pi) from existing project
directories. It merges klamben files without touching your existing
skills, commands, or settings. A `.klamben-manifest.json` tracks
installed files for clean updates and uninstalls.

Open your Flutter project in the harness. The skill auto-activates
for `.dart` files.

## Getting started

After installing, run `/teach` once in your AI harness:

```
/teach
```

This scans your Flutter project (ThemeData, fonts, spacing tokens,
platform patterns, l10n setup) and asks a few questions about your
brand, audience, and accessibility goals. Results are saved to
`.klamben.md` in your project root.

All other commands (`/audit`, `/polish`, `/colorize`, etc.) read
`.klamben.md` for project-specific guidance. Without it, commands
still work but give generic Flutter advice.

## CLI detector

Standalone Dart CLI that scans Flutter projects for anti-patterns
without an AI harness. All 24 rules, text or JSON output.

```bash
# Install from source
cd ~/klamben/cli && dart pub global activate --source path .

# Scan your project
klamben detect lib/
klamben detect --format=json lib/ > findings.json
klamben detect --severity=error lib/

# Explore rules
klamben list-rules
klamben explain visual/hardcoded-color
```

**Exit codes:** `0` no findings, `1` findings present, `2` tool error.

**Example output:**

```
lib/screens/home.dart
  11:15  warning  visual/hardcoded-color      Use ColorScheme semantic token instead of Colors.purple
  24:7   error    layout/missing-safearea     Scaffold body without SafeArea or AppBar
  47:3   info     code-quality/missing-const  Text widget can be const

3 issues (1 error, 1 warning, 1 info) in 1 file.
```

## Architecture

```
klamben/
├── src/                     # CANONICAL SOURCE OF TRUTH
│   ├── skill/               # 1 SKILL.md + 7 reference modules
│   ├── commands/            # 28 slash command definitions
│   └── rules/rules.json    # 24 anti-pattern rule contract
├── tool/                    # Build script (Dart)
│   └── build.dart           # Fans out src/ → build/<harness>/
├── build/                   # GENERATED (committed, do not edit)
│   ├── .claude/             # Claude Code layout
│   ├── .cursor/             # Cursor layout (.mdc extension)
│   ├── .gemini/ .codex/ .opencode/ .kiro/
│   ├── .trae/ .rovo/ .copilot/ .pi/
├── cli/                     # Dart CLI detector package
│   ├── lib/src/rules/       # 24 rule implementations
│   ├── lib/src/reporter/    # text + JSON output
│   └── test/                # 72 tests
```

**Single source of truth:** edit `src/`, run `dart run tool/build.dart`,
all 10 harness folders regenerate. `rules.json` is the contract shared
between the skill markdown, CLI detector, and build script.

## Develop

```bash
git clone https://github.com/obiwancenobi/klamben.git
cd klamben

# Build script
cd tool && dart pub get && cd ..
dart run tool/build.dart           # regenerate build/
dart run tool/build.dart --verify  # CI check: exits non-zero if stale
cd tool && dart test               # 15 build + install tests

# CLI
cd ../cli && dart pub get
dart test                          # 72 tests
dart analyze lib/ test/ bin/       # static analysis
```

## Contributing

1. Edit canonical files under `src/` — never edit `build/` directly
2. Run `dart run tool/build.dart` to regenerate
3. Run tests: `cd tool && dart test && cd ../cli && dart test`
4. Format: `dart format tool/ && cd cli && dart format lib/ test/ bin/`

## License

Apache 2.0. Derivative work of [pbakaus/impeccable](https://github.com/pbakaus/impeccable).
See [NOTICE](NOTICE).
