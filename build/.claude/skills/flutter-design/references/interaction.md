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
