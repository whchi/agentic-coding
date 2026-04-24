# /code-review

Review the current change set directly, then integrate with the superpowers review model by dispatching the `superpowers:code-reviewer` agent when practical.

## Default Scope

If the user does not specify a scope, review current uncommitted changes.

Supported scopes:

1. Current uncommitted changes
2. Staged changes when explicitly requested
3. A user-provided git range or PR diff

## Workflow

1. Detect the scope to review.
2. Perform a direct review using the checklist below.
3. If practical, dispatch the superpowers `code-reviewer` agent with structured context for a second review.
4. If review feedback must be applied, verify each suggestion before changing code.

## Scope Detection

Use this priority order:

1. User-provided git range or PR diff
2. Explicit staged review request
3. Default to uncommitted changes

## Primary Direct Review

Always perform a direct review, even if a secondary reviewer may also be used.

Review the selected changes for:

### Security Issues

- hardcoded credentials, API keys, or tokens
- SQL injection risks
- XSS vulnerabilities
- missing input validation or other basic security issues
- insecure dependencies
- path traversal risks

### Architecture And Design

- scalability problems, including inefficient algorithms and unoptimized queries
- hidden complexity or unnecessarily convoluted logic
- circular dependencies between modules, classes, or components
- misleading logic that appears correct but behaves incorrectly or ambiguously
- DB query N+1 issues

### Reliability And Robustness

- concurrency issues such as race conditions, deadlocks, or thread-safety problems
- resource leak problems such as unclosed connections, memory leaks, or open file handles
- unhandled edge cases or boundary conditions that might break the system
- missing error handling or swallowed exceptions

### Code Quality And Maintainability

- oversized functions or files that hide too much responsibility
- nesting depth that makes reasoning difficult
- debug statements such as `console.log`
- unresolved `TODO` or `FIXME` comments
- mutation patterns where immutable updates would be safer
- missing documentation for public APIs when the project expects it

### Testing And UX

- missing tests for new code
- missing edge-case coverage
- accessibility issues where relevant

## Superpowers Integration

Use the superpowers review model accurately:

1. `requesting-code-review` provides the review-request protocol and context shape.
2. `superpowers:code-reviewer` performs the actual secondary review.
3. `receiving-code-review` provides rules for handling incoming feedback.

Do not describe this as a standalone superpowers `code-review` skill.

When dispatching the superpowers reviewer, provide structured context:

1. `WHAT_WAS_IMPLEMENTED`
2. `PLAN_OR_REQUIREMENTS`
3. `BASE_SHA`
4. `HEAD_SHA`
5. `DESCRIPTION`

Prefer this second review when the environment supports subagent dispatch and you have enough context to make the review meaningful.

## Fallback

If the `superpowers:code-reviewer` agent cannot be dispatched, or if there is not enough context for a useful secondary review, complete the review directly and return findings using the same output format.

Fallback examples:

1. No usable `BASE_SHA` and `HEAD_SHA`
2. No plan or requirements to compare against
3. No subagent dispatch support in the current environment
4. The current review target is better handled directly

## Severity Rules

- `CRITICAL`: security issues, data loss risks, broken auth, remote exploit risk, or clearly broken functionality
- `HIGH`: correctness issues, reliability problems, concurrency hazards, missing required behavior, or major test gaps
- `MEDIUM`: maintainability issues, local robustness concerns, or architectural debt that is not immediately dangerous
- `LOW`: cleanup, polish, and non-blocking improvements

Do not approve code with unresolved `CRITICAL` or `HIGH` issues.

## Output Format

Return findings first.

### Findings

For each finding include:

1. Severity: `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`
2. File and line reference when available
3. Issue description
4. Why it matters
5. Suggested fix when not obvious

### Questions / Assumptions

Use this section only when the review cannot be completed confidently without clarification.

### Strengths

List short, specific positives after findings, not before them.

### Assessment

End with one of:

1. `Ready to merge: Yes`
2. `Ready to merge: With fixes`
3. `Ready to merge: No`

## When Applying Review Feedback

If `/code-review` is being used in a context where feedback must be applied:

1. Read all feedback first.
2. Clarify unclear items before implementing anything.
3. Verify each suggestion against the codebase.
4. Decide whether the suggestion is technically correct for this repo.
5. Fix blocking and security issues first.
6. Verify each fix and check for regressions.

Do not:

- blindly accept reviewer suggestions
- implement only the parts of multi-item feedback that are clear while skipping unclear items
- use performative agreement instead of technical verification

Push back with technical reasoning when feedback is incorrect, incomplete, or conflicts with repo context.
