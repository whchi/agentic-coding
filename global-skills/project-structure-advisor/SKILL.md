---
name: project-structure-advisor
description: Use when designing, reviewing, or refactoring project folder structure, module boundaries, MVC/function-based vs domain-based organization, and high-level separation of user-facing code from database/IO code. Do NOT use for detailed DDD modeling or line-level repository behavior review.
---

# Project Structure Advisor

Use this skill when folder structure and module boundaries affect team speed or maintainability.

## Boundaries

Use related skills for narrower decisions:

- `domain-driven-design-advisor` when the task needs DDD fit, aggregates, entities, value objects, or bounded contexts.
- `repository-boundary-review` when the question is whether a repository, DAO, service, or use case owns specific behavior.
- `maintainable-code-review` for local abstraction/readability issues inside existing files.

## Principle

Structure should follow project scale and ownership. Keep code near the side it serves:

- User-facing IO: controllers, views, request validation, DTOs, use cases.
- Database/external IO: DB clients, DAO, repositories, third-party adapters.
- Business logic sits between user intent and data access.

Do not split folders mechanically. Split by how the team changes the code.

## Choosing Structure

Small project:

- Feature/MVC folders are usually enough.
- Keep ceremony low.
- Prefer simple, discoverable boundaries.

Larger project:

- Consider domain-based structure when more than about three people develop the project at the same time.
- Group code by business capability.
- Keep domain rules close to use cases and models.
- Keep infrastructure adapters behind clear interfaces.

DDD-oriented project:

- Start from bounded contexts, not database tables.
- Keep ubiquitous language consistent inside one bounded context.
- Treat legacy systems and external services as separate contexts behind adapters.
- Use `domain-driven-design-advisor` for the actual modeling work.

Layering guideline:

```text
UI -> Application -> Domain <- Infrastructure
```

- UI: presenter, formatter, validator, router.
- Application: use cases, application services, DTOs, interface adapters.
- Domain: aggregate roots, entities, value objects, domain services, repository interfaces.
- Infrastructure: ORM, DAO, DB, repository implementations, vendor SDKs.

Outer layers may call inward. Inner layers should not know about outer mechanisms.

## Review Checklist

1. How many people actively modify the codebase?
2. Are changes usually feature-local or cross-cutting?
3. Are controllers or views reaching too deeply into DB/IO details?
4. Are repositories doing business decisions instead of persistence access?
5. Are validation and DTOs close to the user boundary?
6. Are third-party and DB concerns isolated enough to test?
7. Would a new teammate know where to add the next feature?
8. Are domain folders based on business language rather than table names?
9. Are domain objects free from ORM/framework/vendor details?
10. Is the DDD structure justified by domain complexity and team size?

## Output

Return:

- Recommended structure
- What should move, if anything
- What should stay
- Boundary risks
- Migration plan in small steps
