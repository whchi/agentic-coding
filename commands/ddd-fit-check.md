---
description: Decide whether DDD is worth adopting before introducing aggregates, repositories, domain services, or domain-based folders; delegate the full assessment to domain-driven-design-advisor.
---

# /ddd-fit-check

Use this command as a short entry point before introducing DDD concepts. Read `CONTEXT.md`, `CONTEXT-MAP.md`, and relevant ADRs when they exist, then follow `domain-driven-design-advisor` for the full fit assessment.

Return only:

- DDD fit: strong, partial, weak, or insufficient evidence
- Evidence and unknowns
- Whether MVC/function folders are enough for now
- The smallest useful next step, or `No DDD adoption recommended`

When fit is weak or evidence is insufficient, do not invent bounded contexts, subdomains, or patterns. If the user asks to implement the chosen direction, switch to the relevant architecture skill and verify the change separately.
