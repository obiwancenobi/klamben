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
