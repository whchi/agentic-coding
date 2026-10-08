---
name: module-boundaries
description: Choose folder and module organization or review whether concrete behavior belongs in persistence, an application use case, or an existing domain model.
---

# Module Boundaries

Recommend the smallest boundary change that improves ownership and change locality. A review produces findings; move code only when a refactor or fix is requested.

## Select the relevant guidance

- For folder layout, feature/MVC/domain organization, or module dependencies, read [references/project-structure.md](references/project-structure.md).
- For repository, DAO, service, or use-case responsibility, read [references/responsibility-placement.md](references/responsibility-placement.md).

Read both only when the task changes organization and responsibility. Start from the behavior being changed, its callers, and existing dependency direction; do not infer ownership from folder names alone. Ordinary layering does not require DDD or a separate domain class for every table.

For DDD adoption, bounded contexts, or aggregate modeling, use `domain-driven-design-advisor` when available. Local abstraction and readability questions belong to `maintainable-code-review`; endpoint contracts belong to `api-design`. Consult those only when the task needs their separate decisions.

## Result

Show the current and proposed owners, evidence of misplaced responsibility, the smallest migration path, and affected behavior to verify. Retain useful existing boundaries and call out any migration cost that outweighs the benefit.
