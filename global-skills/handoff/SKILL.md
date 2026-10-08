---
name: handoff
description: Save or resume a durable handoff when work transfers to another agent or session, or must survive context loss.
argument-hint: "What will the next session be used for?"
---

# Handoff

Write a handoff document so a fresh agent can continue the work without relying on chat history.

## Storage

Prefer a repo-local artifact:

```text
docs/plans/handoff-<short-topic>.md
```

Create `docs/plans/` only when writing the handoff. Use a temporary file only when the user explicitly asks for a scratch handoff.

## Contents

Include:

- goal
- current state
- decisions made
- files or docs touched
- constraints and assumptions
- open questions
- next actions
- risks
- suggested skills or commands for the next session

Do not duplicate content already captured in PRDs, plans, ADRs, issues, commits, or diffs. Reference those artifacts by path or URL instead.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Pick up a handoff

When you continue work from a handoff document, do these steps before you change files:

1. Read the handoff and follow links only for the work being resumed.
2. Compare its recorded revision and pending work with the current branch, worktree, and relevant changes. Inspect running processes only if resuming a live service or test session.
3. Check later decisions when they could supersede the handoff; report material differences.
4. Reuse recorded verification tied to the same revision and environment when appropriate. Rerun affected checks when state changed or evidence is missing; distinguish inherited results from checks run in this session.
