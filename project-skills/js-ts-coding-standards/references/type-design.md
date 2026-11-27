# Type Design at Boundaries

Read the section relevant to the changed type or function. Preserve the project's schema library and branding conventions; do not add dependencies or redesign unrelated interfaces to match these examples.

## Function parameters

Prefer at most three positional parameters; when a function needs more than three inputs (or easily swapped arguments of the same primitive type), accept a single options object and destructure it in the parameter list. Preserve existing public signatures and standard callback/framework signatures (e.g., `Array.prototype.reduce`, Express `(err, req, res, next)`).

```typescript
function createUser({ name, email, role, active }: {
  name: string
  email: string
  role: string
  active: boolean
}) {
  return { name, email, role, active }
}
```

## Parse, don't validate (schema ownership)

Treat untrusted payloads as `unknown` until parsed at the boundary. Derive static types from the authoritative runtime schema rather than maintaining a schema, interface, and manual guard independently. Generated protocol types define wire shape but do not validate incoming bytes.

```typescript
// When the project uses Zod:
const UserSchema = z.object({ id: z.string(), name: z.string() })
type User = z.infer<typeof UserSchema>

function parseUser(input: unknown): User {
  return UserSchema.parse(input)
}
```

Use a non-throwing parse result (`safeParse`) when invalid input is an expected branch. Without a schema library, a type predicate must prove every property it claims:

```typescript
function isStringArray(value: unknown): value is string[] {
  return Array.isArray(value) && value.every(item => typeof item === 'string')
}
```

Prefer discriminant, `typeof`, or `in` narrowing over `as` assertions. Checking `'prop' in obj` proves key presence, not its value's type. Keep unavoidable `as` assertions localized to a validated invariant (such as a branded constructor); do not blanket-ban `as const`.

## Make illegal states unrepresentable (sum types & exhaustiveness)

Use a **discriminated (tagged) union** whenever field presence depends on state so contradictory combinations cannot compile, and enforce **`never` exhaustiveness checking** across handlers:

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

Exhaustiveness is a compile-time proof over trusted typed values, not runtime validation of external input.

## Nominal typing & stronger invariants only when earned

TypeScript uses **structural typing** by default. Introduce **nominal (branded/opaque) primitives** only when confusing domain values (e.g., `UserId` vs `OrderId`, `Cents` vs `Dollars`) or bypassing a validated invariant is a concrete bug risk.

Keep plain arrays for operations that handle empty input (e.g., summing from zero). Require a non-empty tuple (`readonly [T, ...T[]]`) only when callers can establish non-emptiness and the operation requires a head element; prefer `readonly` so mutation cannot invalidate the guarantee. Numeric ranges (e.g., non-negative duration) still require runtime validation at construction.

## Checked configuration and derived types

Use `satisfies` to validate assignability while preserving narrower literal inference; combine with `as const` when deep `readonly` literals are intended (neither validates runtime input):

```typescript
type DisplayConfig = { theme: 'light' | 'dark'; columns: number }
const config = { theme: 'dark', columns: 3 } as const satisfies DisplayConfig
```

Use utility types (`Pick`, `Omit`, `ReturnType`, `Awaited`) when coupling to an owning contract is intentional. Keep an independent domain or public type when it must evolve separately from storage or transport models.
