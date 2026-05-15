---
name: write-a-skill
description: Use when creating, revising, splitting, renaming, or reviewing an agent skill so it is concise, composable, triggerable, and aligned with this repository's global-skills/project-skills distribution.
---

# Write A Skill

Create skills that are small, triggerable, and useful in real agent work. Prefer adapting this repo's vocabulary over mirroring an upstream skill wholesale.

## Placement

Choose one home:

- `global-skills/`: reusable across engineering projects
- `project-skills/`: stack-specific or project-local conventions
- `commands/`: one-shot prompt templates or command workflows

If an existing skill already covers the job, update that skill instead of creating a duplicate.

## Required Shape

Every skill must have:

- a folder named with lowercase kebab-case
- `SKILL.md`
- YAML frontmatter with `name` and `description`
- concise body instructions that tell the agent what to do after the skill triggers

The `description` is the trigger surface. Include when to use the skill, not just what it is.

## Writing Rules

- Keep the skill lean. Add only context the agent would not reliably infer.
- Make the workflow concrete enough to act on, but avoid scripts or rigid steps unless deterministic behavior matters.
- Use repo language: skill, command, global, project, context, ADR, codemap.
- Prefer references only for details that are large, optional, or variant-specific.
- Do not add README, quickstart, changelog, or other auxiliary docs inside a skill folder.

## Review Checklist

Before finishing:

- no overlap with an existing installed skill unless intentional
- frontmatter name matches the directory name
- description says when to use it
- instructions are shorter than the problem they solve
- examples are minimal and actionable
- install script and README are updated when the skill is part of the distribution
