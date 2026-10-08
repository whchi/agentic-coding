---
name: frontend-patterns
description: Choose React or Next.js component, state, form, and accessibility patterns when designing or restructuring interactive UI.
origin: ECC
---

# Frontend Development Patterns

Use the project's existing component and data layers. Choose patterns for the interaction being changed; ordinary UI work does not require an architecture overhaul.

## Component and state decisions

- Keep state with its owner; lift it for shared interactions. Use existing global stores only for genuinely shared client state.
- Keep server data in the project's query layer and derive values instead of storing duplicate state.
- Use composition for reusable structure and controlled APIs when a parent must coordinate state. Compound components are useful for related controls, not every wrapper.
- Use stable list keys that preserve the intended item identity.
- Keep server concerns out of client components unless the interaction needs them.

## Forms and accessibility

Use existing form wrappers; simple forms rarely need a new library. Associate labels and errors with inputs, validate on submit, and choose earlier feedback to fit the interaction.

For the controls being changed, preserve keyboard operation, visible focus, semantic HTML, and accessible names. Modals need focus containment and restoration; menus need appropriate keyboard navigation and dismissal.

Respect reduced-motion preferences; reduce or remove movement while preserving understandable state changes. Gate decorative hover effects with `@media (hover: hover) and (pointer: fine)`; never make content or actions hover-only. Do not disable browser zoom. For iOS input zoom, prefer input font sizes of at least 16px.

## Performance

Use profiling or a clear expensive boundary to justify memoization, virtualization, code splitting, transitions, or deferred values. Keep urgent input feedback synchronous. Split contexts when unrelated consumers otherwise rerender frequently. Follow React Compiler guidance when present.

## Conditional examples

Read only the relevant section of [examples](references/examples.md): composition/compound components, hooks, Context/reducer, forms, error boundaries, performance, or keyboard/focus handling. The examples illustrate choices, not required dependencies.

For effect-specific rewrites use `better-useeffect`; for unstable payload normalization use `frontend-robust-data-handling`; for motion design use `animate` when those are the actual task.
