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

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
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
