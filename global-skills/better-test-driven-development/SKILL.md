---
name: better-test-driven-development
description: Use when implementing any feature, bugfix, refactor, or behavior change before writing implementation code. Use when tests are missing, behavior is unclear, or an agent is tempted to code first.
origin: ECC,superpowers
---

# Better Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

## Supporting Reference

Read `testing-anti-patterns.md` before adding mocks, test utilities, or test-only production APIs.

---

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete

Implement fresh from tests. Period.

---

## When to Use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? Stop. That's rationalization.

---

## Red-Green-Refactor Cycle

Work in vertical slices: one behavior, one failing test, one minimal implementation. Do not write a batch of imagined tests and then a batch of code.

Use a tracer bullet first: one test that proves the path works end-to-end through the public interface. Each next test should respond to what the previous cycle taught you.

### Step 1: Write User Journey
```
As a [role], I want to [action], so that [benefit]
```

### Step 2: RED — Write Failing Test

Write one minimal test showing what should happen.

Requirements:
- One behavior per test
- Clear, descriptive name
- Real code (no mocks unless unavoidable)
- Test names and public interfaces use the repo's domain language when `CONTEXT.md` exists
- Test through the public interface that callers use
- Describe what the system does, not how the implementation does it

### Step 3: Verify RED — **MANDATORY. Never skip.**

Run only the new test file. Confirm:
- Test **fails** (not errors)
- Failure message is what you expect
- Fails because the feature is missing (not a typo)

**Test passes?** You're testing existing behavior. Fix the test.
**Test errors?** Fix the error, re-run until it fails correctly.

### Step 4: GREEN — Write Minimal Code

Write the simplest code to pass the test.

Don't add features, refactor other code, or "improve" beyond what the test demands.

### Step 5: Verify GREEN — **MANDATORY.**

First run the targeted test you just made pass.

Then run the relevant test scope:
- Same test file for tight loops
- Related package/module tests before refactor
- Full suite before claiming completion or merging

Confirm:
- The new test passes
- No relevant existing tests regressed
- Output has no unexpected errors or warnings

**Test fails?** Fix code, not the test.
**Relevant tests fail?** Fix them now.

### Step 6: REFACTOR — Clean Up

After green only:
- Remove duplication
- Improve naming
- Extract helpers
- Deepen modules when the test reveals a shallow interface
- Move behavior behind smaller public interfaces when setup is too complex

Keep tests green. Don't add behavior.

### Step 7: Verify Coverage

Run the repository's configured coverage check when one exists. If no gate exists, verify meaningful behavior coverage for the code you changed.

### Repeat

Next failing test for next behavior.

---

## Coverage And Verification

Default target: meet the repository's configured coverage gate.

If no project gate exists, aim for meaningful behavior coverage:
- New behavior has focused unit or integration tests
- Bug fixes include a regression test that fails before the fix
- Edge cases and error paths are covered when they affect behavior
- Broad coverage targets such as 80% are useful only when the project can enforce them consistently

---

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Behavioral** | Verifies observable behavior | Asserts internal calls or private methods |
| **Public** | Uses the same interface as callers | Reaches into storage or internals to prove side effects |
| **Minimal** | One thing. "and" in name? Split it. | `test('validates email and domain and whitespace')` |
| **Clear** | Name describes behavior | `test('test1')` |
| **Shows intent** | Demonstrates desired API | Obscures what code should do |
| **Isolated** | Each test sets up its own data | Tests depend on each other |

Good tests survive refactors. If renaming or moving an internal helper breaks the test while behavior is unchanged, the test was coupled to implementation.

Prefer integration-style tests through real code paths. Mock only at true system boundaries such as external APIs, time, randomness, file systems, or slow infrastructure. Do not mock your own internal collaborators just to make setup easier.

## Interface Pressure

Let tests shape the interface:

- Hard-to-write tests often mean the interface is unclear.
- Huge setup often means behavior is behind the wrong boundary.
- A deep module has a small public interface with meaningful behavior behind it.
- A shallow module exposes too much setup or passes calls through without leverage.
- Accept dependencies instead of constructing external clients inside business logic.
- Return observable results where possible instead of forcing tests to inspect side effects.

---

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away the exploration, start with TDD. |
| "Test hard = design unclear" | Listen to the test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD is faster than debugging in production. |
| "Manual test faster" | Manual doesn't prove edge cases. You'll re-test every change. |
| "Existing code has no tests" | You're improving it. Add tests for the code you touch. |

---

## Red Flags — STOP and Start Over

- Code written before test
- Test added after implementation
- Test passes immediately without explanation
- Can't explain why the test failed
- Any of: "just this once", "I already manually tested it", "it's about spirit not ritual", "keep as reference", "already spent X hours", "TDD is dogmatic"

**All of these mean: Delete code. Start over with TDD.**

---

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify the design. |
| Need to test through internals | Move behavior behind a public interface that represents the real capability. |

---

## Verification Checklist

Before marking work complete:

- [ ] Every new or changed behavior has a test
- [ ] Watched each test **fail** before implementing
- [ ] Each test failed for the expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and error paths covered
- [ ] Repository coverage gate verified, or meaningful behavior coverage documented

Can't check all boxes? You skipped TDD. Start over.

---
## Testing Anti-Patterns
When adding mocks or test utilities, read `testing-anti-patterns.md` to avoid common pitfalls:

- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

## Final Rule

```
Production code → a test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.
