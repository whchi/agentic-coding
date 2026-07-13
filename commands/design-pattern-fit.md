---
description: Judge whether a classic design pattern fits a concrete code pressure without overengineering; allow a no-pattern result.
---

# /design-pattern-fit

Use this command to judge whether a section of code should use a classic object-oriented design pattern, which pattern fits best, and whether a mixed pattern is justified.

The goal is not to label code with pattern names. The goal is to protect the codebase from overengineering while still identifying useful abstractions when real change pressure exists.

## When To Use

Use this command when the user asks things like:

- Which design pattern fits this code?
- Is this design overengineered?
- How should I refactor this growing conditional or duplicated flow?
- Should this use Strategy, Factory, Observer, Adapter, or a mix?
- How do I decouple object creation, external integrations, state changes, or cross-cutting behavior?

## Core Rules

1. Diagnose the code pressure before naming a pattern.
2. Prefer direct code, functions, maps, modules, or small interfaces when they solve the problem.
3. Recommend a pattern only when it isolates a real variation or boundary.
4. Compare at most 1 to 3 candidates unless the user asks for a catalog.
5. Always name the cost: indirection, lifecycle complexity, test burden, or debugging overhead.
6. In JavaScript, TypeScript, Python, Go, or functional code, translate GoF class patterns into simpler language-native forms when appropriate.
7. A mixed pattern is justified only when there are independent pressures. Do not stack patterns for style.
8. Apply the deletion test: if deleting the abstraction makes complexity disappear, it is probably pass-through code; if complexity reappears across callers, it may be earning its keep.
9. Distinguish real seams from hypothetical seams. One adapter usually means direct code may be enough; two or more adapters make the seam more credible.

## Decision Workflow

### 1. Inspect The Code Pressure

Identify what is actually changing or hurting:

- Object creation varies.
- A family of related objects must stay compatible.
- Object construction is complex or duplicated.
- A third-party or legacy API leaks inward.
- A complex subsystem needs a stable entry point.
- Optional behavior wraps a core object.
- A tree structure needs uniform operations.
- An algorithm or policy varies.
- Actions need queueing, undo, audit, retry, or authorization.
- State changes behavior or transition validity.
- Events need subscribers.
- Traversal, history, grammar evaluation, or operations over a stable structure are the main issue.

Also identify whether the current module is deep or shallow:

- Deep: small interface hides meaningful behavior and improves locality.
- Shallow: callers must understand nearly as much as the implementation.

### 2. Classify The Primary Pressure

| Primary pressure | Candidate family |
|---|---|
| Construction varies | Creational |
| Related product families must stay compatible | Creational |
| Complex object assembly | Creational |
| Existing API does not match internal needs | Structural |
| Complex subsystem needs a simpler entry point | Structural |
| Behavior should wrap an object transparently | Structural |
| Tree / hierarchy needs uniform handling | Structural |
| Algorithm or policy varies | Behavioral |
| Action needs execution metadata or history | Behavioral |
| State changes allowed behavior | Behavioral |
| Many subscribers react to events | Behavioral |
| Traversal / undo / grammar / external operation varies | Behavioral |

### 3. Choose Candidate Patterns

Use the catalog below. Pick the smallest candidate set that explains the actual pressure.

### 4. Reject Bad Fits

For each tempting pattern that is not recommended, explain why it does not fit this code.

### 5. Recommend The Smallest Refactor

Prefer this order:

1. Simple function, map, module split, or direct call.
2. Interface plus concrete implementation when dependency direction matters.
3. One design pattern.
4. A mixed pattern only for independent pressures.

## GoF Pattern Catalog

### Creational Patterns

| Pattern | Fits when | Avoid when |
|---|---|---|
| Factory Method | Creation depends on runtime context, subclass, plugin type, environment, or a framework lifecycle hook. | There is only one product or a simple constructor/map is enough. |
| Abstract Factory | Multiple related products must be created as compatible families, such as provider-specific clients or platform widgets. | Only one object varies or product compatibility is not a real rule. |
| Builder | Construction has many optional steps, validation rules, representations, or unreadable constructor arguments. | The object is a simple DTO with stable fields. |
| Prototype | Cloning a configured object is clearer or cheaper than constructing from scratch. | Identity, resource handles, or shallow/deep copy semantics are risky. |
| Singleton | Exactly one process-level instance is required by an external constraint and lifecycle is explicit. | It is just convenient global mutable state. |

