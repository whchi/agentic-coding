# AGENTS.md

Cross-project engineering and collaboration rules.

## 1. Repository Is the System of Record

Keep decisions and operational knowledge that future contributors need under version control. Prefer existing project documentation and distinguish verified facts from assumptions. Do not create a note for every routine action or load unrelated docs before editing.

## 2. Clarify Ambiguity Before Coding

Ask when missing information changes correctness, data safety, public APIs, migrations, or user-visible behavior. Otherwise, choose the smallest reversible interpretation and state material assumptions. Continue independent work while a necessary answer is pending.

## 3. Scope and Local Conventions

Make the smallest complete change that satisfies the request. Follow local conventions, preserve existing user work, and flag unrelated issues without changing them. Avoid speculative abstractions, unnecessary configuration, and unreachable branches.

When conventions conflict, choose the pattern closest to the changed module among those supported by current tests or documented behavior. Explain material conflicts and why the chosen pattern applies; do not blend incompatible conventions.

## 4. Verification and Reporting

For non-trivial work, state the acceptance criteria and how to verify them before implementation. Carry authorized work through verification and fix failures the change introduces. Proceed with already-authorized reversible steps without asking again.

Choose checks that exercise observable behavior and fail when the affected contract breaks; avoid assertions that merely mirror implementation. For documentation edits, check content, references, and the diff. When UI navigation or state persistence changes, verify what should persist or reset across browser history and reloads.

Mock or stub unmanaged dependencies when isolation is needed. In integration tests, prefer real, isolated instances of managed dependencies. Keep internal collaborators and deterministic libraries real unless a specific test constraint calls for a double.

Reuse evidence only when the code state, environment, and scope match. Rerun affected checks after changes or failures. Expand coverage only for an unresolved risk or a required integration check.

Report changes, observed results, material assumptions, and unverified items with reasons. A pass requires evidence that confirms the expected behavior; inconclusive evidence or the wrong verification surface is not a pass.

## 5. UI Copy

When building or editing a UI, use layout, spacing, and grouping to show how elements relate. Omit decorative labels and descriptions that merely repeat nearby headings or controls. Preserve control labels, accessible names, and text that explains constraints, consequences, or state.

## 6. Deterministic Logic and LLM Use

Implement explicit rules and structured computations in deterministic code. Use an LLM when the requirement calls for language understanding or judgment. Verify facts against source material or tool output.

## 7. Context Budgets and Checkpoints

Honor the project's context budget when one is specified. Before context loss threatens continuity, record decisions, changed files, verification status, blockers, and remaining work in a checkpoint. Resume from that checkpoint; do not equate exhausted context with completion.

## 8. Operations Requiring Explicit Approval

Before any destructive or irreversible operation, or any operation listed below, **show the exact target list and wait for explicit approval of that action on those targets in the current conversation**. General cleanup requests, inferred intent, and approvals from previous conversations do not qualify.

- Deleting files.
- Batch cleanup or glob-based deletion.
- Data deletion or migrations that drop or rewrite data.
- Force pushes.
- Credential or secret changes.
- Production configuration changes.
- Broad dependency upgrades.

## 9. Worktree Development and Verification

Use a single branch by default. Consider additional worktrees for independent changes that can proceed in parallel with little file overlap.

1. In each development worktree, run unit tests, lint, and type checks. Limit feature and E2E tests to the local change. Defer cross-component checks until after merging.
2. Merge one branch at a time into the integration branch. Skip temporary merge combinations and cross-worktree test matrices.
3. After merging, verify affected integration boundaries. Fix post-merge failures on the integration branch and rerun affected checks. Run full suites only when risk, CI policy, or release criteria require them.
