---
name: better-test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code. Enforces TDD with 80%+ coverage including unit, integration, and E2E tests.
origin: ECC,superpowers
---

# Better Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

> **Language-specific commands, frameworks, and examples are in the language skill.**
> Read the appropriate skill before starting:
> - TypeScript / JavaScript → @tdd-typescript.md
> - Python → @tdd-python.md

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

Run the full test suite. Confirm:
- Test passes
- All other tests still pass
- Output is pristine (no errors, no warnings)

**Test fails?** Fix code, not the test.
**Other tests fail?** Fix them now.

### Step 6: REFACTOR — Clean Up

After green only:
- Remove duplication
- Improve naming
- Extract helpers

Keep tests green. Don't add behavior.

### Step 7: Verify Coverage

Run coverage report. Verify **80%+** across branches, functions, lines, statements.

### Repeat

Next failing test for next behavior.

---

## Coverage Requirements

- Minimum **80%** across branches, functions, lines, statements
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

---

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One thing. "and" in name? Split it. | `test('validates email and domain and whitespace')` |
| **Clear** | Name describes behavior | `test('test1')` |
| **Shows intent** | Demonstrates desired API | Obscures what code should do |
| **Isolated** | Each test sets up its own data | Tests depend on each other |

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

---

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test **fail** before implementing
- [ ] Each test failed for the expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and error paths covered
- [ ] 80%+ coverage verified

Can't check all boxes? You skipped TDD. Start over.

---
## Testing Anti-Patterns
When adding mocks or test utilities, read @testing-anti-patterns.md to avoid common pitfalls:

- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

## Final Rule

```
Production code → a test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.
