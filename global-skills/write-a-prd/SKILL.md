---
name: write-a-prd
description: Write a PRD or feature specification when the user needs a requirements document connecting user outcomes, scope, constraints, and acceptance criteria.
---

# Write a PRD

Create a requirements document that supports product decisions and engineering planning. Match the user's language; use zh-TW for Traditional Chinese requests.

Use facts already supplied and inspect only the repository areas that constrain the proposed feature. Consult a glossary for disputed terms, a context map for cross-domain work, or an ADR for a relevant prior decision. Do not require a full repository tour for every spec.

Ask only for unresolved choices that materially affect user behavior, scope, or correctness. Continue drafting supported sections while those choices remain open, clearly distinguishing assumptions from decisions. Existing authorization to write the PRD does not require a second approval to finish it.

## Useful content

Scale the document to the feature. Include:

- **Problem and outcome:** affected users, the current friction, and the observable improvement.
- **Proposed experience:** the main journey, important states, failure cases, and acceptance criteria.
- **Scope:** included behavior, constraints, and explicit non-goals.
- **Decisions and risks:** agreed product and interface decisions, affected system areas, dependencies, and unresolved assumptions.
- **Validation:** how the user outcome and highest-risk behavior will be checked, using existing test surfaces where appropriate.

Use user stories when they clarify different needs; do not produce variants to fill a quota. Describe modules or contracts only as far as requirements need them. Link stable source documents instead of duplicating implementation detail.

For an early or ambiguous product idea, read [product-discovery.md](references/product-discovery.md). Pull in only prompts that resolve a real uncertainty.

Do not invent personas, market evidence, or technical feasibility. Complete the requested document with explicit open questions when evidence is unavailable; distinguish a draft awaiting a product decision from an implementation-ready specification.
