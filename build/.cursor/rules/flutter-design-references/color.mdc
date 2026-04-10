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
