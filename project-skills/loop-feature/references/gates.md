# Shared verification rules

Plan uses this file to define verification checks; build runs local checks for its changes; verify checks the completed build using every applicable check. Verification rounds and stop rules follow the [shared workflow](workflow.md).

## Confirm runnable commands first

- Read the root and affected apps' `package.json`; use pnpm scripts and tools that actually exist. First confirm Node.js, pnpm, and any required PostgreSQL environment meet the project constraints.
- Run from the correct location in the feature workspace; when using workspace filters, take the actual package names from `package.json` instead of guessing script or package names.
- If the repo has no app skeleton, scripts, or test environment yet, record the gap; needed capabilities should be added in plan/build. Never treat nonexistent commands or "no tests to run" as passing.
- When a required environment, tool, or access is missing, record "not executed" and why. Without evidence for a required verification the feature cannot be declared done; explain the reason for checks marked not applicable.

## Choose checks by change scope

| Change scope | Results that must be confirmed |
| --- | --- |
| Docs / skills | Format, referenced paths, whether commands work, flow consistency; run applicable validators, and do not add mirror tests for doc changes. |
| TypeScript code | Type-check of the affected workspaces, applicable builds and behavior tests; build success alone does not prove business rules hold. |
| Hono API / contracts | HTTP status, input validation, response data, and the relevant failure cases match the plan; when a contract affects the frontend, verify the consumer too. |
| React UI / data interaction | Build and type-check plus the affected real interactions; cover loading, empty, success, and error states as applicable, and check the relevant screens against design mocks when they exist. |
| Drizzle schema / migration | Inspect the migration's actual SQL and verify structure and data behavior in an isolated PostgreSQL 17 test environment; never apply it directly to production. Follow the repo's prior-consent rule for data deletion or rewriting. |
| Dependencies / workspace config | Dependency ownership per app, the single root lockfile, version constraints, and the install/build results of affected workspaces. |

- Run only the checks relevant to this change and its acceptance criteria; existing format or lint tools also stay scoped to the change, not repo-wide cleanups.
- Every acceptance criterion must state the rule it protects; tests should fail when that rule is broken, without fixed constants or implementation-mirroring assertions masking errors.
- Records must distinguish "passed", "failed", "not executed", and "not applicable", with the actual commands/operations and necessary evidence. Existing local results are reference only and cannot stand in for checks not yet run in this round.
