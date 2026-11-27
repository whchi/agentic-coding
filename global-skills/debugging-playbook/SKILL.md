---
name: debugging-playbook
description: Diagnose a reported failure or flaky behavior when its cause is unknown, using a reproducible symptom and evidence from environment, data, and logic.
origin: Notion Engineering Practices
---

# Debugging Playbook

Diagnose the reported symptom with a reproducible feedback loop. Distinguish **proximate cause** (the immediate crash or symptom), **root cause** (the defective invariant or state transition), and **contributing factors**. A diagnosis-only request ends with the cause and evidence; a request to fix the problem includes implementation and verification once the cause is known.

## Reproduce and narrow

1. **Build an MRE (Minimal Reproducible Example):** establish the expected contract and the exact failing surface via a failing test, CLI command, browser step, or trace replay. Shrink the input/surface until removing anything else makes the symptom disappear.
2. **Form falsifiable hypotheses** and run the cheapest experiment that eliminates candidates across three axes (search directions, not mandatory checklists):
   - **Environment:** runtime/dependency versions, config, feature flags, deployment skew, network/DNS/TLS, timezone/locale, cache, or upstream availability.
   - **Data:** actual persisted records and wire payloads, duplicates, nulls, stale/corrupt state, schema/migration drift, or authorization/tenant boundaries.
   - **Logic:** control flow, boundary values, state transitions, async ordering, or implicit assumptions.
3. **Use high-leverage narrowing techniques before reading code line by line:**
   - **Binary search / `git bisect` / delta debugging:** bisect the commit range, input payload, or execution pipeline to cut the search space in half each step.
   - **Differential debugging:** diff a working case against the failing case (env vars, headers, payloads, DB rows, feature flags, versions).
   - **Observability triad:** correlate structured logs, metrics, and distributed traces via **correlation / trace IDs** before adding ad-hoc logging.
   - **Heisenbugs & nondeterministic failures:** when symptoms vanish under a debugger or retry, inspect race conditions, shared mutable state, clock/RNG dependence, or uninitialized state; keep instrumentation non-invasive so it does not mask timing.

## Experimental discipline

- Change one variable at a time; instrument only where output distinguishes competing hypotheses, and never expose secrets or raw IO internals to users.
- **Revert disproved experiments immediately:** when evidence refutes a hypothesis, undo the speculative changes it introduced before testing the next one.
- **Attack the premise:** when two attempted fixes sharing the same premise fail the same reproduction, stop patching — challenge the premise and verify which component actually owns the wrong state.

## Fix and verify within scope

Keep the reproduction as a regression check when practical. For an already-authorized fix, implement the smallest supported change, rerun the original failing surface, and run affected checks within repository worktree limits. Load another skill only when its specific guidance helps; do not stop simply to switch skills or ask again for an already-authorized fix.

For diagnosis-only requests, report the cause and proposed fix without changing application code. If reproduction or evidence is unavailable, name the missing prerequisite and keep the conclusion provisional.

A passing unit test does not establish that the user's reported failure is gone. Verify on the relevant surface, or explicitly report verification as incomplete. Remove temporary diagnostic instrumentation according to repository rules.

Report the confirmed root cause (or remaining falsifiable hypothesis), supporting evidence, reproduction status, and verification outcome. Include a next action only when work remains.
