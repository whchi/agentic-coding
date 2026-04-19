---
name: frontend-patterns
description: Use when building React components (composition, props), managing state (Context, Zustand, useReducer), optimizing performance (memoization, virtualization), or implementing forms, error boundaries, and accessibility. Invoke for component architecture decisions, state management choices, and render performance issues.
origin: ECC
---

# Frontend Development Patterns

Modern frontend patterns for React, Next.js, and performant interfaces.

## Component Patterns

### When to Use Each

| Pattern | Best For | Avoid When |
|---------|----------|------------|
| Composition | Flexible layouts, reusable components | Deep prop drilling needed |
| Compound Components | Tabs, Selects, RadioGroups | Simple single components |
| Render Props | Data loading, shareable logic | Performance-critical renders |

### Composition Over Inheritance

Prefer combining small, focused components over extending base components.

```
// ✅ Composition: compose behaviors
<Card><CardHeader>Title</CardHeader><CardBody>Content</CardBody></Card>

// ❌ Inheritance: fragile hierarchies
class BaseCard extends Component {}
class OutlinedCard extends BaseCard {}
```

## State Management

### Decision Guide

| Scope | Recommended Approach |
|-------|---------------------|
| Single component | `useState` |
| Sibling components | Lift state up or Context |
| Deep tree | Context + `useReducer` |
| Global app state | Zustand, Jotai, or Redux |
| Server state | React Query or SWR |

### Context Trade-offs

- **Use Context for**: theme, user, locale — values that change rarely
- **Avoid Context for**: frequently updating state — causes re-renders across entire tree
- **Split Contexts**: separate contexts for separate concerns to limit re-render scope

## Performance

### Memoization Trade-offs

| Hook/Pattern | When to Use | Gotcha |
|--------------|-------------|--------|
| `useMemo` | Expensive computations visible in profiler | Adds complexity, only for measured problems |
| `useCallback` | Passing functions to memoized children | Unnecessary if children aren't memoized |
| `React.memo` | Components re-rendering with same props | Compare prop changes in profiler first |

**Rule**: Profile before memoizing. Premature optimization adds complexity without benefit.

### Virtualization

Use when rendering lists > 100 items or when items have complex DOM.

- `@tanstack/react-virtual` for large lists
- `react-window` for fixed-size lists
- Skip virtualization for < 50 items

## Forms

### Validation Approaches

| Approach | Best For |
|----------|----------|
| Controlled inputs + manual validate | Simple forms, few fields |
| React Hook Form + Zod | Complex forms, schema validation |
| Formik | Legacy codebases, complex validation |

### Key Patterns

- Validate on blur, not on every keystroke
- Show errors inline next to fields
- Disable submit until validation passes

## Common Mistakes

- **Over-using Context** — causes unnecessary re-renders across entire tree
- **Missing cleanup in useEffect** — subscriptions, intervals leak memory
- **Inline object/array creation in render** — breaks dependency equality, causes infinite loops
- **Not keying lists properly** — causes wrong item updates
- **Memoizing without measuring** — adds complexity for no gain
- **Storing derived state** — compute during render instead of syncing via effect
- **Fetching in useEffect without cancellation** — race conditions on prop changes

## Accessibility

### Required for All Interactive Components

- Keyboard navigation (Tab, Enter, Escape, Arrow keys)
- Focus management (save/restore focus for modals)
- ARIA attributes for custom controls (role, aria-expanded, aria-label)
- Visible focus indicators

### Common Patterns

- Modals: trap focus, save previous focus, restore on close
- Dropdowns: arrow key navigation, Escape to close
- Forms: label association, error messages linked to inputs

## References

For code examples, see `references/examples.md`:
- Component patterns (composition, compound components, render props)
- Custom hooks (useToggle, useQuery, useDebounce)
- State patterns (Context +Reducer)
- Performance patterns (virtualization, code splitting)
- Forms, error boundaries, animation, accessibility
