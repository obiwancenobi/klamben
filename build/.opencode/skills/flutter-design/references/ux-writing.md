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
