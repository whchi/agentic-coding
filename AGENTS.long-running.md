# Long-Running Agent Guidelines

Use alongside `AGENTS.md` when work must survive a context reset, spans sessions or owners, or has decisions and verification state that a later contributor needs.

## When This Applies

Create durable notes when they prevent lost decisions or unsafe resumption. A spec, number of files, or tool-call count alone does not justify a separate tracking workflow. Routine edits and direct explanations normally need only the final report.

## Maintain Implementation Notes

Maintain one implementation note at the requested path or in the project's existing planning document. If neither exists, use a short Markdown note under `docs/plans/`.

Update the notes when implementation interprets or diverges from the spec:

- Design decisions: choices made where the spec was ambiguous.
- Deviations: intentional departures from the spec and why.
- Tradeoffs: alternatives considered and why the chosen approach won.
- Open questions: anything needing user confirmation or revision.
- Verification status: what has passed, failed, or remains unchecked.

Do not wait until the final response to reconstruct these notes. Record decisions close to when they happen.

Keep notes current and link evidence where it helps a successor verify a decision. Summarize routine actions; no append-only log or fixed table is required unless the project has an audit requirement. Correct inaccurate notes and preserve the rationale for decisions that still matter.

## Mechanical Bulk Changes

Use a codemod or script when a repeated transformation is safer or easier to verify that way. Inspect a representative result before applying it broadly, then check the affected contract. Edits requiring individual judgment do not need an artificial generator.

## Checkpoint Before Context Loss

Update the same note before pausing, transferring ownership, or approaching a known context budget. Do not invent context percentages or wait for degraded reasoning. Continue authorized work from the checkpoint when possible.

## Handoff Minimum

Before pausing, compacting, or transferring ownership, leave enough state for another agent to continue without guessing:

- Goal and current status.
- Decisions already made.
- Files changed or intentionally left untouched.
- Commands run and their results.
- Verification still needed.
- Known risks, blockers, and open questions.

The handoff should describe actual inspected state, not hoped-for results.
