# Verify stage

Read the [shared verification rules](gates.md) first.

## Before verification

1. Read the feature document and latest build handoff, implementation diff, and local check results in the recorded workspace. Confirm the build completed against the current plan cycle. If no matching build result exists, report that build must finish first and stop. Verification normally starts automatically at the end of the build stage; it does not need separate user approval, because approving the plan already approved checking its implementation.
2. **At most 2 verify rounds per plan cycle.** Read the current cycle and its count first; if the count is already `2 / 2`, do not start a new round. Follow the shared workflow's counting rules.
3. Before running verification checks, increment the count, set status to "Verifying", and record the plan cycle, round, time, actual HEAD, and scope of uncommitted changes. Each round observes one implementation snapshot; HEAD alone cannot represent uncommitted changes.
4. A started verification counts as one round, even if it fails, gets blocked, or is interrupted. If Status is already "Verifying" when this stage starts, the previous round was interrupted — handle it before steps 2–3: close it from existing evidence without running checks or incrementing the count, and mark what is unfinished. Close round 2 as "Verify limit"; close round 1 as "Needs fix" (confirmed implementation defects), "Needs re-plan" (design or requirement problem), or otherwise "Ready to verify", with the next step from the shared status table. Then report and stop; a closed interrupted round never chains. Further checks require a new round and the user's approval within the current cycle's limit.

## Run verification

1. Run all applicable checks from the feature document's verification plan. Record commands, where they ran, results, and failure or non-execution reasons in this round's log; "not executed" is not a pass.
2. Check every acceptance criterion against evidence from actual tests or operations; for UI features, also check the planned interactions and applicable design mocks.
3. Review the feature diff since the base, covering committed, staged, and unstaged changes plus new files. Report only issues supported by code or reproducible evidence.
4. **This stage does not modify product code or tests, and does not automatically re-run after failures.** Record implementation issues and hand them back to build; suggest returning to plan for requirement or design issues. Never package a post-fix re-verification as the same round.

## Results and stop

- All required checks and acceptance criteria pass: set status to "Done" and the next step to "none". Report the evidence and follow-ups, then finish; do not start new features or release flows on your own.
- Round 1 has required checks blocked **by a missing external environment** — something outside the repo that build cannot supply (a database or service instance, credentials or access, a device, a third-party account), as opposed to scripts, test setup, mocks, or seed data that build can add: **do not chain into build, even if defects were also found**, because round 2 would hit the same block. Record the missing items in "Open items". Set status to "Needs fix" with next step `feature-loop build <slug>` if implementation defects were confirmed, otherwise "Ready to verify" with next step `feature-loop verify <slug>`. **Stop and give the setup hint below.**
- Round 1 fails or is incomplete **on implementation defects**, with no required check blocked by a missing external environment: set status to "Needs fix" and the next step to `feature-loop build <slug>`, list the issues, then **continue directly into the [build stage](build.md) in the same run** to fix them, and run verify round 2 afterwards. Do not stop to ask — the answer to "should the defect be fixed" is always yes. Report the round-1 result before starting the fix, so the failure stays visible even if round 2 also fails.
- Round 1 fails **on a design or requirement problem** — the plan itself is wrong and fixing it would change scope or acceptance criteria: set status to "Needs re-plan" and the next step to `feature-loop plan <slug>`. **Stop and let the user decide.** Never auto-fix by quietly narrowing an acceptance criterion.
- Round 2 fails or is incomplete: set status to "Verify limit" and the next step to "stop". Report the remaining issues and the evidence obtained and missing; if a missing external environment blocked checks, include the setup hint so the user can provide it before re-planning. Do not run a third round in this plan cycle or automatically start another build run.
- Every report states the plan cycle, this round's result, and the cycle's count (`1 / 2` or `2 / 2`), including whether the feature passed.

### Setup hint

When a missing external environment stops verification, end the report with this block, filled in concretely — name the variable, service, version, or permission rather than "set up the database":

```text
Verification blocked: missing environment
- Missing: <each item> — needed by <check / acceptance criterion>
- Why build can't supply it: <one line>
- To provide it: <concrete action, e.g. start the database version listed in tech-stack.md and set its connection URL in the local env file>
- Then run: `feature-loop build <slug>` (fix the recorded defects, then verify round 2) or `feature-loop verify <slug>` (verify round 2)
- Verify rounds left in this plan cycle: <n> / 2
```
