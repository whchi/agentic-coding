---
name: debugging-playbook
description: Use when investigating bugs, flaky tests, production incidents, environment-specific failures, data issues, or logic that is taking too long to diagnose by inspection. Do NOT use when the cause and minimal fix are already known.
origin: Notion 工程習慣
---

# Debugging Playbook

Use this skill to debug methodically without getting trapped in code inspection.

## Boundaries

Use this skill to investigate. Once the likely cause is confirmed, switch to the relevant implementation/review skill for the fix, such as `testing-strategy`, `api-design`, or a stack-specific project skill.

## Mental Model

Most bugs come from one or more of:

- Environment
- Data
- Logic

The usual difficulty order is environment > data > logic. Logic is often easiest to inspect, but not always the actual cause.

If logic inspection has gone on for about 30 minutes without a strong lead, deliberately switch to data and environment checks.

## Workflow

1. Write the symptom in one sentence.
2. Write the expected behavior in one sentence.
3. Confirm whether the issue reproduces locally, in tests, in staging, or only in production.
4. Split hypotheses into environment, data, and logic.
5. Gather cheap evidence:
   - Environment: versions, env vars, feature flags, container image, deployment, network, time zone, cache, external service status.
   - Data: actual records, nulls, duplicates, stale state, migrations, payload shape, permissions, deleted rows.
   - Logic: branching, transformations, async order, state transitions, boundary values.
6. Minimize the reproduction.
7. Once the likely cause is known, write a failing test or reproducible command if practical.
8. Fix the confirmed cause, then run the smallest relevant verification.

## Guardrails

- Do not keep rereading the same code without adding new evidence.
- Do not change multiple unrelated variables at once.
- Do not assume frontend data is trustworthy.
- Do not expose low-level IO details while adding diagnostics.
- Preserve useful logs and trace IDs.

## Output

Return:

- Symptom
- Reproduction status
- Hypotheses by bucket
- Evidence gathered
- Most likely cause
- Next action
- Verification result
