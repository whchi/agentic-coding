# /debug-triage

Use this command when debugging a bug, flaky behavior, production issue, or confusing local failure.

## Workflow

1. State the observed symptom and the expected behavior.
2. Classify likely causes into three buckets:
   - Environment: runtime, network, dependency versions, deployment, container, config, permissions, time zone, cache, external services.
   - Data: missing rows, malformed payloads, stale state, unexpected nulls, duplicate records, migration drift, edge-case fixtures.
   - Logic: wrong branching, incorrect assumptions, off-by-one errors, state transitions, async ordering, invalid transformations.
3. Start with the cheapest evidence that separates the buckets.
4. If logic inspection has taken around 30 minutes without a convincing lead, deliberately shift to data and environment checks.
5. Create a minimal reproduction or failing test once the likely bucket is known.
6. Fix the smallest confirmed cause and add regression coverage when behavior changed.

## Output

Return:

- Symptom
- Most likely bucket
- Evidence gathered
- Next checks
- Proposed fix or reproduction path
