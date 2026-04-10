---
name: polish
description: Final pre-ship refinement. Adds const, fixes key hygiene, removes dead code, tightens copy. Safe edits only.
trigger: /polish [path]
reads: [rules/rules.json]
writes: true
---

# /polish

Last-mile cleanup before shipping. Only safe, mechanical changes.

## When to use

- Before creating a PR
- Before merging to main
- After `/audit` shows only info-level issues

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. Add `const` to every eligible constructor (respects
   `prefer_const_constructors` lint)
2. Add `key: ValueKey(...)` to list children that lack keys
3. Remove unused imports
4. Remove commented-out code blocks
5. Tighten button labels and error messages (generic → specific)
6. Add trailing commas to multi-line arg lists (for consistent formatting)

## Do NOT

- Refactor logic
- Restructure widgets
- Rename variables
- Touch tests unless they break from the edits above

## Output

```
polish lib/screens/home.dart

+ const Text('Welcome')
+ const SizedBox(height: 16)
- // TODO: remove this old code
- Container(child: ... // unused)
- 'Submit' → 'Save changes'

8 edits in 1 file.
Run tests before committing.
```
