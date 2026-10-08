---
description: "Diagnose a bug, flaky behavior, or confusing failure; diagnosis only unless a fix is also requested."
---

# /debug-triage

Identify the cause from observable evidence. Use `debugging-playbook` when available; otherwise investigate directly.

Establish the symptom, expected behavior, and a rerunnable reproduction when practical. Read logs, configuration, data, and affected code only as needed to distinguish plausible causes. Test the cheapest discriminating hypothesis first; do not invent a fixed number of hypotheses.

Continue until evidence supports a cause or a specific missing input prevents progress. Separate confirmed facts from inference and record checks that rule out alternatives.

In diagnosis only mode, do not modify application code. When the user's request already includes a fix, continue from the confirmed cause through the smallest repair and scoped verification; do not require a second request.

Return the reproduction, confirmed cause or missing evidence, supporting checks, and proposed fix. If a fix was authorized and applied, report its verification separately. Include a next diagnostic check only when the cause remains unresolved.
