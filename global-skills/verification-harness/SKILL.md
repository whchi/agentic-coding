---
name: verification-harness
description: Create or refresh a project-specific verification skill and feature map when the user requests a maintained way to launch and drive the real app.
origin: backnotprop/pstack@3a60467 (MIT)
---

# Verification Harness

Maintain a project-local `verify-<app>` skill that launches, checks, drives, and stops a real user-facing app. The `qa` command can use its Launch, Doctor, Drive, Evidence, and Cleanup sections for acceptance testing.

## Choose the requested mode

- **Create:** Build the skill and prove one mapped feature. Read [create.md](references/create.md) for the generated section contract and proof procedure.
- **Refresh:** Correct an existing skill and feature map after the app changes. Read [refresh.md](references/refresh.md) for coverage, live-pass invariants, and triage.
- When comparing an existing fix against a baseline, also read [verify-existing-fix.md](references/verify-existing-fix.md).

Use the provider's existing project skills folder. Infer the destination from the active provider and repository convention; ask only when multiple plausible destinations remain or no provider convention can be established.

## Shared constraints

- Separate generated assets from user-owned configuration. A refresh may change the skill and helpers, but must preserve URLs, ports, accounts, and other configuration unless changing them is authorized.
- Keep secrets in environment variables or uncommitted configuration. Evidence and documentation must not expose secret values.
- Isolate workers by account, profile, data directory, and port. Read-only workers do not need write credentials.
- Diagnose prerequisites from actual commands and repository evidence. Continue unblocked authoring when possible; mark an unrun generated skill as a draft rather than complete.
- Fix harness errors and rerun affected proof within scope. Report unrelated product/build failures; obtain authorization before expanding into product fixes or installing tools. Do not ask again for an action already authorized.
- Stop only processes this run started and follow repository rules for scratch cleanup. Preserve evidence after cleanup.
- Commit, push, or open a PR only within the user's authorized workflow.

## Verification scope

Select the features to drive before launching. In development worktrees, refresh only features touched by the current change; add a map entry for an uncovered changed surface. A full feature-map pass belongs on the integration target after planned serial merges.

Do not create trial branch combinations or cross-worktree test matrices. Report full verification as pending integration until it runs there.

A refresh edits the `verify-<app>/` folder, not product code. Distinguish:

- **Doc drift:** the map misstates behavior; correct it with evidence.
- **Harness gap:** the app works but the recipe cannot drive it; correct and re-prove the recipe.
- **Product gap:** the app fails its intended behavior; report it without changing the map to conceal it.

## Completion

A runnable skill needs evidence from the real path, not only a build or source inspection. Report the mode, selected features, evidence paths, changes, and missing prerequisites. Use `clean` when all scoped source and live checks passed without edits, `changed` when corrections were proved, or `blocked` when required coverage remains unavailable.
