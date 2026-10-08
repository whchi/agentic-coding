---
name: handoff
description: Use when compacting current work into a durable handoff document for another agent or future session, especially before context loss, pausing a long task, or transferring implementation ownership.
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

1. Read the handoff document and the implementation notes that it names.
2. Read the last entries of the decision log. Find entries that a later session wrote after the handoff.
3. Examine the real state: the branch, the worktree, `git status`, uncommitted changes, and running processes.
4. Compare the real state with the document. Report each difference.
5. Do not trust a "done" or "passed" statement from the previous agent. Run the verification again, or mark it as not verified.
