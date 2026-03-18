---
name: better-useeffect
description: Use when working on React or Next.js components that include useEffect, need component refactoring, code review, render-loop debugging, stale derived state cleanup, event-driven action flow, mount/unmount synchronization, or reset-on-prop-change behavior. Also use when the user wants to reduce race conditions or avoid direct useEffect usage even if they do not ask for this skill by name.
---

# React Without Direct useEffect

## Overview

Treat direct `useEffect` usage as a smell, not a default primitive.

Most component logic becomes simpler and safer when it stays in one of React's clearer control-flow paths: render-time derivation, event handlers, query abstractions, or explicit mount/unmount boundaries. This skill helps decide which path to use and how to rewrite effect-heavy components into more predictable code.

For rare mount-only synchronization with external systems, prefer a dedicated `useMountEffect` wrapper instead of ad hoc `useEffect` calls inside components.

Read `references/examples.md` when you need code examples for each rewrite pattern.

## When to Use

Use this skill when you see any of these signals:

- A component sets state inside `useEffect` based on props or other state
- A component fetches data in `useEffect` and stores the result locally
- A user action is modeled as `setFlag(true) -> useEffect runs -> reset flag`
- A component uses `useEffect` mainly to reset local state when an ID or prop changes
- A review comment or bug report mentions dependency arrays, stale state, race conditions, infinite loops, or "why did this effect run"
- The user wants a React or Next.js code review focused on maintainability and predictable control flow

Do not use this skill when the task is unrelated to React component logic.

## Default Stance

Do not reach for direct `useEffect` first.

Instead, classify the job the code is trying to do. Most cases fit one of five buckets:

1. Derive values during render
2. Fetch through a data-fetching abstraction
3. Run work directly in an event handler
4. Sync once on mount with an external system via `useMountEffect`
5. Force a fresh instance with `key` instead of dependency choreography

The goal is not to obey a slogan. The goal is to make control flow obvious, local, and easy to debug.

## Decision Flow

When you encounter `useEffect`, ask these questions in order:

### 1. Is this value derived from props or state?

If yes, compute it during render instead of syncing it into another piece of state.

Why: syncing derived values creates extra renders, hidden coupling, and loop risk.

### 2. Is this effect fetching server data?

If yes, prefer a query or data-fetching library that handles caching, cancellation, retries, and staleness.

Why: effect-based fetching often rebuilds fragile async state machines inside components.

### 3. Is this work triggered by a user action?

If yes, perform it in the event handler, not through a state flag that an effect observes.

Why: user intent already has a clear entrypoint. Relaying it through state hides that entrypoint and complicates debugging.

### 4. Is this truly external-system synchronization on mount/unmount?

If yes, `useMountEffect` is acceptable.

Good fits include:

- DOM integration like focus or scroll positioning
- Third-party widget setup and teardown
- Browser API subscription lifecycle
- Imperative media playback or measurement that belongs to mount/unmount boundaries

If the behavior should happen only after some precondition is met, prefer conditional mounting so the component appears only when it is ready.

### 5. Is the real requirement "start fresh when this ID changes"?

If yes, wrap the component and change its `key` so React remounts a fresh instance.

Why: this expresses the requirement directly and avoids trying to emulate remount semantics with effect dependencies.

## Rewrite Patterns

### Pattern 1: Derive state, do not sync it

Smells:

- `useEffect(() => setX(deriveFromY(y)), [y])`
- local state that only mirrors props or other state
- chains like `A updates B, then B updates C`

Preferred rewrite:

- compute the derived value inline during render
- collapse multi-step local synchronization into direct expressions when possible

### Pattern 2: Use data-fetching abstractions

Smells:

- `useEffect(() => { fetch(...).then(setState) }, [...])`
- manual `loading`, `error`, cancellation, or stale-response handling inside the component

Preferred rewrite:

- move fetching to a query abstraction such as TanStack Query or the project's existing data layer
- let the library own async lifecycle concerns

### Pattern 3: Use event handlers, not effect relays

Smells:

- local boolean flags whose only purpose is to trigger an effect
- code shaped like `setPending(true)` followed by effect-driven imperative work

Preferred rewrite:

- invoke the action directly in the click, submit, or change handler
- keep the causal chain close to the user event that triggered it

### Pattern 4: Use `useMountEffect` only for explicit external sync

Wrap the rare mount-only case in a named hook:

```typescript
function useMountEffect(callback: () => void | (() => void)) {
  useEffect(callback, []);
}
```

Why this wrapper helps:

- it makes intent obvious during review
- it discourages casual dependency-array experimentation
- it limits effect usage to the narrow case that actually matches mount semantics

### Pattern 5: Reset with `key`, not dependency choreography

Smells:

- effects that exist only to reload or reset local state when `id` changes
- code trying to simulate "new component instance" behavior with dependencies

Preferred rewrite:

- split the component if needed
- pass a `key` from the parent so React creates a fresh instance for each entity

## Review Guidance

When reviewing code, do not just say "avoid useEffect." Explain the better primitive and why it matches the requirement more closely.

Useful review framing:

- "This state is derived from existing inputs, so storing it separately adds a second source of truth."
- "This action starts from a click, so the handler is the clearest place to do the work."
- "This is server data lifecycle, which belongs in the query layer rather than a component-local effect."
- "This behavior is really remount semantics, so `key` expresses it more directly than an effect."
- "This looks like a genuine external-system sync on mount, so `useMountEffect` is the narrow acceptable escape hatch."

## Response Pattern

When this skill is active for implementation or review work:

1. Identify each direct `useEffect` and briefly classify what it is trying to accomplish
2. Recommend the replacement primitive
3. Explain why the replacement gives clearer control flow
4. Rewrite the component or provide a concrete refactor outline
5. Call out any remaining legitimate mount-only external synchronization separately

## Common Mistakes

- Treating all imperative work as an effect problem instead of asking what event or lifecycle boundary actually owns it
- Using local state as a message bus between handlers and effects
- Keeping duplicated derived state because it feels convenient in the moment
- Re-implementing query lifecycle logic inside a component
- Using dependency arrays to approximate remount behavior
- Using `useMountEffect` for logic that should really be triggered by conditional rendering or explicit user actions

## Output Expectations

When giving advice or a refactor:

- be concrete about which `useEffect` usages are unnecessary
- map each one to a replacement pattern
- prefer small, local rewrites over abstract slogans
- preserve existing project conventions unless they conflict with the core goal of predictable control flow

## Reference

For concrete before/after examples, read `references/examples.md`.