#### Factory Method

Use for one varying product creation step. Common signals are repeated `switch(type)` for creation, framework hooks that create products, or tests that need product substitution.

Costs and risks: factories can hide dependencies, become business workflow containers, or add indirection for a single product.

Simpler alternatives: direct constructor, function map, dependency injection.

#### Abstract Factory

Use when a set of created objects must be compatible as a family. Examples: storage client plus signer plus URL builder by provider; parser plus exporter by document family.

Costs and risks: fake families, broad factory interfaces, provider details leaking past the boundary.

Simpler alternatives: Factory Method for one dimension, config object, Adapter for SDK mismatch.

#### Builder

Use when construction is staged, heavily optional, validated, or repeatedly duplicated in tests and production.

Costs and risks: invalid partial objects, fluent APIs that hide validation, side effects inside builders.

Simpler alternatives: object literal, named parameters, static factory, schema validation.

#### Prototype

Use when runtime-configured objects act as templates and most fields are shared.

Costs and risks: shared mutable nested state, open handles copied accidentally, unclear identity.

Simpler alternatives: immutable copy/spread, Builder with defaults, named factory presets.

#### Singleton

Use only for a true single process-level resource such as immutable config, telemetry registry, event loop integration, or a scarce device handle.

Costs and risks: hidden dependencies, order-dependent tests, request/session state leakage, mistaken assumptions in serverless or multi-process systems.

Simpler alternatives: dependency injection, explicit app context, module-level immutable constants, resource pool.

### Structural Patterns

| Pattern | Fits when | Avoid when |
|---|---|---|
| Adapter | External, legacy, or vendor API does not match the internal interface. | You own both sides and can change the source interface directly. |
| Bridge | Abstraction and implementation vary independently and subclass combinations are exploding. | Only one axis varies or plain composition is enough. |
| Composite | Leaf and group objects form a tree and clients should treat them uniformly. | The data is not naturally hierarchical. |
| Decorator | Add optional responsibilities around an object without changing the core. | Wrapper order is unclear or framework middleware already solves it. |
| Facade | A complex subsystem needs a simpler stable entry point for clients. | The facade becomes a god service or hides bad internals. |
| Flyweight | Many objects share immutable intrinsic state and memory pressure is measured. | Object count is small or shared state would be mutable/confusing. |
| Proxy | Access to another object needs lazy loading, auth, cache, rate limit, remote access, or audit control. | It hides network/DB cost or failure behind a local-looking call. |

#### Adapter

Use to translate external DTOs, methods, errors, pagination, or SDK models into stable internal contracts.

Costs and risks: only renaming methods while vendor concepts still leak inward; swallowing diagnostics; mixing business policy into boundary translation.

Simpler alternatives: change the owned interface, Facade for subsystem simplification, anti-corruption layer for larger domain boundaries.

#### Bridge

Use when two dimensions vary independently, such as notification type and delivery provider.

Costs and risks: too many interfaces before variations are real; overly generic sides that lose domain meaning.

Simpler alternatives: Strategy for one varying behavior, Adapter for vendor mismatch, plain composition.

#### Composite

Use for natural part-whole trees: folders/files, UI nodes, rule groups, menus, org charts.

Costs and risks: meaningless child methods on leaves, uncontrolled cycles, hidden recursive cost.

Simpler alternatives: traversal functions, Visitor when operations vary more than structure, recursive database query.

#### Decorator

Use for additive behavior around the same interface: logging, metrics, caching, retry, auth checks, compression.

Costs and risks: stacked wrappers that obscure behavior, hidden performance cost, semantic mutation.

Simpler alternatives: middleware/interceptor, higher-order function, explicit service composition, Strategy for mutually exclusive behavior.

#### Facade

Use when many clients repeat a multi-service sequence and need a stable use-case entry point.

Costs and risks: god service, hidden errors or transaction boundaries, exposing every subsystem method.

Simpler alternatives: application service, module public API, refactor subsystem boundaries first.

#### Flyweight

Use only after measured memory pressure from many duplicate immutable objects.

