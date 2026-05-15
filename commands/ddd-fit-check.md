# /ddd-fit-check

Use this command before introducing DDD, aggregates, repositories, domain services, clean architecture layers, or domain-based folders.

Before judging fit, read `CONTEXT.md`, `CONTEXT-MAP.md`, and relevant ADRs when they exist. DDD terms should match the project's ubiquitous language, not generic textbook names.

## Fit Check

DDD is useful when:

1. The domain language is important and shared with business experts.
2. Multiple engineers need isolation between business areas.
3. The core business rules are valuable, changing, and worth modeling explicitly.
4. The system has clear bounded contexts or microservice-like boundaries.
5. Persistence details should be hidden from use cases and domain rules.

Be cautious when:

1. The project is early MVP stage.
2. The team is small and moving fast.
3. There is no domain expert or shared ubiquitous language.
4. Most engineers are unfamiliar with DDD.
5. CRUD behavior is the majority of the product.
6. The abstraction would cost more than the business rules it protects.

## Output

Return:

- DDD fit: strong, partial, or weak
- Core domain, supporting subdomains, and generic subdomains
- Candidate bounded contexts
- Existing domain terms or ADRs that support or conflict with the proposal
- Whether MVC/function folders are enough for now
- Smallest useful DDD pattern to adopt
