---
name: bolder
description: Amplify conservative or boring designs — stronger color contrast, bolder typography, more prominent CTAs, richer visual hierarchy.
trigger: /bolder [path]
reads: [skill/references/color.md, skill/references/typography.md, skill/references/spacing.md]
writes: true
---

# /bolder

Make a timid design more confident. For screens that feel generic,
flat, or forgettable.

## When to use

- Screen looks like every other Flutter app
- User says "this is boring" / "make it pop" / "it needs more energy"
- After `/critique` says the hierarchy is flat

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Apply the project's brand personality — "bold" means
   different things for enterprise vs consumer apps.
1. **Increase typographic contrast:**
   - Promote primary heading from `titleMedium` → `headlineMedium`
   - Increase weight on CTAs (`FontWeight.w600` → `w700`)
   - Add more size difference between heading and body (at least 2 scale steps)
2. **Strengthen color usage:**
   - Move primary action from `OutlinedButton` → `FilledButton`
   - Use `primaryContainer` backgrounds for key sections instead of plain `surface`
   - Add accent color on the most important element
3. **Increase spatial contrast:**
   - More padding above primary content (create breathing room)
   - Tighter grouping within related items (reduce internal spacing)
   - Larger touch targets on primary CTAs
4. **Add visual anchors:**
   - Hero element (image, avatar, icon) at the top
   - Visual separator between sections (not just whitespace)
   - Bottom CTA bar for primary action if currently inline
5. **Show before/after reasoning** for each change

## Do NOT

- Make it garish — bolder ≠ louder
- Add gradients, shadows, or decorative elements
- Break accessibility (maintain contrast ratios)
- Override brand guidelines from `.klamben.md`
- Add motion (that's `/animate`)
