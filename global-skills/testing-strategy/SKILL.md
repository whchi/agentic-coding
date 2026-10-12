---
name: testing-strategy
description: Choose or review test levels, dependencies, and fixtures; use test-first implementation when explicitly requested or an authorized bug fix has an obvious, cheap local test path.
disable-model-invocation: true
---

# Testing Strategy

Use the project's existing tests and tools. A request for test advice does not authorize product changes or start TDD.

- **Design or review tests:** Read [test-design.md](references/test-design.md) for test levels, dependency boundaries, and fixtures.
- **Test-first implementation:** Read [test-first.md](references/test-first.md) when the user requests TDD, a failing test, or a regression test, or an authorized bug fix has a clear, cheap local test target. Unknown-cause diagnosis remains diagnosis.
- **Suspicious mocks or test utilities:** Read [testing-anti-patterns.md](references/testing-anti-patterns.md) only when they may hide the behavior under test.

Prefer the smallest useful check. Do not build a broad harness, brittle mocks, or unrelated fixtures merely to follow TDD; use the closest practical verification and explain the limitation. Documentation and configuration changes may need content or runtime checks instead of new tests.

Assert intended behavior, not implementation details. Do not weaken assertions to fit a bug. Mock third-party services in unit tests, keep the behavior under test real, and respect existing frameworks and coverage policy.

Run affected checks within repository scope. In development worktrees, select changed feature/e2e cases; full suites wait until integration after serial merges.

Report proposed cases for advice-only work. For implementation, report failing-before and passing-after evidence, affected checks, and any missing proof with its reason.
