# Instruction optimization — 2026-10-08

## Scope and source

The user requested changes to Markdown in `global-skills/`, `project-skills/`, `coding-agent-flow/`, `commands/`, and the three root `AGENTS*.md` files. Installed copies, plugins, `general-skills/`, and the untracked `pstack/` checkout are excluded.

The supplied article and two screenshots guide this revision. Their relevant principles are: describe concrete skill triggers concisely; load task-specific references only when needed; prefer outcomes and essential constraints over fixed itineraries; use proportional verification; continue already-authorized work through completion. The article's model capability claims are background, not independently verified facts or a requirement to change models.

Success means useful domain guidance and authorization boundaries remain intact while discovery, context loading, and completion behavior become more precise. Shorter text alone is not sufficient evidence of improvement.

## Decisions

- Review all Markdown in scope, including supporting references. Retain concise technical references when they already serve a distinct task.
- Keep commands self-contained because installation copies or converts each command independently.
- Preserve explicit-only invocation policies, licensing, domain contracts, destructive-action authorization, and serial worktree integration with scoped local checks.
- Replace the old mandatory description formula in `docs/agents/rules.md` with a capability and trigger rule; exclusions are useful only for likely routing ambiguity.
- Remove unconditional Jev routing, arbitrary long-running thresholds, append-only activity logs, and repeated generic guidance from AGENTS files. Link optional guidance by task.

## Verification status

Development is split into disjoint worktrees. Each worktree receives content and diff checks; combined repository checks run after serial integration. Structural checks can verify packaging and references but cannot prove improved model routing or behavior. Live model evaluations require an adapter and are not implied by static checks.
