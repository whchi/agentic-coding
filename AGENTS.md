# AGENTS.md

Shared constraints for this repository. Read additional guidance only when the task needs it:

- `docs/agents/rules.md`: maintaining a repeated-mistake rule or its enforcement.
- `commands/qa.md`: acceptance verification, including browser navigation and persisted state.

## 1. Repository Is the System of Record

Keep decisions and operational knowledge needed by future contributors in versioned repo artifacts, preferably an existing relevant document. Distinguish inspected facts from assumptions. Do not create a note for every routine action or load unrelated docs before editing.

## 2. Clarify Ambiguity Before Coding

Ask when missing information changes correctness, data safety, public APIs, migrations, or user-visible behavior. Otherwise, choose the smallest reversible interpretation and state material assumptions. Continue independent work while a necessary answer is pending.

## 3. Keep Changes Small and Local

Make the smallest complete change that satisfies the request and follows local conventions. Avoid speculative abstractions, configuration, and impossible defensive branches. Mention unrelated problems without changing them; preserve existing user work.

## 4. Verify Intent and Report Honestly

For non-trivial work, state the success condition and verification method before implementing. Continue through implementation, inspection, and fixes to failures caused by the change. Do not stop at a first draft or ask again for already-authorized, reversible work.

Match checks to the changed behavior and the worktree limits in section 9. Documentation edits need content, reference, and diff checks. Tests should fail when the protected contract breaks; avoid assertions that merely mirror implementation. For navigation or persisted UI state, verify Back, Forward, and Reload against explicit retention or reset expectations.

Reuse evidence for the same code state, environment, and scope. Rerun affected checks after a change or failure; broaden only for an unresolved concern or a required integration check.

Report what changed, actual verification results, and material assumptions or unverified work with reasons. Inconclusive evidence or the wrong verification surface is not a pass.

## 5. Surface Conflicts Explicitly

Choose the pattern closest to the touched module and supported by current tests or documentation. Explain material conflicts and the chosen precedent; do not blend incompatible conventions or expand into unrelated cleanup.

## 6. Do Not Replace Deterministic Logic With LLM Calls

Use normal code for explicit rules and structured computation. Use models when language understanding or judgment is part of the requirement. Inspect tools and source evidence for deterministic facts.

## 7. Respect Context Budgets

Honor any project budget recorded in `docs/`. Before context loss threatens reliable continuation, save decisions, changed files, verification status, blockers, and remaining work. Resume from that checkpoint; do not equate exhausted context with completion.

## 8. Protect Destructive Operations

**Destructive or irreversible operations require explicit approval.**

This includes:

- Deleting files.
- Batch cleanup or glob-based deletion.
- Data deletion or migrations that drop or rewrite data.
- Force pushes.
- Credential or secret changes.
- Production configuration changes.
- Broad dependency upgrades.

Before any destructive operation:

- Show the exact target list.
- Wait for explicit approval in the current conversation.
- Past approval, general cleanup requests, or inferred intent do not count.

## 9. Worktree Development and Verification Order (When Using Worktrees)

**Using worktrees is optional. Decide based on the task. Once you choose worktree-based development, the following order is mandatory: parallel development with scoped verification → serial merges → full post-merge e2e / feature suites. Do not bypass this order.**

### When to use worktrees
- Prefer worktrees when the work splits into independent, parallelizable units with low overlap in files or modules.
- Prefer working directly on a single branch when the change is small, tightly coupled, sequential, or touches shared files heavily enough that parallel work would mostly create merge conflicts.
- If unsure, work on a single branch. Do not introduce worktrees just for structure.

### Rules once worktrees are in use
- Development worktrees may run unit tests, lint, and type checks.
- Feature and e2e tests in a development worktree must be limited to the behavior changed by that worktree. Do not run full suites, unrelated tests, or broader integration / cross-component verification in development worktrees.
- If a cross-component concern arises in a development worktree, record it in the report and defer it to post-merge verification instead of broadening tests locally.
- Merge worktree changes into the integration target one at a time. Never perform concurrent merges.
- Run the full e2e and feature suites against the combined result in the integration target only after the planned serial merges are complete.
- If post-merge suites fail, fix the failure on the integration target, rerun the affected suites, and report which merge introduced it when identifiable.
- Do not create temporary branch combinations, trial merges, or cross-worktree validation matrices to test permutations of unmerged changes. Do not duplicate post-merge verification across worktrees.
- Section 4's allowance to broaden verification does not apply in development worktrees. Report local checks and the scope of feature / e2e tests run; explicitly mark full-suite verification as pending until it has run after merging.

### When not using worktrees
- Follow the normal verification requirements in section 4. The scoped-verification limits above do not apply, but unit tests must still mock all third-party dependencies.

This order exists to keep redundant cross-validation from delaying merges.

---

**These guidelines are working if:** diffs become smaller, unnecessary rewrites decrease, overcomplication decreases, silent failures become visible, risky operations require approval, and agents ask clarifying questions before making correctness-affecting mistakes.
