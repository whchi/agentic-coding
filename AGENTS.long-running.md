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