Costs and risks: mutable shared state, confusing identity, extrinsic state complexity exceeding memory savings.

Simpler alternatives: immutable value cache, interning, query/data loading optimization.

#### Proxy

Use to control access while preserving the target interface: lazy objects, remote proxy, auth proxy, cache proxy, audit proxy.

Costs and risks: surprising remote latency/failure, unclear cache invalidation, lazy DB queries in loops.

Simpler alternatives: explicit service method, Decorator for additive behavior, repository for persistence access.

### Behavioral Patterns

| Pattern | Fits when | Avoid when |
|---|---|---|
| Chain of Responsibility | A request may be handled by one of many ordered handlers. | All steps must run; that is a pipeline. |
| Command | Actions need queueing, retry, undo, audit, authorization, scheduling, or transaction boundaries. | It only wraps a simple function without execution semantics. |
| Interpreter | A small stable grammar or DSL must be parsed and evaluated. | JSON/config, parser libraries, or rule engines are more appropriate. |
| Iterator | Traversal should not expose collection internals, or collection is lazy/remote/paginated/custom. | Native iteration already solves it. |
| Mediator | Many objects communicate in tangled many-to-many ways. | The mediator becomes a god coordinator. |
| Memento | State snapshots or undo are needed without exposing internals. | Snapshots are huge, unbounded, persistent, or resource-heavy. |
| Observer | Many subscribers react to one source event or state change. | Ordering, failure policy, and side effects are uncontrolled. |
| State | Object behavior and valid actions change by state. | A small stable enum or guard clauses are enough. |
| Strategy | Interchangeable algorithms or policies share one contract and are selected by context. | The branch is tiny, stable, or strategies are nearly identical. |
| Template Method | Algorithm skeleton is fixed but steps vary in subclasses. | Composition, callbacks, or pipeline are clearer. |
| Visitor | Object structure is stable but many operations over it vary. | Element types change often. |

#### Chain Of Responsibility

Use when handlers are tried in sequence and only one or some may handle the request, such as auth checks, validation selection, middleware-style matching, or support escalation.

Costs and risks: implicit order, shared request mutation, disappearing errors, unclear ownership.

Simpler alternatives: pipeline for mandatory steps, Strategy for one selected algorithm, rule engine for complex rules.

#### Command

Use when an action needs to be represented as a value/object with execution metadata.

Costs and risks: moving a function into an object without adding retry/undo/audit/idempotency/authorization value; mixing validation, persistence, and rendering.

Simpler alternatives: plain function, use-case service method, queue job payload plus handler.

#### Interpreter

Use for small stable grammars such as rule expressions, safe filters, formula evaluators, or tiny DSLs.

Costs and risks: accidental full programming language, poor parser/security, no sandboxing for user-provided expressions.

Simpler alternatives: existing parser, rules engine, Specification, predicate functions, config tables.

#### Iterator

Use when traversal needs lazy streaming, pagination, or representation hiding.

Costs and risks: rebuilding native iteration, hidden network/DB calls, mutation semantics during traversal.

Simpler alternatives: native iterator/generator, stream API, explicit pagination interface.

#### Mediator

Use when components directly call many peers and interaction rules are scattered.

Costs and risks: god coordinator, overly passive components, hidden flows.

Simpler alternatives: application service, event bus for event-driven communication, direct dependencies for simple stable interactions.

#### Memento

Use for bounded in-memory snapshots, editor history, checkpoints, or undo/redo while preserving encapsulation.

Costs and risks: huge histories, sensitive data in snapshots, stale external references, confusion with durable persistence or transactions.

Simpler alternatives: event sourcing for durable replay, database rollback, explicit patch/change log.

#### Observer

Use when a publisher should not know concrete subscribers and new subscribers can be added independently.

Costs and risks: hidden side effects, unclear ordering, subscriber failure policy gaps, recursive state changes, generic events like `SomethingChanged`.

Simpler alternatives: direct calls for critical synchronous workflow, domain event with explicit transaction boundary, durable message queue for async work.

#### State

Use when `switch(state)` appears across methods and each state has different allowed actions or transitions.

Costs and risks: state objects that do not own transition rules, persistence/concurrency gaps, bypassable transitions.

Simpler alternatives: transition table, finite state machine library, guard clauses for few stable states.

