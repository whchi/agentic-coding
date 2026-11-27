---
name: maintainable-code-review
description: Review maintainability or proposed design patterns when abstraction, indirection, or unclear function contracts make code difficult for its owning team to change.
---

# Maintainable Code Review

Use this skill when evaluating whether code, abstractions, and contracts remain clear and economical to evolve for the team that owns them.

## Boundaries

Delegate narrower ownership questions to their canonical skills:

- `api-design` for HTTP endpoint contracts, status codes, response shapes, and request validation.
- `module-boundaries` for folder/module organization, persistence vs domain placement, and DDD / Clean Architecture fit.
- `blast-radius` for proving downstream/cross-boundary safety of a proposed behavioral change.
- `testing-strategy` for test levels, test doubles, fixtures, and coverage.
- `js-ts-coding-standards` for JavaScript/TypeScript language-level conventions.

When evaluating a proposed GoF design pattern or comparing pattern alternatives against direct code, read [design-patterns.md](references/design-patterns.md).

## Core Principle

Treat long-term change cost as a first-class constraint. Balance **indirection tax**, **cognitive complexity**, and abstraction depth against team skill, codebase size, and observed change frequency. Prefer **deep modules** (simple interface hiding substantial complexity) over **shallow modules** (broad or noisy interface wrapping trivial logic).

## Workflow

1. Identify the change intent and expected maintenance surface; read surrounding code to learn local idioms before judging style.
2. **Module depth & information leakage:** verify each interface hides meaningful behavior without forcing callers to understand internal state, ordering, or representation. Flag **shallow modules** and **pass-through methods**.
3. **Deletion test (abstraction ROI):** if removing an abstraction makes complexity disappear, it is pass-through ceremony; if complexity explodes across callers, it earns its keep.
4. **Rule of Three / YAGNI:** distinguish real variation seams from **speculative generality**. One implementation rarely justifies an interface unless dependency direction requires it; two or more concrete variants make the seam credible.
5. **Cohesion & connascence:** check for **shotgun surgery** (one change touches many scattered files), **divergent change** (one module changes for unrelated reasons), **feature envy**, and unnecessary **connascence** (positional arguments, implicit magic values, hidden temporal ordering).
6. **Contracts & primitive obsession:** replace **stringly-typed** / primitive conditions and **boolean traps** with explicit constants, enums, or discriminated unions. Keep return shapes uniform (explicit result types over mixed `null`/primitive/object/exception paths) and avoid broad unrelated parameter unions.
7. **Control-flow clarity:** flag clever metaprogramming or dynamic dispatch that obscures control flow, validation, or data shape without measured benefit.
8. **Legacy API migration:** when introducing a replacement API, prefer migrating callers and deleting the legacy path (or using **Expand-and-Contract** / **Strangler Fig** when deployed consumers require a window) over leaving indefinite compatibility shims.
9. Keep recommendations proportional: do not prescribe broad refactors for local issues.

## Deletion Evidence

The deletion test in step 3 evaluates whether an abstraction earns its keep. Recommending dead-code removal from a running system is a separate claim — prove unreachability first:

- **Static reach:** absent across repo references (`rg`, including tests, fixtures, and config).
- **Dynamic reach:** no reflection, string-keyed dispatch, DI container registrations, templates/queries, generated clients, or DB-stored handler names.
- **External consumers:** no published APIs, SDKs, sibling repositories, scripts, or dashboards depending on it.
- **Runtime evidence:** for public, dynamic, or deployed entry points, confirm disuse via telemetry (stating the observation window) or consumer ownership.

Split dead-code findings into:

- **Safe to remove now** — evidence complete, no active consumers; include removal and verification steps.
- **Defer with a plan** — state the missing precondition (flag off window, telemetry threshold, consumer migration, owner sign-off) and rollback path.

For private code with fully visible reachability, static and build evidence may suffice. Follow repository deletion rules and obtain explicit approval for exact targets.

## Bad Smells

- **Shallow modules / pass-through layers:** wrappers that forward arguments without absorbing complexity or invariants.
- **Speculative generality:** interfaces, registries, or plugin hooks built for a single implementation and hypothetical future variation.
- **Primitive obsession / boolean traps:** magic strings/numbers driving branches, or opaque boolean flags altering function semantics.
- **Ambiguous return contracts:** one function returning `null`, primitives, objects, or throwing depending on path.
- **Shotgun surgery / feature envy:** adding one variant forces synchronized edits across unrelated modules, or helpers reach deeply into another module's internals.
- **Indirection tax & opaque dynamism:** reflection, string lookup, or generic helpers obscuring straightforward business rules.
- **Over-wide test seams:** abstractions introduced solely for mocking that expose broader internals than the behavior they protect.
- **Zombie compatibility layers:** shims or legacy APIs kept without an identified consumer or migration timeline.

## Output

Lead with concrete findings. For each finding, include:

- File and line (when available)
- Maintainability risk / named smell
- Concrete impact on future changes
- Smallest useful fix
