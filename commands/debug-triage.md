---
description: Triage a bug or confusing failure by gathering evidence and identifying the confirmed cause; diagnosis only unless the user explicitly asks for a fix.
---

# /debug-triage

Use this command for diagnosis only when debugging a bug, flaky behavior, production issue, or confusing local failure. For the full investigation workflow, follow `debugging-playbook`.

## Workflow

1. State the observed symptom and expected behavior.
2. Classify likely causes into environment, data, or logic.
3. Start with the cheapest evidence that separates those buckets.
4. Reproduce the symptom with a rerunnable test, command, or request when practical.
5. Form 3 to 5 falsifiable hypotheses and test the cheapest one first.
6. Record the evidence that confirms or rules out each hypothesis.

Do not modify application code in triage mode. If the user explicitly asks for a fix after the cause is confirmed, switch to the relevant implementation skill and report its verification separately.

## Output

Return:

- Symptom and expected behavior
- Reproduction status and path
- Most likely bucket
- Hypotheses tested and evidence
- Confirmed cause, or the exact missing evidence
- Next check
- Proposed fix (not applied in triage mode)
