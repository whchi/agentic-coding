---
name: pure-function-pattern
description: Use when implementing or refactoring business logic that should have no side effects — validation rules, calculations, data transformations, or any logic that can be expressed as input-in, output-out. Invoke this skill whenever someone asks to write testable business logic, extract logic from services, or eliminate mocks from unit tests.
---

# Pure Function Pattern

## Skip When

- The logic inherently requires side effects (DB writes, HTTP calls, file I/O) — those belong in service or repository layers
- The function is a thin adapter/mapper with no real logic to test

## What the Skill Produces

1. **Type definitions** — input payload types, response types, and error code unions. When referencing ORM-generated types, use them via `Pick`/`Omit` to avoid importing runtime behavior.
2. **Helper functions** — one function per independent rule. Each must: not mutate inputs, not throw, not produce side effects, and return a consistent discriminated union: `{ ok: true } | { ok: false; error: SomeError }`.
3. **Response builder** — a pure mapping function that transforms domain data into serializable output. Always returns a value, never throws, no dependencies beyond its arguments.
4. **Main pure function** — orchestrates helpers in logical order with TypeScript narrowing. All runtime-variable values (current time, random values, feature flags, lookup tables) must be passed as explicit arguments — never read from the environment or module scope.
5. **Unit tests** — colocated `.test.ts` file using factory helpers (e.g., `createMockOrder`) with sensible defaults. Cover every branch: missing data, each error code, boundary conditions, order-of-checks, and success paths. No `vi.mock()` — every scenario is exercised through input variations only.
6. **Exports** — export all helpers and types that are expected to be used elsewhere.

## Quality Criteria

- **Absolute purity**: Same inputs → same outputs, always. No observable side effects, no input mutations.
- **No exceptions as control flow**: Express all error paths through return types. Use `{ ok: false; error: ... }` unions, not `throw`.
- **Time/randomness as data**: Pass `currentTime`, `randomSeed`, precomputed lookups, and feature flags as explicit parameters — never derive them inside the function.
- Use `zod` schemas only at the route/API boundary; pure modules rely on TypeScript types only.
- Tests assert exact error codes and message strings.
- File naming: `<feature>.ts` and `<feature>.test.ts` in the same directory.

## Examples

See `references/examples.md` for three fully worked examples:

1. **Coupon validation** — discriminated union helpers, time injection, usage limits, order-of-checks tests
2. **Order price calculation** — immutable multi-step accumulation, discount capping
3. **Refactoring before/after** — annotated impure function with each violation called out and fixed

Read the relevant example when you need to see the full file structure or test patterns in action.

## Implementation Steps

1. Read the description or code sample. Identify all independent checks, the input shape, and any values that change at runtime (time, random, flags, lookups). Every such value becomes an explicit parameter.
2. Produce the TypeScript file with strict types. All helpers must be pure, non-mutating, non-throwing, returning the consistent `{ ok: true } | { ok: false; error: ... }` union.
3. Create the colocated Vitest test file with comprehensive input/output coverage and zero mocks.
4. If refactoring existing code, explicitly call out any purity violations found: hidden dependencies, mutations, throws used as control flow, inconsistent return shapes.

## Gotchas

- **Inconsistent return shapes are a silent bug**: mixing `{ ok: false; error }` with `ValidationError | null` across helpers makes the main function impossible to type-narrow cleanly — pick one shape and apply it everywhere.
- **`Date.now()` inside the function breaks testability**: even one call makes the function non-deterministic. Always inject the current time as a parameter.
- **Throw-on-invalid is not purity**: if a helper throws for an expected error case (e.g., "coupon not found"), callers need try/catch instead of type narrowing — encode it in the return type instead.
- **Partial refactors leave mocks behind**: when extracting logic from a larger service, it's easy to miss one dependency that sneaks back in. After refactoring, verify the test file has zero `vi.mock()` calls.
- **ORM type imports**: importing a Prisma/Drizzle model type directly can pull in runtime behavior. Use `Pick`/`Omit` to extract only the plain-data shape you need.
