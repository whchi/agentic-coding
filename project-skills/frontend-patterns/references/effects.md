# React Effect Boundaries

Classify what an effect owns before rewriting it. An effect is for synchronizing React state with an external system — not for data flow inside React.

| Requirement | Preferred expression |
| --- | --- |
| **Derived state** from props or state | Compute during render (memoize only if profiled as expensive) |
| **Server state** fetching & caching | Existing router loader or query/SWR layer |
| **User-triggered action** | Event handler (avoid boolean relay flags) |
| **Reset instance** when entity identity changes | Keyed subtree (`key={id}`) when full state/focus reset is intended |
| **External mutable store** (browser API, subscription) | `useSyncExternalStore` (prevents **tearing** under concurrent rendering) |
| **External imperative sync** (DOM, socket, media, timer) | `useEffect` with accurate dependency array and cleanup |

## Lifecycle invariants

- **StrictMode double-invocation:** setup and cleanup must be idempotent so mounting → cleaning up → remounting in development leaves no leaked listeners, duplicate connections, or broken state.
- **Race condition cancellation:** async work triggered from an effect must cancel or ignore stale responses via `AbortController` or a closure `ignore` flag in cleanup; otherwise out-of-order responses corrupt state.
- **Avoid effect waterfalls & stale closures:** never chain `setState` across cascading effects, and never suppress `react-hooks/exhaustive-deps` (including via custom empty-deps wrappers like `useMountEffect` that hide reactive inputs). Separate non-reactive callbacks with `useEffectEvent` (React 19.2+) or refs only when reactivity is genuinely unwanted.
- A `key` remounts the entire subtree, resetting focus, scroll, and DOM state; use it only when that reset matches the interaction. Do not add a query library solely to eliminate one effect.

Read [effect examples](effect-examples.md) for the specific rewrite pattern needed.

When reviewing, name the effect's responsibility and verify lifecycle, cleanup, dependency accuracy, and async race safety — fewer effects alone is not the goal.
