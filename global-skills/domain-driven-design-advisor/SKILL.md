---
name: domain-driven-design-advisor
description: Use when deciding whether and how to apply DDD, bounded contexts, aggregates, aggregate roots, entities, value objects, domain services, application services, or clean/onion architecture. Do NOT use for ordinary folder cleanup or isolated repository behavior placement.
---

# Domain Driven Design Advisor

Use this skill when DDD may help, but do not assume DDD is always the right answer.

## Boundaries

Use related skills for implementation-level follow-through:

- `project-structure-advisor` for arranging folders and modules once the architectural direction is chosen.
- `repository-boundary-review` for checking whether concrete repository/service/use-case code owns the right behavior.
- `testing-strategy` for domain, application, repository, and adapter test coverage.

## Fit First

DDD is strongest when the core business domain is valuable, complex, and shared between engineers and domain experts. It gives better modularity, stronger business language, and clearer isolation for larger teams or service boundaries.

DDD is often too expensive when the product is early, the team is small, domain expertise is missing, or most behavior is simple CRUD. In those cases, use MVC or feature-based structure and adopt only the smallest useful DDD ideas.

## Problem Space

Classify domains:

- Core domain: the business area that creates the most value or differentiation.
- Supporting subdomain: needed to support the core domain.
- Generic subdomain: common capability better handled by existing tools or services, such as payments or auth unless they are the product.

## Solution Space

Use bounded contexts to separate language and behavior. The same word can mean different things in different contexts, such as `account` in a blog, bank, or social product.

Legacy systems and external services should usually be their own context behind adapters. Do not let an external domain model leak inward.

## Layering

Default dependency direction:

```text
UI layer -> Application layer -> Domain layer <- Infrastructure adapters
```

Outer layers may call inward. Inner layers must not know about outer mechanisms.

- UI: routes, presenters, formatters, request parsing, validators.
- Application: use cases, application services, DTOs, interface adapters.
- Domain: aggregate roots, entities, value objects, domain services, repository interfaces.
- Infrastructure: ORM, DAO, DB, repository implementations, vendor SDKs.

The inner circle is policy. The outer circle is mechanism.

## Aggregates

An aggregate is a consistency boundary. Each aggregate has one aggregate root.

Rules:

1. Clients access entities through the aggregate root.
2. One transaction should usually update one aggregate root and its owned entities.
3. The aggregate protects its own invariants and prevents invalid state.
4. Reference other aggregates by ID, not loaded object references.
5. Keep aggregates small.
6. Use factories when aggregate creation becomes complex.
7. One repository usually corresponds to one aggregate root.

## Entities And Value Objects

Entity:

- Has identity and lifecycle.
- It is not an entity merely because it has an ID.
- Use an entity when identity over time matters.

Value object:

- Has no identity.
- Describes a concept by its attributes.
- Should be immutable or replace-as-a-whole.
- Should have no side effects.

## Repository Guidance

Repositories operate on aggregate roots and hide persistence details from application/domain code.

Repository interfaces belong with the domain/application boundary. Repository implementations live in infrastructure or interface adapters.

The repository may use ORM entities, DAO, DTO, or query builders internally, but callers should see domain concepts or application-level results.

When ORM models already contain useful behavior, decide pragmatically whether to wrap, adapt, or keep them. Do not force separate DDD entities for every table if the domain does not benefit.

## Workflow

1. Decide if DDD is worth its cost for this project and team.
2. Name the core domain and candidate bounded contexts.
3. Identify aggregate roots and invariants.
4. Separate entities from value objects by lifecycle and identity.
5. Define repository interfaces around aggregate roots.
6. Keep application services focused on input/output orchestration and use case flow.
7. Keep domain objects free from UI, framework, ORM, and vendor details.
8. Start with one high-value domain before spreading the pattern across the codebase.

## Output

Return:

- DDD fit assessment
- Bounded contexts
- Aggregate roots and invariants
- Entity/value object candidates
- Repository boundaries
- Layering changes
- Smallest adoption plan
