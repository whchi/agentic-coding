---
name: pure-function-pattern
description: This skill helps developers generate and refactor business logic into clean, testable, and deterministic pure function modules. It enforces strict separation from side effects, ensures immutability, and prepares the output for zero-mock unit testing by downstream agents.
---

# Pure Function Pattern Skill

This skill helps generate clean, testable pure function modules in the style used throughout the billboard-backend codebase. It assumes the user will provide either a description of the logic or an existing implementation that can be refactored into a module of small, deterministic helpers with a single exported entry point and a comprehensive suite of Vitest tests.

## When to invoke
- You want to implement a business rule or validation logic that has strictly **no side effects** (no database calls, no network, no reading from `process.env`).
- The logic must be **deterministic**: it cannot rely on global hidden state like `Date.now()` or `Math.random()`. Such values must be explicitly passed as input parameters.
- You already have a code snippet and want to restructure it into reusable helpers plus a top-level `validateXxx`/`calculateXxx` function.

## What the skill produces
1. **Type definitions** – input payload types, response types, and error code unions. If referencing `Prisma` generated types, use them purely as plain data interfaces via `Pick` or `Omit` to avoid importing any runtime Prisma behaviour into the pure module.
2. **Helper functions** – each independent rule gets its own `checkSomething()` function. These must not mutate inputs, must not throw, and must not produce side effects. Each helper must return a consistent discriminated union: `{ ok: true } | { ok: false; error: ValidationError }`. Do not mix this with nullable returns (`ValidationError | null`) — pick one shape and apply it uniformly across the module.
3. **Response builder** – a pure mapping function that transforms the domain object into a serializable output. It must always return a value (never throw), must not mutate its input, and must have no dependencies beyond its arguments.
4. **Main pure function** – orchestrates helpers in logical order, performs TypeScript narrowing, and returns a predictable `ValidationResult` union type. Add a block comment describing the validation sequence. All external dependencies (current time, random values, precomputed lookup tables, feature flags, etc.) must be passed as explicit arguments — nothing is read from the environment or module scope.
5. **Unit tests** – colocated `.test.ts` file. Provide factory helpers (e.g., `createMockCoupon`) with reasonable default values. Cover every branch: missing data, each error code, boundary conditions, order-of-checks assertions, and success responses. **Since these are pure functions, strictly NO `vi.mock()` should be used in this file.** Every scenario is tested purely via input object variations.
6. **Export statements** – export all helpers and types when expected to be used elsewhere.

## Quality criteria
- **Absolute Purity**: Every function — helpers, response builders, and the main entry point — must be pure: same inputs always produce the same output, with no observable side effects and no mutations of input parameters.
- **No Exceptions as Control Flow**: Pure functions must not `throw`. All error paths must be expressed through the return type. Use the `{ ok: false; error: ... }` discriminated union rather than exceptions.
- **Time/Randomness as Data**: If logic depends on the current time or random generation, those values must be passed in as arguments (e.g., `currentTime: Date`). The same applies to any precomputed data such as whitelists, lookup tables, or feature flags — they must arrive as explicit parameters, not be derived inside the function.
- Use explicit `!== undefined` checks for optional numeric/boolean fields following codebase convention.
- Use `localeCompare` with `numeric: true` for natural sorting if the logic involves string arrays.
- Use `zod` schemas only at the route boundary; pure modules should rely on TypeScript types.
- Tests must assert the exact error message strings and error codes used in the helpers using Vitest (`describe`, `it`, `expect`).
- File naming: `<feature>.ts` and `<feature>.test.ts`, placed in the same directory under services or utilities depending on context.

## Example prompt (to the bot)
```
Here's a description of coupon validation logic that needs to be implemented:
- coupon may be null
- status must be ACTIVE
- valid_from/valid_until bounds (requires passing 'now' as a Date parameter)
- global usage limit
- whitelist/product restrictions passed in as precomputed lookup parameters
- per-user limit with claim override

Generate a pure `validateCoupon` module along with types, helpers, and tests following our project conventions.
```

## Implementation steps for the agent
1. Read the provided description or code sample. Identify all independent checks, the input data shape, and any values that change at runtime (current time, random values, precomputed lookups, flags). Every such value must become an explicit parameter — never read inside the function.
2. Produce the TypeScript file with strict type definitions. All helpers must be pure, immutable, non-throwing, and return the consistent `{ ok: true } | { ok: false; error: ValidationError }` discriminated union.
3. Create the corresponding Vitest file with comprehensive input-output testing scenarios without any mocks.
4. If the user already has one module, refactor it to this structure and explicitly call out any purity violations found (hidden dependencies, mutations, throws used as control flow, inconsistent return shapes).
