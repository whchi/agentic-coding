# JS / TS Testing Pitfalls

Read when writing or debugging JS/TS tests. For test levels, real/fake/mock selection, and fixture strategy, defer to `testing-strategy`; preserve the project's existing test runner and conventions.

- **Fake timers + microtask flushing:** sync `advanceTimersByTime` does not flush chained `Promise` microtasks; use `advanceTimersByTimeAsync` (Vitest/Jest) when timers schedule async work, and always restore real timers in `finally` / `afterEach`.
- **System clock vs injected clock:** prefer injecting `now: Date` into pure rules; use `setSystemTime` only when testing code that genuinely owns clock reads.
- **Mock cleanup semantics:** know the difference — `clearAllMocks` clears call history only, `resetAllMocks` also wipes mock implementations/return values, and `restoreAllMocks` restores original spied implementations.
- **Async rejection assertions:** always `await expect(promise).rejects.toThrow(...)`; dropping `await` lets the test pass before rejection or triggers unhandled-rejection flakes.
- **Abort & resource cleanup:** abort `AbortController` instances, clear intervals, and close handles/servers in `finally` or `afterEach` so open handles do not hang the runner.
- **Type-level contracts:** when public generic inference or discriminated narrowing is part of the API contract, guard it with `expectTypeOf` (Vitest) or `@ts-expect-error` negative assertions.

```typescript
test('fires debounce after delay and cleans up timers', async () => {
  vi.useFakeTimers()
  try {
    const callback = vi.fn()
    const debounced = debounce(callback, 500)

    debounced()
    await vi.advanceTimersByTimeAsync(499)
    expect(callback).not.toHaveBeenCalled()
    await vi.advanceTimersByTimeAsync(1)
    expect(callback).toHaveBeenCalledTimes(1)
  } finally {
    vi.useRealTimers()
  }
})
```
