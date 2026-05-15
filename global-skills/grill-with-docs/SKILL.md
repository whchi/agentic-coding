---
name: grill-with-docs
description: Use when stress-testing a feature, refactor, PRD, architecture proposal, or engineering plan against project documentation, domain language, code evidence, CONTEXT.md, CONTEXT-MAP.md, and ADRs. Updates docs when stable terminology or decisions crystallize.
---

# Grill With Docs

Use this when ordinary grilling is not enough. The point is not to ask more questions; the point is to force alignment between the user's plan, the repository's documented language, existing decisions, and the code.

## Relationship To `grill-me`

Use `grill-me` for general plan stress-testing.

Use `grill-with-docs` when any of these matter:

- the repo has or needs `CONTEXT.md`
- domain terms are fuzzy, overloaded, or disputed
- ADRs or prior decisions may constrain the plan
- the plan must be checked against code evidence
- decisions should be captured as durable repo artifacts

## Workflow

1. Establish the target plan, feature, refactor, PRD, or architecture decision.
2. Inspect relevant repo evidence before asking questions:
   - `AGENTS.md`
   - `CONTEXT.md`
   - `CONTEXT-MAP.md`
   - `docs/adr/`
   - `docs/plans/`
   - nearby code, tests, and fixtures
3. Restate the plan using the repo's canonical language.
4. Ask one high-leverage question at a time, waiting for the user's answer before continuing.
5. For each question, include your recommended answer and why.
6. If the answer can be found in code or docs, inspect the repo instead of asking.
7. When terminology or decisions stabilize, update the appropriate repo artifact inline.

## Documentation Model

Most repos have one root context:

```text
/
├── CONTEXT.md
├── docs/
│   └── adr/
└── src/
```

Repos with multiple contexts use a root map:

```text
/
├── CONTEXT-MAP.md
├── docs/adr/              # system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/      # context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

Create files lazily, only when there is something real to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is accepted.

## During The Session

### Challenge The Glossary

When the user uses a term that conflicts with existing language in `CONTEXT.md`, call it out immediately.

Example: "Your glossary defines cancellation as X, but you seem to mean Y. Which is it?"

### Sharpen Fuzzy Language

When the user uses vague or overloaded terms, propose a precise canonical term.

Example: "You're saying account. Do you mean Customer or User? Those are different concepts here."

### Use Concrete Scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Prefer edge cases that force precision about concept boundaries, lifecycle, ownership, and failure modes.

### Cross-Reference Code

When the user states how something works, check whether the code agrees. If the code contradicts the stated domain model, surface the contradiction and ask which source should change.

### Update CONTEXT.md Inline

When a term is resolved, update `CONTEXT.md` immediately. Do not batch glossary updates until the end of the session. Use [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` is a glossary and shared language artifact. It is not a spec, scratch pad, implementation plan, or implementation detail dump.

### Offer ADRs Sparingly

Only offer an ADR when all three are true:

1. **Hard to reverse**: changing the decision later has meaningful cost.
2. **Surprising without context**: future readers will wonder why the code is shaped this way.
3. **Real trade-off**: there were genuine alternatives and one was chosen for specific reasons.

If any condition is missing, skip the ADR. Use [ADR-FORMAT.md](./ADR-FORMAT.md).

## Output Per Round

Return:

- current repo-grounded interpretation
- conflict, ambiguity, or decision being tested
- one question
- your recommended answer
- doc update needed, if any

Stop when the plan is coherent enough to implement or when the remaining questions require product/user input the repo cannot answer.
