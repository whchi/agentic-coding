---
name: engineering-context
description: Use when setting up or maintaining project-level engineering context such as CONTEXT.md, CONTEXT-MAP.md, ADR folders, plan folders, issue-tracker notes, and triage labels for agent-friendly development.
---

# Engineering Context

Use this skill to make the repository itself the source of truth for agent work.

## Goal

Create a small context layer that helps agents use the project's real language and decisions:

- `CONTEXT.md`: domain glossary only
- `CONTEXT-MAP.md`: map of multiple contexts, ownership, and where their docs live
- `docs/adr/`: hard-to-reverse technical decisions
- `docs/plans/`: implementation plans and handoffs that should survive chat history
- `docs/agents/issue-tracker.md`: issue tracker conventions, if any
- `docs/agents/triage-labels.md`: label meanings, if any

Create files lazily. Do not scaffold empty bureaucracy if the project does not need it.

## Workflow

1. Inspect existing docs before creating anything.
2. Identify whether the project has one context or multiple bounded/product contexts.
3. Add or update the smallest useful artifact.
4. Keep `CONTEXT.md` free of implementation detail. It is a glossary, not a spec.
5. Use ADRs only for decisions that are hard to reverse, surprising without context, and based on a real tradeoff.
6. Keep issue tracker docs optional. A local plan artifact comes first; GitHub, Linear, Jira, or another tracker is downstream.

## External Skill Packs

When importing an external skill pack that already has a `CONTEXT.md`, treat it as source material, not as an additional hidden authority.

Merge useful terms into the repository's root or context-local `CONTEXT.md`, adapting the vocabulary to the current distribution. Do not leave upstream-specific terms as the only documented source of truth unless the imported pack remains intentionally vendored.

## CONTEXT.md Format

Use short entries:

```md
# Context

## Terms

### Order
The customer-facing purchase record created after checkout.
```

## CONTEXT-MAP.md Format

Use this only when there are multiple contexts:

```md
# Context Map

| Context | Purpose | Docs | Key Code |
|---|---|---|---|
| Ordering | Checkout and order lifecycle | `src/ordering/CONTEXT.md` | `src/ordering/` |
```

## ADR Format

Use a short numbered ADR:

```md
# ADR 0001: Use Postgres For Orders

## Status
Accepted

## Context
What made this decision necessary.

## Decision
The decision made.

## Consequences
What this enables and what it costs.
```
