# /mock-or-not

Use this command before adding mocks to tests.

## Decision Rules

Mock only when the dependency is:

1. Uncontrollable, such as third-party APIs, payment providers, email delivery, time, randomness, or external queues.
2. Too expensive or slow to exercise in the target test.
3. Too broad for the behavior under test, such as a service with many unrelated dependencies.
4. A core library boundary where behavior must be verified without real DB, Redis, file system, or network IO.

Prefer real collaborators when they are cheap, deterministic, and clarify behavior.

Avoid asserting call counts on native functions or library internals unless the call itself is the public contract. Libraries may use native functions internally in ways the test should not care about.

## Output

Return:

- What should be real
- What should be mocked/faked
- What should be asserted
- What would make the test brittle
