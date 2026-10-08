# Project Structure

## Principle

Structure should follow project scale and ownership. Split by how the team changes the code, not by a mechanical folder template.

## Choosing Structure

Small project:

- Feature/MVC folders are usually enough.
- Keep ceremony low.
- Prefer simple, discoverable boundaries.

Larger project:

- Consider domain-based structure when business ownership or repeated cross-feature changes make the current organization costly.
- Group code by business capability.
- Keep domain rules close to use cases and models.
- Keep infrastructure adapters behind clear interfaces.

DDD-oriented project:

- Start from bounded contexts, not database tables.
- Keep ubiquitous language consistent inside one bounded context.
- Treat legacy systems and external services as separate contexts behind adapters.
- Use `domain-driven-design-advisor` for the actual modeling work.

For a project that needs layered boundaries:

```text
UI -> Application -> Domain <- Infrastructure
```

- UI: presenter, formatter, validator, router.
- Application: use cases, application services, DTOs, interface adapters.
- Domain: aggregate roots, entities, value objects, domain services, repository interfaces.
- Infrastructure: ORM, DAO, DB, repository implementations, vendor SDKs.

Outer layers may call inward. Inner layers should not know about outer mechanisms. Do not introduce every layer into a simple feature structure. For disputed ownership of concrete behavior, read [responsibility-placement.md](responsibility-placement.md).

## Review Questions

Use these where they bear on the requested structure decision; team size alone does not justify a migration.

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
