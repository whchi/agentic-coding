---
name: js-ts-coding-standards
description: Use when writing or reviewing JavaScript or TypeScript for naming, type safety, immutability, async control flow, error handling, file organization, and code smell detection. Do NOT use for React architecture, useEffect rewrites, or REST API contract design.
origin: ECC
---

# JavaScript And TypeScript Coding Standards

Universal JavaScript and TypeScript code quality standards. This skill owns language-level maintainability, not React architecture or API contract design.

## When To Use

Use this skill for:
- naming conventions and file organization
- type safety, `any` avoidance, interfaces, type guards
- immutability at boundaries
- async control flow and concurrency
- error handling and input validation
- code smell detection during implementation or review

Do NOT use for:
- React component architecture, forms, accessibility, or render performance — use `frontend-patterns`
- direct `useEffect` review or rewrites — use `better-useeffect`
- REST endpoint contracts, status codes, pagination, or error shapes — use `api-design`

## Core Principles

### 1. Readability First

Code is read more than written. Prefer clear names and simple control flow over clever abstractions or explanatory comments.

### 2. Immutability At Boundaries

Do not mutate React state, function inputs, shared objects, or cached data directly. Local mutation is acceptable when it is contained, clearer, and not observable outside the function.

### 3. Explicit Over Implicit

Prefer explicit types, return values, and error handling at module boundaries. Let inference handle obvious local variables.

### 4. Fail Fast

Validate inputs early, return early, and throw meaningful errors before doing irreversible work.

## Key Patterns

### Immutability

```typescript
const updatedUser = { ...user, name: 'New Name' }
const nextItems = [...oldItems, newItem]

// Avoid mutating shared inputs or state directly.
user.name = 'New Name'
oldItems.push(newItem)
```

Use local mutation only when contained:

```typescript
function groupById(items: Item[]) {
  const groups: Record<string, Item[]> = {}

  for (const item of items) {
    groups[item.id] ??= []
    groups[item.id].push(item)
  }

  return groups
}
```

### Async Control Flow

```typescript
// Independent work should run in parallel.
const [users, markets] = await Promise.all([
  fetchUsers(),
  fetchMarkets()
])

// Sequential work is only for true dependencies.
const user = await fetchUser(userId)
const orders = await fetchOrders(user.id)
```

### Error Handling

```typescript
async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url)

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status} ${response.statusText}`)
  }

  return response.json() as Promise<T>
}
```

Rules:
- Do not swallow errors with empty `catch` blocks.
- Add context when rethrowing errors.
- Do not expose secrets, raw SQL errors, tokens, or stack traces to users.

### Type Safety

```typescript
interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
}

function getMarket(id: string): Promise<Market>
```

Avoid:

```typescript
function getMarket(id: any): Promise<any>
```

## Code Smells

| Smell | Detection | Fix |
|-------|-----------|-----|
| Long functions | Hard to scan, many responsibilities | Split by purpose, not by arbitrary line count |
| Deep nesting | 4+ levels or hard-to-follow branches | Early returns, guard clauses, extract functions |
| Magic values | Unexplained constants or strings | Named constants or domain enums |
| Shared mutation | Mutating inputs/state/cache | Return new values or isolate mutation locally |
| Missing types | `any`, implicit boundary types | Interfaces, generics, type guards |
| Catch-all handlers | Empty catch blocks or generic logs | Specific handling with useful context |
| Premature abstraction | One-off helper or indirection | Inline until the pattern repeats with stable shape |

## Gotchas

- **Async in loops** — `for...of` with `await` is sequential; use `Promise.all` only when operations are independent.
- **Defensive redundancy** — don't check the same invariant repeatedly; validate once at the boundary.
- **Type assertions hide bugs** — prefer narrowing and validation over `as SomeType`.
- **DRY too early** — duplication is cheaper than the wrong abstraction; wait for a stable repeated shape.
- **Mutable APIs leak** — copying once at a boundary is often cheaper than debugging shared mutation.

## References

For detailed examples, see:
- `references/naming-conventions.md` — variable, function, file naming
- `references/testing.md` — test structure, naming, AAA pattern
- `references/file-organization.md` — project structure, imports, file naming

Use related skills instead of duplicating their guidance:
- `frontend-patterns` for React component architecture, forms, accessibility, and performance patterns
- `better-useeffect` for direct `useEffect` review or rewrites
- `api-design` for REST endpoint contracts, status codes, pagination, and error responses
