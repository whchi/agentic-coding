---
name: repository-boundary-review
description: Review responsibility placement when behavior may belong in persistence, an application use case, or a domain aggregate.
---

# Repository Boundary Review

Use this skill to keep persistence access separate from business behavior.

## Boundaries

Use related skills when the question is broader or narrower:

- `project-structure-advisor` for folder/module organization.
- `domain-driven-design-advisor` for DDD fit, aggregate discovery, and bounded context modeling.
- `api-design` for request/response contracts and user-facing error shapes.
- `testing-strategy` for deciding which layer needs coverage after moving behavior.

## Principle

Business logic is the operation between user-facing IO and data. Repository code abstracts access to data and aggregate roots; it should not become the place where product behavior silently lives.

Repository code usually contains CRUD, queries, persistence mapping, and aggregate retrieval. Use cases/services decide how those results serve the user or workflow.

In DDD, one repository usually corresponds to one aggregate root. The aggregate root is the only object clients should obtain through the repository, and repository operations should preserve the aggregate as a consistency boundary.

## Boundary Rules

Repository may:

- Query and persist data.
- Encapsulate ORM, DAO, DTO, and model access.
- Provide named queries that reflect data retrieval intent.
- Hide DB-specific details from higher layers.
- Build domain models or aggregate roots from persistence data.
- Reference other aggregates by ID instead of loading them as object graphs.

Repository should avoid:

- Pagination or display decisions unless they are part of the data access contract.
- User-facing formatting.
- Authorization decisions.
- Workflow state transitions that belong to use cases.
- Error messages intended for API users.
- Returning arbitrary child entities that bypass aggregate root invariants.
- Managing multiple aggregate roots in one transaction unless there is an explicit consistency reason.
- Letting ORM entity shape become the public domain model by accident.

Use case/service may:

- Coordinate repositories.
- Apply business rules.
- Paginate or shape data for workflows.
- Decide state transitions.
- Wrap low-level persistence errors for user-facing boundaries.

Aggregate root should:

- Protect its own invariants.
- Prevent invalid or incomplete state.
- Own changes to its related entities inside the aggregate.
- Stay small enough to reason about.

Entity vs value object:

- Entity matters because of identity and lifecycle, not merely because it has an ID.
- Value object has no identity, describes a concept by attributes, and should be immutable or replace-as-a-whole.

## Review approach

A review produces findings; implement moves only when the user requests a refactor or fix. Apply aggregate-specific checks only where the project uses aggregate boundaries.

1. Identify the behavior being reviewed.
2. Trace the functions that mix user IO, business policy, or persistence responsibilities.
3. Check whether repository functions are only retrieving/persisting data.
4. Identify the aggregate root and check whether callers bypass it.
5. Identify misplaced display, pagination, workflow, or policy decisions; keep data-access pagination in the repository when it belongs to that contract.
6. Keep query helpers in repositories when they are reusable data access concepts.
7. Decide pragmatically whether ORM entities should be adapted into separate domain entities.
8. Add tests at the layer where the behavior actually belongs.

## Output

Return:

- Current responsibility split
- Misplaced logic
- Suggested owner
- Minimal refactor path
- Tests to add or move
