# Shared loop workflow

This file is the source of truth for the order, handoffs, and verify-count rules of the four `loop-*` skills.

## Execution order and user decisions

```text
loop-feature → report and stop
loop-plan    → report and stop
loop-build   → report and stop
loop-verify  → report and stop (at most 2 rounds per plan cycle)
```

Plan defines the scope and acceptance criteria. Build implements the plan and records its result. Verify checks that completed build against the plan's acceptance criteria.

- Before each stage, make sure `AGENTS.md` is in context; read it if the agent has not loaded it.
- New features always start with `loop-feature` creating the feature document and workspace record, then plan → build → verify in order. Stage skills never open unregistered features or skip earlier outputs.
- **One loop means one run of a `loop-*` skill.** Every run ends by reporting the results, unfinished items, and a suggested next step, then waiting for the user. Never chain the next skill, create background work, or open side tasks to bypass the stop.
- When the user says "continue" after a report, it only approves the proposed next step, not all later stages. If multiple next steps were proposed and the user did not choose, confirm the goal first.
- A feature opened by `loop-feature` can be resumed directly with the matching stage skill; re-creating the feature each time is not needed. In a new conversation, read the feature document and actual workspace instead of relying on conversation memory or restarting the count.
- You may propose returning to an earlier stage, but report first and let the user decide.
- Load skills through the agent's available mechanism; without a native skill tool, read the corresponding `SKILL.md` directly.
- Feature documents stay in the same workspace as the code and go into the same version change. Running the loop does not authorize automatic commit, push, merge, release, or workspace deletion; follow the user's instructions and repo rules.

## Verification budget and re-planning

- A new feature starts at `Plan cycle: 1` with `Verify count: 0 / 2`. Each plan cycle allows at most two verification rounds.
- When the user explicitly starts re-planning, `loop-plan` increments the plan cycle and resets its verify count to `0 / 2` before revising the plan. Record the decision and reason, and preserve previous task and verification history under its original cycle. Apply this transition once per re-plan decision.
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
| No document | loop-feature | Open the feature first |
| Planning | loop-plan | Requirement and workspace located |
| Ready to build | loop-build | Plan complete and user approves implementation |
| Building | loop-build | Resume unfinished tasks |
| Ready to verify | loop-verify | Build complete for the current plan cycle and fewer than 2 verify rounds used |
| Verifying | Consolidate the interrupted results | No silent re-runs; close the round from its results and the current cycle's count |
| Needs fix | loop-build; loop-plan for design issues | The current cycle's round 1 failed and the user decides to fix |
| Done | none | All required checks and acceptance criteria have passing evidence |
| Verify limit | Stop; await the user's decision, including whether to re-plan | The current cycle's round 2 failed or is incomplete |

If the document and code disagree, clarify first; never skip work by editing the status. If the count or round records are inconsistent, reconcile from existing evidence; never assume zero.

## Feature document

Keep `docs/features/<slug>.md` in the feature workspace as the only status document. Only `loop-feature` loads the creation template for a new feature; other stages read the existing feature document. Fill in known information at creation and complete the design during plan, omitting inapplicable details.
