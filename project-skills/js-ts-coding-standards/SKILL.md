---
name: js-ts-coding-standards
description: Review or standardize JavaScript and TypeScript naming, type boundaries, mutation, and async error handling when code conventions are the task.
origin: ECC
---

# JavaScript and TypeScript Coding Standards

Follow local conventions. Apply the standards relevant to the changed code rather than reformatting or reorganizing unrelated modules.

- Do not mutate inputs, state, shared objects, or caches. Contained local mutation is acceptable when it is clearer and cannot escape.
- Make module boundaries explicit; let inference handle obvious locals.
- Validate untrusted data at the boundary and derive types from authoritative schemas. Type assertions do not perform validation.
- Use discriminated unions for states that would otherwise allow contradictory fields. Check exhaustiveness when all variants require handling.
- Introduce branded primitives only when confusion between domain IDs is a real risk.
- Run independent async operations concurrently when resource and rate limits allow it; preserve ordering for dependent work and side effects.
- Handle failures explicitly. Do not swallow errors or expose secrets, raw SQL errors, tokens, or stack traces to users.
- Keep functions and modules organized by responsibility; avoid arbitrary line limits or abstractions for single-use code.

Read a reference only when that convention needs attention:

- [Naming](references/naming-conventions.md): names, boolean predicates, domain vocabulary.
- [File organization](references/file-organization.md): existing module boundaries, imports, exports.
- [Testing](references/testing.md): test organization and examples when editing tests.

These references are examples, not a mandate to replace the project's architecture or test framework. React architecture, effects, and REST contracts belong to their specific workflows.
