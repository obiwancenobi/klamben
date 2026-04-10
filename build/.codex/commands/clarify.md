---
name: clarify
description: Improve unclear UX copy — button labels, error messages, onboarding text, tooltips, and empty states. Makes text actionable and human.
trigger: /clarify [path]
reads: [skill/references/ux-writing.md]
writes: true
---

# /clarify

Rewrite unclear, generic, or robotic UX text. Focuses on copy only —
no layout or styling changes.

## When to use

- After `/critique` flags copy issues
- User says "the text feels off" / "improve the wording"
- Before shipping user-facing screens

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand personality and audience
   to tone decisions below.
1. **Scan for copy issues** in the target path:
   - **Generic buttons:** "Submit", "OK", "Cancel", "Click here"
   - **Vague errors:** "Error occurred", "Something went wrong", "Failed"
   - **Missing context:** empty states with no guidance
   - **Robot speak:** overly formal or technical language for consumer UX
   - **Wall of text:** paragraphs where a sentence would do
   - **Missing labels:** tooltips, semantic labels, placeholder text
2. **Rewrite each** following these rules:
   - Buttons: verb + object ("Save changes", "Delete 3 items")
   - Errors: what happened + what to do ("Couldn't save. Check your
     connection and try again.")
   - Empty states: what this is + how to start ("No items yet. Tap +
     to add your first.")
   - Onboarding: benefit-first, not feature-first
   - Tone: match `.klamben.md` brand personality (professional vs playful)
3. **Show before/after** for each change
4. **Check length:** button labels ≤20 chars, errors ≤2 sentences

## Do NOT

- Change layout or styling (that's `/polish` or `/distill`)
- Translate text (that's `/localize`)
- Rewrite debug/log strings
- Change copy that's already good
