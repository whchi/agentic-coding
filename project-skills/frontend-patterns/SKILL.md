---
name: frontend-patterns
description: Choose React component, state, form, accessibility, and render-safe API data-handling patterns when designing interactive UI, or refactor effects that duplicate state or misplace event and lifecycle work.
origin: ECC
---

# Frontend Development Patterns

Use the project's existing React component and data layers. Choose patterns for the interaction being changed; ordinary UI work does not require an architecture overhaul.

## Component and state decisions

- **State colocation & SSOT:** keep state with its lowest common owner and lift only for shared interactions. Compute **derived state** during render rather than synchronizing duplicate state.
- **Server state vs client UI state:** keep remote data in the project's query/SWR cache layer instead of mirroring it in global client stores; use global stores only for genuinely cross-tree client UI state. Apply **optimistic UI** deliberately with rollback on failure.
- **Composition & IoC:** prefer composition, slots, and **controlled vs uncontrolled** APIs over deep prop drilling or boolean-flag explosion. Use **compound components** for tightly related controls, not every wrapper.
- Use stable reconciliation keys tied to item identity (never array index for reorderable or stateful rows).

## Forms and accessibility

Use existing form primitives; simple forms rarely need a new library. Associate `<label>`, `aria-invalid`, `aria-describedby`, and `aria-live` status/error messages with inputs; validate on submit and add earlier feedback only when it helps the interaction.

Follow **WAI-ARIA Authoring Practices (APG)** for the changed controls: preserve keyboard operation, visible focus, semantic HTML, and accessible names. Modals need a **focus trap** (`inert` / native `<dialog>`) and focus restoration to the opener; menus, tabs, and listboxes need **roving tabindex** or `aria-activedescendant` and `Escape` dismissal.

Respect `prefers-reduced-motion: reduce` (leave motion craft and timing to `animate`). Gate decorative hover styles behind `@media (hover: hover) and (pointer: fine)`; never make content or actions hover-only. Never disable browser zoom; keep iOS input font sizes at least `16px`.

## Performance

Optimize around **Core Web Vitals (INP, CLS)** and real profiling evidence before adding `useMemo`, `useCallback`, or `React.memo`. Use virtualization for large lists, `React.lazy` + `Suspense` for heavy routes/widgets, and concurrent primitives (`useTransition`, `useDeferredValue`) to keep urgent input feedback synchronous. Split Context providers (or use selectors) to avoid fan-out rerenders across unrelated consumers. Follow React Compiler rules when enabled.

## Conditional guidance

- Effect review or refactoring (StrictMode double-invocation, stale closures, race cancellation, external stores): read [effect boundaries](references/effects.md).
- Missing, null, partial, or unknown API payloads and Anti-Corruption ViewModel adapters: read [data handling](references/data-handling.md).
- Focused implementation sketches (split Context + reducer, accessible form, virtualization, native `<dialog>` focus): read only the relevant section of [examples](references/examples.md).
