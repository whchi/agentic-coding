---
name: loop-verify
description: Verify the latest completed build against the feature plan after user approval, and report acceptance evidence.
---

# Verify: Check the build result

Read the [shared workflow](../loop-feature/references/workflow.md) and [shared verification rules](../loop-feature/references/gates.md) first.

## Before verification

1. Read the feature document and latest build handoff, implementation diff, and local check results in the recorded workspace. Confirm the build completed against the current plan cycle and the user approved verification. If no matching build result exists, report that build must finish first and stop.
2. **At most 2 verify rounds per plan cycle.** Read the current cycle and its count first; if the count is already `2 / 2`, do not start a new round. Follow the shared workflow's counting rules.
3. Before running verification checks, increment the count, set status to "Verifying", and record the plan cycle, round, time, actual HEAD, and scope of uncommitted changes. Each round observes one implementation snapshot; HEAD alone cannot represent uncommitted changes.
4. A started verification counts as one round, even if it fails, gets blocked, or is interrupted. After an interruption, consolidate existing evidence and mark what is unfinished; running further checks requires a new round and user approval within the current cycle's limit.

## Run verification

1. Run all applicable checks from the feature document's verification plan. Record commands, where they ran, results, and failure or non-execution reasons in this round's log; "not executed" is not a pass.
2. Check every acceptance criterion against evidence from actual tests or operations; for UI features, also check the planned interactions and applicable design mocks.
3. Review the feature diff since the base, covering committed, staged, and unstaged changes plus new files. Report only issues supported by code or reproducible evidence.
4. **This stage does not modify product code or tests, and does not automatically re-run after failures.** Record implementation issues and hand them back to build; suggest returning to plan for requirement or design issues. Never package a post-fix re-verification as the same round.

## Results and stop

- All required checks and acceptance criteria pass: set status to "Done" and the next step to "none". Report the evidence and follow-ups, then finish; do not start new features or release flows on your own.
- Round 1 fails or is incomplete: set status to "Needs fix", list the issues, and suggest `loop-build <slug>` (or `loop-plan <slug>` for design issues). Let the user decide whether to continue; after fixes, report again and let the user decide whether to use verify round 2.
- Round 2 fails or is incomplete: set status to "Verify limit" and the next step to "stop". Report the remaining issues and the evidence obtained and missing; do not run a third round in this plan cycle or automatically start another build run.
- Every report states the plan cycle, this round's result, and the cycle's count (`1 / 2` or `2 / 2`), including whether the feature passed.
