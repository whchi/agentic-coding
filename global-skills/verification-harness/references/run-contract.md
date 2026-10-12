# Case and Run Contract

Use the project's existing test runner and artifact formats when they express this contract. Add an adapter or helper only for a demonstrated gap; a Markdown recipe alone is not an executable runner. Keep reusable cases versioned and run evidence outside source control. A generated harness must work without the generator's installation or any reference repository.

## Cases: what counts as correct

Give each selected case a stable ID, a feature ID, and:

| Field | Required content |
| --- | --- |
| Requirement | Requirement, acceptance criterion, or established contract source; do not derive correctness solely from current implementation |
| Surface and entry | UI, CLI, API, or other real user entry point; name the path actually tested |
| Preconditions | Account role, fixtures, starting state, and relevant environment prerequisites; reference secret variable names only |
| Actions and expectations | Ordered actions paired with observable expected values or state; include forbidden effects when relevant |
| Evidence | Assertions and artifacts needed to distinguish success from failure; a screenshot alone does not prove persistence |
| Reset and limits | How to restore owned fixtures; readiness condition, case timeout, and retry allowance chosen before execution |

Feature maps index these cases. Existing automated tests may supply actions and assertions by test ID; do not duplicate their implementation in prose. If a required expected behavior is unknown, mark the case blocked until resolved. Record omitted or not-applicable cases and reasons instead of silently reducing scope.

For a persistence case: create through the UI, assert the success result, reload or reopen through an independent read path, assert the saved fields, and check for duplicate writes if repeat submission is a risk. Setup may seed disposable fixtures directly; the behavior under test must follow the declared user path.

## Run identity and evidence validity

Before launch, record a unique run ID, selected case IDs, scope (`scoped` or `full`), base and tested revisions, and whether integration verification is pending. Include a diff fingerprint for uncommitted changes, build identity, dependency lockfile fingerprint, relevant non-secret configuration, fixture/seed version, browser or driver version, and case/harness revision. Mark unavailable values explicitly.

Reuse evidence only when these behavior-relevant inputs match and artifacts still exist. A matching patch or commit message alone is insufficient after a base, dependency, fixture, or configuration change. Record which earlier run supplies reused evidence. If equivalence cannot be established, rerun affected cases.

Each attempt records case ID, attempt number, start/end times, actual command or interaction recipe, expected and actual result, exit/error details, evidence paths, and failure classification. Keep screenshots, traces, logs, and stored-state checks tied to that attempt. Redact credentials and personal data before retaining or sharing artifacts; screenshots and traces may contain secrets too. Record redaction that limits a claim.

## Execution ownership and recovery

Run Launch, Doctor, selected cases, then Cleanup. Use observable readiness with bounded waits. Always attempt cleanup on failure, timeout, and cancellation; record incomplete cleanup and the owned resource IDs so it can be retried safely. Preserve evidence and never kill processes by broad name matching.

Parallel live runs require isolated accounts, profiles, fixtures, ports, and data directories, including external test resources. Otherwise serialize. Give each run explicit ownership of the resources it creates. Never reset shared or user-owned state to make a case pass.

Classify failures from evidence as `product`, `harness`, `environment`, `test-data`, or `unknown`. Source-file location or repeated failure alone cannot establish the cause. A blocked prerequisite is not a product failure. A failed assertion with an untrusted driver result is inconclusive until the driver is checked.

Do not retry a confirmed product defect to obtain green. For a suspected transient failure, default to at most one diagnostic retry after Doctor and a fixture reset; preserve both attempts. A failure followed by a pass is `unstable`, not a clean pass. Intermittent-bug or performance investigations may declare a larger sample plan and time budget before running. Stop at the limit and report unresolved evidence.

QA can repair tests it is authorized to change. Harness repair requires create/refresh or other explicit harness-edit scope; product repair requires product-fix scope. After a repair, record the new revision and rerun affected proof. Do not alter expectations or baselines merely to make a failure disappear.

## Results: separate four dimensions

- **Case result:** `passed`, `failed`, `blocked`, `unstable`, or `not-run`. Record a reason for every result other than passed. A confirmed requirement violation stays failed even if other cases are blocked.
- **Coverage:** selected, executed, and unresolved case IDs; excluded cases with reasons; `complete`, `partial`, or `pending-integration`. Complete refers only to the declared scope, never the entire app by implication.
- **Environment:** `ready`, `blocked`, or `degraded`, with prerequisite and cleanup problems recorded separately from product defects.
- **Harness changes:** changed files or none, with proof status. This is independent of whether the app passed.

Emit a human summary and a machine-readable result such as `run.json`. At minimum it contains `run_id`, `identity`, `scope`, `selected_cases`, `excluded_cases`, `attempts`, `case_results`, `coverage`, `environment`, `harness_changes`, and `cleanup`. Use the values defined above and actual evidence paths, not inferred success from an agent's report. Map these fields from existing runner reports rather than requiring a new test framework.

Acceptance is Passed only when every required selected case passed with valid evidence and no unresolved unstable or blocked cases. Confirmed violations yield Failed; missing proof yields Partial. Report Pending Integration separately when required full verification remains. Preserve failure and coverage information together.

Choose an artifact directory and retention policy using project conventions. Preserve evidence through cleanup; if no retention policy exists, retain it until an explicit cleanup decision. Publishing, committing, or deleting evidence is separate from running QA.
