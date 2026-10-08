---
name: better-test-driven-development
description: Implement behavior through red-green-refactor cycles when TDD is requested or a focused regression test should guide a known fix.
origin: ECC,superpowers
---

# Better Test-Driven Development

Use a failing behavioral test to guide one small implementation change at a time. For a known bug, the test should reproduce the reported failure before the fix.

## Red, green, refactor

- **Red:** Exercise the interface callers use and assert the required result, state change, or side effect. Run the selected case and confirm it fails because the behavior is missing or wrong, not because setup is broken.
- **Green:** Make the smallest implementation that satisfies that contract. Run the selected case again, then affected checks within the repository's permitted scope.
- **Refactor:** Simplify code only where the change creates duplication or exposes an unclear interface. Keep behavior and the relevant tests green.

An existing test that already exposes the failure can serve as red. If a new test passes immediately, establish whether it covers existing behavior or misses the regression before changing implementation.

## Scope and completion

Match verification to risk and the user's request. Documentation edits, generated artifacts, and configuration changes may need content, schema, or runtime checks rather than a new unit test. Do not require approval merely to choose an appropriate check.

If implementation already exists, preserve it and add the missing verification. Demonstrate the test's sensitivity with the pre-fix revision or a controlled, reversible mutation when practical; report when red was not observed. Do not delete working code to replay the sequence.

Complete the requested implementation and affected checks without an intermediate review gate. Respect repository worktree limits: select changed feature/e2e cases before running them, and defer full suites to the integration target after serial merges.

## Test quality

- Assert behavior that would fail if the requirement broke. Avoid internal call counts unless the interaction itself is the contract.
- Keep independent setup and meaningful boundary cases; a test can assert several outcomes of one coherent behavior.
- Use the repository's domain vocabulary for names and interfaces.
- Mock third-party services in unit tests. Keep the behavior under test real, and use integration tests when the real boundary is what needs verification.
- Large setup can reveal an unclear interface, but does not authorize an unrelated redesign.
- Follow an existing coverage gate; do not invent a percentage or broaden checks merely to increase coverage.

For mocks, test utilities, or suspicious test-only APIs, read [testing-anti-patterns.md](testing-anti-patterns.md). For choosing test levels or persistence fixtures, use the testing-strategy skill only when that decision needs more guidance.

Report the behavior protected, checks actually run, and any unverified regression or environment limitation.
