---
name: distill
description: Reduce widget nesting and extract repeated trees into named widgets. Flattens Container/Padding/Container chains.
trigger: /distill [path]
reads: [rules/rules.json, skill/references/spacing.md]
writes: true
---

# /distill

Collapse redundant widgets and extract duplication.

## When to use

- A widget file exceeds ~200 lines
- `/audit` flags layout/nested-padding or visual/nested-cards
- A subtree repeats 3+ times

## Actions

1. **Flatten redundant wrappers:**
   - `Padding > Container > Padding` → single `Container(padding: ...)`
   - `Container > Center > Text` → `Container(alignment: Alignment.center, child: Text)`
   - `Card > Card` → single `Card` with internal structure
2. **Extract repeated subtrees** into private StatelessWidget classes
   at the bottom of the file
3. **Name extracted widgets** descriptively (`_UserRow`, not `_Row1`)
4. **Drop unused Container decorations** (empty `BoxDecoration`)

## Do NOT

- Extract widgets that appear only once (premature abstraction)
- Create public API widgets without the user asking
- Move widgets to new files (that's `/widgetize`)

## Output

```
distill lib/screens/home.dart

- Padding(padding: EdgeInsets.all(16),
-   child: Container(padding: EdgeInsets.all(16), child: Text('Hi')))
+ Container(padding: EdgeInsets.all(32), child: Text('Hi'))

Extracted 3 repeated _UserRow subtrees into class _UserRow at L187.

4 collapses, 1 extraction.
```
