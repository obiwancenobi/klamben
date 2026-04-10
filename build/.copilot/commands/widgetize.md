---
name: widgetize
description: Extract inline widget trees into named StatelessWidget classes with documented params.
trigger: /widgetize [widget or file]
reads: [rules/rules.json, skill/references/spacing.md]
writes: true
---

# /widgetize

Extract a subtree into a reusable widget class.

## When to use

- A build method exceeds ~100 lines
- Same tree repeats 3+ times
- Prep for testing an isolated component

## Actions

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand, platform targets,
   accessibility tier, and existing patterns to your work below.
1. Identify the target subtree
2. Create a new private `StatelessWidget` (or `StatefulWidget` if
   it has state) in the same file, below the parent class
3. Pass captured variables as constructor parameters
4. Add dartdoc to the new class
5. Replace the inline tree with a call to the new widget

## Do NOT

- Move widgets to new files (unless the file is > 500 lines)
- Make widgets public without user confirmation
- Extract one-use widgets (YAGNI)
