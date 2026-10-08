---
name: pure-function-pattern
description: Extract or implement deterministic TypeScript domain rules for validation, calculations, and transformations with explicit inputs and no observable side effects.
---

# Pure Function Pattern

Keep domain decisions separate from I/O. A pure function returns the same result for the same inputs and does not mutate inputs or shared state.

- Pass time, randomness, flags, and runtime lookups explicitly. Keep database, HTTP, and filesystem operations at the caller's boundary.
- Represent expected domain failures with the project's result type; a discriminated union such as `{ ok: true; value: T } | { ok: false; error: ErrorCode }` works when no convention exists.
- Keep helper return shapes consistent where the orchestrator must narrow them. Do not split each check into a helper unless it improves readability or reuse.
- Validate untrusted input at the I/O boundary; retain domain validation inside the rule.
- Use `import type` for ORM-generated types; use `Pick`/`Omit` when the function needs only part of that data shape.
- Export the public rule and helpers that callers need, not internals solely for tests.

For a refactor, preserve rule order and observable error precedence. Verify relevant boundaries, success paths, failure codes, and non-mutation through the public function using the project's testing conventions.

Read the matching section of [examples](references/examples.md) only when helpful:

- Coupon validation: time injection, usage limits, error precedence.
- Order pricing: immutable accumulation and discount capping.
- Service extraction: moving hidden dependencies and effects to the caller.
