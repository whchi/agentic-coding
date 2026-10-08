# Testing Conventions

Read when editing JS/TS tests. Use the repository's framework, fixture conventions, and test locations; do not introduce Jest, Vitest, a directory hierarchy, or a coverage threshold just to match an example.

Name the behavior and condition, such as `rejects an expired coupon`. Arrange/act/assert can clarify complex tests; obvious short tests do not need those labels.

- Assert the public contract, including side effects when they define the behavior.
- Derive fixtures from the scenario and vary the values that distinguish the rule. Avoid assertions that can pass after the rule is broken.
- Mock third-party services in unit tests; keep integration and end-to-end checks within the repository's permitted scope.
- Await promises and UI conditions. Use fake timers for timer behavior and restore timers/mocks after the test.
- Use factories only when repeated fixture setup obscures the scenario; override the fields relevant to each case.
- Follow existing coverage policy. A coverage percentage is not evidence that a business rule is protected.

Example of a timer boundary, using Jest syntax only if Jest is the project's framework:

```typescript
test('waits for the full debounce delay', () => {
  jest.useFakeTimers()
  try {
    const callback = jest.fn()
    const delayMs = 500
    const debounced = debounce(callback, delayMs)

    debounced()
    jest.advanceTimersByTime(delayMs - 1)
    expect(callback).not.toHaveBeenCalled()
    jest.advanceTimersByTime(1)
    expect(callback).toHaveBeenCalledTimes(1)
  } finally {
    jest.useRealTimers()
  }
})
```

Run the affected checks with commands discovered in the project. Do not broaden to full feature/e2e suites in a development worktree.
