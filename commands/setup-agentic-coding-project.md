# /setup-agentic-coding-project

Set up a project-level engineering context layer for agent-friendly work.

Use this command when a repo needs `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, plan folders, or issue-tracker conventions. Do not overwrite existing docs without reading them first.

This is the one-time setup entrypoint for the `engineering-context` project skill.

## Workflow

1. Inspect existing project docs:
   - `AGENTS.md`
   - `CONTEXT.md`
   - `CONTEXT-MAP.md`
   - `docs/`
   - `.codex/`
   - `.opencode/`
2. Decide the smallest useful setup:
   - single context: root `CONTEXT.md`
   - multiple contexts: root `CONTEXT-MAP.md` plus context-local `CONTEXT.md`
   - meaningful decisions: `docs/adr/`
   - durable plans: `docs/plans/`
   - tracker conventions: `docs/agents/`
3. Ask only when the choice affects project structure, issue tracker integration, or existing docs.
4. Create missing directories/files one at a time.
5. Keep generated content minimal and truthful. Use TODO markers only for facts the repo does not yet know.

## Default Artifacts

Prefer these names:

```text
CONTEXT.md
CONTEXT-MAP.md
docs/adr/
docs/plans/
docs/agents/issue-tracker.md
docs/agents/triage-labels.md
```

## Output

Report:

- files created or updated
- assumptions made
- docs intentionally skipped
- next recommended skill or command
