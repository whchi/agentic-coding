---
name: js-ts-coding-standards
description: Use when writing or reviewing TypeScript, JavaScript, React, or Node.js code. Invoke for naming conventions, immutability patterns, async best practices, component structure, and code smell detection.
origin: ECC
---

# Coding Standards & Best Practices

Universal coding standards for TypeScript, JavaScript, React, and Node.js development.

## Core Principles

### 1. Readability First
Code is read more than written. Prefer clear names over comments.

### 2. Immutability (Critical)
Never mutate state directly. Always use spread operator or return new values.

### 3. Explicit > Implicit
Prefer explicit types, explicit returns, explicit error handling.

### 4. Fail Fast
Validate inputs early, return early, throw meaningful errors.

## Key Patterns

### Immutability

```typescript
// ✅ ALWAYS use spread operator
const updated = { ...user, name: 'New Name' }
const items = [...oldItems, newItem]

// ❌ NEVER mutate directly
user.name = 'New Name'      // BAD
items.push(newItem)          // BAD
```

### Async/Await

```typescript
// ✅ Parallel when independent
const [users, markets] = await Promise.all([
  fetchUsers(),
  fetchMarkets()
])

// ❌ Sequential when unnecessary
const users = await fetchUsers()
const markets = await fetchMarkets()
```

### Error Handling

```typescript
// ✅ Comprehensive error handling
async function fetchData(url: string) {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return await response.json()
  } catch (error) {
    console.error('Fetch failed:', error)
    throw new Error('Failed to fetch data')
  }
}
```

### Type Safety

```typescript
// ✅ Proper types
interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
}

function getMarket(id: string): Promise<Market>

// ❌ Using 'any'
function getMarket(id: any): Promise<any>
```

## Code Smells

| Smell | Detection | Fix |
|-------|-----------|-----|
| Long functions | > 50 lines | Split into smaller functions |
| Deep nesting | 5+ levels | Early returns, extract functions |
| Magic numbers | Unexplained constants | Named constants |
| Mutable state | Direct mutations | Spread operator, immutable updates |
| Missing types | `any`, implicit | Explicit interfaces, type guards |
| Catch-all handlers | Empty catch blocks | Specific error handling, logging |

## Gotchas

- **Over-memoization** — `useMemo`/`useCallback` add complexity; only use when profiling shows re-renders are a problem
- **Premature abstraction** — DRY doesn't mean deduplicate immediately; wait for the third instance
- **Defensive redundancy** — Don't check for null twice; trust your types
- **Async in loops** — `for...of` with `await` is sequential; use `Promise.all` for parallel
- **Stale closures** — Variables in async callbacks can be stale; use refs or functional updates

## References

For detailed examples, see:
- `references/naming-conventions.md` — Variable, function, file naming
- `references/react-patterns.md` — Components, hooks, state management
- `references/api-design.md` — REST conventions, validation, responses
- `references/testing.md` — Test structure, naming, AAA pattern
- `references/file-organization.md` — Project structure, file naming
