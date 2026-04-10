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
