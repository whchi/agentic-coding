---
description: "Build and run acceptance checks for a specified change, including real-browser and history-state verification when UI behavior changes."
---

# /qa

Produce verifiable acceptance evidence for the current change. Establish the expected behavior, scope, and completion criteria from the requirements, Acceptance Criteria, and existing contracts; do not treat the current implementation as the source of truth. Seek clarification only where missing information affects the acceptance decision.

This command authorizes adding or adjusting tests and executing verification. If product fixes are already within the user's request, proceed with those fixes and scoped verification without requesting permission again. If authorization extends only to QA, report product defects without independently modifying production behavior.

## Select the Necessary Verification

- Follow the project's existing frameworks and testing conventions. When choosing test levels, mock / fake / real dependencies, or fixtures, use the available `testing-strategy` skill; do not install it merely because it is unavailable.
- Cover the current requirements, significant error paths, and affected regression scenarios. Include cases involving permissions, invalid IDs, URL manipulation, and similar concerns only when the corresponding behavior is affected.
- Mock all third-party dependencies in Unit Tests; this rule does not restrict UI acceptance verification to mock screens.
- Reuse verifiable results for the same code state, environment, and scope. Run additional checks only when changes, failures, insufficient evidence, or new risks warrant them.
- QA does not automatically initiate a full code review. Within `feature-loop verify`, follow that workflow's management of rounds, state, and fixes.
- Establish how to launch, operate, and verify the target project by inspecting its README, scripts, test configuration, and existing tests; use commands and tools that actually exist. After launch, confirm that the environment is operational, exercise the affected feature entry points, preserve evidence, and clean up resources created during this run. If operating instructions are missing, report the specific gap. Do not assume that a dedicated verification skill, feature map, or control command exists; QA itself does not authorize rewriting the harness.

## Cases and Execution Records

Before execution, list each case ID, requirement or contract source, entry point, prerequisite data, actions and expected results, evidence, reset method, and timeout. Reference existing tests by test ID rather than duplicating them. Explain exclusions and items deemed not applicable; when expected behavior is unclear, do not derive a passing criterion from the current screen.

Use the target project's existing test execution methods and report formats. Record the following without relying on an additional verification skill or contract document:

- Run ID, base / tested revision, fingerprint of uncommitted changes, build, dependencies, non-sensitive configuration, fixture, and tool and case versions. Reuse results only when the relevant inputs are unchanged and the evidence remains available.
- For each attempt, record the case ID, actions / commands, Expected / Actual, time, outcome, and evidence paths. Preserve the initial failure; a successful rerun must not overwrite the failure record.
- Record case outcomes (passed / failed / blocked / unstable / not-run), coverage, environment status, and harness changes separately. Produce a concise summary and `run.json`, or an existing equivalent machine-readable report.

Classify failures as product, harness, environment, test-data, or unknown based on evidence. Do not infer the cause solely because a file is outside the diff or a second attempt also fails. For a suspected transient failure, allow at most one diagnostic rerun by default. First verify the version under test, processes, connectivity, and required authentication state, then restore test data owned by this run. Mark a failure followed by success as unstable, not a clean pass. For intermittent issues, define sampling and time limits in advance; do not keep rerunning until green.

Confirm resource ownership and isolation before execution. Clean up resources created during this run even after failure, timeout, or cancellation; record cleanup failures and retain evidence. Do not reset shared or user data. Store evidence according to the project's retention policy, redact secrets and personal information from traces, logs, and screenshots, and do not automatically publish or delete evidence.

Add visual, performance, or behavioral-equivalence verification modes only when the requirements call for them. Fix the baseline, comparison conditions, and thresholds in advance; do not adjust the baseline to eliminate failures. Code review, PR watching, and merging are outside the QA runner's remit.

## Real-Browser Verification and State

Changes involving UI, Routing, Browser State, or interaction flows require real-browser evidence. Static checks, API Tests, and Mock UI are not substitutes.

Prefer the available Chrome DevTools MCP for interactive acceptance verification, or use Playwright / the project's existing real-browser tools. If complete, verifiable Playwright evidence already exists, do not repeat the same scenarios manually; record the tool actually used. Report limitations when tools are unavailable; do not install them independently.

- Exercise the affected flows through the UI and assert specific field values, selection states, data, and outcomes, rather than merely checking that elements exist.
- Inspect Network, HTTP Status, and Console anomalies relevant to the acceptance criteria; verify persisted results when writes are involved.
- Wait for observable loading conditions rather than using fixed sleep intervals. Retain Screenshot, Trace, Console, or Network Evidence where necessary.
- Select representative cases for each affected state rule rather than exhaustively combining every operation.

When navigation or state retention is involved, first specify, according to the requirements, which URLs, filters / sort orders / page numbers, tabs, selections, drafts, or saved data must be retained, reset, or reloaded after Back, Forward, and Reload.

Create distinct history states through the UI, perform actual Browser Back / Forward navigation, then Reload; verify the URL, rendered screen, and specific data. Do not substitute direct URL navigation for history navigation. For write flows, confirm that navigation or Reload does not cause duplicate submissions. If the change also affects list pagination, separately test its previous-page / next-page buttons. Mark these checks Not Applicable when no relevant behavior is involved.

## Worktree Scope

Follow **parallel development and scoped verification → serial merges → full Feature / E2E Suite**:

- Within a Worktree, run Unit Tests, Lint, and Type-check; initially restrict Feature / E2E execution to test files or cases relevant to the current change. Verification may span components to exercise that behavior, but must not extend to unrelated flows.
- If execution cannot be scoped, report the limitation and defer it until after merging. Apply the same scope restrictions to real-browser interactions.
- If Sessions, data, and state cannot be isolated in a shared browser or environment, perform verification serially.
- Do not create temporary branch combinations, trial merges, or cross-Worktree test matrices.
- Run the full suite against the integrated result only after the planned serial merges are complete. QA itself does not authorize merging.

## Completion and Reporting

Complete test creation and execution within the authorized scope, and fix issues caused by your own test changes. Explicitly list unfinished work when required accounts, environments, tools, or authorization for product fixes are unavailable.

Report the acceptance scope and criteria, tests changed, actual commands and results, browser flows and state evidence, Expected / Actual behavior and reproduction steps for issues, and reasons for any unverified items. Distinguish automated E2E evidence from interactive browser evidence.

Determine the final status from the evidence:

- **Passed**: All applicable automated tests and required browser checks passed.
- **Failed**: Verified behavior violates a requirement or contract.
- **Partial**: Required acceptance items remain outstanding; mock results alone or a successful page load are insufficient for a pass.
- Unresolved unstable or blocked cases constitute incomplete acceptance verification and must not be reported as Passed.
- **Pending Integration**: Scoped verification is complete; the full suite awaits the planned serial merges.

When failures and unverified items coexist, report both; do not conceal limitations behind a single status. Never claim that an unexecuted check passed.
