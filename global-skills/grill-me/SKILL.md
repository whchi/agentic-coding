---
name: grill-me
description: Use when the user wants to stress-test a plan, design, architecture, or proposal through pointed questioning. Also use when the user explicitly asks to be grilled, challenged, or pushed to clarify assumptions, risks, tradeoffs, and missing decisions.
---

# Grill Me

Stress-test a plan by asking sharp, sequential questions that expose assumptions, risks, tradeoffs, and unresolved decisions.

## When to Use

Use this skill when:

- The user wants to stress-test a plan or design
- The user says `grill me` or asks for hard questions
- A proposal sounds plausible but still has unclear assumptions, gaps, or weak tradeoff analysis

Do not use this skill when:

- The user wants gentle brainstorming rather than adversarial review
- The task is already in execution and no longer needs design pressure-testing
- The open questions can be resolved faster by reading the code or docs directly

## Workflow

1. **Establish the target.** If the user hasn't provided a written plan or design artifact, ask them to describe the proposal briefly. Then restate back: what the plan proposes, what success looks like, and what the key decisions are. Do not start grilling until you have a clear target.

2. **Question one issue at a time.** Ask one sharp question per turn. Wait for the user's response before asking the next. Focus on assumptions, edge cases, dependencies, failure modes, and tradeoffs.

3. **Filter out answerable questions.** Before asking, check whether the codebase, documentation, or configuration can answer the question. If it can, inspect the evidence and skip asking — note the resolved issue and move on. Only ask questions the user uniquely holds the answer to.

4. **Provide your recommended answer.** With each question you do ask, state your own current recommendation and reasoning. This keeps the conversation grounded and prevents fishing without direction.

5. **Prioritize high-risk gaps.** Target questions that would change the design, scope, or feasibility if answered differently. Do not chase low-impact edge cases while major risks remain unexamined.

6. **Stop when coherent.** End when assumptions, decisions, and tradeoffs are explicit enough to move forward.

## Good Questions

Prefer questions like:

- What assumption fails first under real usage?
- What dependency is still implicit here?
- What happens when this workflow partially fails?
- Which choice becomes expensive to reverse later?
- What alternative did we reject, and why?

## Gotchas

- Do not ask multiple questions in one message
- Do not grill for the sake of tone; grill to improve the plan
- Do not ask the user things the codebase can already answer
- Do not get stuck in low-impact edge cases while major risks remain unresolved
- Do not challenge without also helping the user converge
