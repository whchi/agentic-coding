---
name: concurrency-review
description: Review race conditions and idempotency when overlapping callers or retries can change shared state between a decision and its action.
---

# Concurrency Review

Concurrency bugs are invisible to sequential reading. The code is correct for one caller and wrong for two, so reviewing it line by line proves nothing. This skill supplies the shapes to look for.

## Boundaries

Use related skills for narrower ownership questions:

- `module-boundaries` for whether behavior belongs in persistence, application, or domain code.
- `api-design` for the HTTP contract of retryable endpoints: method idempotency, status codes, and `Retry-After`.
- `frontend-patterns` and its effects reference for React effect re-entry and stale-closure races.
- `debugging-playbook` when an intermittent failure is already observed and needs diagnosis.

## Core Principle

Find every place where a decision and the action it authorizes are separated in time, then ask what a second caller does in that gap.

Correctness under concurrency is not a property of a function. It is a property of the window between reading state and acting on it.

## Workflow

1. List the state this change reads and writes: process memory, module or global scope, cache, database rows, filesystem, external service.
2. For each write, ask: can two callers reach this line at once? Two requests, two workers, two tabs, a retry overlapping its own original, a cron overlapping the previous run.
3. Locate the decision-to-action gaps. Ask: between checking and acting, could the state have changed?
4. First, ask whether the sharing is necessary. If each caller can own a separate file, key, row, or branch, remove the shared state. Use serialization only when one shared writer is a real invariant.
5. For each remaining gap, decide the control deliberately: atomic operation, optimistic lock, pessimistic lock, unique constraint, queue, or accept the race with a stated reason.
6. Ask what a retry does. If the operation runs twice, is the result identical or doubled?
7. Check failure paths, not just success paths: a partial write, a timeout that leaves the peer's state unknown, a lock released before the transaction commits.
8. Keep the control proportional. A row-level unique constraint often replaces a distributed lock; reach for coordination only when cheaper mechanisms cannot express the invariant.

## Patterns To Flag

**Check-then-act (TOCTOU).** The decision is stale before the action runs.

```
if not exists(key): create(key)          # two callers both create
if user.balance >= amount: deduct(...)   # two callers both pass the check
if stock > 0: place_order(...)           # oversell
if authorized: perform(...)              # permission revoked in the gap
```

Fix with an atomic conditional write, a unique constraint, or a conditional update whose `WHERE` clause carries the precondition (`UPDATE ... WHERE id = ? AND balance >= ?`) — then check the affected row count.

**Read-modify-write.** Reading a value into the application, changing it, and writing it back loses the other caller's update.

```
value = get(key); value += 1; set(key, value)
```

Fix with an atomic in-place update (`SET count = count + 1`), a database sequence, or an optimistic version check.

**Missing lock selection.** Ask which one the invariant needs, and record the answer:

- Optimistic (`version` column, compare-and-set, checking `updated_at`): contention is rare, and a losing writer can safely retry or fail.
- Pessimistic (`SELECT ... FOR UPDATE`, advisory lock): contention is common, or the losing writer cannot be retried.
- Neither: the operation is already atomic, or a constraint enforces the invariant.

Report a missing control when a concrete interleaving violates the invariant; do not require locks on unshared state.

**Non-idempotent retries.** Identify which attempts represent the same logical operation and what duplicate effects the contract permits. For retried payments, deliveries, or creates that must happen once, require a natural idempotency key, deduplication record, or equivalent constraint. A bare `INSERT` is a finding when replay can duplicate a prohibited effect.

**Lock and transaction scope errors.** Side effects that escape the transaction that authorizes them: publishing an event, calling an external service, or releasing a lock before commit. If the transaction then rolls back, the outside world has already been told. Moving the side effect after commit trades this for a lost effect if the process dies in between; when the effect must not be lost, write it to an outbox in the same transaction and publish from there.

**Cache invalidation races.** A write that updates the store and then deletes the cache key can be interleaved by a concurrent read that repopulates the cache with the pre-write value. Ask what the cache holds if the read's fetch and the write's delete land in the wrong order.

**Lazy initialization.** Singletons, connection pools, and memoized module-level values built on first use, without a guard, can be constructed twice — or observed half-constructed.

## Signals

Good signs:

- The precondition travels with the write instead of preceding it.
- Uniqueness is enforced by a constraint, not by a prior existence check.
- Retryable operations carry an idempotency key or deduplication record.
- The lock strategy is named and matched to expected contention.
- External calls and event publishing happen after commit, or through an outbox written in the same transaction — not inside it.

Bad smells:

- `if` on shared state followed by a write to that same state.
- Counters, balances, or inventory updated from a value read into the application.
- Module-level mutable state written during request handling.
- A comment saying a race is unlikely, with no constraint behind it.
- Retry or requeue logic with no statement of what a duplicate run does.

## Output

When reviewing, report per finding:

- The shared state and the two callers that collide
- The decision-to-action gap, with file and line
- The concrete interleaving that produces the wrong result
- The smallest control that closes it, and why that control over the alternatives

State explicitly when a race is real but accepted, and what makes it tolerable.
