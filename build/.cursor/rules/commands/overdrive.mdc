---
name: overdrive
description: Add technically extraordinary visual effects — custom painters, shaders, particle systems, complex gesture animations, parallax, morphing transitions.
trigger: /overdrive [path or description]
reads: [skill/references/motion.md, skill/references/interaction.md]
writes: true
---

# /overdrive

Go beyond standard widgets. For moments that need to feel exceptional —
onboarding, celebrations, premium features, hero moments.

## When to use

- User wants a "wow" moment
- Onboarding or first-run experience
- Achievement/celebration screens
- Premium feature showcase
- User explicitly asks for advanced effects

## Process

0. **Check design context:** If `.klamben.md` exists in the project root,
   read it first. Overdrive effects should match the brand tone.
1. **Identify the moment** — What specific interaction or screen
   deserves the extraordinary treatment? (Not everything — pick one.)
2. **Choose the technique:**
   - **Custom painting** (`CustomPainter`) — animated backgrounds,
     progress rings, custom charts, wave effects
   - **Shader effects** (`FragmentProgram`) — blur, glow, gradient
     mesh, frosted glass
   - **Particle systems** — celebration confetti, floating elements,
     ambient particles
   - **Complex gestures** — drag-to-dismiss with physics, pinch-zoom
     with momentum, swipe cards
   - **Parallax** — layered scroll with depth
   - **Morphing** — `Hero` with `flightShuttleBuilder`, shape
     morphing via `TweenAnimationBuilder`
   - **Staggered animations** — sequenced entry of list items,
     cascading reveals
3. **Implement with performance in mind:**
   - `RepaintBoundary` around the effect
   - `AnimatedBuilder` not `setState`
   - Dispose all controllers
   - Respect `MediaQuery.disableAnimations`
   - Test on low-end devices (profile mode)
4. **Keep it contained** — the effect should enhance one moment,
   not spread across the whole screen
5. **Add fallback** for reduced-motion users (static version of
   the effect)

## Do NOT

- Apply overdrive effects to routine UI (buttons, lists, forms)
- Skip performance considerations
- Ignore reduced-motion accessibility
- Use effects that distract from the primary action
- Add particle effects to business/enterprise apps unless explicitly asked
