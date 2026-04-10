---
name: form
description: Build a validated form with TextFormField, error states, focus flow, and correct keyboard types.
trigger: /form [description or path]
reads: [rules/rules.json, skill/references/interaction.md, skill/references/ux-writing.md]
writes: true
---

# /form

Generate a production-grade form.

## Actions

1. Use `Form` + `GlobalKey<FormState>` for validation
2. `TextFormField` per field with `validator`
3. Correct `keyboardType` per field (email, number, phone, multiline)
4. `textInputAction` for focus flow (next, done)
5. `FocusNode` wiring for next-field
6. Error messages from `/ux-writing.md` style (specific, actionable)
7. Submit button with loading state, disabled while invalid
8. `SingleChildScrollView` + keyboard inset padding
9. Success → `/harden`-style error handling

## Do NOT

- Use third-party form packages unless user asks
- Persist state without being told where
- Add analytics hooks
