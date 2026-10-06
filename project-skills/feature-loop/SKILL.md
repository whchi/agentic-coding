---
name: feature-loop
description: Use when the user invokes the staged feature loop — `feature-loop <open|plan|build|verify> <slug>`, or "continue" on a feature tracked in `docs/features/<slug>.md`. Do NOT use for feature or implementation requests that name neither the loop nor a tracked feature, standalone PRDs or specs (`write-a-prd`), one-off edits, bug fixes, or reviews.
---

# Feature Loop

One feature moves through four stages: open → plan → build → verify. Each run handles the stage the user asked for and ends at a decision point.

## Pick the stage

| Stage | Invocation | Instructions |
| --- | --- | --- |
| open | `feature-loop open <requirement or slug>` | [open.md](references/open.md) |
| plan | `feature-loop plan <slug>` | [plan.md](references/plan.md) |
| build | `feature-loop build <slug>` | [build.md](references/build.md) |
| verify | `feature-loop verify <slug>` | [verify.md](references/verify.md) |

1. Read the [shared workflow](references/workflow.md) and make sure `AGENTS.md` (or the agent's equivalent project-instructions file) is in context.
2. Take the stage from the user's explicit instruction: `feature-loop <stage>`. If the user says "continue" — including "continue per the Next step" — pick the stage from the document's **Status** via the shared status table. The `Next step` line is only a hint: it lags behind an interrupted chain; if it disagrees with Status, follow Status and say so in the report. "Continue" approves that stage and its permitted chain only.
   - Status `Verifying`: run only the verify stage's interrupted-round rule ("Before verification", step 4), then stop.
   - Report and ask instead when Status is `Verify limit` or `Done`, when "Open items" records a question the last run stopped on (a re-plan proposal, build's 3-attempt stop, or a missing external environment), or when nothing names a stage.
3. Read only that stage's instruction file and follow it. Read another stage's file only when a permitted chain enters it.

## Permitted chains

Only two, and only while the current plan cycle has a verify round left:

- build → verify in the same run.
- verify round 1 fails on an implementation defect → build fixes it → verify round 2.

Every other stage ends with its report. A design or requirement failure stops for the user's decision; a check blocked by a missing external environment stops with a setup hint (see the verify stage).

## Done

A run is done when the feature document is updated and the report states the stage result, document path, status, plan cycle, verify count, and suggested next step — then wait for the user.

## Gotchas

- Status never means the user approved the next stage; never edit status to skip work.
- A chained run still reports every stage it passed through.
