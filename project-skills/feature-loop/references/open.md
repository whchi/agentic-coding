---
name: loop-feature
description: Start a new feature or resume an existing one by creating or locating its document and workspace.
---

# Feature: Open a feature

Read the [shared workflow](references/workflow.md) first. This skill only opens or locates a feature; plan, build, and verify each run separately.

## Locate the feature

1. Use the supplied requirement or slug when it identifies the target. If the target cannot be determined, ask which feature to create or resume and stop.
2. Check Git status and existing worktrees to locate the feature workspace and `docs/features/<slug>.md` before treating the feature as new.
3. If the document exists, read its progress, plan cycle, and verify count. Use the recorded workspace and branch, then go directly to **Report and stop**. Do not run the creation steps or reinitialize the document.

## Create a new feature

Run these steps only when no document exists for the target feature.

1. Use an English kebab-case slug. If Git is not initialized or no base commit can be resolved, report the missing prerequisite and stop.
2. Reuse a branch only if the user explicitly selected it. Otherwise, create `feature/<slug>`. Base the branch on the user-specified ref, or the current HEAD if none; record the actual ref and SHA.
3. Use the selected branch's workspace; create a worktree when isolation from other work is needed. Preserve unrelated changes.
4. Copy the [feature template](assets/feature-template.md) to `docs/features/<slug>.md`. Fill in known requirements and workspace info; set status to "Planning", plan cycle to `1`, and verify count to `0 / 2`. Leave design decisions for `loop-plan`.

## Report and stop

- For a new feature, propose `loop-plan <slug>`. For an existing feature, use the shared status table. If an earlier stage's output is missing, propose that stage as the next step and stop.
- Report the feature document, actual branch/workspace, current status, and suggested next step, then ask the user whether to continue.
- **This run ends here. Do not automatically invoke plan, build, or verify.** Only the user's next explicit instruction starts the next stage.
