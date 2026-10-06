# Shared loop workflow

This file is the source of truth for the order, handoffs, and verify-count rules of the four `feature-loop` stages.

## Execution order and user decisions

```text
open    → report and stop
plan    → report and stop          ← the user's approval gate for implementation
build   → chain directly into verify (same run)
verify  round 1 pass → status Done; report and stop
        round 1 fail
          ├─ missing external environment → status Ready to verify / Needs fix; stop with a setup hint
          ├─ implementation defect → chain back into build, fix, then verify round 2
          └─ design / requirement problem → status Needs re-plan; report and stop
        round 2 pass → status Done; report and stop
        round 2 fail → status Verify limit; report and stop
```

**Build and verify run as one unit, and so does fixing an implementation defect.**
A finished build is always verified in the same run, and a verification that fails on
*implementation* goes straight back into build and uses the cycle's second verify round —
there is no useful decision for the user between "the check found a defect" and "fix the defect";
the answer is always "fix it". Stopping there just parks a known-broken build and asks a question
whose answer was never in doubt.

**The one failure that must still stop is a design or requirement problem** — the plan itself is
wrong, so the fix is re-planning, which changes scope or acceptance criteria. That *is* the user's
decision, and auto-fixing it digs the hole deeper. Judge by this: if the fix keeps the plan's scope
and acceptance criteria intact, it is an implementation defect and the chain continues; if the fix
requires changing them, stop and report.

**A check blocked by a missing external environment also stops** — a database or service instance,
credentials, a device, or an account that build cannot supply. Chaining into build would only spend
round 2 on the same block, so stop and tell the user exactly what to provide and how to resume.

The whole chain is bounded and cannot run away: at most 2 verify rounds per plan cycle, and build's
own 3-attempt limit per task still applies. When the budget is spent, verify stops at
"Verify limit" and waits.

The stops that remain are the ones where the user genuinely decides something — approving the plan
before implementation, choosing whether to re-plan, providing a missing environment, and deciding
what to do once the verify budget is exhausted.

**No chain runs when the current plan cycle has no verify round left** (`Verify count` already
`2 / 2`) — neither build → verify nor verify → build. In that case the run stops at
"Ready to verify" or "Verify limit" and reports that the cycle's verification budget is exhausted;
only explicit re-planning opens a new cycle.

Plan defines the scope and acceptance criteria. Build implements the plan and records its result. Verify checks that completed build against the plan's acceptance criteria.

- New features always start with the open stage creating the feature document and workspace record, then plan → build → verify in order. Later stages never open unregistered features or skip earlier outputs.
- **One run ends at a decision point, not at a stage boundary.** Every run ends by reporting the results, unfinished items, and a suggested next step, then waiting for the user. Beyond the two chains above, never chain any other stage, create background work, or open side tasks to bypass a stop.
- **A chained run still reports every stage.** Auto-continuing does not mean reporting only the final outcome: the build result, each verify round, and the fix applied between them all appear in the feature document and in the run's report. The user must be able to see what broke without asking.
- When the user says "continue" after a report, it only approves the proposed next step, not all later stages. If multiple next steps were proposed and the user did not choose, confirm the goal first.
- A feature opened by the open stage can be resumed directly with the matching stage; re-creating the feature each time is not needed. In a new conversation, read the feature document and actual workspace instead of relying on conversation memory or restarting the count.
- You may propose returning to an earlier stage, but report first and let the user decide.
- Feature documents stay in the same workspace as the code and go into the same version change. Running the loop does not authorize automatic commit, push, merge, release, or workspace deletion; follow the user's instructions and repo rules.

## Verification budget and re-planning

- A new feature starts at `Plan cycle: 1` with `Verify count: 0 / 2`. Each plan cycle allows at most two verification rounds.
- When the user explicitly starts re-planning, the plan stage increments the plan cycle and resets its verify count to `0 / 2` before revising the plan. Record the decision and reason, and preserve previous task and verification history under its original cycle. Apply this transition once per re-plan decision.
- Returning to plan counts as re-planning only when the user approves revising the plan's scope, design, or acceptance criteria — including after a round-1 design issue. Fix-only work stays in build and keeps the current cycle's count.
- Re-planning must be motivated by a requirement or design change. Never propose re-planning as a way to obtain additional verification rounds.
- Re-planning returns to plan → build → verify. A build handoff from an earlier plan cycle cannot replace build for the new plan.
- Initial planning, resuming the current plan, switching conversations, reopening the feature, or renaming its slug does not reset the cycle or count.
- Persist the cycle and count before each verification round starts. A started round counts even if it fails, gets blocked, or is interrupted. Verify never fixes or retries automatically.
- Local build checks do not count as verify rounds, but cannot replace full verification or bypass the limit.
- "Verify limit" stops the current plan cycle after round 2 fails or is incomplete. Wait for the user's next decision; explicit re-planning can start a new cycle as above. Do not declare unresolved work verified just because the user accepts its current state.

## Status and next step

Status describes output progress; **it never means the user has approved the next stage**.

| Document status | Suggested next step | Precondition |
| --- | --- | --- |
| No document | feature-loop open | Open the feature first |
| Planning | feature-loop plan | Requirement and workspace located |
| Ready to build | feature-loop build（完成後自動接 verify） | Plan complete and user approves implementation |
| Building | feature-loop build | Resume unfinished tasks |
| Ready to verify | feature-loop verify | build 完成後通常同一輪直接進 verify；只有 chain 中斷、本 cycle verify 次數用盡、verify 第 1 輪因缺外部環境停下、或使用者單獨要求驗證時才會停在此狀態 |
| Verifying | Consolidate the interrupted results | No silent re-runs; close the round from its results and the current cycle's count |
| Needs fix | feature-loop build（同一輪內自動接續） | The current cycle's round 1 found implementation defects; build resumes automatically and verify round 2 follows — unless the round stopped on a missing external environment (recorded in "Open items"), which the user provides first |
| Needs re-plan | feature-loop plan | Round 1 found a design or requirement problem; fixing it would change scope or acceptance criteria, so the user decides |
| Done | none | All required checks and acceptance criteria have passing evidence |
| Verify limit | Stop; await the user's decision, including whether to re-plan | The current cycle's round 2 failed or is incomplete |

If the document and code disagree, clarify first; never skip work by editing the status. If the count or round records are inconsistent, reconcile from existing evidence; never assume zero.

## Feature document

Keep `docs/features/<slug>.md` in the feature workspace as the only status document. Only the open stage loads the creation template for a new feature; other stages read the existing feature document. Fill in known information at creation and complete the design during plan, omitting inapplicable details.
