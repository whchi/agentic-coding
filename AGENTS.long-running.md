# Long-Running Agent Guidelines

Use this alongside `AGENTS.md` for spec-driven or long-running implementation work.

These rules are not for trivial edits, single-command answers, typo fixes, or small mechanical changes.

## When This Applies

Treat work as long-running when any of these are true:

- The user provides a spec, PRD, plan, ticket, or multi-step implementation request.
- The task is expected to touch 3+ files.
- The task requires 5+ tool calls to inspect, edit, or verify.
- The task spans more than one concern, such as API + UI, schema + service, refactor + tests, or docs + install flow.
- The task requires a meaningful design decision, public API change, migration, data rewrite, architecture change, or user-visible behavior change.
- The task cannot be safely resumed by another agent from the final chat answer alone.

Do not treat work as long-running when it is a small mechanical edit, typo fix, single-file copy change, simple command output, or direct explanation with no repository changes.

When unsure, create durable notes only if they will reduce future confusion. Otherwise, report assumptions in the final response.

## Maintain Implementation Notes

For long-running work, maintain a durable implementation notes artifact while working.

Use the path requested by the user. If none is specified, follow the project convention. If no convention exists, use a short Markdown note under `docs/plans/`.

Update the notes when implementation interprets or diverges from the spec:

- Design decisions: choices made where the spec was ambiguous.
- Deviations: intentional departures from the spec and why.
- Tradeoffs: alternatives considered and why the chosen approach won.
- Open questions: anything needing user confirmation or revision.
- Verification status: what has passed, failed, or remains unchecked.

Do not wait until the final response to reconstruct these notes. Record decisions close to when they happen.

### Decision Log

Keep a decision log as a table in the same notes file. Do not start a second log file.

| Time | Decision | Reason | Evidence | Result |
|---|---|---|---|---|
| 2026-10-08T09:40Z | Captured baseline screenshots before the style change | To compare old and new output | `scripts/snapshot.sh`, `baseline/` | 120 screenshots saved |

- Add one row for each decision point: a selected option, a completed unit with its check result, a revert with its cause, or a blocker.
- Do not add rows for trivial actions.
- Put a pointer in the Evidence cell: a commit SHA, a `file:line`, a PR number, or an artifact path. Do not write a paragraph.
- Do not edit or delete a row. To correct a row, add a new row that replaces it.
- When a new session continues the log, its first row has the decision `start`. Read the last rows before you add a row.

Before the final response, audit the log against the transcript of the current workspace. Do not read the transcripts of other projects.

1. Make sure that each row agrees with an action that occurred.
2. Make sure that each Evidence pointer opens and shows what the row claims.
3. Add a row for each decision that changed the work but has no row.
4. Correct the log, not the story. Do not remove an incorrect row. Add a row that replaces it.

## Mechanical Bulk Changes

For a repeated edit across many files, write a tool that makes the change, such as a codemod, a script, or a generator. Do not make the edits by hand. A reviewer can run the tool again.

1. Complete one example by hand.
2. Run the tool on the same input.
3. Compare the tool output with the hand-made example. They must be identical.
4. Run the tool on the remaining files.
5. Check the result with a command, such as a type check, a test, or a search for the old pattern.

## Checkpoint Before Context Loss

Context and token budgets are checkpoint triggers.

When context or token budget becomes a risk:

- Around 60% context usage: update implementation notes with current decisions, deviations, tradeoffs, open questions, files touched, and verification status.
- Around 80% context usage: create or update a handoff summary before continuing.
- Around 90% context usage: stop expanding scope; summarize remaining work before proceeding.

If exact context percentage is unavailable, use judgment based on conversation length, number of files inspected, number of files changed, and remaining complexity.

## Handoff Minimum

Before pausing, compacting, or transferring ownership, leave enough state for another agent to continue without guessing:

- Goal and current status.
- Decisions already made.
- Files changed or intentionally left untouched.
- Commands run and their results.
- Verification still needed.
- Known risks, blockers, and open questions.

The handoff should describe actual inspected state, not hoped-for results.
