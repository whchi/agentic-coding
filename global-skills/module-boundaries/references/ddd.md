# Domain-Driven Design Fit and Modeling

Evaluate whether DDD is worth its cost before adopting aggregates, repositories, domain services, or domain-based folders. Do not assume DDD is always the right answer.

## Fit First

Read `CONTEXT.md` for relevant domain language, `CONTEXT-MAP.md` when context boundaries matter, and only ADRs that constrain the proposal. Missing documents are unknowns, not permission to invent a domain model.

DDD is strongest when the core business domain is valuable, complex, and shared between engineers and domain experts. It gives better modularity, stronger business language, and clearer isolation for larger teams or service boundaries.

DDD is often too expensive when the product is early, the team is small, domain expertise is missing, or most behavior is simple CRUD. In those cases, use MVC or feature-based structure and adopt only the smallest useful ideas. Say `No DDD adoption recommended` when appropriate; weak fit or insufficient evidence does not require inventing bounded contexts or aggregates.

## Problem Space

Classify domains:

- Core domain: the business area that creates the most value or differentiation.
- Supporting subdomain: needed to support the core domain.
- Generic subdomain: common capability better handled by existing tools or services, such as payments or auth unless they are the product.

## Solution Space

Use bounded contexts to separate language and behavior. The same word can mean different things in different contexts, such as `account` in a blog, bank, or social product.

Legacy systems and external services should usually be their own context behind adapters. Do not let an external domain model leak inward.

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

## Entities and Value Objects

Entity:

- Has identity and lifecycle.
- It is not an entity merely because it has an ID.
- Use an entity when identity over time matters.

Value object:

- Has no identity.
- Describes a concept by its attributes.
- Should be immutable or replace-as-a-whole.
- Should have no side effects.

## Aggregate Persistence

Repositories operate on aggregate roots and hide persistence details from application/domain code.

When ORM models already contain useful behavior, decide pragmatically whether to wrap, adapt, or keep them. Do not force separate DDD entities for every table if the domain does not benefit.

## Output

Report only the decisions relevant to the requested scope:

- DDD fit (strong, partial, weak, or insufficient evidence) with supporting evidence and material unknowns
- Bounded contexts, aggregate roots and invariants, entity/value object candidates, repository boundaries, and layering changes (when applicable)
- Smallest useful next step or adoption plan
