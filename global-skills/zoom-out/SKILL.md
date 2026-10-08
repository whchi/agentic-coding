---
name: zoom-out
description: Map an unfamiliar code area's role, callers, dependencies, and invariants when local code is insufficient to understand an intended change.
---

# Zoom Out

Do not start by changing code. Build a system-level map of the area first.

## Workflow

1. Identify the local target: file, function, component, route, module, or behavior.
2. Follow the applicable project instructions. Read a glossary for unfamiliar domain terms, a context map for cross-module ownership, or a relevant ADR when a decision needs context; inspect nearby tests for behavioral contracts.
3. Search outward:
   - direct callers and imports
   - downstream dependencies
   - public interfaces and entry points
   - related tests, fixtures, and docs
4. Summarize one layer above the target. Stop expanding when its role, relevant contracts, and change risks are clear; assess abstraction depth only if it affects the intended edit.

## Output

Return a concise map:

- **Role:** what this area does in the system
- **Domain language:** repo terms that matter
- **Upstream:** callers, routes, jobs, UI flows, or commands
- **Downstream:** storage, APIs, services, helpers, or side effects
- **Invariants:** behavior that must remain true
- **Change risk:** where edits are likely to ripple
- **Next move:** smallest safe inspection, test, or edit
