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
