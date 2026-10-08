---
name: debugging-playbook
description: Diagnose a reported failure or flaky behavior when its cause is unknown, using a reproducible symptom and evidence from environment, data, and logic.
origin: Notion 工程習慣
---

# Debugging Playbook

Diagnose the reported symptom with a reproducible feedback loop. A diagnosis-only request ends with the cause and evidence; a request to fix the problem includes implementation and verification once the cause is known.

## Evidence loop

Establish the expected behavior and the surface where the failure occurs. Use a failing test, command, browser action, trace replay, or other repeatable check that shows the same symptom. Minimize the reproduction when that helps distinguish causes.

Form falsifiable hypotheses and choose the cheapest check that distinguishes them:

- **Environment:** versions, configuration, feature flags, deployment, network, time zone, cache, or service availability.
- **Data:** actual records and payloads, duplicates, stale state, nulls, permissions, or migrations.
- **Logic:** branches, transformations, async order, state transitions, or boundary values.

These are search directions, not required buckets. If rereading logic produces no evidence, revisit data and environment assumptions. Instrument only where the result distinguishes hypotheses; preserve useful trace IDs without exposing secrets or low-level IO details to users.

Change one relevant variable at a time. When evidence disproves a hypothesis, undo only the experimental changes it caused. When two attempted fixes sharing a premise fail the same check, reassess that premise and identify which component holds the wrong state before trying another.

## Fix and verify within scope

Keep the reproduction as a regression check when practical. For an authorized fix, implement the smallest supported change, rerun the original loop, and run affected checks within repository worktree limits. Load another skill only when its specific guidance helps; do not stop simply to switch skills or ask again for an already-authorized fix.

For diagnosis-only requests, report the cause and proposed fix without changing application code. If reproduction or evidence is unavailable, name the missing prerequisite and keep the conclusion provisional.

A passing unit test does not establish that the user's reported failure is gone. Verify on the relevant surface, or explicitly report that verification as incomplete. Remove temporary instrumentation introduced for the investigation according to repository rules.

Report the confirmed cause or remaining hypothesis, supporting evidence, reproduction status, and verification outcome. Include a next action only when work remains.
