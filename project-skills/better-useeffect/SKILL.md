---
name: better-useeffect
description: Review or refactor React effects that duplicate derived state, relay user actions, fetch data, or reset component state.
---

# React Effect Boundaries

Classify what an effect owns before replacing it. Remove unnecessary synchronization while preserving intentional lifecycle and state behavior.

| Requirement | Preferred expression |
| --- | --- |
| Derive a value from props or state | Compute during render |
| Fetch server data | Existing framework loader or query layer |
| Respond to a user action | Event handler |
| Reset the entire instance when identity changes | A keyed component |
| Synchronize with an external system | Effect with matching dependencies and cleanup |

A key resets the whole subtree, including focus and local state; use it only when that reset is intended. Do not add a query library solely to remove one effect.

For genuinely mount-scoped external synchronization, an existing `useMountEffect` convention may make intent clearer. Do not hide reactive dependencies inside an empty dependency wrapper; changing inputs may legitimately require resynchronization. Setup and cleanup must remain safe when React repeats them.

Read [examples](references/examples.md) for the particular rewrite being considered. They illustrate semantics, not a requirement to remount every subscription or media player.

When reviewing, name the effect's responsibility and explain why the replacement preserves it. When editing, check the affected lifecycle, cleanup, input changes, and asynchronous races rather than treating fewer effects as the success criterion.
