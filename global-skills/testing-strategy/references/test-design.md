# Test Design

Name the behavior and choose the narrowest existing test surface that can expose a violation.

| Behavior under test | Useful level |
| --- | --- |
| A calculation, domain invariant, or isolated use case | Unit |
| Translation, persistence, or interaction between real components | Integration |
| A complete user path and its observable result | E2E |

Choose by the contract, not layer names alone. An API-through-persistence check may be the end-to-end surface for a backend.

## Dependencies and fixtures

- Mock third-party services in unit tests. Use a fake for controlled state or real local dependencies when their interaction is the subject; do not mock away the requirement.
- Use the established test database when its semantics fit. Dialect, transaction, lock, index, JSON, timezone, or migration behavior may require the production database engine in an isolated test environment.
- Build deterministic fixtures from actual schemas. Include the relationships, ownership, boundaries, and failure states needed for this behavior, not a universal catalogue of every status and optional field.
- In DDD code, keep aggregate behavior real for invariant tests; fake repository interfaces for orchestration and exercise repository implementations against the relevant persistence layer.

## Review and recommendation

Ask whether the test fails when the required behavior breaks. Check concrete outputs, state, or required interactions; presence or absence can itself be the contract. Avoid assertions that only observe mock setup.

For advice-only work, return the proposed cases, level, dependency/data choices, and known commands. Do not modify the product or describe unrun checks as passed. When implementation is authorized, follow the entrypoint's scope and test-first conditions.
