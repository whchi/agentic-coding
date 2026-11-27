# Pure Function Pattern (Functional Core, Imperative Shell)

Separate deterministic domain decisions (**Functional Core**) from I/O and orchestration (**Imperative Shell**). A pure function exhibits **referential transparency**: it returns the same result for the same inputs and does not mutate inputs or shared state.

- **Explicit dependency injection:** pass wall-clock time (`now: Date`), randomness, feature flags, and pre-fetched lookups as parameters. Keep database, HTTP, filesystem, and global config reads in the imperative shell.
- **Typed error channel:** represent expected domain rejections with the project's **Result / Either** discriminated union (e.g., `{ ok: true; value: T } | { ok: false; error: ErrorCode }`), reserving thrown exceptions for unexpected defects.
- **Uniform narrowing:** keep internal helper return shapes consistent where the orchestrator narrows them. Do not split trivial single checks into helpers unless it improves readability or reuse.
- **Parse at the shell, enforce invariants in the core:** parse untrusted transport input at the I/O boundary; retain domain-invariant checks inside the pure rule.
- **Minimal type coupling:** use `import type` for ORM/transport types and narrow inputs with `Pick`/`Omit` or a dedicated input interface when the rule needs only a subset of fields.
- **Cohesive exports:** export the public rule and genuinely reused helpers — never expose private internals solely to appease unit tests.

When refactoring existing logic, preserve rule order and observable error precedence. Verify boundary conditions, error precedence, and non-mutation through the public entry point using the project's testing conventions.

Read [pure function examples](pure-functions-examples.md) for a concise impure-to-pure Functional Core / Imperative Shell refactoring example.
