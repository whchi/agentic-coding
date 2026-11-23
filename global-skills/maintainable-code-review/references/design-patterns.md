# Design Pattern Fit

Recommend the smallest design that addresses observed change pressure. Inspect affected code, callers, and contracts to identify what varies, repeats, leaks across a boundary, or resists change; rely on observed requirements rather than hypothetical future extensibility.

## Decision criteria

- Prefer direct code, a function, map, module, or small interface when it solves the problem.
- Recommend a pattern only when it isolates a real variation or protects a meaningful boundary. A single implementation can justify a boundary when dependency direction matters; its mere existence does not justify an abstraction.
- Compare only plausible candidates and explain their indirection, lifecycle, testing, and debugging costs.
- Use language-native composition rather than translating every pattern into classes.
- Combine patterns only when each addresses an independent pressure.

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

Do not force exhaustive catalog coverage. If no pattern is warranted, say `No GoF design pattern is justified here` and give the smallest direct improvement. When a pattern is justified, explain the protected boundary or variation, why the simplest alternative falls short, material costs, and the minimal migration.
