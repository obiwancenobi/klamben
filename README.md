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

## Install (Claude Code)

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
