---
name: zoom-out
description: Use when an unfamiliar code area needs a higher-level map before editing, including module purpose, upstream/downstream callers, domain responsibility, invariants, and how it fits the broader system. Do NOT use for a local edit whose callers and side effects are already visible in the code being changed.
---

# Zoom Out

Do not start by changing code. Build a system-level map of the area first.

## Workflow

1. Identify the local target: file, function, component, route, module, or behavior.
2. Read project context that exists: `AGENTS.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs near the area, and nearby tests.
3. Search outward:
   - direct callers and imports
   - downstream dependencies
   - public interfaces and entry points
   - related tests, fixtures, and docs
4. Fill the map below one layer above the code. Under **Change risk**, say whether the abstraction is deep (a small interface hiding real behavior) or shallow (callers must understand its implementation).

## Output

Return a concise map:

- **Role:** what this area does in the system
- **Domain language:** repo terms that matter
- **Upstream:** callers, routes, jobs, UI flows, or commands
- **Downstream:** storage, APIs, services, helpers, or side effects
- **Invariants:** behavior that must remain true
- **Change risk:** where edits are likely to ripple
- **Next move:** smallest safe inspection, test, or edit
