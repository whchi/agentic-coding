---
description: "Assess a proposed design pattern or abstraction against concrete code change pressure and simpler alternatives."
---

# /design-pattern-fit

Recommend the smallest design that addresses the observed problem. This is an assessment unless the user also requests implementation.

Inspect the affected code, callers, and relevant contracts to identify what varies, repeats, leaks across a boundary, or is difficult to change. Use observed requirements rather than hypothetical future extensibility.

## Decision criteria

- Prefer direct code, a function, map, module, or small interface when it solves the problem.
- Recommend a pattern only when it isolates a real variation or protects a meaningful boundary. A single implementation can justify a boundary when dependency direction matters; its mere existence does not justify an abstraction.
- Compare only plausible candidates. Explain their indirection, lifecycle, testing, and debugging costs.
- Use language-native composition rather than translating every pattern into classes.
- Combine patterns only when each addresses an independent pressure.
- If removing an abstraction removes complexity, it may be pass-through code. If it spreads required complexity across callers, it may earn its place.

Use these distinctions when relevant:

| Pressure | Useful distinction |
|---|---|
| Construction | A factory selects varying products; an abstract factory preserves compatible families; a builder manages meaningful assembly rules. A constructor or named parameters may suffice. |
| External boundary | An adapter translates contracts; a facade simplifies a subsystem. Keep vendor concepts and business policy on their proper sides. |
| Variable behavior | Strategy selects interchangeable policies; State owns valid transitions. A function map or transition table may suffice. |
| Execution | Command adds queueing, undo, audit, or other execution semantics. Wrapping a function alone adds no value. |
| Events | Observer decouples subscribers but requires explicit ordering, failure, and transaction semantics. Direct calls may be clearer. |
| Wrapping and access | Decorator adds behavior; Proxy controls access. Keep latency, failure, cache invalidation, and wrapper order visible. |
| Trees and operations | Composite models natural hierarchies; Visitor suits a stable structure with varying operations. Native traversal may suffice. |
| Shared resources | Singleton needs an actual lifecycle constraint; Flyweight needs measured memory pressure. Avoid hidden mutable state and speculative optimization. |

Do not force exhaustive catalog coverage. Investigate another pattern only when the code's pressure makes it relevant.

## Result

Lead with the recommendation and evidence. If no pattern is warranted, say `No GoF design pattern is justified here` and give the smallest direct improvement.

When a pattern is justified, explain the protected boundary or variation, the simplest alternative and why it falls short, material costs, and the minimal migration. Include control flow, lifecycle, error handling, or verification details only where the proposed change affects them.

If implementation is already authorized, carry the selected change through scoped verification without another approval gate. Otherwise provide the assessment without modifying code.
