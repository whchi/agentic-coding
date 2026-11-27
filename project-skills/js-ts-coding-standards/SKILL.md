---
name: js-ts-coding-standards
description: Review or standardize JavaScript and TypeScript naming, type boundaries, mutation, async error handling, or deterministic pure domain rules when code conventions or side-effect isolation are the task.
origin: ECC
---

# JavaScript and TypeScript Coding Standards

Follow local conventions. Apply standards relevant to the changed code rather than reformatting or reorganizing unrelated modules.

- **Immutability & referential transparency:** do not mutate inputs, state, shared objects, or caches. Contained local mutation is acceptable only when clearer and unobservable outside the function.
- **Explicit module contracts:** annotate exported function/module boundaries; let inference handle obvious locals.
- **Parse, don't validate:** treat external/untrusted payloads as `unknown` at the I/O boundary, parse with the project's authoritative schema, and derive static types from it. Type assertions (`as`) provide zero runtime safety.
- **Make illegal states unrepresentable:** model mutually exclusive states with **discriminated (tagged) unions** and **`never` exhaustiveness checking**. Use **nominal (branded/opaque) types** only when structural typing creates a real risk of swapping domain IDs or units.
- **Bounded concurrency & structured async:** run independent async work concurrently with **bounded concurrency / backpressure** when resource or rate limits apply; choose `Promise.all` (fail-fast) vs `Promise.allSettled` (partial failure) intentionally, propagate **`AbortSignal`** for cancellation, and preserve ordering for dependent side effects.
- **Typed error channels & error cause chaining:** represent expected domain failures with explicit **Result / discriminated union** returns and reserve thrown exceptions for unexpected defects; wrap low-level errors with `new Error(msg, { cause })`. Never swallow errors or leak secrets, raw SQL errors, tokens, or stack traces.
- Keep functions and modules cohesive by responsibility; avoid arbitrary line limits or premature abstractions for single-use code.

Read a reference only when that area needs attention:

- [Naming](references/naming-conventions.md): domain vocabulary, boolean predicates, units, and file naming.
- [Type design](references/type-design.md): Parse-don't-validate, positional vs options-object parameters, discriminated unions, exhaustiveness, branded types, and `satisfies`.
- [File organization](references/file-organization.md): colocation, `import type`, and barrel-file tree-shaking / circular-dependency hazards.
- [Pure functions](references/pure-functions.md): **Functional Core, Imperative Shell** — extracting deterministic TypeScript domain rules with explicit dependency injection and no observable side effects.
- [Testing](references/testing.md): JS/TS runtime testing pitfalls (fake timers, mock lifecycle cleanup, async rejections, type-level assertions).

These references are conventions to apply proportionally, not a mandate to replace the project's architecture or test framework. React architecture/effects belong to `frontend-patterns`; REST contracts to `api-design`; test levels and dependency strategy to `testing-strategy`.
