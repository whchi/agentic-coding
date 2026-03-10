# Code Review

Comprehensive security and quality review of uncommitted changes:

1. Get changed files: `git diff --name-only HEAD`

2. For each changed file, check for:

**Security Issues (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation or any basic security issues
- Insecure dependencies
- Path traversal risks

**Architecture & Design (HIGH):**
- Scalability problems (e.g., inefficient algorithms, unoptimized database queries)
- Hidden complexity in the design or unnecessarily convoluted logic
- Circular dependencies between modules, classes, or components

**Reliability & Robustness (HIGH):**
- Concurrency issues (e.g., race conditions, deadlocks, thread safety)
- Resource leak problems (e.g., unclosed database connections, memory leaks, open file handles)
- Unhandled edge cases or boundary conditions that might break the system

**Code Quality (HIGH):**
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling / swallowing exceptions
- `console.log` or debug statements left behind
- TODO/FIXME comments unresolved
- Missing JSDoc for public APIs

**Best Practices (MEDIUM):**
- Mutation patterns (prefer immutable data structures instead)
- Emoji usage in code/comments
- Missing tests for new code or missing edge case coverage
- Accessibility issues (a11y)

3. Generate report with:
   - Severity: CRITICAL, HIGH, MEDIUM, LOW
   - File location and line numbers
   - Issue description
   - Suggested fix

4. Block commit if CRITICAL or HIGH issues found

Never approve code with security vulnerabilities!
