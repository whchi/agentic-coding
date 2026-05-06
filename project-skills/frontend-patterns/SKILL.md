---
name: frontend-patterns
description: Use when designing React component architecture, choosing client/server state patterns, optimizing render performance, implementing forms, error boundaries, accessibility, virtualization, or animation patterns. Do NOT use for useEffect-specific rewrites, JS/TS language conventions, or HTML slide decks.
origin: ECC
---

# Frontend Development Patterns

Modern frontend patterns for React, Next.js, and performant interfaces. This skill owns frontend architecture and UI behavior decisions, not language-level JavaScript/TypeScript standards.

## When To Use

Use this skill when the task involves:
- component structure: composition, compound components, controlled/uncontrolled APIs
- state decisions: local state, lifted state, Context, reducer, Zustand/Jotai/Redux, server state
- performance: memoization, virtualization, code splitting
- UI patterns: forms, error boundaries, animation, accessibility

Do NOT use when:
- the task is specifically about removing or reviewing `useEffect` usage — use `better-useeffect`
- the task is about JS/TS naming, immutability, async, or type standards — use `js-ts-coding-standards`
- the task is about HTML slide decks — use `frontend-slides`

## Approach

1. Identify the problem category: component structure, state, performance, forms, accessibility, or animation.
2. Check existing project conventions before introducing a library or pattern.
3. Choose the simplest pattern that fits the requirement.
4. Use `references/examples.md` when the example fixes project style or non-obvious API details.
5. Verify the result does not add complexity disproportionate to the problem.

## Component Patterns

| Pattern | Best For | Avoid When |
|---------|----------|------------|
| Composition | Flexible layouts, reusable components | Deep prop drilling needed |
| Compound Components | Tabs, Selects, RadioGroups | Simple single components |
| Controlled component API | Forms, inputs, popovers, reusable stateful UI | State should stay fully internal |

Prefer combining small, focused components over extending base components.

```tsx
<Card>
  <CardHeader>Title</CardHeader>
  <CardBody>Content</CardBody>
</Card>
```

## State Management

| Scope | Recommended Approach |
|-------|----------------------|
| Single component | `useState` |
| Sibling components | Lift state up or Context |
| Deep tree, related transitions | Context + `useReducer` |
| Global client state | Zustand, Jotai, or Redux if already used |
| Server state | Project query layer, React Query, or SWR |

Context rules:
- Use Context for values that change rarely: theme, user, locale.
- Avoid frequently updating Context values; they re-render broad subtrees.
- Split contexts by concern and update frequency.

## Performance

| Pattern | When to Use | Gotcha |
|---------|-------------|--------|
| `useMemo` | Expensive computation visible in profiler | Adds complexity; avoid by default |
| `useCallback` | Function identity matters to memoized children or external subscriptions | Unneeded if children are not memoized |
| `React.memo` | Component re-renders with same props and cost is measured | Compare prop changes first |
| Virtualization | Large lists or complex rows | Adds layout complexity |
| Code splitting | Heavy routes, charts, editors, 3D, rarely-used panels | Add useful fallback states |

Rule: profile before memoizing. Prefer simpler rendering until there is measured cost or an obvious high-cost boundary.

## Forms

| Approach | Best For |
|----------|----------|
| Controlled inputs + local validation | Simple forms, few fields |
| React Hook Form + Zod | Complex forms, schema validation |
| Existing project form wrapper | Any project with established form conventions |

Patterns:
- Validate on blur or submit unless live validation is explicitly useful.
- Associate labels and error messages with inputs.
- Disable submit only when that matches product behavior; still validate on submit.

## Accessibility

Required for interactive components:
- keyboard navigation for reachable controls
- focus management for modals, popovers, and route-like transitions
- visible focus indicators
- semantic HTML first; ARIA only when native semantics are insufficient
- screen-reader labels for custom controls

Common patterns:
- Modals: trap focus, save previous focus, restore on close.
- Dropdowns/menus: arrow key navigation and Escape to close.
- Forms: label association and error messages linked to inputs.

## Common Mistakes

- **Over-using Context** — frequently changing values re-render broad subtrees.
- **Memoizing without measuring** — `useMemo`/`useCallback` can add complexity for no gain.
- **Wrong keys** — unstable list keys cause incorrect item state retention.
- **Inventing a pattern before checking conventions** — existing project patterns usually matter more than generic preference.
- **Treating effect problems as frontend architecture** — use `better-useeffect` for direct `useEffect` review.

## References

For code examples, see `references/examples.md`:
- component patterns: composition and compound components
- custom hooks: `useToggle`, `useDebounce`
- state patterns: Context + reducer
- forms and error boundaries
- performance: memoization, code splitting, virtualization
- animation and accessibility
