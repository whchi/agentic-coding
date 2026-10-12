# Type Design at Boundaries

Read the section relevant to the changed type or function. Preserve the project's schema library and branding conventions; do not add dependencies or redesign unrelated interfaces to match these examples.

## Unknown inputs and schema ownership

Treat untrusted payloads as `unknown` until validated. Prefer an existing runtime schema and derive its type rather than maintaining a schema, interface, and property-by-property guard independently. Generated protocol types are authoritative for their shape, but do not themselves validate incoming bytes.

```typescript
// When the project already uses Zod:
const UserSchema = z.object({ id: z.string(), name: z.string() })
type User = z.infer<typeof UserSchema>

function parseUser(input: unknown): User {
  return UserSchema.parse(input)
}
```

Use the library's non-throwing parse result when invalid input is an expected branch. For a small check with no schema system, a guard is sufficient, but it must establish everything its predicate promises:

```typescript
function isStringArray(value: unknown): value is string[] {
  return Array.isArray(value) && value.every(item => typeof item === 'string')
}
```

Prefer direct discriminant, `typeof`, or `in` narrowing when it proves the needed fact. A property existing does not establish its value's type. An `as` assertion provides no runtime proof; keep unavoidable assertions local to a documented invariant, such as a validated brand constructor. Do not blanket-ban `as const` or replace working narrowing with new wrappers.

## State variants and exhaustive handling

Use a discriminated union when fields depend on the state. This excludes contradictory combinations without making every property optional.

```typescript
type LoadState<T> =
  | { kind: 'loading' }
  | { kind: 'ready'; value: T }
  | { kind: 'failed'; message: string }

function statusText(state: LoadState<string>): string {
  switch (state.kind) {
    case 'loading': return 'Loading'
    case 'ready': return state.value
    case 'failed': return state.message
    default: {
      const unhandled: never = state
      return unhandled
    }
  }
}
```

Adding a variant now requires updating handlers that cover every case. This is a compile-time check for trusted typed values, not runtime validation of external inputs.

## Stronger inputs only when needed

Keep plain arrays for operations that already handle empty input, such as summing from zero. For an operation needing a first element, either accept absence in the return type or require a non-empty input when callers can establish it.

```typescript
type NonEmpty<T> = readonly [T, ...T[]]

function first<T>(items: NonEmpty<T>): T {
  return items[0]
}

function hasItems<T>(items: readonly T[]): items is NonEmpty<T> {
  return items.length > 0
}
```

Non-empty does not prove an arbitrary numeric index is in bounds. Prefer `readonly` when mutation could invalidate the guarantee. Grouping values as pairs can encode pair structure; changing a time range to `{ start: Date; durationMs: number }` cannot prove a non-negative duration. Numeric constraints still need validation at creation. Introduce branded primitives only for a concrete domain distinction or validated invariant that callers need to preserve.

## Checked configuration and derived types

Use `satisfies` to check assignability without replacing an expression's inferred type with an assertion. Use `as const` when literal preservation and readonly properties are intended; neither construct validates external data.

```typescript
type DisplayConfig = { theme: 'light' | 'dark'; columns: number }
const config = { theme: 'dark', columns: 3 } as const satisfies DisplayConfig
```

Derive a type when the owning contract should propagate its changes:

```typescript
type UserSummary = Pick<User, 'id' | 'name'>
```

Use `Pick`, `Omit`, `ReturnType`, or `Awaited` where that dependency is intentional. Keep a separate domain or public contract when it must evolve independently of storage, transport, or implementation details. Object parameters help distinguish several easily swapped arguments; they are not a requirement for every function.
