# /debug-triage

Use this command when debugging a bug, flaky behavior, production issue, or confusing local failure.

## Workflow

1. State the observed symptom and the expected behavior.
2. Classify likely causes into three buckets:
   - Environment: runtime, network, dependency versions, deployment, container, config, permissions, time zone, cache, external services.
   - Data: missing rows, malformed payloads, stale state, unexpected nulls, duplicate records, migration drift, edge-case fixtures.
   - Logic: wrong branching, incorrect assumptions, off-by-one errors, state transitions, async ordering, invalid transformations.
3. Start with the cheapest evidence that separates the buckets.
4. Build a feedback loop before guessing: reproduce the symptom, capture the exact failure, and make it rerunnable.
5. Minimize the reproduction until one likely cause remains.
6. Form 3 to 5 falsifiable hypotheses and test the cheapest one first.
7. Instrument only at boundaries that distinguish hypotheses. Remove temporary instrumentation before finishing.
8. Fix the smallest confirmed cause and add regression coverage when behavior changed.

## Output

Return:

- Symptom
- Most likely bucket
- Evidence gathered
- Reproduction path
- Hypotheses tested
- Next checks
- Proposed fix or reproduction path