#### Strategy

Use when algorithms or policies are independently testable and selected by config, context, user choice, environment, or runtime condition.

Costs and risks: class/file explosion, vague contracts, nearly identical strategies, selection logic becoming more complex than behavior.

Simpler alternatives: function map, plain conditional, Template Method when a fixed skeleton and inheritance already fit.

#### Template Method

Use when many classes share the same high-level algorithm and only specific steps vary, and inheritance is already acceptable.

Costs and risks: fragile base class, too many hooks, subclasses breaking invariants, hidden control flow.

Simpler alternatives: Strategy, pipeline composition, higher-order functions or callbacks.

#### Visitor

Use when a structure such as an AST or document tree is stable, but operations like export, validation, rendering, or analysis grow.

Costs and risks: every new element type requires visitor updates, operation may belong naturally on the object, excessive access to internals.

Simpler alternatives: polymorphic methods, pattern matching, traversal functions.

## Common Bad Smells

- Pattern-first design: choosing Strategy, Factory, or Observer before identifying change pressure.
- One-class-per-pattern theater: many `Factory`, `Strategy`, `Manager`, and `Context` classes without clearer responsibility.
- Abstracting before the second use case: interfaces, plugins, and factories for one implementation.
- Pattern stacking: combining Factory, Strategy, Command, Decorator, and Observer for one small feature.
- Interface without contract: swappable in syntax, not in behavior.
- Singleton as global mutable state.
- Factory hiding bad domain modeling.
- Strategy explosion for tiny stable branches.
- Observer event soup with unclear ordering and side effects.
- Decorator stacks that are hard to debug.
- Facade becoming a god service.
- State machine without state ownership, persistence rules, or transition tests.
- Command without execution boundary.
- Adapter leaking third-party concepts.
- Pattern used to avoid deleting old code.

## Mixed Pattern Guidance

Recommend mixed patterns only when each pattern handles a separate pressure:

- Adapter + Strategy: normalize vendor APIs first, then choose among interchangeable policies.
- Factory Method + Strategy: create the right strategy when creation varies and behavior varies.
- Facade + Adapter: simplify a subsystem while protecting core code from vendor details.
- Command + Observer: execute/audit actions first, then publish explicit events after transaction boundaries.
- State + Strategy: state owns valid transitions, strategy handles state-specific interchangeable calculations.
- Composite + Visitor: tree structure is stable, operations over the tree vary.
- Decorator + Proxy: use carefully only when access control/lazy loading and additive behavior are genuinely separate.

If one simpler construct can express the whole design, do not recommend a mix.

## Required Output Format

First choose one result mode:

- **Pattern mode**: use the full format below only when evidence shows a stable variation point or boundary that benefits from a pattern.
- **No-pattern mode**: say `No GoF design pattern is justified here`, explain the evidence, give the smallest direct refactor, and omit Candidate Patterns, Rejected Patterns, Proposed Design, and Minimal Migration Steps unless they contain useful non-pattern guidance.

```md
## Summary

- ...

## Design Pressure Diagnosis

- Primary pressure: ...
- Evidence: ...
- Non-goals: ...

## Candidate Patterns

### 1. Pattern Name

- Fit:
- Why it may fit:
- Cost:
- Anti-pattern risk:

## Recommended Approach

- Pattern: ...
- Reason: ...
- Smallest useful design: ...

## Rejected Patterns

- Pattern: ...
- Reason: ...

## Proposed Design

### Responsibility Boundaries

- ...

### Data / Control Flow

1. ...
2. ...

### Error / Lifecycle Handling

- ...

### Testing Strategy

- Unit tests:
- Contract tests:
- Integration tests:

## Minimal Migration Steps

1. ...
2. ...
3. ...

## Overengineering Check

- Is there more than one real variation? ...
- Is the abstraction protecting a stable boundary? ...
- Can a simpler function/map/module solve this? ...
```

## Final Guardrail

If no design pattern is justified, say so directly.

Do not force a GoF pattern just because the user asked for one. A valid recommendation may be:

> No GoF design pattern is justified here. The smallest useful refactor is: ...

This is often the best answer when the code has no stable variation point, no repeated abstraction pressure, and no boundary that needs protection.
