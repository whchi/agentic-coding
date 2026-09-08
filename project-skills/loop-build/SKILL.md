---
name: loop-build
description: Implement an approved feature plan, resume unfinished tasks, or repair findings from the current plan cycle's first verification round.
---

# Build: Implement the feature

Read the [shared workflow](../loop-feature/references/workflow.md) and [shared verification rules](../loop-feature/references/gates.md) first.

## Before implementation

1. Read the feature document and relevant domain skills; confirm the workspace, actual diff, task progress, plan cycle, and verify count.
2. A document created by `loop-feature` and a complete plan must exist, and the user must approve starting or resuming build for this run. If the status is still "Planning" or the plan lacks necessary decisions, report that plan must be completed first and stop.
3. After the current plan cycle's first verification round fails on implementation defects, `loop-verify` hands straight back here in the same run — no separate user approval is needed, because approving the plan already approved making its implementation match. Add the confirmed issues to the task list and fix only those; do not widen the scope while fixing. If the failure is a design or requirement problem, verify stops instead and the user decides. Follow the shared workflow's verification budget and stop rules.
4. When starting implementation, record the user's instruction for the plan/fix and set status to "Building"; never treat a previous stage's suggestion as user authorization.

## Implement

1. Implement tasks in dependency order. If the code invalidates a key assumption in the plan, record the difference, propose re-planning, and stop.
2. Run relevant local checks and record commands, results, and evidence per the shared verification rules. Full verification belongs to `loop-verify`.
3. **If a task's local checks still fail after 3 fix attempts, stop working on that task.** Note each failed attempt in the task entry as it happens, so a resumed session inherits the count. When stopping, record the failing checks, the approaches tried, and the remaining errors in "Open items", then report and ask the user how to proceed. The count is per task; it is unrelated to verify rounds.
4. Update the feature document after finishing tasks; retain unfinished, failed, or blocked items. Never make a task "done" by deleting acceptance criteria or loosening tests.

## Hand off to verify

- When implementation tasks are done, record this build's outcome and plan cycle in "Decisions and handoffs". Set status to "Ready to verify" and the next step to `loop-verify <slug>`. This does not mean the feature is complete.
- **Continue directly into `loop-verify` in the same run.** A finished build is always verified; the user has no useful decision to make between writing the code and checking it. Report the build result first, then start verification. This applies equally to a fix run handed back from a failed round 1 — it continues into verify round 2.
- **Do not chain when the current plan cycle has no verify round left** (`Verify count` already `2 / 2`). Stop at "Ready to verify", report that the cycle's budget is exhausted, and let the user decide whether to re-plan.
- Report the changes, local check results, unverified items, and remaining verify rounds before verification starts, so the build result stays readable even if verification then fails.
