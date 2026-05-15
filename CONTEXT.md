# Context

Domain glossary for this repository.

## Terms

### Agentic Coding Distribution
A curated collection of engineering-focused skills, project skills, commands, and references for agent-assisted software work.

### Skill
A reusable agent behavior packaged as a directory with a `SKILL.md` file. A skill should have a clear trigger surface and concise workflow guidance.

### Global Skill
A skill intended to be reused across engineering projects. In this repo, "global" means cross-project engineering utility, not universally useful for every possible conversation.

### Project Skill
A skill intended for project-local or stack-specific conventions. Project skills are installed into a repository rather than the user's global agent configuration.

### Command
A reusable prompt template or slash-command style workflow for a bounded task.

### Engineering Context
Project-level documentation that helps agents use the repo's real language and decisions: `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, plans, and agent-facing tracker notes.

### Context Map
A map used when a repository has multiple product, domain, or bounded contexts. It points agents to context-specific glossaries, decisions, and key code areas.

### ADR
An architecture decision record for decisions that are hard to reverse, surprising without context, and based on a real tradeoff.

### Issue Tracker
The tool or convention that hosts a repository's issues, such as GitHub Issues, Linear, Jira, or local markdown files.

Avoid: backlog manager, backlog backend, issue host.

### Issue
A single tracked unit of work inside an Issue Tracker: a bug, task, PRD, or implementation slice.

Avoid: ticket, except when quoting an external system that uses that word.

### Triage Role
A canonical state label applied to an Issue during triage. Concrete label names belong in project docs such as `docs/agents/triage-labels.md`.

## Relationships

- An Agentic Coding Distribution contains Skills, Project Skills, Commands, and References.
- An Engineering Context helps Skills and Commands align with a repository's language and decisions.
- An Issue Tracker holds many Issues.
- An Issue carries one Triage Role at a time.

## Flagged Ambiguities

- "global" can sound universal; in this repo it means reusable across engineering projects.
- "backlog" can mean either a tool or a body of work. Use Issue Tracker for the tool and Issues for tracked work.
