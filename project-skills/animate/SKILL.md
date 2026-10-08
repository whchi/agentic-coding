---
name: animate
description: Build or tune a specific web UI animation, including timing, easing, interruption, and reduced-motion behavior; not a codebase motion audit.
origin: emilkowalski/skills (MIT)
---

# Building Animations

Make motion serve feedback, spatial continuity, state changes, or explanation. Frequently repeated interactions need especially restrained timing; keyboard input must stay responsive. Recommend an instant state change when motion adds delay without helping the task.

## Choose the implementation

Reuse existing motion tokens and accessible component primitives. Do not retune a shared token for one element or install a motion library for a fade.

- CSS transitions suit hover, press, and interruptible state changes.
- `@starting-style` can handle entry transitions where supported.
- CSS keyframes suit predetermined motion.
- WAAPI suits programmatic control without a library.
- The project's motion library may suit springs, layout, exit, and gesture animation.

Prefer `transform` and `opacity` for smooth motion; layout properties can be appropriate for content expansion but need checking under load. Use a full transform string when it enables compositor acceleration in the installed motion library. Do not assume every CSS animation runs off the main thread.

## Motion decisions

- Anchor popover/menu transform origins to their trigger; centered modals can remain centered.
- Prefer modest scale entrances such as 0.95 with opacity over a distracting scale-from-zero effect.
- Entrances usually benefit from ease-out; movement across the screen often suits ease-in-out. Reuse project curves before adding new ones.
- Start around 100–160ms for press feedback, 125–250ms for small overlays, and 200–500ms for larger overlays; tune for distance, responsiveness, and existing conventions.
- Use transitions or interruptible animations for rapidly repeated actions. Springs can preserve gesture velocity; keep bounce restrained in functional UI.
- Keep entrance and exit paths spatially coherent. Name transitioned properties instead of using `transition: all`.

Read the matching section of [RECIPES.md](RECIPES.md) for component-specific starting points. Values and examples are defaults to adapt, not a required recipe.

## Accessibility and verification

Ship reduced-motion handling with the animation: reduce or remove movement, retaining gentle opacity/color changes only when useful and comfortable. Gate hover motion behind `@media (hover: hover) and (pointer: fine)`. Preserve focus, keyboard operation, and dismissal behavior when animating an interactive primitive.

Check the actual changed interaction, including interruption, exit, reduced motion, and relevant pointer input. Report any visual or device behavior you could not inspect. Deliver the implementation with a brief explanation of its purpose and timing; no fixed report format is required.
