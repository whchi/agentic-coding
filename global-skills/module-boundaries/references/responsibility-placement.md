# Responsibility Placement

## Principle

Business logic is the operation between user-facing IO and data. Repository code abstracts access to data and aggregate roots; it should not become the place where product behavior silently lives.

Repository code usually contains CRUD, queries, persistence mapping, and aggregate retrieval. Use cases/services decide how those results serve the user or workflow.

Apply aggregate checks only when the project already uses aggregate boundaries; ordinary repository/use-case separation does not require DDD. For aggregate discovery, invariants, or entity/value-object modeling, use `domain-driven-design-advisor` when available.

## Boundary Rules

Repository may:

- Query and persist data.
- Encapsulate ORM, DAO, DTO, and model access.
- Provide named queries that reflect data retrieval intent.
- Hide DB-specific details from higher layers.
- Build domain models or aggregate roots from persistence data.

Repository should avoid:

- Pagination or display decisions unless they are part of the data access contract.
- User-facing formatting.
- Authorization decisions.
- Workflow state transitions that belong to use cases.
- Error messages intended for API users.
- Bypassing existing aggregate invariants or crossing consistency boundaries without an explicit reason.
- Letting ORM entity shape become the public domain model by accident.

Use case/service may:

- Coordinate repositories.
- Apply business rules.
- Paginate or shape data for workflows.
- Decide state transitions.
- Wrap low-level persistence errors for user-facing boundaries.

## Review approach

A review produces findings; implement moves only when the user requests a refactor or fix. Apply aggregate-specific checks only where the project uses aggregate boundaries.

1. Identify the behavior being reviewed.
2. Trace the functions that mix user IO, business policy, or persistence responsibilities.
3. Check whether repository functions are only retrieving/persisting data.
4. Where aggregate boundaries exist, check whether callers bypass the root or its invariants.
5. Identify misplaced display, pagination, workflow, or policy decisions; keep data-access pagination in the repository when it belongs to that contract.
6. Keep query helpers in repositories when they are reusable data access concepts.
7. Decide pragmatically whether ORM entities should be adapted into separate domain entities.
8. Identify tests at the layer where the behavior belongs; add or move them when implementing an authorized refactor.

## Output

Return:

- Current responsibility split
- Misplaced logic
- Suggested owner
- Minimal refactor path
- Tests to add or move
