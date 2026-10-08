# Repository Evidence

Use this mode when a plan depends on domain terminology, context ownership, prior decisions, or existing behavior. Inspect the evidence that resolves the current uncertainty: the glossary for terms, a context map for ownership, an ADR for a decision, or code and tests for behavior. Do not load every document by default.

Restate the plan using the repository's canonical language. Distinguish documented intent from implemented behavior and proposed changes. When they conflict, surface the discrepancy and resolve which source should change before treating the claim as settled.

## Domain language and ownership

Challenge terms that conflict with the existing glossary. For vague or overloaded language, propose a precise term and explain the distinction; for example, determine whether “account” means Customer or User. Use concrete scenarios to test concept boundaries, cardinality, lifecycle, ownership, and failure behavior.

Follow existing documentation locations. If `CONTEXT-MAP.md` exists, use it to locate the relevant context and its glossary or decisions. A single-context repository may use a root `CONTEXT.md` and `docs/adr/`; multiple contexts may have context-local equivalents plus system-wide decisions. Ask when the topic's owning context is consequential and remains unclear.

Capture resolved terminology in the existing glossary as it stabilizes. `CONTEXT.md` holds domain language and relationships, not specifications, scratch notes, implementation plans, or general programming concepts. Do not record tentative discussion as agreement. Read [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) when creating a glossary or changing its structure. Create a missing glossary lazily, when the first domain term is resolved, rather than scaffolding empty documentation.

## Durable decisions

Use [ADR-FORMAT.md](ADR-FORMAT.md) when a settled decision warrants an ADR: it must be hard to reverse, surprising without context, and the result of a real trade-off. Otherwise retain the decision in the appropriate existing plan or summary. Follow the repository's ADR convention and distinguish proposed choices from accepted decisions.

## Interview output

In each round, explain the repo-grounded interpretation and the conflict or decision being tested. Ask only consequential questions that the evidence cannot answer, with a recommended answer and its tradeoff; bundle independent questions and defer dependent ones. Note relevant documentation updates without imposing a fixed response template. Stop when the plan is coherent enough to implement or name the product or user input still needed.
