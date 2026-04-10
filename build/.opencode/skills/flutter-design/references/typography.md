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
