---
name: testing-strategy
description: Use when choosing test levels, writing or reviewing unit/integration/e2e tests, deciding whether to mock dependencies, selecting test data or a test database, or checking whether behavior/spec changes are covered by tests. Do NOT use as a substitute for strict test-first workflow.
---

# Testing Strategy

Use this skill to choose the right test shape for a behavior change.

## Boundaries

Use `better-test-driven-development` when the task requires strict test-first implementation: write a failing test, watch it fail, then implement. Use this skill to decide what kind of test is appropriate and what dependencies should be real, fake, or mocked.

## Test Levels

Unit tests:

- Target use cases, models, services, or pure functions.
- Usually assert input/output.
- Avoid asserting internal flow unless the flow itself is complex and important.

Integration tests:

- Test interaction between components and interfaces.
- Useful across ORM, services, controllers, queues, repositories, and internal APIs.

E2E tests:

- Test a full user or system flow.
- For backend-only work, an HTTP API request through persistence and side effects often acts as e2e/integration coverage.

## Database Choice

For most small and medium projects using an ORM, prefer SQLite for tests when it is supported and behavior is close enough.

Use the production-like database when:

- The project is large.
- SQL dialect behavior matters.
- Transaction, lock, index, JSON, timezone, or migration behavior differs materially.
- The test is specifically about database behavior.

## Mocking Rules

Mock:

- Third-party APIs and external providers.
- Uncontrollable services.
- Expensive, slow, or nondeterministic dependencies.
- Core library IO boundaries when you need precise control over DB, Redis, storage, or network behavior.

Avoid:

- Mocking native function call counts unless that call is the contract.
- Mocking so much that the test no longer verifies real interfaces.
- Adding test-only production APIs just to make mocking easier.

## DDD Testing Notes

For DDD-style code:

- Test aggregate invariants close to the domain model with unit tests.
- Test use cases/application services around workflow and orchestration.
- Test repository implementations with integration tests against the chosen persistence layer.
- Mock or fake repository interfaces in application-layer tests when persistence is not the behavior under test.
- Do not mock the aggregate root's own behavior when testing domain rules.
- Add tests that prove child entities cannot be modified in ways that bypass aggregate root invariants.
- For bounded context adapters, test translation between external models and internal domain language.

## Review Smells

- Requirements changed but tests did not.
- Tests assert implementation details more than behavior.
- Happy path is covered but boundary cases are not.
- Mocks hide a broken integration boundary.
- Seed data is too artificial to catch real scenarios.

## Realistic Test Data

Fixtures, factories, and local demo data should look like real production scenarios, not only minimal happy paths.

Include:

- Ordinary valid records
- Empty or minimal states
- Realistic relationships and ownership
- Status variation, such as draft, active, archived, deleted, failed, or expired
- Dates across useful ranges
- Realistic text lengths, optional fields, and nullable values

Keep seeds deterministic enough for tests and demos. Avoid fake data that trains developers to ignore real constraints.

## Workflow

1. Name the behavior under test.
2. Pick the narrowest test level that gives confidence.
3. Add edge cases: empty, one, ordinary, max, mixed sizes, invalid shape, duplicate/conflict.
4. Decide which dependencies are real, fake, or mocked.
5. Use realistic fixtures or seeds.
6. If DDD layers exist, choose the test level by layer: domain, application, repository, or adapter.
7. Confirm the test would fail before the fix when working on a bug.
8. Run the targeted test first, then the relevant broader suite.

## Output

Return:

- Recommended test levels
- Concrete test cases
- Mock/fake/real dependency decisions
- Test data needs
- Verification commands when known
