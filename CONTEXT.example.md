# Context

Domain glossary for this repository.

## Language

**Skill**
A reusable agent behavior packaged as a directory with a `SKILL.md` file. A skill should have a clear trigger surface and concise workflow guidance.

**Global Skill**
A skill intended to be reused across engineering projects. In this repo, "global" means cross-project engineering utility, not universally useful for every possible conversation.

**Project Skill**
A skill intended for project-local or stack-specific conventions. Project skills are installed into a repository rather than the user's global agent configuration.

**Command** 
A reusable prompt template or slash-command style workflow for a bounded task.

**Engineering Context**
Project-level documentation that helps agents use the repo's real language and decisions: `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, plans, and agent-facing tracker notes.

**Context Map**
A map used when a repository has multiple product, domain, or bounded contexts. It points agents to context-specific glossaries, decisions, and key code areas.

**ADR**
An architecture decision record for decisions that are hard to reverse, surprising without context, and based on a real tradeoff.

## Relationships

- An Agentic Coding Distribution contains Skills, Project Skills, Commands, and References.

## Flagged Ambiguities

- "global" can sound universal; in this repo it means reusable across engineering projects.
