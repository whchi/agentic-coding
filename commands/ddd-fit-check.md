---
description: "Assess whether DDD is justified before adopting aggregates, repositories, domain services, or domain-based folders."
---

# /ddd-fit-check

Assess the proposed adoption against actual business rules, change pressure, and team needs. Use `domain-driven-design-advisor` when available for the full assessment; otherwise make the bounded assessment directly.

Read `CONTEXT.md` for relevant domain language, `CONTEXT-MAP.md` when context boundaries matter, and only ADRs that constrain the proposal. Missing documents are unknowns, not permission to invent a domain model.

Return the fit (strong, partial, weak, or insufficient evidence), supporting evidence, material unknowns, and smallest useful next step. Consider whether existing MVC or function-based organization is enough. Say `No DDD adoption recommended` when appropriate.

This command assesses fit. If implementation is already part of the user's request, continue through the chosen change and its relevant verification within that authorization; otherwise leave a recommendation.
