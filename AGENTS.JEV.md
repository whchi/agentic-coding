# Jev-Assisted Model Routing

Use alongside `AGENTS.md` when the user or project explicitly selects a Jev-assisted, multi-model workflow and the integration is available. Ordinary engineering work does not require a routing call or model switch.

## Decision boundary

Jev can help with an unresolved routing judgment: task complexity, retry versus escalation, or whether more investigation is warranted. Supply the question and concise evidence only when its answer changes the next action.

Keep code generation, patches, and architecture design with the coding agent. Use tools for deterministic facts such as test results, compilation, types, lint, and diffs; Jev cannot replace or override that evidence.

Read `TYPESAFE_API_KEY` from the environment only when the configured integration needs it. Never print, log, or commit it. If the integration is missing, report the limitation and continue work that does not depend on it.

## Routing and continuation

Respect the user's model choice and use only models and reasoning levels available in the current environment. Within an authorized multi-model workflow, choose the least costly option adequate for the task. Escalate when failed attempts or unresolved complexity justify it; do not require a fixed ladder of model calls.

Continue implementation and affected verification within the agreed scope. Reassess routing when new evidence changes the decision, not after every edit. Report completion from implemented behavior and actual verification; identify unresolved failures or unavailable checks.
