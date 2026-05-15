---
name: maintainable-code-review
description: Use when reviewing code or refining an implementation for maintainability, team readability, abstraction level, dynamic behavior, return/parameter contracts, and long-term change cost. Do NOT use as the primary skill for API contracts, folder structure, repository boundaries, or test strategy.
---

# Maintainable Code Review

Use this skill when code needs to be understandable and maintainable by the actual team that owns it.

## Boundaries

Use related skills for narrower ownership questions:

- `api-design` for endpoint contracts, status codes, response shapes, and request validation.
- `project-structure-advisor` for folder/module organization.
- `repository-boundary-review` for persistence vs business behavior placement.
- `testing-strategy` for test levels, mocks, fixtures, and coverage.
- `js-ts-coding-standards` for JavaScript/TypeScript language-level conventions.

## Core Principle

Write code with maintenance as a first-class constraint. Choose the amount of dynamic programming, indirection, and abstraction based on team skill, project size, and change frequency.

Simple problems should use simple solutions. Complex problems may need complex solutions, but only when the complexity buys clarity, safety, or flexibility.

## Workflow

1. Identify the change intent and the future maintenance surface.
2. Read surrounding code to learn existing patterns before judging style.
3. Check whether the abstraction level fits the team and codebase.
4. Check module depth: does a small interface hide meaningful behavior, or does the caller still need to understand the implementation?
5. Apply the deletion test: if deleting an abstraction makes complexity disappear, it is likely pass-through code; if complexity reappears across callers, the abstraction may be earning its keep.
6. Distinguish real seams from hypothetical seams. One adapter usually means direct code may be enough; two or more adapters make the seam more credible.
7. Prefer explicit constants, enums, and named concepts over primitive condition strings.
8. Check return contracts: avoid functions returning more than two unrelated shapes.
9. Check parameter contracts: avoid broad unions or many unrelated accepted types unless the runtime behavior truly requires it.
10. Flag clever dynamic behavior when it hides control flow, validation, or data shape.
11. Check whether DDD or clean architecture abstractions are paying for themselves.
12. Keep recommendations proportional: do not request large rewrites for local issues.

## Review Signals

Good signs:

- Names reveal business meaning.
- Data shape is validated before reaching deeper layers.
- Condition values use constants, enums, or discriminated unions.
- Functions return one stable shape or an explicit result type.
- Abstractions remove meaningful duplication or complexity.
- Modules improve locality: related behavior, invariants, and tests are concentrated behind a useful interface.

Bad smells:

- Primitive strings or numbers drive important conditions.
- One function returns null, primitives, objects, and exceptions depending on path.
- Generic helpers obscure business rules.
- Dynamic lookup replaces simple branching without a clear benefit.
- Code requires unusually deep framework knowledge for ordinary changes.
- DDD folders exist but contain anemic models, getters/setters only, and business logic scattered elsewhere.
- Domain objects know about HTTP, ORM, vendor SDKs, or response formatting.
- Clean architecture layers are present but dependency direction is reversed.
- Pass-through modules add names without leverage.
- Interfaces exist only for hypothetical future variation.
- Test seams are broader than the behavior they protect.

## Output

When reviewing, lead with concrete findings. Include:

- File and line when available
- Maintainability risk
- Why the risk matters for future changes
- Smallest useful fix
