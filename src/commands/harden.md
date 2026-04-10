---
name: harden
description: Add loading/error/empty states, mounted guards, disposal, null safety tightening. Makes screens production-ready.
trigger: /harden [path]
reads: [rules/rules.json, skill/references/interaction.md]
writes: true
---

# /harden

Prep a screen for production. Add the safety scaffolding most AI-
generated code misses.

## When to use

- Taking a prototype to production
- After `/audit` shows errors in code-quality category
- Before a real-user launch

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. **Loading states:** Any async button/action gets a `_loading` flag
   and disabled-while-loading UI
2. **Error states:** Wrap async calls in try/catch; show user-facing
   error (SnackBar or inline); log to `debugPrint`
3. **Empty states:** Any list screen gets a meaningful empty state
4. **Mounted guards:** Every `setState` or `context` use after `await`
   gets `if (!mounted) return;`
5. **Dispose:** Every `*Controller` field in `State` gets disposed in
   `dispose()`
6. **Null safety:** `!` → explicit null check where possible
7. **Swallowed errors:** Empty `catch (_)` → logged + reported

## Output

```
harden lib/screens/home.dart

+ late bool _loading = false;
+ try/catch around api.save() with user-facing SnackBar on error
+ if (!mounted) return; guards on 3 async methods
+ @override void dispose() { _controller.dispose(); super.dispose(); }
+ Empty state widget when items.isEmpty

8 safety additions.
Run tests before committing.
```

## Do NOT

- Change business logic
- Add features the user didn't ask for
- Touch unrelated screens
