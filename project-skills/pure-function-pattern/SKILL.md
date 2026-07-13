---
name: pure-function-pattern
description: Use when implementing or refactoring non-trivial TypeScript domain rules that should have no side effects, such as validation, calculations, or data transformations. Use `better-test-driven-development` for test-first sequencing and `testing-strategy` for test level, mocking, and fixture choices.
---

# Pure Function Pattern

## Boundaries

This skill owns purity, explicit dependencies, return shapes, and domain-rule boundaries. Use `better-test-driven-development` for test-first sequencing and `testing-strategy` for test level, mocking, and fixture choices.

## Skip When

- The logic inherently requires side effects (DB writes, HTTP calls, file I/O) — those belong in service or repository layers
- The function is a thin adapter/mapper with no real logic to test

## What the Skill Produces

1. **Type definitions** — input payload types, response types, and error code unions. When referencing ORM-generated types, use `Pick`/`Omit` to avoid importing runtime behavior.
2. **Helper functions** — one function per independent rule, returning the consistent discriminated union: `{ ok: true } | { ok: false; error: SomeError }`.
3. **Main pure function** — orchestrates helpers in logical order with TypeScript narrowing. All runtime-variable values (current time, random values, feature flags, lookup tables) must be passed as explicit arguments — never read from the environment or module scope.
4. **Test contract** — identify the branches, boundaries, and success paths that need coverage. Follow the project's test strategy and test-first workflow instead of imposing a framework or mock policy here.
5. **Public interface** — keep the main function and only the helpers that callers or tests genuinely need public; do not export internals solely to make them testable.

## Quality Criteria

- **Absolute purity**: Same inputs → same outputs, always. No observable side effects, no input mutations.
- **No exceptions as control flow**: Express all error paths through return types — never `throw`.
- **Time/randomness as data**: Pass `currentTime`, `randomSeed`, precomputed lookups, and feature flags as explicit parameters.
- Runtime validation (schemas, parsing) belongs at the I/O boundary, not inside pure modules.
- Tests should assert stable error codes or other public behavior; do not require incidental message text unless it is part of the contract.
- File naming: `<feature>.ts` and `<feature>.test.ts` in the same directory.

## Examples

See `references/examples.md` for three fully worked examples:

1. **Coupon validation** — discriminated union helpers, time injection, usage limits, order-of-checks tests
2. **Order price calculation** — immutable multi-step accumulation, discount capping
3. **Refactoring before/after** — annotated impure function with each violation called out and fixed

Read the relevant example when you need to see the full file structure or test patterns in action.

## Implementation Steps

1. Read the description or code sample. Identify all independent checks, the input shape, and any values that change at runtime (time, random, flags, lookups). Every such value becomes an explicit parameter.
2. Define the public behavior and let `better-test-driven-development` establish the failing test before implementation.
3. Produce the TypeScript file. All helpers must be pure, non-mutating, non-throwing, returning the consistent `{ ok: true } | { ok: false; error: ... }` union. Use the repository's configured test framework and `testing-strategy` guidance for coverage and test doubles.
4. If refactoring existing code, explicitly call out any purity violations found: hidden dependencies, mutations, throws used as control flow, inconsistent return shapes.

## Gotchas

- **Inconsistent return shapes**: mixing `{ ok: false; error }` with `ValidationError | null` across helpers makes the main function impossible to type-narrow cleanly. Pick one shape and apply it everywhere.
- **`Date.now()` inside the function**: even one call makes the function non-deterministic. Always inject the current time as a parameter.
- **Throw-on-invalid is not purity**: if a helper throws for an expected error case (e.g., "coupon not found"), callers need try/catch instead of type narrowing — encode it in the return type.
- **Partial refactors leave hidden dependencies behind**: after extracting logic from a larger service, verify runtime values and side effects are explicit at the boundary.
- **ORM type imports**: importing a Prisma/Drizzle model type directly can pull in runtime behavior. Use `Pick`/`Omit` to extract only the plain-data shape you need.
