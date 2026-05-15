# Agentic Coding Distribution

Domain glossary for this repository. Defines the shared language used across skills, commands, and documentation in this agentic coding assets distribution.

## Language

**Skill**:
A reusable agent behavior packaged as a directory with a `SKILL.md` file. A skill should have a clear trigger surface and concise workflow guidance.
_Avoid_: capability, plugin, tool

**Global Skill**:
A skill intended to be reused across engineering projects. In this repo, "global" means cross-project engineering utility, not universally useful for every possible conversation.
_Avoid_: universal skill, system skill

**Project Skill**:
A skill intended for project-local or stack-specific conventions. Project skills are installed into a repository rather than the user's global agent configuration.
_Avoid_: local skill, stack module

**Command**:
A reusable prompt template or slash-command style workflow for a bounded task.
_Avoid_: snippet, macro

**Engineering Context**:
Project-level documentation that helps agents use the repo's real language and decisions: `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, plans, and agent-facing tracker notes.
_Avoid_: project docs, wiki

**Context Map**:
A map used when a repository has multiple product, domain, or bounded contexts. It points agents to context-specific glossaries, decisions, and key code areas.
_Avoid_: architecture map, module index

**ADR**:
An architecture decision record for decisions that are hard to reverse, surprising without context, and based on a real tradeoff.
_Avoid_: decision log, tech spec

## Relationships

- An **Agentic Coding Distribution** contains **Skills**, **Project Skills**, **Commands**, and **References**
- A **Global Skill** is installed to the user's global agent configuration
- A **Project Skill** is installed into a specific repository
- **Commands** are installed alongside skills into agent configuration directories

## Example dialogue

> **Dev:** "Should `api-design` be a **Global Skill** or a **Project Skill**?"
> **Maintainer:** "It's a **Global Skill** — it's reusable across any engineering project that needs API design guidance."
>
> **Dev:** "What's the difference between a **Skill** and a **Command**?"
> **Maintainer:** "A **Skill** is a full workflow with structured steps and decision points. A **Command** is a single reusable prompt for a bounded task like `code-review`."

## Flagged ambiguities

- "global" was used to mean both "system-wide" and "cross-project"; resolved: in this repo it specifically means reusable across engineering projects, not universally applicable to every conversation.
- "context" was used to mean both "agent conversation context" and "project domain context"; resolved: **Engineering Context** refers specifically to project-level documentation artifacts.
