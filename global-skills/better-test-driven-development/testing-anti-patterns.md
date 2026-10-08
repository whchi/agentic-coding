# Testing Anti-Patterns

Read this when mocks, test utilities, or test-only APIs may hide the behavior a test is supposed to protect.

## Testing the double instead of the behavior

An assertion that a mocked component exists proves little about its parent. Exercise the real component when it owns the behavior, or assert the parent's contract with the dependency isolated. An outgoing call is a valid assertion when sending that call is itself the requirement.

```typescript
// Weak: only establishes that the mock was rendered.
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();

// Useful when the requirement is accessible navigation.
expect(screen.getByRole('navigation')).toBeInTheDocument();
```

A stronger assertion may be needed if the requirement is navigation contents or behavior rather than presence.

## Test-only production methods

Keep fixture cleanup in test utilities unless the production object actually owns the lifecycle. Do not expose destructive methods on production classes solely to reset test state. Use supported public interfaces or injected dependencies instead of reaching into private state.

## Mocking away the requirement

Identify the side effects and state the test relies on before selecting a mock boundary. For a duplicate-creation test, mocking the operation that persists the first record removes the condition that should make the second attempt fail.

Mock the external operation below that state transition, or use a fake that preserves the relevant contract. In unit tests, do not call real third-party services to discover how a mock should behave; inspect the adapter contract, fixtures, and documentation.

The duplicate test must assert rejection or the required unchanged state. Calling the operation twice without checking the outcome is not a regression test.

## Incomplete or invented mock contracts

Build fixtures from the actual schema. Include required fields and fields consumed by the path under test. Exercise missing optional fields when they are permitted. Do not fill every optional field merely for completeness, or omit required downstream fields to make a test pass.

For example, if the consumer requires `metadata.requestId`, a fixture with only `status` and `data` does not represent a valid successful response. A deliberately malformed fixture is appropriate when testing invalid-input handling.

## Excessive mocking

When setup recreates the implementation, check whether a smaller public interface or an integration test would prove the behavior more directly. Keep external dependencies isolated according to the selected test level and repository rules.

TDD helps expose weak tests, but a test failing first does not prove its assertions are meaningful. Ask whether the test would fail if the required behavior broke while the mocks stayed the same.

## Missing verification

Verification belongs to the requested deliverable. Preserve an existing implementation while adding a regression test; do not discard it to enforce a ritual. Report what was run and what remains unverified. Match the check to the change rather than requiring a new test for every edited line.
